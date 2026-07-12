# frozen_string_literal: true

# Razas seleccionadas por su importancia en producción de leche, carne,
# huevos, lana/fibra, piel o trabajo rural.
PRODUCTION_BREEDS = [
  # Aves de postura, carne y doble propósito
  ['aves', 'mediana', 'leghorn', 'Leghorn', 'Italia', '1,8-2,7 kg', '5-8 años', 'Activa, precoz y eficiente', 'Gallina mediterránea especializada en postura de huevo blanco', 'Galpón ventilado, nidos limpios y 14-16 h de luz', 'Ración de ponedora con 16-18% proteína y 3,5-4% calcio'],
  ['aves', 'mediana', 'rhode_island_red', 'Rhode Island Red', 'EE.UU.', '2,5-3,9 kg', '6-8 años', 'Rústica, dócil y adaptable', 'Gallina de doble propósito para huevo marrón y carne', 'Pastoreo o galpón con control de depredadores', 'Ración de postura más forraje e insoluble grit'],
  ['aves', 'mediana', 'plymouth_rock', 'Plymouth Rock', 'EE.UU.', '2,9-4,3 kg', '6-8 años', 'Dócil, maternal y resistente', 'Gallina barrada de doble propósito y crecimiento moderado', 'Nidos secos, cama profunda y control de condición corporal', 'Ración balanceada por fase productiva'],
  ['aves', 'mediana', 'sussex', 'Sussex', 'Inglaterra', '3-4,1 kg', '6-8 años', 'Tranquila, forrajera y productiva', 'Gallina británica de doble propósito, buena ponedora invernal', 'Acceso a pastoreo y refugio seco', 'Ración de ponedora y forraje de calidad'],
  ['aves', 'grande', 'cornish_industrial', 'Cornish', 'Inglaterra', '3,5-5 kg', '5-7 años', 'Musculosa, tranquila y precoz', 'Base genética de líneas de pollo de engorde por su pechuga desarrollada', 'Control de crecimiento, cama seca y ventilación estricta', 'Ración de engorde por fases, sin sobrealimentación reproductora'],
  ['aves', 'grande', 'pato_pekin', 'Pato Pekín', 'China', '3,5-4,5 kg', '8-10 años', 'Rústico, gregario y precoz', 'Pato blanco especializado en carne, de rápido crecimiento', 'Agua para limpiar pico, cama seca y buen drenaje', 'Ración para patos de carne con niacina adecuada'],
  ['aves', 'grande', 'pato_muscovy', 'Pato Muscovy', 'América tropical', '3-6 kg', '8-12 años', 'Silencioso, forrajero y maternal', 'Pato criollo productor de carne magra y aptitud de incubación', 'Pastoreo cercado, perchas bajas y control de vuelo', 'Forraje, grano y ración balanceada'],
  ['aves', 'grande', 'pavo_blanco_pechuga_ancha', 'Pavo Blanco de Pechuga Ancha', 'EE.UU.', '8-18 kg', '5-7 años', 'Precoz, pesado y dependiente del manejo', 'Línea comercial de pavo para producción intensiva de carne', 'Control de patas, ventilación y densidad reducida', 'Ración de pavo por fases con proteína elevada'],

  # Bovinos lecheros, cárnicos y doble propósito
  ['bovinos', 'mediana', 'ayrshire', 'Ayrshire', 'Escocia', '450-600 kg', '15-20 años', 'Activa, longeva y lechera', 'Raza lechera de ubres funcionales y sólidos lácteos altos', 'Ordeño higiénico, control podal y sombra', 'Forraje de calidad más concentrado según litros producidos'],
  ['bovinos', 'mediana', 'guernsey', 'Guernsey', 'Islas del Canal', '450-550 kg', '15-20 años', 'Dócil, eficiente y lechera', 'Vaca lechera con leche rica en grasa, proteína y beta-caroteno', 'Ordeño regular y prevención de mastitis', 'Ración con fibra efectiva y energía para lactación'],
  ['bovinos', 'grande', 'pardo_suizo', 'Pardo Suizo', 'Suiza', '600-750 kg', '15-20 años', 'Dócil, longeva y adaptable', 'Raza lechera de alta proteína, apta para queso y sistemas de montaña', 'Control de pezuñas, reproducción y calidad de leche', 'Forraje abundante, concentrado y minerales'],
  ['bovinos', 'grande', 'normanda', 'Normanda', 'Francia', '650-800 kg', '15-20 años', 'Rústica, fértil y doble propósito', 'Bovino francés para leche quesera y carne', 'Pastoreo rotacional y registros reproductivos', 'Pasto, ensilaje y suplemento según lactación'],
  ['bovinos', 'grande', 'montbeliarde', 'Montbéliarde', 'Francia', '600-750 kg', '15-20 años', 'Resistente, funcional y lechera', 'Raza francesa valorada para quesería y cruzamientos lecheros', 'Ordeño, control de células somáticas y aplomos', 'Forraje de alta calidad y concentrado balanceado'],
  ['bovinos', 'grande', 'azul_belga', 'Azul Belga', 'Bélgica', '700-1.100 kg', '12-18 años', 'Musculosa, tranquila y cárnica', 'Raza de doble musculatura y alto rendimiento de canal', 'Vigilancia obstétrica intensiva y asistencia al parto', 'Ración energética-proteica con fibra efectiva'],
  ['bovinos', 'grande', 'chianina', 'Chianina', 'Italia', '800-1.300 kg', '15-20 años', 'Rústica, grande y cárnica', 'Una de las razas bovinas más grandes, productora de carne magra', 'Pastoreo extensivo, cercas robustas y manejo tranquilo', 'Pasto y suplementación en acabado'],
  ['bovinos', 'grande', 'santa_gertrudis', 'Santa Gertrudis', 'EE.UU.', '600-900 kg', '15-20 años', 'Tolerante al calor, maternal y cárnica', 'Compuesto 5/8 Shorthorn y 3/8 Brahman para carne tropical', 'Sombra, agua abundante y control de garrapata', 'Pasto tropical y suplemento en sequía'],
  ['bovinos', 'grande', 'gyr_lechero', 'Gyr Lechero', 'India/Brasil', '450-650 kg', '15-20 años', 'Tolerante al calor, fértil y lechera', 'Cebú lechero adaptado al trópico y base del Girolando', 'Ordeño tranquilo, control parasitario y sombra', 'Pasto tropical más concentrado de lactación'],
  ['bovinos', 'mediana', 'romosinuano', 'Romosinuano', 'Colombia', '450-650 kg', '15-20 años', 'Manso, fértil y adaptado al trópico', 'Criollo colombiano mocho, especializado en carne y eficiencia reproductiva', 'Pastoreo extensivo y conservación genética', 'Pasto tropical, sal mineral y agua'],

  # Porcinos
  ['porcinos', 'grande', 'chester_white', 'Chester White', 'EE.UU.', '250-350 kg', '10-12 años', 'Maternal, prolífico y dócil', 'Cerdo blanco estadounidense para línea materna y carne', 'Protección solar, registros de camada y ventilación', 'Pienso por fase con aminoácidos balanceados'],
  ['porcinos', 'grande', 'poland_china', 'Poland China', 'EE.UU.', '250-360 kg', '10-12 años', 'Precoz, robusto y cárnico', 'Cerdo negro de rápido crecimiento y buen rendimiento de canal', 'Control de aplomos y condición corporal', 'Ración de crecimiento y acabado'],
  ['porcinos', 'mediana', 'meishan', 'Meishan', 'China', '150-200 kg', '12-15 años', 'Muy prolífica, maternal y tranquila', 'Raza china destacada por camadas numerosas y madurez temprana', 'Manejo neonatal intensivo por camadas grandes', 'Ración de reproductora ajustada a prolificidad'],
  ['porcinos', 'mediana', 'gloucestershire_old_spots', 'Gloucestershire Old Spots', 'Inglaterra', '200-300 kg', '10-12 años', 'Dócil, forrajera y maternal', 'Raza patrimonial de pastoreo para carne y charcutería', 'Pastoreo rotacional, sombra y refugio seco', 'Forraje complementado con pienso balanceado'],
  ['porcinos', 'mediana', 'british_saddleback', 'British Saddleback', 'Reino Unido', '220-320 kg', '10-12 años', 'Rústico, maternal y forrajero', 'Cerdo negro con banda blanca para sistemas al aire libre', 'Cercado firme, rotación de potreros y refugio', 'Pasto más ración de crecimiento'],
  ['porcinos', 'grande', 'lacombe', 'Lacombe', 'Canadá', '250-330 kg', '10-12 años', 'Dócil, precoz y eficiente', 'Raza canadiense blanca para producción comercial de carne', 'Bioseguridad, ventilación y control de conversión', 'Pienso por fase con proteína digestible'],

  # Ovinos de carne, leche y lana
  ['ovinos', 'mediana', 'dorset', 'Dorset', 'Reino Unido', '70-110 kg', '10-12 años', 'Fértil, maternal y precoz', 'Oveja de carne capaz de reproducirse fuera de estación', 'Flushing pre-servicio y control de partos', 'Pasto, heno y suplemento preparto'],
  ['ovinos', 'grande', 'hampshire_down', 'Hampshire Down', 'Inglaterra', '90-140 kg', '10-12 años', 'Precoz, cárnica y maternal', 'Raza terminal de rápido crecimiento y buena canal', 'Control de peso al nacimiento y pastoreo', 'Forraje más suplemento de engorde'],
  ['ovinos', 'mediana', 'rambouillet', 'Rambouillet', 'Francia/EE.UU.', '65-110 kg', '10-14 años', 'Rústica, gregaria y lanera', 'Merino de gran tamaño para lana fina y carne', 'Esquila anual y selección por diámetro de fibra', 'Pasto, heno y minerales'],
  ['ovinos', 'mediana', 'awassi', 'Awassi', 'Oriente Medio', '50-90 kg', '10-12 años', 'Resistente, lechera y adaptada a sequía', 'Oveja de cola grasa para leche, carne y lana', 'Ordeño, protección térmica y manejo extensivo', 'Pasto seco, heno y concentrado de lactación'],
  ['ovinos', 'mediana', 'frisona_oriental', 'Frisona Oriental', 'Alemania/Países Bajos', '70-100 kg', '10-12 años', 'Lechera, prolífica y exigente', 'Una de las razas ovinas de mayor producción de leche', 'Ordeño higiénico, control de mastitis y buena nutrición', 'Forraje premium y concentrado de lactación'],
  ['ovinos', 'mediana', 'lacaune', 'Lacaune', 'Francia', '65-100 kg', '10-12 años', 'Lechera, funcional y gregaria', 'Raza francesa cuya leche se usa para queso Roquefort', 'Ordeño mecánico y selección por células somáticas', 'Pasto, ensilaje y concentrado según producción'],
  ['ovinos', 'mediana', 'corriedale', 'Corriedale', 'Nueva Zelanda', '60-100 kg', '12-14 años', 'Rústica, maternal y doble propósito', 'Oveja para lana media y carne en sistemas extensivos', 'Esquila anual, control de parásitos y pastoreo', 'Pasto natural y suplemento estacional'],
  ['ovinos', 'mediana', 'pelibuey', 'Pelibuey', 'Caribe', '35-60 kg', '10-12 años', 'Prolífica, resistente y sin lana', 'Oveja de pelo tropical para producción de carne', 'Sombra, control parasitario y reproducción continua', 'Pasto tropical y suplemento en sequía'],

  # Caprinos de leche, carne y fibra
  ['caprinos', 'mediana', 'murciano_granadina', 'Murciano-Granadina', 'España', '45-65 kg', '10-12 años', 'Lechera, rústica y eficiente', 'Cabra española de leche con alto contenido de grasa y proteína', 'Ordeño higiénico y control de mastitis', 'Forraje de calidad y concentrado de lactación'],
  ['caprinos', 'mediana', 'majorera', 'Majorera', 'Islas Canarias', '45-70 kg', '10-12 años', 'Rústica, lechera y adaptada a aridez', 'Cabra canaria productora de leche para queso Majorero', 'Manejo semiextensivo, sombra y ordeño', 'Forrajes secos y suplemento de lactación'],
  ['caprinos', 'mediana', 'malaguena', 'Malagueña', 'España', '45-70 kg', '10-12 años', 'Dócil, prolífica y lechera', 'Raza española para leche y cabrito', 'Ordeño, registros de lactación y selección mamaria', 'Pasto, heno y concentrado'],
  ['caprinos', 'mediana', 'oberhasli', 'Oberhasli', 'Suiza', '55-75 kg', '10-12 años', 'Tranquila, lechera y activa', 'Cabra suiza chamoisée para leche de buen sabor', 'Ordeño regular y ejercicio en pastoreo', 'Forraje, heno y concentrado lácteo'],
  ['caprinos', 'mediana', 'cachemira', 'Cabra de Cachemira', 'Asia Central', '40-70 kg', '10-15 años', 'Rústica, fibrosa y resistente al frío', 'Tipo caprino productor de fibra cashmere fina', 'Peinado o esquila estacional y clasificación de fibra', 'Pastoreo, heno y suplemento proteico en muda'],
  ['caprinos', 'grande', 'damasco', 'Cabra de Damasco', 'Siria/Líbano', '60-90 kg', '10-12 años', 'Lechera, prolífica y tolerante al calor', 'Raza de Oriente Medio para leche, carne y cruzamiento', 'Sombra, ordeño y control reproductivo', 'Forraje y concentrado de lactación'],

  # Conejos de carne, piel y fibra
  ['conejos', 'mediana', 'champagne_argent', 'Champagne d’Argent', 'Francia', '4-5,5 kg', '7-10 años', 'Dócil, precoz y cárnico', 'Conejo plateado para carne y piel', 'Jaula amplia, nidal seco y control podal', 'Heno libre y pellet de producción'],
  ['conejos', 'grande', 'belier_frances', 'Bélier Francés', 'Francia', '4,5-6,5 kg', '7-10 años', 'Tranquilo, pesado y maternal', 'Conejo de orejas caídas usado en producción cárnica y exhibición', 'Control de orejas, patas y reproducción', 'Heno, pellet alto en fibra y verduras'],
  ['conejos', 'mediana', 'satin', 'Satín', 'EE.UU.', '3,5-5 kg', '7-10 años', 'Dócil, maternal y de pelaje brillante', 'Conejo de doble aptitud carne y piel', 'Cepillado, nidos higiénicos y registro de camadas', 'Heno libre y pellet balanceado'],
  ['conejos', 'grande', 'chinchilla_gigante', 'Chinchilla Gigante', 'EE.UU.', '5,5-7 kg', '7-10 años', 'Calmado, pesado y productivo', 'Conejo grande para carne y piel tipo chinchilla', 'Piso confortable, control de pododermatitis', 'Heno, pellet de crecimiento y agua'],

  # Camélidos de fibra y trabajo
  ['camelidos', 'mediana', 'alpaca_huacaya', 'Alpaca Huacaya', 'Andes', '55-80 kg', '15-20 años', 'Dócil, fibrosa y gregaria', 'Alpaca de vellón esponjoso para fibra textil', 'Esquila anual y clasificación por micronaje', 'Pasto andino, heno y minerales'],
  ['camelidos', 'grande', 'camello_bactriano', 'Camello Bactriano', 'Asia Central', '450-650 kg', '30-40 años', 'Resistente, fuerte y multipropósito', 'Camélido de dos jorobas para leche, fibra, carne y carga', 'Amplio espacio, protección del calor húmedo y esquila', 'Forraje seco, heno y agua suficiente'],

  # Equinos de tiro agrícola
  ['equinos', 'grande', 'suffolk_punch', 'Suffolk Punch', 'Inglaterra', '750-1.000 kg', '20-25 años', 'Fuerte, dócil y trabajador', 'Caballo de tiro agrícola compacto y eficiente', 'Trabajo progresivo, herraje y descanso muscular', 'Heno abundante y concentrado según carga'],
  ['equinos', 'grande', 'ardenes', 'Ardenés', 'Bélgica/Francia', '700-1.000 kg', '20-25 años', 'Potente, tranquilo y resistente', 'Caballo de tiro pesado para agricultura y silvicultura', 'Cuidado de cascos, arnés ajustado y control articular', 'Forraje de calidad y energía según trabajo'],

  # Peces de acuicultura y producción alimentaria
  ['peces', 'mediana', 'tilapia_nilotica', 'Tilapia del Nilo', 'África oriental', '0,3-0,6 kg (faena)', '5-10 años', 'Rústica, gregaria y omnívora', 'Oreochromis niloticus, principal especie de acuicultura tropical mundial', 'Estanques o jaulas con oxígeno, bioseguridad y densidad controlada', 'Pellets 28-32% proteína según fase; suplemento vegetal cuando aplique'],
  ['peces', 'mediana', 'trucha_arcoiris', 'Trucha Arcoíris', 'Norteamérica', '0,25-0,5 kg (faena)', '4-11 años', 'Activa, carnívora y sensible al estrés', 'Oncorhynchus mykiss para piscicultura en agua fría y ríos', 'Flujo alto, T° 10-16 °C, control de amoniaco y mortalidad por estrés', 'Pellets de alta digestibilidad 40-45% proteína por talla'],
  ['peces', 'grande', 'salmon_atlantico', 'Salmón del Atlántico', 'Atlántico norte', '3-6 kg (faena)', '4-6 años (cultivo)', 'Migratoria, exigente y de alto valor', 'Salmo salar cultivado en jaulas marinas y tierra para filete premium', 'Bioseguridad marina, control de piojos del mar y oxígeno', 'Ración extruida por fase con pigmentantes y ácidos grasos omega-3'],
  ['peces', 'grande', 'carpa_comun', 'Carpa Común', 'Europa/Asia', '1-3 kg (faena)', '10-20 años', 'Rústica, bentónica y tolerante', 'Cyprinus carpio base de piscicultura continental y policultivo', 'Estanques extensivos o semiintensivos con aireación en verano', 'Pellets 25-32% proteína; forraje natural y suplemento estacional'],
  ['peces', 'grande', 'bagre_canal', 'Bagre de Canal', 'EE.UU.', '0,5-2 kg (faena)', '8-15 años', 'Omnívora, rústica y de fondo', 'Ictalurus punctatus líder en acuicultura de agua dulce templada', 'Estanques profundos, aireación nocturna y manejo sanitario', 'Pellets flotantes 32-36% proteína según talla'],
  ['peces', 'grande', 'pangasius', 'Pangasius (Basa)', 'Vietnam/Mekong', '1-2,5 kg (faena)', '8-10 años', 'Rápido crecimiento, gregaria y resistente', 'Pangasianodon hypophthalmus de producción intensiva tropical', 'Jaulas fluviales o estanques con calidad de agua estricta', 'Pellets 28-32% proteína; control de alimento y conversión'],
  ['peces', 'mediana', 'lubina_europea', 'Lubina Europea', 'Mediterráneo/Atlántico', '0,3-1,5 kg (faena)', '10-20 años', 'Carnívora, territorial y exigente', 'Dicentrarchus labrax de acuicultura marina mediterránea', 'Jaulas marinas, salinidad estable y manejo de estrés en faena', 'Ración marina 45-50% proteína con control de grasa visceral'],
  ['peces', 'mediana', 'dorada_gilthead', 'Dorada (Dorada Gilthead)', 'Mediterráneo', '0,35-1,2 kg (faena)', '8-12 años', 'Gregaria, carnívora y de alto valor', 'Sparus aurata cultivada en jaulas marinas para mercado fresco', 'Bioseguridad marina, vacunación según zona y oxígeno disuelto', 'Pellets marinos por fase; pigmentación y calidad de filete']
].freeze

PRODUCTION_METADATA = {
  'leghorn' => ['Huevos', 'Sistemas intensivo, campero u orgánico', '280-320 huevos/año; huevo blanco de 55-63 g'],
  'rhode_island_red' => ['Doble propósito', 'Campero, traspatio o semiintensivo', '200-280 huevos/año y buena canal'],
  'plymouth_rock' => ['Doble propósito', 'Campero o semiintensivo', '180-250 huevos/año; crecimiento moderado'],
  'sussex' => ['Doble propósito', 'Campero y pastoreo', '200-250 huevos/año; buena aptitud cárnica'],
  'cornish_industrial' => ['Carne', 'Intensivo con control ambiental', 'Alto rendimiento de pechuga; base de cruces broiler'],
  'pato_pekin' => ['Carne', 'Intensivo o semiintensivo', 'Peso de faena 3-4 kg a las 7-9 semanas'],
  'pato_muscovy' => ['Carne e incubación', 'Pastoreo o semiintensivo', 'Carne magra; buena habilidad maternal'],
  'pavo_blanco_pechuga_ancha' => ['Carne', 'Intensivo', 'Machos 15-18 kg a faena; hembras 8-10 kg'],
  'ayrshire' => ['Leche', 'Pastoreo o estabulación', '6.000-8.000 kg/lactancia; 4,0-4,3% grasa'],
  'guernsey' => ['Leche', 'Pastoreo o semiintensivo', '5.000-7.000 kg/lactancia; 4,5-5,0% grasa'],
  'pardo_suizo' => ['Leche y queso', 'Estabulación o montaña', '7.000-10.000 kg/lactancia; proteína 3,5-3,8%'],
  'normanda' => ['Leche y carne', 'Pastoreo', '6.000-8.000 kg/lactancia; excelente rendimiento quesero'],
  'montbeliarde' => ['Leche y queso', 'Pastoreo o estabulación', '7.000-9.000 kg/lactancia; alta caseína'],
  'azul_belga' => ['Carne', 'Semiintensivo', 'Rendimiento de canal 65-70%; alta frecuencia de cesárea'],
  'chianina' => ['Carne', 'Extensivo o feedlot', 'Ganancia diaria elevada y canal magra'],
  'santa_gertrudis' => ['Carne tropical', 'Extensivo', 'Buena fertilidad y ganancia en clima cálido'],
  'gyr_lechero' => ['Leche tropical', 'Pastoreo tropical', '3.000-6.000 kg/lactancia según selección'],
  'romosinuano' => ['Carne y cría', 'Extensivo tropical', 'Alta fertilidad, longevidad y facilidad de parto'],
  'chester_white' => ['Carne y línea materna', 'Intensivo', 'Camadas grandes y buena conversión'],
  'poland_china' => ['Carne', 'Intensivo', 'Rápido crecimiento y buena canal'],
  'meishan' => ['Reproducción', 'Semiintensivo', '14-18 lechones nacidos por camada'],
  'gloucestershire_old_spots' => ['Carne premium', 'Pastoreo', 'Buena calidad sensorial y habilidad maternal'],
  'british_saddleback' => ['Carne y cría', 'Exterior', 'Camadas numerosas y buena aptitud forrajera'],
  'lacombe' => ['Carne', 'Intensivo', 'Buena conversión y rendimiento de canal'],
  'dorset' => ['Carne y reproducción', 'Pastoreo', 'Reproducción fuera de estación; 150-200% prolificidad'],
  'hampshire_down' => ['Carne', 'Sistema terminal', 'Alta ganancia diaria y conformación de canal'],
  'rambouillet' => ['Lana fina y carne', 'Extensivo', 'Fibra 18-24 micras; vellón pesado'],
  'awassi' => ['Leche y carne', 'Extensivo árido', '250-500 L/lactancia en líneas seleccionadas'],
  'frisona_oriental' => ['Leche', 'Intensivo o semiintensivo', '400-700 L/lactancia; alta prolificidad'],
  'lacaune' => ['Leche y queso', 'Semiintensivo', '300-450 L/lactancia; selección por sólidos'],
  'corriedale' => ['Lana y carne', 'Extensivo', 'Lana 25-31 micras y buena canal'],
  'pelibuey' => ['Carne tropical', 'Extensivo', 'Alta prolificidad y reproducción no estacional'],
  'murciano_granadina' => ['Leche y queso', 'Intensivo o semiintensivo', '500-700 L/lactancia; sólidos elevados'],
  'majorera' => ['Leche y queso', 'Árido semiintensivo', 'Alta persistencia de lactación en clima seco'],
  'malaguena' => ['Leche y cabrito', 'Semiintensivo', '450-600 L/lactancia'],
  'oberhasli' => ['Leche', 'Pastoreo o estabulación', '600-900 L/lactancia'],
  'cachemira' => ['Fibra', 'Extensivo frío', '150-500 g de cashmere fino/año'],
  'damasco' => ['Leche y carne', 'Semiintensivo cálido', '500-800 L/lactancia y alta prolificidad'],
  'champagne_argent' => ['Carne y piel', 'Cunicultura semiintensiva', 'Buen crecimiento y piel plateada'],
  'belier_frances' => ['Carne', 'Cunicultura semiintensiva', 'Peso adulto 4,5-6,5 kg'],
  'satin' => ['Carne y piel', 'Cunicultura semiintensiva', 'Buena canal y pelo satinado'],
  'chinchilla_gigante' => ['Carne y piel', 'Cunicultura semiintensiva', 'Peso adulto 5,5-7 kg'],
  'alpaca_huacaya' => ['Fibra', 'Pastoreo altoandino', 'Vellón 2-4 kg/año; fibra 18-30 micras'],
  'camello_bactriano' => ['Leche, fibra, carne y carga', 'Extensivo continental', '3-8 L leche/día; fibra estacional'],
  'suffolk_punch' => ['Trabajo agrícola', 'Tracción animal sostenible', 'Alta fuerza de tiro y bajo consumo relativo'],
  'ardenes' => ['Trabajo agrícola y forestal', 'Tracción animal', 'Alta potencia en tiro pesado'],
  'tilapia_nilotica' => ['Carne', 'Estanques extensivos, semiintensivos o RAS tropical', 'FCR 1,2-1,8; 3-5 t/ha/año según sistema; faena 250-500 g'],
  'trucha_arcoiris' => ['Carne', 'Piscicultura en agua fría o jaulas fluviales', 'FCR 1,0-1,3; crecimiento 100-150 g/mes en condiciones óptimas'],
  'salmon_atlantico' => ['Carne premium', 'Jaulas marinas o RAS costero', 'FCR 1,1-1,4; rendimiento filete 65-70%; ciclo 18-24 meses'],
  'carpa_comun' => ['Carne', 'Estanques extensivos o semiintensivos', 'FCR 1,5-2,5; 2-5 t/ha/año; policultivo con otras especies'],
  'bagre_canal' => ['Carne', 'Estanques semiintensivos templados', 'FCR 1,5-2,0; 4-7 t/ha/año; faena 450-900 g'],
  'pangasius' => ['Carne', 'Estanques o jaulas fluviales intensivas', 'FCR 1,4-1,9; crecimiento rápido; faena 1-1,5 kg'],
  'lubina_europea' => ['Carne marina', 'Jaulas marinas mediterráneas', 'FCR 1,3-1,6; faena 400-800 g; alto valor de mercado'],
  'dorada_gilthead' => ['Carne marina', 'Jaulas marinas costeras', 'FCR 1,4-1,7; faena 350-600 g; excelente aceptación comercial']
}.freeze

PRODUCTION_BREED_EXTRA = PRODUCTION_BREEDS.each_with_object({}) do |row, result|
  animal_id, _size, id, name, origin, weight, lifespan, temperament, description, care, feeding = row
  product, system, performance = PRODUCTION_METADATA.fetch(id)
  result[id] = {
    enfoque_produccion: true,
    tipo_produccion: product,
    sistema_productivo: system,
    rendimiento_productivo: performance,
    indicadores_productivos: [
      "Registrar rendimiento individual o por lote: #{performance}",
      'Conversión alimenticia o eficiencia por unidad producida',
      'Mortalidad, morbilidad y descartes con causa documentada',
      'Fertilidad, intervalo entre partos/posturas y longevidad productiva',
      'Calidad del producto según mercado y normativa sanitaria'
    ],
    manejo_productivo: "#{care}. Establecer lotes homogéneos, calendario reproductivo, control de condición corporal y revisión de instalaciones.",
    nutricion_productiva: "#{feeding}. Formular raciones por etapa fisiológica y verificar agua, minerales y calidad de materias primas.",
    bioseguridad_productiva: "Cuarentena de ingresos, sistema todo dentro/todo fuera cuando aplique, limpieza y desinfección, control de vectores, aislamiento de enfermos y registro de tratamientos en #{animal_id}.",
    bienestar_productivo: 'Aplicar las cinco libertades: agua y alimento suficientes, confort, prevención del dolor y enfermedad, expresión de conducta natural y ausencia de miedo. Evaluar densidad, locomoción, lesiones y comportamiento.',
    registros_productivos: ['Identificación individual o por lote', 'Consumo de alimento y agua', 'Producción diaria/mensual', 'Reproducción y genealogía', 'Vacunación, tratamientos y tiempos de retiro', 'Mortalidad y decomisos'],
    historia: "#{name} se desarrolló en #{origin} mediante selección orientada a #{product.downcase}. Su conservación depende de programas de cría que equilibren productividad, salud, fertilidad y diversidad genética.",
    caracteristicas: "#{description}. Peso adulto de referencia: #{weight}; longevidad biológica aproximada: #{lifespan}.",
    aptitudes: "#{product}. Sistema recomendado: #{system}. Rendimiento de referencia: #{performance}.",
    fuentes_produccion: ['FAO Domestic Animal Diversity Information System (DAD-IS)', 'Oklahoma State University — Breeds of Livestock', 'Manual Merck Veterinario — Producción Animal']
  }
end.freeze
