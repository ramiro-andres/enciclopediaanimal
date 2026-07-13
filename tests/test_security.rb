# frozen_string_literal: true

# Auditoría de seguridad estática — sitio sin backend (GitHub Pages).
# Complementa la suite funcional con checks de secretos, XSS, SW, workflows y datos.

require 'json'
require 'open3'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

def tracked_files
  @tracked_files ||= `git -C #{ROOT} ls-files`.split("\n").reject(&:empty?)
end

def read_repo(path)
  File.read(File.join(ROOT, path))
rescue Errno::ENOENT
  nil
end

def grep_repo(pattern, paths: nil, ignore_case: false)
  flags = ignore_case ? '-i' : ''
  scope = paths ? Array(paths).map { |p| File.join(ROOT, p) } : [ROOT]
  hits = []
  scope.each do |base|
    next unless File.exist?(base)

    if File.directory?(base)
      Dir.glob(File.join(base, '**', '*')).each do |file|
        next unless File.file?(file)
        next if file.include?('/node_modules/')
        next if file.include?('/.git/')

        content = File.read(file)
        re = ignore_case ? /#{pattern}/i : /#{pattern}/
        content.each_line.with_index(1) do |line, ln|
          hits << "#{file.sub(%r{^#{ROOT}/?}, '')}:#{ln}" if line.match?(re)
        end
      end
    else
      content = File.read(base)
      re = ignore_case ? /#{pattern}/i : /#{pattern}/
      content.each_line.with_index(1) do |line, ln|
        hits << "#{base.sub(%r{^#{ROOT}/?}, '')}:#{ln}" if line.match?(re)
      end
    end
  end
  hits
end

# ── Secretos y archivos sensibles ────────────────────────────────────────────
class SecretsSecurityTest < Minitest::Test
  SECRET_PATTERNS = [
    ['AWS access key', /AKIA[0-9A-Z]{16}/],
    ['GitHub PAT', /ghp_[a-zA-Z0-9]{36}/],
    ['GitHub fine-grained PAT', /github_pat_[a-zA-Z0-9_]{20,}/],
    ['OpenAI-style key', /sk-[a-zA-Z0-9]{20,}/],
    ['Generic API key assignment', /(?:api[_-]?key|secret[_-]?key|auth[_-]?token)\s*[:=]\s*['"][^'"]{8,}['"]/i]
  ].freeze

  SENSITIVE_TRACKED = %w[.env .env.local .env.production credentials.json id_rsa id_rsa.pub].freeze

  def test_no_archivos_sensibles_trackeados
    SENSITIVE_TRACKED.each do |name|
      refute_includes tracked_files, name, "Archivo sensible trackeado: #{name}"
    end
  end

  def test_sin_patrones_de_secretos_en_data_y_js
    scope = tracked_files.select { |f| f.start_with?('data/', 'js/') && f.match?(/\.(json|js)$/) }
    offenders = []
    scope.each do |rel|
      content = read_repo(rel)
      next unless content

      SECRET_PATTERNS.each do |label, pattern|
        offenders << "#{rel} (#{label})" if content.match?(pattern)
      end
    end
    assert_empty offenders, "Posibles secretos en repo:\n#{offenders.join("\n")}"
  end
end

# ── XSS estático en app.js ───────────────────────────────────────────────────
class XssStaticSecurityTest < Minitest::Test
  def setup
    @app = read_repo('js/app.js')
  end

  def test_sin_eval_ni_document_write
    refute_match(/\beval\s*\(/, @app, 'eval() detectado en app.js')
    refute_match(/\bdocument\.write\s*\(/, @app, 'document.write() detectado en app.js')
  end

  def test_metodo_esc_existe
    assert_match(/\besc\s*\(/, @app, 'Falta método esc() para escape HTML')
    assert_includes @app, '&amp;', 'esc() debe escapar ampersands'
    assert_includes @app, '&lt;', 'esc() debe escapar <'
  end

  def test_innerhtml_sin_interpolacion_cruda_de_errores
    # Regresión: err.message en innerHTML sin esc() permite XSS si el error es manipulado.
    err_lines = @app.each_line.with_index(1).select do |line, _|
      line.include?('innerHTML') && line.include?('${err.message}')
    end
    err_lines.each do |line, ln|
      refute line.include?('innerHTML') && line.include?('${err.message}') && !line.include?('esc(err'),
               "L#{ln}: err.message en innerHTML debe usar esc()"
    end
  end
end

# ── Datos JSON sin payloads script ───────────────────────────────────────────
class DataInjectionSecurityTest < Minitest::Test
  DANGEROUS = [
    /<script[\s>]/i,
    /javascript\s*:/i,
    /\bon(?:click|error|load|mouseover)\s*=/i
  ].freeze

  def test_json_datos_sin_etiquetas_script
    json_files = Dir.glob(File.join(ROOT, 'data', '**', '*.json'))
    offenders = []
    json_files.each do |path|
      text = File.read(path)
      DANGEROUS.each do |pattern|
        next unless text.match?(pattern)

        rel = path.sub(%r{^#{ROOT}/?}, '')
        offenders << "#{rel} (#{pattern.source})"
      end
    end
    assert_empty offenders, "Payloads peligrosos en datos JSON:\n#{offenders.join("\n")}"
  end

  def test_chunks_json_sin_script_tags
    Dir.glob(File.join(ROOT, 'data', 'chunks', '*.json')).each do |path|
      text = File.read(path)
      refute_match(/<script/i, text, "Chunk con <script: #{path}")
    end
  end
end

# ── Enlaces externos target=_blank ───────────────────────────────────────────
class ExternalLinksSecurityTest < Minitest::Test
  def test_target_blank_con_noopener_y_noreferrer
    files = tracked_files.select { |f| f.end_with?('.html', '.js') }
    offenders = []
    files.each do |rel|
      content = read_repo(rel)
      next unless content

      content.scan(/target\s*=\s*["']_blank["'][^>]*>/i) do |tag|
        unless tag.match?(/rel\s*=\s*["'][^"']*noopener[^"']*noreferrer/i) ||
               tag.match?(/rel\s*=\s*["'][^"']*noreferrer[^"']*noopener/i)
          offenders << "#{rel}: #{tag.strip[0, 80]}"
        end
      end
    end
    assert_empty offenders, "Enlaces _blank sin rel=noopener noreferrer:\n#{offenders.join("\n")}"
  end
end

# ── Service Worker ───────────────────────────────────────────────────────────
class ServiceWorkerSecurityTest < Minitest::Test
  def setup
    @sw = read_repo('sw.js')
  end

  def test_sw_solo_cachea_mismo_origen
    assert_includes @sw, 'url.origin !== self.location.origin'
    assert_includes @sw, "request.method !== 'GET'"
  end

  def test_sw_precache_sin_urls_externas
    urls = @sw.scan(/['"](\.\/[^'"]+)['"]/).flatten
    refute_empty urls
    urls.each do |u|
      refute_match(%r{^https?://}, u, "URL externa en precache: #{u}")
    end
  end

  def test_sw_limpia_caches_antiguas
    assert_includes @sw, 'caches.delete'
    assert_includes @sw, "k.startsWith('atlas-')"
  end
end

# ── Dependencias npm ─────────────────────────────────────────────────────────
class DependenciesSecurityTest < Minitest::Test
  def setup
    @pkg = JSON.parse(read_repo('package.json'))
  end

  def test_playwright_version_minima
    ver = @pkg.dig('devDependencies', '@playwright/test').to_s.delete_prefix('^').delete_prefix('~')
    major, minor = ver.split('.').map(&:to_i)
    assert_operator major, :>=, 1
    assert_operator minor, :>=, 40, "Playwright < 1.40 puede tener CVEs conocidos (#{ver})"
  end

  def test_sin_dependencias_runtime_innecesarias
    refute @pkg['dependencies'], 'Evitar dependencies de runtime en sitio estático'
  end
end

# ── Workflows GitHub Actions ─────────────────────────────────────────────────
class WorkflowSecurityTest < Minitest::Test
  WORKFLOWS = Dir.glob(File.join(ROOT, '.github', 'workflows', '*.yml')).freeze

  def test_workflows_con_permissions_explicitos
    WORKFLOWS.each do |path|
      content = File.read(path)
      assert_match(/permissions:/, content, "Falta permissions en #{File.basename(path)}")
      refute_includes content, 'write-all', "#{File.basename(path)} usa write-all"
    end
  end

  def test_test_workflow_solo_lectura
    wf = read_repo('.github/workflows/test.yml')
    assert_match(/contents:\s*read/, wf)
  end

  def test_deploy_sin_token_excesivo
    wf = read_repo('.github/workflows/deploy-pages.yml')
    refute_includes wf, 'GITHUB_TOKEN' # no hardcodear tokens
    assert_match(/contents:\s*read/, wf)
  end
end

# ── CSP (recomendación documentada) ──────────────────────────────────────────
class CspSecurityTest < Minitest::Test
  def setup
    @html = read_repo('index.html')
  end

  def test_csp_ausente_documentado
    has_csp = @html.match?(/Content-Security-Policy/i)
    # Sitio estático file:// + GitHub Pages: CSP estricta puede romper analytics locales.
    # El test documenta la recomendación sin forzar meta CSP en producción aún.
    skip 'CSP ya implementada' if has_csp

    doc = read_repo('docs/DESARROLLO.md')
    assert_includes doc, 'seguridad', 'Documentar suite de seguridad en DESARROLLO.md'
    assert_includes doc, 'CSP', 'Documentar recomendación CSP en DESARROLLO.md'
  end
end
