#!/usr/bin/env ruby
# frozen_string_literal: true
# Lista enfermedades únicas (por especie + nombre) sin imagen JPG válida ni SVG.
# Usado en CI (F4-03 / US-DEV-18). Umbral: JPG >8 KB o SVG de respaldo.
require 'json'

ROOT = File.expand_path('../..', __dir__)
DATA = File.join(ROOT, 'data', 'enciclopedia.json')
IMG_DIR = File.join(ROOT, 'images', 'enfermedades')

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

data = JSON.parse(File.read(DATA))
unique = {}
data['animales'].each do |animal|
  animal_id = animal['id']
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |breed|
      (breed['enfermedades'] || []).each do |disease|
        image_id = disease_image_id(animal_id, disease['nombre'])
        unique[image_id] ||= [animal_id, disease['nombre']]
      end
    end
  end
end

missing = []
unique.each do |image_id, (animal_id, disease_name)|
  jpg = File.join(IMG_DIR, "#{image_id}.jpg")
  svg = File.join(IMG_DIR, "#{image_id}.svg")
  has_jpg = File.exist?(jpg) && File.size(jpg) > 8000
  has_svg = File.exist?(svg)
  missing << [image_id, animal_id, disease_name] unless has_jpg || has_svg
end

missing.each { |id, animal, name| puts "#{id}\t#{animal}\t#{name}" }
warn "Enfermedades únicas: #{unique.size} · Faltantes: #{missing.size}"
exit(missing.empty? ? 0 : 1)
