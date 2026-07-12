# frozen_string_literal: true

# Lote 6 — Razas y especies productivas relevantes para Colombia.
# Incluye criollos colombianos, sistemas tropicales y acuicultura continental.
PRODUCTION_BREEDS_BATCH6_COLOMBIA = [
  # Bovinos criollos colombianos y compuestos tropicales
  ['bovinos', 'mediana', 'blanco_orejinegro', 'Blanco Orejinegro (BON)', 'Colombia', '400-700 kg', '15-20 años', 'Manso, fértil y rústico', 'Bovino criollo colombiano blanco con orejas negras, adaptado a ladera, humedad y trópico medio', 'Pastoreo rotacional, selección por fertilidad y conservación genética', 'Pasto tropical, sal mineralizada y suplemento estratégico en verano'],
  ['bovinos', 'mediana', 'harton_del_valle', 'Hartón del Valle', 'Colombia', '450-750 kg', '15-20 años', 'Dócil, longevo y doble propósito', 'Criollo bovino del Valle del Cauca usado para leche, carne y cruzamientos adaptados', 'Manejo en pastoreo cálido, ordeño higiénico y control reproductivo', 'Forraje de buena calidad, agua abundante y concentrado según lactancia'],
  ['bovinos', 'mediana', 'sanmartinero', 'Sanmartinero', 'Colombia', '430-680 kg', '15-20 años', 'Rústico, caminador y fértil', 'Bovino criollo de la Orinoquía para carne y cría en sabanas tropicales', 'Pastoreo extensivo, sombra, control de garrapata y registro de natalidad', 'Pasto de sabana mejorado, sal mineral y suplemento proteico en sequía'],
  ['bovinos', 'mediana', 'costeno_con_cuernos', 'Costeño con Cuernos', 'Colombia', '400-650 kg', '15-20 años', 'Adaptado, maternal y resistente', 'Criollo colombiano de la región Caribe, útil para cría, leche rústica y cruzamientos', 'Manejo extensivo con sombra, agua permanente y conservación de líneas criollas', 'Pasto tropical, bancos de proteína y sal mineralizada'],
  ['bovinos', 'mediana', 'chino_santandereano', 'Chino Santandereano', 'Colombia', '380-620 kg', '15-20 años', 'Sobrio, fértil y resistente', 'Bovino criollo de Santander adaptado a topografía quebrada y sistemas campesinos', 'Pastoreo en ladera, manejo tranquilo y selección por rusticidad', 'Forraje de ladera, sal mineral y suplemento energético puntual'],
  ['bovinos', 'mediana', 'casanareno', 'Casanareño', 'Colombia', '350-600 kg', '15-20 años', 'Rústico, caminador y tolerante al calor', 'Criollo bovino de los Llanos Orientales para cría extensiva y resistencia ambiental', 'Manejo extensivo, control sanitario básico y selección por habilidad materna', 'Pasto de sabana, sal mineral y agua en bebederos o caños seguros'],
  ['bovinos', 'mediana', 'criollo_caqueteno', 'Criollo Caqueteño', 'Colombia', '400-650 kg', '15-20 años', 'Adaptado, doble propósito y rústico', 'Bovino criollo de la Amazonía colombiana para sistemas de carne y leche tropical', 'Pastoreo en trópico húmedo, control de parásitos y sombra natural', 'Pasto tropical húmedo, leguminosas y suplemento mineral'],
  ['bovinos', 'mediana', 'lucerna_colombiana', 'Lucerna Colombiana', 'Colombia', '450-700 kg', '15-20 años', 'Lechera, dócil y funcional', 'Raza sintética colombiana de doble propósito con base criolla, Holstein y Shorthorn', 'Ordeño higiénico, registros lecheros y control de mastitis', 'Pasto de calidad, ensilaje y concentrado según litros producidos'],
  ['bovinos', 'grande', 'velasquez_colombiano', 'Velásquez', 'Colombia', '550-850 kg', '15-20 años', 'Cárnico, precoz y adaptado', 'Compuesto colombiano para carne tropical, con buena adaptación y rendimiento de canal', 'Pastoreo de engorde, selección por ganancia diaria y manejo sanitario preventivo', 'Pasto mejorado, suplemento energético-proteico y sal mineralizada'],

  # Porcinos criollos
  ['porcinos', 'mediana', 'cerdo_zungo', 'Cerdo Zungo', 'Colombia', '80-160 kg', '8-12 años', 'Rústico, forrajero y resistente', 'Cerdo criollo colombiano adaptado al trópico, útil en producción campesina y conservación genética', 'Sistema semiintensivo o traspatio tecnificado con sombra, bioseguridad y registros', 'Subproductos seguros, forraje y balanceado por fase productiva'],
  ['porcinos', 'mediana', 'cerdo_casco_de_mula', 'Cerdo Casco de Mula', 'Colombia', '90-170 kg', '8-12 años', 'Rústico, caminador y maternal', 'Cerdo criollo colombiano de pezuña compacta, valorado por adaptación a sistemas extensivos', 'Pastoreo controlado, refugio seco, cercas firmes y control sanitario', 'Ración de crecimiento, tubérculos cocidos seguros y suplemento proteico'],

  # Ovinos y caprinos tropicales colombianos
  ['ovinos', 'mediana', 'ovino_criollo_colombiano', 'Ovino Criollo Colombiano', 'Colombia', '30-55 kg', '8-12 años', 'Prolífico, rústico y adaptado', 'Ovino de pelo usado en carne y cría en sistemas tropicales de bajo insumo', 'Pastoreo rotacional, control de parásitos gastrointestinales y sombra', 'Pasto tropical, sal ovina baja en cobre y suplemento en gestación'],
  ['ovinos', 'mediana', 'camuro_colombiano', 'Camuro Colombiano', 'Colombia', '30-60 kg', '8-12 años', 'Resistente, fértil y carnicero', 'Ovino tropical de pelo frecuente en sistemas campesinos para carne de cordero', 'Manejo en potreros, desparasitación estratégica y selección por prolificidad', 'Forraje, bloques nutricionales y suplemento en lactancia'],
  ['caprinos', 'mediana', 'caprino_criollo_colombiano', 'Caprino Criollo Colombiano', 'Colombia', '30-55 kg', '10-12 años', 'Rústico, ramoneador y fértil', 'Cabra criolla adaptada a zonas secas y de ladera para leche, carne y autoconsumo', 'Ramoneo controlado, sombra, control podal y registros reproductivos', 'Ramoneo, heno, sal mineral caprina y agua limpia'],
  ['caprinos', 'mediana', 'cabra_santandereana', 'Cabra Santandereana', 'Colombia', '35-60 kg', '10-12 años', 'Lechera, resistente y caminadora', 'Tipo caprino regional de Santander usado para leche artesanal y cabrito', 'Pastoreo de ladera, ordeño higiénico y control de mastitis', 'Forraje arbustivo, concentrado de lactancia y minerales'],

  # Acuicultura continental colombiana
  ['peces', 'mediana', 'bocachico', 'Bocachico', 'Colombia', '0,3-1 kg (faena)', '5-10 años', 'Detritívoro, migratorio y gregario', 'Prochilodus magdalenae, pez nativo clave para repoblamiento y consumo regional', 'Estanques con buena calidad de agua, manejo de alevinos y respeto por vedas', 'Alimento natural del estanque y pellets complementarios 24-28% proteína'],
  ['peces', 'grande', 'yamu', 'Yamú', 'Colombia', '1-3 kg (faena)', '8-12 años', 'Omnívoro, fuerte y de rápido crecimiento', 'Brycon amazonicus cultivado en estanques tropicales por su carne apreciada', 'Agua bien oxigenada, densidad moderada y manejo cuidadoso por saltos', 'Pellets 28-32% proteína, frutas/semillas controladas y alimentación por talla'],
  ['peces', 'grande', 'cachama_negra', 'Cachama Negra', 'Colombia/Amazonas', '2-8 kg (faena)', '10-20 años', 'Rústica, omnívora y gregaria', 'Colossoma macropomum de alta importancia en acuicultura amazónica y Orinoquía', 'Estanques profundos, aireación, calidad de agua y bioseguridad', 'Pellets 28-34% proteína, frutas regionales y control de conversión'],
  ['peces', 'mediana', 'capaz', 'Capaz', 'Colombia', '0,2-0,8 kg (faena)', '5-8 años', 'Bentónico, delicado y de agua dulce', 'Pimelodus grosskopfii, especie nativa con potencial de cultivo y conservación', 'Manejo de calidad de agua, refugios y densidades bajas durante adaptación', 'Pellets hundibles de alta digestibilidad y alimento natural del fondo'],
  ['peces', 'grande', 'bagre_rayado', 'Bagre Rayado', 'Colombia', '2-10 kg (faena)', '10-20 años', 'Carnívoro, migratorio y valioso', 'Pseudoplatystoma magdaleniatum, bagre nativo de alto valor comercial y conservación', 'Cultivo especializado, manejo de larvicultura, oxígeno alto y bioseguridad', 'Ración carnívora 38-45% proteína, transición gradual a pellets'],

  # Aves criollas y patos de sistemas campesinos
  ['aves', 'mediana', 'gallina_criolla_colombiana', 'Gallina Criolla Colombiana', 'Colombia', '1,6-2,8 kg', '5-8 años', 'Rústica, clueca y forrajera', 'Gallina local de traspatio para huevo, carne y seguridad alimentaria familiar', 'Corral seguro, nidos limpios, vacunación y control de depredadores', 'Maíz, forraje, sobras seguras y suplemento de ponedora con calcio'],
  ['aves', 'mediana', 'pato_criollo_colombiano', 'Pato Criollo Colombiano', 'Colombia', '2,5-5 kg', '8-12 años', 'Forrajero, maternal y resistente', 'Pato criollo de sistemas rurales para carne, huevos e incubación natural', 'Acceso a agua, refugio seco, control de parásitos y manejo de crías', 'Forraje, granos, insectos y ración de crecimiento con niacina']
].freeze

PRODUCTION_METADATA_BATCH6_COLOMBIA = {
  'blanco_orejinegro' => ['Carne, cría y cruzamiento adaptado', 'Pastoreo tropical de ladera y trópico medio', 'Alta fertilidad y supervivencia; útil para cruzamientos en calor y humedad'],
  'harton_del_valle' => ['Doble propósito', 'Pastoreo cálido semiintensivo', 'Leche y carne con buena longevidad; sólidos lácteos para quesería regional'],
  'sanmartinero' => ['Carne y cría', 'Sabanas de la Orinoquía', 'Alta habilidad materna, facilidad de parto y rusticidad en extensivo'],
  'costeno_con_cuernos' => ['Doble propósito y conservación', 'Trópico bajo Caribe', 'Buena adaptación al calor; producción campesina de leche y cría'],
  'chino_santandereano' => ['Carne, cría y trabajo rural', 'Ladera santandereana y sistemas campesinos', 'Rusticidad, sobriedad y fertilidad en zonas quebradas'],
  'casanareno' => ['Cría extensiva', 'Llanos Orientales', 'Resistencia al calor, caminatas largas y sistemas de bajo insumo'],
  'criollo_caqueteno' => ['Doble propósito tropical', 'Trópico húmedo amazónico', 'Adaptación a humedad, parásitos y sistemas de pequeña ganadería'],
  'lucerna_colombiana' => ['Leche y doble propósito', 'Pastoreo mejorado con ordeño', 'Producción lechera funcional en trópico; buena fertilidad y longevidad'],
  'velasquez_colombiano' => ['Carne tropical', 'Pastoreo y ceba tropical', 'Buenas ganancias en pasturas y rendimiento de canal para clima cálido'],
  'cerdo_zungo' => ['Carne y conservación genética', 'Traspatio tecnificado o semiintensivo', 'Alta rusticidad, aprovechamiento de recursos locales y carne regional'],
  'cerdo_casco_de_mula' => ['Carne criolla', 'Sistemas extensivos controlados', 'Adaptación al terreno y bajo insumo; interés en conservación genética'],
  'ovino_criollo_colombiano' => ['Carne tropical', 'Pastoreo tropical', 'Corderos rústicos, buena reproducción y tolerancia a calor'],
  'camuro_colombiano' => ['Carne de cordero', 'Pastoreo y traspatio rural', 'Buena prolificidad y adaptación a sistemas campesinos'],
  'caprino_criollo_colombiano' => ['Leche, carne y autoconsumo', 'Ramoneo en zonas secas o ladera', 'Bajo costo de alimentación y buena rusticidad'],
  'cabra_santandereana' => ['Leche y cabrito', 'Ladera semiintensiva', 'Producción artesanal de leche y cabrito en sistemas regionales'],
  'bocachico' => ['Carne y repoblamiento', 'Estanques y programas de conservación', 'Especie nativa de alta demanda regional; valor para seguridad alimentaria'],
  'yamu' => ['Carne', 'Estanques tropicales semiintensivos', 'Crecimiento rápido y buen precio local en Orinoquía/Amazonía'],
  'cachama_negra' => ['Carne', 'Estanques tropicales', 'Faena 2-5 kg; alta aceptación en mercado colombiano'],
  'capaz' => ['Carne nativa', 'Cultivo experimental o conservación', 'Alto valor regional; requiere manejo técnico de alevinaje'],
  'bagre_rayado' => ['Carne premium nativa', 'Acuicultura especializada', 'Alto valor comercial; ciclo más técnico y exigente'],
  'gallina_criolla_colombiana' => ['Huevos y carne de traspatio', 'Traspatio, campero y sistemas familiares', 'Huevos y carne para autoconsumo; alta rusticidad y cluequez'],
  'pato_criollo_colombiano' => ['Carne, huevos e incubación', 'Traspatio con agua y pastoreo', 'Carne rústica, buena crianza natural y aprovechamiento de forraje']
}.freeze

PRODUCTION_BREED_EXTRA_BATCH6_COLOMBIA = PRODUCTION_BREEDS_BATCH6_COLOMBIA.each_with_object({}) do |row, result|
  animal_id, _size, id, name, origin, weight, lifespan, temperament, description, care, feeding = row
  product, system, performance = PRODUCTION_METADATA_BATCH6_COLOMBIA.fetch(id)
  result[id] = {
    enfoque_produccion: true,
    tipo_produccion: product,
    sistema_productivo: system,
    rendimiento_productivo: performance,
    indicadores_productivos: [
      "Registrar rendimiento individual o por lote: #{performance}",
      'Fertilidad, natalidad, supervivencia y peso al destete cuando aplique',
      'Conversión alimenticia o eficiencia por unidad producida',
      'Mortalidad, morbilidad y descartes con causa documentada',
      'Adaptación al calor, parásitos y disponibilidad de forraje local'
    ],
    manejo_productivo: "#{care}. Priorizar conservación genética, bienestar, trazabilidad sanitaria y selección de animales adaptados a regiones colombianas.",
    nutricion_productiva: "#{feeding}. Ajustar suplementación a época seca/lluviosa, calidad de pasto o agua y disponibilidad local de materias primas.",
    bioseguridad_productiva: "Cuarentena de ingresos, control de vectores y parásitos, limpieza de corrales/estanques, aislamiento de enfermos y registros sanitarios en #{animal_id}.",
    bienestar_productivo: 'Garantizar sombra, agua limpia, espacio suficiente, manejo tranquilo y prevención de dolor, hambre, sed, estrés térmico y enfermedades.',
    registros_productivos: ['Identificación individual o por lote', 'Consumo de alimento y agua', 'Producción diaria/mensual', 'Reproducción, partos o desoves', 'Tratamientos y tiempos de retiro', 'Mortalidad, decomisos y causas'],
    historia: "#{name} forma parte de los recursos productivos usados o conservados en Colombia. Su valor está en la adaptación al trópico, la rusticidad y la posibilidad de producir con insumos locales.",
    caracteristicas: "#{description}. Peso adulto o de faena de referencia: #{weight}; longevidad biológica aproximada: #{lifespan}.",
    aptitudes: "#{product}. Sistema recomendado: #{system}. Rendimiento de referencia: #{performance}.",
    fuentes_produccion: ['AGROSAVIA — Recursos zoogenéticos y sistemas productivos de Colombia', 'FAO Domestic Animal Diversity Information System (DAD-IS)', 'ICA Colombia — Sanidad agropecuaria e inocuidad']
  }
end.freeze
