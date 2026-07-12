#!/usr/bin/env ruby
# frozen_string_literal: true
# Descarga imágenes de Google para enfermedades (por especie + nombre)
require 'json'
require 'net/http'
require 'uri'
require 'cgi'
require 'fileutils'
require 'open3'

ROOT = File.expand_path('../..', __dir__)
IMG_DIR = File.join(ROOT, 'images', 'enfermedades')
DATA = File.join(ROOT, 'data', 'enciclopedia.json')
UA = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
MAX_DIM = 800
IMAGE_INDEX = 1
GOOGLE_SIZE_FILTER = 'isz:lt,islt:svga'

SKIP_HOST = %w[
  gstatic.com google.com googleusercontent.com ggpht.com
  favicon icon.png /bar/ googleg_ kiddle.co ytimg.com/vi/
].freeze

ANIMAL_QUERY = {
  'perros' => 'perro',
  'gatos' => 'gato',
  'aves' => 'ave',
  'conejos' => 'conejo',
  'equinos' => 'caballo',
  'peces' => 'pez',
  'bovinos' => 'vaca bovino',
  'porcinos' => 'cerdo',
  'ovinos' => 'oveja',
  'caprinos' => 'cabra',
  'camelidos' => 'camelido',
  'roedores' => 'roedor',
  'reptiles' => 'reptil'
}.freeze

DISEASE_QUERIES = {
  'hipoglucemia' => 'hipoglucemia perro veterinaria',
  'moquillo' => 'moquillo canino enfermedad',
  'parvovirus' => 'parvovirus canino veterinaria',
  'enfermedad periodontal' => 'enfermedad periodontal perro dental',
  'luxacion de rotula' => 'luxacion rotula perro veterinaria',
  'cardiomiopatia hipertrofica' => 'cardiomiopatia hipertrofica gato',
  'obstruccion urinaria' => 'obstruccion urinaria gato veterinaria',
  'mastitis' => 'mastitis bovina veterinaria',
  'cólico' => 'colico equino veterinaria',
  'colico' => 'colico equino veterinaria',
  'ich' => 'ichthyophthirius peces acuario enfermedad',
  'psitacosis' => 'psitacosis ave veterinaria',
  'estasis gastrointestinal' => 'estasis gastrointestinal conejo',
  'metabolic bone disease' => 'metabolic bone disease reptile',
  'enfermedad renal cronica' => 'enfermedad renal cronica gato',
  'torsión gástrica' => 'torsion gastrica perro GDV',
  'torsion gastrica' => 'torsion gastrica perro GDV'
}.freeze

def slugify(text)
  text.to_s.downcase
      .unicode_normalize(:nfkd)
      .encode('ASCII', replace: '')
      .gsub(/[^a-z0-9]+/, '_')
      .gsub(/^_|_$/, '')
end

def disease_image_id(animal_id, disease_name)
  "#{animal_id}_#{slugify(disease_name)}"
end

def query_for(animal_id, animal_nombre, disease_name)
  key = slugify(disease_name).tr('_', ' ')
  return DISEASE_QUERIES[key] if DISEASE_QUERIES[key]
  return DISEASE_QUERIES[disease_name.downcase] if DISEASE_QUERIES[disease_name.downcase]

  term = ANIMAL_QUERY[animal_id] || animal_nombre.downcase
  "#{disease_name} enfermedad #{term} veterinaria"
end

def http_get(url, limit: 6)
  raise 'too many redirects' if limit.zero?
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == 'https'
  http.open_timeout = 12
  http.read_timeout = 25
  req = Net::HTTP::Get.new(uri)
  req['User-Agent'] = UA
  req['Referer'] = 'https://www.google.com/'
  res = http.request(req)
  case res
  when Net::HTTPRedirection then http_get(res['location'], limit: limit - 1)
  when Net::HTTPSuccess then res.body
  end
rescue StandardError
  nil
end

def valid_image?(body)
  return false unless body && body.bytesize > 12_000
  b = body.b
  b.start_with?("\xFF\xD8\xFF".b) || b.start_with?("\x89PNG".b) || b.start_with?("RIFF".b)
end

def google_html(query)
  q = CGI.escape(query)
  url = "https://www.google.com/search?q=#{q}&udm=2&hl=es&tbs=#{GOOGLE_SIZE_FILTER}"
  script = <<~APPLESCRIPT
    tell application "Safari"
      if (count of windows) = 0 then make new document
      set URL of current tab of front window to "#{url}"
      delay 6
      return source of document 1
    end tell
  APPLESCRIPT
  out, _, status = Open3.capture3('osascript', stdin_data: script)
  return nil unless status.success? && out && out.bytesize > 50_000
  out
end

def extract_google_image_urls(html)
  urls = html.scan(/"(https?:\/\/[^"]+\.(?:jpg|jpeg|png|webp)(?:\?[^"]*)?)"/i).flatten
  urls.map { |u| u.gsub('\\u003d', '=').gsub('\\u0026', '&').gsub('\\/', '/') }
      .reject { |u| SKIP_HOST.any? { |s| u.include?(s) } }
      .reject { |u| u.match?(/\/\d{2,3}px-/) }
      .uniq
end

def normalize_image(raw_path, out_path)
  ok = system('sips', '-s', 'format', 'jpeg', '-Z', MAX_DIM.to_s, raw_path, '--out', out_path,
              out: File::NULL, err: File::NULL)
  ok && File.exist?(out_path) && File.size(out_path) > 8000
end

def download_google_image(image_id, query, index: IMAGE_INDEX)
  html = google_html(query)
  return :no_html unless html

  urls = extract_google_image_urls(html)
  found = 0
  urls.each do |img_url|
    body = http_get(img_url)
    next unless valid_image?(body)

    if found == index
      raw = File.join(IMG_DIR, "#{image_id}_raw.jpg")
      out = File.join(IMG_DIR, "#{image_id}.jpg")
      File.binwrite(raw, body)
      if normalize_image(raw, out)
        File.delete(raw)
        return :ok
      end
      File.delete(raw) if File.exist?(raw)
      return :bad_normalize
    end
    found += 1
  end

  return :no_image if index.positive?

  :no_image
end

def write_placeholder_svg(path, title, animal)
  safe_title = title.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
  svg = <<~SVG
    <svg xmlns="http://www.w3.org/2000/svg" width="440" height="280" viewBox="0 0 440 280">
      <rect width="440" height="280" fill="#e8ece3"/>
      <rect x="24" y="24" width="392" height="232" fill="#f8f7f2" stroke="#c8cac4"/>
      <text x="220" y="118" text-anchor="middle" font-family="Arial,sans-serif" font-size="42">🩺</text>
      <text x="220" y="158" text-anchor="middle" font-family="Arial,sans-serif" font-size="15" font-weight="bold" fill="#1e3b2f">#{safe_title}</text>
      <text x="220" y="182" text-anchor="middle" font-family="Arial,sans-serif" font-size="12" fill="#5f645d">#{animal}</text>
    </svg>
  SVG
  File.write(path, svg)
end

def collect_unique_diseases(data)
  map = {}
  data['animales'].each do |animal|
    animal_id = animal['id']
    animal_nombre = animal['nombre']
    %w[pequena mediana grande].each do |size|
      (animal.dig('razas', size) || []).each do |breed|
        (breed['enfermedades'] || []).each do |disease|
          image_id = disease_image_id(animal_id, disease['nombre'])
          map[image_id] ||= {
            animal_id: animal_id,
            animal_nombre: animal_nombre,
            disease_name: disease['nombre'],
            query: query_for(animal_id, animal_nombre, disease['nombre'])
          }
        end
      end
    end
  end
  map
end

def assign_images_to_data!(data)
  data['animales'].each do |animal|
    animal_id = animal['id']
    %w[pequena mediana grande].each do |size|
      (animal.dig('razas', size) || []).each do |breed|
        (breed['enfermedades'] || []).each do |disease|
          image_id = disease_image_id(animal_id, disease['nombre'])
          disease['imagen'] = "images/enfermedades/#{image_id}.jpg"
        end
      end
    end
  end
end

# --- Main ---
$stdout.sync = true
ONLY_MISSING = ARGV.include?('--only-missing')
ASSIGN_ONLY = ARGV.include?('--assign-only')
LIMIT = (ARGV.find { |a| a.start_with?('--limit=') }&.split('=')&.last || nil)&.to_i

FileUtils.mkdir_p(IMG_DIR)
data = JSON.parse(File.read(DATA))
unique = collect_unique_diseases(data)
assign_images_to_data!(data)

items = unique.to_a
items = items.reject { |id, _| File.exist?(File.join(IMG_DIR, "#{id}.jpg")) } if ONLY_MISSING
items = items.first(LIMIT) if LIMIT&.positive?

if ASSIGN_ONLY
  unique.each do |image_id, info|
    svg_path = File.join(IMG_DIR, "#{image_id}.svg")
    write_placeholder_svg(svg_path, info[:disease_name], info[:animal_nombre]) unless File.exist?(svg_path)
  end
  File.write(DATA, JSON.pretty_generate(data))
  puts "Rutas asignadas para #{unique.size} enfermedades únicas"
  puts "Placeholders SVG en images/enfermedades/"
  exit 0
end

puts "Enfermedades únicas por especie: #{unique.size}"
puts "Descargando imágenes de Google: #{items.length} (#{ONLY_MISSING ? 'solo faltantes' : 'todas'})"
puts ''

ok = fail = 0
items.each_with_index do |(image_id, info), idx|
  svg_path = File.join(IMG_DIR, "#{image_id}.svg")
  write_placeholder_svg(svg_path, info[:disease_name], info[:animal_nombre]) unless File.exist?(svg_path)

  result = download_google_image(image_id, info[:query])
  result = download_google_image(image_id, info[:query], index: 0) if result == :no_image

  if result == :ok
    ok += 1
    puts "[#{idx + 1}/#{items.length}] OK #{image_id}"
  else
    fail += 1
    puts "[#{idx + 1}/#{items.length}] FAIL #{image_id} (#{result})"
  end
end

File.write(DATA, JSON.pretty_generate(data))
puts ''
puts "Resultado: #{ok} OK, #{fail} fallidas"
puts "Rutas asignadas en enciclopedia.json: images/enfermedades/<especie>_<enfermedad>.jpg"
