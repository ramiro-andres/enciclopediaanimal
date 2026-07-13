# frozen_string_literal: true

# US-UX-13 — Búsqueda con sinónimos y tolerancia a typos
require 'json'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

class SearchSynonymsDataTest < Minitest::Test
  def setup
    @json_path = File.join(ROOT, 'data', 'search_synonyms.json')
    @js_path = File.join(ROOT, 'data', 'search_synonyms.js')
    @data = JSON.parse(File.read(@json_path))
    @js = File.read(@js_path)
  end

  def test_archivo_json_valido_con_estructura
    assert_equal 1, @data['version']
    assert @data['terms'].is_a?(Hash)
    assert @data['by_category'].is_a?(Hash)
    assert_operator @data['stats']['canonical_terms'], :>=, 100
    assert_operator @data['stats']['categories'], :>=, 10
  end

  def test_js_expone_window_search_synonyms
    assert_includes @js, 'window.SEARCH_SYNONYMS'
    assert_match(/"parvovirus"/, @js)
  end

  def test_sinonimos_clinicos_ejemplo
    parvo = @data['terms']['parvovirus']
    assert_includes parvo, 'parvovirosis'
    assert_includes parvo, 'parvo'

    mastitis = @data['terms']['mastitis']
    assert mastitis, 'Debe existir entrada mastitis'
    assert_includes mastitis, 'inflamacion'
    assert_includes mastitis, 'mamaria'
  end

  def test_script_build_en_actualizar_datos
    script = File.read(File.join(ROOT, 'actualizar_datos.sh'))
    assert_includes script, 'build_search_index.rb'
  end
end

class SearchSynonymsUiTest < Minitest::Test
  def setup
    @html = File.read(File.join(ROOT, 'index.html'))
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
    @sw = File.read(File.join(ROOT, 'sw.js'))
  end

  def test_index_carga_search_synonyms_js
    assert_includes @html, 'data/search_synonyms.js'
  end

  def test_service_worker_precachea_sinonimos
    assert_includes @sw, 'search_synonyms.js'
    m = @sw.match(/CACHE_VERSION\s*=\s*'atlas-v(\d+)'/)
    assert m, 'CACHE_VERSION no encontrado'
    assert_operator m[1].to_i, :>=, 6
  end

  def test_logica_busqueda_en_app
    %w[
      loadSearchSynonyms
      buildSynonymIndex
      matchesSearch
      levenshtein
      findSynonymGroupFor
      matchesTypo
      renderSearchMatchHint
      search-glossary-list
    ].each do |needle|
      assert_includes @app, needle, "Falta #{needle} en app.js"
    end
  end

  def test_busqueda_global_incluye_glosario
    assert_includes @app, 'glossary.push'
    assert_includes @app, 'search.glossary_section'
  end

  def test_i18n_claves_busqueda_sinonimos
    %w[
      search.synonym_match
      search.typo_match
      search.glossary_section
      search.results_summary
      search.no_results
    ].each do |key|
      assert_includes @i18n, "'#{key}'"
    end
  end

  def test_estilos_resultados_sinonimos
    assert_includes @css, '.search-match-hint'
    assert_includes @css, '.search-glossary-item'
  end
end

class BuildSearchIndexScriptTest < Minitest::Test
  def test_script_genera_archivos
    script = File.join(ROOT, 'scripts', 'data', 'build_search_index.rb')
    assert File.exist?(script)
    output = `ruby "#{script}" 2>&1`
    assert_predicate $?, :success?, output
    assert_includes output, 'search_synonyms.json actualizado'
  end
end
