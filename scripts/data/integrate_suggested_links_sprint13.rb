# frozen_string_literal: true

# Sprint 13 — US-UX-19: integra ≥50 enlaces validados desde sugerencias_enlaces.json
# en enlaces_clinicos.json (glosario ↔ enfermedades bidireccional).

require 'json'
require 'set'

ROOT = File.expand_path('../..', __dir__)
LINKS_PATH = File.join(ROOT, 'data', 'enlaces_clinicos.json')
SUGGESTIONS_PATH = File.join(ROOT, 'data', 'sugerencias_enlaces.json')
ENC_PATH = File.join(ROOT, 'data', 'enciclopedia.json')
DICT_PATH = File.join(ROOT, 'data', 'diccionario_medicos.json')

MIN_INTEGRATE = 50
MAX_EXAMPLES_PER_TERM = 10
MAX_TERMS_PER_DISEASE = 12
MAX_SPRINT13_PER_TERM = 3

# Términos estructurales demasiado genéricos para enlaces útiles.
GENERIC_TERMS = %w[
  sintomas causas tratamiento diagnostico prevencion pronostico urgencia
  gravedad factores de riesgo examenes complementarios
].freeze

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
    disease['diagnostico'],
    disease['tratamiento'],
    disease['prevencion']
  ]
  normalize(parts.compact.join(' '))
end

def load_disease_index
  data = JSON.parse(File.read(ENC_PATH))
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
            'texto' => disease_text(enf)
          }
        end
      end
    end
  end
  diseases
end

def term_category_map
  dict = JSON.parse(File.read(DICT_PATH))
  map = {}
  (dict['categorias'] || []).each do |cat|
    (cat['terminos'] || []).each do |term|
      map[normalize(term['termino'])] = {
        'termino' => term['termino'],
        'categoriaId' => cat['id'],
        'categoriaNombre' => cat['nombre']
      }
    end
  end
  map
end

links = JSON.parse(File.read(LINKS_PATH))
suggestions = JSON.parse(File.read(SUGGESTIONS_PATH))
diseases = load_disease_index
term_map = term_category_map

por_termino = links['por_termino'] || {}
por_enfermedad = links['por_enfermedad'] || {}

candidates = (suggestions['sugerencias'] || [])
  .sort_by { |s| [-s['score'].to_f, s['termino'].to_s] }
  .uniq { |s| "#{s['termino_norm']}::#{s['enfermedad_norm']}" }

# Complementar con términos del diccionario Sprint 13 aún no enlazados.
require_relative 'expand_dictionary_sprint13'
sprint13_keys = EXTRA_TERMS_SPRINT13.values.flatten.map { |t| normalize(t['termino']) }.to_set

dict = JSON.parse(File.read(DICT_PATH))
(dict['categorias'] || []).each do |cat|
  (cat['terminos'] || []).each do |term|
    term_key = normalize(term['termino'])
    next if term_key.length < 5
    next if GENERIC_TERMS.include?(term_key)
    next if por_termino.key?(term_key)
    next unless sprint13_keys.include?(term_key)

    diseases.each do |dis_key, dis|
      pattern = /\b#{Regexp.escape(term_key)}\b/
      next unless dis['texto'].to_s.match?(pattern)

      candidates << {
        'termino' => term['termino'],
        'termino_norm' => term_key,
        'categoria' => cat['nombre'],
        'enfermedad' => dis['nombre'],
        'enfermedad_norm' => dis_key,
        'animalId' => dis['animalId'],
        'breedId' => dis['breedId'],
        'score' => 0.45,
        'motivo' => 'texto_clinico_complementario'
      }
      break
    end
  end
end

candidates = candidates
  .sort_by { |s| [por_termino.key?(s['termino_norm'] || normalize(s['termino'])) ? 1 : 0, -s['score'].to_f, s['termino'].to_s] }
  .uniq { |s| "#{s['termino_norm']}::#{s['enfermedad_norm']}" }

integrated = 0
skipped = 0
sprint13_per_term = Hash.new(0)

candidates.each do |sug|
  break if integrated >= MIN_INTEGRATE

  term_key = sug['termino_norm'] || normalize(sug['termino'])
  dis_key = sug['enfermedad_norm'] || normalize(sug['enfermedad'])
  next if term_key.length < 5
  next if dis_key.empty?

  disease = diseases[dis_key]
  next unless disease

  term_info = term_map[term_key]
  unless term_info
    term_info = {
      'termino' => sug['termino'],
      'categoriaId' => 'sugerencia_validada',
      'categoriaNombre' => sug['categoria'] || 'Sugerencia validada'
    }
  end

  entry = por_termino[term_key]
  from_complement = sug['motivo'] == 'texto_clinico_complementario'
  if entry
    existing_names = (entry['ejemplos'] || []).map { |e| normalize(e['nombre']) }
    next if existing_names.include?(dis_key)
    next if from_complement && sprint13_per_term[term_key] >= MAX_SPRINT13_PER_TERM
  end

  ejemplo = {
    'nombre' => disease['nombre'],
    'gravedad' => disease['gravedad'],
    'animalId' => sug['animalId'] || disease['animalId'],
    'breedId' => sug['breedId'] || disease['breedId'],
    'breedNombre' => disease['breedNombre']
  }

  if entry
    entry['ejemplos'] << ejemplo
    entry['ejemplos'] = entry['ejemplos'].first(MAX_EXAMPLES_PER_TERM)
    entry['total'] = entry['total'].to_i + 1
  else
    por_termino[term_key] = {
      'termino' => term_info['termino'],
      'categoriaId' => term_info['categoriaId'],
      'categoriaNombre' => term_info['categoriaNombre'],
      'total' => 1,
      'ejemplos' => [ejemplo],
      'origen' => 'sprint13_sugerencias'
    }
  end

  dis_entry = por_enfermedad[dis_key] ||= {
    'nombre' => disease['nombre'],
    'animalId' => disease['animalId'],
    'breedId' => disease['breedId'],
    'terminos' => []
  }
  unless dis_entry['terminos'].any? { |t| normalize(t['termino']) == term_key }
    dis_entry['terminos'] << {
      'termino' => term_info['termino'],
      'categoriaId' => term_info['categoriaId']
    }
    dis_entry['terminos'] = dis_entry['terminos']
      .sort_by { |t| t['termino'].downcase }
      .first(MAX_TERMS_PER_DISEASE)
  end

  sprint13_per_term[term_key] += 1
  integrated += 1
end

por_enfermedad.each_value do |entry|
  entry['terminos'] = entry['terminos']
    .sort_by { |t| t['termino'].downcase }
    .first(MAX_TERMS_PER_DISEASE)
end

output = links.merge(
  'generado_por' => 'scripts/data/build_cross_links.rb + integrate_suggested_links_sprint13.rb',
  'sprint13_integrados' => integrated,
  'total_terminos_enlazados' => por_termino.length,
  'total_enfermedades_enlazadas' => por_enfermedad.length,
  'por_termino' => por_termino,
  'por_enfermedad' => por_enfermedad
)

File.write(LINKS_PATH, JSON.pretty_generate(output) + "\n")
puts "integrate_suggested_links_sprint13: #{integrated} enlaces nuevos integrados"
puts "  términos enlazados:     #{por_termino.length}"
puts "  enfermedades enlazadas: #{por_enfermedad.length}"
abort "Se requieren al menos #{MIN_INTEGRATE} enlaces integrados" if integrated < MIN_INTEGRATE
