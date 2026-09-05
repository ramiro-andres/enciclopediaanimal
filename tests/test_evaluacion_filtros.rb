#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require 'json'

class EvaluacionFiltrosTest < Minitest::Test
  def setup
    @root = File.expand_path('..', __dir__)
    @app = File.read(File.join(@root, 'js/app.js'))
    @i18n = File.read(File.join(@root, 'js/i18n.js'))
    @css = File.read(File.join(@root, 'css/styles.css'))
    @bank = JSON.parse(File.read(File.join(@root, 'data/evaluacion_preguntas.json')))
  end

  def test_banco_tiene_categorias
    cats = @bank['preguntas'].map { |p| p['categoria_id'] }.compact.uniq
    assert cats.size >= 5, "se esperaban varias categorías, hay #{cats.size}"
    assert @bank['preguntas'].all? { |p| p['categoria_id'] && p['categoria'] }
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
    assert_includes sw, "CACHE_VERSION = 'atlas-v31'"
  end
end
