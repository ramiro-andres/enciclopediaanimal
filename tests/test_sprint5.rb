# frozen_string_literal: true

# Pruebas del Sprint 5 — EP-10: Herramientas clínicas de bolsillo
#   - US-TOOL-01: Calculadora RER/MER
#   - US-TOOL-02: Índice de toxicología
#   - US-TOOL-03: Compartir/copiar enlace de ficha
#   - US-TOOL-04: Badges zoonóticos + calendario vacunación

require 'json'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

# US-TOOL-02 — Toxicología
class ToxicologiaDataTest < Minitest::Test
  def setup
    @json = JSON.parse(File.read(File.join(ROOT, 'data', 'toxicologia.json')))
    @js = File.read(File.join(ROOT, 'data', 'toxicologia.js'))
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
  end

  def test_json_tiene_sustancias_suficientes
    assert_operator @json['sustancias'].length, :>=, 15
  end

  def test_incluye_sustancias_clave_perros_gatos
    nombres = @json['sustancias'].map { |s| s['nombre'].downcase }
    assert nombres.any? { |n| n.include?('chocolate') }, 'Falta chocolate'
    assert nombres.any? { |n| n.include?('xilitol') }, 'Falta xilitol'
    assert nombres.any? { |n| n.include?('uva') }, 'Falta uvas/pasas'
    perro_tox = @json['sustancias'].select { |s| s['especies'].include?('perros') }
    gato_tox = @json['sustancias'].select { |s| s['especies'].include?('gatos') }
    assert_operator perro_tox.length, :>=, 8
    assert_operator gato_tox.length, :>=, 6
  end

  def test_js_sincronizado
    assert_includes @js, 'window.TOXICOLOGIA_DATA'
    assert_includes @js, '"chocolate"'
  end

  def test_vista_toxicologia_en_ui
    assert_includes @html, 'id="toxicologiaView"'
    assert_includes @html, 'data/toxicologia.js'
    assert_includes @app, 'showToxicologia'
    assert_includes @app, "parts[0] === 'toxicologia'"
  end

  def test_script_build_toxicologia
    script = File.join(ROOT, 'scripts', 'data', 'build_toxicologia.rb')
    assert File.exist?(script)
    assert_includes File.read(File.join(ROOT, 'actualizar_datos.sh')), 'build_toxicologia.rb'
  end
end

# US-TOOL-01 — RER/MER
class RerMerCalculatorTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @tools = File.read(File.join(ROOT, 'js', 'tools.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
  end

  def test_vista_rer_mer
    assert_includes @html, 'id="rerMerView"'
    assert_includes @app, 'showRerMer'
    assert_includes @app, "parts[0] === 'rer-mer'"
    assert_includes @app, 'calculateRer'
  end

  def test_formula_rer_y_factores_mer
    assert_match(/70 \* Math\.pow\(kg, 0\.75\)/, @tools)
    assert_includes @app, 'MER_FACTORS'
    assert_includes @tools, 'MER_FACTORS'
    assert_includes @app, 'kgToLb'
    assert_includes @app, 'lbToKg'
    assert_includes @app, 'rerMerUnit'
  end

  def test_disclaimer_educativo
    assert_includes @app, 'rer.disclaimer'
    assert_includes @i18n, "'rer.disclaimer'"
  end

  def test_enlace_desde_herramientas_y_header
    assert_includes @html, 'id="goToolsBtn"'
    assert_includes @html, 'id="openToolsCard"'
    assert_includes @app, 'showTools'
    assert_includes @app, "parts[0] === 'herramientas'"
  end
end

# US-TOOL-03 — Compartir ficha
class ShareFeatureTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
  end

  def test_boton_compartir_en_fichas
    assert_includes @app, 'renderShareButton'
    assert_includes @app, 'bindShareButtons'
    assert_includes @app, 'navigator.share'
    assert_includes @app, 'clipboard.writeText'
  end

  def test_toast_feedback
    assert_includes @html, 'id="toastContainer"'
    assert_includes @app, 'showToast'
    assert_includes @app, 'share.copied'
  end

  def test_url_con_hash
    assert_includes @app, 'window.location.origin'
    assert_includes @app, 'data-share-hash'
  end
end

# US-TOOL-04 — Zoonóticas y vacunación
class ZoonoticVaccinationTest < Minitest::Test
  def setup
    @data = JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
    @cal = JSON.parse(File.read(File.join(ROOT, 'data', 'calendario_vacunacion.json')))
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
  end

  def all_diseases
    list = []
    @data['animales'].each do |animal|
      %w[pequena mediana grande].each do |size|
        (animal.dig('razas', size) || []).each do |raza|
          (raza['enfermedades'] || []).each { |e| list << e }
        end
      end
    end
    list
  end

  def test_enfermedades_tienen_campo_zoonotica
    diseases = all_diseases
    assert diseases.any?, 'Sin enfermedades'
    diseases.each do |e|
      assert [true, false].include?(e['zoonotica']), "#{e['nombre']} sin zoonotica booleana"
    end
    zoonotic = diseases.count { |e| e['zoonotica'] }
    assert_operator zoonotic, :>=, 20, 'Debe haber enfermedades zoonóticas marcadas'
  end

  def test_script_mark_zoonotic
    script = File.join(ROOT, 'scripts', 'data', 'mark_zoonotic_diseases.rb')
    assert File.exist?(script)
  end

  def test_badge_zoonotico_en_ui
    assert_includes @app, 'renderZoonoticBadge'
    assert_includes @app, 'zoonotic-badge'
  end

  def test_calendario_vacunacion_por_especie
    assert @cal['especies'].is_a?(Hash)
    assert_operator @cal['especies'].length, :>=, 10
    %w[perros gatos].each do |id|
      esp = @cal['especies'][id]
      assert esp, "Falta calendario para #{id}"
      %w[cachorro adulto senior].each do |phase|
        assert esp[phase].is_a?(Array), "#{id}.#{phase} debe ser array"
        assert_operator esp[phase].length, :>=, 2
      end
    end
    assert @cal['disclaimer']
  end

  def test_calendario_en_ficha_raza
    assert_includes @app, 'renderVaccinationCalendar'
    assert_includes @html, 'calendario_vacunacion.js'
    assert File.exist?(File.join(ROOT, 'data', 'calendario_vacunacion.js'))
  end
end

# Service worker — nuevos datos en precache
class Sprint5ServiceWorkerTest < Minitest::Test
  def setup
    @sw = File.read(File.join(ROOT, 'sw.js'))
  end

  def test_precache_toxicologia_y_calendario
    assert_includes @sw, './data/toxicologia.js'
    assert_includes @sw, './data/calendario_vacunacion.js'
  end

  def test_cache_version_bump
    m = @sw.match(/CACHE_VERSION\s*=\s*'atlas-v(\d+)'/)
    assert m, 'CACHE_VERSION no encontrado'
    assert_operator m[1].to_i, :>=, 4
  end
end

# Urgencias enlaza toxicología
class UrgencyToxLinkTest < Minitest::Test
  def test_enlace_desde_urgencias
    app = File.read(File.join(ROOT, 'js', 'app.js'))
    assert_includes app, 'urgency-tox-btn'
    assert_includes app, 'showToxicologia'
  end
end
