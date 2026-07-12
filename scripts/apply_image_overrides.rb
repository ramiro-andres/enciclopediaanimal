#!/usr/bin/env ruby
# frozen_string_literal: true
require 'json'
require 'net/http'
require 'uri'

ROOT = File.expand_path('..', __dir__)
IMG = File.join(ROOT, 'images')
UA = 'EnciclopediaAnimal/1.0 (educational local)'

# URLs verificadas de Wikipedia/Wikimedia (foto principal del artículo)
OVERRIDES = {
  'guacamayo' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Scarlet_macaw_%28Ara_macao_cyanopterus%29_Copan.jpg/800px-Scarlet_macaw_%28Ara_macao_cyanopterus%29_Copan.jpg',
  'belga' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Belgisch_trekpaard1.JPG/800px-Belgisch_trekpaard1.JPG',
  'red_angus' => 'https://upload.wikimedia.org/wikipedia/commons/b/b3/2009-red-angus.jpg',
  'mini_pig' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Haengebauchschwein_Sus_scrofa_f._domestica_Wildpark_Poing-01.jpg/800px-Haengebauchschwein_Sus_scrofa_f._domestica_Wildpark_Poing-01.jpg',
  'cerdo_landrace' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Landrace_pig_%28Belagro-2021%29.jpg/800px-Landrace_pig_%28Belagro-2021%29.jpg',
  'rex_mini' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Fast_Track%2C_Lilac_Mini_Rex.jpg/800px-Fast_Track%2C_Lilac_Mini_Rex.jpg',
  'oveja_merino' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/251017_Rokkosan_Pasture_Kobe_Japan07s3.jpg/800px-251017_Rokkosan_Pasture_Kobe_Japan07s3.jpg',
  'merino_extra' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Merino_sheep_grazing_at_Wagga_Wagga.jpg/800px-Merino_sheep_grazing_at_Wagga_Wagga.jpg',
  'alpaca' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Alpaca_in_Higashiyama_Zoo_-_1.jpg/800px-Alpaca_in_Higashiyama_Zoo_-_1.jpg',
  'guanaco' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/32/Guanaco_%28Lama_guanicoe%29_Leona_Amarga.jpg/800px-Guanaco_%28Lama_guanicoe%29_Leona_Amarga.jpg',
  'rata_domestica' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Lyonblackandwhitehoodedrat.jpg/800px-Lyonblackandwhitehoodedrat.jpg',
  'degu' => 'https://upload.wikimedia.org/wikipedia/commons/4/47/Octodon_degus_-Heidelberg_Zoo%2C_Germany-8a.jpg',
  'capibara' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/Capybaracropped.jpg/800px-Capybaracropped.jpg',
  'large_white' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Large_White_pig.jpg/800px-Large_White_pig.jpg',
  'duroc_extra' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/Duroc_pig_%28Belagro-2021%29_2.jpg/800px-Duroc_pig_%28Belagro-2021%29_2.jpg',
  'holandes_enano' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Netherland_Dwarf_Rabbit.jpg/800px-Netherland_Dwarf_Rabbit.jpg',
  'angora_extra' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/Angora_Rabbit_01.jpg/800px-Angora_Rabbit_01.jpg',
  'gigante_flandes_extra' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Flemish_giant_rabbit.JPG/800px-Flemish_giant_rabbit.JPG',
  'llama_extra' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Llama_lying_down.jpg/800px-Llama_lying_down.jpg',
  'nubia_extra' => 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Nubian_goat_in_England.jpg/800px-Nubian_goat_in_England.jpg'
}.freeze

def http_get(url)
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.open_timeout = 12
  http.read_timeout = 30
  req = Net::HTTP::Get.new(uri)
  req['User-Agent'] = UA
  res = http.request(req)
  res.is_a?(Net::HTTPSuccess) ? res.body : nil
end

OVERRIDES.each do |id, url|
  body = http_get(url)
  if body && body.bytesize > 8000 && body.b.start_with?("\xFF\xD8\xFF".b, "\x89PNG".b)
    File.binwrite(File.join(IMG, "#{id}.jpg"), body)
    puts "OK #{id} (#{body.bytesize})"
  else
    puts "FAIL #{id}"
  end
  sleep 0.5
end
