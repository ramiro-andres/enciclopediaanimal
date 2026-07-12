#!/usr/bin/env ruby
# frozen_string_literal: true
# Descarga imágenes desde múltiples fuentes: Dog CEO, Pexels, Pixabay, Unsplash, Wikimedia, LoremFlickr
require 'json'
require 'net/http'
require 'uri'
require 'openssl'

ROOT = File.expand_path('..', __dir__)
IMG  = File.join(ROOT, 'images')
DATA = File.join(ROOT, 'data', 'enciclopedia.json')
UA   = 'EnciclopediaAnimal/2.0 (educational local)'

DOG_CEO = {
  'chihuahua' => 'chihuahua', 'yorkshire' => 'terrier/yorkshire', 'pomerania' => 'pomeranian',
  'maltes' => 'maltese', 'beagle' => 'beagle', 'cocker' => 'spaniel/cocker',
  'border_collie' => 'collie/border', 'bulldog_frances' => 'bulldog/french',
  'labrador' => 'labrador', 'pastor_aleman' => 'germanshepherd',
  'golden_retriever' => 'retriever/golden', 'gran_danes' => 'greatdane',
  'shih_tzu' => 'shihtzu', 'papillon' => 'papillon', 'bichon_frances' => 'bichon',
  'pinscher_miniatura' => 'pinscher/miniature', 'boxer' => 'boxer', 'shiba_inu' => 'shiba',
  'samoyedo' => 'samoyed', 'pointer_ingles' => 'pointer/german',
  'rottweiler' => 'rottweiler', 'husky_siberiano' => 'husky',
  'san_bernardo' => 'stbernard', 'doberman' => 'doberman'
}.freeze

# Fuentes curadas: Pexels, Unsplash, Pixabay, Wikimedia
CURATED = {
  'devon_rex' => ['https://images.pexels.com/photos/416160/pexels-photo-416160.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'munchkin' => ['https://images.pexels.com/photos/1170986/pexels-photo-1170986.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'abisinio' => ['https://images.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'siberiano' => ['https://images.pexels.com/photos/1317840/pexels-photo-1317840.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'exotico' => ['https://images.pexels.com/photos/2071872/pexels-photo-2071872.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'burmes' => ['https://images.pexels.com/photos/979247/pexels-photo-979247.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'bosque_noruego' => ['https://images.pexels.com/photos/1173987/pexels-photo-1173987.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'savannah' => ['https://images.pexels.com/photos/236606/pexels-photo-236606.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'singapura' => ['https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800&h=500&fit=crop&q=80'],
  'bengala' => ['https://images.unsplash.com/photo-1529774711955-4fd1c04bafb8?w=800&h=500&fit=crop&q=80'],
  'siames' => ['https://images.unsplash.com/photo-1513360371669-4adf7dd7df8f?w=800&h=500&fit=crop&q=80'],
  'persa' => ['https://images.unsplash.com/photo-1595433707802-6b2626ff1c95?w=800&h=500&fit=crop&q=80'],
  'british_shorthair' => ['https://images.unsplash.com/photo-1573865526739-10659fec78a5?w=800&h=500&fit=crop&q=80'],
  'maine_coon' => ['https://images.unsplash.com/photo-1535268647677-300fcd418329?w=800&h=500&fit=crop&q=80'],
  'ragdoll' => ['https://images.unsplash.com/photo-1574158622682-e40e69881006?w=800&h=500&fit=crop&q=80'],
  'canario' => ['https://images.pexels.com/photos/1661170/pexels-photo-1661170.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'periquito' => ['https://images.pexels.com/photos/349758/pexels-photo-349758.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'cacatua' => ['https://images.pexels.com/photos/349758/pexels-photo-349758.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'guacamayo' => ['https://images.pexels.com/photos/1661170/pexels-photo-1661170.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'diamante_mandarin' => ['https://images.pexels.com/photos/349758/pexels-photo-349758.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'ninfa' => ['https://images.pexels.com/photos/349758/pexels-photo-349758.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'agapornis' => ['https://images.pexels.com/photos/1661170/pexels-photo-1661170.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'pony_shetland' => ['https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?w=800&h=500&fit=crop&q=80'],
  'caballo_andaluz' => ['https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?w=800&h=500&fit=crop&q=80'],
  'cuarto_milla' => ['https://images.pexels.com/photos/1996333/pexels-photo-1996333.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'holstein' => ['https://images.pexels.com/photos/243558/pexels-photo-243558.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'angus' => ['https://images.pexels.com/photos/1805164/pexels-photo-1805164.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'hereford' => ['https://images.pexels.com/photos/1323256/pexels-photo-1323256.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'conejo_mini' => ['https://images.pexels.com/photos/326012/pexels-photo-326012.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'iguana' => ['https://images.pexels.com/photos/752383/pexels-photo-752383.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'tortuga' => ['https://images.pexels.com/photos/236731/pexels-photo-236731.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'goldfish' => ['https://images.pexels.com/photos/128756/pexels-photo-128756.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'betta' => ['https://images.pexels.com/photos/128756/pexels-photo-128756.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'hamster' => ['https://images.pexels.com/photos/4588065/pexels-photo-4588065.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'cobaya' => ['https://images.pexels.com/photos/4588065/pexels-photo-4588065.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'llama' => ['https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=500&fit=crop&q=80'],
  'oveja_merino' => ['https://images.pexels.com/photos/257414/pexels-photo-257414.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'cabra_nubia' => ['https://images.pexels.com/photos/1131457/pexels-photo-1131457.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'cerdo_iberico' => ['https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  # Aves adicionales
  'amazonas_frente_amarilla' => ['https://images.pexels.com/photos/1876783/pexels-photo-1876783.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'eclectus' => ['https://images.unsplash.com/photo-1552728080-077fdeb79bd5?w=800&h=500&fit=crop&q=80'],
  'cotorra_argentina' => ['https://cdn.pixabay.com/photo/2017/05/25/15/45/parrot-2345085_1280.jpg'],
  'cacatua_molucca' => ['https://images.pexels.com/photos/2134076/pexels-photo-2134076.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'loro_yaco' => ['https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Psittacus_erithacus_-Singapore_Zoo-8a.jpg/800px-Psittacus_erithacus_-Singapore_Zoo-8a.jpg'],
  'guacamayo_verde' => ['https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Ara_militaris_-Columbus_Zoo-6a.jpg/800px-Ara_militaris_-Columbus_Zoo-6a.jpg'],
  # Equinos
  'pony_connemara' => ['https://images.pexels.com/photos/1618071/pexels-photo-1618071.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'pony_welsh' => ['https://cdn.pixabay.com/photo/2016/11/29/03/53/horse-1867812_1280.jpg'],
  'arabe' => ['https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?w=800&h=500&fit=crop&q=80'],
  'hanoveriano' => ['https://images.pexels.com/photos/1996333/pexels-photo-1996333.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'mustang' => ['https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Mustang_1.jpg/800px-Mustang_1.jpg'],
  'belga' => ['https://cdn.pixabay.com/photo/2017/12/18/18/38/horse-3027042_1280.jpg'],
  'frison' => ['https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Friesian_horse.jpg/800px-Friesian_horse.jpg'],
  'pura_sangre_ingles' => ['https://images.unsplash.com/photo-1553284966-0244f2e5d3a8?w=800&h=500&fit=crop&q=80'],
  # Bovinos
  'dexter' => ['https://images.pexels.com/photos/288622/pexels-photo-288622.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'mini_hereford' => ['https://images.pexels.com/photos/96318/pexels-photo-96318.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'jersey' => ['https://images.pexels.com/photos/248038/pexels-photo-248038.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'charolais' => ['https://images.pexels.com/photos/243558/pexels-photo-243558.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'red_angus' => ['https://images.pexels.com/photos/1805164/pexels-photo-1805164.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'brahman' => ['https://images.pexels.com/photos/1323256/pexels-photo-1323256.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'limousin' => ['https://images.pexels.com/photos/1203703/pexels-photo-1203703.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'simmental' => ['https://images.pexels.com/photos/1543793/pexels-photo-1543793.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  # Porcinos
  'mini_pig' => ['https://images.pexels.com/photos/1203703/pexels-photo-1203703.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'vietnamita' => ['https://images.pexels.com/photos/1543793/pexels-photo-1543793.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'cerdo_landrace' => ['https://images.pexels.com/photos/248038/pexels-photo-248038.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'yorkshire_porcino' => ['https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'pietrain' => ['https://images.pexels.com/photos/1203703/pexels-photo-1203703.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'hampshire' => ['https://images.pexels.com/photos/1543793/pexels-photo-1543793.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'cerdo_duroc' => ['https://images.pexels.com/photos/248038/pexels-photo-248038.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'large_white' => ['https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'duroc_extra' => ['https://images.pexels.com/photos/1203703/pexels-photo-1203703.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  # Conejos
  'holandes_enano' => ['https://images.pexels.com/photos/326012/pexels-photo-326012.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'rex_mini' => ['https://cdn.pixabay.com/photo/2017/07/11/08/44/rabbit-2494424_1280.jpg'],
  'conejo_angora' => ['https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=800&h=500&fit=crop&q=80'],
  'californiano' => ['https://images.pexels.com/photos/4001296/pexels-photo-4001296.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'belier' => ['https://cdn.pixabay.com/photo/2016/11/29/08/41/rabbit-1867813_1280.jpg'],
  'angora_extra' => ['https://images.pexels.com/photos/326012/pexels-photo-326012.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'conejo_gigante' => ['https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Flemish_Giant_Rabbit.jpg/800px-Flemish_Giant_Rabbit.jpg'],
  'nueva_zelanda' => ['https://images.pexels.com/photos/4001296/pexels-photo-4001296.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'gigante_flandes_extra' => ['https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Flemish_Giant_Rabbit.jpg/800px-Flemish_Giant_Rabbit.jpg'],
  # Reptiles
  'serpiente_corn' => ['https://images.pexels.com/photos/236731/pexels-photo-236731.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'gecko_leopardo' => ['https://images.pexels.com/photos/594687/pexels-photo-594687.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'camaleon_pantera' => ['https://images.pexels.com/photos/752383/pexels-photo-752383.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'piton_bola' => ['https://images.pexels.com/photos/4588066/pexels-photo-4588066.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'dragon_barbudo' => ['https://images.pexels.com/photos/594687/pexels-photo-594687.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'tortuga_mediterranea' => ['https://images.pexels.com/photos/236731/pexels-photo-236731.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'python_reticulado' => ['https://images.pexels.com/photos/4588066/pexels-photo-4588066.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'monitor_savannah' => ['https://images.pexels.com/photos/752383/pexels-photo-752383.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'iguana_extra' => ['https://images.pexels.com/photos/752383/pexels-photo-752383.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  # Peces
  'neon_tetra' => ['https://images.pexels.com/photos/2156312/pexels-photo-2156312.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'guppy' => ['https://cdn.pixabay.com/photo/2017/02/08/15/45/guppy-1743814_1280.jpg'],
  'platy' => ['https://images.pexels.com/photos/2156312/pexels-photo-2156312.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'pez_angel' => ['https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Pterophyllum_scalare.jpg/800px-Pterophyllum_scalare.jpg'],
  'cichlidae' => ['https://images.pexels.com/photos/128756/pexels-photo-128756.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'tetra_congo' => ['https://images.pexels.com/photos/2156312/pexels-photo-2156312.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'carpa_koi' => ['https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Koi_fish.jpg/800px-Koi_fish.jpg'],
  'oscar' => ['https://cdn.pixabay.com/photo/2016/11/29/09/16/animal-1867912_1280.jpg'],
  'discus' => ['https://images.unsplash.com/photo-1522069169874-58b5277aa34e?w=800&h=500&fit=crop&q=80'],
  'arowana' => ['https://images.pexels.com/photos/128756/pexels-photo-128756.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  # Ovinos
  'ouessant' => ['https://images.pexels.com/photos/145939/pexels-photo-145939.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'suffolk' => ['https://images.pexels.com/photos/2607544/pexels-photo-2607544.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'dorper' => ['https://images.pexels.com/photos/145957/pexels-photo-145957.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'merino_extra' => ['https://images.pexels.com/photos/257414/pexels-photo-257414.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'texel' => ['https://images.pexels.com/photos/145939/pexels-photo-145939.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'romney' => ['https://images.pexels.com/photos/2607544/pexels-photo-2607544.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  # Caprinos
  'cabra_pigmea' => ['https://images.pexels.com/photos/1132046/pexels-photo-1132046.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'saanen' => ['https://images.pexels.com/photos/1131458/pexels-photo-1131458.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'alpine' => ['https://images.pexels.com/photos/1132047/pexels-photo-1132047.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'nubia_extra' => ['https://images.pexels.com/photos/1131457/pexels-photo-1131457.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'boer' => ['https://images.pexels.com/photos/1132046/pexels-photo-1132046.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'angora_cabra' => ['https://images.pexels.com/photos/1131458/pexels-photo-1131458.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  # Camelidos
  'alpaca' => ['https://images.pexels.com/photos/4009786/pexels-photo-4009786.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'llama_extra' => ['https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=500&fit=crop&q=80'],
  'vicuna' => ['https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Vicugna_vicugna.jpg/800px-Vicugna_vicugna.jpg'],
  'guanaco' => ['https://cdn.pixabay.com/photo/2016/11/29/09/16/animal-1867912_1280.jpg'],
  # Roedores
  'huron' => ['https://images.pexels.com/photos/4588065/pexels-photo-4588065.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'raton_domestico' => ['https://cdn.pixabay.com/photo/2017/02/20/18/26/mouse-2082625_1280.jpg'],
  'gerbo_mongol' => ['https://images.pexels.com/photos/4588065/pexels-photo-4588065.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'chinchilla' => ['https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Chinchilla_lanigera.jpg/800px-Chinchilla_lanigera.jpg'],
  'rata_domestica' => ['https://cdn.pixabay.com/photo/2017/02/20/18/26/mouse-2082625_1280.jpg'],
  'degu' => ['https://images.pexels.com/photos/4588065/pexels-photo-4588065.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'],
  'capibara' => ['https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Capybara_portrait.jpg/800px-Capybara_portrait.jpg']
}.freeze

# Respaldo por categoría (Pexels, Unsplash, Pixabay, Wikimedia)
ANIMAL_POOLS = {
  'aves' => [
    'https://images.pexels.com/photos/1661170/pexels-photo-1661170.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://images.pexels.com/photos/349758/pexels-photo-349758.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://cdn.pixabay.com/photo/2017/05/25/15/45/parrot-2345085_1280.jpg'
  ],
  'equinos' => [
    'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?w=800&h=500&fit=crop&q=80',
    'https://images.pexels.com/photos/1996333/pexels-photo-1996333.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://cdn.pixabay.com/photo/2016/11/29/03/53/horse-1867812_1280.jpg'
  ],
  'bovinos' => [
    'https://images.pexels.com/photos/243558/pexels-photo-243558.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://images.pexels.com/photos/1805164/pexels-photo-1805164.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://images.pexels.com/photos/1323256/pexels-photo-1323256.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'
  ],
  'porcinos' => [
    'https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://images.pexels.com/photos/1203703/pexels-photo-1203703.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://images.pexels.com/photos/1543793/pexels-photo-1543793.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'
  ],
  'conejos' => [
    'https://images.pexels.com/photos/326012/pexels-photo-326012.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=800&h=500&fit=crop&q=80',
    'https://cdn.pixabay.com/photo/2016/11/29/08/41/rabbit-1867813_1280.jpg'
  ],
  'reptiles' => [
    'https://images.pexels.com/photos/752383/pexels-photo-752383.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://images.pexels.com/photos/236731/pexels-photo-236731.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://images.pexels.com/photos/594687/pexels-photo-594687.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'
  ],
  'peces' => [
    'https://images.pexels.com/photos/128756/pexels-photo-128756.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://images.pexels.com/photos/2156312/pexels-photo-2156312.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://images.unsplash.com/photo-1522069169874-58b5277aa34e?w=800&h=500&fit=crop&q=80'
  ],
  'ovinos' => [
    'https://images.pexels.com/photos/257414/pexels-photo-257414.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://images.pexels.com/photos/145939/pexels-photo-145939.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://images.pexels.com/photos/2607544/pexels-photo-2607544.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'
  ],
  'caprinos' => [
    'https://images.pexels.com/photos/1131457/pexels-photo-1131457.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://images.pexels.com/photos/1131458/pexels-photo-1131458.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://images.pexels.com/photos/1132046/pexels-photo-1132046.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'
  ],
  'camelidos' => [
    'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=500&fit=crop&q=80',
    'https://images.pexels.com/photos/4009786/pexels-photo-4009786.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop'
  ],
  'roedores' => [
    'https://images.pexels.com/photos/4588065/pexels-photo-4588065.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://cdn.pixabay.com/photo/2017/02/20/18/26/mouse-2082625_1280.jpg'
  ],
  'gatos' => [
    'https://images.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg?auto=compress&cs=tinysrgb&w=800&h=500&fit=crop',
    'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800&h=500&fit=crop&q=80'
  ]
}.freeze

FLICKR_TAGS = {
  'perros' => 'dog',
  'gatos' => 'cat',
  'aves' => 'bird,parrot',
  'equinos' => 'horse',
  'bovinos' => 'cow,cattle',
  'porcinos' => 'pig',
  'conejos' => 'rabbit',
  'reptiles' => 'reptile,lizard',
  'peces' => 'fish,aquarium',
  'ovinos' => 'sheep',
  'caprinos' => 'goat',
  'camelidos' => 'llama,alpaca',
  'roedores' => 'hamster,rodent'
}.freeze

def http_get(url, limit: 8)
  raise 'too many redirects' if limit.zero?
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == 'https'
  http.open_timeout = 6
  http.read_timeout = 10
  req = Net::HTTP::Get.new(uri)
  req['User-Agent'] = UA
  res = http.request(req)
  case res
  when Net::HTTPRedirection then http_get(res['location'], limit: limit - 1)
  when Net::HTTPSuccess then res.body
  else nil
  end
rescue StandardError
  nil
end

def dog_ceo_url(breed_id)
  path = DOG_CEO[breed_id]
  return nil unless path
  json = http_get("https://dog.ceo/api/breed/#{path}/images/random")
  return nil unless json
  data = JSON.parse(json)
  data['message'] if data['status'] == 'success'
rescue StandardError
  nil
end

def loremflickr_url(breed_id, animal_id)
  base = FLICKR_TAGS[animal_id] || 'animal'
  tags = "#{breed_id.tr('_', '')},#{base}"
  # Obtener URL final tras redirect
  uri = URI("https://loremflickr.com/800/500/#{tags}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Get.new(uri)
  req['User-Agent'] = UA
  res = http.request(req)
  return res['location'] if res.is_a?(Net::HTTPRedirection)
  nil
rescue StandardError
  nil
end

def cat_api_url
  json = http_get('https://api.thecatapi.com/v1/images/search?limit=1&size=med')
  return nil unless json
  data = JSON.parse(json)
  data[0]['url'] if data.is_a?(Array) && data[0]
rescue StandardError
  nil
end

def sources_for(breed_id, animal_id, _nombre)
  urls = []
  urls << dog_ceo_url(breed_id) if animal_id == 'perros'
  urls.concat(CURATED[breed_id] || [])
  urls.concat(ANIMAL_POOLS[animal_id] || [])
  tag = FLICKR_TAGS[animal_id] || 'animal'
  urls << "https://loremflickr.com/800/500/#{breed_id},#{tag}"
  urls.compact.uniq
end

def download_breed(breed_id, animal_id, nombre, force: false)
  out = File.join(IMG, "#{breed_id}.jpg")
  if !force && File.exist?(out) && File.size(out) > 12_000
    return :skip
  end

  sources_for(breed_id, animal_id, nombre).each_with_index do |url, i|
    sleep 0.15 if i > 0
    body = http_get(url)
    next unless body && body.bytesize > 8000
    b = body.b
    valid = b.start_with?("\xFF\xD8\xFF".b) || b.start_with?("\x89PNG".b) || b.start_with?("RIFF".b)
    next unless valid

    File.binwrite(out, body)
    return :ok if File.size(out) > 8000
  end
  :fail
end

# --- Main ---
$stdout.sync = true
require 'thread'

data = JSON.parse(File.read(DATA))
breeds = []
data['animales'].each do |animal|
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |raza|
      breeds << [raza['id'], animal['id'], raza['nombre'], raza]
    end
  end
end

puts "Descargando imágenes para #{breeds.length} razas..."
puts "Fuentes: Dog CEO, Pexels, Unsplash, Pixabay, Wikimedia, LoremFlickr"
puts ''

ok = skip = fail = 0
pending = breeds.select do |(id, _animal, _nombre, _raza)|
  out = File.join(IMG, "#{id}.jpg")
  !File.exist?(out) || File.size(out) < 12_000
end

puts "Pendientes: #{pending.length} / #{breeds.length}"
puts ''

mutex = Mutex.new
ok = fail = 0
queue = Queue.new
pending.each { |item| queue << item }
workers = [pending.length, 10].min.times.map do
  Thread.new do
    loop do
      item = queue.pop(true)
      id, animal, nombre, raza = item
      result = download_breed(id, animal, nombre)
      mutex.synchronize do
        case result
        when :ok
          ok += 1
          puts "OK #{id}"
        when :fail
          fail += 1
          puts "FAIL #{id}"
        end
        raza['imagen'] = "images/#{id}.jpg"
      end
    rescue ThreadError
      break
    end
  end
end
workers.each(&:join)

# Actualizar rutas de las que ya tenían imagen
breeds.each do |(id, _animal, _nombre, raza)|
  next if pending.any? { |p| p[0] == id }
  raza['imagen'] = "images/#{id}.jpg"
end

File.write(DATA, JSON.pretty_generate(data))
puts ''
puts "Resultado: #{ok} descargadas, #{breeds.length - pending.length} existentes, #{fail} fallidas"
puts "JSON actualizado con rutas .jpg"
