# frozen_string_literal: true

# Lote 5 — aves de consumo humano: broilers, criollas, codorniz, pintada, faisán, etc.
PRODUCTION_BREEDS_BATCH5 = [
  # Pollos de engorde comercial
  ['aves', 'grande', 'pollo_broiler_ross', 'Pollo Broiler Ross 308', 'Escocia/Comercial', '2-2,5 kg (faena)', '6-8 semanas', 'Precoz, eficiente y gregario', 'Línea comercial de pollo de engorde más utilizada mundialmente', 'Galpón climatizado, cama de cama, ventilación y densidad regulada', 'Ración starter/grower/finisher 20-23% proteína'],
  ['aves', 'grande', 'pollo_cobb500', 'Pollo Cobb 500', 'EE.UU./Comercial', '2-2,8 kg (faena)', '6-8 semanas', 'Robusto, precoz y uniforme', 'Línea de engorde de alto rendimiento de pechuga y pierna', 'Control ambiental estricto, bioseguridad y registro de conversión', 'Ración comercial por fase con aminoácidos digestibles'],
  ['aves', 'mediana', 'pollo_red_ranger', 'Pollo Red Ranger', 'Francia/Comercial', '2-2,5 kg (faena)', '10-12 semanas', 'Activo, forrajero y de crecimiento lento', 'Pollo campero de carne con pigmentación amarilla y sabor intenso', 'Sistema al aire libre o semiextensivo con refugio', 'Ración completa más pastoreo y forraje verde'],

  # Gallinas de granja y consumo familiar
  ['aves', 'grande', 'brahma', 'Brahma', 'EE.UU./Asia', '4-5,5 kg', '6-8 años', 'Tranquila, pesada y maternal', 'Gallina gigante de doble propósito para carne de caldero y huevos', 'Corral espacioso, perchas bajas y protección del frío', 'Ración de mantenimiento y suplemento en postura'],
  ['aves', 'mediana', 'wyandotte', 'Wyandotte', 'EE.UU.', '2,5-3,5 kg', '6-8 años', 'Dócil, forrajera y resistente al frío', 'Gallina barrada de granja para huevos y carne de consumo', 'Sistema campero con nidos y cama profunda', 'Ración de ponedora y forraje estacional'],
  ['aves', 'mediana', 'gallina_criolla', 'Gallina Criolla', 'Latinoamérica', '1,5-2,5 kg', '4-6 años', 'Rústica, forrajera y resistente', 'Ave autóctona de traspatio para huevos y carne familiar', 'Manejo extensivo, bioseguridad básica y refugio nocturno', 'Grano, forraje, desperdicios controlados y calcio'],
  ['aves', 'mediana', 'ameraucana', 'Ameraucana', 'EE.UU.', '2-2,5 kg', '6-8 años', 'Activa, rústica y de plumas', 'Gallina productora de huevos azules para mercado diferenciado', 'Corral con nidos, sombra y manejo sanitario', 'Ración de ponedora con 16-18% proteína'],

  # Patos y gansos de mesa
  ['aves', 'grande', 'pato_mulard', 'Pato Mulard', 'Francia/Híbrido', '4-5 kg (faena)', '12-15 semanas', 'Híbrido, pesado y de rápido engorde', 'Cruce Pekín × Muscovy para carne magra y foie gras', 'Engorde controlado, agua para limpieza y densidad moderada', 'Ración de engorde con maíz y suplemento de niacina'],
  ['aves', 'grande', 'pato_aylesbury', 'Pato Aylesbury', 'Inglaterra', '4-5 kg (faena)', '8-12 años', 'Tranquilo, blanco y pesado', 'Pato blanco tradicional inglés para carne de mesa', 'Corral con agua, cama seca y protección del barro', 'Ración de pato de carne y forraje verde'],
  ['aves', 'grande', 'ganso_toulouse', 'Ganso Toulouse', 'Francia', '7-12 kg', '10-15 años', 'Pesado, forrajero y rústico', 'Ganso gris de gran tamaño para carne, grasa y foie', 'Pastos verdes, agua para baño y engorde estacional', 'Pasto, maíz y ración de engorde en fase final'],
  ['aves', 'grande', 'ganso_chino', 'Ganso Chino (Africano)', 'China', '5-8 kg', '10-15 años', 'Vocal, forrajero y prolífico', 'Ganso de cuello largo para carne, huevos y cría', 'Pastoreo con agua, refugio y control de depredadores', 'Pasto, grano y suplemento reproductivo'],

  # Pavos de consumo
  ['aves', 'grande', 'pavo_bourbon_red', 'Pavo Bourbon Red', 'EE.UU.', '7-14 kg', '5-8 años', 'Activo, rústico y forrajero', 'Pavo rojizo de granja para carne de sabor tradicional', 'Corral amplio, perchas y protección de pavipollo', 'Ración de pavo y forraje'],
  ['aves', 'grande', 'pavo_narragansett', 'Pavo Narragansett', 'EE.UU.', '7-13 kg', '5-8 años', 'Tranquilo, maternal y forrajero', 'Pavo barrado de granja para carne de calidad', 'Sistema semiextensivo con refugio y registro reproductivo', 'Ración balanceada y pastoreo'],

  # Aves menores de consumo humano
  ['aves', 'pequena', 'codorniz_japonesa', 'Codorniz Japonesa', 'Asia', '0,1-0,15 kg', '2-3 años', 'Nerviosa, prolífica y de ciclo corto', 'Ave de corral para huevos gourmet y carne de bistró', 'Jaulas o pisos elevados, luz 14-16 h y bioseguridad', 'Ración de codorniz 24-28% proteína y calcio fino'],
  ['aves', 'mediana', 'pintada', 'Pintada (Guinea Fowl)', 'África', '1,3-1,8 kg', '6-8 años', 'Vigilante, forrajera y ruidosa', 'Ave de corral para carne magra y huevos de sabor intenso', 'Corral cubierto, percha y protección nocturna', 'Grano, forraje, insectos y ración de mantenimiento'],
  ['aves', 'mediana', 'faisan_dorado', 'Faisán Dorado', 'Asia', '1-1,5 kg (faena)', '3-5 años', 'Territorial, cauteloso y colorido', 'Ave de caza criada en granja para carne premium', 'Aviarios amplios con refugio y control de estrés', 'Ración de faisán 20-24% proteína y forraje']
].freeze

PRODUCTION_METADATA_BATCH5 = {
  'pollo_broiler_ross' => ['Carne', 'Engorde intensivo en galpón', 'FCR 1,5-1,8; faena 2-2,5 kg a las 6-7 semanas'],
  'pollo_cobb500' => ['Carne', 'Engorde intensivo comercial', 'FCR 1,45-1,75; alto rendimiento de pechuga'],
  'pollo_red_ranger' => ['Carne campera', 'Semiextensivo o label rouge', 'Faena 2-2,5 kg a las 10-12 semanas; carne amarilla'],
  'brahma' => ['Carne y huevos', 'Granja familiar o traspatio', 'Carne de caldero; 150-180 huevos/año'],
  'wyandotte' => ['Huevos y carne', 'Campero y granja', '200-240 huevos/año; buena carne de consumo'],
  'gallina_criolla' => ['Huevos y carne', 'Traspatio y producción familiar', '180-220 huevos/año; carne de sabor tradicional'],
  'ameraucana' => ['Huevos', 'Campero y mercado gourmet', '200-250 huevos azules/año'],
  'pato_mulard' => ['Carne y foie', 'Engorde intensivo o semiintensivo', 'Peso faena 4-5 kg; hígado graso para foie gras'],
  'pato_aylesbury' => ['Carne', 'Granja tradicional', 'Faena 4-5 kg; carne blanca tierna'],
  'ganso_toulouse' => ['Carne y grasa', 'Pastoreo con engorde final', 'Peso adulto 7-12 kg; carne y foie de calidad'],
  'ganso_chino' => ['Carne y huevos', 'Pastoreo y granja familiar', '40-60 huevos/año; carne magra de granja'],
  'pavo_bourbon_red' => ['Carne', 'Granja semiextensiva', 'Machos 10-14 kg a faena; carne de sabor intenso'],
  'pavo_narragansett' => ['Carne', 'Granja familiar o pastoreo', 'Machos 9-12 kg a faena; buena habilidad maternal'],
  'codorniz_japonesa' => ['Huevos y carne', 'Avicultura intensiva o semiintensiva', '250-300 huevos/año; faena 120-150 g a las 6-8 semanas'],
  'pintada' => ['Carne y huevos', 'Corral forrajero', '100-150 huevos/año; carne magra de alto valor'],
  'faisan_dorado' => ['Carne', 'Avicultura de caza o granja', 'Faena 1-1,2 kg; carne premium de restaurante']
}.freeze

PRODUCTION_BREED_EXTRA_BATCH5 = PRODUCTION_BREEDS_BATCH5.each_with_object({}) do |row, result|
  animal_id, _size, id, name, origin, weight, lifespan, temperament, description, care, feeding = row
  product, system, performance = PRODUCTION_METADATA_BATCH5.fetch(id)
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
    fuentes_produccion: ['FAO Domestic Animal Diversity Information System (DAD-IS)', 'Oklahoma State University — Breeds of Livestock', 'Manual Merck Veterinario — Producción Avícola']
  }
end.freeze
