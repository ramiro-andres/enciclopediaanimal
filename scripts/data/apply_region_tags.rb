# frozen_string_literal: true

# Etiqueta razas existentes con metadato `region` según origen declarado.
require 'json'

ROOT = File.expand_path('../..', __dir__)
INPUT = File.join(ROOT, 'data', 'enciclopedia.json')

REGION_BY_COUNTRY = {
  'colombia' => 'Colombia',
  'méxico' => 'México',
  'mexico' => 'México',
  'argentina' => 'Argentina',
  'chile' => 'Chile',
  'perú' => 'Perú',
  'peru' => 'Perú',
  'brasil' => 'Brasil',
  'ecuador' => 'Ecuador',
  'venezuela' => 'Venezuela',
  'bolivia' => 'Bolivia',
  'uruguay' => 'Uruguay',
  'paraguay' => 'Paraguay'
}.freeze

def infer_region(origen)
  return nil unless origen

  text = origen.downcase
  REGION_BY_COUNTRY.each do |key, region|
    return region if text.include?(key)
  end
  nil
end

data = JSON.parse(File.read(INPUT))
tagged = 0

data['animales'].each do |animal|
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |breed|
      next if breed['region']

      region = infer_region(breed['origen'])
      next unless region

      breed['region'] = region
      tagged += 1
    end
  end
end

File.write(INPUT, JSON.pretty_generate(data))
puts "Regiones asignadas: #{tagged}"
