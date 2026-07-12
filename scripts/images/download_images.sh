#!/bin/bash
# Descarga imágenes con pausa anti rate-limit (Wikimedia Commons)
UA="EnciclopediaAnimal/1.0 (local educational; ramirokun)"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DIR="$ROOT/images"
cd "$DIR"
PAUSE=3

dl() {
  local name="$1" url="$2"
  if [ -f "${name}.jpg" ] && [ "$(wc -c < "${name}.jpg" 2>/dev/null || echo 0)" -gt 5000 ]; then
    echo "SKIP $name"
    return 0
  fi
  sleep "$PAUSE"
  if curl -fsSL -A "$UA" --retry 2 --retry-delay 5 -o "${name}.jpg" "$url"; then
    echo "OK $name ($(wc -c < "${name}.jpg") bytes)"
  else
    echo "FAIL $name"
    return 1
  fi
}

dl yorkshire       "https://upload.wikimedia.org/wikipedia/commons/1/14/Yorkshire_Terrier_Photo.jpg"
dl maltes          "https://upload.wikimedia.org/wikipedia/commons/2/2f/Maltese_600.jpg"
dl cocker          "https://upload.wikimedia.org/wikipedia/commons/4/4b/English_Cocker_Spaniel_600.jpg"
dl border_collie   "https://upload.wikimedia.org/wikipedia/commons/0/00/Border_Collie_600.jpg"
dl bulldog_frances "https://upload.wikimedia.org/wikipedia/commons/6/6f/Bulldog_frances.jpg"
dl pastor_aleman   "https://upload.wikimedia.org/wikipedia/commons/d/d0/German_Shepherd_-_DSC_0346_%2810096362833%29.jpg"
dl golden_retriever "https://upload.wikimedia.org/wikipedia/commons/b/bd/Golden_Retriever_600.jpg"
dl gran_danes      "https://upload.wikimedia.org/wikipedia/commons/e/e8/Great_Dane_600.jpg"
dl siames          "https://upload.wikimedia.org/wikipedia/commons/4/4a/Traditional_siamese_%28cat%29.jpg"
dl persa           "https://upload.wikimedia.org/wikipedia/commons/1/15/Persian_Cat_600.jpg"
dl british_shorthair "https://upload.wikimedia.org/wikipedia/commons/9/9d/British_shorthair_silver_tabby.jpg"
dl maine_coon      "https://upload.wikimedia.org/wikipedia/commons/4/4e/Mainecoon_cat.jpg"
dl ragdoll         "https://upload.wikimedia.org/wikipedia/commons/6/63/Ragdoll_from_Gatil_Ragbelas.jpg"
dl bengala         "https://upload.wikimedia.org/wikipedia/commons/b/ba/Bengalcat-lil-spotted.jpg"
dl singapura       "https://upload.wikimedia.org/wikipedia/commons/8/8e/Singapura_Cat.jpg"
dl canario         "https://upload.wikimedia.org/wikipedia/commons/5/57/Serinus_canaria_-England-8.jpg"
dl periquito       "https://upload.wikimedia.org/wikipedia/commons/7/7e/Melopsittacus_undulatus_-pet-8a.jpg"
dl cacatua         "https://upload.wikimedia.org/wikipedia/commons/2/2f/Cacatua_galerita_-perching_on_branch-8a.jpg"
dl guacamayo       "https://upload.wikimedia.org/wikipedia/commons/5/5a/Ara_ararauna_Luc_Viatour.jpg"
dl pony_shetland   "https://upload.wikimedia.org/wikipedia/commons/4/48/Shetland_Pony_in_Shetland.jpg"
dl cuarto_milla    "https://upload.wikimedia.org/wikipedia/commons/8/8d/American_Quarter_Horse.jpg"
dl caballo_andaluz "https://upload.wikimedia.org/wikipedia/commons/1/1e/Andalusian_horse.jpg"
dl holstein        "https://upload.wikimedia.org/wikipedia/commons/0/0c/Holstein_Friesian_cow.jpg"
dl angus           "https://upload.wikimedia.org/wikipedia/commons/3/3a/Angus_cattle.jpg"
dl hereford        "https://upload.wikimedia.org/wikipedia/commons/4/4c/Hereford_bull.jpg"
dl cerdo_iberico   "https://upload.wikimedia.org/wikipedia/commons/4/44/Iberian_pigs.jpg"
dl cerdo_landrace  "https://upload.wikimedia.org/wikipedia/commons/8/8a/Landrace_pig.jpg"
dl cerdo_duroc     "https://upload.wikimedia.org/wikipedia/commons/9/9e/Duroc_pig.jpg"
dl conejo_mini     "https://upload.wikimedia.org/wikipedia/commons/1/1f/Dwarf_rabbit.jpg"
dl conejo_angora   "https://upload.wikimedia.org/wikipedia/commons/6/6e/Angora_rabbit.jpg"
dl conejo_gigante  "https://upload.wikimedia.org/wikipedia/commons/3/37/Flemish_Giant_rabbit.jpg"
dl iguana          "https://upload.wikimedia.org/wikipedia/commons/8/8f/Iguana_iguana_Portoviejo_Ecuador.jpg"
dl tortuga         "https://upload.wikimedia.org/wikipedia/commons/0/00/Testudo_graeca_iberia.jpg"
dl serpiente_corn  "https://upload.wikimedia.org/wikipedia/commons/c/c6/Pantherophis_guttatus.jpg"
dl goldfish        "https://upload.wikimedia.org/wikipedia/commons/a/ae/Carassius_auratus.jpg"
dl betta           "https://upload.wikimedia.org/wikipedia/commons/1/12/Betta_splendens_male.jpg"
dl carpa_koi       "https://upload.wikimedia.org/wikipedia/commons/4/4a/Koi_fish.jpg"
dl oveja_merino    "https://upload.wikimedia.org/wikipedia/commons/3/3e/Merino_sheep.jpg"
dl cabra_nubia     "https://upload.wikimedia.org/wikipedia/commons/5/5d/Nubian_goat.jpg"
dl llama           "https://upload.wikimedia.org/wikipedia/commons/9/9e/Llama_lying_down.jpg"
dl hamster         "https://upload.wikimedia.org/wikipedia/commons/9/96/Syrian_hamster.jpg"
dl cobaya          "https://upload.wikimedia.org/wikipedia/commons/3/3d/Guinea_pig_-_Melbourne_Zoo.jpg"
dl huron           "https://upload.wikimedia.org/wikipedia/commons/5/5f/Ferret_2008.png"

echo "---"
echo "Descargados: $(ls -1 *.jpg 2>/dev/null | wc -l | tr -d ' ') imágenes"
