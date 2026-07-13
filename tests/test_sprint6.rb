# frozen_string_literal: true

# Pruebas del Sprint 6 — EP-11: SEO, sharing y descubrimiento
#   - US-SEO-01: sitemap.xml
#   - US-SEO-02: OG dinámicos por ruta
#   - US-SEO-03: JSON-LD Schema.org
#   - US-SEO-04: Reportar error vía GitHub

require 'json'
require 'minitest/autorun'
require 'rexml/document'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

# US-SEO-01 — Sitemap
class SitemapTest < Minitest::Test
  def setup
    @script = File.join(ROOT, 'scripts', 'data', 'build_sitemap.rb')
    @sitemap_path = File.join(ROOT, 'sitemap.xml')
    @robots = File.read(File.join(ROOT, 'robots.txt'))
    @enc = JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
    system('ruby', @script, chdir: ROOT) unless File.exist?(@sitemap_path)
    @xml = File.read(@sitemap_path)
  end

  def test_script_build_sitemap_existe
    assert File.exist?(@script)
    assert_includes File.read(File.join(ROOT, 'actualizar_datos.sh')), 'build_sitemap.rb'
  end

  def test_robots_txt_referencia_sitemap
    assert_includes @robots, 'Sitemap:'
    assert_includes @robots, 'sitemap.xml'
    assert_includes @robots, 'Allow: /'
  end

  def test_sitemap_xml_valido_y_con_rutas
    doc = REXML::Document.new(@xml)
    urls = REXML::XPath.match(doc, '//url/loc').map(&:text)
    assert_operator urls.length, :>=, 100, 'El sitemap debe listar muchas rutas del atlas'
    assert urls.any? { |u| u.end_with?('/enciclopediaanimal/') || u.match?(%r{enciclopediaanimal/?$}) },
           'Debe incluir la home'
    assert urls.any? { |u| u.include?('#razas') }, 'Debe incluir #razas'
    assert urls.any? { |u| u.include?('#glosario') }, 'Debe incluir #glosario'
    assert urls.any? { |u| u.include?('#raza/') }, 'Debe incluir fichas de raza'
    assert urls.any? { |u| u.include?('#enfermedad/') }, 'Debe incluir fichas de enfermedad'
  end

  def test_workflows_copian_sitemap_y_robots
    deploy = File.read(File.join(ROOT, '.github', 'workflows', 'deploy-pages.yml'))
    lighthouse = File.read(File.join(ROOT, '.github', 'workflows', 'lighthouse.yml'))
    preview = File.read(File.join(ROOT, '.github', 'workflows', 'preview.yml'))
    assert_includes deploy, 'build_sitemap.rb'
    assert_includes deploy, 'sitemap.xml'
    assert_includes deploy, 'robots.txt'
    assert_includes lighthouse, 'sitemap.xml'
    assert_includes preview, 'sitemap.xml'
  end

  def test_index_enlaza_sitemap
    html = File.read(File.join(ROOT, 'index.html'))
    assert_includes html, 'rel="sitemap"'
    assert_includes html, 'sitemap.xml'
  end
end

# US-SEO-02 — OG dinámicos
class DynamicOgTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @html = File.read(File.join(ROOT, 'index.html'))
  end

  def test_meta_estaticos_en_index
    assert_match(/property="og:title"/, @html)
    assert_match(/property="og:description"/, @html)
    assert_match(/property="og:image"/, @html)
    assert_match(/name="twitter:card"/, @html)
    assert_match(/rel="canonical"/, @html)
  end

  def test_actualizacion_dinamica_og_en_app
    assert_includes @app, 'updatePageMeta'
    assert_includes @app, 'resetPageMeta'
    assert_includes @app, 'DEFAULT_META'
    assert_includes @app, "setMetaTag('property', 'og:title'"
    assert_includes @app, "setMetaTag('name', 'twitter:title'"
    assert_includes @app, "canonical.setAttribute('href'"
  end

  def test_og_en_fichas_y_reset_en_home
    assert_includes @app, 'showBreedDetail'
    assert_includes @app, 'showDiseaseDetail'
    assert_includes @app, 'resetPageMeta'
    assert_match(/goWelcome[\s\S]*resetPageMeta/, @app)
    assert_match(/showBreedDetail[\s\S]*updatePageMeta/, @app)
    assert_match(/showDiseaseDetail[\s\S]*updatePageMeta/, @app)
  end

  def test_documentacion_limitacion_og
    seo_doc = File.read(File.join(ROOT, 'docs', 'SEO.md'))
    assert_includes seo_doc, 'no ejecutan JavaScript'
    assert_includes seo_doc, 'sitemap.xml'
  end
end

# US-SEO-03 — JSON-LD
class JsonLdTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
  end

  def test_json_ld_enfermedad
    assert_includes @app, 'jsonLdForDisease'
    assert_includes @app, 'MedicalWebPage'
    assert_includes @app, 'MedicalCondition'
    assert_match(/showDiseaseDetail[\s\S]*setJsonLd/, @app)
  end

  def test_json_ld_glosario
    assert_includes @app, 'jsonLdForTerm'
    assert_includes @app, 'DefinedTerm'
    assert_includes @app, 'showDictionaryTerm'
    assert_includes @app, "parts[0] === 'glosario'"
  end

  def test_limpieza_json_ld
    assert_includes @app, 'clearJsonLd'
    assert_includes @app, 'atlas-jsonld'
    assert_includes @app, 'setJsonLd'
  end
end

# US-SEO-04 — Reportar error
class ReportErrorTest < Minitest::Test
  def setup
    @app = File.read(File.join(ROOT, 'js', 'app.js'))
    @i18n = File.read(File.join(ROOT, 'js', 'i18n.js'))
    @css = File.read(File.join(ROOT, 'css', 'styles.css'))
    @template = File.read(File.join(ROOT, '.github', 'ISSUE_TEMPLATE', 'content_request.yml'))
  end

  def test_boton_reportar_en_fichas
    assert_includes @app, 'renderReportErrorButton'
    assert_includes @app, 'btn-report-error'
    assert_match(/showBreedDetail[\s\S]*renderReportErrorButton/, @app)
    assert_match(/showDiseaseDetail[\s\S]*renderReportErrorButton/, @app)
  end

  def test_url_github_con_plantilla_y_campos
    assert_includes @app, 'content_request.yml'
    assert_includes @app, 'GITHUB_ISSUES_REPO'
    assert_includes @app, 'title_name'
    assert_includes @app, 'content_type'
    assert_includes @app, 'Ampliación de ficha existente'
    assert_includes @template, 'content_type'
    assert_includes @template, 'title_name'
  end

  def test_i18n_y_estilos_reporte
    assert_includes @i18n, "'report.error'"
    assert_includes @css, '.btn-report-error'
  end
end
