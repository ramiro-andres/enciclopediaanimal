#!/usr/bin/env ruby
# frozen_string_literal: true
# Reemplaza imágenes incorrectas usando la foto principal de Wikipedia (misma que Google muestra)
require 'json'
require 'net/http'
require 'uri'
require 'digest'

ROOT = File.expand_path('..', __dir__)
IMG  = File.join(ROOT, 'images')
DATA = File.join(ROOT, 'data', 'enciclopedia.json')
TITLES = JSON.parse(File.read(File.join(ROOT, 'scripts', 'wikipedia_titles.json')))
UA = 'EnciclopediaAnimal/1.0 (https://localhost; uso educativo local; ruby)'

# Razas a corregir según reporte del usuario
FIX_IDS = %w[
  pastor_aleman gran_danes rottweiler doberman loro_yaco guacamayo
  pony_shetland cuarto_milla hanoveriano caballo_andaluz belga frison pura_sangre_ingles
  dexter mini_hereford red_angus limousin simmental
  cerdo_iberico mini_pig vietnamita cerdo_landrace yorkshire_porcino pietrain
  hampshire cerdo_duroc large_white duroc_extra
  conejo_mini holandes_enano rex_mini conejo_angora californiano belier angora_extra
  conejo_gigante nueva_zelanda gigante_flandes_extra
  discus ouessant oveja_merino suffolk dorper merino_extra texel romney
  cabra_pigmea cabra_nubia saanen alpine nubia_extra boer angora_cabra
  alpaca llama llama_extra vicuna guanaco
  hamster cobaya huron raton_domestico gerbo_mongol chinchilla rata_domestica degu capibara
].freeze

def http_get(url, limit: 8)
  raise 'too many redirects' if limit.zero?
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == 'https'
  http.open_timeout = 12
  http.read_timeout = 25
  req = Net::HTTP::Get.new(uri)
  req['User-Agent'] = UA
  res = http.request(req)
  case res
  when Net::HTTPRedirection then http_get(res['location'], limit: limit - 1)
  when Net::HTTPSuccess then res.body
  else nil
  end
rescue StandardError
  nil
end

def valid_image?(body)
  return false unless body && body.bytesize > 12_000
  b = body.b
  b.start_with?("\xFF\xD8\xFF".b) || b.start_with?("\x89PNG".b)
end

def upscale_wikimedia(url)
  return url unless url&.include?('/thumb/')
  url.sub(%r{/\d+px-}, '/800px-')
end

def wikipedia_image_url(title)
  sleep 1.1
  encoded = URI.encode_www_form_component(title).gsub('+', '%20')
  json = http_get("https://en.wikipedia.org/api/rest_v1/page/summary/#{encoded}")
  return nil unless json

  data = JSON.parse(json)
  url = data.dig('originalimage', 'source') || data.dig('thumbnail', 'source')
  return nil unless url

  upscale_wikimedia(url)
rescue StandardError
  nil
end

def download_breed_image(breed_id)
  title = TITLES[breed_id]
  return :no_title unless title

  img_url = wikipedia_image_url(title)
  return :no_url unless img_url

  body = http_get(img_url)
  return :bad_image unless valid_image?(body)

  File.binwrite(File.join(IMG, "#{breed_id}.jpg"), body)
  :ok
end

# --- Main ---
$stdout.sync = true
data = JSON.parse(File.read(DATA))
breeds = []
data['animales'].each do |animal|
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |raza|
      breeds << raza if FIX_IDS.include?(raza['id'])
    end
  end
end

puts "Corrigiendo #{breeds.length} imágenes con foto principal de Wikipedia..."
puts ''

ok = fail = 0
breeds.each_with_index do |raza, idx|
  id = raza['id']
  result = download_breed_image(id)
  if result == :ok
    ok += 1
    size = File.size(File.join(IMG, "#{id}.jpg"))
    puts "[#{idx + 1}/#{breeds.length}] OK #{id} (#{size} bytes) <- #{TITLES[id]}"
  else
    fail += 1
    puts "[#{idx + 1}/#{breeds.length}] FAIL #{id} (#{result})"
  end
  raza['imagen'] = "images/#{id}.jpg"
end

File.write(DATA, JSON.pretty_generate(data))
puts ''
puts "Resultado: #{ok} corregidas, #{fail} fallidas"
