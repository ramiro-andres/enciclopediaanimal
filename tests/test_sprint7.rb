# frozen_string_literal: true

# Pruebas del Sprint 7 — EP-13: UX Atlas público
#   - US-UX-09: Tab bar móvil
#   - US-UX-10: Favoritos localStorage
#   - US-UX-11: Vista de impresión
#   - US-UX-12: Disclaimer por sesión
#   - US-CON-08: Fuentes bibliográficas en diseaseView

require 'json'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

# US-UX-09 — Tab bar móvil
class MobileTabBarTest < Minitest::Test
  def setup
    @html = File.read(File.join(ROOT, 'index.html'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
  end

  def test_tab_bar_en_index_con_cinco_pestanas
    assert_includes @html, 'id="mobileTabBar"'
    assert_includes @html, 'role="navigation"'
    assert_includes @html, 'data-tab="welcome"'
    assert_includes @html, 'data-tab="explore"'
    assert_includes @html, 'data-tab="glossary"'
    assert_includes @html, 'data-tab="urgency"'
    assert_includes @html, 'data-tab="tools"'
    assert_includes @html, 'data-i18n="tab.home"'
    assert_includes @html, 'data-i18n="tab.explore"'
    assert_includes @html, 'data-i18n="tab.glossary"'
    assert_includes @html, 'data-i18n="tab.urgency"'
    assert_includes @html, 'data-i18n="tab.tools"'
  end

  def test_estilos_movil_safe_area_y_aria
    assert_match(/@media \(max-width: 768px\)/, @css)
    assert_includes @css, '.mobile-tab-bar'
    assert_includes @css, 'safe-area-inset-bottom'
    assert_includes @css, 'aria-current'
    assert_includes @css, '.mobile-tab--active'
  end

  def test_logica_tab_bar_en_app
    assert_includes @app, 'bindMobileTabBar'
    assert_includes @app, 'updateMobileTabBar'
    assert_includes @app, 'mobileTabForView'
    assert_includes @app, 'showDictionary'
    assert_includes @app, 'showUrgency'
    assert_includes @app, 'showTools'
    assert_includes @app, 'enterBrowse'
  end

  def test_i18n_tab_bar
    %w[tab.home tab.explore tab.glossary tab.urgency tab.tools tab.nav].each do |key|
      assert_includes @i18n, "'#{key}'"
    end
  end
end

# US-UX-10 — Favoritos
class FavoritesTest < Minitest::Test
  def setup
    @html = File.read(File.join(ROOT, 'index.html'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
  end

  def test_panel_favoritos_en_welcome
    assert_includes @html, 'id="favoritesPanel"'
    assert_includes @html, 'id="favoritesList"'
    assert_includes @html, 'id="clearFavoritesBtn"'
    assert_includes @html, 'data-i18n="favorites.title"'
  end

  def test_localstorage_y_botones_en_fichas
    assert_includes @app, "FAVORITES_KEY: 'atlas_favorites'"
    assert_includes @app, 'localStorage.getItem(this.FAVORITES_KEY)'
    assert_includes @app, 'renderFavoriteButton'
    assert_includes @app, 'bindFavoriteButtons'
    assert_includes @app, 'toggleFavorite'
    assert_includes @app, 'renderFavorites'
    assert_includes @app, 'renderPrintButton' # coexiste en hero actions
    assert_match(/renderFavoriteButton/, @app)
    assert_match(/bindFavoriteButtons\(el\)/, @app)
  end

  def test_estilos_favoritos
    assert_includes @css, '.favorites-panel'
    assert_includes @css, '.btn-favorite'
    assert_includes @css, '.favorite-item'
  end

  def test_i18n_favoritos
    %w[favorites.title favorites.clear favorites.add favorites.remove favorites.added favorites.removed].each do |key|
      assert_includes @i18n, "'#{key}'"
    end
  end
end

# US-UX-11 — Impresión
class PrintViewTest < Minitest::Test
  def setup
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
  end

  def test_media_print_oculta_chrome
    assert_match(/@media print/, @css)
    assert_includes @css, '.header'
    assert_includes @css, '.mobile-tab-bar'
    assert_includes @css, '.sidebar'
    assert_includes @css, '.btn-print'
    assert_includes @css, 'display: none !important'
  end

  def test_boton_imprimir_y_disclaimer_en_fichas
    assert_includes @app, 'renderPrintButton'
    assert_includes @app, 'bindPrintButtons'
    assert_includes @app, 'renderPrintDisclaimer'
    assert_includes @app, 'window.print()'
    assert_includes @app, 'print.disclaimer'
    assert_includes @css, '.print-disclaimer'
  end

  def test_i18n_impresion
    assert_includes @i18n, "'print.button'"
    assert_includes @i18n, "'print.label'"
    assert_includes @i18n, "'print.disclaimer'"
  end
end

# US-UX-12 — Disclaimer por sesión
class SessionDisclaimerTest < Minitest::Test
  def setup
    @html = File.read(File.join(ROOT, 'index.html'))
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
  end

  def test_modal_disclaimer_en_dom
    assert_includes @html, 'id="disclaimerOverlay"'
    assert_includes @html, 'id="disclaimerModal"'
    assert_includes @html, 'id="disclaimerAcceptBtn"'
  end

  def test_session_storage_al_aceptar
    assert_includes @app, 'SESSION_KEY: \'atlas_disclaimer_accepted\''
    assert_includes @app, 'sessionStorage.getItem(this.SESSION_KEY)'
    assert_includes @app, 'sessionStorage.setItem(this.SESSION_KEY'
    assert_includes @app, 'wasAccepted()'
  end
end

# US-CON-08 — Fuentes bibliográficas
class BibliographicSourcesTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
    @enc = JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
  end

  def test_render_bibliograficas_en_disease_view
    assert_includes @app, 'renderBibliographicSources'
    assert_match(/fuentes_bibliograficas \|\| disease\.referencias/, @app)
    assert_includes @app, 'sources.title'
    assert_includes @css, '.bibliographic-sources'
  end

  def test_datos_tienen_referencias_en_enfermedades
    count = 0
    @enc['animales'].each do |animal|
      razas = animal['razas']
      next unless razas
      breed_list = razas.is_a?(Hash) ? razas.values.flatten : razas
      breed_list.each do |raza|
        raza['enfermedades']&.each do |enf|
          sources = enf['fuentes_bibliograficas'] || enf['referencias']
          count += 1 if sources&.any?
        end
      end
    end
    assert_operator count, :>=, 100, 'Debe haber enfermedades con referencias bibliográficas en datos'
  end

  def test_i18n_fuentes
    assert_includes @i18n, "'sources.title'"
  end
end
