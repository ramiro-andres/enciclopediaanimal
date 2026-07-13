# frozen_string_literal: true

# US-DEV-14 — Parte enciclopedia.json en chunks por animalId + manifest + índice de búsqueda.
# Uso: ruby scripts/data/build_chunks.rb
# También se invoca desde actualizar_datos.sh

require 'json'
require 'fileutils'

ROOT = File.expand_path('../..', __dir__)
ENC_PATH = File.join(ROOT, 'data', 'enciclopedia.json')
CHUNKS_DIR = File.join(ROOT, 'data', 'chunks')
MANIFEST_JSON = File.join(CHUNKS_DIR, 'manifest.json')
MANIFEST_JS = File.join(CHUNKS_DIR, 'manifest.js')
SEARCH_INDEX_JSON = File.join(ROOT, 'data', 'search_index.json')
SEARCH_INDEX_JS = File.join(ROOT, 'data', 'search_index.js')

def breed_count(animal)
  %w[pequena mediana grande].sum { |s| (animal.dig('razas', s) || []).length }
end

def disease_count(animal)
  total = 0
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |raza|
      total += (raza['enfermedades'] || []).length
    end
  end
  total
end

enc = JSON.parse(File.read(ENC_PATH))
FileUtils.mkdir_p(CHUNKS_DIR)

manifest_animales = []
search_breeds = []
total_breeds = 0
total_diseases = 0

enc['animales'].each do |animal|
  chunk = {
    'id' => animal['id'],
    'nombre' => animal['nombre'],
    'icono' => animal['icono'],
    'razas' => animal['razas']
  }
  chunk_path = File.join(CHUNKS_DIR, "#{animal['id']}.json")
  js_path = File.join(CHUNKS_DIR, "#{animal['id']}.js")
  File.write(chunk_path, JSON.generate(chunk))
  File.write(js_path,
              "window.ENCICLOPEDIA_CHUNKS=window.ENCICLOPEDIA_CHUNKS||{};" \
              "window.ENCICLOPEDIA_CHUNKS['#{animal['id']}']=#{chunk.to_json};\n")

  counts = { 'pequena' => 0, 'mediana' => 0, 'grande' => 0 }
  %w[pequena mediana grande].each do |size|
    counts[size] = (animal.dig('razas', size) || []).length
    (animal.dig('razas', size) || []).each do |raza|
      search_breeds << {
        'animalId' => animal['id'],
        'id' => raza['id'],
        'nombre' => raza['nombre'],
        'diseases' => (raza['enfermedades'] || []).map { |e| e['nombre'] }
      }
    end
  end

  bc = breed_count(animal)
  dc = disease_count(animal)
  total_breeds += bc
  total_diseases += dc

  manifest_animales << {
    'id' => animal['id'],
    'nombre' => animal['nombre'],
    'icono' => animal['icono'],
    'breed_counts' => counts,
    'total_breeds' => bc,
    'total_diseases' => dc
  }
end

manifest = {
  'version' => 1,
  'generated_at' => Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ'),
  'total_breeds' => total_breeds,
  'total_diseases' => total_diseases,
  'animales' => manifest_animales
}

File.write(MANIFEST_JSON, JSON.pretty_generate(manifest))
File.write(MANIFEST_JS, "window.ENCICLOPEDIA_MANIFEST = #{manifest.to_json};\n")

search_index = {
  'version' => 1,
  'generated_at' => manifest['generated_at'],
  'total_breeds' => total_breeds,
  'breeds' => search_breeds
}
File.write(SEARCH_INDEX_JSON, JSON.generate(search_index))
File.write(SEARCH_INDEX_JS, "window.SEARCH_INDEX = #{search_index.to_json};\n")

puts "chunks generados: #{manifest_animales.length} archivos en data/chunks/"
puts "manifest.json — #{total_breeds} razas, #{total_diseases} enfermedades"
puts "search_index.json — #{search_breeds.length} entradas de búsqueda"
