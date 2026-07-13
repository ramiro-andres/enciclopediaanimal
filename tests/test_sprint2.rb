# frozen_string_literal: true

# Pruebas del Sprint 2:
#   - US-UX-04: enlaces cruzados diccionario ↔ enfermedades
#   - US-DEV-04: infraestructura de pruebas E2E sin servidor
#   - US-DEV-09: workflow de vista previa (preview) + validaciones adicionales

require 'json'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

def s2_normalize(text)
  String(text).to_s.unicode_normalize(:nfd).gsub(/\p{Mn}/, '').downcase.strip
end

class EnlacesCruzadosTest < Minitest::Test
  def setup
    @path = File.join(ROOT, 'data', 'enlaces_clinicos.json')
    @enl = JSON.parse(File.read(@path))
    @enc = JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
    @dic = JSON.parse(File.read(File.join(ROOT, 'data', 'diccionario_medicos.json')))
  end

  def breeds
    @breeds ||= begin
      list = []
      @enc['animales'].each do |animal|
        %w[pequena mediana grande].each do |size|
          (animal.dig('razas', size) || []).each do |raza|
            list << raza.merge('animalId' => animal['id'])
          end
        end
      end
      list
    end
  end

  def test_estructura_del_indice
    assert @enl['por_termino'].is_a?(Hash), 'Falta índice por_termino'
    assert @enl['por_enfermedad'].is_a?(Hash), 'Falta índice por_enfermedad'
    assert_equal @enl['por_termino'].length, @enl['total_terminos_enlazados']
  end

  def test_al_menos_50_terminos_enlazados
    assert_operator @enl['total_terminos_enlazados'], :>=, 50,
                    "Se requieren >= 50 términos enlazados (hay #{@enl['total_terminos_enlazados']})"
  end

  def test_terminos_enlazados_existen_en_diccionario
    dict_terms = {}
    @dic['categorias'].each { |c| (c['terminos'] || []).each { |t| dict_terms[s2_normalize(t['termino'])] = true } }
    @enl['por_termino'].each_key do |key|
      assert dict_terms[key], "Término enlazado ausente del diccionario: #{key}"
    end
  end

  def test_ejemplos_apuntan_a_enfermedades_reales
    disease_index = {}
    breeds.each do |raza|
      (raza['enfermedades'] || []).each do |enf|
        disease_index["#{raza['animalId']}:#{raza['id']}:#{s2_normalize(enf['nombre'])}"] = true
      end
    end

    @enl['por_termino'].each_value do |info|
      (info['ejemplos'] || []).each do |ej|
        key = "#{ej['animalId']}:#{ej['breedId']}:#{s2_normalize(ej['nombre'])}"
        assert disease_index[key],
               "Enlace roto: '#{info['termino']}' -> enfermedad inexistente '#{ej['nombre']}'"
      end
    end
  end

  def test_indice_es_bidireccional
    assert_operator @enl['total_enfermedades_enlazadas'], :>=, 50
    @enl['por_enfermedad'].each_value do |entry|
      assert entry['terminos'].is_a?(Array)
      refute_empty entry['terminos'], "Enfermedad #{entry['nombre']} sin términos relacionados"
    end
  end

  def test_js_derivado_existe_y_sincronizado
    js_path = File.join(ROOT, 'data', 'enlaces_clinicos.js')
    assert File.exist?(js_path), 'Falta data/enlaces_clinicos.js'
    js = File.read(js_path)
    assert_match(/window\.ENLACES_CLINICOS\s*=/, js)
    derived = js.sub(/^window\.ENLACES_CLINICOS\s*=\s*/, '').sub(/;\s*\z/, '')
    assert_equal JSON.parse(File.read(@path)), JSON.parse(derived),
                 'enlaces_clinicos.js desincronizado (ejecuta actualizar_datos.sh)'
  end

  def test_generador_existe
    assert File.exist?(File.join(ROOT, 'scripts', 'data', 'build_cross_links.rb'))
  end
end

class EnlacesUiTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
  end

  def test_html_incluye_script_de_enlaces
    assert_match(%r{src="data/enlaces_clinicos\.js"}, @html)
  end

  def test_app_tiene_metodos_de_enlaces
    %w[
      loadCrossLinks crossLinksForTerm crossLinksForDisease
      renderTermDiseaseLinks renderDiseaseTermLinks
      openDiseaseFromLink openDictionaryWithTerm
    ].each do |method|
      assert_match(/#{method}\(/, @app, "Falta método de enlaces: #{method}")
    end
  end

  def test_app_renderiza_chips_bidireccionales
    assert_includes @app, 'dictionary-term-link'
    assert_includes @app, 'disease-term-link'
    assert_includes @app, "t('common.related_diseases')"
    assert_includes @app, "t('common.related_glossary')"
  end

  def test_css_tiene_estilos_de_enlaces
    css = File.read(File.join(ROOT, 'css', 'styles.css'))
    assert_includes css, '.cross-link-chip'
    assert_includes css, '.cross-link-chips'
  end
end

class E2eInfraTest < Minitest::Test
  def test_archivos_de_configuracion_e2e
    assert File.exist?(File.join(ROOT, 'package.json')), 'Falta package.json'
    assert File.exist?(File.join(ROOT, 'playwright.config.js')), 'Falta playwright.config.js'
    assert File.exist?(File.join(ROOT, 'tests', 'e2e', 'atlas.spec.js')), 'Falta spec E2E'
    assert File.exist?(File.join(ROOT, 'ejecutar_e2e.sh')), 'Falta ejecutar_e2e.sh'
  end

  def test_package_declara_playwright
    pkg = JSON.parse(File.read(File.join(ROOT, 'package.json')))
    assert pkg.dig('devDependencies', '@playwright/test'), 'package.json sin @playwright/test'
    assert pkg.dig('scripts', 'test:e2e'), 'package.json sin script test:e2e'
  end

  def test_spec_cubre_al_menos_3_flujos
    spec = File.read(File.join(ROOT, 'tests', 'e2e', 'atlas.spec.js'))
    flujos = spec.scan(/\btest\(/).length
    assert_operator flujos, :>=, 3, "Se requieren >= 3 flujos E2E (hay #{flujos})"
    assert_includes spec, 'file://'
    assert_includes spec, '__E2E_STATE__'
    refute_match(/localhost|127\.0\.0\.1|http-server/, spec, 'El E2E no debe depender de un servidor')
  end

  def test_spec_valida_enlaces_cruzados
    spec = File.read(File.join(ROOT, 'tests', 'e2e', 'atlas.spec.js'))
    assert_includes spec, 'dictionary-term-link'
  end

  def test_workflow_e2e_existe_y_no_usa_servidor
    path = File.join(ROOT, '.github', 'workflows', 'e2e.yml')
    assert File.exist?(path), 'Falta workflow e2e.yml'
    wf = File.read(path)
    assert_includes wf, 'permissions:'
    assert_includes wf, 'contents: read'
    assert_includes wf, 'playwright'
  end

  def test_app_exporta_conteo_de_enlaces_en_estado_e2e
    app = File.read(File.join(ROOT, 'js', 'app.js'))
    assert_includes app, 'crossLinkTerms'
  end
end

class PreviewYValidacionTest < Minitest::Test
  def test_workflow_preview_existe_con_permisos_minimos
    path = File.join(ROOT, '.github', 'workflows', 'preview.yml')
    assert File.exist?(path), 'Falta workflow preview.yml'
    wf = File.read(path)
    assert_match(/permissions:\s*\n\s+contents: read/, wf)
    assert_includes wf, 'validar_integridad.rb'
    assert_includes wf, 'upload-artifact'
    refute_includes wf, 'write-all'
  end

  def test_script_validacion_existe
    assert File.exist?(File.join(ROOT, 'scripts', 'setup', 'validar_integridad.rb'))
  end

  def test_workflow_test_valida_sincronizacion_de_enlaces
    wf = File.read(File.join(ROOT, '.github', 'workflows', 'test.yml'))
    assert_includes wf, 'actualizar_datos.sh'
    assert_includes wf, 'data/enlaces_clinicos.js'
    assert_includes wf, 'validar_integridad.rb'
  end

  def test_actualizar_datos_genera_enlaces
    sh = File.read(File.join(ROOT, 'actualizar_datos.sh'))
    assert_includes sh, 'build_cross_links.rb'
    assert_includes sh, 'enlaces_clinicos.js'
  end
end
