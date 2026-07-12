# frozen_string_literal: true

# Validación de integridad del atlas usada por el workflow de vista previa (preview.yml)
# y ejecutable en local. Comprueba, con permisos mínimos y sin servidor:
#   1. Los JSON principales son válidos.
#   2. Los .js derivados están sincronizados con sus JSON.
#   3. Las imágenes referenciadas por las razas existen.
#   4. Los enlaces clínicos (US-UX-04) apuntan a enfermedades y términos reales.
#
# Sale con código != 0 si detecta cualquier problema.

require 'json'

ROOT = File.expand_path('../..', __dir__)
errores = []
avisos = []

def leer_json(path, errores)
  JSON.parse(File.read(path))
rescue StandardError => e
  errores << "JSON inválido en #{File.basename(path)}: #{e.message}"
  nil
end

def normalize(text)
  String(text).to_s.unicode_normalize(:nfd).gsub(/\p{Mn}/, '').downcase.strip
end

enc_path = File.join(ROOT, 'data', 'enciclopedia.json')
dic_path = File.join(ROOT, 'data', 'diccionario_medicos.json')
enl_path = File.join(ROOT, 'data', 'enlaces_clinicos.json')

enc = leer_json(enc_path, errores)
dic = leer_json(dic_path, errores)
enl = leer_json(enl_path, errores)

# 1. Estructura básica de la enciclopedia.
if enc
  errores << 'enciclopedia.json sin clave "animales"' unless enc['animales'].is_a?(Array)
end

# 2. Sincronización JSON -> JS derivados.
{
  'enciclopedia.js' => ['window.ENCICLOPEDIA_DATA', enc_path],
  'diccionario_medicos.js' => ['window.DICCIONARIO_MEDICOS', dic_path],
  'enlaces_clinicos.js' => ['window.ENLACES_CLINICOS', enl_path]
}.each do |js_name, (var, json_path)|
  js_path = File.join(ROOT, 'data', js_name)
  unless File.exist?(js_path)
    errores << "Falta el archivo derivado data/#{js_name} (ejecuta actualizar_datos.sh)"
    next
  end
  js = File.read(js_path)
  errores << "data/#{js_name} no define #{var}" unless js.include?(var)
  next unless File.exist?(json_path)

  derived = js.sub(/^#{Regexp.escape(var)}\s*=\s*/, '').sub(/;\s*\z/, '')
  begin
    unless JSON.parse(derived) == JSON.parse(File.read(json_path))
      errores << "data/#{js_name} está desincronizado con su JSON (ejecuta actualizar_datos.sh)"
    end
  rescue StandardError => e
    errores << "No se pudo comparar data/#{js_name}: #{e.message}"
  end
end

# 3. Imágenes de razas referenciadas existen (jpg o svg de respaldo).
breeds = []
if enc && enc['animales'].is_a?(Array)
  enc['animales'].each do |animal|
    %w[pequena mediana grande].each do |size|
      (animal.dig('razas', size) || []).each do |raza|
        breeds << raza.merge('animalId' => animal['id'])
      end
    end
  end

  breeds.each do |raza|
    next unless raza['imagen']

    jpg = File.join(ROOT, raza['imagen'])
    svg = jpg.sub(/\.jpg\z/, '.svg')
    unless File.exist?(jpg) || File.exist?(svg)
      errores << "Imagen inexistente para raza #{raza['id']}: #{raza['imagen']}"
    end
  end
end

# 4. Integridad de los enlaces clínicos (US-UX-04).
if enl && enc
  disease_index = {}
  breeds.each do |raza|
    (raza['enfermedades'] || []).each do |enf|
      disease_index["#{raza['animalId']}:#{raza['id']}:#{normalize(enf['nombre'])}"] = true
    end
  end

  dict_terms = {}
  if dic && dic['categorias'].is_a?(Array)
    dic['categorias'].each { |c| (c['terminos'] || []).each { |t| dict_terms[normalize(t['termino'])] = true } }
  end

  enlazados = enl['total_terminos_enlazados'].to_i
  errores << "Muy pocos términos enlazados (#{enlazados}); se esperan >= 50" if enlazados < 50

  (enl['por_termino'] || {}).each do |term_key, info|
    avisos << "Término enlazado ausente del diccionario: #{info['termino']}" unless dict_terms[term_key]
    (info['ejemplos'] || []).each do |ej|
      key = "#{ej['animalId']}:#{ej['breedId']}:#{normalize(ej['nombre'])}"
      unless disease_index[key]
        errores << "Enlace roto: término '#{info['termino']}' apunta a enfermedad inexistente '#{ej['nombre']}' (#{ej['animalId']}/#{ej['breedId']})"
      end
    end
  end
end

puts '── Validación de integridad ──'
puts "Razas analizadas: #{breeds.length}"
puts "Términos enlazados: #{enl ? enl['total_terminos_enlazados'] : 'N/D'}"
avisos.uniq.first(20).each { |a| puts "AVISO: #{a}" }

if errores.empty?
  puts '✅ Integridad correcta.'
  exit 0
else
  puts "❌ #{errores.length} error(es) de integridad:"
  errores.first(50).each { |e| puts "  - #{e}" }
  exit 1
end
