#!/usr/bin/env ruby
# frozen_string_literal: true
require 'json'

ROOT = File.expand_path('../..', __dir__)
data = JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
missing = []
data['animales'].each do |animal|
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |raza|
      image = raza['imagen'].to_s
      path = File.join(ROOT, image)
      jpg = path.sub(/\.svg$/, '.jpg')
      svg = path.sub(/\.jpg$/, '.svg')
      has_jpg = File.exist?(jpg) && File.size(jpg) > 8000
      has_svg = File.exist?(svg)
      missing << [raza['id'], animal['id']] unless has_jpg || has_svg
    end
  end
end
missing.each { |id, animal| puts "#{id}\t#{animal}" }
warn "Total faltantes: #{missing.size}"
exit(missing.empty? ? 0 : 1)
