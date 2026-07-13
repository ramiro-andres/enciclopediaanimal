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
    assert_operator @breeds.length, :>=, 405
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
    assert_operator @breeds.length, :>=, 405
    assert_equal 431, @breeds.length
  end

  def test_filtro_por_animal_perros
    filtered = filter_breeds(@breeds, animal: 'perros')
    assert_operator filtered.length, :>=, 43
    assert filtered.all? { |b| b['animalId'] == 'perros' }
  end

  def test_filtro_por_animal_aves
    filtered = filter_breeds(@breeds, animal: 'aves')
    assert_operator filtered.length, :>=, 62
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
    assert_operator total, :>=, 2500
    assert_equal 2555, total
  end

  def test_razas_productivas_tienen_datos_zootecnicos
    productivas = @breeds.select { |b| b['enfoque_produccion'] }
    assert_equal 181, productivas.length

    required = %w[
      tipo_produccion sistema_productivo rendimiento_productivo
      indicadores_productivos manejo_productivo nutricion_productiva
      bioseguridad_productiva bienestar_productivo registros_productivos
      fuentes_produccion
    ]
    productivas.each do |raza|
      refute_match(/kg|años/, raza['origen'], "Origen inválido en #{raza['id']}")
      assert_match(/kg|g/, raza['peso'], "Peso inválido en #{raza['id']}")
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

  def test_modal_aviso_educativo
    assert_match(/role="dialog"/, @html)
    assert_match(/aria-labelledby="disclaimerTitle"/, @html)
    assert_match(/id="disclaimerAcceptBtn"/, @html)
    assert_match(/Aviso importante/, @html)
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
      disclaimerOverlay disclaimerModal disclaimerTitle disclaimerBody disclaimerAcceptBtn
    ].each do |id|
      assert_match(/id="#{id}"/, @html, "Falta elemento ##{id}")
    end
  end

  def test_scripts_requeridos
    assert_match(/src="data\/enciclopedia\.js"/, @html)
    assert_match(/src="data\/diccionario_medicos\.js"/, @html)
    assert_match(/src="js\/app\.js"/, @html)
  end

  def test_meta_tags_seo_y_open_graph
    assert_match(/<meta name="description"/, @html)
    assert_match(/property="og:title"/, @html)
    assert_match(/property="og:description"/, @html)
    assert_match(/property="og:image"/, @html)
    assert_match(/name="twitter:card"/, @html)
    assert File.exist?(File.join(ROOT, 'images', 'og-image.svg'))
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

  def test_meta_tags_seo_y_open_graph
    assert_match(/<meta name="description"/, @html)
    assert_match(/educativ/i, @html)
    assert_match(/property="og:title"/, @html)
    assert_match(/property="og:description"/, @html)
    assert_match(/property="og:image"/, @html)
    assert_match(/property="og:url"/, @html)
    assert_match(/name="twitter:card"/, @html)
    assert_match(/name="twitter:image"/, @html)
    assert_match(/images\/og-image\.svg/, @html)
  end

  def test_imagen_og_existe
    assert File.exist?(File.join(ROOT, 'images', 'og-image.svg'))
  end
end

class AssetsTest < Minitest::Test
  def test_css_existe_y_tiene_reglas_clave
    css = File.read(File.join(ROOT, 'css', 'styles.css'))
    %w[.header .sidebar .breed-grid .breed-card .disease-card .empty-state .main-search-panel .search-results .dictionary-term-card .dictionary-page .disclaimer-overlay .disclaimer-modal .dose-calculator-panel].each do |sel|
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
showDictionary renderDictionary loadDictionaryData openRouteFromHash updateHash diseaseRoute showDictionary renderDictionary loadDictionaryData
      renderDoseCalculator bindDoseCalculator calculateDoseForDrug getDoseCalculatorData
    ].each do |method|
      assert_match(/#{method}\(/, js, "Falta método #{method}")
    end
  end

  def test_app_js_tiene_rutas_hash_compartibles
    js = File.read(File.join(ROOT, 'js', 'app.js'))
    assert_includes js, '#glosario'
    assert_includes js, '#raza/'
    assert_includes js, '#enfermedad/'
    assert_includes js, "window.addEventListener('hashchange'"
    assert_includes js, 'window.location.hash'
  end

  def test_app_js_usa_data_key_compuesto
    js = File.read(File.join(ROOT, 'js', 'app.js'))
    assert_includes js, 'data-key="${b.animalId}:${b.id}"'
    assert_includes js, "card.dataset.key.split(':')"
  end

  def test_app_js_tiene_aviso_educativo
    js = File.read(File.join(ROOT, 'js', 'app.js'))
    assert_includes js, 'DisclaimerModal'
    assert_includes js, 'sessionStorage'
    assert_includes js, 'atlas_disclaimer_accepted'
  end

  def test_app_js_routing_por_hash
    js = File.read(File.join(ROOT, 'js', 'app.js'))
    %w[
      openRouteFromHash updateHash clearHash breedRoute diseaseRoute browseRoute
      diseaseSlug findBreed findDisease hashchange
    ].each do |fragment|
      assert_includes js, fragment, "Falta soporte de hash: #{fragment}"
    end
    assert_match(/#raza\//, js)
    assert_match(/#enfermedad\//, js)
    assert_includes js, '#glosario'
  end

  def test_plantillas_de_issues_existen
    %w[bug_report.yml content_request.yml feature_request.yml].each do |file|
      path = File.join(ROOT, '.github', 'ISSUE_TEMPLATE', file)
      assert File.exist?(path), "Falta plantilla #{file}"
    end
  end

  def test_workflow_ci_valida_json_js
    workflow = File.read(File.join(ROOT, '.github', 'workflows', 'test.yml'))
    assert_includes workflow, 'actualizar_datos.sh'
    assert_includes workflow, 'git diff --exit-code'
    assert_includes workflow, 'permissions:'
    assert_includes workflow, 'contents: read'
  end

  def test_workflow_deploy_tiene_permisos_minimos
    workflow = File.read(File.join(ROOT, '.github', 'workflows', 'deploy-pages.yml'))
    assert_includes workflow, 'permissions:'
    assert_includes workflow, 'contents: read'
    assert_includes workflow, 'pages: write'
    assert_includes workflow, 'id-token: write'
  end

  def test_scripts_de_inicio_existen
    assert File.exist?(File.join(ROOT, 'actualizar_datos.sh'))
    assert File.exist?(File.join(ROOT, 'ejecutar_pruebas.sh'))
    assert File.exist?(File.join(ROOT, 'scripts', 'data', 'build_medical_dictionary.rb'))
  end

  def test_placeholder_existe
    assert File.exist?(File.join(ROOT, 'images', 'placeholder.svg'))
  end
end

class WorkflowAndGovernanceTest < Minitest::Test
  def test_workflow_test_valida_js_derivados
    workflow = File.read(File.join(ROOT, '.github', 'workflows', 'test.yml'))
    assert_match(/permissions:\s*\n\s+contents: read/, workflow)
    assert_includes workflow, 'bash actualizar_datos.sh'
    assert_includes workflow, 'git diff --exit-code -- data/enciclopedia.js data/diccionario_medicos.js'
  end

  def test_workflow_deploy_usa_permisos_minimos
    workflow = File.read(File.join(ROOT, '.github', 'workflows', 'deploy-pages.yml'))
    assert_match(/permissions:\s*\n\s+contents: read\n\s+pages: write\n\s+id-token: write/, workflow)
    refute_includes workflow, 'write-all'
  end

  def test_plantillas_de_issues_existen
    templates = %w[bug_report.yml content_request.yml feature_request.yml]
    templates.each do |template|
      path = File.join(ROOT, '.github', 'ISSUE_TEMPLATE', template)
      assert File.exist?(path), "Falta plantilla #{template}"
      content = File.read(path)
      assert_includes content, 'name:'
      assert_includes content, 'body:'
    end
  end
end

class Sprint4BacklogTest < Minitest::Test
  def setup
    @data = load_json
    @breeds = all_breeds(@data)
  end

  def test_dependabot_configurado
    path = File.join(ROOT, '.github', 'dependabot.yml')
    assert File.exist?(path)
    content = File.read(path)
    assert_includes content, 'github-actions'
  end

  def test_favicon_y_apple_touch_icon
    html = File.read(File.join(ROOT, 'index.html'))
    assert_match(/rel="icon"/, html)
    assert_match(/apple-touch-icon/, html)
    assert File.exist?(File.join(ROOT, 'images', 'favicon.svg'))
    assert File.exist?(File.join(ROOT, 'images', 'apple-touch-icon.svg'))
  end

  def test_razas_latam_con_region
    latam = @breeds.select { |b| %w[México Argentina Chile].include?(b['region']) }
    assert_operator latam.length, :>=, 30, 'Se esperan al menos 30 razas LATAM con metadato region'
    %w[México Argentina Chile].each do |country|
      count = latam.count { |b| b['region'] == country }
      assert_operator count, :>=, 10, "Faltan razas de #{country}"
    end
  end

  def test_app_js_sprint4_features
    js = File.read(File.join(ROOT, 'js', 'app.js'))
    %w[
      showUrgency renderUrgency renderRecentHistory trackVisit
      renderRegionFilters getAvailableRegions protocol-accordion
      #urgencias sessionStorage
    ].each do |fragment|
      assert_includes js, fragment, "Falta feature Sprint 4: #{fragment}"
    end
  end

  def test_workflow_verifica_imagenes_y_deploy
    test_wf = File.read(File.join(ROOT, '.github', 'workflows', 'test.yml'))
    deploy_wf = File.read(File.join(ROOT, '.github', 'workflows', 'deploy-pages.yml'))
    assert_includes test_wf, 'list_missing_images.rb'
    assert_includes deploy_wf, 'curl'
    assert_includes deploy_wf, 'HTTP 200'
  end

  def test_codeowners_por_area
    owners = File.read(File.join(ROOT, '.github', 'CODEOWNERS'))
    %w[/data/ /js/ /scripts/ /docs/].each do |path|
      assert_includes owners, path
    end
  end

  def test_pr_template_checklist_clinica
    template = File.read(File.join(ROOT, '.github', 'pull_request_template.md'))
    assert_includes template, 'contenido clínico'
    assert_includes template, 'actualizar_datos.sh'
  end

  def test_scripts_latam_y_perfiles
    assert File.exist?(File.join(ROOT, 'scripts', 'data', 'production_breeds_batch7_latam.rb'))
    assert File.exist?(File.join(ROOT, 'scripts', 'data', 'production_breeds_batch7_international.rb'))
    assert File.exist?(File.join(ROOT, 'scripts', 'data', 'apply_region_tags.rb'))
    assert File.exist?(File.join(ROOT, 'scripts', 'data', 'apply_clinical_profiles.rb'))
    assert File.exist?(File.join(ROOT, 'scripts', 'setup', 'setup_github_labels.sh'))
  end
end

class Sprint3BacklogTest < Minitest::Test
  def setup
    @html = File.read(File.join(ROOT, 'index.html'))
    @js = File.read(File.join(ROOT, 'js', 'app.js'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
  end

  def test_pwa_manifest_y_service_worker
    assert File.exist?(File.join(ROOT, 'manifest.webmanifest'))
    assert File.exist?(File.join(ROOT, 'sw.js'))
    assert_match(/rel="manifest"/, @html)
    assert_match(/serviceWorker\.register/, @html)
    manifest = JSON.parse(File.read(File.join(ROOT, 'manifest.webmanifest')))
    assert manifest['icons'].length >= 2
    assert File.exist?(File.join(ROOT, 'docs', 'PWA.md'))
  end

  def test_i18n_es_en
    assert File.exist?(File.join(ROOT, 'js', 'i18n.js'))
    assert_match(/src="js\/i18n\.js"/, @html)
    i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
    assert_includes i18n, "'es'"
    assert_includes i18n, "'en'"
    assert_includes i18n, 'localStorage'
    assert_includes @js, 'I18n'
    assert_match(/data-lang="es"/, @html)
    assert File.exist?(File.join(ROOT, 'docs', 'I18N.md'))
  end

  def test_comparador_de_razas
    assert_match(/id="compareView"/, @html)
    assert_match(/id="goCompareBtn"/, @html)
    %w[showCompare renderCompare addToCompare compareList COMPARE_MAX].each do |frag|
      assert_includes @js, frag, "Falta comparador: #{frag}"
    end
    assert_includes @js, '#comparar'
    assert_includes @css, '.compare-grid'
  end

  def test_accesibilidad_wcag_basico
    assert_includes @css, '.skip-link'
    assert_includes @css, 'prefers-reduced-motion'
    assert_includes @css, ':focus-visible'
    assert_match(/id="mainContent"/, @html)
    assert_match(/role="main"/, @html)
    assert_match(/role="dialog"/, @html)
    assert_match(/aria-modal="true"/, @html)
  end

  def test_analytics_privacy_friendly
    assert File.exist?(File.join(ROOT, 'js', 'analytics.js'))
    assert File.exist?(File.join(ROOT, 'docs', 'PRIVACIDAD.md'))
    analytics = File.read(File.join(ROOT, 'js', 'analytics.js'))
    assert_includes analytics, 'GOATCOUNTER_ENDPOINT'
  end

  def test_validacion_clinica_script
    assert File.exist?(File.join(ROOT, 'scripts', 'data', 'validate_clinical_content.rb'))
    workflow_path = File.join(ROOT, '.github', 'workflows', 'test.yml')
    workflow = File.read(workflow_path)
    assert_includes workflow, 'validate_clinical_content.rb'
  end

  def test_contribuir_enlaza_plantillas
    contrib = File.read(File.join(ROOT, 'docs', 'CONTRIBUIR.md'))
    assert_match(/ISSUE_TEMPLATE|plantilla/i, contrib)
  end
end

class DoseCalculatorTest < Minitest::Test
  def setup
    @data = load_json
    @breeds = all_breeds(@data)
  end

  def test_cada_raza_tiene_calculadora_dosis
    @breeds.each do |raza|
      calc = raza['calculadora_dosis']
      refute_nil calc, "Raza #{raza['id']} sin calculadora_dosis"
      assert calc['peso_tipico_kg'].is_a?(Numeric) && calc['peso_tipico_kg'] > 0
      assert calc['farmacos'].is_a?(Array) && calc['farmacos'].length >= 3,
             "Raza #{raza['id']} con pocos fármacos en calculadora"
    end
  end

  def test_farmacos_calculadora_tienen_campos_requeridos
    required = %w[
      id principio_activo nombre_comercial dosis_texto calculable
      via frecuencia duracion notas enfermedad_origen origen
    ]
    @breeds.each do |raza|
      raza['calculadora_dosis']['farmacos'].each do |f|
        required.each { |field| refute_nil f[field], "Fármaco en #{raza['id']} sin #{field}" if field != 'calculable' }
        refute_nil f['calculable'], "Fármaco en #{raza['id']} sin calculable"
        if f['calculable']
          assert f['unidad'], "Fármaco calculable sin unidad en #{raza['id']}"
          assert f['min_por_kg'], "Fármaco calculable sin min_por_kg en #{raza['id']}"
          assert f['max_por_kg'], "Fármaco calculable sin max_por_kg en #{raza['id']}"
        end
      end
    end
  end

  def test_parse_dosis_mg_kg_rango
    require_relative '../scripts/data/build_dose_calculator'
    parsed = parse_dosis('0,5-1 mg/kg')
    assert parsed[:calculable]
    assert_equal 'mg/kg', parsed[:unidad]
    assert_in_delta 0.5, parsed[:min_por_kg], 0.001
    assert_in_delta 1.0, parsed[:max_por_kg], 0.001
  end

  def test_parse_dosis_ml_kg
    require_relative '../scripts/data/build_dose_calculator'
    parsed = parse_dosis('2-5 ml/kg')
    assert parsed[:calculable]
    assert_equal 'ml/kg', parsed[:unidad]
    assert_in_delta 2.0, parsed[:min_por_kg], 0.001
    assert_in_delta 5.0, parsed[:max_por_kg], 0.001
  end

  def test_parse_peso_tipico_chihuahua
    require_relative '../scripts/data/build_dose_calculator'
    peso = parse_peso_kg('1.5-3 kg')
    assert_in_delta 2.25, peso[:tipico], 0.01
    chihuahua = @breeds.find { |b| b['id'] == 'chihuahua' }
    assert_in_delta 2.25, chihuahua['calculadora_dosis']['peso_tipico_kg'], 0.01
  end

  def test_calculo_dosis_total_meloxicam_10kg
    drug = {
      'calculable' => true,
      'min_por_kg' => 0.1,
      'max_por_kg' => 0.1,
      'unidad' => 'mg/kg',
      'dosis_texto' => '0,1 mg/kg',
      'concentracion_mg_ml' => 1.5
    }
    min_total = drug['min_por_kg'] * 10
    max_total = drug['max_por_kg'] * 10
    assert_in_delta 1.0, min_total, 0.001
    assert_in_delta 1.0, max_total, 0.001
    volume = min_total / drug['concentracion_mg_ml']
    assert_in_delta 0.67, volume, 0.05
  end

  def test_app_js_tiene_calculadora_accesible
    js = File.read(File.join(ROOT, 'js', 'app.js'))
    assert_includes js, 'doseWeightInput'
    assert_includes js, 'doseDrugSelect'
    assert_includes js, 'aria-live="polite"'
    assert_includes js, 'Aviso educativo'
    assert_includes js, 'no sustituye el diagnóstico'
  end
end
