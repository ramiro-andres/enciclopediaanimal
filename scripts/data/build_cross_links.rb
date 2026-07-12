# frozen_string_literal: true

# Genera data/enlaces_clinicos.json: mapa bidireccional entre los términos del
# diccionario médico y las enfermedades del atlas.
#
# Un término se enlaza con una enfermedad cuando el término aparece como palabra
# completa dentro del texto clínico de la enfermedad (nombre, síntomas, causas,
# diagnóstico, tratamiento, etc.). Los términos "estructurales" que aparecen en
# casi todas las fichas (más del umbral) se descartan por ser demasiado genéricos
# y no aportar un enlace útil.
#
# Salida: data/enlaces_clinicos.json con dos índices:
#   - por_termino:    término normalizado -> enfermedades de ejemplo
#   - por_enfermedad: enfermedad normalizada -> términos del glosario relacionados

require 'json'

ROOT = File.expand_path('../..', __dir__)

# Fracción máxima de enfermedades que puede tocar un término sin considerarse
# demasiado genérico (p. ej. "Síntomas" o "Tratamiento" aparecen en todas).
GENERIC_THRESHOLD = 0.3
# Longitud mínima del término para evitar coincidencias triviales.
MIN_TERM_LENGTH = 5
# Máximo de enfermedades de ejemplo almacenadas por término.
MAX_EXAMPLES_PER_TERM = 10
# Máximo de términos relacionados almacenados por enfermedad.
MAX_TERMS_PER_DISEASE = 12

def normalize(text)
  String(text).to_s
    .unicode_normalize(:nfd)
    .gsub(/\p{Mn}/, '')
    .downcase
    .strip
end

def disease_text(disease)
  parts = [
    disease['nombre'],
    *(disease['sintomas'] || []),
    disease['causas'],
    *(disease['factores_riesgo'] || []),
    disease['criterios_diagnostico'],
    *(disease['diagnostico_diferencial'] || []),
    disease['diagnostico'],
    *(disease['examenes'] || []),
    disease['tratamiento'],
    disease['prevencion'],
    disease['notas_clinicas']
  ]
  normalize(parts.compact.join(' '))
end

data = JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
dict = JSON.parse(File.read(File.join(ROOT, 'data', 'diccionario_medicos.json')))

# Enfermedades únicas por nombre, guardando una ficha de ejemplo (primera vista).
diseases = {}
data['animales'].each do |animal|
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |raza|
      (raza['enfermedades'] || []).each do |enf|
        key = normalize(enf['nombre'])
        next if key.empty?

        diseases[key] ||= {
          'nombre' => enf['nombre'],
          'gravedad' => enf['gravedad'] || 'moderada',
          'animalId' => animal['id'],
          'breedId' => raza['id'],
          'breedNombre' => raza['nombre'],
          'animalNombre' => animal['nombre'],
          'texto' => disease_text(enf)
        }
      end
    end
  end
end

total_diseases = diseases.length
generic_limit = (total_diseases * GENERIC_THRESHOLD).ceil

# Términos únicos del diccionario (por término normalizado).
terms = {}
dict['categorias'].each do |cat|
  (cat['terminos'] || []).each do |term|
    key = normalize(term['termino'])
    next if key.length < MIN_TERM_LENGTH

    terms[key] ||= {
      'termino' => term['termino'],
      'categoriaId' => cat['id'],
      'categoriaNombre' => cat['nombre']
    }
  end
end

por_termino = {}
por_enfermedad = {}

terms.each do |term_key, term_info|
  pattern = /\b#{Regexp.escape(term_key)}\b/
  matches = diseases.select { |_dk, d| d['texto'].match?(pattern) }
  next if matches.empty?
  next if matches.length > generic_limit # término demasiado genérico

  ejemplos = matches.first(MAX_EXAMPLES_PER_TERM).map do |_dk, d|
    {
      'nombre' => d['nombre'],
      'gravedad' => d['gravedad'],
      'animalId' => d['animalId'],
      'breedId' => d['breedId'],
      'breedNombre' => d['breedNombre']
    }
  end

  por_termino[term_key] = {
    'termino' => term_info['termino'],
    'categoriaId' => term_info['categoriaId'],
    'categoriaNombre' => term_info['categoriaNombre'],
    'total' => matches.length,
    'ejemplos' => ejemplos
  }

  matches.each_key do |dk|
    (por_enfermedad[dk] ||= {
      'nombre' => diseases[dk]['nombre'],
      'animalId' => diseases[dk]['animalId'],
      'breedId' => diseases[dk]['breedId'],
      'terminos' => []
    })['terminos'] << {
      'termino' => term_info['termino'],
      'categoriaId' => term_info['categoriaId']
    }
  end
end

# Recorta y ordena los términos por enfermedad para una vista limpia.
por_enfermedad.each_value do |entry|
  entry['terminos'] = entry['terminos']
    .sort_by { |t| t['termino'].downcase }
    .first(MAX_TERMS_PER_DISEASE)
end

output = {
  'generado_por' => 'scripts/data/build_cross_links.rb',
  'descripcion' => 'Enlaces bidireccionales entre términos del glosario y enfermedades del atlas.',
  'umbral_generico' => GENERIC_THRESHOLD,
  'total_terminos_enlazados' => por_termino.length,
  'total_enfermedades_enlazadas' => por_enfermedad.length,
  'por_termino' => por_termino,
  'por_enfermedad' => por_enfermedad
}

out_path = File.join(ROOT, 'data', 'enlaces_clinicos.json')
File.write(out_path, JSON.pretty_generate(output) + "\n")

puts "enlaces_clinicos.json generado"
puts "  términos enlazados:     #{por_termino.length} / #{terms.length}"
puts "  enfermedades enlazadas: #{por_enfermedad.length} / #{total_diseases}"
