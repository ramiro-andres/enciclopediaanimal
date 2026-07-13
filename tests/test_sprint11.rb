# frozen_string_literal: true

# Pruebas del Sprint 11 — EP-16: Contenido clínico y rendimiento atlas
#   - US-CON-13: Rangos de laboratorio por especie (#laboratorio)
#   - US-UX-17: Raza de la semana en welcomeView
#   - US-DEV-14: Carga diferida por chunks (manifest + search_index)
#   - US-DEV-15: Detección de inconsistencias en CI

require 'json'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

# US-CON-13 — Rangos de laboratorio
class LabReferenceTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
    @json = JSON.parse(File.read(File.join(ROOT, 'data', 'lab_reference.json')))
    @js = File.read(File.join(ROOT, 'data', 'lab_reference.js'))
    @script = File.join(ROOT, 'scripts', 'data', 'build_lab_reference.rb')
  end

  def test_vista_laboratorio_en_ui
    assert_includes @html, 'id="laboratorioView"'
    assert_includes @html, 'data/lab_reference.js'
    assert_includes @app, 'showLaboratorio'
    assert_includes @app, "parts[0] === 'laboratorio'"
    assert_includes @app, 'renderLaboratorio'
    assert_includes @app, 'loadLabReferenceData'
  end

  def test_datos_por_especie_hemograma_y_bioquimica
    assert_operator @json['especies'].length, :>=, 6
    perros = @json['especies'].find { |s| s['id'] == 'perros' }
    assert perros, 'Debe existir especie perros'
    assert_operator perros['hemograma'].length, :>=, 5
    assert_operator perros['bioquimica'].length, :>=, 8
    assert_includes @json['disclaimer_es'], 'laboratorio'
  end

  def test_enlace_herramientas_y_glosario
    assert_includes @app, "title: this.t('lab.title')"
    assert_includes @app, 'showLaboratorio()'
    assert_includes @app, 'openLabFromDict'
    assert_includes @css, '.lab-table'
    assert_includes @css, '@media print'
  end

  def test_i18n_lab_es_en
    %w[lab.title lab.card_desc lab.hemogram lab.biochemistry lab.print].each do |key|
      assert_includes @i18n, "'#{key}'"
    end
  end

  def test_script_build_lab_reference
    assert File.exist?(@script)
    assert_includes @js, 'window.LAB_REFERENCE'
    assert_includes File.read(File.join(ROOT, 'actualizar_datos.sh')), 'build_lab_reference.rb'
  end
end

# US-UX-17 — Raza de la semana
class BreedOfWeekTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
  end

  def test_panel_en_welcome
    assert_includes @html, 'id="breedOfWeekPanel"'
    assert_includes @app, 'renderBreedOfWeek'
    assert_includes @app, 'getBreedOfWeekEntry'
    assert_includes @app, 'getWeekOfYear'
  end

  def test_rotacion_deterministica
    assert_includes @app, 'year * 53 + week'
    assert_includes @app, 'searchIndex'
  end

  def test_i18n_breed_week
    %w[breed_week.eyebrow breed_week.week breed_week.cta].each do |key|
      assert_includes @i18n, "'#{key}'"
    end
  end

  def test_estilos_breed_of_week
    assert_includes @css, '.breed-of-week-panel'
    assert_includes @css, '.breed-of-week-card'
  end
end

# US-DEV-14 — Chunks lazy load
class ChunksLazyLoadTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @sw = File.read(File.join(ROOT, 'sw.js'))
    @manifest = JSON.parse(File.read(File.join(ROOT, 'data', 'chunks', 'manifest.json')))
    @search_index = JSON.parse(File.read(File.join(ROOT, 'data', 'search_index.json')))
    @script = File.join(ROOT, 'scripts', 'data', 'build_chunks.rb')
    @chunks_dir = File.join(ROOT, 'data', 'chunks')
  end

  def test_script_build_chunks_existe
    assert File.exist?(@script)
    assert_includes File.read(File.join(ROOT, 'actualizar_datos.sh')), 'build_chunks.rb'
  end

  def test_chunks_por_animal_y_manifest_coherente
    @manifest['animales'].each do |animal|
      chunk_path = File.join(@chunks_dir, "#{animal['id']}.json")
      js_path = File.join(@chunks_dir, "#{animal['id']}.js")
      assert File.exist?(chunk_path), "Falta chunk #{animal['id']}.json"
      assert File.exist?(js_path), "Falta chunk #{animal['id']}.js"
      chunk = JSON.parse(File.read(chunk_path))
      assert_equal animal['id'], chunk['id']
      assert chunk['razas'].is_a?(Hash)
      actual = %w[pequena mediana grande].sum { |s| (chunk['razas'][s] || []).length }
      assert_equal animal['total_breeds'], actual,
                   "Manifest y chunk desincronizados para #{animal['id']}"
    end
  end

  def test_manifest_totales
    assert_operator @manifest['total_breeds'], :>=, 481
    assert_operator @manifest['total_diseases'], :>=, 2000
    assert_equal @manifest['animales'].length, 13
  end

  def test_search_index_coherente
    assert_equal @manifest['total_breeds'], @search_index['breeds'].length
    assert @search_index['breeds'].all? { |b| b['animalId'] && b['id'] && b['nombre'] }
  end

  def test_app_carga_manifest_y_chunks
    assert_includes @html, 'data/chunks/manifest.js'
    assert_includes @html, 'data/search_index.js'
    refute_includes @html, 'data/enciclopedia.js'
    assert_includes @app, 'loadChunk'
    assert_includes @app, 'loadChunkViaScript'
    assert_includes @app, 'preloadAllChunks'
    assert_includes @app, 'getGlobalSearchResultsFromIndex'
    assert_includes @app, 'buildDataFromManifest'
  end

  def test_sw_precache_manifest
    assert_includes @sw, 'data/chunks/manifest.js'
    assert_includes @sw, 'data/search_index.js'
    assert_match(/atlas-v1[123]/, @sw)
  end
end

# US-DEV-15 — Detección inconsistencias CI
class InconsistenciesCiTest < Minitest::Test
  def setup
    @script = File.join(ROOT, 'scripts', 'data', 'detect_inconsistencies.rb')
    @workflow = File.read(File.join(ROOT, '.github', 'workflows', 'test.yml'))
    @ejecutar = File.read(File.join(ROOT, 'ejecutar_pruebas.sh'))
  end

  def test_script_existe_y_cubre_casos
    content = File.read(@script)
    assert_includes content, 'dosis fuera de rango'
    assert_includes content, 'campo'
    assert_includes content, 'Descripción duplicada'
    assert_includes content, 'dosis_mg_kg'
  end

  def test_integrado_en_ci_y_suite_local
    assert_includes @workflow, 'detect_inconsistencies.rb'
    assert_includes @ejecutar, 'detect_inconsistencies.rb'
  end
end
