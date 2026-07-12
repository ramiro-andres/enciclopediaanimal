#!/usr/bin/env ruby
# frozen_string_literal: true
# Descarga la 2ª imagen de Google Imágenes (filtro: grandes >800×600) sin recortar
require 'json'
require 'net/http'
require 'uri'
require 'cgi'
require 'digest'
require 'open3'
require 'fileutils'

ROOT = File.expand_path('..', __dir__)
IMG  = File.join(ROOT, 'images')
DATA = File.join(ROOT, 'data', 'enciclopedia.json')
UA   = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'

MAX_DIM = 800       # Redimensionar sin recortar (mantiene proporción)
IMAGE_INDEX = 1     # 0=primera, 1=segunda imagen de Google
# Filtro Google: imágenes grandes (mayores de 800×600)
GOOGLE_SIZE_FILTER = 'isz:lt,islt:svga'

SKIP_HOST = %w[
  gstatic.com google.com googleusercontent.com ggpht.com
  favicon icon.png /bar/ googleg_ kiddle.co ytimg.com/vi/
].freeze

GOOGLE_QUERIES = {
  'chihuahua' => 'chihuahua perro raza',
  'yorkshire' => 'yorkshire terrier perro raza',
  'pomerania' => 'pomerania perro raza',
  'maltes' => 'bichon maltes perro raza',
  'shih_tzu' => 'shih tzu perro raza',
  'papillon' => 'papillon perro raza',
  'bichon_frances' => 'bichon frise perro raza',
  'pinscher_miniatura' => 'pinscher miniatura perro raza',
  'beagle' => 'beagle perro raza',
  'cocker' => 'cocker spaniel perro raza',
  'border_collie' => 'border collie perro raza',
  'bulldog_frances' => 'bulldog frances perro raza',
  'boxer' => 'boxer perro raza',
  'shiba_inu' => 'shiba inu perro raza',
  'samoyedo' => 'samoyedo perro raza',
  'pointer_ingles' => 'pointer ingles perro raza',
  'labrador' => 'labrador retriever perro raza',
  'pastor_aleman' => 'pastor aleman perro raza',
  'golden_retriever' => 'golden retriever perro raza',
  'gran_danes' => 'gran danes perro raza',
  'rottweiler' => 'rottweiler perro raza',
  'husky_siberiano' => 'husky siberiano perro raza',
  'san_bernardo' => 'san bernardo perro raza',
  'doberman' => 'doberman perro raza',
  'singapura' => 'gato singapura raza',
  'bengala' => 'gato bengala raza',
  'devon_rex' => 'gato devon rex raza',
  'munchkin' => 'gato munchkin raza',
  'siames' => 'gato siames raza',
  'persa' => 'gato persa raza',
  'british_shorthair' => 'gato british shorthair raza',
  'abisinio' => 'gato abisinio raza',
  'siberiano' => 'gato siberiano raza',
  'exotico' => 'gato exotico pelo corto raza',
  'burmes' => 'gato burmes raza',
  'maine_coon' => 'gato maine coon raza',
  'ragdoll' => 'gato ragdoll raza',
  'bosque_noruego' => 'gato bosque de noruega raza',
  'savannah' => 'gato savannah raza',
  'canario' => 'canario ave mascota',
  'periquito' => 'periquito ave mascota',
  'diamante_mandarin' => 'diamante mandarin ave',
  'ninfa' => 'ninfa cockatiel ave',
  'agapornis' => 'agapornis ave',
  'cacatua' => 'cacatua ave',
  'amazonas_frente_amarilla' => 'amazona frente amarilla ave',
  'eclectus' => 'loro eclectus ave',
  'cotorra_argentina' => 'cotorra argentina ave',
  'guacamayo' => 'guacamayo rojo ave',
  'cacatua_molucca' => 'cacatua molucas ave',
  'loro_yaco' => 'loro yaco gris africano',
  'guacamayo_verde' => 'guacamayo verde ave',
  'pony_shetland' => 'pony shetland caballo',
  'pony_connemara' => 'pony connemara caballo',
  'pony_welsh' => 'pony gales caballo',
  'cuarto_milla' => 'caballo cuarto de milla quarter horse',
  'arabe' => 'caballo arabe raza',
  'hanoveriano' => 'caballo hanoveriano warmblood',
  'mustang' => 'caballo mustang',
  'caballo_andaluz' => 'caballo andaluz PRE',
  'belga' => 'caballo belga de tiro',
  'frison' => 'caballo frison negro',
  'pura_sangre_ingles' => 'caballo pura sangre ingles thoroughbred',
  'hereford' => 'vaca hereford raza',
  'dexter' => 'vaca dexter raza',
  'mini_hereford' => 'vaca hereford miniatura',
  'angus' => 'vaca angus negra raza',
  'jersey' => 'vaca jersey lechera',
  'charolais' => 'vaca charolais raza',
  'red_angus' => 'vaca red angus raza',
  'holstein' => 'vaca holstein frisona lechera',
  'brahman' => 'vaca brahman raza',
  'limousin' => 'vaca limousin raza',
  'simmental' => 'vaca simmental raza',
  'cerdo_iberico' => 'cerdo iberico raza',
  'mini_pig' => 'mini pig cerdo miniatura',
  'vietnamita' => 'cerdo vietnamita panza cerveza',
  'cerdo_landrace' => 'cerdo landrace raza',
  'yorkshire_porcino' => 'cerdo yorkshire large white',
  'pietrain' => 'cerdo pietrain raza',
  'hampshire' => 'cerdo hampshire raza',
  'cerdo_duroc' => 'cerdo duroc raza',
  'large_white' => 'cerdo large white raza',
  'duroc_extra' => 'cerdo duroc rojo',
  'conejo_mini' => 'conejo mini enano raza',
  'holandes_enano' => 'conejo holandes enano',
  'rex_mini' => 'conejo rex miniatura',
  'conejo_angora' => 'conejo angora raza',
  'californiano' => 'conejo californiano raza',
  'belier' => 'conejo belier lop orejas caidas',
  'angora_extra' => 'conejo angora ingles',
  'conejo_gigante' => 'conejo gigante flandes',
  'nueva_zelanda' => 'conejo nueva zelanda blanco',
  'gigante_flandes_extra' => 'conejo gigante de flandes',
  'serpiente_corn' => 'serpiente del maiz corn snake',
  'gecko_leopardo' => 'gecko leopardo mascota',
  'camaleon_pantera' => 'camaleon pantera',
  'tortuga' => 'tortuga mascota',
  'piton_bola' => 'piton bola mascota',
  'dragon_barbudo' => 'dragon barbudo pogona',
  'tortuga_mediterranea' => 'tortuga mediterranea hermann',
  'iguana' => 'iguana verde mascota',
  'python_reticulado' => 'piton reticulado',
  'monitor_savannah' => 'monitor savannah lagarto',
  'iguana_extra' => 'iguana verde grande',
  'betta' => 'pez betta luchador',
  'neon_tetra' => 'neon tetra pez acuario',
  'guppy' => 'guppy pez acuario',
  'platy' => 'platy pez acuario',
  'goldfish' => 'pez dorado goldfish',
  'pez_angel' => 'pez angel acuario',
  'cichlidae' => 'cichlido africano pez',
  'tetra_congo' => 'tetra congo pez',
  'carpa_koi' => 'carpa koi estanque',
  'oscar' => 'pez oscar cichlido',
  'discus' => 'pez discus acuario',
  'arowana' => 'arowana pez acuario',
  'ouessant' => 'oveja ouessant miniatura',
  'oveja_merino' => 'oveja merino raza',
  'suffolk' => 'oveja suffolk raza',
  'dorper' => 'oveja dorper raza',
  'merino_extra' => 'oveja merino lana',
  'texel' => 'oveja texel raza',
  'romney' => 'oveja romney raza',
  'cabra_pigmea' => 'cabra pigmea nigerian dwarf',
  'cabra_nubia' => 'cabra nubia anglo nubian',
  'saanen' => 'cabra saanen blanca',
  'alpine' => 'cabra alpina raza',
  'nubia_extra' => 'cabra nubia orejas largas',
  'boer' => 'cabra boer carne',
  'angora_cabra' => 'cabra angora mohair',
  'alpaca' => 'alpaca animal',
  'llama' => 'llama animal',
  'llama_extra' => 'llama andina',
  'vicuna' => 'vicuna animal',
  'guanaco' => 'guanaco animal',
  'hamster' => 'hamster dorado sirio',
  'cobaya' => 'cobaya cuy mascota',
  'huron' => 'hurón mascota',
  'raton_domestico' => 'raton domestico mascota fancy',
  'gerbo_mongol' => 'gerbo mongol mascota',
  'chinchilla' => 'chinchilla mascota',
  'rata_domestica' => 'rata domestica mascota fancy',
  'degu' => 'degu mascota octodon',
  'capibara' => 'capibara animal',
  # Batch 2 — perros
  'pug' => 'pug perro raza',
  'dachshund' => 'dachshund teckel perro raza',
  'boston_terrier' => 'boston terrier perro raza',
  'pekines' => 'pequines perro raza',
  'west_highland' => 'west highland white terrier perro',
  'schnauzer_miniatura' => 'schnauzer miniatura perro raza',
  'dalmatian' => 'dalmata perro raza',
  'australian_shepherd' => 'pastor australiano perro raza',
  'corgi_gales' => 'corgi gales pembroke perro',
  'weimaraner' => 'weimaraner perro raza',
  'bull_terrier' => 'bull terrier perro raza',
  'vizsla' => 'vizsla perro raza',
  'springer_spaniel' => 'springer spaniel ingles perro',
  'akita_inu' => 'akita inu perro raza',
  'bernese' => 'boyero de berna perro raza',
  'newfoundland' => 'terranova perro raza',
  'mastiff_ingles' => 'mastin ingles perro raza',
  'irish_setter' => 'setter irlandes perro raza',
  'gran_perro_montana' => 'gran perro de montaña suizo raza',
  # Batch 2 — gatos
  'sphynx' => 'gato sphynx raza',
  'cornish_rex' => 'gato cornish rex raza',
  'manx' => 'gato manx raza',
  'tonkinese' => 'gato tonkines raza',
  'scottish_fold' => 'gato scottish fold raza',
  'russian_blue' => 'gato azul ruso raza',
  'oriental' => 'gato oriental pelo corto raza',
  'bombay' => 'gato bombay negro raza',
  'american_shorthair' => 'gato american shorthair raza',
  'balinese' => 'gato balines raza',
  'birman' => 'gato birmano raza',
  'chartreux' => 'gato chartreux raza',
  'norwegian_forest' => 'norwegian forest cat long hair brown tabby',
  'turkish_van' => 'gato van turco raza',
  # Batch 2 — aves
  'kakariki' => 'kakariki ave psitacida',
  'rosella' => 'rosella perico australiano',
  'caique' => 'caique loro ave',
  'pionus' => 'pionus loro ave',
  'conure' => 'conure aratinga ave',
  'lorikeet' => 'lorikeet lori ave',
  'cacatua_umbrella' => 'umbrella cockatoo white yellow crest bird',
  # Batch 2 — equinos
  'miniatura_americana' => 'caballo miniatura americano',
  'appaloosa' => 'caballo appaloosa raza',
  'lipizzano' => 'caballo lipizzano raza',
  'criollo_argentino' => 'caballo criollo argentino',
  'percheron' => 'caballo percheron tiro',
  'clydesdale' => 'caballo clydesdale raza',
  # Batch 2 — bovinos
  'lowline_angus' => 'vaca angus lowline raza',
  'galloway' => 'vaca galloway raza',
  'shorthorn' => 'vaca shorthorn raza',
  'piedmontese' => 'vaca piemontesa raza',
  'highland' => 'vaca highland escocesa raza',
  'nelore' => 'vaca nelore cebu raza',
  # Batch 2 — porcinos
  'kunekune' => 'cerdo kunekune raza',
  'berkshire' => 'cerdo berkshire raza',
  'tamworth' => 'cerdo tamworth raza',
  'mangalica' => 'cerdo mangalica raza',
  # Batch 2 — conejos
  'lionhead' => 'conejo lionhead melena raza',
  'mini_lop' => 'conejo mini lop raza',
  'harlequin' => 'conejo harlequin raza',
  'english_spot' => 'conejo english spot raza',
  'silver_fox' => 'conejo silver fox raza',
  # Batch 2 — reptiles
  'crested_gecko' => 'gecko crestado mascota',
  'leopard_gecko_extra' => 'gecko leopardo mascota',
  'boa_constrictor' => 'boa constrictor serpiente',
  'tortuga_rusa' => 'tortuga rusa horsfieldii',
  'blue_tongue_skink' => 'lagarto lengua azul skink',
  'california_kingsnake' => 'culebra real california serpiente',
  'uromastyx' => 'uromastyx lagarto mascota',
  'tegu_argentino' => 'tegu argentino lagarto',
  # Batch 2 — peces
  'cherry_barb' => 'barbo cereza pez acuario',
  'ember_tetra' => 'tetra ember pez acuario',
  'molly' => 'molly pez acuario',
  'swordtail' => 'pez espada swordtail acuario',
  'corydoras' => 'corydoras pez gato acuario',
  'gourami_perla' => 'gourami perla pez acuario',
  'plecostomus' => 'plecostomus pez acuario',
  'flowerhorn' => 'flowerhorn pez cichlido',
  # Batch 2 — ovinos
  'babydoll_southdown' => 'oveja southdown miniatura',
  'icelandic' => 'oveja islandesa raza',
  'barbados_blackbelly' => 'oveja barbados blackbelly',
  'katahdin' => 'oveja katahdin pelo raza',
  'leicester' => 'oveja leicester raza',
  # Batch 2 — caprinos
  'nigerian_dwarf' => 'cabra nigerian dwarf raza',
  'toggenburg' => 'cabra toggenburg raza',
  'la_mancha' => 'cabra la mancha raza',
  'kiko' => 'cabra kiko raza',
  'myotonic_goat' => 'cabra fainting tennessee raza',
  # Batch 2 — camélidos
  'suri_alpaca' => 'alpaca suri animal',
  'dromedario' => 'dromedario camello animal',
  # Batch 2 — roedores
  'roborovski' => 'hamster roborovski mascota',
  'campbell_hamster' => 'hamster campbell mascota',
  'hamster_sirio' => 'syrian golden hamster pet sitting',
  'jerbo_egipcio' => 'jerbo egipcio mascota',
  'mara_patagonica' => 'mara patagonica roedor animal',
  # Batch 3 — razas de producción
  'leghorn' => 'gallina leghorn blanca raza',
  'rhode_island_red' => 'gallina rhode island red raza',
  'plymouth_rock' => 'gallina plymouth rock barrada',
  'sussex' => 'gallina sussex raza',
  'cornish_industrial' => 'gallina cornish raza carne',
  'pato_pekin' => 'pato pekin blanco raza',
  'pato_muscovy' => 'pato muscovy criollo raza',
  'pavo_blanco_pechuga_ancha' => 'pavo blanco pechuga ancha raza',
  'ayrshire' => 'vaca ayrshire lechera raza',
  'guernsey' => 'vaca guernsey lechera raza',
  'pardo_suizo' => 'vaca pardo suizo brown swiss raza',
  'normanda' => 'vaca normanda raza',
  'montbeliarde' => 'vaca montbeliarde raza',
  'azul_belga' => 'vaca azul belga raza',
  'chianina' => 'vaca chianina raza',
  'santa_gertrudis' => 'vaca santa gertrudis raza',
  'gyr_lechero' => 'vaca gyr lechero raza',
  'romosinuano' => 'ganado romosinuano raza',
  'chester_white' => 'cerdo chester white raza',
  'poland_china' => 'cerdo poland china raza',
  'meishan' => 'cerdo meishan raza',
  'gloucestershire_old_spots' => 'cerdo gloucestershire old spots',
  'british_saddleback' => 'cerdo british saddleback raza',
  'lacombe' => 'cerdo lacombe raza',
  'dorset' => 'oveja dorset raza',
  'hampshire_down' => 'oveja hampshire down raza',
  'rambouillet' => 'oveja rambouillet raza',
  'awassi' => 'oveja awassi raza',
  'frisona_oriental' => 'oveja frisona oriental east friesian',
  'lacaune' => 'oveja lacaune raza',
  'corriedale' => 'oveja corriedale raza',
  'pelibuey' => 'oveja pelibuey raza',
  'murciano_granadina' => 'cabra murciano granadina raza',
  'majorera' => 'cabra majorera raza',
  'malaguena' => 'cabra malagueña raza',
  'oberhasli' => 'cabra oberhasli raza',
  'cachemira' => 'cabra cachemira cashmere raza',
  'damasco' => 'cabra damasco damascus raza',
  'champagne_argent' => 'conejo champagne argent raza',
  'belier_frances' => 'conejo belier frances raza',
  'satin' => 'conejo satin raza',
  'chinchilla_gigante' => 'conejo chinchilla gigante raza',
  'alpaca_huacaya' => 'alpaca huacaya raza',
  'camello_bactriano' => 'camello bactriano dos jorobas',
  'suffolk_punch' => 'caballo suffolk punch raza',
  'ardenes' => 'caballo ardenes tiro raza',
  'tilapia_nilotica' => 'tilapia nilotica acuicultura estanque',
  'trucha_arcoiris' => 'trucha arcoiris piscicultura granja',
  'salmon_atlantico' => 'salmon atlantico acuicultura jaula marina',
  'carpa_comun' => 'carpa comun piscicultura acuicultura',
  'bagre_canal' => 'bagre canal catfish acuicultura',
  'pangasius' => 'pangasius basa acuicultura vietnam',
  'lubina_europea' => 'lubina europea acuicultura marina',
  'dorada_gilthead' => 'dorada gilthead seabream acuicultura',
  # Batch 4 — ponedoras, patos, gansos y peces acuícolas
  'australorp' => 'gallina australorp negra ponedora',
  'welsummer' => 'gallina welsummer ponedora raza',
  'barnevelder' => 'gallina barnevelder barrada raza',
  'ancona' => 'gallina ancona moteada ponedora',
  'lohmann_brown' => 'gallina lohmann brown ponedora comercial',
  'marans' => 'gallina marans francesa huevos chocolate',
  'orpington' => 'gallina orpington buff ponedora',
  'isa_brown' => 'gallina isa brown ponedora comercial',
  'new_hampshire' => 'gallina new hampshire roja raza',
  'minorca' => 'gallina minorca blanca ponedora',
  'khaki_campbell' => 'pato khaki campbell ponedor huevos',
  'pato_corredor' => 'pato corredor indian runner duck',
  'pato_cayuga' => 'pato cayuga negro granja',
  'pato_rouen' => 'pato rouen frances carne',
  'pavo_bronce' => 'pavo bronce bronze turkey granja',
  'ganso_embden' => 'ganso embden blanco granja',
  'bagre_africano' => 'bagre africano clarias acuicultura',
  'cachama_blanca' => 'cachama blanca piaractus acuicultura',
  'pacu' => 'pacu colossoma acuicultura amazonica',
  'rodaballo' => 'rodaballo turbot acuicultura granja',
  'salmon_coho' => 'salmon coho acuicultura jaula',
  'mojarra_roja' => 'mojarra roja tilapia acuicultura',
  'esturion_siberiano' => 'esturion siberiano acipenser caviar',
  'corvina_acuicultura' => 'corvina blanca acuicultura marina',
  # Batch 5 — aves de consumo humano
  'pollo_broiler_ross' => 'pollo broiler ross 308 engorde granja',
  'pollo_cobb500' => 'pollo cobb 500 broiler engorde',
  'pollo_red_ranger' => 'pollo red ranger campero carne',
  'brahma' => 'gallina brahma gigante granja',
  'wyandotte' => 'gallina wyandotte barrada granja',
  'gallina_criolla' => 'gallina criolla traspatio latinoamerica',
  'ameraucana' => 'gallina ameraucana huevos azules',
  'pato_mulard' => 'pato mulard moulard engorde carne',
  'pato_aylesbury' => 'pato aylesbury blanco carne',
  'ganso_toulouse' => 'ganso toulouse frances granja',
  'ganso_chino' => 'ganso chino africano granja',
  'pavo_bourbon_red' => 'pavo bourbon red granja',
  'pavo_narragansett' => 'pavo narragansett granja',
  'codorniz_japonesa' => 'codorniz japonesa huevos carne avicultura',
  'pintada' => 'pintada guinea fowl granja carne',
  'faisan_dorado' => 'faisan dorado granja carne',
  # Lote Colombia — razas y especies productivas
  'blanco_orejinegro' => 'vaca blanco orejinegro BON Colombia ganado criollo',
  'harton_del_valle' => 'vaca harton del valle Colombia ganado criollo',
  'sanmartinero' => 'vaca sanmartinero Colombia llanos ganado',
  'costeno_con_cuernos' => 'vaca costeño con cuernos Colombia ganado criollo',
  'chino_santandereano' => 'vaca chino santandereano Colombia ganado',
  'casanareno' => 'vaca casanareño Colombia llanos ganado criollo',
  'criollo_caqueteno' => 'vaca criollo caqueteño Colombia ganado',
  'lucerna_colombiana' => 'vaca lucerna colombiana ganado doble proposito',
  'velasquez_colombiano' => 'vaca velasquez colombiana ganado carne',
  'cerdo_zungo' => 'cerdo zungo criollo Colombia porcino',
  'cerdo_casco_de_mula' => 'cerdo casco de mula Colombia criollo',
  'ovino_criollo_colombiano' => 'oveja criollo colombiano ganado ovino',
  'camuro_colombiano' => 'oveja camuro Colombia ovino carne',
  'caprino_criollo_colombiano' => 'cabra criollo colombiano caprino',
  'cabra_santandereana' => 'cabra santandereana Colombia leche',
  'bocachico' => 'bocachico Prochilodus magdalenae pez Colombia',
  'yamu' => 'yamu Brycon amazonicus pez Colombia acuicultura',
  'cachama_negra' => 'cachama negra Colossoma macropomum Colombia piscicultura',
  'capaz' => 'capaz Pimelodus grosskopfii pez Colombia',
  'bagre_rayado' => 'bagre rayado Pseudoplatystoma magdaleniatum Colombia',
  'gallina_criolla_colombiana' => 'gallina criolla colombiana traspatio',
  'pato_criollo_colombiano' => 'pato criollo colombiano granja'
}.freeze

def http_get(url, limit: 6)
  raise 'too many redirects' if limit.zero?
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == 'https'
  http.open_timeout = 12
  http.read_timeout = 25
  req = Net::HTTP::Get.new(uri)
  req['User-Agent'] = UA
  req['Referer'] = 'https://www.google.com/'
  res = http.request(req)
  case res
  when Net::HTTPRedirection then http_get(res['location'], limit: limit - 1)
  when Net::HTTPSuccess then res.body
  else nil
  end
rescue StandardError
  nil
end

def valid_image?(body)
  return false unless body && body.bytesize > 12_000
  b = body.b
  b.start_with?("\xFF\xD8\xFF".b) || b.start_with?("\x89PNG".b) || b.start_with?("RIFF".b)
end

def google_html(query)
  q = CGI.escape(query)
  url = "https://www.google.com/search?q=#{q}&udm=2&hl=es&tbs=#{GOOGLE_SIZE_FILTER}"
  script = <<~APPLESCRIPT
    tell application "Safari"
      if (count of windows) = 0 then make new document
      set URL of current tab of front window to "#{url}"
      delay 6
      return source of document 1
    end tell
  APPLESCRIPT
  out, _, status = Open3.capture3('osascript', stdin_data: script)
  return nil unless status.success? && out && out.bytesize > 50_000
  out
end

def extract_google_image_urls(html)
  urls = html.scan(/"(https?:\/\/[^"]+\.(?:jpg|jpeg|png|webp)(?:\?[^"]*)?)"/i).flatten
  urls.map { |u| u.gsub('\\u003d', '=').gsub('\\u0026', '&').gsub('\\/', '/') }
      .reject { |u| SKIP_HOST.any? { |s| u.include?(s) } }
      .reject { |u| u.match?(/\/\d{2,3}px-/) }
      .uniq
end

def normalize_image(raw_path, out_path)
  ok = system('sips', '-s', 'format', 'jpeg', '-Z', MAX_DIM.to_s, raw_path, '--out', out_path,
              out: File::NULL, err: File::NULL)
  ok && File.exist?(out_path) && File.size(out_path) > 8000
end

def download_google_image(breed_id, query, index: IMAGE_INDEX)
  html = google_html(query)
  return :no_html unless html

  urls = extract_google_image_urls(html)
  found = 0
  urls.each do |img_url|
    body = http_get(img_url)
    next unless valid_image?(body)

    if found == index
      raw = File.join(IMG, "#{breed_id}_raw.jpg")
      out = File.join(IMG, "#{breed_id}.jpg")
      File.binwrite(raw, body)
      if normalize_image(raw, out)
        File.delete(raw)
        return :ok
      end
      File.delete(raw) if File.exist?(raw)
      return :bad_normalize
    end
    found += 1
  end

  # Si no hay suficientes, usar la primera disponible
  return :no_image if index.positive?

  :no_image
end

def query_for(raza, animal)
  GOOGLE_QUERIES[raza['id']] || "#{raza['nombre']} #{animal['nombre']} raza"
end

# --- Main ---
$stdout.sync = true
ONLY_MISSING = ARGV.include?('--only-missing')

data = JSON.parse(File.read(DATA))
breeds = []
data['animales'].each do |animal|
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |raza|
      next if ONLY_MISSING && File.exist?(File.join(IMG, "#{raza['id']}.jpg"))
      breeds << [raza, animal]
    end
  end
end

if ONLY_MISSING
  puts "Modo --only-missing: descargando solo razas sin imagen JPG (#{breeds.length} pendientes)"
else
  puts "Descargando 2ª imagen de Google (#{breeds.length} razas, filtro grandes, sin recorte)..."
end
puts '' unless breeds.empty?

ok = fail = 0
breeds.each_with_index do |(raza, animal), idx|
  id = raza['id']
  query = query_for(raza, animal)
  result = download_google_image(id, query)
  if result != :ok && result == :no_image
    result = download_google_image(id, query, index: 0)
  end
  if result == :ok
    ok += 1
    puts "[#{idx + 1}/#{breeds.length}] OK #{id}"
  else
    fail += 1
    puts "[#{idx + 1}/#{breeds.length}] FAIL #{id} (#{result})"
  end
  raza['imagen'] = "images/#{id}.jpg"
end

File.write(DATA, JSON.pretty_generate(data))

puts ''
puts "Resultado: #{ok} OK, #{fail} fallidas (redimensionadas max #{MAX_DIM}px, sin recorte)"
