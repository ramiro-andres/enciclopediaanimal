#!/usr/bin/env ruby
# frozen_string_literal: true

# Pruebas del Sprint 14 — EP-19: Cierre backlog atlas (último sprint núcleo)
#   - US-DEV-17: Badges CI en README (test, e2e, deploy-pages)
#   - US-DEV-18: Verificación imágenes enfermedades en CI + script --only-missing
#   - US-UX-18: prefers-reduced-motion en CSS y tour
#   - US-GOV-05: Labels GitHub + guía contenido clínico en CONTRIBUIR

require 'json'
require 'minitest/autorun'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

# US-DEV-17 — Badges README
class ReadmeBadgesSprint14Test < Minitest::Test
  def setup
    @readme = File.read(File.join(ROOT, 'README.md'))
  end

  def test_badges_test_e2e_deploy
    assert_match(/workflows\/test\.yml\/badge\.svg/, @readme)
    assert_match(/workflows\/e2e\.yml\/badge\.svg/, @readme)
    assert_match(/workflows\/deploy-pages\.yml\/badge\.svg/, @readme)
  end

  def test_workflows_existen
    %w[test.yml e2e.yml deploy-pages.yml].each do |wf|
      assert File.exist?(File.join(ROOT, '.github', 'workflows', wf)), "Falta workflow #{wf}"
    end
  end
end

# US-DEV-18 — Imágenes enfermedades
class DiseaseImagesSprint14Test < Minitest::Test
  def setup
    @list = File.join(ROOT, 'scripts', 'images', 'list_missing_disease_images.rb')
    @download = File.read(File.join(ROOT, 'scripts', 'images', 'download_disease_google_images.rb'))
    @workflow = File.read(File.join(ROOT, '.github', 'workflows', 'test.yml'))
  end

  def test_script_list_missing_disease_existe
    assert File.exist?(@list)
    content = File.read(@list)
    assert_includes content, '8000'
    assert_includes content, 'enfermedades'
  end

  def test_download_soporta_only_missing
    assert_includes @download, '--only-missing'
    assert_includes @download, 'ONLY_MISSING'
  end

  def test_ci_verifica_imagenes_enfermedades
    assert_includes @workflow, 'list_missing_disease_images.rb'
    assert_includes @workflow, 'download_disease_google_images.rb --only-missing'
  end

  def test_sin_imagenes_enfermedades_faltantes
    out = `ruby #{@list} 2>&1`
    assert_equal 0, $?.exitstatus, "Hay enfermedades sin imagen:\n#{out}"
  end
end

# US-UX-18 — prefers-reduced-motion
class ReducedMotionSprint14Test < Minitest::Test
  def setup
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
  end

  def test_css_reduced_motion_global
    assert_includes @css, '@media (prefers-reduced-motion: reduce)'
    assert_includes @css, 'scroll-behavior: auto !important'
    assert_includes @css, '.welcome-tour-overlay'
  end

  def test_app_respeta_reduced_motion
    assert_includes @app, 'prefersReducedMotion'
    assert_includes @app, 'scrollBehaviorPref'
    assert_includes @app, 'prefersReducedMotion() || this.wasDone()'
  end

  def test_showview_usa_scroll_behavior_pref
    assert_match(/showView\(view\)[\s\S]*?scrollBehaviorPref\(\)/, @app)
  end
end

# US-GOV-05 — Labels y guía contenido clínico
class GovernanceSprint14Test < Minitest::Test
  def setup
    @labels = File.read(File.join(ROOT, 'scripts', 'setup', 'setup_github_labels.sh'))
    @contrib = File.read(File.join(ROOT, 'docs', 'CONTRIBUIR.md'))
  end

  def test_script_labels_ampliado
    %w[content bug ui ci docs good\ first\ issue dependencies community a11y data images enhancement].each do |label|
      assert_includes @labels, label
    end
  end

  def test_guia_contenido_clinico_ampliada
    assert_includes @contrib, 'Contribuir contenido clínico'
    assert_includes @contrib, 'protocolo_farmacologico'
    assert_includes @contrib, 'referencias'
    assert_includes @contrib, 'validate_clinical_content.rb'
    assert_includes @contrib, 'setup_github_labels.sh'
  end
end

# PWA Sprint 14
class Sprint14SwTest < Minitest::Test
  def test_sw_version_bump
    sw = File.read(File.join(ROOT, 'sw.js'))
    assert_includes sw, 'atlas-v14'
  end
end

# SCRUM Sprint 14
class ScrumSprint14Test < Minitest::Test
  def test_scrum_sprint14_completado
    scrum = File.read(File.join(ROOT, 'docs', 'SCRUM.md'))
    assert_includes scrum, 'Sprint 14'
    assert_includes scrum, 'EP-19'
    assert_match(/backlog núcleo.*COMPLETADO/i, scrum)
    %w[US-DEV-17 US-DEV-18 US-UX-18 US-GOV-05].each do |us|
      assert_includes scrum, us
    end
  end
end
