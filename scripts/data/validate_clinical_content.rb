#!/usr/bin/env ruby
# frozen_string_literal: true

# Valida coherencia del contenido clínico en enciclopedia.json.
# Usado en CI y en ejecutar_pruebas.sh para detectar texto genérico o campos faltantes.

require 'json'

ROOT = File.expand_path('../..', __dir__)
INPUT = File.join(ROOT, 'data', 'enciclopedia.json')

GENERIC_DIAGNOSIS = /El veterinario realizará anamnesis detallada/i
GENERIC_DIAGNOSIS_SHORT = /^Evaluación clínica completa para/i

def generic_diagnosis?(text)
  t = text.to_s
  return true if t.match?(GENERIC_DIAGNOSIS_SHORT)
  return true if t.match?(GENERIC_DIAGNOSIS) && t.length < 220
  false
end
GENERIC_SYMPTOM = /signo clínico principal/i
MIN_DIAGNOSIS_LEN = 50
MIN_TREATMENT_LEN = 50
MIN_PREVENTION_LEN = 50
MIN_REFERENCES = 2
MIN_DIFFERENTIAL = 3
MIN_PROTOCOL_ENTRIES = 3
PROTOCOL_FIELDS = %w[principio_activo nombre_comercial dosis_mg_kg via frecuencia duracion notas].freeze
VALID_GRAVEDAD = %w[leve moderada grave].freeze

errors = []
warnings = []
breed_count = 0
disease_count = 0
sample_bibliography_ok = 0

data = JSON.parse(File.read(INPUT))

data['animales'].each do |animal|
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |breed|
      breed_count += 1
      refs = breed['fuentes_bibliograficas']
      sample_bibliography_ok += 1 if refs.is_a?(Array) && refs.length >= 1

      (breed['enfermedades'] || []).each do |disease|
        disease_count += 1
        ctx = "#{breed['id']}/#{disease['nombre']}"

        unless VALID_GRAVEDAD.include?(disease['gravedad'])
          errors << "#{ctx}: gravedad inválida (#{disease['gravedad']})"
        end

        %w[diagnostico tratamiento prevencion].each do |field|
          text = disease[field].to_s
          min_len = { 'diagnostico' => MIN_DIAGNOSIS_LEN, 'tratamiento' => MIN_TREATMENT_LEN, 'prevencion' => MIN_PREVENTION_LEN }[field]
          if text.length < min_len
            errors << "#{ctx}: #{field} demasiado corto (#{text.length} chars)"
          end
        end

        errors << "#{ctx}: diagnóstico genérico detectado" if generic_diagnosis?(disease['diagnostico'])

        (disease['sintomas'] || []).each do |symptom|
          errors << "#{ctx}: síntoma genérico (#{symptom})" if symptom.match?(GENERIC_SYMPTOM)
        end

        diff = disease['diagnostico_diferencial']
        if !diff.is_a?(Array) || diff.length < MIN_DIFFERENTIAL
          errors << "#{ctx}: diagnóstico diferencial insuficiente"
        end

        refs_d = disease['referencias']
        if !refs_d.is_a?(Array) || refs_d.length < MIN_REFERENCES
          errors << "#{ctx}: referencias insuficientes"
        end

        protocol = disease['protocolo_farmacologico']
        if !protocol.is_a?(Array) || protocol.length < MIN_PROTOCOL_ENTRIES
          errors << "#{ctx}: protocolo farmacológico insuficiente"
        else
          protocol.each_with_index do |entry, idx|
            PROTOCOL_FIELDS.each do |field|
              errors << "#{ctx}: protocolo[#{idx}] sin #{field}" unless entry[field]
            end
          end
        end
      end
    end
  end
end

if breed_count < 405
  errors << "Cantidad de razas insuficiente: #{breed_count} (mínimo 405)"
end

bibliography_ratio = sample_bibliography_ok.to_f / breed_count
if bibliography_ratio < 0.95
  warnings << "Solo #{sample_bibliography_ok}/#{breed_count} razas tienen fuentes_bibliograficas"
end

puts "Validación clínica — #{breed_count} razas, #{disease_count} enfermedades"

if warnings.any?
  puts "\nAdvertencias (#{warnings.length}):"
  warnings.first(10).each { |w| puts "  ⚠ #{w}" }
end

if errors.any?
  puts "\nErrores (#{errors.length}):"
  errors.first(20).each { |e| puts "  ✗ #{e}" }
  puts "  ... y #{errors.length - 20} más" if errors.length > 20
  exit 1
end

puts '✓ Contenido clínico válido'
exit 0
