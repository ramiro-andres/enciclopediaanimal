# frozen_string_literal: true

# US-CON-12 — Genera resumen_1min por enfermedad (modo estudio).
# Plantilla: síntomas clave + gravedad + acción recomendada.
require 'json'

ROOT = File.expand_path('../..', __dir__)
ENC_PATH = File.join(ROOT, 'data', 'enciclopedia.json')

GRAVEDAD_LABEL = {
  'leve' => 'leve',
  'moderada' => 'moderada',
  'grave' => 'grave',
  'critica' => 'crítica',
  'crítica' => 'crítica'
}.freeze

def sintomas_resumen(enf)
  lista = enf['sintomas']
  return 'variable' unless lista.is_a?(Array) && lista.any?

  lista.first(3).join(', ')
end

def accion_resumen(enf)
  return enf['urgencia'] if enf['urgencia'].to_s.strip != ''
  return enf['pronostico'] if enf['pronostico'].to_s.strip != ''
  return enf['prevencion'] if enf['prevencion'].to_s.strip != ''

  'Consultar veterinario si los signos persisten o empeoran.'
end

def build_resumen_1min(enf)
  gravedad = GRAVEDAD_LABEL[enf['gravedad'].to_s.downcase] || enf['gravedad'] || 'variable'
  sintomas = sintomas_resumen(enf)
  accion = accion_resumen(enf)
  "Síntomas clave: #{sintomas}. Gravedad: #{gravedad}. Acción: #{accion}"
end

enc = JSON.parse(File.read(ENC_PATH))
count = 0

enc['animales'].each do |animal|
  animal['razas'].each_value do |razas|
    razas.each do |raza|
      (raza['enfermedades'] || []).each do |enf|
        enf['resumen_1min'] = build_resumen_1min(enf)
        count += 1
      end
    end
  end
end

File.write(ENC_PATH, JSON.pretty_generate(enc))
puts "resumen_1min generado para #{count} enfermedades"
