# frozen_string_literal: true

# Valida y regenera data/toxicologia.js desde toxicologia.json.
# Uso: ruby scripts/data/build_toxicologia.rb
# También se invoca desde actualizar_datos.sh

require 'json'

ROOT = File.expand_path('../..', __dir__)
JSON_PATH = File.join(ROOT, 'data', 'toxicologia.json')
JS_PATH = File.join(ROOT, 'data', 'toxicologia.js')

ESPECIES_VALIDAS = %w[
  perros gatos aves equinos bovinos porcinos conejos reptiles peces
  ovinos caprinos camelidos roedores
].freeze

TOXICIDAD_VALIDA = %w[leve moderada alta].freeze

def validate!(data)
  raise 'toxicologia.json debe tener clave "sustancias"' unless data['sustancias'].is_a?(Array)
  raise 'Debe haber al menos 10 sustancias' if data['sustancias'].length < 10

  data['sustancias'].each do |s|
    %w[id nombre especies categoria toxicidad sintomas accion].each do |field|
      raise "Sustancia #{s['id'] || '?'} sin campo #{field}" if s[field].nil? || s[field] == ''
    end
    raise "Toxicidad inválida en #{s['id']}" unless TOXICIDAD_VALIDA.include?(s['toxicidad'])
    raise "Especies inválidas en #{s['id']}" unless s['especies'].is_a?(Array) && s['especies'].any?
    s['especies'].each do |esp|
      raise "Especie desconocida #{esp} en #{s['id']}" unless ESPECIES_VALIDAS.include?(esp)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  data = JSON.parse(File.read(JSON_PATH))
  validate!(data)
  File.write(JS_PATH, "window.TOXICOLOGIA_DATA = #{data.to_json};\n")
  puts "toxicologia.js actualizado (#{data['sustancias'].length} sustancias)"
end
