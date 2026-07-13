# frozen_string_literal: true

# Genera sitemap.xml con rutas hash del atlas (razas, enfermedades, glosario).
# Uso: ruby scripts/data/build_sitemap.rb
# Variable opcional: SITEMAP_BASE_URL (por defecto GitHub Pages de producción).

require 'json'
require 'time'
require 'uri'

ROOT = File.expand_path('../..', __dir__)
BASE_URL = ENV.fetch('SITEMAP_BASE_URL', 'https://ramiro-andres.github.io/enciclopediaanimal/')

def slugify(text)
  text.to_s.downcase
      .unicode_normalize(:nfkd)
      .encode('ASCII', replace: '')
      .gsub(/[^a-z0-9]+/, '-')
      .gsub(/^-+|-+$/, '')
end

def route_part(value)
  URI.encode_www_form_component(value.to_s.strip)
end

def loc_for_hash(hash_part)
  base = BASE_URL.chomp('/')
  fragment = hash_part.to_s.sub(/^#/, '')
  fragment.empty? ? "#{BASE_URL}" : "#{base}/##{fragment}"
end

def xml_escape(text)
  text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
end

enc = JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
dict_path = File.join(ROOT, 'data', 'diccionario_medicos.json')
dict = File.exist?(dict_path) ? JSON.parse(File.read(dict_path)) : { 'categorias' => [] }

urls = []
lastmod = Time.now.utc.strftime('%Y-%m-%d')

static_routes = [
  ['', 'weekly', '1.0'],
  ['razas', 'weekly', '0.9'],
  ['glosario', 'weekly', '0.8'],
  ['herramientas', 'monthly', '0.7'],
  ['urgencias', 'monthly', '0.7'],
  ['comparar', 'monthly', '0.6'],
  ['rer-mer', 'monthly', '0.6'],
  ['toxicologia', 'monthly', '0.6'],
  ['fluidoterapia', 'monthly', '0.6'],
  ['unidades', 'monthly', '0.6'],
  ['predisposiciones', 'weekly', '0.7']
]

static_routes.each do |fragment, freq, priority|
  urls << { loc: loc_for_hash(fragment), changefreq: freq, priority: priority }
end

enc['animales'].each do |animal|
  animal_id = animal['id']
  urls << { loc: loc_for_hash("animal/#{route_part(animal_id)}"), changefreq: 'weekly', priority: '0.7' }

  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |raza|
      breed_fragment = "raza/#{route_part(animal_id)}/#{route_part(raza['id'])}"
      urls << { loc: loc_for_hash(breed_fragment), changefreq: 'monthly', priority: '0.6' }

      (raza['enfermedades'] || []).each do |enf|
        dis_fragment = "enfermedad/#{route_part(animal_id)}/#{route_part(raza['id'])}/#{route_part(slugify(enf['nombre']))}"
        urls << { loc: loc_for_hash(dis_fragment), changefreq: 'monthly', priority: '0.5' }
      end
    end
  end
end

(dict['categorias'] || []).each do |cat|
  (cat['terminos'] || []).each do |term|
    term_fragment = "glosario/#{route_part(slugify(term['termino']))}"
    urls << { loc: loc_for_hash(term_fragment), changefreq: 'yearly', priority: '0.4' }
  end
end

unique_urls = urls.uniq { |u| u[:loc] }

entries = unique_urls.map do |u|
  <<~ENTRY.strip
    <url>
      <loc>#{xml_escape(u[:loc])}</loc>
      <lastmod>#{lastmod}</lastmod>
      <changefreq>#{u[:changefreq]}</changefreq>
      <priority>#{u[:priority]}</priority>
    </url>
  ENTRY
end

xml = <<~XML
  <?xml version="1.0" encoding="UTF-8"?>
  <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  #{entries.join("\n")}
  </urlset>
XML

out = File.join(ROOT, 'sitemap.xml')
File.write(out, xml)
puts "sitemap.xml generado (#{unique_urls.length} URLs) → #{out}"
