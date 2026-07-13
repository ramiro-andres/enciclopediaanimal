#!/bin/bash
# Regenera los .js derivados (enciclopedia, diccionario y enlaces clínicos) desde JSON
DIR="$(cd "$(dirname "$0")" && pwd)"
ruby "$DIR/scripts/data/build_medical_dictionary.rb"
ruby "$DIR/scripts/data/build_search_index.rb"
ruby "$DIR/scripts/data/build_cross_links.rb"
ruby "$DIR/scripts/data/suggest_glossary_links.rb"
ruby "$DIR/scripts/data/integrate_suggested_links_sprint13.rb"
ruby "$DIR/scripts/data/build_toxicologia.rb"
ruby "$DIR/scripts/data/build_emergencias_latam.rb"
ruby "$DIR/scripts/data/build_triaje.rb"
ruby "$DIR/scripts/data/expand_bibliografia_sprint10.rb"
ruby "$DIR/scripts/data/build_resumen_estudio_sprint10.rb"
ruby "$DIR/scripts/data/build_chunks.rb"
ruby "$DIR/scripts/data/build_lab_reference.rb"
ruby "$DIR/scripts/data/build_changelog.rb"
ruby "$DIR/scripts/data/build_sitemap.rb"
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

  links_path = base + "/data/enlaces_clinicos.json"
  if File.exist?(links_path)
    links = JSON.parse(File.read(links_path))
    File.write(base + "/data/enlaces_clinicos.js", "window.ENLACES_CLINICOS = " + links.to_json + ";\n")
    puts "enlaces_clinicos.js actualizado (#{links["total_terminos_enlazados"]} términos enlazados)"
  end

  cal_path = base + "/data/calendario_vacunacion.json"
  if File.exist?(cal_path)
    cal = JSON.parse(File.read(cal_path))
    File.write(base + "/data/calendario_vacunacion.js", "window.CALENDARIO_VACUNACION = " + cal.to_json + ";\n")
    puts "calendario_vacunacion.js actualizado (#{cal["especies"].length} especies)"
  end

  changelog_path = base + "/data/changelog.json"
  if File.exist?(changelog_path)
    changelog = JSON.parse(File.read(changelog_path))
    File.write(base + "/data/changelog.js", "window.ATLAS_CHANGELOG = " + changelog.to_json + ";\n")
    puts "changelog.js actualizado (#{changelog["entries"].length} entradas)"
  end
' "$DIR"
