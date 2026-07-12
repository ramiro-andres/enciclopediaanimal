#!/usr/bin/env ruby
# frozen_string_literal: true
require 'json'
require 'net/http'
require 'uri'
require 'digest'

ROOT = File.expand_path('..', __dir__)
IMG  = File.join(ROOT, 'images')
DATA = File.join(ROOT, 'data', 'enciclopedia.json')
SEARCHES = JSON.parse(File.read(File.join(ROOT, 'scripts', 'breed_searches.json')))
UA = 'EnciclopediaAnimal/3.0 (educational; breed-specific images)'

DOG_CEO = {
  'chihuahua' => 'chihuahua', 'yorkshire' => 'terrier/yorkshire', 'pomerania' => 'pomeranian',
  'maltes' => 'maltese', 'beagle' => 'beagle', 'cocker' => 'spaniel/cocker',
  'border_collie' => 'collie/border', 'bulldog_frances' => 'bulldog/french',
  'labrador' => 'labrador', 'pastor_aleman' => 'germanshepherd',
  'golden_retriever' => 'retriever/golden', 'gran_danes' => 'greatdane',
  'shih_tzu' => 'shihtzu', 'papillon' => 'papillon', 'bichon_frances' => 'bichon',
  'pinscher_miniatura' => 'pinscher/miniature', 'boxer' => 'boxer', 'shiba_inu' => 'shiba',
  'samoyedo' => 'samoyed', 'pointer_ingles' => 'pointer/german',
  'rottweiler' => 'rottweiler', 'husky_siberiano' => 'husky',
  'san_bernardo' => 'stbernard', 'doberman' => 'doberman'
}.freeze

CAT_API = {
  'singapura' => 'sing', 'bengala' => 'beng', 'devon_rex' => 'drex', 'munchkin' => 'munc',
  'siames' => 'siam', 'persa' => 'pers', 'british_shorthair' => 'bsho', 'abisinio' => 'abys',
  'siberiano' => 'sibe', 'exotico' => 'esho', 'burmes' => 'bure', 'maine_coon' => 'mcoo',
  'ragdoll' => 'ragd', 'bosque_noruego' => 'norw', 'savannah' => 'sava'
}.freeze

$api_mutex = Mutex.new
$used_hashes = {}
$hash_mutex = Mutex.new

def api_pause(seconds = 0.25)
  $api_mutex.synchronize { sleep seconds }
end

def http_get(url, limit: 8, retries: 3)
  raise 'too many redirects' if limit.zero?

  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == 'https'
  http.open_timeout = 10
  http.read_timeout = 20
  req = Net::HTTP::Get.new(uri)
  req['User-Agent'] = UA
  res = http.request(req)
  case res
  when Net::HTTPRedirection then http_get(res['location'], limit: limit - 1, retries: retries)
  when Net::HTTPSuccess then res.body
  when Net::HTTPTooManyRequests
    return nil if retries.zero?
    sleep 2 * (4 - retries)
    http_get(url, limit: limit, retries: retries - 1)
  else nil
  end
rescue StandardError
  nil
end

def valid_image?(body)
  return false unless body && body.bytesize > 8000
  b = body.b
  b.start_with?("\xFF\xD8\xFF".b) || b.start_with?("\x89PNG".b) || b.start_with?("RIFF".b)
end

def reserve_hash(body, breed_id)
  hash = Digest::MD5.hexdigest(body)
  $hash_mutex.synchronize do
    return nil if $used_hashes[hash] && $used_hashes[hash] != breed_id
    $used_hashes[hash] = breed_id
  end
  hash
end

def save_image(breed_id, body)
  hash = reserve_hash(body, breed_id)
  return false unless hash
  File.binwrite(File.join(IMG, "#{breed_id}.jpg"), body)
  true
end

def dog_ceo_urls(breed_id)
  path = DOG_CEO[breed_id]
  return [] unless path
  urls = []
  3.times do
    json = http_get("https://dog.ceo/api/breed/#{path}/images/random")
    next unless json
    data = JSON.parse(json)
    urls << data['message'] if data['status'] == 'success'
    sleep 0.2
  end
  urls.compact.uniq
rescue StandardError
  []
end

def cat_api_urls(breed_id)
  code = CAT_API[breed_id]
  return [] unless code
  json = http_get("https://api.thecatapi.com/v1/images/search?breed_ids=#{code}&limit=5&size=med")
  return [] unless json
  data = JSON.parse(json)
  data.map { |x| x['url'] }.compact
rescue StandardError
  []
end

def openverse_urls(query, page: 1, page_size: 10)
  api_pause
  uri = URI('https://api.openverse.org/v1/images/')
  uri.query = URI.encode_www_form(
    'q' => query, 'page' => page.to_s, 'page_size' => page_size.to_s,
    'license' => 'cc0,pdm,by,by-sa', 'extension' => 'jpg,jpeg,png'
  )
  json = http_get(uri.to_s)
  return [] unless json

  data = JSON.parse(json)
  (data['results'] || []).filter_map do |r|
    next if r['height'].to_i < 300 || r['width'].to_i < 300
    r['url']
  end
rescue StandardError
  []
end

def inaturalist_urls(query, page: 1)
  api_pause
  uri = URI('https://api.inaturalist.org/v1/observations')
  uri.query = URI.encode_www_form(
    'q' => query, 'photos' => 'true', 'quality_grade' => 'research',
    'per_page' => '12', 'page' => page.to_s, 'order' => 'desc', 'order_by' => 'votes'
  )
  json = http_get(uri.to_s)
  return [] unless json

  data = JSON.parse(json)
  (data['results'] || []).flat_map do |obs|
    (obs['photos'] || []).map do |p|
      (p['url'] || '').sub('square', 'large').sub('small', 'large').sub('medium', 'large')
    end
  end.compact.uniq
rescue StandardError
  []
end

def gbif_urls(query, limit: 10)
  api_pause
  uri = URI('https://api.gbif.org/v1/occurrence/search')
  uri.query = URI.encode_www_form('q' => query, 'mediaType' => 'StillImage', 'limit' => limit.to_s)
  json = http_get(uri.to_s)
  return [] unless json

  data = JSON.parse(json)
  (data['results'] || []).flat_map do |r|
    (r['media'] || []).map { |m| m['identifier'] }
  end.compact.uniq
rescue StandardError
  []
end

def wikimedia_urls(query, limit: 8, offset: 0)
  api_pause(0.7)
  params = {
    'action' => 'query', 'format' => 'json', 'generator' => 'search',
    'gsrsearch' => query, 'gsrnamespace' => '6', 'gsrlimit' => limit.to_s,
    'gsroffset' => offset.to_s,
    'prop' => 'imageinfo', 'iiprop' => 'url|mime|size', 'iiurlwidth' => '800'
  }
  uri = URI('https://commons.wikimedia.org/w/api.php')
  uri.query = URI.encode_www_form(params)
  json = http_get(uri.to_s)
  return [] unless json

  pages = JSON.parse(json).dig('query', 'pages') || {}
  pages.values.sort_by { |p| p['title'].to_s }.filter_map do |page|
    info = page['imageinfo']&.first
    next unless info&.dig('mime')&.start_with?('image/')
    next if info['size'].to_i < 8000
    info['thumburl'] || info['url']
  end
rescue StandardError
  []
end

def try_urls(urls, breed_id)
  urls.each do |url|
    body = http_get(url)
    next unless valid_image?(body)
    return true if save_image(breed_id, body)
  end
  false
end

def collect_urls_for_queries(queries, breed_id, page_index: 0)
  urls = []
  queries.each_with_index do |q, qi|
    page = page_index + qi + 1
    urls.concat(openverse_urls(q, page: page))
    urls.concat(inaturalist_urls(q, page: page))
    urls.concat(gbif_urls(q)) if qi.zero?
    [0, 4].each do |offset|
      urls.concat(wikimedia_urls(q, limit: 5, offset: offset + page_index * 3))
    end
  end
  urls.uniq
end

def download_breed(breed_id, animal_id, nombre)
  out = File.join(IMG, "#{breed_id}.jpg")
  File.delete(out) if File.exist?(out)
  $hash_mutex.synchronize { $used_hashes.delete_if { |_, v| v == breed_id } }

  urls = []
  urls.concat(dog_ceo_urls(breed_id)) if animal_id == 'perros'
  urls.concat(cat_api_urls(breed_id)) if animal_id == 'gatos'
  return :ok if try_urls(urls.uniq, breed_id)

  queries = SEARCHES[breed_id] || [nombre]
  3.times do |pass|
    batch = collect_urls_for_queries(queries, breed_id, page_index: pass)
    return :ok if try_urls(batch, breed_id)
  end
  :fail
end

# --- Main ---
$stdout.sync = true
data = JSON.parse(File.read(DATA))
breeds = []
data['animales'].each do |animal|
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |raza|
      breeds << [raza['id'], animal['id'], raza['nombre'], raza]
    end
  end
end

puts "Redescargando #{breeds.length} imágenes específicas por raza..."
puts 'Fuentes: Dog CEO, Cat API, Openverse, iNaturalist, GBIF, Wikimedia'
puts ''

ok = fail = 0
breeds.each_with_index do |(id, animal, nombre, raza), idx|
  result = download_breed(id, animal, nombre)
  if result == :ok
    ok += 1
    puts "[#{idx + 1}/#{breeds.length}] OK #{id}"
  else
    fail += 1
    puts "[#{idx + 1}/#{breeds.length}] FAIL #{id}"
  end
  raza['imagen'] = "images/#{id}.jpg"
end

File.write(DATA, JSON.pretty_generate(data))

dups = {}
Dir[File.join(IMG, '*.jpg')].each do |f|
  next unless File.size(f) > 8000
  h = Digest::MD5.file(f).hexdigest
  dups[h] ||= []
  dups[h] << File.basename(f, '.jpg')
end
dup_groups = dups.select { |_, v| v.size > 1 }

puts ''
puts "Resultado: #{ok} OK, #{fail} fallidas"
puts "Duplicados: #{dup_groups.size} grupos"
dup_groups.each { |_, ids| puts "  ⚠️  #{ids.join(', ')}" }

if dup_groups.any?
  puts 'Corrigiendo duplicados...'
  dup_groups.values.flatten.uniq.each do |dup_id|
    item = breeds.find { |b| b[0] == dup_id }
    next unless item
    id, animal, nombre, = item
    File.delete(File.join(IMG, "#{id}.jpg")) if File.exist?(File.join(IMG, "#{id}.jpg"))
    $hash_mutex.synchronize { $used_hashes.delete_if { |_, v| v == id } }
    extra = (SEARCHES[id] || []) + ["#{nombre} breed", "#{id.tr('_', ' ')} animal"]
    4.times do |pass|
      batch = collect_urls_for_queries(extra, id, page_index: pass + 2)
      break if try_urls(batch, id)
    end
    puts "  FIX #{id}" if File.exist?(File.join(IMG, "#{id}.jpg"))
  end
  File.write(DATA, JSON.pretty_generate(data))
end

puts 'JSON actualizado.'
