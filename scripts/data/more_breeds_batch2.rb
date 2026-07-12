# frozen_string_literal: true
# Segundo lote de razas populares que faltaban en la enciclopedia

MORE_BREEDS = [
  # PERROS pequeña
  ['perros', 'pequena', 'pug', 'Pug', 'China', '6-8 kg', '12-15 años', 'Cariñoso, juguetón y sociable', 'Perro braquicéfalo de arrugas y hocico chato', 'Control de peso, limpieza de pliegues faciales, evitar calor', 'Pienso para razas pequeñas, raciones medidas'],
  ['perros', 'pequena', 'dachshund', 'Dachshund (Teckel)', 'Alemania', '7-15 kg', '12-16 años', 'Valiente, curioso y tenaz', 'Perro salchicha de patas cortas y cuerpo alargado', 'Evitar saltos y obesidad, protección de columna', 'Pienso para razas pequeñas, control de peso estricto'],
  ['perros', 'pequena', 'boston_terrier', 'Boston Terrier', 'EE.UU.', '4-11 kg', '11-15 años', 'Amigable, alerta y equilibrado', 'Terrier compacto de hocico corto y marcas tuxedo', 'Ejercicio moderado, protección térmica en verano', 'Pienso de calidad, premios limitados'],
  ['perros', 'pequena', 'pekines', 'Pekinés', 'China', '3-6 kg', '12-15 años', 'Independiente, leal y digno', 'Perro de compañía imperial de pelaje largo', 'Cepillado diario, evitar sobrecalentamiento', 'Pienso pequeño, heno dental, agua fresca'],
  ['perros', 'pequena', 'west_highland', 'West Highland White Terrier', 'Escocia', '6-10 kg', '12-16 años', 'Alegre, seguro y activo', 'Terrier blanco de pelo duro y orejas erguidas', 'Peluquería regular, revisión de piel y orejas', 'Pienso para terriers, suplemento omega si piel seca'],
  ['perros', 'pequena', 'schnauzer_miniatura', 'Schnauzer Miniatura', 'Alemania', '5-9 kg', '12-15 años', 'Inteligente, alerta y vivaz', 'Terrier alemán de barba y cejas marcadas', 'Corte de pelo cada 6-8 semanas, ejercicio diario', 'Pienso para razas pequeñas activas'],
  # PERROS mediana
  ['perros', 'mediana', 'dalmatian', 'Dálmata', 'Croacia', '23-32 kg', '10-13 años', 'Enérgico, amigable y elegante', 'Perro manchado blanco y negro de gran resistencia', 'Ejercicio intenso diario, hidratación en calor', 'Pienso alto en proteína, control de purinas si urato'],
  ['perros', 'mediana', 'australian_shepherd', 'Pastor Australiano', 'EE.UU.', '16-32 kg', '12-15 años', 'Inteligente, trabajador y leal', 'Pastor de ojos claros y manto merle o tricolor', 'Estimulación mental y física intensa', 'Pienso para perros activos, suplemento articular si necesario'],
  ['perros', 'mediana', 'corgi_gales', 'Corgi Galés de Pembroke', 'Gales', '10-14 kg', '12-15 años', 'Alerta, afectuoso y juguetón', 'Pastor bajo de patas cortas y orejas erguidas', 'Control de peso, protección de espalda', 'Pienso medido, evitar sobrepeso'],
  ['perros', 'mediana', 'weimaraner', 'Weimaraner', 'Alemania', '25-40 kg', '10-13 años', 'Energético, obediente y afectuoso', 'Braco gris de caza versátil y gran resistencia', 'Ejercicio prolongado, socialización temprana', 'Pienso de alto rendimiento, agua abundante'],
  ['perros', 'mediana', 'bull_terrier', 'Bull Terrier', 'Inglaterra', '22-38 kg', '10-14 años', 'Travieso, valiente y afectuoso', 'Terrier de cabeza ovalada y cuerpo musculoso', 'Entrenamiento positivo, ejercicio vigoroso', 'Pienso para razas musculosas, control de alergias'],
  ['perros', 'mediana', 'vizsla', 'Vizsla', 'Hungría', '20-30 kg', '12-14 años', 'Cariñoso, activo y sensible', 'Braco húngaro de pelaje dorado rojizo', 'Ejercicio diario intenso, compañía cercana', 'Pienso de caza o alto rendimiento'],
  ['perros', 'mediana', 'springer_spaniel', 'Springer Spaniel Inglés', 'Inglaterra', '20-25 kg', '12-14 años', 'Amigable, obediente y enérgico', 'Spaniel de caza de orejas largas y manto ondulado', 'Ejercicio y cepillado regular, revisión de orejas', 'Pienso para perros activos, control de peso'],
  # PERROS grande
  ['perros', 'grande', 'akita_inu', 'Akita Inu', 'Japón', '32-59 kg', '10-12 años', 'Digno, leal y reservado', 'Spitz japonés grande de pelaje denso', 'Socialización temprana, espacio amplio', 'Pienso de calidad, porciones según actividad'],
  ['perros', 'grande', 'bernese', 'Boyero de Berna', 'Suiza', '36-50 kg', '7-10 años', 'Tranquilo, afectuoso y trabajador', 'Boyero tricolor de pelaje largo y gran tamaño', 'Ejercicio moderado, cepillado frecuente', 'Pienso para razas grandes, suplemento articular'],
  ['perros', 'grande', 'newfoundland', 'Terranova', 'Canadá', '45-70 kg', '8-10 años', 'Dulce, paciente y protector', 'Perro de agua gigante de pelaje denso negro o marrón', 'Nado supervisado, cepillado, evitar calor', 'Pienso para razas gigantes, control de peso'],
  ['perros', 'grande', 'mastiff_ingles', 'Mastín Inglés', 'Inglaterra', '54-100 kg', '6-10 años', 'Calmado, digno y protector', 'Moloso gigante de cabeza masiva y temperamento sereno', 'Espacio amplio, ejercicio ligero, cuidado articular', 'Pienso para razas gigantes, raciones fraccionadas'],
  ['perros', 'grande', 'irish_setter', 'Setter Irlandés', 'Irlanda', '27-32 kg', '12-15 años', 'Enérgico, amigable y elegante', 'Perro de caza de pelaje rojo castaño sedoso', 'Ejercicio intenso diario, cepillado regular', 'Pienso alto en energía, agua siempre disponible'],
  ['perros', 'grande', 'gran_perro_montana', 'Gran Perro de Montaña Suizo', 'Suiza', '50-70 kg', '8-11 años', 'Confiado, vigilante y afectuoso', 'Boyero tricolor grande de trabajo y guarda', 'Ejercicio moderado, cepillado, socialización', 'Pienso para razas grandes de trabajo'],
  # GATOS pequeña
  ['gatos', 'pequena', 'sphynx', 'Sphynx', 'Canadá', '3-5,5 kg', '12-15 años', 'Extrovertido, cariñoso y curioso', 'Gato sin pelo de piel arrugada y gran metabolismo', 'Baños regulares, protección del frío y sol', 'Dieta alta en calorías, agua abundante'],
  ['gatos', 'pequena', 'cornish_rex', 'Cornish Rex', 'Inglaterra', '2,5-4,5 kg', '12-15 años', 'Activo, juguetón y sociable', 'Gato de pelaje rizado corto y cuerpo esbelto', 'Ambiente cálido, juego diario', 'Pienso de calidad, raciones frecuentes'],
  ['gatos', 'pequena', 'manx', 'Manx', 'Isla de Man', '3-5,5 kg', '12-14 años', 'Inteligente, leal y tranquilo', 'Gato sin cola o rabo corto de cuerpo redondeado', 'Control de peso, ejercicio moderado', 'Pienso felino equilibrado, control de estreñimiento'],
  ['gatos', 'pequena', 'tonkinese', 'Tonkinesa', 'Canadá/EE.UU.', '2,5-5,5 kg', '12-16 años', 'Sociable, vocal y activa', 'Cruce de siamesa y birmana de ojos azul verdosos', 'Compañía humana, juguetes interactivos', 'Pienso felino premium, agua fresca'],
  # GATOS mediana
  ['gatos', 'mediana', 'scottish_fold', 'Scottish Fold', 'Escocia', '3-6 kg', '11-14 años', 'Dulce, tranquilo y adaptable', 'Gato de orejas plegadas y rostro redondeado', 'Revisión articular, cepillado regular', 'Pienso para control de peso si sedentario'],
  ['gatos', 'mediana', 'russian_blue', 'Azul Ruso', 'Rusia', '3-5,5 kg', '15-20 años', 'Reservado, elegante y afectuoso', 'Gato de pelaje azul plateado y ojos verdes', 'Ambiente tranquilo, cepillado semanal', 'Pienso de alta digestibilidad'],
  ['gatos', 'mediana', 'oriental', 'Oriental de Pelo Corto', 'Tailandia/EE.UU.', '3-5 kg', '12-15 años', 'Vocal, activo y muy social', 'Gato esbelto de gran variedad de colores', 'Estimulación mental, compañía', 'Pienso alto en proteína, raciones medidas'],
  ['gatos', 'mediana', 'bombay', 'Bombay', 'EE.UU.', '3-5,5 kg', '12-16 años', 'Cariñoso, curioso y juguetón', 'Gato negro brillante de aspecto pantera miniatura', 'Juego diario, cepillado suave', 'Pienso felino de calidad'],
  ['gatos', 'mediana', 'american_shorthair', 'American Shorthair', 'EE.UU.', '4-6 kg', '15-20 años', 'Equilibrado, adaptable y saludable', 'Gato robusto de pelo corto y gran longevidad', 'Cepillado semanal, control de peso', 'Pienso felino estándar, agua fresca'],
  ['gatos', 'mediana', 'balinese', 'Balinesa', 'EE.UU.', '3-5 kg', '12-16 años', 'Elegante, vocal y afectuosa', 'Variación de pelo largo del siames colorpoint', 'Cepillado frecuente, enriquecimiento', 'Pienso felino, control de bolas de pelo'],
  ['gatos', 'mediana', 'birman', 'Birmana', 'Birmania/Francia', '3-6 kg', '12-16 años', 'Dulce, tranquila y sociable', 'Gata sagrada de guantes blancos y ojos azules', 'Cepillado regular, compañía', 'Pienso de calidad, cepillado y malt'],
  ['gatos', 'mediana', 'chartreux', 'Chartreux', 'Francia', '4-7 kg', '12-15 años', 'Tranquilo, inteligente y observador', 'Gato francés de pelaje azul grisáceo y ojos cobrizos', 'Cepillado semanal, juego moderado', 'Pienso felino, control de peso'],
  # GATOS grande
  ['gatos', 'grande', 'norwegian_forest', 'Bosque de Noruega (línea grande)', 'Noruega', '5-9 kg', '14-16 años', 'Independiente, amigable y resistente', 'Gato nórdico de triple manto y gran tamaño', 'Cepillado en muda, rascador alto', 'Pienso alto en proteína, agua abundante'],
  ['gatos', 'grande', 'turkish_van', 'Van Turco', 'Turquía', '5-8 kg', '12-17 años', 'Activo, inteligente y acuático', 'Gato semilargo blanco con marcas color en cabeza y cola', 'Acceso a agua para juego, cepillado', 'Pienso felino activo'],
  # AVES pequeña
  ['aves', 'pequena', 'kakariki', 'Kakariki', 'Nueva Zelanda', '50-70 g', '8-12 años', 'Activo, curioso y ruidoso', 'Psitácido verde de frente roja y vuelo rápido', 'Jaula amplia, frutas y verduras frescas', 'Mezcla de semillas, pellets, verduras diarias'],
  ['aves', 'pequena', 'rosella', 'Rosella', 'Australia', '90-120 g', '15-20 años', 'Activa, inteligente y territorial', 'Perico australiano de colores vivos en plumaje', 'Vuelo diario, enriquecimiento, socialización', 'Pellets, semillas, frutas y verduras'],
  # AVES mediana
  ['aves', 'mediana', 'caique', 'Caique', 'Sudamérica', '140-170 g', '25-30 años', 'Juguetón, travieso y enérgico', 'Loro pequeño de gran personalidad y colorido', 'Juguetes destructivos, baños, vuelo', 'Pellets, frutas tropicales, semillas con moderación'],
  ['aves', 'mediana', 'pionus', 'Pionus', 'Sudamérica', '200-280 g', '25-35 años', 'Tranquilo, cariñoso y menos ruidoso', 'Loro mediano de plumaje verde con matices', 'Jaula espaciosa, baños regulares', 'Pellets, frutas, verduras, semillas limitadas'],
  ['aves', 'mediana', 'conure', 'Aratinga (Conure)', 'Sudamérica', '80-120 g', '20-25 años', 'Sociable, ruidosa y afectuosa', 'Perico mediano de cola larga y gran vínculo', 'Tiempo fuera de jaula, juguetes, socialización', 'Pellets, frutas, verduras, semillas'],
  ['aves', 'mediana', 'lorikeet', 'Lori (Lorikeet)', 'Australia/Pacífico', '80-150 g', '15-25 años', 'Activo, juguetón y nectarívoro', 'Loro de lengua cepillada alimentado con néctar', 'Dieta líquida especial, higiene de jaula', 'Néctar comercial, frutas, polen'],
  # AVES grande
  ['aves', 'grande', 'cacatua_umbrella', 'Cacatúa Paraguas', 'Indonesia', '500-700 g', '40-60 años', 'Afectuosa, demandante y vocal', 'Cacatúa blanca de cresta amarilla desplegable', 'Atención diaria, juguetes duros, vuelo', 'Pellets, frutas, verduras, frutos secos moderados'],
  # EQUINOS pequeña
  ['equinos', 'pequena', 'miniatura_americana', 'Miniatura Americana', 'EE.UU.', '70-90 kg', '25-35 años', 'Inteligente, dócil y sociable', 'Caballo miniatura de menos de 86 cm', 'Control de obesidad, cuidado dental, refugio', 'Heno de calidad, ración mínima de concentrado'],
  # EQUINOS mediana
  ['equinos', 'mediana', 'appaloosa', 'Appaloosa', 'EE.UU.', '430-570 kg', '25-30 años', 'Versátil, inteligente y resistente', 'Caballo manchado de origen nez percé', 'Ejercicio regular, cuidado de cascos', 'Heno, concentrado según trabajo, agua limpia'],
  ['equinos', 'mediana', 'lipizzano', 'Lipizzano', 'España/Austria', '400-500 kg', '25-30 años', 'Elegante, obediente y atlético', 'Caballo barroco blanco de la Escuela Española', 'Entrenamiento progresivo, herraje regular', 'Heno de calidad, concentrado moderado'],
  ['equinos', 'mediana', 'criollo_argentino', 'Criollo Argentino', 'Argentina', '400-500 kg', '25-30 años', 'Resistente, dócil y frugal', 'Caballo criollo de gran adaptación al campo', 'Pastoreo, herraje, desparasitación', 'Pasto natural, suplemento en invierno'],
  # EQUINOS grande
  ['equinos', 'grande', 'percheron', 'Percherón', 'Francia', '800-1200 kg', '20-25 años', 'Fuerte, tranquilo y trabajador', 'Caballo de tiro pesado de pelaje gris o negro', 'Espacio amplio, cuidado de cascos y espalda', 'Heno abundante, concentrado según carga'],
  ['equinos', 'grande', 'clydesdale', 'Clydesdale', 'Escocia', '800-1000 kg', '20-25 años', 'Gentil, fuerte y llamativo', 'Caballo de tiro con plumas en cascos', 'Herraje frecuente, cepillado de plumas', 'Heno de calidad, concentrado moderado'],
  # BOVINOS pequeña
  ['bovinos', 'pequena', 'lowline_angus', 'Lowline Angus', 'Australia', '300-450 kg', '15-20 años', 'Tranquilo, compacto y eficiente', 'Línea miniatura de Angus para carne en pastoreo', 'Manejo en pastoreo, sombra en verano', 'Pasto, heno, suplemento mineral'],
  # BOVINOS mediana
  ['bovinos', 'mediana', 'galloway', 'Galloway', 'Escocia', '450-600 kg', '15-20 años', 'Rustico, dócil y resistente al frío', 'Raza escocesa de pelo largo rizado sin joroba', 'Pastoreo extensivo, refugio en nieve', 'Pasto, heno en invierno, sal mineral'],
  ['bovinos', 'mediana', 'shorthorn', 'Shorthorn', 'Inglaterra', '550-800 kg', '15-20 años', 'Dócil, dual propósito y precoz', 'Raza británica roja, blanca o rojiblanca', 'Manejo en corral o pastoreo, ordeño si lechera', 'Pasto, concentrado según producción'],
  ['bovinos', 'mediana', 'piedmontese', 'Piamontesa', 'Italia', '500-700 kg', '15-18 años', 'Tranquila, musculosa y eficiente', 'Raza italiana de carne magra por gen miostatin', 'Manejo tranquilo, buenas instalaciones', 'Pasto de calidad, suplemento en engorde'],
  # BOVINOS grande
  ['bovinos', 'grande', 'highland', 'Highland', 'Escocia', '400-600 kg', '15-20 años', 'Dócil, resistente y pintoresca', 'Vaca escocesa de largos cuernos y pelaje lanoso', 'Pastoreo en terreno variado, refugio', 'Pasto, heno, bloques minerales'],
  ['bovinos', 'grande', 'nelore', 'Nelore', 'India/Brasil', '450-600 kg', '15-20 años', 'Resistente, adaptada al calor y frugal', 'Cebú blanco de gran adaptación tropical', 'Sombra y agua en calor, manejo en pastoreo', 'Pasto tropical, suplemento en sequía'],
  # PORCINOS pequeña
  ['porcinos', 'pequena', 'kunekune', 'Kunekune', 'Nueva Zelanda', '60-100 kg', '12-15 años', 'Dócil, sociable y pastoreo', 'Cerdo miniatura de hocico corto y sin joroba', 'Pastoreo con refugio, control de peso', 'Pasto, pienso complementario, agua'],
  # PORCINOS mediana
  ['porcinos', 'mediana', 'berkshire', 'Berkshire', 'Inglaterra', '220-280 kg', '10-12 años', 'Dócil, activo y de carne premium', 'Cerdo negro con puntas blancas de carne marmolada', 'Instalaciones limpias, bienestar térmico', 'Pienso balanceado, agua abundante'],
  ['porcinos', 'mediana', 'tamworth', 'Tamworth', 'Inglaterra', '230-300 kg', '10-12 años', 'Activo, resistente y rústico', 'Cerdo pelirrojo de orejas erguidas para pastoreo', 'Acceso a pasto y barro, sombra', 'Pasto, pienso, agua limpia'],
  # PORCINOS grande
  ['porcinos', 'grande', 'mangalica', 'Mangalica', 'Hungría', '250-350 kg', '12-15 años', 'Tranquilo, resistente al frío y lanudo', 'Cerdo rizado de grasa infiltrada tipo cordero', 'Pastoreo en clima frío, refugio', 'Pasto, bellotas si disponible, pienso'],
  # CONEJOS pequeña
  ['conejos', 'pequena', 'lionhead', 'Lionhead', 'Bélgica/EE.UU.', '1-1,7 kg', '7-10 años', 'Amigable, curioso y juguetón', 'Conejo de melena alrededor de la cabeza', 'Cepillado de melena, heno libre', 'Heno, pellets, verduras frescas moderadas'],
  ['conejos', 'pequena', 'mini_lop', 'Mini Lop', 'Alemania', '1,5-2,5 kg', '7-12 años', 'Dócil, cariñoso y tranquilo', 'Conejo enano de orejas caídas compactas', 'Cepillado, espacio para saltar, heno', 'Heno libre, pellets medidos, verduras'],
  # CONEJOS mediana
  ['conejos', 'mediana', 'harlequin', 'Harlequin', 'Francia', '2-3 kg', '7-10 años', 'Activo, sociable y llamativo', 'Conejo de pelaje bicolor en patrones', 'Ejercicio diario, cepillado, heno', 'Heno, pellets, verduras variadas'],
  ['conejos', 'mediana', 'english_spot', 'English Spot', 'Inglaterra', '2,5-3,5 kg', '7-10 años', 'Activo, amigable y elegante', 'Conejo manchado con línea dorsal y marcas faciales', 'Espacio amplio, heno, juguetes', 'Heno libre, pellets, verduras'],
  ['conejos', 'mediana', 'silver_fox', 'Silver Fox', 'EE.UU.', '3-4,5 kg', '7-10 años', 'Tranquilo, dócil y de pelaje único', 'Conejo de pelaje plateado que resiste al revés', 'Cepillado semanal, heno, refugio', 'Heno, pellets, verduras frescas'],
  # REPTILES pequeña
  ['reptiles', 'pequena', 'crested_gecko', 'Gecko Crestado', 'Nueva Caledonia', '35-55 g', '15-20 años', 'Nocturno, tranquilo y arborícola', 'Gecko con cresta y cola prensil sin regenerar', 'Terrario vertical, humedad 60-80%, temperatura 22-26 °C', 'Dieta comercial crested, fruta, insectos'],
  ['reptiles', 'pequena', 'leopard_gecko_extra', 'Gecko Leopardo (línea show)', 'Asia Central', '50-80 g', '15-20 años', 'Tranquilo, dócil y crepuscular', 'Gecko terrestre de cola grasa y patrones variados', 'Terrario cálido 26-32 °C, escondite húmedo', 'Insectos gut-loaded, calcio, agua'],
  # REPTILES mediana
  ['reptiles', 'mediana', 'boa_constrictor', 'Boa Constrictor', 'América Central/Sur', '10-15 kg', '20-30 años', 'Tranquila, fuerte y nocturna', 'Serpiente constrictora de gran tamaño moderado', 'Terrario amplio, calor 28-32 °C, humedad', 'Roedores de tamaño apropiado, agua'],
  ['reptiles', 'mediana', 'tortuga_rusa', 'Tortuga Rusa (Horsfieldii)', 'Asia Central', '400-800 g', '40-50 años', 'Activa, resistente y herbívora', 'Tortuga terrestre de caparazón bajo y redondeado', 'Terrario seco con zona cálida, UVB', 'Verduras, heno, flores comestibles, calcio'],
  ['reptiles', 'mediana', 'blue_tongue_skink', 'Lagarto de Lengua Azul', 'Australia/Indonesia', '300-500 g', '15-20 años', 'Dócil, curioso y diurno', 'Escinco terrestre de lengua azul y cuerpo robusto', 'Terrario amplio, 26-32 °C, sustrato', 'Insectos, verduras, fruta, pienso monitor'],
  ['reptiles', 'mediana', 'california_kingsnake', 'Culebra Real de California', 'EE.UU.', '400-900 g', '15-20 años', 'Activa, resistente y fácil manejo', 'Serpiente terrestre de bandas blancas y negras', 'Terrario con escondites, 24-28 °C', 'Roedores pequeños, agua'],
  # REPTILES grande
  ['reptiles', 'grande', 'uromastyx', 'Uromastyx', 'África/Oriente Medio', '400-900 g', '15-20 años', 'Diurna, herbívora y territorial', 'Lagarto de cola espinosa adaptado al desierto', 'Terrario muy cálido 35-40 °C, UVB intenso', 'Verduras de hoja, semillas, calcio'],
  ['reptiles', 'grande', 'tegu_argentino', 'Tegú Argentino', 'Argentina', '8-15 kg', '15-20 años', 'Inteligente, curioso y omnívoro', 'Lagarto grande de cuerpo negro y blanco juvenil', 'Terrario enorme o exterior climatizado, 28-32 °C', 'Insectos, huevo, fruta, roedor ocasional'],
  # PECES pequeña
  ['peces', 'pequena', 'cherry_barb', 'Barbo Cereza', 'Sri Lanka', '2-5 g', '4-6 años', 'Pacífico, escolar y colorido', 'Pez tropical rojo de acuario comunitario', 'Acuario plantado 40 L+, parámetros estables', 'Flocos, microgránulos, alimento vivo ocasional'],
  ['peces', 'pequena', 'ember_tetra', 'Tetra Ember', 'Brasil', '1-2 g', '2-4 años', 'Pacífico, escolar y diminuto', 'Tetra naranja fuego de acuario nano', 'Acuario 20 L+, agua ácida suave', 'Microgránulos, artemia, daphnia'],
  # PECES mediana
  ['peces', 'mediana', 'molly', 'Molly', 'Centroamérica', '15-30 g', '3-5 años', 'Activo, adaptable y vivíparo', 'Pez vivo de agua dulce o salobre', 'Acuario 60 L+, sal moderada si se desea', 'Flocos, algas, verduras hervidas'],
  ['peces', 'mediana', 'swordtail', 'Espada (Swordtail)', 'Centroamérica', '15-40 g', '3-5 años', 'Activo, pacífico y vivíparo', 'Pez con prolongación caudal en machos', 'Acuario 80 L+, plantas, flujo moderado', 'Flocos variados, algas, artemia'],
  ['peces', 'mediana', 'corydoras', 'Corydoras', 'Sudamérica', '20-40 g', '5-10 años', 'Pacífico, gregario y bentónico', 'Pez gato armado de fondo en cardumen', 'Acuario con sustrato de arena, grupo 6+', 'Tabletas de fondo, larvas, restos controlados'],
  ['peces', 'mediana', 'gourami_perla', 'Gourami Perla', 'Asia', '15-25 g', '4-6 años', 'Tranquilo, laberíntico y territorial', 'Pez de laberinto de puntos perlados', 'Acuario plantado, superficie tranquila', 'Flocos, artemia, daphnia'],
  # PECES grande
  ['peces', 'grande', 'plecostomus', 'Plecostomus', 'Sudamérica', '200-500 g', '10-15 años', 'Nocturno, limpiador y territorial', 'Pez gato de ventosas y gran tamaño adulto', 'Acuario 200 L+, madera, refugios', 'Tabletas de alga, verduras, madera'],
  ['peces', 'grande', 'flowerhorn', 'Flowerhorn', 'Asia (híbrido)', '300-600 g', '8-12 años', 'Territorial, inteligente y llamativo', 'Cíclido híbrido de joroba y colores vivos', 'Acuario 200 L+ individual o pareja', 'Pellets cíclidos, gusanos, krill'],
  # OVINOS pequeña
  ['ovinos', 'pequena', 'babydoll_southdown', 'Southdown Miniatura', 'Inglaterra', '30-45 kg', '12-15 años', 'Dócil, compacto y cariñoso', 'Oveja miniatura de lana corta y cara oscura', 'Pastoreo, refugio, esquila anual', 'Pasto, heno, suplemento mineral'],
  # OVINOS mediana
  ['ovinos', 'mediana', 'icelandic', 'Islandesa', 'Islandia', '60-90 kg', '12-15 años', 'Resistente, prolífica y rústica', 'Oveja nórdica de múltiples cuernos y lana doble', 'Pastoreo en clima frío, esquila', 'Pasto, heno, sal mineral'],
  ['ovinos', 'mediana', 'barbados_blackbelly', 'Barbados Blackbelly', 'Caribe', '40-60 kg', '10-12 años', 'Resistente al calor, prolífica y sin lana', 'Oveja pelo de vientre negro y carne magra', 'Pastoreo tropical, sombra, agua', 'Pasto, suplemento en sequía'],
  ['ovinos', 'mediana', 'katahdin', 'Katahdin', 'EE.UU.', '55-80 kg', '10-12 años', 'Resistente, sin esquila y prolífica', 'Oveja de pelo adaptada a parásitos', 'Pastoreo, FAMACHA, refugio', 'Pasto, heno, mineral'],
  # OVINOS grande
  ['ovinos', 'grande', 'leicester', 'Leicester', 'Inglaterra', '100-150 kg', '10-12 años', 'Tranquila, de lana larga y maternal', 'Oveja británica de lana larga y cuerpo masivo', 'Esquila, pastoreo, refugio', 'Pasto de calidad, heno, concentrado en lactación'],
  # CAPRINOS pequeña
  ['caprinos', 'pequena', 'nigerian_dwarf', 'Nigerian Dwarf', 'África Occidental/EE.UU.', '25-35 kg', '10-12 años', 'Dócil, juguetona y lechera mini', 'Cabra enana de gran producción relativa', 'Ordeño, refugio, control de parásitos', 'Pasto, concentrado lácteo, agua'],
  # CAPRINOS mediana
  ['caprinos', 'mediana', 'toggenburg', 'Toggenburg', 'Suiza', '55-75 kg', '10-12 años', 'Activa, lechera y resistente', 'Cabra lechera parda con líneas blancas', 'Ordeño, pastoreo, refugio', 'Pasto, concentrado, heno'],
  ['caprinos', 'mediana', 'la_mancha', 'La Mancha', 'EE.UU.', '50-70 kg', '10-12 años', 'Tranquila, lechera y dócil', 'Cabra casi sin orejas externas de alta producción', 'Ordeño, sombra, control de mastitis', 'Pasto, concentrado lácteo'],
  ['caprinos', 'mediana', 'kiko', 'Kiko', 'Nueva Zelanda', '60-90 kg', '10-12 años', 'Rústica, materna y de carne', 'Cabra de carne resistente a parásitos', 'Pastoreo extensivo, refugio', 'Pasto, suplemento en invierno'],
  # CAPRINOS grande
  ['caprinos', 'grande', 'myotonic_goat', 'Cabra Tennessee (Fainting)', 'EE.UU.', '50-80 kg', '10-12 años', 'Curiosa, rústica y muscular', 'Cabra que se tensa ante sustos sin dolor', 'Pastoreo con refugio, vallas seguras', 'Pasto, heno, mineral'],
  # CAMELIDOS mediana
  ['camelidos', 'mediana', 'suri_alpaca', 'Alpaca Suri', 'Perú', '55-80 kg', '15-20 años', 'Dócil, elegante y de fibra larga', 'Alpaca de fibra en ringlets brillantes', 'Esquileo anual, protección del calor', 'Pasto, heno, suplemento mineral'],
  # CAMELIDOS grande
  ['camelidos', 'grande', 'dromedario', 'Dromedario', 'Oriente Medio/África', '400-600 kg', '25-40 años', 'Resistente, independiente y fuerte', 'Camélido de una joroba adaptado al desierto', 'Espacio amplio, sombra, agua regular', 'Pasto, heno, concentrado ocasional'],
  # ROEDORES pequeña
  ['roedores', 'pequena', 'roborovski', 'Hamster Roborovski', 'Asia Central', '20-30 g', '2-3 años', 'Rápido, tímido y social en grupo', 'Hamster enano del desierto muy activo', 'Jaula con sustrato profundo, rueda segura', 'Mezcla de hamster, semillas, insectos secos'],
  ['roedores', 'pequena', 'campbell_hamster', 'Hamster Campbell', 'Asia', '30-50 g', '1,5-2,5 años', 'Activo, territorial y sociable en parejas', 'Hamster enano de línea dorsal oscura', 'Jaula espaciosa, temperatura fresca', 'Mezcla enana, verduras, proteína'],
  # ROEDORES mediana
  ['roedores', 'mediana', 'hamster_sirio', 'Hamster Sirio (Dorado)', 'Siria', '100-200 g', '2-3 años', 'Solitario, territorial y nocturno', 'Hamster clásico de mejillas y pelaje dorado', 'Jaula amplia individual, rueda grande', 'Mezcla siria, verduras, insectos'],
  ['roedores', 'mediana', 'jerbo_egipcio', 'Jerbo Egipcio', 'Egipto', '40-60 g', '5-7 años', 'Activo, saltador y nocturno', 'Roedor de patas largas del desierto', 'Jaula con sustrato para cavar, sin rueda', 'Mezcla de jerbo, semillas, insectos'],
  # ROEDORES grande
  ['roedores', 'grande', 'mara_patagonica', 'Mara Patagónica', 'Argentina', '8-16 kg', '12-14 años', 'Social, rápida y monógama', 'Roedor grande parecido a liebre de patas largas', 'Espacio exterior amplio, pareja, refugio', 'Heno, pasto, verduras, pellets']
].freeze

MORE_BREED_EXTRA = {
  'pug' => { historia: 'Originario de China, perro de la nobleza imperial. Llegó a Europa con comerciantes holandeses en el siglo XVI.', caracteristicas: 'Cuerpo compacto cuadrado, hocico chato braquicéfalo, arrugas faciales. Colores leonado y negro. Peso 6-8 kg.', aptitudes: 'Compañía urbana, perro de terapia, exposición.', altura: '25-33 cm a la cruz', emergencias: 'BOAS, golpe de calor, prolapso ocular, epilepsia y obesidad.' },
  'sphynx' => { historia: 'Mutación natural en Minnesota (1966). Desarrollada como raza en Canadá con selección de pelo mínimo.', caracteristicas: 'Piel expuesta con vello fino, orejas grandes, metabolismo acelerado. Peso 3-5,5 kg.', aptitudes: 'Compañía intensa, exposición, mascota de interior con calefacción.', altura: '20-25 cm a la cruz', emergencias: 'Hipotermia, quemaduras solares, problemas cardíacos (HCM) y dermatitis.' },
  'akita_inu' => { historia: 'Raza nacional de Japón, símbolo de lealtad (Hachiko). Originalmente perro de caza mayor y guarda.', caracteristicas: 'Spitz grande de pelaje doble, cola enroscada, orejas erguidas. Colores variados. Peso 32-59 kg.', aptitudes: 'Guarda, compañía con dueño experimentado, exposición.', altura: '61-71 cm a la cruz', emergencias: 'Torsión gástrica, displasia, agresión por dolor y enfermedad de Sebaceous adenitis.' },
  'dromedario' => { historia: 'Domesticado hace más de 3000 años en Arabia. Animal de carga, leche y carne en zonas áridas.', caracteristicas: 'Una joroba, labio superior hendido, pestañas largas. Peso 400-600 kg.', aptitudes: 'Transporte, producción de leche, turismo, carrera.', altura: '180-210 cm a la cruz', emergencias: 'Golpe de calor, tétanos, parásitos internos y parto distócico.' }
}.freeze
