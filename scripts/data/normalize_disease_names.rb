# frozen_string_literal: true

# Normaliza etiquetas de enfermedades y fusiona duplicados intra-raza
# (mismo nombre o mismo núcleo semántico, p. ej. KHV con orden de palabras distinto).
#
# Uso:
#   ruby scripts/data/normalize_disease_names.rb
#   ruby scripts/data/normalize_disease_names.rb --dry-run

require 'json'
require 'set'

module DiseaseNameNormalize
  ROOT = File.expand_path('../..', __dir__)
  DATA_PATH = File.join(ROOT, 'data', 'enciclopedia.json')

  # Variantes de etiqueta → nombre canónico del catálogo.
  RENAME_MAP = {
    'Enfermedad del Koi herpesvirus (KHV)' => 'Enfermedad del herpesvirus koi (KHV)',
    'Enfermedad de disco intervertebral' => 'Enfermedad del disco intervertebral',
    'Timpanismo (meteorismo ruminal)' => 'Timpanismo',
    'Neumonía (complejo respiratorio bovino)' => 'Neumonía',
    'Clostridiosis (mancha, gangrena gaseosa)' => 'Clostridiosis',
    'Psitacosis (clamidiosis)' => 'Psitacosis',
    'Tricobezoares (bolas de pelo)' => 'Tricobezoar',
    'Miasis (bichera)' => 'Miasis',
    'Estomatitis (boca podrida)' => 'Estomatitis',
    'Escorbuto (deficiencia de vitamina C)' => 'Escorbuto',
    'Poliquistosis renal (PKD)' => 'Poliquistosis renal',
    'Cálculos urinarios (urolitiasis)' => 'Cálculos urinarios',
    'Ácaros de patas (Cnemidocoptes)' => 'Ácaros de patas',
    'Meningeal worm (Parelaphostrongylus)' => 'Meningeal worm',
    'Hipocalcemia (fiebre de leche)' => 'Hipocalcemia posparto',
    'Pododermatitis (footrot)' => 'Pododermatitis',
    'Pododermatitis (llagas en corvejones)' => 'Pododermatitis',
    'Tumores (lipomas y otros)' => 'Tumores',
    'Infección respiratoria (neumonía)' => 'Infección respiratoria'
  }.freeze

  STOPWORDS = %w[
    de del la las los el y o en por para con sin
    enfermedad sindrome syndrome disease
  ].freeze

  module_function

  def normalize(text)
    String(text).to_s
      .unicode_normalize(:nfd)
      .gsub(/\p{Mn}/, '')
      .downcase
      .strip
  end

  # Núcleo comparable: sin paréntesis, stopwords y tokens ordenados.
  def merge_key(name)
    normalize(name)
      .gsub(/\([^)]*\)/, ' ')
      .gsub(/[^a-z0-9\s]/, ' ')
      .split
      .reject { |w| STOPWORDS.include?(w) || w.length < 2 }
      .sort
      .join(' ')
  end

  def richness(entry)
    score = 0
    score += 50 if entry['notas'].to_s.strip != ''
    score += 20 if entry['resumen_1min'].to_s.strip != ''
    score += Array(entry['sintomas']).size * 3
    score += Array(entry['examenes']).size
    score += Array(entry['medicamentos']).size
    score += Array(entry['referencias']).size * 2
    score += entry.to_json.bytesize / 50
    score
  end

  def merge_list(a, b)
    seen = Set.new
    out = []
    (Array(a) + Array(b)).each do |item|
      key = item.is_a?(Hash) ? item.to_json : normalize(item)
      next if key.empty? || seen.include?(key)

      seen << key
      out << item
    end
    out
  end

  def merge_entries(primary, secondary)
    merged = primary.dup
    secondary.each do |key, value|
      next if key == 'nombre'

      if value.is_a?(Array)
        merged[key] = merge_list(merged[key], value)
      elsif (merged[key].nil? || merged[key].to_s.strip.empty?) && !value.nil? && value.to_s.strip != ''
        merged[key] = value
      end
    end
    merged
  end

  def apply_renames_in_strings!(obj, renamed_counter)
    case obj
    when Hash
      obj.each do |key, value|
        if value.is_a?(String) && RENAME_MAP[value]
          obj[key] = RENAME_MAP[value]
          renamed_counter[:n] += 1
        else
          apply_renames_in_strings!(value, renamed_counter)
        end
      end
    when Array
      obj.each_with_index do |value, idx|
        if value.is_a?(String) && RENAME_MAP[value]
          obj[idx] = RENAME_MAP[value]
          renamed_counter[:n] += 1
        else
          apply_renames_in_strings!(value, renamed_counter)
        end
      end
    end
  end

  def run!(dry_run: false)
    data = JSON.parse(File.read(DATA_PATH))
    renamed = 0
    merged_pairs = 0
    removed = 0
    extra = { n: 0 }

    data['animales'].each do |animal|
      (animal['razas'] || {}).each_value do |razas|
        Array(razas).each do |raza|
          diseases = Array(raza['enfermedades'])
          next if diseases.empty? && !raza.key?('predisposiciones_geneticas')

          diseases.each do |enf|
            name = enf['nombre'].to_s
            canon = RENAME_MAP[name]
            next unless canon && canon != name

            enf['nombre'] = canon
            renamed += 1
          end

          buckets = {}
          diseases.each do |enf|
            key = merge_key(enf['nombre'])
            key = normalize(enf['nombre']) if key.empty?
            (buckets[key] ||= []) << enf
          end

          new_list = []
          buckets.each_value do |group|
            if group.size == 1
              new_list << group[0]
              next
            end

            ranked = group.sort_by { |e| -richness(e) }
            keep = ranked[0]
            ranked[1..].each do |extra_entry|
              keep = merge_entries(keep, extra_entry)
              merged_pairs += 1
              removed += 1
            end
            preferred = group.map { |e| e['nombre'] }.find { |n| RENAME_MAP.value?(n) }
            keep['nombre'] = preferred if preferred
            new_list << keep
          end

          raza['enfermedades'] = new_list unless diseases.empty?

          # Predisposiciones y otros strings con la etiqueta antigua.
          apply_renames_in_strings!(raza['predisposiciones_geneticas'], extra) if raza['predisposiciones_geneticas']
          apply_renames_in_strings!(raza['senales_alerta'], extra) if raza['senales_alerta']
        end
      end
    end

    unless dry_run
      File.write(DATA_PATH, JSON.pretty_generate(data) + "\n")
    end

    {
      renamed: renamed,
      renamed_elsewhere: extra[:n],
      merged_pairs: merged_pairs,
      removed: removed,
      dry_run: dry_run
    }
  end
end

if $PROGRAM_NAME == __FILE__
  dry = ARGV.include?('--dry-run')
  stats = DiseaseNameNormalize.run!(dry_run: dry)
  puts "Renombradas (nombre ficha): #{stats[:renamed]}"
  puts "Renombradas (predisposiciones/otros): #{stats[:renamed_elsewhere]}"
  puts "Fusiones (pares): #{stats[:merged_pairs]}"
  puts "Entradas eliminadas por merge: #{stats[:removed]}"
  puts '(dry-run, sin escribir)' if dry
end
