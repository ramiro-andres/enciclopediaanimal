#!/bin/bash
# Genera placeholders SVG para razas sin imagen descargada
DIR="$(cd "$(dirname "$0")" && pwd)"
IMG="$DIR/images"
DATA="$DIR/data/enciclopedia.json"

ruby -rjson -e '
  data = JSON.parse(File.read(ARGV[0]))
  icons = {
    "perros"=>"🐕","gatos"=>"🐈","aves"=>"🦜","equinos"=>"🐴",
    "bovinos"=>"🐄","porcinos"=>"🐷","conejos"=>"🐇","reptiles"=>"🦎",
    "peces"=>"🐟","ovinos"=>"🐑","caprinos"=>"🐐","camelidos"=>"🦙","roedores"=>"🐹"
  }
  colors = {"pequena"=>"#d8f3dc","mediana"=>"#b7e4c7","grande"=>"#a8dadc"}
  data["animales"].each do |animal|
    ["pequena","mediana","grande"].each do |size|
      (animal["razas"][size] || []).each do |raza|
        jpg = File.join(ARGV[1], raza["id"] + ".jpg")
        next if File.exist?(jpg) && File.size(jpg) > 8000
        icon = icons[animal["id"]] || "🐾"
        bg = colors[size] || "#eef4ea"
        nombre = raza["nombre"].gsub("&","&amp;").gsub("<","&lt;")
        svg = %Q{<svg xmlns="http://www.w3.org/2000/svg" width="440" height="280" viewBox="0 0 440 280">
  <rect width="440" height="280" fill="#{bg}"/>
  <text x="220" y="110" text-anchor="middle" font-size="56">#{icon}</text>
  <text x="220" y="160" text-anchor="middle" font-family="Arial,sans-serif" font-size="18" font-weight="bold" fill="#1b4332">#{nombre}</text>
  <text x="220" y="185" text-anchor="middle" font-family="Arial,sans-serif" font-size="13" fill="#5c6370">#{animal["nombre"]} · #{size.capitalize}</text>
</svg>}
        File.write(jpg.sub(/\.jpg$/,".svg"), svg)
        puts "SVG #{raza["id"]}"
      end
    end
  end
' "$DATA" "$IMG"
