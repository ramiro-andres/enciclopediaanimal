#!/usr/bin/env ruby
# frozen_string_literal: true
# Enriquece toda la enciclopedia con contenido clínico veterinario detallado y fidedigno

require 'json'

ROOT = File.expand_path('../..', __dir__)
INPUT = File.join(ROOT, 'data', 'enciclopedia.json')

require_relative 'clinical_disease_library'
require_relative 'breed_clinical_profiles'
require_relative 'breed_nutrition_profiles'
require_relative 'pharma_protocols'

puts 'Cargando enciclopedia...'
data = JSON.parse(File.read(INPUT))

enriched_diseases = 0
enriched_breeds = 0
clinical_matches = 0

data['animales'].each do |animal|
  animal_id = animal['id']
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |breed|
      # Enriquecer raza
      enriched_breed = BreedClinicalProfiles.enrich_breed(breed, animal_id, size)
      breed.replace(enriched_breed)
      enriched_breeds += 1

      # Enriquecer enfermedades
      breed['enfermedades'].each_with_index do |disease, idx|
        enriched = ClinicalDiseaseLibrary.enrich_disease(disease, animal_id, breed['id'])
        clinical_matches += 1 if ClinicalDiseaseLibrary.lookup(disease['nombre'], animal_id)

        # Regenerar protocolo farmacológico con mapeo corregido
        enriched['protocolo_farmacologico'] = PharmaProtocols.generate(enriched, animal_id)

        breed['enfermedades'][idx] = enriched
        enriched_diseases += 1
      end
    end
  end
end

File.write(INPUT, JSON.pretty_generate(data))

# Validación
parsed = JSON.parse(File.read(INPUT))
breed_count = parsed['animales'].flat_map { |a| a['razas'].values.flatten }.length
disease_count = parsed['animales'].flat_map { |a| a['razas'].values.flatten }.sum { |r| r['enfermedades'].length }

# Verificar calidad: sin relleno genérico
generic_count = 0
parsed['animales'].each do |animal|
  animal['razas'].values.flatten.each do |breed|
    breed['enfermedades'].each do |d|
      generic_count += 1 if d['diagnostico']&.include?('El veterinario realizará anamnesis detallada')
      generic_count += 1 if d['sintomas']&.any? { |s| s.match?(/signo clínico principal/i) }
    end
  end
end

# Verificar protocolos
missing_protocol = 0
parsed['animales'].each do |animal|
  animal['razas'].values.flatten.each do |breed|
    breed['enfermedades'].each do |d|
      pf = d['protocolo_farmacologico']
      missing_protocol += 1 if pf.nil? || pf.length < 3
    end
  end
end

puts ''
puts "✓ Razas enriquecidas: #{enriched_breeds}"
puts "✓ Enfermedades enriquecidas: #{enriched_diseases}"
puts "✓ Coincidencias con biblioteca clínica: #{clinical_matches}"
puts "✓ Total razas: #{breed_count}"
puts "✓ Total enfermedades: #{disease_count}"
puts "✓ Campos genéricos restantes: #{generic_count}"
puts "✓ Enfermedades sin protocolo: #{missing_protocol}"
puts "Guardado: #{INPUT}"

raise 'Validación fallida: faltan protocolos' if missing_protocol > 0
