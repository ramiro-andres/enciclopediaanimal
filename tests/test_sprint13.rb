# frozen_string_literal: true

# Pruebas del Sprint 13 — EP-18: Contenido clínico y calidad
#   - US-CON-06: Diccionario +100 términos (527→627)
#   - US-UX-19: Integrar ≥50 enlaces desde sugerencias_enlaces.json
#   - US-CON-07: Filtro región/país en explorador de razas
#   - US-DEV-05 + F4-01: Higiene repo (prune ramas + dependabot)

require 'json'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

# US-CON-06 — Expandir diccionario
class DictionarySprint13Test < Minitest::Test
  def setup
    @script = File.join(ROOT, 'scripts', 'data', 'expand_dictionary_sprint13.rb')
    @build = File.read(File.join(ROOT, 'scripts', 'data', 'build_medical_dictionary.rb'))
    @dict = JSON.parse(File.read(File.join(ROOT, 'data', 'diccionario_medicos.json')))
    @actualizar = File.read(File.join(ROOT, 'actualizar_datos.sh'))
  end

  def test_script_expand_dictionary_existe
    assert File.exist?(@script)
    assert_includes @build, 'expand_dictionary_sprint13'
    assert_includes @build, 'merge_sprint13_terms'
  end

  def test_cantidad_terminos_minima
    total = @dict['total_terminos'] || @dict['categorias'].sum { |c| c['terminos'].length }
    assert_operator total, :>=, 627, "Se requieren ≥627 términos (hay #{total})"
  end

  def test_categoria_clinica_especializada
    ids = @dict['categorias'].map { |c| c['id'] }
    assert_includes ids, 'clinica_especializada'
  end
end

# US-UX-19 — Enlaces clínicos integrados
class ClinicalLinksSprint13Test < Minitest::Test
  def setup
    @script = File.join(ROOT, 'scripts', 'data', 'integrate_suggested_links_sprint13.rb')
    @links = JSON.parse(File.read(File.join(ROOT, 'data', 'enlaces_clinicos.json')))
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @actualizar = File.read(File.join(ROOT, 'actualizar_datos.sh'))
  end

  def test_script_integracion_existe
    assert File.exist?(@script)
    assert_includes @actualizar, 'integrate_suggested_links_sprint13.rb'
  end

  def test_enlaces_integrados_minimo
    integrated = @links['sprint13_integrados'].to_i
    assert_operator integrated, :>=, 50, "Se requieren ≥50 enlaces integrados (hay #{integrated})"
    assert_operator @links['total_terminos_enlazados'].to_i, :>=, 235
  end

  def test_ui_enlaces_bidireccionales
    assert_includes @app, 'crossLinksForTerm'
    assert_includes @app, 'crossLinksForDisease'
    assert_includes @app, 'dictionary-term-link'
    assert_includes @app, 'disease-term-link'
  end
end

# US-CON-07 — Filtro región/país
class RegionFilterSprint13Test < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
    @data = JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
  end

  def test_filtro_region_en_ui
    assert_includes @html, 'id="regionFiltersSection"'
    assert_includes @html, 'id="regionFilters"'
    assert_includes @html, 'data-i18n="sidebar.region"'
    assert_includes @app, 'REGION_MACRO_GROUPS'
    assert_includes @app, 'matchesRegionFilter'
    assert_includes @app, 'renderRegionFilters'
  end

  def test_i18n_region_es_en
    %w[sidebar.region region.all region.countries region.macro.LATAM region.macro.Europa].each do |key|
      assert_includes @i18n, "'#{key}'"
    end
  end

  def test_razas_batch8_con_region
    breeds = @data['animales'].flat_map { |a| %w[pequena mediana grande].flat_map { |s| a['razas'][s] || [] } }
    batch8 = %w[criollo_peruano alpaca_peruana nelore_brasileiro hereford_uruguayo]
    batch8.each do |id|
      breed = breeds.find { |b| b['id'] == id }
      assert breed, "Falta raza batch8: #{id}"
      assert breed['region'], "Raza #{id} sin metadato region"
    end
  end

  def test_estilos_region
    assert_includes @css, '.region-filters'
    assert_includes @css, '.region-filter-heading'
  end
end

# US-DEV-05 + F4-01 — Higiene repo
class RepoHygieneSprint13Test < Minitest::Test
  def setup
    @prune = File.join(ROOT, 'scripts', 'setup', 'prune_merged_branches.sh')
    @dependabot = File.join(ROOT, '.github', 'dependabot.yml')
  end

  def test_script_prune_ramas
    assert File.exist?(@prune)
    content = File.read(@prune)
    assert_includes content, 'prune'
    assert_includes content, 'main'
    assert_includes content, '--dry-run'
  end

  def test_dependabot_github_actions_y_npm
    assert File.exist?(@dependabot)
    content = File.read(@dependabot)
    assert_includes content, 'github-actions'
    assert_includes content, 'npm'
    assert_includes content, 'weekly'
  end
end

# PWA Sprint 13
class Sprint13SwTest < Minitest::Test
  def test_sw_version_bump
    sw = File.read(File.join(ROOT, 'sw.js'))
    m = sw.match(/CACHE_VERSION\s*=\s*'atlas-v(\d+)'/)
    assert m, 'CACHE_VERSION atlas-vN no encontrado'
    assert_operator m[1].to_i, :>=, 13
  end
end
