# frozen_string_literal: true

# Pruebas del Sprint 12 — EP-17: Comunidad y expansión contenido atlas
#   - US-UX-18: Changelog público (#changelog)
#   - US-CON-15: +50 razas batch 8 (≥481 razas)
#   - US-GOV-04: Sección Contribuye en footer
#   - US-DEV-16: Script sugerencias enlaces glosario↔enfermedad

require 'json'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

# US-UX-18 — Changelog público
class ChangelogPublicTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
    @script = File.join(ROOT, 'scripts', 'data', 'build_changelog.rb')
    @json_path = File.join(ROOT, 'data', 'changelog.json')
    @js_path = File.join(ROOT, 'data', 'changelog.js')
  end

  def test_vista_changelog_en_ui
    assert_includes @html, 'id="changelogView"'
    assert_includes @html, 'data/changelog.js'
    assert_includes @html, 'id="footerChangelogBtn"'
    assert_includes @html, 'id="welcomeChangelogBtn"'
    assert_includes @app, 'showChangelog'
    assert_includes @app, "parts[0] === 'changelog'"
    assert_includes @app, 'renderChangelog'
    assert_includes @app, 'loadChangelogData'
  end

  def test_datos_changelog_generados
    assert File.exist?(@script)
    assert File.exist?(@json_path)
    assert File.exist?(@js_path)
    json = JSON.parse(File.read(@json_path))
    assert json['entries'].is_a?(Array)
    assert_operator json['entries'].length, :>=, 1
    assert_includes File.read(@js_path), 'window.ATLAS_CHANGELOG'
    assert_includes File.read(File.join(ROOT, 'actualizar_datos.sh')), 'build_changelog.rb'
    assert File.exist?(File.join(ROOT, 'CHANGELOG.md'))
  end

  def test_i18n_changelog_es_en
    %w[changelog.link changelog.title changelog.intro contribute.title].each do |key|
      assert_includes @i18n, "'#{key}'"
    end
  end

  def test_estilos_changelog
    assert_includes @css, '.changelog-page'
    assert_includes @css, '.changelog-entry'
  end
end

# US-CON-15 — Batch 8 razas
class Batch8BreedsTest < Minitest::Test
  def setup
    @batch = File.join(ROOT, 'scripts', 'data', 'production_breeds_batch8.rb')
    @update = File.read(File.join(ROOT, 'scripts', 'data', 'update_enciclopedia_full.rb'))
    @manifest = JSON.parse(File.read(File.join(ROOT, 'data', 'chunks', 'manifest.json')))
    @search = JSON.parse(File.read(File.join(ROOT, 'data', 'search_index.json')))
  end

  def test_script_batch8_integrado
    assert File.exist?(@batch)
    assert_includes @update, 'production_breeds_batch8'
    assert_includes @update, 'PRODUCTION_BREED_EXTRA_BATCH8'
  end

  def test_cantidad_razas_minima
    assert_operator @manifest['total_breeds'], :>=, 481
    assert_equal @manifest['total_breeds'], @search['breeds'].length
  end

  def test_razas_latam_batch8_en_enciclopedia
    enc = JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
    ids = enc['animales'].flat_map { |a| %w[pequena mediana grande].flat_map { |s| (a['razas'][s] || []).map { |r| r['id'] } } }
    %w[criollo_peruano alpaca_peruana nelore_brasileiro hereford_uruguayo].each do |id|
      assert_includes ids, id, "Falta raza batch8: #{id}"
    end
  end
end

# US-GOV-04 — Footer Contribuye
class FooterContributeTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
  end

  def test_footer_contribuye_en_ui
    assert_includes @html, 'id="footerContribute"'
    assert_includes @html, 'class="footer-contribute"'
    assert_includes @app, 'renderFooterContribute'
    assert_includes @app, 'CONTRIBUTE_DOC_URL'
    assert_includes @app, 'GOOD_FIRST_ISSUE_URL'
    assert_includes @app, 'good+first+issue'
  end

  def test_stats_dinamicos_desde_manifest
    assert_includes @app, 'getCatalogStats()'
    assert_includes @app, 'footer-contribute-stats'
  end

  def test_i18n_contribute
    %w[contribute.title contribute.github contribute.guide contribute.good_first].each do |key|
      assert_includes @i18n, "'#{key}'"
    end
  end

  def test_estilos_footer_contribute
    assert_includes @css, '.footer-contribute'
    assert_includes @css, '.footer-contribute-stats'
  end
end

# US-DEV-16 — Sugerencias enlaces CI
class SuggestLinksCiTest < Minitest::Test
  def setup
    @script = File.join(ROOT, 'scripts', 'data', 'suggest_glossary_links.rb')
    @out = File.join(ROOT, 'data', 'sugerencias_enlaces.json')
    @workflow = File.read(File.join(ROOT, '.github', 'workflows', 'test.yml'))
    @ejecutar = File.read(File.join(ROOT, 'ejecutar_pruebas.sh'))
  end

  def test_script_genera_json_opcional
    assert File.exist?(@script)
    assert_includes File.read(@script), 'similitud'
    assert File.exist?(@out)
    data = JSON.parse(File.read(@out))
    assert data.key?('sugerencias')
    assert data.key?('nota')
  end

  def test_integrado_en_ci_y_suite_local
    assert_includes @workflow, 'suggest_glossary_links.rb'
    assert_includes @ejecutar, 'suggest_glossary_links.rb'
  end
end

# PWA Sprint 12
class Sprint12SwTest < Minitest::Test
  def test_sw_precache_changelog
    sw = File.read(File.join(ROOT, 'sw.js'))
    assert_includes sw, 'data/changelog.js'
    assert_includes sw, 'atlas-v11'
  end
end
