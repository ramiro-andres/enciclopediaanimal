#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require 'json'

class EvaluacionFiltrosTest < Minitest::Test
  MIN_PER_CATEGORY = 10

  def setup
    @root = File.expand_path('..', __dir__)
    @app = File.read(File.join(@root, 'js/app.js'))
    @i18n = File.read(File.join(@root, 'js/i18n.js'))
    @css = File.read(File.join(@root, 'css/styles.css'))
    @bank = JSON.parse(File.read(File.join(@root, 'data/evaluacion_preguntas.json')))
  end

  def normalize(text)
    text.to_s.downcase
        .unicode_normalize(:nfd)
        .gsub(/\p{M}/, '')
        .gsub(/[^a-z0-9\s]/, ' ')
        .squeeze(' ')
        .strip
  end

  def test_banco_tiene_categorias
    cats = @bank['preguntas'].map { |p| p['categoria_id'] }.compact.uniq
    assert cats.size >= 5, "se esperaban varias categorías, hay #{cats.size}"
    assert @bank['preguntas'].all? { |p| p['categoria_id'] && p['categoria'] }
  end

  def test_minimo_diez_por_categoria
    by = Hash.new(0)
    @bank['preguntas'].each { |p| by[p['categoria_id']] += 1 }
    short = by.select { |_, n| n < MIN_PER_CATEGORY }
    assert_empty short, "categorías bajo el mínimo de #{MIN_PER_CATEGORY}: #{short}"
    assert_operator @bank['min_per_category'].to_i, :>=, MIN_PER_CATEGORY
    assert_operator @bank.dig('stats', 'min_per_category').to_i, :>=, MIN_PER_CATEGORY
  end

  def test_stem_no_filtra_respuesta
    leaks = []
    @bank['preguntas'].each do |q|
      forms = ([q['respuesta']] + Array(q['sinonimos'])).map(&:to_s).reject { |s| s.strip.length < 3 }
      nstem = normalize(q['stem'])
      forms.each do |form|
        next unless nstem.include?(normalize(form))

        leaks << "#{q['id']}:#{q['respuesta']}"
        break
      end
    end
    assert_empty leaks, "stems que filtraban la respuesta: #{leaks.first(8).join(', ')}"
  end

  def test_urocultivo_redactado_si_existe
    q = @bank['preguntas'].find { |p| p['respuesta'].to_s.match?(/urocultivo/i) }
    skip 'Urocultivo no está en el banco actual' unless q

    assert_match(/____/, q['stem'])
    refute_match(/urocultivo/i, q['stem'])
  end

  def test_app_filtros_y_feedback
    %w[
      loadEvaluacionPrefs
      filterEvaluacionBank
      getEvaluacionCategories
      buildMixedEvaluacionDeck
      advanceEvaluacionAfterFeedback
      evaluacionCategorySelect
      evaluacionTypeSelect
      evaluacionAvailableCount
      evaluacion-feedback
      retry_failed
    ].each do |needle|
      assert_includes @app, needle, "falta #{needle} en app.js"
    end
    assert_includes @app, 'available < 10'
    assert_includes @app, '[10, 15, 20, 25]'
  end

  def test_i18n_claves_filtros
    %w[
      eval.category_label
      eval.type_label
      eval.available_count
      eval.feedback_ok
      eval.feedback_ko
      eval.retry_same
      eval.retry_failed
      eval.failed_list
      eval.open_glossary
    ].each do |key|
      assert_includes @i18n, "'#{key}'", "falta clave i18n #{key}"
    end
  end

  def test_css_feedback
    assert_includes @css, '.evaluacion-feedback'
    assert_includes @css, '.evaluacion-failed-list'
    assert_includes @css, '.evaluacion-setup-count'
  end

  def test_sw_cache_bump
    sw = File.read(File.join(@root, 'sw.js'))
    assert_includes sw, "CACHE_VERSION = 'atlas-v41'"
  end

  def test_build_script_garantiza_minimo_y_redaccion
    script = File.read(File.join(@root, 'scripts/data/build_evaluacion_preguntas.rb'))
    assert_includes script, 'MIN_PER_CATEGORY = 10'
    assert_includes script, 'def redact_stem'
    assert_includes script, 'def stem_leaks_answer?'
  end
end
