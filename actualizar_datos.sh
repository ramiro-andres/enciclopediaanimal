#!/bin/bash
# Regenera data/enciclopedia.js y data/diccionario_medicos.js desde JSON
DIR="$(cd "$(dirname "$0")" && pwd)"
ruby "$DIR/scripts/build_medical_dictionary.rb"
ruby -rjson -e '
  base = ARGV[0]
  d = JSON.parse(File.read(base + "/data/enciclopedia.json"))
  File.write(base + "/data/enciclopedia.js", "window.ENCICLOPEDIA_DATA = " + d.to_json + ";\n")
  puts "enciclopedia.js actualizado (#{d["animales"].length} animales)"

  dict_path = base + "/data/diccionario_medicos.json"
  if File.exist?(dict_path)
    dict = JSON.parse(File.read(dict_path))
    File.write(base + "/data/diccionario_medicos.js", "window.DICCIONARIO_MEDICOS = " + dict.to_json + ";\n")
    terms = dict["categorias"].sum { |c| c["terminos"].length }
    puts "diccionario_medicos.js actualizado (#{terms} términos)"
  end
' "$DIR"
