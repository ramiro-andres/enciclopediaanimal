# frozen_string_literal: true

# Marca enfermedades zoonóticas conocidas en enciclopedia.json con zoonotica: true/false.
# Uso: ruby scripts/data/mark_zoonotic_diseases.rb
# Regenerar JS: bash actualizar_datos.sh

require 'json'

ROOT = File.expand_path('../..', __dir__)
JSON_PATH = File.join(ROOT, 'data', 'enciclopedia.json')

# Patrones normalizados (sin acentos, minúsculas) para identificar enfermedades zoonóticas.
ZOONOTIC_PATTERNS = [
  'rabia', 'leptospir', 'toxoplasmosis', 'brucelosis', 'salmonelosis', 'campylobacter',
  'giardiasis', 'criptosporidiosis', 'leishmaniosis', 'leishmania', 'ehrlichiosis',
  'anaplasmosis', 'bartonella', 'bartonelosis', 'tularemia', 'dermatofitosis', 'tiña',
  'ringworm', 'pasteurelosis', 'psitacosis', 'ornitosis', 'clamidiosis', 'tuberculosis',
  'mycobacterium', 'coxiella', 'fiebre q', 'borreliosis', 'enfermedad de lyme',
  'toxocariasis', 'equinococosis', 'hidatidosis', 'triquinosis', 'teniasis',
  'sarcoptes scabiei', 'sarna sarcoptica', 'demodecosis', 'escabiosis',
  'grippe aviar', 'influenza', 'coronavirus', 'covid', 'hantavirus',
  'leptospira', 'yersinia', 'plague', 'peste', 'rickettsia', 'erliquiosis',
  'capnocytophaga', 'streptococcus equi', 'ringel', 'ringworm',
  'escrofula', 'linfogranuloma', 'cat scratch', 'arañazo de gato',
  'cryptococcosis', 'histoplasmosis', 'blastomicosis', 'coccidioidomicosis',
  'escabiosis zoonotica', 'sarna notoédrica', 'cheyletiella',
  'triquinelosis', 'anisakiasis', 'larva migrans',
  'fiebre del valle del rift', 'fiebre hemorragica', 'ebola', 'marburg',
  'ornitosis aviar', 'colibacilosis zoonotica', 'listeriosis',
  'carbunco', 'ántrax', 'anthrax', 'botulismo', 'clostridium',
  'escabiosis humana', 'pediculosis', 'sarna humana'
].freeze

def normalize(str)
  str.to_s.downcase
      .tr('áéíóúüñ', 'aeiouun')
      .gsub(/[^a-z0-9\s]/, ' ')
      .squeeze(' ')
      .strip
end

def zoonotic?(nombre)
  n = normalize(nombre)
  ZOONOTIC_PATTERNS.any? { |pat| n.include?(normalize(pat)) }
end

def mark_all!(data)
  marked_true = 0
  marked_false = 0

  data['animales'].each do |animal|
    %w[pequena mediana grande].each do |size|
      (animal.dig('razas', size) || []).each do |raza|
        (raza['enfermedades'] || []).each do |enf|
          is_zoo = zoonotic?(enf['nombre'])
          enf['zoonotica'] = is_zoo
          is_zoo ? marked_true += 1 : marked_false += 1
        end
      end
    end
  end

  { true_count: marked_true, false_count: marked_false }
end

if __FILE__ == $PROGRAM_NAME
  data = JSON.parse(File.read(JSON_PATH))
  stats = mark_all!(data)
  File.write(JSON_PATH, JSON.pretty_generate(data))
  puts "zoonotica marcada: #{stats[:true_count]} enfermedades zoonóticas, #{stats[:false_count]} no zoonóticas"
end
