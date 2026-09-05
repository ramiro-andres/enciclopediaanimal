# frozen_string_literal: true

# Genera data/evaluacion_preguntas.json (+ .js) desde el glosario médico.
# Mezcla MCQ (definición → término) y preguntas escritas (definición → término libre).
# El enunciado (stem) NUNCA debe contener el término respuesta ni sus sinónimos.
require 'json'
require 'time'

ROOT = File.expand_path('../..', __dir__)
DICT_PATH = File.join(ROOT, 'data', 'diccionario_medicos.json')
SYN_PATH = File.join(ROOT, 'data', 'search_synonyms.json')
OUT_JSON = File.join(ROOT, 'data', 'evaluacion_preguntas.json')
OUT_JS = File.join(ROOT, 'data', 'evaluacion_preguntas.js')

OPTIONS_PER_MCQ = 4
MIN_PER_CATEGORY = 10
WRITTEN_RATIO = 0.3
SEED = 52

# Definiciones tautológicas tras redactar el término (poco útiles como enunciado).
WEAK_STEM_PATTERNS = [
  /\A_{2,}\s*es una condición clínica documentada/i,
  /\A_{2,}\s*es cuadro por exposición/i,
  /\A_{2,}\s*es lesión mecánica/i,
  /\A_{2,}\s*es alteración ocular/i,
  /\A_{2,}\s*es afección de vías/i,
  /\A_{2,}\s*es proliferación celular/i,
  /\A_{2,}\s*es salida anormal/i,
  /\A_{2,}\s*es\b/i
].freeze

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

def collect_synonyms(term_hash, synonyms_map)
  base = term_hash['termino']
  list = [base, strip_parens(base)]
  list.concat(term_hash['sinonimos'])
  list.concat(term_hash['sinonimos'].map { |s| strip_parens(s) })
  list.concat(base.to_s.scan(/\(([^)]+)\)/).flatten)
  key = normalize(base)
  list.concat(Array(synonyms_map[key])) if synonyms_map[key]
  key2 = normalize(strip_parens(base))
  list.concat(Array(synonyms_map[key2])) if synonyms_map[key2]
  list.map(&:to_s).map(&:strip).reject { |s| s.empty? || s.length < 2 }.uniq
end

def answer_forms(term_hash, synonyms_map)
  collect_synonyms(term_hash, synonyms_map).sort_by { |s| -s.length }
end

# Sustituye el término (y alias) por huecos para que el enunciado no filtre la respuesta.
def redact_stem(definition, forms)
  text = definition.to_s.dup
  forms.each do |form|
    next if form.length < 2

    esc = Regexp.escape(form)
    text.gsub!(/[«“"'']#{esc}[»”"'']/i, '____')
    text.gsub!(/(?<![\p{L}\p{N}_])#{esc}(?![\p{L}\p{N}_])/i, '____')
  end

  text.gsub!(/También se menciona como _{2,}[^.]*\.?\s*/i, '')
  text.gsub!(/\A_{2,}\s*es un principio activo citado en protocolos de referencia de esta enciclopedia\.\s*/i, '')
  text.gsub!(/\s*_{2,}\s*aparece en protocolos de referencia de esta enciclopedia;\s*/i, ' ')
  text.gsub!(/Uso educativo; no sustituye la valoración de un veterinario colegiado\.?/i, '')
  text.gsub!(/\s{2,}/, ' ')
  text = text.strip.sub(/\A[,.;:\s]+/, '').sub(/[,;\s]+\z/, '')
  text += '.' unless text.empty? || text.match?(/[.!?…]$/)
  text
end

def stem_leaks_answer?(stem, forms)
  nstem = normalize(stem)
  forms.any? { |f| f.length >= 3 && nstem.include?(normalize(f)) }
end

def weak_stem?(stem)
  return true if stem.to_s.strip.length < 45

  WEAK_STEM_PATTERNS.any? { |rx| stem.match?(rx) }
end

def build_eligible_term(raw, cat, synonyms_map)
  term = {
    'termino' => raw['termino'],
    'definicion' => raw['definicion'],
    'categoria_id' => cat['id'],
    'categoria' => cat['nombre'],
    'sinonimos' => Array(raw['sinonimos']).map(&:to_s).reject(&:empty?)
  }
  forms = answer_forms(term, synonyms_map)
  stem = redact_stem(term['definicion'], forms)
  return nil if stem_leaks_answer?(stem, forms) || weak_stem?(stem)

  term.merge('stem' => stem, 'forms' => forms)
end

dict = JSON.parse(File.read(DICT_PATH))
synonyms_map = begin
  JSON.parse(File.read(SYN_PATH)).fetch('terms', {})
rescue StandardError
  {}
end

by_category = {}
dict.fetch('categorias', []).each do |cat|
  eligible = []
  (cat['terminos'] || []).each do |t|
    next if t['termino'].to_s.strip.empty? || t['definicion'].to_s.strip.empty?

    built = build_eligible_term(t, cat, synonyms_map)
    eligible << built if built
  end
  by_category[cat['id']] = {
    'nombre' => cat['nombre'],
    'terms' => eligible
  }
end

short = by_category.select { |_, v| v['terms'].length < MIN_PER_CATEGORY }
unless short.empty?
  detail = short.map { |id, v| "#{id}=#{v['terms'].length}" }.join(', ')
  raise "Categorías con menos de #{MIN_PER_CATEGORY} términos elegibles: #{detail}"
end

all_terms = by_category.values.flat_map { |v| v['terms'] }
raise 'Glosario vacío: no se pueden generar preguntas' if all_terms.length < OPTIONS_PER_MCQ

rng = Random.new(SEED)
preguntas = []
id_seq = 0
stats_by_cat = {}

by_category.each do |_cat_id, bucket|
  pool = bucket['terms'].shuffle(random: rng)
  # Al menos MIN_PER_CATEGORY; en categorías grandes usamos todos los elegibles.
  selected = pool
  raise "#{bucket['nombre']}: solo #{selected.length} elegibles" if selected.length < MIN_PER_CATEGORY

  written_target = [1, (selected.length * WRITTEN_RATIO).round].max
  written_target = [written_target, selected.length - 1].min # dejar al menos 1 MCQ si hay opciones

  selected.each_with_index do |term, idx|
    tipo = idx < written_target ? 'written' : 'mcq'

    if tipo == 'mcq'
      distractors = all_terms
                    .reject { |x| normalize(x['termino']) == normalize(term['termino']) }
                    .sample(OPTIONS_PER_MCQ - 1, random: rng)
      if distractors.length < OPTIONS_PER_MCQ - 1
        # Sin distractores suficientes: convertir a escrita
        tipo = 'written'
      else
        options = ([term] + distractors).shuffle(random: rng).map { |x| x['termino'] }
        correct_index = options.index(term['termino'])
        id_seq += 1
        preguntas << {
          'id' => "mcq-#{id_seq}",
          'tipo' => 'mcq',
          'prompt' => '¿Qué término del glosario corresponde a esta definición?',
          'prompt_en' => 'Which glossary term matches this definition?',
          'stem' => term['stem'],
          'opciones' => options,
          'correct_index' => correct_index,
          'respuesta' => term['termino'],
          'sinonimos' => collect_synonyms(term, synonyms_map),
          'categoria' => term['categoria'],
          'categoria_id' => term['categoria_id']
        }
        next
      end
    end

    id_seq += 1
    preguntas << {
      'id' => "written-#{id_seq}",
      'tipo' => 'written',
      'prompt' => 'Escribe el término médico que corresponde a esta definición (se aceptan sinónimos y ortografía aproximada).',
      'prompt_en' => 'Write the medical term that matches this definition (synonyms and approximate spelling accepted).',
      'stem' => term['stem'],
      'respuesta' => term['termino'],
      'sinonimos' => collect_synonyms(term, synonyms_map),
      'keywords' => normalize(term['termino']).split.reject { |w| w.length < 3 },
      'categoria' => term['categoria'],
      'categoria_id' => term['categoria_id']
    }
  end

  stats_by_cat[bucket['nombre']] = preguntas.count { |p| p['categoria'] == bucket['nombre'] }
end

# Garantía final: ningún stem filtra la respuesta
preguntas.each do |q|
  forms = answer_forms(
    { 'termino' => q['respuesta'], 'sinonimos' => q['sinonimos'] || [] },
    {}
  )
  # Incluir sinónimos ya listados en la pregunta
  forms = (forms + Array(q['sinonimos'])).uniq.sort_by { |s| -s.length }
  if stem_leaks_answer?(q['stem'], forms)
    raise "Stem filtra respuesta en #{q['id']}: #{q['respuesta']}"
  end
end

short_final = stats_by_cat.select { |_, n| n < MIN_PER_CATEGORY }
raise "Categorías por debajo del mínimo tras generar: #{short_final}" unless short_final.empty?

preguntas = preguntas.shuffle(random: rng)

payload = {
  'version' => 2,
  'generated_at' => Time.now.utc.iso8601,
  'pass_threshold' => 0.8,
  'min_per_category' => MIN_PER_CATEGORY,
  'disclaimer_es' => 'Simulación educativa de autoevaluación. No es un examen oficial ni otorga certificación profesional.',
  'disclaimer_en' => 'Educational self-assessment simulation. Not an official exam and does not grant professional certification.',
  'stats' => {
    'total' => preguntas.length,
    'mcq' => preguntas.count { |p| p['tipo'] == 'mcq' },
    'written' => preguntas.count { |p| p['tipo'] == 'written' },
    'source_terms' => all_terms.length,
    'categories' => stats_by_cat.length,
    'min_per_category' => stats_by_cat.values.min,
    'by_category' => stats_by_cat
  },
  'preguntas' => preguntas
}

File.write(OUT_JSON, JSON.pretty_generate(payload))
File.write(OUT_JS, "window.EVALUACION_PREGUNTAS = #{payload.to_json};\n")
puts "evaluacion_preguntas: #{payload['stats']['mcq']} MCQ + #{payload['stats']['written']} escritas " \
     "(#{payload['stats']['total']} total, ≥#{MIN_PER_CATEGORY}/categoría) → data/evaluacion_preguntas.{json,js}"
stats_by_cat.sort_by { |_, n| -n }.each do |nombre, n|
  puts "  #{n.to_s.rjust(3)}  #{nombre}"
end
