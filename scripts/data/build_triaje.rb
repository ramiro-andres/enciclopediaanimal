# frozen_string_literal: true

# US-TOOL-09 — Genera triaje.js desde triaje.json (árbol educativo estático).
require 'json'
ROOT = File.expand_path('../..', __dir__)
json_path = File.join(ROOT, 'data', 'triaje.json')
js_path = File.join(ROOT, 'data', 'triaje.js')

data = JSON.parse(File.read(json_path))
File.write(js_path, "window.TRIAJE_DATA = #{data.to_json};\n")
puts "triaje.js actualizado (#{data['categorias'].length} categorías, " \
     "#{data['categorias'].sum { |c| c['sintomas'].length }} síntomas)"
