#!/usr/bin/env ruby
# frozen_string_literal: true
require 'json'

ROOT = File.expand_path('..', __dir__)
data = JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
missing = []
data['animales'].each do |animal|
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |raza|
      f = File.join(ROOT, 'images', "#{raza['id']}.jpg")
      missing << [raza['id'], animal['id']] unless File.exist?(f) && File.size(f) > 8000
    end
  end
end
missing.each { |id, animal| puts "#{id}\t#{animal}" }
warn "Total faltantes: #{missing.size}"
