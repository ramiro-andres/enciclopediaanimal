# frozen_string_literal: true

# Aplica perfiles clínicos por especie a razas que aún no los tienen completos (F3-04).
require 'json'

ROOT = File.expand_path('../..', __dir__)
INPUT = File.join(ROOT, 'data', 'enciclopedia.json')
require_relative 'breed_clinical_profiles'

PROFILE_FIELDS = %w[
  parametros_salud vacunacion vacunacion_detallada desparasitacion revisiones
  cribado_salud_recomendado nutricion_clinica manejo_clinico contraindicaciones_especie
  fuentes_bibliograficas
].freeze

data = JSON.parse(File.read(INPUT))
updated = 0

data['animales'].each do |animal|
  profile = BreedClinicalProfiles::SPECIES_PROFILES[animal['id']]
  next unless profile

  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |breed|
      changed = false
      PROFILE_FIELDS.each do |field|
        next if breed[field] && !breed[field].to_s.empty?

        breed[field] = profile[field]
        changed = true
      end
      updated += 1 if changed
    end
  end
end

File.write(INPUT, JSON.pretty_generate(data))
puts "Razas con perfiles clínicos actualizados: #{updated}"
