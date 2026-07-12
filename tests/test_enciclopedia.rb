# frozen_string_literal: true

require 'json'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__)

def load_json
  JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
end

def all_breeds(data)
  breeds = []
  data['animales'].each do |animal|
    %w[pequena mediana grande].each do |size|
      (animal.dig('razas', size) || []).each do |raza|
        breeds << raza.merge(
          'animalId' => animal['id'],
          'animalNombre' => animal['nombre'],
          'animalIcono' => animal['icono'],
          'tamano' => size
        )
      end
    end
  end
  breeds
end

def filter_breeds(breeds, animal: 'todos', size: 'todos', query: '')
  result = breeds.dup
  result = result.select { |b| b['animalId'] == animal } unless animal == 'todos'
  result = result.select { |b| b['tamano'] == size } unless size == 'todos'
  unless query.empty?
    q = query.downcase
    result = result.select do |b|
      text = [
        b['nombre'], b['descripcion'], b['animalNombre'],
        *(b['enfermedades'] || []).flat_map { |e| [e['nombre'], *(e['sintomas'] || [])] }
      ].join(' ').downcase
      text.include?(q)
    end
  end
  result
end

class DataIntegrityTest < Minitest::Test
  def setup
    @data = load_json
    @breeds = all_breeds(@data)
  end

  def test_json_es_valido
    assert @data.is_a?(Hash)
    assert @data['animales'].is_a?(Array)
  end

  def test_cantidad_minima_de_animales
    assert_operator @data['animales'].length, :>=, 10
  end

  def test_cantidad_minima_de_razas
    assert_operator @breeds.length, :>=, 140
  end

  def test_cada_animal_tiene_campos_requeridos
    @data['animales'].each do |animal|
      %w[id nombre icono razas].each do |field|
        assert animal[field], "Animal #{animal['id'] || '?'} sin campo #{field}"
      end
      assert animal['razas'].is_a?(Hash), "razas debe ser objeto en #{animal['id']}"
    end
  end

  def test_cada_raza_tiene_campos_requeridos
    required = %w[id nombre descripcion imagen origen esperanza_vida peso temperamento cuidados alimentacion historia caracteristicas aptitudes parametros_salud vacunacion desparasitacion senales_alerta revisiones emergencias enfermedades predisposiciones_geneticas cribado_salud_recomendado nutricion_clinica fuentes_bibliograficas]
    @breeds.each do |raza|
      required.each do |field|
        assert raza[field], "Raza #{raza['id']} (#{raza['animalId']}) sin #{field}"
      end
      assert raza['enfermedades'].length >= 5, "Raza #{raza['id']} debe tener al menos 5 enfermedades"
    end
  end

  def test_cada_enfermedad_tiene_campos_requeridos
    required = %w[nombre gravedad sintomas diagnostico tratamiento prevencion causas factores_riesgo examenes protocolo_farmacologico cuidados_casa evolucion pronostico urgencia diagnostico_diferencial criterios_diagnostico referencias notas_clinicas imagen]
    valid_gravedad = %w[leve moderada grave]
    @breeds.each do |raza|
      raza['enfermedades'].each do |enf|
        required.each do |field|
          assert enf[field], "Enfermedad en #{raza['id']} sin #{field}"
        end
        assert valid_gravedad.include?(enf['gravedad']), "Gravedad inválida en #{enf['nombre']}"
        assert enf['protocolo_farmacologico'].is_a?(Array) && enf['protocolo_farmacologico'].length >= 3, "Protocolo insuficiente en #{enf['nombre']}"
        enf['protocolo_farmacologico'].each do |p|
          %w[principio_activo nombre_comercial dosis_mg_kg via frecuencia duracion notas].each do |f|
            assert p[f], "Protocolo en #{enf['nombre']} sin #{f}"
          end
        end
        assert enf['diagnostico'].length > 50
        assert enf['tratamiento'].length > 50
        assert enf['prevencion'].length > 50
        refute enf['diagnostico'].include?('El veterinario realizará anamnesis detallada'),
               "Diagnóstico genérico en #{enf['nombre']} (#{raza['id']})"
        refute enf['sintomas'].any? { |s| s.match?(/signo clínico principal/i) },
               "Síntomas genéricos en #{enf['nombre']} (#{raza['id']})"
        assert enf['diagnostico_diferencial'].length >= 3, "Falta diagnóstico diferencial en #{enf['nombre']}"
        assert enf['referencias'].length >= 2, "Faltan referencias en #{enf['nombre']}"
      end
    end
  end

  def test_ids_de_razas_unicos_por_animal
    @data['animales'].each do |animal|
      ids = %w[pequena mediana grande].flat_map { |s| (animal.dig('razas', s) || []).map { |r| r['id'] } }
      assert_equal ids.length, ids.uniq.length, "IDs duplicados en #{animal['id']}"
    end
  end

  def test_imagenes_referenciadas_existen
    @breeds.each do |raza|
      path = File.join(ROOT, raza['imagen'])
      svg = path.sub(/\.jpg$/, '.svg')
      assert File.exist?(path) || File.exist?(svg),
             "Sin imagen para #{raza['id']}: #{raza['imagen']}"
    end
  end

  def test_imagenes_unicas_por_raza
    require 'digest'
    hashes = {}
    @breeds.each do |raza|
      jpg = File.join(ROOT, 'images', "#{raza['id']}.jpg")
      next unless File.exist?(jpg) && File.size(jpg) > 8000

      h = Digest::MD5.file(jpg).hexdigest
      refute hashes.key?(h), "Imagen duplicada: #{raza['id']} comparte foto con #{hashes[h]}"
      hashes[h] = raza['id']
    end
    assert_operator hashes.length, :>=, 200,
                    "Demasiadas razas sin imagen JPG única (#{hashes.length}/#{@breeds.length})"
  end

  def test_categorias_esperadas_presentes
    ids = @data['animales'].map { |a| a['id'] }
    %w[perros gatos aves equinos bovinos porcinos conejos reptiles peces].each do |cat|
      assert_includes ids, cat, "Falta categoría #{cat}"
    end
  end
end

class AppLogicTest < Minitest::Test
  def setup
    @data = load_json
    @breeds = all_breeds(@data)
  end

  def test_get_all_breeds_total
    assert_equal 355, @breeds.length
  end

  def test_filtro_por_animal_perros
    filtered = filter_breeds(@breeds, animal: 'perros')
    assert_equal 43, filtered.length
    assert filtered.all? { |b| b['animalId'] == 'perros' }
  end

  def test_filtro_por_animal_aves
    filtered = filter_breeds(@breeds, animal: 'aves')
    assert_equal 62, filtered.length
  end

  def test_filtro_por_tamano_pequena
    filtered = filter_breeds(@breeds, size: 'pequena')
    assert_operator filtered.length, :>, 10
    assert filtered.all? { |b| b['tamano'] == 'pequena' }
  end

  def test_busqueda_por_enfermedad
    filtered = filter_breeds(@breeds, query: 'displasia')
    assert_operator filtered.length, :>=, 5
  end

  def test_busqueda_por_raza
    filtered = filter_breeds(@breeds, query: 'chihuahua')
    assert_equal 1, filtered.length
    assert_equal 'chihuahua', filtered.first['id']
  end

  def test_filtro_combinado_sin_resultados
    filtered = filter_breeds(@breeds, animal: 'peces', size: 'grande', query: 'xyzinexistente')
    assert_empty filtered
  end

  def test_contar_enfermedades
    total = @breeds.sum { |b| b['enfermedades'].length }
    assert_operator total, :>=, 800
    assert_equal 2099, total
  end

  def test_razas_productivas_tienen_datos_zootecnicos
    productivas = @breeds.select { |b| b['enfoque_produccion'] }
    assert_equal 116, productivas.length

    required = %w[
      tipo_produccion sistema_productivo rendimiento_productivo
      indicadores_productivos manejo_productivo nutricion_productiva
      bioseguridad_productiva bienestar_productivo registros_productivos
      fuentes_produccion
    ]
    productivas.each do |raza|
      refute_match(/kg|años/, raza['origen'], "Origen inválido en #{raza['id']}")
      assert_match(/kg/, raza['peso'], "Peso inválido en #{raza['id']}")
      required.each do |field|
        refute_nil raza[field], "Raza productiva #{raza['id']} sin #{field}"
      end
      assert_operator raza['indicadores_productivos'].length, :>=, 4
      assert_operator raza['registros_productivos'].length, :>=, 5
      assert_operator raza['fuentes_produccion'].length, :>=, 2
    end
  end

  def test_enfermedades_tienen_imagen_asignada
    @breeds.each do |raza|
      raza['enfermedades'].each do |enf|
        assert enf['imagen'], "Enfermedad #{enf['nombre']} en #{raza['id']} sin imagen"
        assert_match(%r{^images/enfermedades/[a-z0-9_]+\.jpg$}, enf['imagen'])
      end
    end
  end

  def test_razas_tienen_nutricion_detallada
    required = %w[
      resumen tipos_dietas frecuencia_alimentacion porcion_diaria
      requerimientos_nutricionales alimentos_recomendados alimentos_evitar dietas_por_etapa
    ]
    @breeds.each do |raza|
      nut = raza['nutricion_detallada']
      refute_nil nut, "Raza #{raza['id']} sin nutricion_detallada"
      required.each { |field| refute_nil nut[field], "Raza #{raza['id']} sin nutricion_detallada.#{field}" }
      assert_operator nut['tipos_dietas'].length, :>=, 3
      assert_operator nut['requerimientos_nutricionales'].length, :>=, 3
      assert_operator nut['dietas_por_etapa'].length, :>=, 2
    end
  end
end

class HtmlStructureTest < Minitest::Test
  def setup
    @html = File.read(File.join(ROOT, 'index.html'))
  end

  def test_elementos_dom_requeridos
    %w[
      welcomeView welcomeCategoryCards welcomeIntro welcomeStats searchInputWelcome
      goHomeBtn goDictionaryBtn changeCategoryBtn btnExploreAll browseContext sizeFiltersSection
      dictionaryView dictionarySearchInput dictionaryList openDictionaryCard backDictionaryBtn
      searchInput animalNav breedGrid statsContent
      searchClearBtn searchResults browseSection focusSearchBtn
      homeView detailView diseaseView breedDetail diseaseDetail
      backBtn backDiseaseBtn resultsTitle resultsCount
    ].each do |id|
      assert_match(/id="#{id}"/, @html, "Falta elemento ##{id}")
    end
  end

  def test_scripts_requeridos
    assert_match(/src="data\/enciclopedia\.js"/, @html)
    assert_match(/src="data\/diccionario_medicos\.js"/, @html)
    assert_match(/src="js\/app\.js"/, @html)
  end

  def test_diccionario_medicos_existe_y_es_valido
    assert File.exist?(File.join(ROOT, 'data', 'diccionario_medicos.json'))
    dict = JSON.parse(File.read(File.join(ROOT, 'data', 'diccionario_medicos.json')))
    assert dict['categorias'].is_a?(Array)
    assert_operator dict['categorias'].length, :>=, 5
    terms = dict['categorias'].sum { |c| c['terminos'].length }
    assert_operator terms, :>=, 150
  end

  def test_diccionario_medicos_js_existe
    js = File.read(File.join(ROOT, 'data', 'diccionario_medicos.js'))
    assert_match(/window\.DICCIONARIO_MEDICOS\s*=/, js)
  end

  def test_enciclopedia_js_existe_y_es_valido
    js = File.read(File.join(ROOT, 'data', 'enciclopedia.js'))
    assert_match(/window\.ENCICLOPEDIA_DATA\s*=/, js)
    json = js.sub(/^window\.ENCICLOPEDIA_DATA\s*=\s*/, '').sub(/;\s*$/, '')
    data = JSON.parse(json)
    assert_equal 13, data['animales'].length
  end

  def test_app_exporta_estado_e2e
    js = File.read(File.join(ROOT, 'js', 'app.js'))
    assert_includes js, 'exportE2EState'
    assert_includes js, '__E2E_STATE__'
  end

  def test_filtros_de_tamano_en_html
    %w[todos pequena mediana grande].each do |size|
      assert_match(/data-size="#{size}"/, @html)
    end
  end
end

class AssetsTest < Minitest::Test
  def test_css_existe_y_tiene_reglas_clave
    css = File.read(File.join(ROOT, 'css', 'styles.css'))
    %w[.header .sidebar .breed-grid .breed-card .disease-card .empty-state .main-search-panel .search-results .dictionary-term-card .dictionary-page].each do |sel|
      assert_includes css, sel
    end
    assert_operator css.length, :>, 1000
  end

  def test_app_js_tiene_metodos_requeridos
    js = File.read(File.join(ROOT, 'js', 'app.js'))
    %w[
      init loadData getAllBreeds getFilteredBreeds renderBreeds
      showBreedDetail showDiseaseDetail showView sizeLabel
      enterBrowse goWelcome renderWelcome updateSidebar renderNutritionSection renderDiseaseImage
      showDictionary renderDictionary loadDictionaryData
    ].each do |method|
      assert_match(/#{method}\(/, js, "Falta método #{method}")
    end
  end

  def test_app_js_usa_data_key_compuesto
    js = File.read(File.join(ROOT, 'js', 'app.js'))
    assert_includes js, 'data-key="${b.animalId}:${b.id}"'
    assert_includes js, "card.dataset.key.split(':')"
  end

  def test_scripts_de_inicio_existen
    assert File.exist?(File.join(ROOT, 'iniciar.sh'))
    assert File.exist?(File.join(ROOT, 'actualizar_datos.sh'))
    assert File.exist?(File.join(ROOT, 'scripts', 'build_medical_dictionary.rb'))
  end

  def test_placeholder_existe
    assert File.exist?(File.join(ROOT, 'images', 'placeholder.svg'))
  end
end

class ServerIntegrationTest < Minitest::Test
  def setup
    @port = ENV['TEST_PORT'] || '8080'
    @base = "http://localhost:#{@port}"
  end

  def server_up?
    require 'net/http'
    uri = URI("#{@base}/index.html")
    Net::HTTP.get_response(uri).code == '200'
  rescue StandardError
    false
  end

  def test_servidor_sirve_index
    skip 'Servidor no activo en puerto 8080' unless server_up?
    require 'net/http'
    res = Net::HTTP.get_response(URI("#{@base}/index.html"))
    assert_equal '200', res.code
    assert_includes res.body, 'Enciclopedia Animal'
    assert_includes res.body, 'data/enciclopedia.js'
    assert_includes res.body, 'id="breedGrid"'
  end

  def test_servidor_sirve_app_js
    skip 'Servidor no activo en puerto 8080' unless server_up?
    require 'net/http'
    res = Net::HTTP.get_response(URI("#{@base}/js/app.js"))
    assert_equal '200', res.code
    assert_includes res.body, 'const App'
  end

  def test_servidor_sirve_css
    skip 'Servidor no activo en puerto 8080' unless server_up?
    require 'net/http'
    res = Net::HTTP.get_response(URI("#{@base}/css/styles.css"))
    assert_equal '200', res.code
  end

  def test_servidor_sirve_enciclopedia_js
    skip 'Servidor no activo en puerto 8080' unless server_up?
    require 'net/http'
    res = Net::HTTP.get_response(URI("#{@base}/data/enciclopedia.js"))
    assert_equal '200', res.code
    assert_includes res.body, 'window.ENCICLOPEDIA_DATA'
    assert_includes res.body, '"perros"'
  end

  def test_e2e_page_existe
    assert File.exist?(File.join(ROOT, 'tests', 'e2e_browser.html'))
    e2e = File.read(File.join(ROOT, 'tests', 'e2e_browser.html'))
    assert_includes e2e, '__E2E_RESULTS__'
    assert_includes e2e, 'runInteractionTests'
  end
end

# SECURITY_TEST: cambio no aprobado (simulación contribuidor externo)
