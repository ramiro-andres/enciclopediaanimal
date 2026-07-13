# frozen_string_literal: true

# Valida y regenera data/emergencias_latam.js desde emergencias_latam.json.
# Uso: ruby scripts/data/build_emergencias_latam.rb

require 'json'

ROOT = File.expand_path('../..', __dir__)
JSON_PATH = File.join(ROOT, 'data', 'emergencias_latam.json')
JS_PATH = File.join(ROOT, 'data', 'emergencias_latam.js')

def validate!(data)
  raise 'emergencias_latam.json debe tener clave "paises"' unless data['paises'].is_a?(Array)
  raise 'Debe haber al menos 8 países' if data['paises'].length < 8

  data['paises'].each do |p|
    %w[id nombre colegios lineas].each do |field|
      raise "País #{p['id'] || '?'} sin campo #{field}" if p[field].nil?
    end
    raise "País #{p['id']} sin colegios" unless p['colegios'].is_a?(Array) && p['colegios'].any?
    p['colegios'].each do |c|
      raise "Colegio en #{p['id']} sin nombre" if c['nombre'].to_s.strip.empty?
      raise "Colegio en #{p['id']} sin url" if c['url'].to_s.strip.empty?
    end
    p['lineas'].each do |l|
      raise "Línea en #{p['id']} sin nombre" if l['nombre'].to_s.strip.empty?
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  data = JSON.parse(File.read(JSON_PATH))
  validate!(data)
  File.write(JS_PATH, "window.EMERGENCIAS_LATAM = #{data.to_json};\n")
  puts "emergencias_latam.js actualizado (#{data['paises'].length} países)"
end
