# frozen_string_literal: true

# Pruebas de regresión y gaps de cobertura crítica (pre-sprint).
# Complementa tests por sprint con checks transversales: sintaxis JS, sync JSON→JS,
# filtro región y coherencia chunks/manifest.

require 'json'
require 'open3'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

def load_json_file(path)
  JSON.parse(File.read(File.join(ROOT, path)))
end

def parse_js_export(path, var_name)
  text = File.read(File.join(ROOT, path))
  prefix = "window.#{var_name} = "
  assert text.start_with?(prefix), "#{path} no exporta #{var_name}"
  JSON.parse(text.sub(prefix, '').sub(/;\s*$/, ''))
end

def all_breeds_from(data)
  breeds = []
  data['animales'].each do |animal|
    %w[pequena mediana grande].each do |size|
      (animal.dig('razas', size) || []).each do |raza|
        breeds << raza.merge('animalId' => animal['id'], 'tamano' => size)
      end
    end
  end
  breeds
end

def filter_by_region(breeds, region)
  return breeds if region == 'todos'

  breeds.select { |b| (b['region'] || infer_region(b['origen'])) == region }
end

def infer_region(origen)
  return nil unless origen

  text = origen.to_s.downcase
  map = { 'méxico' => 'México', 'mexico' => 'México', 'argentina' => 'Argentina', 'chile' => 'Chile' }
  map.each { |key, val| return val if text.include?(key) }
  nil
end

def node_bin
  %w[/opt/homebrew/bin/node /usr/local/bin/node node].find do |bin|
    system(bin, '--version', out: File::NULL, err: File::NULL)
  end
end

# ── Sintaxis app.js (regresión PR #21) ───────────────────────────────────────
class AppJsSyntaxTest < Minitest::Test
  def test_app_js_sin_errores_de_sintaxis
    bin = node_bin
    skip 'Node.js no disponible localmente' unless bin

    out, status = Open3.capture2e(bin, '--check', File.join(ROOT, 'js', 'app.js'))
    assert status.success?, "Sintaxis inválida en app.js:\n#{out}"
  end

  def test_sw_js_sin_errores_de_sintaxis
    bin = node_bin
    skip 'Node.js no disponible localmente' unless bin

    out, status = Open3.capture2e(bin, '--check', File.join(ROOT, 'sw.js'))
    assert status.success?, "Sintaxis inválida en sw.js:\n#{out}"
  end
end

# ── Sincronización JSON → JS ─────────────────────────────────────────────────
class JsonJsSyncTest < Minitest::Test
  PAIRS = [
    ['data/enciclopedia.json', 'data/enciclopedia.js', 'ENCICLOPEDIA_DATA'],
    ['data/diccionario_medicos.json', 'data/diccionario_medicos.js', 'DICCIONARIO_MEDICOS'],
    ['data/enlaces_clinicos.json', 'data/enlaces_clinicos.js', 'ENLACES_CLINICOS'],
    ['data/toxicologia.json', 'data/toxicologia.js', 'TOXICOLOGIA_DATA'],
    ['data/chunks/manifest.json', 'data/chunks/manifest.js', 'ENCICLOPEDIA_MANIFEST']
  ].freeze

  PAIRS.each do |json_rel, js_rel, var|
    define_method("test_sync_#{var.downcase}") do
      skip "Falta #{json_rel}" unless File.exist?(File.join(ROOT, json_rel))
      skip "Falta #{js_rel}" unless File.exist?(File.join(ROOT, js_rel))

      json_data = load_json_file(json_rel)
      js_data = parse_js_export(js_rel, var)
      assert_equal json_data, js_data, "#{js_rel} desincronizado respecto a #{json_rel}"
    end
  end
end

# ── Filtro región (explorador de razas) ──────────────────────────────────────
class RegionFilterRegressionTest < Minitest::Test
  def setup
    @data = load_json_file('data/enciclopedia.json')
    @breeds = all_breeds_from(@data)
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
  end

  def test_ui_filtro_region_presente
    assert_includes @html, 'id="regionFiltersSection"'
    assert_includes @html, 'id="regionFilters"'
    assert_includes @app, 'renderRegionFilters'
    assert_includes @app, 'getAvailableRegions'
    assert_includes @app, 'currentRegion'
  end

  def test_filtro_region_mexico_reduce_resultados
    mexico = filter_by_region(@breeds, 'México')
    assert_operator mexico.length, :>=, 10
    assert_operator mexico.length, :<, @breeds.length
    mexico.each { |b| assert_equal 'México', b['region'] || infer_region(b['origen']) }
  end

  def test_filtro_region_todos_devuelve_todas
    assert_equal @breeds.length, filter_by_region(@breeds, 'todos').length
  end

  def test_region_escapada_en_render
    assert_includes @app, 'data-region="${this.esc(item.id)}"'
    assert_includes @app, '${this.esc(item.label)}'
  end
end

# ── Integridad chunks / manifest (lazy load) ─────────────────────────────────
class ChunksManifestRegressionTest < Minitest::Test
  def setup
    @manifest = load_json_file('data/chunks/manifest.json')
    @manifest_js = parse_js_export('data/chunks/manifest.js', 'ENCICLOPEDIA_MANIFEST')
    @chunks_dir = File.join(ROOT, 'data', 'chunks')
  end

  def test_manifest_json_y_js_identicos
    assert_equal @manifest, @manifest_js
  end

  def test_cada_chunk_tiene_par_json_js
    (@manifest['animales'] || []).each do |entry|
      id = entry['id']
      assert File.exist?(File.join(@chunks_dir, "#{id}.json")), "Falta #{id}.json"
      assert File.exist?(File.join(@chunks_dir, "#{id}.js")), "Falta #{id}.js"
    end
  end

  def test_totales_manifest_coinciden_con_chunks
    (@manifest['animales'] || []).each do |entry|
      chunk = load_json_file("data/chunks/#{entry['id']}.json")
      actual = %w[pequena mediana grande].sum { |s| (chunk['razas'][s] || []).length }
      assert_equal entry['total_breeds'], actual,
                   "Total desincronizado en chunk #{entry['id']}: manifest=#{entry['total_breeds']} real=#{actual}"
    end
  end

  def test_chunk_js_sincronizado_con_json
    (@manifest['animales'] || []).first(3).each do |entry|
      id = entry['id']
      json_data = load_json_file("data/chunks/#{id}.json")
      js_text = File.read(File.join(@chunks_dir, "#{id}.js"))
      match = js_text.match(/ENCICLOPEDIA_CHUNKS\['#{Regexp.escape(id)}'\]\s*=\s*(\{.*\})\s*;?\s*\z/m)
      assert match, "Formato chunk JS inesperado: #{id}.js"
      assert_equal json_data, JSON.parse(match[1]), "Chunk JS desincronizado: #{id}"
    end
  end
end
