# frozen_string_literal: true

# Sugiere enlaces glosario ↔ enfermedad por similitud de texto para revisión manual.
# Salida opcional: data/sugerencias_enlaces.json (Sprint 12 — US-DEV-16)

require 'json'
require 'set'
require 'time'

ROOT = File.expand_path('../..', __dir__)
OUT = File.join(ROOT, 'data', 'sugerencias_enlaces.json')

MIN_TERM_LENGTH = 5
MIN_SCORE = 0.25
MAX_SUGGESTIONS = 200

def normalize(text)
  String(text).to_s
    .unicode_normalize(:nfd)
    .gsub(/\p{Mn}/, '')
    .downcase
    .strip
end

def tokenize(text)
  normalize(text).scan(/[a-z0-9áéíóúüñ]+/).reject { |t| t.length < 3 }
end

def jaccard(a_tokens, b_tokens)
  a = a_tokens.to_set
  b = b_tokens.to_set
  union = (a | b).size
  return 0.0 if union.zero?

  (a & b).size.to_f / union
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

data = JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
dict = JSON.parse(File.read(File.join(ROOT, 'data', 'diccionario_medicos.json')))
links_path = File.join(ROOT, 'data', 'enlaces_clinicos.json')
linked_terms = if File.exist?(links_path)
                 JSON.parse(File.read(links_path)).fetch('por_termino', {}).keys.to_set
               else
                 Set.new
               end

diseases = {}
data['animales'].each do |animal|
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |raza|
      (raza['enfermedades'] || []).each do |enf|
        key = normalize(enf['nombre'])
        next if key.empty?

        diseases[key] ||= {
          'nombre' => enf['nombre'],
          'animalId' => animal['id'],
          'breedId' => raza['id'],
          'texto' => disease_text(enf),
          'tokens' => tokenize(disease_text(enf))
        }
      end
    end
  end
end

terms = []
(dict['categorias'] || []).each do |cat|
  (cat['terminos'] || []).each do |term|
    tnorm = normalize(term['termino'])
    next if tnorm.length < MIN_TERM_LENGTH
    next if linked_terms.include?(tnorm)

    terms << {
      termino: term['termino'],
      termino_norm: tnorm,
      categoria: cat['nombre'],
      definicion: term['definicion'],
      tokens: tokenize("#{term['termino']} #{term['definicion']}")
    }
  end
end

suggestions = []
terms.each do |term|
  diseases.each_value do |dis|
    term_in_text = dis['texto'].include?(term[:termino_norm])
    score = jaccard(term[:tokens], dis['tokens'])
    score = [score, 0.4].max if term_in_text
    next if score < MIN_SCORE

    final_score = score.round(3)

    suggestions << {
      'termino' => term[:termino],
      'termino_norm' => term[:termino_norm],
      'categoria' => term[:categoria],
      'enfermedad' => dis['nombre'],
      'enfermedad_norm' => normalize(dis['nombre']),
      'animalId' => dis['animalId'],
      'breedId' => dis['breedId'],
      'score' => final_score,
      'motivo' => term_in_text ? 'texto_clinico' : 'similitud_texto'
    }
  end
end

suggestions.sort_by! { |s| -s['score'] }
suggestions = suggestions.first(MAX_SUGGESTIONS)

payload = {
  'generated_at' => Time.now.utc.iso8601,
  'total_sugerencias' => suggestions.length,
  'nota' => 'Sugerencias para revisión manual; no se aplican automáticamente en la UI.',
  'sugerencias' => suggestions
}

File.write(OUT, JSON.pretty_generate(payload))
puts "sugerencias_enlaces.json generado (#{suggestions.length} sugerencias) → #{OUT}"
