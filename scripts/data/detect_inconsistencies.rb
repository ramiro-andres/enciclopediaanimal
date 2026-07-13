# frozen_string_literal: true

# US-DEV-15 — Detección de inconsistencias en datos clínicos para CI.
# Alerta: dosis fuera de rango, campos clínicos vacíos, descripciones duplicadas.
# Uso: ruby scripts/data/detect_inconsistencies.rb
# Sale con código 1 si hay errores críticos; advertencias no bloquean.

require 'json'

ROOT = File.expand_path('../..', __dir__)
ENC_PATH = File.join(ROOT, 'data', 'enciclopedia.json')

DOSE_MIN = 0.001
DOSE_MAX = 500.0
MIN_DESC_LEN = 40
CLINICAL_FIELDS = %w[diagnostico tratamiento prevencion].freeze

errors = []
warnings = []
desc_map = Hash.new { |h, k| h[k] = [] }

data = JSON.parse(File.read(ENC_PATH))

data['animales'].each do |animal|
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |breed|
      ctx = "#{animal['id']}/#{breed['id']}"
      desc = breed['descripcion'].to_s.strip

      if desc.length < MIN_DESC_LEN
        warnings << "#{ctx}: descripción muy corta (#{desc.length} chars)"
      elsif desc.length >= MIN_DESC_LEN
        key = desc[0, 120]
        desc_map[key] << ctx
      end

      (breed['enfermedades'] || []).each do |disease|
        dctx = "#{ctx}/#{disease['nombre']}"

        CLINICAL_FIELDS.each do |field|
          text = disease[field].to_s.strip
          warnings << "#{dctx}: campo #{field} vacío" if text.empty?
        end

        (disease['protocolo_farmacologico'] || []).each_with_index do |entry, idx|
          raw = entry['dosis_mg_kg'].to_s.strip
          next if raw.empty? || raw == '—' || raw == '-'
          # Solo validar dosis en mg/kg; ignorar UI/kg, ml/kg, gotas, etc.
          next unless raw.match?(/mg\s*\/\s*kg/i)

          nums = raw.scan(/[\d]+[.,]?[\d]*/).map { |n| n.tr(',', '.').to_f }
          nums.each do |val|
            next if val.zero?

            if val < DOSE_MIN || val > DOSE_MAX
              errors << "#{dctx}: dosis fuera de rango (#{entry['principio_activo']}: #{raw})"
            end
          end
        end
      end
    end
  end
end

desc_map.each do |_prefix, breeds|
  next if breeds.length < 3

  warnings << "Descripción duplicada en #{breeds.length} razas: #{breeds.first(3).join(', ')}#{'...' if breeds.length > 3}"
end

puts 'Detección de inconsistencias — enciclopedia'
puts "  Errores: #{errors.length}"
puts "  Advertencias: #{warnings.length}"

if warnings.any?
  puts "\nAdvertencias (primeras 15):"
  warnings.first(15).each { |w| puts "  ⚠ #{w}" }
  puts "  ... y #{warnings.length - 15} más" if warnings.length > 15
end

if errors.any?
  puts "\nErrores críticos (primeros 20):"
  errors.first(20).each { |e| puts "  ✗ #{e}" }
  puts "  ... y #{errors.length - 20} más" if errors.length > 20
  exit 1
end

puts '✓ Sin errores críticos de inconsistencia'
exit 0
