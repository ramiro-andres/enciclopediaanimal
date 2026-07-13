#!/bin/bash
# Regenera los .js derivados (enciclopedia, diccionario y enlaces clínicos) desde JSON.
# SOLO_JS=1 omite la regeneración de JSON (CI: validar sincronización sin reintegrar enlaces).
DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "${SOLO_JS:-}" != "1" ]; then
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
fi

ruby -rjson -e '
  def deep_sort(obj)
    case obj
    when Hash
      obj.sort.to_h.transform_values { |v| deep_sort(v) }
    when Array
      obj.map { |v| deep_sort(v) }
    else
      obj
    end
  end

  def write_js_window(path, global, data)
    payload = deep_sort(data).to_json
    File.write(path, "window.#{global} = #{payload};\n")
  end

  base = ARGV[0]
  d = JSON.parse(File.read(base + "/data/enciclopedia.json"))
  write_js_window(base + "/data/enciclopedia.js", "ENCICLOPEDIA_DATA", d)
  puts "enciclopedia.js actualizado (#{d["animales"].length} animales)"

  dict_path = base + "/data/diccionario_medicos.json"
  if File.exist?(dict_path)
    dict = JSON.parse(File.read(dict_path))
    write_js_window(base + "/data/diccionario_medicos.js", "DICCIONARIO_MEDICOS", dict)
    terms = dict["categorias"].sum { |c| c["terminos"].length }
    puts "diccionario_medicos.js actualizado (#{terms} términos)"
  end

  links_path = base + "/data/enlaces_clinicos.json"
  if File.exist?(links_path)
    links = JSON.parse(File.read(links_path))
    write_js_window(base + "/data/enlaces_clinicos.js", "ENLACES_CLINICOS", links)
    puts "enlaces_clinicos.js actualizado (#{links["total_terminos_enlazados"]} términos enlazados)"
  end

  cal_path = base + "/data/calendario_vacunacion.json"
  if File.exist?(cal_path)
    cal = JSON.parse(File.read(cal_path))
    write_js_window(base + "/data/calendario_vacunacion.js", "CALENDARIO_VACUNACION", cal)
    puts "calendario_vacunacion.js actualizado (#{cal["especies"].length} especies)"
  end

  changelog_path = base + "/data/changelog.json"
  if File.exist?(changelog_path)
    changelog = JSON.parse(File.read(changelog_path))
    write_js_window(base + "/data/changelog.js", "ATLAS_CHANGELOG", changelog)
    puts "changelog.js actualizado (#{changelog["entries"].length} entradas)"
  end
' "$DIR"
