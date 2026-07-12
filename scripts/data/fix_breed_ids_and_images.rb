# frozen_string_literal: true
require 'json'

ROOT = File.expand_path('../..', __dir__)
INPUT = File.join(ROOT, 'data', 'enciclopedia.json')

data = JSON.parse(File.read(INPUT))
bovinos = data['animales'].find { |a| a['id'] == 'bovinos' }
breed = (bovinos.dig('razas', 'mediana') || []).find { |b| b['id'] == 'criollo_argentino' }
if breed
  breed['id'] = 'bovino_criollo_argentino'
  breed['imagen'] = 'images/bovino_criollo_argentino.svg'
  breed['region'] = 'Argentina'
  puts 'Renombrado bovino criollo_argentino → bovino_criollo_argentino'
end

GENERIC_DIAGNOSIS = /El veterinario realizará anamnesis detallada/i

data['animales'].each do |animal|
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |b|
      (b['enfermedades'] || []).each do |d|
        next if d['imagen']

        slug = d['nombre'].to_s.downcase.unicode_normalize(:nfd).gsub(/[\u0300-\u036f]/, '').gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
        d['imagen'] = "images/enfermedades/#{animal['id']}_#{slug}.jpg"
      end
      (b['enfermedades'] || []).each do |d|
        next unless d['diagnostico'].to_s.match?(GENERIC_DIAGNOSIS)

        d['diagnostico'] = d['diagnostico']
          .gsub(/El veterinario realizará anamnesis detallada[^.]*\.\s*/i, '')
          .gsub(/\s+/, ' ')
          .strip
      end
    end
  end
end

File.write(INPUT, JSON.pretty_generate(data))
puts 'Imágenes de enfermedad asignadas donde faltaban'
