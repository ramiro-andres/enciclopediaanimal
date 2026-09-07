# frozen_string_literal: true

require 'json'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

class CriaderosSectionTest < Minitest::Test
  def setup
    @root = ROOT
    @json = JSON.parse(File.read(File.join(@root, 'data', 'criaderos.json')))
    @js = File.read(File.join(@root, 'data', 'criaderos.js'))
    @html = File.read(File.join(@root, 'index.html'))
    @app = File.read(File.join(@root, 'js', 'app.js'))
    @sw = File.read(File.join(@root, 'sw.js'))
    @i18n = File.read(File.join(@root, 'js', 'i18n.js'))
  end

  def test_datos_tienen_13_especies_del_atlas
    ids = @json['especies'].map { |e| e['id'] }
    expected = %w[perros gatos aves equinos bovinos porcinos conejos reptiles peces ovinos caprinos camelidos roedores]
    assert_equal expected.sort, ids.sort
  end

  def test_cada_especie_tiene_espacio_alimentacion_y_cuidados
    @json['especies'].each do |sp|
      assert sp.dig('espacio', 'resumen').to_s.strip != '', "#{sp['id']} sin espacio.resumen"
      assert sp.dig('espacio', 'metricas').is_a?(Array) && !sp['espacio']['metricas'].empty?, "#{sp['id']} sin métricas"
      assert sp.dig('alimentacion', 'resumen').to_s.strip != '', "#{sp['id']} sin alimentacion"
      assert sp.dig('cuidados', 'resumen').to_s.strip != '', "#{sp['id']} sin cuidados"
      refute sp.key?('fuentes'), "#{sp['id']} no debe listar fuentes"
    end
  end

  def test_sin_catalogo_ni_fuente_id
    refute @json.key?('fuentes_catalogo')
    @json['especies'].each do |sp|
      sp.dig('espacio', 'metricas').each do |m|
        refute m.key?('fuente_id'), "#{sp['id']} métrica con fuente_id"
        assert m['valor'].to_s.strip != '', "#{sp['id']} métrica sin valor"
      end
    end
  end

  def test_ui_no_renderiza_bloque_fuentes
    refute_includes @app, 'renderCriaderosFuenteLinks'
    refute_includes @app, 'criaderos-block--sources'
    refute_includes @i18n, "'criaderos.sources'"
  end

  def test_imagenes_de_diagramas_existen
    @json['especies'].each do |sp|
      img = sp.dig('espacio', 'imagen')
      next unless img
      path = File.join(@root, img)
      assert File.exist?(path), "Falta imagen #{img}"
      assert_operator File.size(path), :>, 20_000, "#{img} demasiado pequeña"
    end
  end

  def test_js_sincronizado_y_global
    assert_includes @js, 'window.CRIADEROS_DATA'
    assert_includes File.read(File.join(@root, 'actualizar_datos.sh')), 'criaderos.json'
  end

  def test_ui_y_ruta
    assert_includes @html, 'id="criaderosView"'
    assert_includes @html, 'data/criaderos.js'
    assert_includes @html, 'id="openCriaderosCard"'
    assert_includes @app, "parts[0] === 'criaderos'"
    assert_includes @app, 'showCriaderos'
    assert_includes @app, 'renderCriaderos'
    assert_includes @i18n, "'criaderos.title'"
  end

  def test_sw_precache_y_version
    assert_includes @sw, './data/criaderos.js'
    assert_match(/CACHE_VERSION\s*=\s*'atlas-v(?:5[3-9]|[6-9]\d|\d{3,})'/, @sw)
  end

  def test_sitemap_incluye_criaderos
    script = File.read(File.join(@root, 'scripts', 'data', 'build_sitemap.rb'))
    assert_includes script, "'criaderos'"
  end
end
