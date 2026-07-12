#!/bin/bash
# Resuelve URLs via API de Wikimedia y descarga imágenes
UA="EnciclopediaAnimal/1.0 (local educational project)"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DIR="$ROOT/images"
API="https://commons.wikimedia.org/w/api.php"
PAUSE=8

get_url() {
  local file="$1"
  curl -fsSL -A "$UA" \
    "${API}?action=query&titles=File:${file}&prop=imageinfo&iiprop=url&format=json" \
    | ruby -rjson -e '
      d=JSON.parse(STDIN.read)
      pages=d["query"]["pages"].values.first
      puts pages.dig("imageinfo",0,"url") || ""
    ' 2>/dev/null
}

download_breed() {
  local name="$1" file="$2"
  local out="${DIR}/${name}.jpg"
  if [ -f "$out" ] && [ "$(wc -c < "$out")" -gt 8000 ]; then
    echo "SKIP $name"; return 0
  fi
  sleep "$PAUSE"
  local url
  url=$(get_url "$file")
  if [ -z "$url" ]; then
    echo "NOURL $name ($file)"
    return 1
  fi
  if curl -fsSL -A "$UA" --retry 2 --retry-delay 10 -o "$out" "$url"; then
    echo "OK $name"
  else
    echo "FAIL $name"
    return 1
  fi
}

download_breed chihuahua "Chihuahua1_bvdb.jpg"
download_breed yorkshire "YorkshireTerrier.jpg"
download_breed pomerania "Pomeranian.JPG"
download_breed maltes "Maltese_600.jpg"
download_breed beagle "Beagle_600.jpg"
download_breed cocker "English_Cocker_Spaniel.jpg"
download_breed border_collie "Border_Collie_600.jpg"
download_breed bulldog_frances "Bulldog_frances.jpg"
download_breed labrador "YellowLabradorLooking_new.jpg"
download_breed pastor_aleman "German_Shepherd_Dog_600.jpg"
download_breed golden_retriever "Golden_Retriever_600.jpg"
download_breed gran_danes "Great_Dane_600.jpg"
download_breed siames "Traditional_siamese_(cat).jpg"
download_breed persa "Persian_Cat_600.jpg"
download_breed british_shorthair "British_shorthair_silver_tabby.jpg"
download_breed maine_coon "Mainecoon_cat.jpg"
download_breed ragdoll "Ragdoll_from_Gatil_Ragbelas.jpg"
download_breed bengala "Bengalcat-lil-spotted.jpg"
download_breed singapura "Singapura_Cat.jpg"
download_breed canario "Serinus_canaria_-England-8.jpg"
download_breed periquito "Melopsittacus_undulatus_-pet-8a.jpg"
download_breed cacatua "Cacatua_galerita_-perching_on_branch-8a.jpg"
download_breed guacamayo "Ara_ararauna_Luc_Viatour.jpg"
download_breed pony_shetland "Shetland_Pony_in_Shetland.jpg"
download_breed cuarto_milla "American_Quarter_Horse.jpg"
download_breed caballo_andaluz "Andalusian_horse.jpg"
download_breed holstein "Holstein_Friesian_cow.jpg"
download_breed angus "Angus_cattle.jpg"
download_breed hereford "Hereford_bull.jpg"
download_breed cerdo_iberico "Iberian_pigs.jpg"
download_breed cerdo_landrace "Landrace_pig.jpg"
download_breed cerdo_duroc "Duroc_pig.jpg"
download_breed conejo_mini "Dwarf_rabbit.jpg"
download_breed conejo_angora "Angora_rabbit.jpg"
download_breed conejo_gigante "Flemish_Giant_rabbit.jpg"
download_breed iguana "Iguana_iguana_Portoviejo_Ecuador.jpg"
download_breed tortuga "Testudo_graeca_iberia.jpg"
download_breed serpiente_corn "Pantherophis_guttatus.jpg"
download_breed goldfish "Carassius_auratus.jpg"
download_breed betta "Betta_splendens_male.jpg"
download_breed carpa_koi "Koi_fish.jpg"
download_breed oveja_merino "Merino_sheep.jpg"
download_breed cabra_nubia "Nubian_goat.jpg"
download_breed llama "Llama_lying_down.jpg"
download_breed hamster "Syrian_hamster.jpg"
download_breed cobaya "Guinea_pig_-_Melbourne_Zoo.jpg"
download_breed huron "Ferret_2008.png"

echo "Total: $(ls -1 "${DIR}"/*.jpg 2>/dev/null | wc -l | tr -d ' ') imágenes"
