# frozen_string_literal: true

# Pruebas del Sprint 4 — EP-12: Producción confiable y offline real
#   - US-DEV-10: gate de deploy (deploy solo con test + e2e verdes)
#   - US-DEV-11: service worker completo (precache datos JS + imágenes SWR)
#   - US-DEV-12: hook pre-commit que regenera/valida JSON → JS
#   - US-DEV-13: Lighthouse CI con umbral de accesibilidad >= 90

require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

# US-DEV-11 — Service Worker
class ServiceWorkerTest < Minitest::Test
  def setup
    @sw = File.read(File.join(ROOT, 'sw.js'))
  end

  def cache_version
    m = @sw.match(/CACHE_VERSION\s*=\s*'atlas-v(\d+)'/)
    assert m, 'No se encontró CACHE_VERSION con formato atlas-vN'
    m[1].to_i
  end

  def test_cache_version_bump
    assert_operator cache_version, :>=, 3, 'CACHE_VERSION debe subir a atlas-v3 o superior'
  end

  def test_precache_incluye_datos_criticos
    %w[
      ./data/enciclopedia.js
      ./data/diccionario_medicos.js
      ./data/enlaces_clinicos.js
    ].each do |asset|
      assert_includes @sw, "'#{asset}'", "El precache debe incluir #{asset}"
    end
  end

  def test_precache_incluye_app_shell
    %w[
      ./index.html ./css/styles.css ./js/app.js ./manifest.webmanifest
    ].each do |asset|
      assert_includes @sw, "'#{asset}'", "El precache debe incluir #{asset}"
    end
  end

  def test_estrategia_stale_while_revalidate_imagenes
    assert_includes @sw, 'staleWhileRevalidate', 'Falta estrategia stale-while-revalidate'
    assert_includes @sw, 'IMAGE_CACHE', 'Falta caché específica de imágenes'
    assert_match(/isImageRequest/, @sw, 'Falta detección de peticiones de imagen')
  end

  def test_activate_limpia_caches_viejas
    assert_includes @sw, 'CURRENT_CACHES', 'activate debe conservar solo las cachés actuales'
    assert_match(/caches\.delete/, @sw)
  end

  def test_registro_en_index
    html = File.read(File.join(ROOT, 'index.html'))
    assert_match(/serviceWorker/, html)
    assert_match(/register\(\s*'sw\.js'\s*\)/, html)
  end
end

# US-DEV-10 — Gate de deploy
class DeployGateTest < Minitest::Test
  def setup
    @wf = File.read(File.join(ROOT, '.github', 'workflows', 'deploy-pages.yml'))
  end

  def test_no_dispara_directo_en_push
    refute_match(/^on:\s*\n\s*push:/m, @wf,
                 'El deploy no debe dispararse directamente en push a main')
  end

  def test_usa_workflow_run_sobre_test_y_e2e
    assert_includes @wf, 'workflow_run:', 'Debe usar el trigger workflow_run'
    assert_match(/workflows:\s*\[\s*"test"\s*,\s*"e2e"\s*\]/, @wf,
                 'workflow_run debe depender de "test" y "e2e"')
  end

  def test_tiene_puerta_de_calidad
    assert_includes @wf, 'should_deploy', 'Debe existir la salida de puerta should_deploy'
    assert_match(/needs\.gate\.outputs\.should_deploy == 'true'/, @wf,
                 'build debe condicionarse a la puerta de calidad')
  end

  def test_verifica_conclusiones_de_ambos_workflows
    assert_includes @wf, 'conclusion_for', 'Debe verificar la conclusión de cada workflow'
    assert_match(/actions: read/, @wf, 'Requiere permiso actions: read para consultar runs')
  end
end

# US-DEV-12 — Hook pre-commit JSON → JS
class PreCommitHookTest < Minitest::Test
  def test_hook_existe_y_es_ejecutable
    hook = File.join(ROOT, 'scripts', 'setup', 'pre-commit')
    assert File.exist?(hook), 'Falta scripts/setup/pre-commit'
    assert File.executable?(hook), 'El hook pre-commit debe ser ejecutable'
  end

  def test_instalador_existe
    inst = File.join(ROOT, 'scripts', 'setup', 'instalar_hooks.sh')
    assert File.exist?(inst), 'Falta scripts/setup/instalar_hooks.sh'
    assert_includes File.read(inst), '.git/hooks/pre-commit'
  end

  def test_hook_regenera_y_valida
    hook = File.read(File.join(ROOT, 'scripts', 'setup', 'pre-commit'))
    assert_includes hook, 'data/*.json', 'El hook debe detectar cambios en data/*.json'
    assert_includes hook, 'actualizar_datos.sh', 'El hook debe ejecutar actualizar_datos.sh'
    assert_includes hook, 'data/*.js', 'El hook debe validar los .js derivados'
  end

  def test_documentado_en_desarrollo
    doc = File.read(File.join(ROOT, 'docs', 'DESARROLLO.md'))
    assert_includes doc, 'instalar_hooks.sh', 'DESARROLLO.md debe documentar el hook'
  end
end

# US-DEV-13 — Lighthouse CI
class LighthouseCiTest < Minitest::Test
  def test_workflow_existe
    path = File.join(ROOT, '.github', 'workflows', 'lighthouse.yml')
    assert File.exist?(path), 'Falta workflow lighthouse.yml'
    wf = File.read(path)
    assert_includes wf, 'permissions:'
    assert_includes wf, 'contents: read'
    assert_match(/lighthouse-ci-action/, wf, 'Debe usar Lighthouse CI')
  end

  def test_config_umbral_accesibilidad
    require 'json'
    path = File.join(ROOT, 'lighthouserc.json')
    assert File.exist?(path), 'Falta lighthouserc.json'
    cfg = JSON.parse(File.read(path))
    a11y = cfg.dig('ci', 'assert', 'assertions', 'categories:accessibility')
    assert a11y, 'Falta la aserción de accesibilidad'
    assert_equal 'error', a11y[0], 'La accesibilidad debe bloquear (error)'
    assert_operator a11y[1]['minScore'], :>=, 0.9, 'El umbral A11y debe ser >= 0.90'
  end
end
