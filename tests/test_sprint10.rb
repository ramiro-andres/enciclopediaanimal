# frozen_string_literal: true

# Pruebas del Sprint 10 — EP-15: Atlas clínico avanzado
#   - US-TOOL-09: Asistente triaje educativo (#triaje)
#   - US-CON-11: Fuentes bibliográficas ampliadas
#   - US-UX-16: Modo lectura nocturno
#   - US-CON-12: Resúmenes modo estudio (resumen_1min)

require 'json'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

# US-TOOL-09 — Triaje educativo
class TriajeEducativoTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
    @json = JSON.parse(File.read(File.join(ROOT, 'data', 'triaje.json')))
    @js = File.read(File.join(ROOT, 'data', 'triaje.js'))
  end

  def test_vista_triaje_en_ui
    assert_includes @html, 'id="triajeView"'
    assert_includes @html, 'data/triaje.js'
    assert_includes @app, 'showTriaje'
    assert_includes @app, "parts[0] === 'triaje'"
    assert_includes @app, 'renderTriaje'
    assert_includes @app, 'loadTriajeData'
  end

  def test_arbol_estatico_tres_niveles_minimo
    assert_operator @json['categorias'].length, :>=, 3
    cat = @json['categorias'].first
    assert cat['sintomas'].any?
    assert cat['sintomas'].first['causas'].any?
    causa = cat['sintomas'].first['causas'].first
    assert causa['gravedad']
    assert causa['accion_es']
    assert causa['accion_en']
  end

  def test_disclaimer_sin_diagnostico
    assert_includes @app, 'triaje.disclaimer'
    assert_includes @json['disclaimer_es'], 'No'
    assert_includes @i18n, "'triaje.disclaimer'"
  end

  def test_enlace_desde_herramientas_y_urgencias
    assert_includes @app, "title: this.t('triaje.title')"
    assert_includes @app, 'showTriaje()'
    assert_includes @app, 'urgency-triaje-btn'
    assert_includes @app, 'triaje.urgency_link'
  end

  def test_i18n_triaje_es_en
    %w[triaje.title triaje.card_desc triaje.severity.grave triaje.restart].each do |key|
      assert_includes @i18n, "'#{key}'"
    end
  end

  def test_estilos_triaje
    assert_includes @css, '.triaje-page'
    assert_includes @css, '.triaje-card'
    assert_includes @css, '.triaje-severity--grave'
  end

  def test_script_build_triaje
    script = File.join(ROOT, 'scripts', 'data', 'build_triaje.rb')
    assert File.exist?(script)
    assert_includes @js, 'window.TRIAJE_DATA'
    assert_includes File.read(File.join(ROOT, 'actualizar_datos.sh')), 'build_triaje.rb'
  end
end

# US-CON-11 — Bibliografía ampliada
class BibliografiaSprint10Test < Minitest::Test
  def setup
    @enc = JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @script = File.join(ROOT, 'scripts', 'data', 'expand_bibliografia_sprint10.rb')
  end

  def test_script_expansion_existe
    assert File.exist?(@script)
    assert_includes File.read(File.join(ROOT, 'actualizar_datos.sh')), 'expand_bibliografia_sprint10.rb'
  end

  def test_cobertura_referencias_al_menos_30_porciento
    total = 0
    with_refs = 0
    @enc['animales'].each do |animal|
      animal['razas'].each_value do |razas|
        razas.each do |raza|
          (raza['enfermedades'] || []).each do |enf|
            total += 1
            refs = enf['referencias'] || enf['fuentes_bibliograficas']
            with_refs += 1 if refs.is_a?(Array) && refs.any?
          end
        end
      end
    end
    pct = (with_refs * 100.0 / total)
    assert_operator pct, :>=, 30.0, "Solo #{pct.round(1)}% con referencias"
  end

  def test_referencias_enriquecidas_objeto
    found = false
    @enc['animales'].each do |animal|
      animal['razas'].each_value do |razas|
        razas.each do |raza|
          (raza['enfermedades'] || []).each do |enf|
            next unless enf['nombre'] == 'Hipoglucemia'
            refs = enf['referencias'] || []
            found = refs.any? { |r| r.is_a?(Hash) && r['url'] }
            break if found
          end
        end
      end
    end
    assert found, 'Hipoglucemia debe tener referencias enriquecidas con URL'
  end

  def test_render_bibliografico_en_disease_view
    assert_includes @app, 'renderBibliographicSources'
    assert_match(/fuentes_bibliograficas \|\| disease\.referencias/, @app)
  end
end

# US-UX-16 — Modo lectura nocturno
class ModoNocturnoTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
  end

  def test_toggle_en_header
    assert_includes @html, 'id="themeToggleBtn"'
    assert_includes @app, 'initTheme'
    assert_includes @app, 'toggleTheme'
    assert_includes @app, 'bindThemeToggle'
  end

  def test_variables_css_y_prefers_color_scheme
    assert_includes @css, ':root[data-theme="dark"]'
    assert_includes @css, 'prefers-color-scheme: dark'
    assert_includes @css, '--bg:'
    assert_includes @css, '.theme-toggle-btn'
  end

  def test_persistencia_local_storage
    assert_includes @app, "THEME_KEY: 'atlas_theme'"
    assert_includes @app, 'data-theme-mode'
    assert_includes @app, 'data-theme'
  end

  def test_i18n_tema
    assert_includes @i18n, "'theme.toggle'"
    assert_includes @i18n, "'theme.dark'"
  end
end

# US-CON-12 — Resúmenes modo estudio
class ResumenEstudioTest < Minitest::Test
  def setup
    @enc = JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
    @script = File.join(ROOT, 'scripts', 'data', 'build_resumen_estudio_sprint10.rb')
  end

  def test_script_build_resumen
    assert File.exist?(@script)
    assert_includes File.read(File.join(ROOT, 'actualizar_datos.sh')), 'build_resumen_estudio_sprint10.rb'
  end

  def test_campo_resumen_1min_en_datos
    count = 0
    @enc['animales'].each do |animal|
      animal['razas'].each_value do |razas|
        razas.each do |raza|
          (raza['enfermedades'] || []).each do |enf|
            count += 1 if enf['resumen_1min'].to_s.strip != ''
          end
        end
      end
    end
    assert_operator count, :>=, 100, 'Debe haber enfermedades con resumen_1min'
  end

  def test_plantilla_sintomas_gravedad_accion
    sample = nil
    @enc['animales'].each do |animal|
      animal['razas'].each_value do |razas|
        razas.each do |raza|
          (raza['enfermedades'] || []).each do |enf|
            if enf['resumen_1min']
              sample = enf['resumen_1min']
              break
            end
          end
        end
      end
    end
    assert sample
    assert_includes sample, 'Síntomas clave:'
    assert_includes sample, 'Gravedad:'
    assert_includes sample, 'Acción:'
  end

  def test_render_en_disease_view
    assert_includes @app, 'resumen_1min'
    assert_includes @app, 'study.summary_title'
    assert_includes @css, '.study-summary'
  end
end

# Integración Sprint 10
class Sprint10IntegrationTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @sitemap_script = File.read(File.join(ROOT, 'scripts', 'data', 'build_sitemap.rb'))
    @sw = File.read(File.join(ROOT, 'sw.js'))
  end

  def test_tab_bar_y_show_view_triaje
    assert_includes @app, "triaje: 'tools'"
    assert_includes @app, "view === 'triaje'"
  end

  def test_sitemap_ruta_triaje
    assert_includes @sitemap_script, "'triaje'"
  end

  def test_cache_version_y_precache_triaje
    m = @sw.match(/CACHE_VERSION\s*=\s*'atlas-v(\d+)'/)
    assert m
    assert_operator m[1].to_i, :>=, 9
    assert_includes @sw, 'triaje.js'
  end
end
