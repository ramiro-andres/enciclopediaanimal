# frozen_string_literal: true

# Pruebas del Sprint 8 — EP-13: Herramientas y mapa de predisposiciones
#   - US-TOOL-05: Calculadora fluidoterapia de mantenimiento
#   - US-CON-09: Mapa de predisposiciones genéticas
#   - US-TOOL-06: Conversor de unidades clínicas
#   - US-UX-14: Tour de bienvenida

require 'json'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

# US-TOOL-05 — Fluidoterapia
class FluidoterapiaTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
  end

  def test_vista_fluidoterapia_en_ui
    assert_includes @html, 'id="fluidoterapiaView"'
    assert_includes @app, 'showFluidoterapia'
    assert_includes @app, "parts[0] === 'fluidoterapia'"
    assert_includes @app, 'renderFluidoterapia'
    assert_includes @app, 'FLUID_PROFILES'
    assert_includes @app, 'mlKgDay'
  end

  def test_perfiles_especies_clave
    assert_includes @app, "perros: { mlKgDay: 60"
    assert_includes @app, "gatos: { mlKgDay: 50"
    assert_includes @app, 'shockMin'
    assert_includes @app, 'shockMax'
  end

  def test_peso_kg_lb_y_disclaimer
    assert_includes @app, 'fluidUnit'
    assert_includes @app, 'lbToKg'
    assert_includes @app, 'fluid.disclaimer'
    assert_includes @i18n, "'fluid.disclaimer'"
    assert_includes @i18n, "'fluid.shock_title'"
  end

  def test_enlace_desde_herramientas
    assert_includes @app, "title: this.t('fluid.title')"
    assert_includes @app, 'showFluidoterapia()'
  end

  def test_estilos_fluidoterapia
    assert_includes @css, '.fluidoterapia-page'
    assert_includes @css, '.fluid-shock-panel'
  end
end

# US-TOOL-06 — Conversor de unidades
class UnidadesClinicasTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
  end

  def test_vista_unidades
    assert_includes @html, 'id="unidadesView"'
    assert_includes @app, 'showUnidades'
    assert_includes @app, "parts[0] === 'unidades'"
    assert_includes @app, 'renderUnidades'
    assert_includes @app, 'bindUnidadesConverter'
  end

  def test_conversiones_implementadas
    assert_includes @app, 'celsiusToFahrenheit'
    assert_includes @app, 'fahrenheitToCelsius'
    assert_includes @app, 'unitsMgInput'
    assert_includes @app, 'unitsDoseMgKg'
    assert_includes @app, 'unitsMlInput'
    assert_includes @app, 'unitsDropsFactor'
  end

  def test_factor_gotas_documentado
    assert_includes @app, 'unitsDropsFactor: 20'
    assert_includes @i18n, "'units.drops_macro'"
    assert_includes @i18n, "'units.drops_micro'"
    assert_includes @i18n, "'units.drops_note'"
  end

  def test_enlace_desde_calculadora_dosis
    assert_includes @app, 'dose-units-link'
    assert_includes @app, 'units.open_from_dose'
    assert_match(/dose-units-link.*showUnidades/, @app)
  end

  def test_enlace_desde_hub_herramientas
    assert_includes @app, "title: this.t('units.title')"
    assert_includes @app, 'showUnidades()'
  end
end

# US-CON-09 — Predisposiciones genéticas
class PredisposicionesMapTest < Minitest::Test
  def setup
    @enc = JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
  end

  def all_breeds
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

  def test_dataset_tiene_predisposiciones_en_razas
    breeds = all_breeds
    assert_operator breeds.length, :>=, 431
    with_predis = breeds.count { |b| b['predisposiciones_geneticas']&.any? }
    assert_operator with_predis, :>=, 400, 'La mayoría de razas deben tener predisposiciones'
  end

  def test_vista_predisposiciones
    assert_includes @html, 'id="predisposicionesView"'
    assert_includes @html, 'id="predisSearchInput"'
    assert_includes @html, 'id="predisAnimalFilters"'
    assert_includes @html, 'id="openPredisposicionesCard"'
    assert_includes @app, 'showPredisposiciones'
    assert_includes @app, "parts[0] === 'predisposiciones'"
    assert_includes @app, 'getPredisposicionesIndex'
    assert_includes @app, 'getFilteredPredisposiciones'
    assert_includes @app, 'renderPredisposiciones'
  end

  def test_filtros_y_enlaces_a_razas
    assert_includes @app, 'predisposicionesQuery'
    assert_includes @app, 'predisposicionesAnimal'
    assert_includes @app, 'predis-breed-link'
    assert_includes @app, 'showBreedDetail(breed)'
    assert_includes @app, 'predis.map_link'
  end

  def test_i18n_predisposiciones
    %w[predis.title predis.search predis.all_animals predis.view_breed predis.card_title].each do |key|
      assert_includes @i18n, "'#{key}'"
    end
  end
end

# US-UX-14 — Tour de bienvenida
class WelcomeTourTest < Minitest::Test
  def setup
    @html = File.read(File.join(ROOT, 'index.html'))
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
  end

  def test_overlay_tour_en_dom
    assert_includes @html, 'id="welcomeTourOverlay"'
    assert_includes @html, 'id="welcomeTourPopover"'
    assert_includes @html, 'id="welcomeTourSkipBtn"'
    assert_includes @html, 'id="welcomeTourNextBtn"'
  end

  def test_logica_tour_session_storage
    assert_includes @app, 'const WelcomeTour'
    assert_includes @app, "SESSION_KEY: 'atlas_welcome_tour_done'"
    assert_includes @app, 'sessionStorage.setItem(this.SESSION_KEY'
    assert_includes @app, 'WelcomeTour.tryStart'
  end

  def test_cinco_pasos_tour
    assert_includes @app, 'tour.step1.title'
    assert_includes @app, 'tour.step5.title'
    assert_includes @app, '#welcomeCategoryCards'
    assert_includes @app, '#favoritesPanel'
    steps_block = @app[/steps\(\) \{[\s\S]*?\n  \},/m]
    assert steps_block
    assert_operator steps_block.scan(/titleKey:/).length, :>=, 5
  end

  def test_i18n_tour
    %w[tour.skip tour.next tour.finish tour.step_label].each do |key|
      assert_includes @i18n, "'#{key}'"
    end
  end

  def test_estilos_tour
    assert_includes @css, '.welcome-tour-overlay'
    assert_includes @css, '.welcome-tour-highlight'
  end
end

# Integración Sprint 8
class Sprint8IntegrationTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @sitemap_script = File.read(File.join(ROOT, 'scripts', 'data', 'build_sitemap.rb'))
    @sw = File.read(File.join(ROOT, 'sw.js'))
  end

  def test_tab_bar_sincroniza_nuevas_vistas
    assert_includes @app, "fluidoterapia: 'tools'"
    assert_includes @app, "unidades: 'tools'"
    assert_includes @app, "predisposiciones: 'explore'"
  end

  def test_show_view_incluye_vistas_nuevas
    assert_includes @app, "view === 'fluidoterapia'"
    assert_includes @app, "view === 'unidades'"
    assert_includes @app, "view === 'predisposiciones'"
  end

  def test_sitemap_rutas_nuevas
    assert_includes @sitemap_script, "'fluidoterapia'"
    assert_includes @sitemap_script, "'unidades'"
    assert_includes @sitemap_script, "'predisposiciones'"
  end

  def test_cache_version_bump
    m = @sw.match(/CACHE_VERSION\s*=\s*'atlas-v(\d+)'/)
    assert m
    assert_operator m[1].to_i, :>=, 7
  end
end
