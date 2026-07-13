# frozen_string_literal: true

# US-CON-13 — Genera lab_reference.js desde lab_reference.json
require 'json'

ROOT = File.expand_path('../..', __dir__)
json_path = File.join(ROOT, 'data', 'lab_reference.json')
js_path = File.join(ROOT, 'data', 'lab_reference.js')

data = JSON.parse(File.read(json_path))
raise 'Sin especies en lab_reference.json' if data['especies'].empty?

data['especies'].each do |sp|
  raise "Especie #{sp['id']} sin hemograma" unless sp['hemograma']&.any?
  raise "Especie #{sp['id']} sin bioquímica" unless sp['bioquimica']&.any?
end

File.write(js_path, "window.LAB_REFERENCE = #{data.to_json};\n")
puts "lab_reference.js actualizado (#{data['especies'].length} especies)"
