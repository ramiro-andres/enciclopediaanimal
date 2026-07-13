# frozen_string_literal: true

# Contratos de runtime JS (sin DOM): sintaxis, módulos extraídos, fachada App.
require 'open3'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

class JsSyntaxContractTest < Minitest::Test
  def js_files
    Dir.glob(File.join(ROOT, 'js', '*.js')).sort
  end

  def test_node_check_todos_los_js_del_shell
    skip 'node no disponible' unless system('command -v node >/dev/null 2>&1')

    js_files.each do |path|
      rel = path.sub(%r{^#{ROOT}/?}, '')
      out, status = Open3.capture2e('node', '--check', path)
      assert status.success?, "node --check falló en #{rel}:\n#{out}"
    end
  end

  def test_node_check_sw_y_data_criticos
    skip 'node no disponible' unless system('command -v node >/dev/null 2>&1')

    critical = %w[sw.js] + Dir.glob(File.join(ROOT, 'data', '{search_index,toxicologia,triaje,diccionario_medicos}.js'))
      .map { |p| p.sub(%r{^#{ROOT}/?}, '') }
    critical.each do |rel|
      path = File.join(ROOT, rel)
      next unless File.file?(path)

      out, status = Open3.capture2e('node', '--check', path)
      assert status.success?, "node --check falló en #{rel}:\n#{out}"
    end
  end
end

class AtlasUtilsEscContractTest < Minitest::Test
  def setup
    @utils = File.read(File.join(ROOT, 'js', 'utils.js'))
  end

  def test_esc_incluye_comillas_para_atributos
    assert_includes @utils, '&quot;', 'AtlasUtils.esc debe escapar "'
    assert_includes @utils, '&#39;', "AtlasUtils.esc debe escapar '"
    assert_match(/\.replace\(\/&\/g,\s*'&amp;'\)/, @utils)
  end

  def test_esc_evaluable_en_node
    skip 'node no disponible' unless system('command -v node >/dev/null 2>&1')

    script = <<~'JS'
      const fs = require('fs');
      const path = require('path');
      const src = fs.readFileSync(process.argv[1], 'utf8');
      eval(src);
      const s = AtlasUtils.esc('<img src=x onerror=alert(1) "\'>');
      if (!s.includes('&lt;') || !s.includes('&quot;') || !s.includes('&#39;')) {
        console.error('escape incompleto:', s);
        process.exit(1);
      }
    JS
    utils_path = File.join(ROOT, 'js', 'utils.js')
    out, status = Open3.capture2e('node', '-e', script, utils_path)
    assert status.success?, "AtlasUtils.esc runtime falló:\n#{out}"
  end
end

class AtlasToolsContractTest < Minitest::Test
  def setup
    @tools = File.read(File.join(ROOT, 'js', 'tools.js'))
  end

  def test_exporta_api_esperada
    %w[
      MER_FACTORS
      BCS_DOG_CAT_SCORES
      BCS_EQUINE_SCORES
      FLUID_PROFILES
      kgToLb
      lbToKg
      calculateRer
      formatDoseNumber
      getFluidProfile
      parseTypicalWeightKg
      calculateDoseTotals
    ].each do |name|
      assert_includes @tools, name, "AtlasTools debe exportar #{name}"
    end
  end

  def test_calculos_evaluables_en_node
    skip 'node no disponible' unless system('command -v node >/dev/null 2>&1')

    script = <<~JS
      #{@tools}
      const rer = AtlasTools.calculateRer(10);
      if (!(rer > 0)) { console.error('RER inválido', rer); process.exit(1); }
      const dose = AtlasTools.calculateDoseTotals(10, {
        calculable: true, min_por_kg: 1, max_por_kg: 2, unidad: 'mg/kg',
        dosis_texto: '1-2 mg/kg', via: 'IV', frecuencia: 'q12h', concentracion_mg_ml: 10
      });
      if (!dose.calculable || dose.minTotal !== 10 || !dose.volumeText) {
        console.error('dosis inválida', dose); process.exit(1);
      }
      if (AtlasTools.getFluidProfile('gatos').mlKgDay !== 50) {
        console.error('perfil fluido gatos'); process.exit(1);
      }
    JS
    out, status = Open3.capture2e('node', '-e', script)
    assert status.success?, "AtlasTools runtime falló:\n#{out}"
  end
end

class AppFacadeSmokeTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
    @sw = File.read(File.join(ROOT, 'sw.js'))
    @tools = File.read(File.join(ROOT, 'js', 'tools.js'))
  end

  def test_metodos_clave_existen_en_app
    %w[
      init
      renderHome
      renderSearchResults
      renderTools
      renderTriaje
      calculateRer
      calculateDoseForDrug
      formatDoseNumber
      esc
      applyTheme
      showBreedDetail
      openRouteFromHash
    ].each do |name|
      assert_match(/\b#{Regexp.escape(name)}\s*\(/, @app, "Falta método/función #{name} en app.js")
    end
  end

  def test_modulos_extraidos_cableados
    assert_includes @html, 'js/utils.js'
    assert_includes @html, 'js/tools.js'
    assert_match(%r{js/utils\.js.*js/tools\.js.*js/app\.js}m, @html,
                 'utils.js y tools.js deben cargarse antes de app.js')
    assert_includes @sw, './js/utils.js'
    assert_includes @sw, './js/tools.js'
    assert_includes @app, 'AtlasUtils.esc'
    assert_includes @app, 'AtlasTools.calculateRer'
    assert_includes @tools, 'calculateDoseTotals'
  end

  def test_name_matches_eliminada
    refute_match(/\bnameMatches\s*\(/, @app, 'nameMatches era código muerto; no debe permanecer')
  end

  def test_onerror_usa_data_fallback
    assert_includes @app, 'data-fallback='
    assert_includes @app, "getAttribute('data-fallback')"
    refute_match(/onerror="[^"]*\$\{this\.esc/, @app,
                 'onerror no debe interpolar rutas escapadas en el handler')
  end
end

class RubyDataDupContractTest < Minitest::Test
  def test_clinical_extended_deprecated_stub
    path = File.join(ROOT, 'scripts', 'data', 'clinical_disease_extended.rb')
    text = File.read(path)
    assert_match(/DEPRECATED/i, text)
    assert_includes text, "require_relative 'clinical_disease_extended_data'"
    refute_match(/EXTENDED_ENTRIES\s*=\s*\{/, text,
                 'El stub no debe redefinir EXTENDED_ENTRIES (vive en _data.rb)')
  end
end
