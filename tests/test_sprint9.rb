# frozen_string_literal: true

# Pruebas del Sprint 9 — EP-14: Contenido y herramientas atlas
#   - US-TOOL-07: Guía visual BCS (1-9 perro/gato, 1-5 equino)
#   - US-TOOL-08: Ampliar toxicología (+30 sustancias)
#   - US-CON-10: Directorio emergencias LATAM
#   - US-UX-15: Flashcards modo estudio del glosario

require 'json'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

# US-TOOL-07 — BCS
class BcsGuideTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
  end

  def test_vista_bcs_en_ui
    assert_includes @html, 'id="bcsView"'
    assert_includes @app, 'showBcs'
    assert_includes @app, "parts[0] === 'bcs'"
    assert_includes @app, 'renderBcs'
    assert_includes @app, 'renderBcsSvg'
  end

  def test_escalas_perro_gato_y_equino
    assert_includes @app, 'BCS_DOG_CAT_SCORES'
    assert_includes @app, 'BCS_EQUINE_SCORES'
    assert_includes @app, "bcsSpecies === 'equinos'"
    assert_includes @app, 'bcs.dog_cat.'
    assert_includes @app, 'bcs.equine.'
  end

  def test_svg_y_descripciones_i18n
    assert_includes @app, 'bcs-silhouette-svg'
    assert_includes @i18n, "'bcs.dog_cat.1'"
    assert_includes @i18n, "'bcs.dog_cat.9'"
    assert_includes @i18n, "'bcs.equine.5'"
    assert_includes @i18n, "'bcs.disclaimer'"
  end

  def test_enlace_desde_herramientas
    assert_includes @app, "title: this.t('bcs.title')"
    assert_includes @app, 'showBcs()'
  end

  def test_estilos_bcs
    assert_includes @css, '.bcs-page'
    assert_includes @css, '.bcs-silhouette-svg'
  end
end

# US-TOOL-08 — Toxicología ampliada
class ToxicologiaSprint9Test < Minitest::Test
  def setup
    @json = JSON.parse(File.read(File.join(ROOT, 'data', 'toxicologia.json')))
    @js = File.read(File.join(ROOT, 'data', 'toxicologia.js'))
    @script = File.join(ROOT, 'scripts', 'data', 'expand_toxicologia_sprint9.rb')
  end

  def test_al_menos_50_sustancias
    assert_operator @json['sustancias'].length, :>=, 50
  end

  def test_categorias_ampliadas
    cats = @json['sustancias'].map { |s| s['categoria'] }.uniq
    assert cats.include?('planta'), 'Debe haber plantas'
    assert cats.include?('alimento'), 'Debe haber alimentos'
    assert cats.include?('farmaco'), 'Debe haber medicamentos'
  end

  def test_nuevas_sustancias_clave
    ids = @json['sustancias'].map { |s| s['id'] }
    %w[difenhidramina sago_cycas oleandro aspirina_salicilatos].each do |id|
      assert_includes ids, id, "Falta sustancia #{id}"
    end
  end

  def test_script_expansion_y_js_sincronizado
    assert File.exist?(@script)
    assert_includes @js, 'window.TOXICOLOGIA_DATA'
    assert_includes @js, '"difenhidramina"'
  end
end

# US-CON-10 — Emergencias LATAM
class EmergenciasLatamTest < Minitest::Test
  def setup
    @json = JSON.parse(File.read(File.join(ROOT, 'data', 'emergencias_latam.json')))
    @js = File.read(File.join(ROOT, 'data', 'emergencias_latam.js'))
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
  end

  def test_json_paises_latam
    assert_operator @json['paises'].length, :>=, 8
    paises = @json['paises'].map { |p| p['id'] }
    %w[colombia mexico argentina chile peru].each do |id|
      assert_includes paises, id
    end
  end

  def test_colegios_y_lineas_por_pais
    @json['paises'].each do |p|
      assert p['colegios'].any?, "País #{p['id']} sin colegios"
      p['colegios'].each do |c|
        assert c['url'].to_s.start_with?('http'), "URL inválida en #{p['id']}"
      end
    end
  end

  def test_vista_y_carga_en_ui
    assert_includes @html, 'id="emergenciasLatamView"'
    assert_includes @html, 'data/emergencias_latam.js'
    assert_includes @app, 'showEmergenciasLatam'
    assert_includes @app, "parts[0] === 'emergencias-latam'"
    assert_includes @app, 'loadEmergenciasLatamData'
    assert_includes @app, 'renderEmergenciasLatam'
    assert_includes @js, 'window.EMERGENCIAS_LATAM'
  end

  def test_enlace_desde_urgencias
    assert_includes @app, 'urgency-emerg-latam-btn'
    assert_includes @app, 'emerg.urgency_link'
    assert_includes @i18n, "'emerg.open'"
  end

  def test_script_build_emergencias
    script = File.join(ROOT, 'scripts', 'data', 'build_emergencias_latam.rb')
    assert File.exist?(script)
    assert_includes File.read(File.join(ROOT, 'actualizar_datos.sh')), 'build_emergencias_latam.rb'
  end
end

# US-UX-15 — Flashcards
class FlashcardsStudyTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
  end

  def test_vista_flashcards
    assert_includes @html, 'id="flashcardsView"'
    assert_includes @app, 'showFlashcards'
    assert_includes @app, "parts[0] === 'flashcards'"
    assert_includes @app, 'renderFlashcards'
    assert_includes @app, 'buildFlashcardsDeck'
  end

  def test_barajar_y_progreso_local_storage
    assert_includes @app, 'shuffleArray'
    assert_includes @app, "FLASHCARDS_KEY: 'atlas_flashcards_progress'"
    assert_includes @app, 'localStorage.setItem(this.FLASHCARDS_KEY'
    assert_includes @app, 'flashcardsRevealed'
    assert_includes @app, 'flashcard--revealed'
  end

  def test_enlace_desde_glosario
    assert_includes @app, 'openFlashcardsFromDict'
    assert_includes @app, 'flash.open'
  end

  def test_i18n_flashcards
    %w[flash.title flash.shuffle flash.tap_reveal flash.mark_known flash.progress].each do |key|
      assert_includes @i18n, "'#{key}'"
    end
  end

  def test_estilos_flashcards
    assert_includes @css, '.flashcards-page'
    assert_includes @css, '.flashcard'
  end
end

# Integración Sprint 9
class Sprint9IntegrationTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @sitemap_script = File.read(File.join(ROOT, 'scripts', 'data', 'build_sitemap.rb'))
    @sw = File.read(File.join(ROOT, 'sw.js'))
  end

  def test_tab_bar_sincroniza_vistas_nuevas
    assert_includes @app, "bcs: 'tools'"
    assert_includes @app, "flashcards: 'glossary'"
    assert_includes @app, "emergenciasLatam: 'urgency'"
  end

  def test_show_view_incluye_vistas_nuevas
    assert_includes @app, "view === 'bcs'"
    assert_includes @app, "view === 'flashcards'"
    assert_includes @app, "view === 'emergenciasLatam'"
  end

  def test_sitemap_rutas_nuevas
    assert_includes @sitemap_script, "'bcs'"
    assert_includes @sitemap_script, "'flashcards'"
    assert_includes @sitemap_script, "'emergencias-latam'"
  end

  def test_cache_version_y_precache_emergencias
    m = @sw.match(/CACHE_VERSION\s*=\s*'atlas-v(\d+)'/)
    assert m
    assert_operator m[1].to_i, :>=, 8
    assert_includes @sw, 'emergencias_latam.js'
  end
end
