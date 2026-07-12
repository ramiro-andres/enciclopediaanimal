# frozen_string_literal: true

# Genera calculadora_dosis por raza a partir de protocolo_farmacologico existente.
# Fuentes de concentraciones comerciales (solo orientativas):
# - Plumb's Veterinary Drug Handbook, 9th ed.
# - BSAVA Small Animal Formulary
#
# Uso: ruby scripts/data/build_dose_calculator.rb
# Regenerar JS: bash actualizar_datos.sh

require 'json'
require_relative 'pharma_protocols'

DATA_ROOT = File.expand_path('../..', __dir__)
JSON_PATH = File.join(DATA_ROOT, 'data', 'enciclopedia.json')

# Concentraciones mg/ml para estimar volumen oral/inyectable (educativo, no prescriptivo)
CONCENTRACIONES = {
  'Meloxicam' => 1.5,
  'Carprofeno' => 20.0,
  'Amoxicilina + Ácido clavulánico' => 50.0,
  'Cefalexina' => 100.0,
  'Gabapentina' => 50.0,
  'Omeprazol' => 2.0,
  'Prednisolona' => 5.0,
  'Enalapril' => 1.0,
  'Pimobendan' => 1.25,
  'Furosemida' => 10.0,
  'Tramadol' => 10.0,
  'Maropitant' => 10.0,
  'Clindamicina' => 25.0,
  'Enrofloxacina' => 25.0,
  'Metronidazol' => 40.0,
  'Fenbendazol' => 100.0,
  'Flunixin meglumine' => 50.0,
  'Fenilbutazona' => 200.0
}.freeze

def parse_decimal(str)
  s = str.to_s.strip
  if s.include?(',') && s.include?('.')
    s.tr('.', '').tr(',', '.').to_f
  elsif s.include?(',')
    s.tr(',', '.').to_f
  else
    s.to_f
  end
end

def parse_peso_kg(peso_texto)
  return { min: nil, max: nil, tipico: 10.0, texto: peso_texto } unless peso_texto

  if peso_texto =~ /(\d[\d.,]*)\s*-\s*(\d[\d.,]*)\s*kg/i
    min = parse_decimal(Regexp.last_match(1))
    max = parse_decimal(Regexp.last_match(2))
    { min: min, max: max, tipico: ((min + max) / 2.0).round(2), texto: peso_texto }
  elsif peso_texto =~ /(\d[\d.,]*)\s*kg/i
    val = parse_decimal(Regexp.last_match(1))
    { min: val, max: val, tipico: val, texto: peso_texto }
  else
    { min: nil, max: nil, tipico: 10.0, texto: peso_texto }
  end
end

def parse_dosis(dosis_texto)
  base = {
    dosis_texto: dosis_texto,
    calculable: false,
    unidad: nil,
    min_por_kg: nil,
    max_por_kg: nil
  }
  return base unless dosis_texto

  normalized = dosis_texto.strip

  if normalized =~ /^(\d[\d.,]*)\s*-\s*(\d[\d.,]*)\s*(mg|ml|mcg|UI|g)\/kg/i
    unit = Regexp.last_match(3).downcase
    unit = 'UI' if unit == 'ui'
    {
      dosis_texto: dosis_texto,
      calculable: true,
      unidad: "#{unit}/kg",
      min_por_kg: parse_decimal(Regexp.last_match(1)),
      max_por_kg: parse_decimal(Regexp.last_match(2))
    }
  elsif normalized =~ /^(\d[\d.,]*)\s*(mg|ml|mcg|UI|g)\/kg/i
    unit = Regexp.last_match(2).downcase
    unit = 'UI' if unit == 'ui'
    val = parse_decimal(Regexp.last_match(1))
    {
      dosis_texto: dosis_texto,
      calculable: true,
      unidad: "#{unit}/kg",
      min_por_kg: val,
      max_por_kg: val
    }
  else
    base
  end
end

def drug_key(entry)
  entry['principio_activo'].to_s.downcase.strip
end

def build_farmaco(entry, enfermedad, origen: 'protocolo')
  parsed = parse_dosis(entry['dosis_mg_kg'])
  concentracion = CONCENTRACIONES[entry['principio_activo']]
  {
    'id' => drug_key(entry).gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, ''),
    'principio_activo' => entry['principio_activo'],
    'nombre_comercial' => entry['nombre_comercial'],
    'dosis_texto' => parsed[:dosis_texto],
    'calculable' => parsed[:calculable],
    'unidad' => parsed[:unidad],
    'min_por_kg' => parsed[:min_por_kg],
    'max_por_kg' => parsed[:max_por_kg],
    'via' => entry['via'],
    'frecuencia' => entry['frecuencia'],
    'duracion' => entry['duracion'],
    'notas' => entry['notas'],
    'enfermedad_origen' => enfermedad,
    'origen' => origen,
    'concentracion_mg_ml' => concentracion
  }
end

def collect_from_diseases(raza)
  farmacos = {}
  (raza['enfermedades'] || []).each do |enf|
    (enf['protocolo_farmacologico'] || []).each do |p|
      key = drug_key(p)
      next if key.empty?

      candidate = build_farmaco(p, enf['nombre'])
      existing = farmacos[key]
      if !existing || (candidate['calculable'] && !existing['calculable'])
        farmacos[key] = candidate
      end
    end
  end
  farmacos.values
end

def species_fallback(animal_id, existing_keys)
  drugs = PharmaProtocols::DRUGS[animal_id.to_sym]
  return [] unless drugs

  drugs.values.map do |entry|
    key = drug_key(entry)
    next if existing_keys.include?(key)

    build_farmaco(entry, 'Catálogo de especie', origen: 'especie')
  end.compact
end

def build_all_dose_calculators!(data)
  total_farmacos = 0
  calculable_count = 0

  data['animales'].each do |animal|
    %w[pequena mediana grande].each do |size|
      (animal.dig('razas', size) || []).each do |raza|
        farmacos = collect_from_diseases(raza)
        existing_keys = farmacos.map { |f| drug_key(f) }
        fallback = species_fallback(animal['id'], existing_keys)
        farmacos.concat(fallback.first(5)) if farmacos.length < 5

        farmacos.sort_by! { |f| [f['calculable'] ? 0 : 1, f['principio_activo']] }
        peso = parse_peso_kg(raza['peso'])

        raza['calculadora_dosis'] = {
          'peso_tipico_kg' => peso[:tipico],
          'peso_min_kg' => peso[:min],
          'peso_max_kg' => peso[:max],
          'peso_texto' => peso[:texto],
          'farmacos' => farmacos
        }

        total_farmacos += farmacos.length
        calculable_count += farmacos.count { |f| f['calculable'] }
      end
    end
  end

  { total_farmacos: total_farmacos, calculable_count: calculable_count }
end

if __FILE__ == $PROGRAM_NAME
  data = JSON.parse(File.read(JSON_PATH))
  stats = build_all_dose_calculators!(data)
  File.write(JSON_PATH, JSON.pretty_generate(data))
  breed_count = data['animales'].sum { |a| %w[pequena mediana grande].sum { |s| (a.dig('razas', s) || []).length } }
  puts "calculadora_dosis añadida a #{breed_count} razas"
  puts "Total fármacos indexados: #{stats[:total_farmacos]} (#{stats[:calculable_count]} calculables por kg)"
end
