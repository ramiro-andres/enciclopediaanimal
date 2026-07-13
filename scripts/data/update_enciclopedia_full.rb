# frozen_string_literal: true

require 'json'

ROOT = File.expand_path('../..', __dir__)
INPUT = File.join(ROOT, 'data', 'enciclopedia.json')

require_relative 'pharma_protocols'
require_relative 'new_breeds_data'
require_relative 'more_breeds_batch2'
require_relative 'production_breeds_batch3'
require_relative 'production_breeds_batch4'
require_relative 'production_breeds_batch5'
require_relative 'production_breeds_batch6_colombia'
require_relative 'production_breeds_batch7_international'
require_relative 'production_breeds_batch7_latam'
require_relative 'production_breeds_batch8'
require_relative 'expand_enciclopedia'
require 'set'

def build_disease(name, gravedad, animal_id, breed_id)
  base = {
    'nombre' => name,
    'gravedad' => gravedad,
    'sintomas' => ["Signo clínico principal de #{name.downcase}", 'Letargo o cambio de conducta', 'Pérdida de apetito', 'Fiebre o decaimiento', 'Dolor a la palpación', 'Empeoramiento progresivo sin tratamiento'],
    'diagnostico' => "Evaluación clínica completa para #{name.downcase} por veterinario especializado en #{animal_id}.",
    'tratamiento' => "Plan terapéutico individualizado para #{name.downcase} según gravedad y especie.",
    'prevencion' => "Medidas preventivas específicas para reducir el riesgo de #{name.downcase} en esta raza."
  }
  expand_disease(base, animal_id, breed_id)
end

def build_breed_entry(row)
  animal_id, tamano, id, nombre, origen, peso, esperanza_vida, temperamento, desc, cuidados, alimentacion = row
  pool = DISEASES_BY_ANIMAL[animal_id] || DISEASES_BY_ANIMAL['perros']
  diseases = pool.first(6).map { |n, g| build_disease(n, g, animal_id, id) }

  {
    'id' => id,
    'nombre' => nombre,
    'descripcion' => desc,
    'imagen' => "images/#{id}.svg",
    'origen' => origen,
    'esperanza_vida' => esperanza_vida,
    'peso' => peso,
    'temperamento' => temperamento,
    'cuidados' => cuidados,
    'alimentacion' => alimentacion,
    'enfermedades' => diseases
  }
end

puts 'Cargando JSON...'
data = JSON.parse(File.read(INPUT))

# TASK 1: protocolo_farmacologico en todas las enfermedades existentes
protocol_count = 0
data['animales'].each do |animal|
  %w[pequena mediana grande].each do |size|
    (animal['razas'][size] || []).each do |breed|
      breed['enfermedades'].each do |disease|
        disease['protocolo_farmacologico'] = PharmaProtocols.generate(disease, animal['id'])
        protocol_count += disease['protocolo_farmacologico'].length
      end
    end
  end
end
puts "Protocolos añadidos a enfermedades existentes (#{protocol_count} entradas)"

# TASK 2: añadir nuevas razas
existing_ids = {}
data['animales'].each do |animal|
  existing_ids[animal['id']] = %w[pequena mediana grande].flat_map { |s| (animal['razas'][s] || []).map { |r| r['id'] } }.to_set
end

added = 0
skipped = 0
ALL_NEW_BREEDS = (
  NEW_BREEDS + MORE_BREEDS + PRODUCTION_BREEDS +
  PRODUCTION_BREEDS_BATCH4 + PRODUCTION_BREEDS_BATCH5 +
  PRODUCTION_BREEDS_BATCH6_COLOMBIA + PRODUCTION_BREEDS_BATCH7_LATAM +
  PRODUCTION_BREEDS_BATCH7_INTERNATIONAL + PRODUCTION_BREEDS_BATCH8
).freeze
ALL_BREED_EXTRA = BREED_EXTRA
  .merge(MORE_BREED_EXTRA)
  .merge(PRODUCTION_BREED_EXTRA)
  .merge(PRODUCTION_BREED_EXTRA_BATCH4)
  .merge(PRODUCTION_BREED_EXTRA_BATCH5)
  .merge(PRODUCTION_BREED_EXTRA_BATCH6_COLOMBIA)
  .merge(PRODUCTION_BREED_EXTRA_BATCH7_LATAM)
  .merge(PRODUCTION_BREED_EXTRA_BATCH7)
  .merge(PRODUCTION_BREED_EXTRA_BATCH8)
  .freeze
ALL_PRODUCTION_EXTRA = PRODUCTION_BREED_EXTRA
  .merge(PRODUCTION_BREED_EXTRA_BATCH4)
  .merge(PRODUCTION_BREED_EXTRA_BATCH5)
  .merge(PRODUCTION_BREED_EXTRA_BATCH6_COLOMBIA)
  .merge(PRODUCTION_BREED_EXTRA_BATCH7_LATAM)
  .merge(PRODUCTION_BREED_EXTRA_BATCH7)
  .merge(PRODUCTION_BREED_EXTRA_BATCH8)
  .freeze

ALL_NEW_BREEDS.each do |row|
  animal_id = row[0]
  tamano = row[1]
  breed_id = row[2]

  if existing_ids[animal_id]&.include?(breed_id)
    # Mantener sincronizados los datos zootécnicos del lote productivo.
    if ALL_PRODUCTION_EXTRA.key?(breed_id)
      animal = data['animales'].find { |a| a['id'] == animal_id }
      breed = animal['razas'].values.flatten.find { |b| b['id'] == breed_id }
      _animal_id, _size, _id, nombre, origen, peso, esperanza_vida,
        temperamento, descripcion, cuidados, alimentacion = row
      breed.merge!(
        'nombre' => nombre,
        'origen' => origen,
        'peso' => peso,
        'esperanza_vida' => esperanza_vida,
        'temperamento' => temperamento,
        'descripcion' => descripcion,
        'cuidados' => cuidados,
        'alimentacion' => alimentacion
      )
      ALL_PRODUCTION_EXTRA.fetch(breed_id).each { |key, value| breed[key.to_s] = value }
    end
    skipped += 1
    next
  end

  animal = data['animales'].find { |a| a['id'] == animal_id }
  next unless animal

  breed = build_breed_entry(row)
  breed = expand_breed(breed, animal_id)

  extra = ALL_BREED_EXTRA[breed_id]
  if extra
    extra.each { |k, v| breed[k.to_s] = v }
  end

  breed['enfermedades'].each do |d|
    d['protocolo_farmacologico'] = PharmaProtocols.generate(d, animal_id)
  end

  animal['razas'][tamano] ||= []
  animal['razas'][tamano] << breed
  existing_ids[animal_id] << breed_id
  added += 1
end
puts "Razas añadidas: #{added}, omitidas (duplicadas): #{skipped}"

# Guardar
File.write(INPUT, JSON.pretty_generate(data))
puts "Guardado: #{INPUT}"

# Validación
parsed = JSON.parse(File.read(INPUT))
breed_count = parsed['animales'].flat_map { |a| a['razas'].values.flatten }.length
disease_count = parsed['animales'].flat_map { |a| a['razas'].values.flatten }.sum { |r| r['enfermedades'].length }
missing_protocol = 0
parsed['animales'].each do |animal|
  animal['razas'].values.flatten.each do |breed|
    breed['enfermedades'].each do |d|
      pf = d['protocolo_farmacologico']
      if pf.nil? || pf.length < 3
        missing_protocol += 1
      else
        pf.each do |entry|
          %w[principio_activo nombre_comercial dosis_mg_kg via frecuencia duracion notas].each do |f|
            raise "Falta #{f} en #{breed['id']}/#{d['nombre']}" unless entry[f]
          end
        end
      end
    end
  end
end

puts "JSON válido ✓"
puts "Total razas: #{breed_count}"
puts "Total enfermedades: #{disease_count}"
puts "Enfermedades sin protocolo completo: #{missing_protocol}"
raise 'Validación fallida: faltan protocolos' if missing_protocol > 0
