# frozen_string_literal: true

# Enriquece razas nuevas con perfiles clínicos, nutrición e imágenes de enfermedad.
require 'json'

ROOT = File.expand_path('../..', __dir__)
INPUT = File.join(ROOT, 'data', 'enciclopedia.json')
require_relative 'breed_clinical_profiles'
require_relative 'breed_nutrition_profiles'
require_relative 'expand_enciclopedia'
require_relative 'pharma_protocols'

def disease_image_path(animal_id, name)
  slug = name.to_s.downcase
    .unicode_normalize(:nfd).gsub(/[\u0300-\u036f]/, '')
    .gsub(/[^a-z0-9]+/, '_')
    .gsub(/^_|_$/, '')
  "images/enfermedades/#{animal_id}_#{slug}.jpg"
end

def ensure_disease_fields(disease, animal_id, breed_id)
  d = expand_disease(disease, animal_id, breed_id)
  d['imagen'] ||= disease_image_path(animal_id, d['nombre'])
  d['diagnostico_diferencial'] ||= ['Diagnósticos alternativos según presentación clínica', 'Enfermedades infecciosas con signos superpuestos', 'Procesos metabólicos o nutricionales']
  d['criterios_diagnostico'] ||= "Criterios clínicos y de laboratorio para confirmar #{d['nombre'].downcase} en #{animal_id}."
  d['referencias'] ||= ['Merck Veterinary Manual', 'Manual de medicina interna veterinaria de referencia']
  d['notas_clinicas'] ||= "Notas orientativas para #{d['nombre'].downcase}; ajustar al contexto individual del paciente."
  d['protocolo_farmacologico'] = PharmaProtocols.generate(d, animal_id) if d['protocolo_farmacologico'].nil? || d['protocolo_farmacologico'].length < 3
  d
end

data = JSON.parse(File.read(INPUT))
updated = 0

data['animales'].each do |animal|
  %w[pequena mediana grande].each do |size|
    animal['razas'][size] = (animal.dig('razas', size) || []).map do |breed|
      needs = breed['nutricion_detallada'].nil? ||
              breed['predisposiciones_geneticas'].nil? ||
              (breed['enfermedades'] || []).any? { |d| d['imagen'].nil? }
      next breed unless needs

      enriched = BreedClinicalProfiles.enrich_breed(breed, animal['id'], size)
      enriched['enfermedades'] = (enriched['enfermedades'] || []).map do |d|
        ensure_disease_fields(d, animal['id'], breed['id'])
      end
      updated += 1
      enriched
    end
  end
end

File.write(INPUT, JSON.pretty_generate(data))
puts "Razas enriquecidas: #{updated}"
