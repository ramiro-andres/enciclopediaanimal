# frozen_string_literal: true

# Genera data/evaluacion_preguntas.json (+ .js) desde el glosario médico.
# Mezcla MCQ (definición → término) y preguntas escritas (definición → término libre).
require 'json'
require 'time'

ROOT = File.expand_path('../..', __dir__)
DICT_PATH = File.join(ROOT, 'data', 'diccionario_medicos.json')
SYN_PATH = File.join(ROOT, 'data', 'search_synonyms.json')
OUT_JSON = File.join(ROOT, 'data', 'evaluacion_preguntas.json')
OUT_JS = File.join(ROOT, 'data', 'evaluacion_preguntas.js')

MCQ_TARGET = 80
WRITTEN_TARGET = 40
OPTIONS_PER_MCQ = 4
SEED = 51

def normalize(text)
  text.to_s.downcase
      .unicode_normalize(:nfd)
      .gsub(/\p{M}/, '')
      .gsub(/[^a-z0-9\s]/, ' ')
      .squeeze(' ')
      .strip
end

def strip_parens(term)
  term.to_s.gsub(/\s*\([^)]*\)\s*/, ' ').squeeze(' ').strip
end

dict = JSON.parse(File.read(DICT_PATH))
synonyms_map = begin
  JSON.parse(File.read(SYN_PATH)).fetch('terms', {})
rescue StandardError
  {}
end

terms = []
dict.fetch('categorias', []).each do |cat|
  (cat['terminos'] || []).each do |t|
    next if t['termino'].to_s.strip.empty? || t['definicion'].to_s.strip.empty?
    terms << {
      'termino' => t['termino'],
      'definicion' => t['definicion'],
      'categoria_id' => cat['id'],
      'categoria' => cat['nombre'],
      'sinonimos' => Array(t['sinonimos']).map(&:to_s).reject(&:empty?)
    }
  end
end

raise 'Glosario vacío: no se pueden generar preguntas' if terms.length < OPTIONS_PER_MCQ

rng = Random.new(SEED)
shuffled = terms.shuffle(random: rng)

def collect_synonyms(term_hash, synonyms_map)
  base = term_hash['termino']
  list = [base, strip_parens(base)]
  list.concat(term_hash['sinonimos'])
  list.concat(term_hash['sinonimos'].map { |s| strip_parens(s) })
  key = normalize(base)
  if synonyms_map[key]
    list.concat(synonyms_map[key])
  end
  # También probar sin paréntesis como clave
  key2 = normalize(strip_parens(base))
  list.concat(Array(synonyms_map[key2])) if synonyms_map[key2]
  list.map(&:to_s).map(&:strip).reject(&:empty?).uniq
end

mcq_pool = shuffled.take([MCQ_TARGET * 2, shuffled.length].min)
written_pool = shuffled.drop(mcq_pool.length / 2).take([WRITTEN_TARGET * 2, shuffled.length].min)

preguntas = []
id_seq = 0

mcq_pool.each do |term|
  break if preguntas.count { |p| p['tipo'] == 'mcq' } >= MCQ_TARGET

  distractors = terms
                .reject { |x| normalize(x['termino']) == normalize(term['termino']) }
                .sample(OPTIONS_PER_MCQ - 1, random: rng)
  next if distractors.length < OPTIONS_PER_MCQ - 1

  options = ([term] + distractors).shuffle(random: rng).map { |x| x['termino'] }
  correct_index = options.index(term['termino'])
  id_seq += 1
  preguntas << {
    'id' => "mcq-#{id_seq}",
    'tipo' => 'mcq',
    'prompt' => '¿Qué término del glosario corresponde a esta definición?',
    'prompt_en' => 'Which glossary term matches this definition?',
    'stem' => term['definicion'],
    'opciones' => options,
    'correct_index' => correct_index,
    'respuesta' => term['termino'],
    'sinonimos' => collect_synonyms(term, synonyms_map),
    'categoria' => term['categoria'],
    'categoria_id' => term['categoria_id']
  }
end

written_pool.each do |term|
  break if preguntas.count { |p| p['tipo'] == 'written' } >= WRITTEN_TARGET

  id_seq += 1
  preguntas << {
    'id' => "written-#{id_seq}",
    'tipo' => 'written',
    'prompt' => 'Escribe el término médico que corresponde a esta definición (se aceptan sinónimos y ortografía aproximada).',
    'prompt_en' => 'Write the medical term that matches this definition (synonyms and approximate spelling accepted).',
    'stem' => term['definicion'],
    'respuesta' => term['termino'],
    'sinonimos' => collect_synonyms(term, synonyms_map),
    'keywords' => normalize(term['termino']).split.reject { |w| w.length < 3 },
    'categoria' => term['categoria'],
    'categoria_id' => term['categoria_id']
  }
end

preguntas = preguntas.shuffle(random: rng)

payload = {
  'version' => 1,
  'generated_at' => Time.now.utc.iso8601,
  'pass_threshold' => 0.8,
  'disclaimer_es' => 'Simulación educativa de autoevaluación. No es un examen oficial ni otorga certificación profesional.',
  'disclaimer_en' => 'Educational self-assessment simulation. Not an official exam and does not grant professional certification.',
  'stats' => {
    'total' => preguntas.length,
    'mcq' => preguntas.count { |p| p['tipo'] == 'mcq' },
    'written' => preguntas.count { |p| p['tipo'] == 'written' },
    'source_terms' => terms.length
  },
  'preguntas' => preguntas
}

File.write(OUT_JSON, JSON.pretty_generate(payload))
File.write(OUT_JS, "window.EVALUACION_PREGUNTAS = #{payload.to_json};\n")
puts "evaluacion_preguntas: #{payload['stats']['mcq']} MCQ + #{payload['stats']['written']} escritas " \
     "(#{payload['stats']['total']} total) → data/evaluacion_preguntas.{json,js}"
