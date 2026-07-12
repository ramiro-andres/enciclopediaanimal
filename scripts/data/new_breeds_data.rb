# frozen_string_literal: true

# Definiciones de nuevas razas: [animal_id, tamano, id, nombre, origen, peso, esperanza_vida, temperamento, descripcion_corta, cuidados, alimentacion, enfermedades_nombres]
NEW_BREEDS = [
  # PERROS pequena
  ['perros', 'pequena', 'shih_tzu', 'Shih Tzu', 'China/Tíbet', '4-7 kg', '10-18 años', 'Afectuoso, juguetón y adaptable', 'Perro toy de pelo largo, originario de la corte imperial china', 'Cepillado diario del pelaje, limpieza facial de pliegues, higiene dental', 'Pienso para razas toy; evitar sobrealimentación'],
  ['perros', 'pequena', 'papillon', 'Papillon', 'Francia/Bélgica', '3-5 kg', '13-16 años', 'Inteligente, alerta y enérgico', 'Spaniel miniatura con orejas en forma de mariposa', 'Cepillado 2-3 veces/semana, ejercicio mental diario', 'Pienso premium pequeño; control de porciones'],
  ['perros', 'pequena', 'bichon_frances', 'Bichón Frisé', 'Francia', '3-5 kg', '12-15 años', 'Alegre, sociable y cariñoso', 'Perro de compañía blanco de pelo rizado', 'Peluquería profesional cada 4-6 semanas, cepillado diario', 'Pienso hipoalergénico; evitar alimentos grasos'],
  ['perros', 'pequena', 'pinscher_miniatura', 'Pinscher Miniatura', 'Alemania', '3-5 kg', '12-16 años', 'Valiente, alerta y enérgico', 'Versión miniatura del pinscher alemán', 'Ejercicio diario moderado, socialización temprana', 'Pienso para razas pequeñas activas'],
  # PERROS mediana
  ['perros', 'mediana', 'boxer', 'Boxer', 'Alemania', '25-32 kg', '10-12 años', 'Leal, juguetón y protector', 'Moloso atlético alemán, perro de trabajo y familia', 'Ejercicio intenso diario, protección solar en hocico', 'Pienso para razas activas medianas-grandes'],
  ['perros', 'mediana', 'shiba_inu', 'Shiba Inu', 'Japón', '8-11 kg', '12-15 años', 'Independiente, alerta y limpio', 'Raza japonesa primitiva de tamaño mediano', 'Cepillado frecuente en muda, socialización temprana', 'Pienso de calidad; control estricto de raciones'],
  ['perros', 'mediana', 'samoyedo', 'Samoyedo', 'Rusia', '20-30 kg', '12-14 años', 'Amigable, gentil y activo', 'Perro nórdico de pelaje blanco esponjoso', 'Cepillado diario en muda, ejercicio abundante', 'Pienso para razas activas de clima frío'],
  ['perros', 'mediana', 'pointer_ingles', 'Pointer Inglés', 'Inglaterra', '25-34 kg', '12-17 años', 'Enérgico, leal y dócil', 'Perro de caza señalador de aves', 'Ejercicio intenso diario, espacio amplio', 'Dieta alta en proteína para perros activos'],
  # PERROS grande
  ['perros', 'grande', 'rottweiler', 'Rottweiler', 'Alemania', '35-60 kg', '8-10 años', 'Confiado, valiente y leal', 'Moloso alemán de guardia y trabajo', 'Entrenamiento y socialización desde cachorro', 'Pienso para razas grandes; control de crecimiento en cachorros'],
  ['perros', 'grande', 'husky_siberiano', 'Husky Siberiano', 'Siberia', '20-27 kg', '12-14 años', 'Amigable, enérgico e independiente', 'Perro de trineo nórdico de gran resistencia', 'Ejercicio intenso, nunca afeitar el pelaje', 'Pienso para perros activos; evitar sobrecalentamiento'],
  ['perros', 'grande', 'san_bernardo', 'San Bernardo', 'Suiza', '54-82 kg', '8-10 años', 'Gentil, paciente y leal', 'Perro de rescate alpino de gran tamaño', 'Control de peso, limpieza de pliegues, ejercicio moderado', 'Pienso controlado para razas gigantes'],
  ['perros', 'grande', 'doberman', 'Doberman', 'Alemania', '32-45 kg', '10-13 años', 'Inteligente, alerta y leal', 'Perro de guardia y compañía elegante', 'Ejercicio diario, estimulación mental', 'Pienso premium para razas activas grandes'],
  # GATOS pequena
  ['gatos', 'pequena', 'devon_rex', 'Devon Rex', 'Inglaterra', '2,5-4 kg', '12-16 años', 'Juguetón, cariñoso y travieso', 'Gato de pelo rizado y orejas grandes', 'Piel sensible, baños ocasionales, ambiente cálido', 'Dieta rica en proteína de alta calidad'],
  ['gatos', 'pequena', 'munchkin', 'Munchkin', 'EE.UU.', '2-4 kg', '12-15 años', 'Sociable, activo y curioso', 'Gato de patas cortas por mutación natural', 'Evitar saltos excesivos, control de peso', 'Pienso felino equilibrado; evitar obesidad'],
  # GATOS mediana
  ['gatos', 'mediana', 'abisinio', 'Abisinio', 'Etiopía', '3-5 kg', '12-16 años', 'Activo, curioso e inteligente', 'Gato atigrado ticked de aspecto salvaje', 'Enriquecimiento ambiental, juego interactivo', 'Dieta alta en proteína animal'],
  ['gatos', 'mediana', 'siberiano', 'Siberiano', 'Rusia', '4-7 kg', '11-15 años', 'Afectuoso, inteligente y juguetón', 'Gato de bosque ruso de triple capa', 'Cepillado en muda, tolerante al frío', 'Pienso premium; posible alergenicidad reducida'],
  ['gatos', 'mediana', 'exotico', 'Exótico de Pelo Corto', 'EE.UU.', '3-6 kg', '12-15 años', 'Tranquilo, cariñoso y dócil', 'Versión de pelo corto del Persa', 'Limpieza facial de pliegues, cepillado semanal', 'Pienso para razas braquicéfalas'],
  ['gatos', 'mediana', 'burmes', 'Burmés', 'Birmania', '4-6 kg', '12-16 años', 'Sociable, vocal y cariñoso', 'Gato oriental de pelaje satinado', 'Compañía humana frecuente, juego diario', 'Dieta equilibrada; control de peso'],
  # GATOS grande
  ['gatos', 'grande', 'bosque_noruego', 'Bosque de Noruega', 'Noruega', '5-9 kg', '14-16 años', 'Tranquilo, independiente y cariñoso', 'Gato grande adaptado al clima nórdico', 'Cepillado frecuente, rascador alto', 'Dieta rica en proteína y omega-3'],
  ['gatos', 'grande', 'savannah', 'Savannah', 'EE.UU.', '5-11 kg', '12-17 años', 'Activo, curioso y leal', 'Híbrido de gato doméstico y serval', 'Espacio amplio, paseos con arnés posibles', 'Dieta alta en proteína; consultar normativa local'],
  # AVES pequena
  ['aves', 'pequena', 'diamante_mandarin', 'Diamante Mandarín', 'Australia', '10-15 g', '5-7 años', 'Sociable, activo y melodioso', 'Pinzón australiano muy popular en avicultura', 'Jaula amplia, pareja recomendada, baños regulares', 'Mezcla de semillas, mijo y verduras frescas'],
  ['aves', 'pequena', 'ninfa', 'Ninfa (Cockatiel)', 'Australia', '80-120 g', '15-20 años', 'Cariñosa, inteligente y vocal', 'Cacatúa en miniatura con cresta expresiva', 'Socialización diaria, juguetes, vuelo supervisado', 'Pellets, semillas limitadas, verduras y frutas'],
  ['aves', 'pequena', 'agapornis', 'Agapornis', 'África', '40-60 g', '10-15 años', 'Afectuoso, activo y social', 'Pájaro del amor que forma parejas fuertes', 'Pareja o atención diaria, jaula espaciosa', 'Mezcla de semillas, verduras y pellets'],
  # AVES mediana
  ['aves', 'mediana', 'amazonas_frente_amarilla', 'Amazonas Frente Amarilla', 'América Central', '400-600 g', '40-60 años', 'Inteligente, vocal y sociable', 'Loro amazónico de gran longevidad', 'Atención social intensa, enriquecimiento cognitivo', 'Pellets, frutas, verduras; limitar grasa'],
  ['aves', 'mediana', 'eclectus', 'Eclectus', 'Nueva Guinea', '400-550 g', '30-40 años', 'Tranquilo, inteligente y sensible', 'Loro con dimorfismo sexual marcado', 'Dieta específica baja en grasa, ambiente calmado', 'Frutas, verduras, pellets; evitar semillas grasas'],
  ['aves', 'mediana', 'cotorra_argentina', 'Cotorra Argentina', 'Sudamérica', '200-300 g', '20-30 años', 'Inteligente, ruidosa y social', 'Psitácida adaptada a ambientes urbanos', 'Socialización, vuelo diario, juguetes destructivos', 'Pellets, frutas y verduras frescas'],
  # AVES grande
  ['aves', 'grande', 'cacatua_molucca', 'Cacatúa de las Molucas', 'Indonesia', '850-1100 g', '40-60 años', 'Afectuosa, ruidosa y demandante', 'Gran cacatúa salmón de las Molucas', 'Atención social extensa, espacio amplio', 'Pellets, frutas, verduras; control de grasa'],
  ['aves', 'grande', 'loro_yaco', 'Loro Yaco (Gris Africano)', 'África Central', '400-650 g', '40-60 años', 'Inteligente, sensible y vocal', 'Uno de los loros más inteligentes', 'Estimulación cognitiva diaria, socialización', 'Pellets, frutas, verduras; calcio y vitamina A'],
  ['aves', 'grande', 'guacamayo_verde', 'Guacamayo Verde', 'América Central', '1000-1400 g', '50-70 años', 'Sociable, ruidoso y juguetón', 'Gran guacamayo de plumaje verde predominante', 'Espacio muy amplio, compañía de por vida', 'Nueces con moderación, pellets, frutas'],
  # EQUINOS pequena
  ['equinos', 'pequena', 'pony_connemara', 'Pony Connemara', 'Irlanda', '200-350 kg', '25-30 años', 'Dócil, resistente y versátil', 'Pony irlandés de gran rusticidad', 'Control de pasto, cuidado de casco regular', 'Forraje de calidad, limitar pasto rico'],
  ['equinos', 'pequena', 'pony_welsh', 'Pony Galés', 'Gales', '180-300 kg', '25-30 años', 'Inteligente, fuerte y amigable', 'Pony montés galés de montaña', 'Recorte de pezuñas, control de peso', 'Forraje y ración equilibrada según trabajo'],
  # EQUINOS mediana
  ['equinos', 'mediana', 'arabe', 'Caballo Árabe', 'Península Arábiga', '360-450 kg', '25-30 años', 'Energético, inteligente y leal', 'Raza más antigua y pura del mundo', 'Ejercicio regular, cuidado de casco', 'Forraje de calidad, concentrado según actividad'],
  ['equinos', 'mediana', 'hanoveriano', 'Hanoveriano', 'Alemania', '550-650 kg', '25-30 años', 'Equilibrado, atlético y dócil', 'Caballo de deporte alemán de dressage y salto', 'Entrenamiento progresivo, cuidado articular', 'Dieta de caballo de deporte con electrolitos'],
  ['equinos', 'mediana', 'mustang', 'Mustang', 'EE.UU.', '350-450 kg', '25-30 años', 'Resistente, inteligente e independiente', 'Caballo salvaje americano descendiente de coloniales', 'Domado gradual, respeto al instinto', 'Forraje adaptado; transición lenta de dietas'],
  # EQUINOS grande
  ['equinos', 'grande', 'belga', 'Caballo Belga', 'Bélgica', '860-1000 kg', '18-25 años', 'Tranquilo, fuerte y trabajador', 'Raza de tiro pesado más popular del mundo', 'Control de peso, cuidado de cascos', 'Forraje abundante, limitar concentrado'],
  ['equinos', 'grande', 'frison', 'Frisón', 'Países Bajos', '540-680 kg', '16-20 años', 'Elegante, dócil y majestuoso', 'Caballo negro de crin abundante', 'Cepillado frecuente, cuidado de plumas', 'Dieta equilibrada; riesgo de laminitis'],
  ['equinos', 'grande', 'pura_sangre_ingles', 'Pura Sangre Inglés', 'Inglaterra', '450-500 kg', '20-25 años', 'Veloz, enérgico y sensible', 'Raza de carreras por excelencia', 'Ejercicio diario, cuidado de tendones', 'Dieta de alto rendimiento con suplementos'],
  # BOVINOS pequena
  ['bovinos', 'pequena', 'dexter', 'Dexter', 'Irlanda', '300-450 kg', '15-20 años', 'Dócil, resistente y eficiente', 'Raza bovina miniatura irlandesa', 'Control de peso, desparasitación regular', 'Pasto de calidad, heno en invierno'],
  ['bovinos', 'pequena', 'mini_hereford', 'Mini Hereford', 'EE.UU.', '400-550 kg', '12-15 años', 'Tranquilo, dócil y eficiente', 'Versión miniatura del Hereford', 'Manejo en espacios reducidos posible', 'Pasto y suplemento mineral'],
  # BOVINOS mediana
  ['bovinos', 'mediana', 'jersey', 'Jersey', 'Isla de Jersey', '350-450 kg', '12-15 años', 'Dócil, curiosa y eficiente', 'Raza lechera de alta calidad grasa-proteína', 'Ordeño regular, control de mastitis', 'Pasto, concentrado lácteo, agua limpia'],
  ['bovinos', 'mediana', 'charolais', 'Charolais', 'Francia', '900-1100 kg', '12-15 años', 'Robusto, musculoso y vigoroso', 'Raza de carne francesa de gran tamaño', 'Manejo seguro por tamaño, control de pezuñas', 'Pasto y suplemento proteico en engorde'],
  ['bovinos', 'mediana', 'red_angus', 'Red Angus', 'Escocia/EE.UU.', '700-900 kg', '12-15 años', 'Tranquilo, eficiente y maternal', 'Variante roja del Angus sin cuernos', 'Manejo en pastoreo, bioseguridad', 'Pasto de calidad, suplemento mineral'],
  # BOVINOS grande
  ['bovinos', 'grande', 'brahman', 'Brahman', 'India/EE.UU.', '725-1000 kg', '12-16 años', 'Resistente, inteligente y adaptado al calor', 'Cebú con joroba y papada características', 'Sombra y agua en verano, control de garrapatas', 'Forraje adaptado al clima cálido'],
  ['bovinos', 'grande', 'limousin', 'Limousin', 'Francia', '700-900 kg', '12-15 años', 'Musculoso, eficiente y rústico', 'Raza de carne francesa de canal estrecha', 'Manejo tranquilo, instalaciones seguras', 'Pasto y engorde con suplemento energético'],
  ['bovinos', 'grande', 'simmental', 'Simmental', 'Suiza/Austria', '800-1100 kg', '12-15 años', 'Docil, productivo y versátil', 'Raza dual propósito carne-leche', 'Control reproductivo, manejo de peso', 'Dieta equilibrada según producción'],
  # PORCINOS pequena
  ['porcinos', 'pequena', 'mini_pig', 'Mini Pig', 'Vietnam/EE.UU.', '20-70 kg', '12-20 años', 'Inteligente, social y limpio', 'Cerdo miniatura criado como mascota', 'Espacio exterior, enriquecimiento, socialización', 'Pienso porcino de mantenimiento; NO sobrealimentar'],
  ['porcinos', 'pequena', 'vietnamita', 'Cerdo Vietnamita', 'Vietnam', '50-100 kg', '10-15 años', 'Resistente, dócil y adaptado', 'Cerdo cérvico de barriga colgante', 'Sombra, barro para termorregulación', 'Forraje, frutas y pienso balanceado'],
  # PORCINOS mediana
  ['porcinos', 'mediana', 'yorkshire_porcino', 'Yorkshire Porcino', 'Inglaterra', '250-350 kg', '10-12 años', 'Prolífico, maternal y vigoroso', 'Raza blanca de producción comercial', 'Bioseguridad estricta, control sanitario', 'Pienso comercial por fases productivas'],
  ['porcinos', 'mediana', 'pietrain', 'Pietrain', 'Bélgica', '230-280 kg', '10-12 años', 'Musculoso, magro y activo', 'Raza de carne magra con manchas negras', 'Manejo tranquilo (susceptible al estrés)', 'Pienso de engorde controlado'],
  ['porcinos', 'mediana', 'hampshire', 'Hampshire', 'EE.UU.', '270-350 kg', '10-12 años', 'Vigoroso, rápido crecimiento', 'Cerdo negro con cinturón blanco', 'Instalaciones limpias, ventilación adecuada', 'Pienso comercial de engorde'],
  # PORCINOS grande
  ['porcinos', 'grande', 'large_white', 'Large White', 'Inglaterra', '300-400 kg', '10-12 años', 'Prolífico, rústico y eficiente', 'Raza blanca base de producción mundial', 'Control sanitario, bioseguridad', 'Pienso comercial por etapa'],
  ['porcinos', 'grande', 'duroc_extra', 'Duroc (línea grande)', 'EE.UU.', '300-400 kg', '10-12 años', 'Rápido crecimiento, carne marmolada', 'Línea Duroc de producción comercial grande', 'Ventilación y frescor en verano', 'Pienso de engorde con alto rendimiento'],
  # CONEJOS pequena
  ['conejos', 'pequena', 'holandes_enano', 'Holandés Enano', 'Países Bajos', '0,9-1,4 kg', '8-12 años', 'Activo, tímido y alerta', 'Conejo enano con cabeza redonda y orejas cortas', 'Espacio seguro, heno abundante, manejo suave', 'Heno libre, pellets limitados, verduras'],
  ['conejos', 'pequena', 'rex_mini', 'Rex Miniatura', 'Francia', '1,1-1,6 kg', '7-10 años', 'Tranquilo, dócil y suave', 'Conejo de pelaje aterciopelado en miniatura', 'Cuidado del pelaje corto, suelo blando', 'Heno, pellets enanas, verduras frescas'],
  # CONEJOS mediana
  ['conejos', 'mediana', 'californiano', 'Californiano', 'EE.UU.', '3,5-5 kg', '5-9 años', 'Tranquilo, dócil y maternal', 'Conejo blanco con nariz y orejas oscuras', 'Espacio amplio, compañía conejil', 'Heno libre, pellets, verduras variadas'],
  ['conejos', 'mediana', 'belier', 'Belier (Lop)', 'Francia', '3-4,5 kg', '7-12 años', 'Dócil, cariñoso y relajado', 'Conejo de orejas caídas y temperamento calmado', 'Limpieza de orejas, cepillado regular', 'Heno, pellets, verduras; control de peso'],
  ['conejos', 'mediana', 'angora_extra', 'Angora (línea mediana)', 'Turquía', '2,5-4 kg', '7-12 años', 'Tranquilo, dócil y requiere aseo', 'Línea Angora de tamaño mediano para fibra', 'Esquileo cada 3-4 meses, cepillado diario', 'Heno abundante, suplemento proteico en muda'],
  # CONEJOS grande
  ['conejos', 'grande', 'nueva_zelanda', 'Nueva Zelanda', 'EE.UU.', '4,5-5,5 kg', '5-8 años', 'Dócil, robusto y maternal', 'Conejo blanco de carne y compañía', 'Espacio amplio, suelo acolchado', 'Heno libre, pellets, verduras'],
  ['conejos', 'grande', 'gigante_flandes_extra', 'Gigante de Flandes (línea grande)', 'Bélgica', '6-10 kg', '5-8 años', 'Dócil, gentil y sociable', 'Una de las razas más grandes de conejo', 'Suelo reforzado, control de peso estricto', 'Heno, pellets limitados, verduras'],
  # REPTILES pequena
  ['reptiles', 'pequena', 'gecko_leopardo', 'Gecko Leopardo', 'Pakistán/Afganistán', '50-80 g', '10-20 años', 'Nocturno, dócil y fácil de mantener', 'Lagarto popular en terrariofilia', 'Terrario 60x40 cm, gradiente térmico 26-32°C', 'Insectos (grillos, tenebrios) con calcio'],
  ['reptiles', 'pequena', 'camaleon_pantera', 'Camaleón Pantera', 'Madagascar', '150-250 g', '5-8 años', 'Solitario, territorial y sensible', 'Camaleón colorido de Madagascar', 'Terrario vertical, niebla, UVB, temperatura controlada', 'Insectos variados con suplementación'],
  # REPTILES mediana
  ['reptiles', 'mediana', 'piton_bola', 'Pitón Bola', 'África Occidental', '1,5-3 kg', '20-30 años', 'Dócil, nocturno y tranquilo', 'Serpiente constrictora que se enrolla en defensa', 'Terrario 120x60 cm, calor 30-32°C, humedad 50-60%', 'Roedores congelados del tamaño adecuado'],
  ['reptiles', 'mediana', 'dragon_barbudo', 'Dragón Barbudo', 'Australia', '300-600 g', '8-12 años', 'Diurno, dócil e inteligente', 'Lagarto australiano de cresta espinosa', 'Terrario 120x60 cm, UVB 10-12 h, gradiente 38-42°C', 'Insectos, verduras y frutas variadas'],
  ['reptiles', 'mediana', 'tortuga_mediterranea', 'Tortuga Mediterránea', 'Mediterráneo', '1-3 kg', '50-100 años', 'Diurna, herbívora y longeva', 'Testudo hermanni de jardín mediterráneo', 'Exterior con recinto seguro, UV natural, hibernación', 'Hierbas, flores, verduras; calcio'],
  # REPTILES grande
  ['reptiles', 'grande', 'python_reticulado', 'Pitón Reticulado', 'Sudeste Asiático', '50-100+ kg', '20-30 años', 'Potente, inteligente y requiere experto', 'Una de las serpientes más largas del mundo', 'Terrario grande o habitación dedicada, manejo con 2 personas', 'Roedores y aves de tamaño proporcional'],
  ['reptiles', 'grande', 'monitor_savannah', 'Monitor de Savannah', 'África', '5-10 kg', '10-15 años', 'Activo, inteligente y territorial', 'Lagarto monitor africano de gran tamaño', 'Terrario mínimo 240x120 cm, calor intenso', 'Insectos, roedores, huevos; dieta variada'],
  ['reptiles', 'grande', 'iguana_extra', 'Iguana Verde (línea grande)', 'América Central', '4-8 kg', '15-20 años', 'Arbóreo, territorial y longevo', 'Lagarto verde de gran tamaño adulto', 'Terrario vertical mínimo 180x120x180 cm', 'Verduras de hoja, frutas limitadas, calcio'],
  # PECES pequena
  ['peces', 'pequena', 'neon_tetra', 'Neon Tetra', 'Amazonas', '0,2-0,5 g', '3-5 años', 'Pacífico, escolar y colorido', 'Pez tropical de acuario comunitario', 'Acuario plantado 40L+, cardumen mínimo 6', 'Escamas finas, larvas, alimento congelado'],
  ['peces', 'pequena', 'guppy', 'Guppy', 'Sudamérica', '0,3-1 g', '2-3 años', 'Activo, prolífico y colorido', 'Pez vivíparo ideal para principiantes', 'Acuario 40L+, temperatura 22-28°C', 'Escamas, artemia, alimento variado'],
  ['peces', 'pequena', 'platy', 'Platy', 'Centroamérica', '1-3 g', '2-3 años', 'Pacífico, colorido y fácil', 'Pez vivíparo de acuario comunitario', 'Acuario 40L+, cardumen de 4+', 'Escamas, verduras blandas, alimento vivo'],
  # PECES mediana
  ['peces', 'mediana', 'pez_angel', 'Pez Ángel', 'Amazonas', '30-50 g', '5-10 años', 'Elegante, territorial y majestuoso', 'Cíclido amazónico de aletas largas', 'Acuario 120L+, altura mínima 40 cm', 'Escamas, larvas, alimento congelado'],
  ['peces', 'mediana', 'cichlidae', 'Cíclido Africano', 'Lagos Africanos', '50-150 g', '5-10 años', 'Territorial, colorido y activo', 'Cíclido de los lagos Malawi/Tanganica', 'Acuario 200L+, rocas y cuevas', 'Escamas específicas, spirulina, artemia'],
  ['peces', 'mediana', 'tetra_congo', 'Tetra Congo', 'África Central', '15-25 g', '3-5 años', 'Pacífico, escolar y brillante', 'Tetra de agua dulce africano iridiscente', 'Acuario 100L+, cardumen de 6+', 'Escamas finas, alimento congelado'],
  # PECES grande
  ['peces', 'grande', 'oscar', 'Óscar', 'Amazonas', '200-500 g', '10-15 años', 'Inteligente, territorial y interactivo', 'Cíclido grande de acuario', 'Acuario 300L+, filtración potente', 'Pellets grandes, pescado, gusanos'],
  ['peces', 'grande', 'discus', 'Discus', 'Amazonas', '150-250 g', '10-15 años', 'Sensibles, majestuosos y sociales', 'Reyes del acuario amazónico', 'Acuario 250L+, agua blanda y caliente 28-30°C', 'Alimento específico discus, artemia, gusanos'],
  ['peces', 'grande', 'arowana', 'Arowana', 'Sudeste Asiático', '500-2000 g', '10-20 años', 'Imponente, saltador y longevo', 'Pez dragón de acuario grande', 'Acuario 500L+ con tapa (salta), temperatura 26-30°C', 'Insectos, peces pequeños, pellets grandes'],
  # OVINOS pequena
  ['ovinos', 'pequena', 'ouessant', 'Ouessant', 'Francia', '10-20 kg', '10-12 años', 'Dócil, resistente y compacto', 'Oveja miniatura de la isla de Ouessant', 'Esquileo anual, recorte de pezuñas', 'Pasto, heno, suplemento mineral'],
  # OVINOS mediana
  ['ovinos', 'mediana', 'suffolk', 'Suffolk', 'Inglaterra', '80-130 kg', '10-12 años', 'Robusto, prolífico y eficiente', 'Oveja de carne con cabeza y patas negras', 'Manejo en pastoreo, control de parásitos', 'Pasto de calidad, suplemento en gestación'],
  ['ovinos', 'mediana', 'dorper', 'Dorper', 'Sudáfrica', '70-110 kg', '10-12 años', 'Resistente, adaptado al calor', 'Oveja de carne sin lana ( pelo )', 'Sombra en verano, agua abundante', 'Pasto seco, suplemento en sequía'],
  ['ovinos', 'mediana', 'merino_extra', 'Merino (línea mediana)', 'España/Australia', '60-90 kg', '10-12 años', 'Rustica, lanar y eficiente', 'Línea Merino de producción lanar media', 'Esquileo semestral, control de miasis', 'Pasto, suplemento proteico en lactación'],
  # OVINOS grande
  ['ovinos', 'grande', 'texel', 'Texel', 'Países Bajos', '80-110 kg', '10-12 años', 'Musculoso, lanar y compacto', 'Oveja de carne de canal ancha', 'Esquileo, recorte de pezuñas, control parasitario', 'Pasto de calidad, suplemento en engorde'],
  ['ovinos', 'grande', 'romney', 'Romney', 'Inglaterra', '80-120 kg', '10-12 años', 'Dócil, resistente y dual propósito', 'Oveja de lana larga y carne', 'Esquileo anual, pastoreo extensivo', 'Pasto, heno, suplemento mineral'],
  # CAPRINOS pequena
  ['caprinos', 'pequena', 'cabra_pigmea', 'Cabra Pigmea', 'África Occidental', '20-35 kg', '10-12 años', 'Amigable, dócil y social', 'Cabra miniatura ideal para pequeñas fincas', 'Recorte de pezuñas, desparasitación', 'Pasto, heno, suplemento mineral'],
  # CAPRINOS mediana
  ['caprinos', 'mediana', 'saanen', 'Saanen', 'Suiza', '60-80 kg', '10-12 años', 'Dócil, prolífica y lechera', 'Cabra lechera blanca de alta producción', 'Ordeño regular, control de mastitis', 'Pasto, concentrado lácteo, agua limpia'],
  ['caprinos', 'mediana', 'alpine', 'Alpina', 'Francia/Suiza', '55-75 kg', '10-12 años', 'Resistente, activa y lechera', 'Cabra alpina de gran adaptabilidad', 'Pastoreo en terreno variado, refugio', 'Pasto, heno, suplemento según lactación'],
  ['caprinos', 'mediana', 'nubia_extra', 'Nubia (línea mediana)', 'África/EE.UU.', '60-80 kg', '10-12 años', 'Vocal, dócil y lechera', 'Cabra de orejas largas caídas', 'Protección solar en orejas, ordeño', 'Pasto, concentrado, agua abundante'],
  # CAPRINOS grande
  ['caprinos', 'grande', 'boer', 'Boer', 'Sudáfrica', '90-120 kg', '10-12 años', 'Rápido crecimiento, carne de calidad', 'Cabra de carne de cabeza blanca', 'Manejo en pastoreo, control sanitario', 'Pasto de calidad, suplemento en engorde'],
  ['caprinos', 'grande', 'angora_cabra', 'Angora (cabra)', 'Turquía', '50-70 kg', '10-12 años', 'Tranquila, lanar y productiva', 'Cabra productora de mohair', 'Esquileo cada 6 meses, refugio seco', 'Pasto, suplemento proteico en esquileo'],
  # CAMELIDOS mediana
  ['camelidos', 'mediana', 'alpaca', 'Alpaca', 'Perú/Bolivia', '55-80 kg', '15-20 años', 'Dócil, social y curiosa', 'Camélido sudamericano productor de fibra fina', 'Esquileo anual, protección del calor', 'Pasto, heno, suplemento mineral'],
  # CAMELIDOS grande
  ['camelidos', 'grande', 'llama_extra', 'Llama (línea grande)', 'Andes', '130-200 kg', '15-25 años', 'Dócil, fuerte y guardián', 'Camélido andino de carga y fibra', 'Esquileo, recorte de uñas, refugio', 'Pasto andino, heno, agua limpia'],
  ['camelidos', 'grande', 'vicuna', 'Vicuña', 'Andes', '35-50 kg', '15-20 años', 'Salvaje, esquiva y protegida', 'Camélido silvestre de fibra más fina del mundo', 'Manejo mínimo, protección legal en muchos países', 'Pastoreo altoandino natural'],
  ['camelidos', 'grande', 'guanaco', 'Guanaco', 'Patagonia/Andes', '90-140 kg', '15-20 años', 'Salvaje, resistente e independiente', 'Antepasado del llama, adaptado al frío', 'Espacio amplio, manejo mínimo', 'Pastoreo extensivo en terreno variado'],
  # ROEDORES pequena
  ['roedores', 'pequena', 'raton_domestico', 'Ratón Doméstico', 'Asia/EE.UU.', '20-40 g', '1,5-3 años', 'Curioso, social y activo', 'Mus musculus domesticado como mascota', 'Jaula con niveles, compañía de su especie', 'Mezcla de roedores, verduras, proteína'],
  ['roedores', 'pequena', 'gerbo_mongol', 'Gerbo Mongol', 'Mongolia/China', '50-130 g', '3-5 años', 'Activo, curioso y saltador', 'Roedor del desierto con patas traseras largas', 'Jaula con sustrato para cavar, rueda segura', 'Mezcla de gerbo, semillas, insectos secos'],
  # ROEDORES mediana
  ['roedores', 'mediana', 'chinchilla', 'Chinchilla', 'Andes', '400-700 g', '10-20 años', 'Activa, nocturna y delicada', 'Roedor de pelaje más denso del reino animal', 'Jaula amplia, polvo de baño volcánico, temperatura fresca', 'Heno, pellets de chinchilla, heno limitado'],
  ['roedores', 'mediana', 'rata_domestica', 'Rata Doméstica', 'Europa/EE.UU.', '300-500 g', '2-3 años', 'Inteligente, social y cariñosa', 'Rata de laboratorio domesticada como mascota', 'Jaula grande, compañía, enriquecimiento', 'Pellets de rata, verduras, proteína cocida'],
  ['roedores', 'mediana', 'degu', 'Degu', 'Chile', '200-300 g', '5-8 años', 'Social, activo y vocal', 'Roedor chileno diurno de cola con pincel', 'Jaula con compañero, rueda, madera para roer', 'Heno libre, pellets sin azúcar, verduras secas'],
  # ROEDORES grande
  ['roedores', 'grande', 'capibara', 'Capibara', 'Sudamérica', '35-65 kg', '8-10 años', 'Social, dócil y acuático', 'Roedor más grande del mundo', 'Acceso a agua para nadar, grupo social, espacio amplio', 'Pasto, heno, verduras, pellets específicos']
].freeze

DISEASES_BY_ANIMAL = {
  'perros' => [
    ['Displasia de cadera', 'grave'], ['Enfermedad periodontal', 'moderada'], ['Otitis externa', 'moderada'],
    ['Dermatitis atópica', 'moderada'], ['Obesidad', 'moderada'], ['Epilepsia idiopática', 'grave'],
    ['Torsión gástrica', 'grave'], ['Cardiomiopatía dilatada', 'grave'], ['Luxación de rótula', 'moderada'],
    ['Hipotiroidismo', 'moderada'], ['Colapso traqueal', 'moderada'], ['Hipoglucemia', 'grave']
  ],
  'gatos' => [
    ['Enfermedad renal crónica', 'grave'], ['Obstrucción urinaria', 'grave'], ['Cardiomiopatía hipertrófica', 'grave'],
    ['Diabetes mellitus', 'moderada'], ['Enfermedad periodontal', 'moderada'], ['Asma felino', 'moderada'],
    ['Pancreatitis', 'grave'], ['Infección del tracto urinario', 'moderada'], ['Obesidad', 'moderada'],
    ['Linfoma', 'grave'], ['Neoplasia mamaria', 'grave'], ['Luxación de rótula', 'leve']
  ],
  'aves' => [
    ['Psitacosis', 'grave'], ['Aspergilosis', 'grave'], ['Candidiasis', 'moderada'],
    ['Ácaros respiratorios', 'moderada'], ['Obesidad', 'moderada'], ['Egg binding', 'grave'],
    ['Metalosis por intoxicación', 'grave'], ['Pododermatitis', 'moderada'], ['Feather picking', 'moderada'],
    ['Prolapso cloacal', 'grave'], ['Sarcocistosis', 'moderada'], ['Avian pox', 'moderada']
  ],
  'equinos' => [
    ['Cólico', 'grave'], ['Laminitis', 'grave'], ['Artritis degenerativa', 'moderada'],
    ['Úlcera gástrica', 'moderada'], ['Neumonía', 'grave'], ['Tétanos', 'grave'],
    ['Cushing (PPID)', 'moderada'], ['Melanoma', 'moderada'], ['Tendinitis', 'moderada'],
    ['Anemia parasitaria', 'moderada'], ['Contusión muscular', 'leve'], ['Queratoconjuntivitis', 'moderada']
  ],
  'bovinos' => [
    ['Mastitis', 'moderada'], ['Timpanismo', 'grave'], ['Neumonía', 'grave'],
    ['Clostridiosis', 'grave'], ['Metritis', 'moderada'], ['Hipocalcemia posparto', 'grave'],
    ['Anaplasmosis', 'moderada'], ['Pododermatitis digital', 'moderada'], ['Retención de placenta', 'moderada'],
    ['Desplazamiento de abomaso', 'grave'], ['Cetosis', 'moderada'], ['Queratoconjuntivitis', 'moderada']
  ],
  'porcinos' => [
    ['Disentería porcina', 'grave'], ['Erisipela', 'grave'], ['PCV2 (circovirus)', 'grave'],
    ['Mycoplasma', 'moderada'], ['MMA (metritis-mastitis-agalactia)', 'grave'], ['Golpe de calor', 'grave'],
    ['Osteocondrosis', 'moderada'], ['Síndrome de estrés porcino', 'grave'], ['Aflatoxicosis', 'grave'],
    ['Parásitos internos', 'moderada'], ['Neumonía en lechones', 'grave'], ['Prolapso rectal', 'moderada']
  ],
  'conejos' => [
    ['Estasis gastrointestinal', 'grave'], ['Maloclusión dental', 'moderada'], ['Pododermatitis', 'moderada'],
    ['Pasteurelosis', 'grave'], ['Encefalitozoon cuniculi', 'grave'], ['Tricobezoar', 'grave'],
    ['Fractura por caída', 'grave'], ['Enteritis', 'grave'], ['Otitis', 'moderada'],
    ['Obesidad', 'moderada'], ['Coccidiosis', 'moderada'], ['Heat stroke', 'grave']
  ],
  'reptiles' => [
    ['Enfermedad ósea metabólica', 'grave'], ['Infección respiratoria', 'moderada'], ['Parásitos internos', 'moderada'],
    ['Muda retenida', 'moderada'], ['Quemaduras térmicas', 'moderada'], ['Estomatitis', 'moderada'],
    ['Prolapso cloacal', 'grave'], ['Gota', 'moderada'], ['Deshidratación', 'grave'],
    ['Shell rot', 'moderada'], ['Infección fúngica cutánea', 'moderada'], ['Intoxicación', 'grave']
  ],
  'peces' => [
    ['Ich (punto blanco)', 'moderada'], ['Columnaris', 'grave'], ['Velvet (Oodinium)', 'moderada'],
    ['Dropsy (hidropesía)', 'grave'], ['Podredumbre de aletas', 'moderada'], ['Intoxicación por amoniaco', 'grave'],
    ['Costia', 'moderada'], ['Hexamita', 'moderada'], ['Swim bladder disorder', 'moderada'],
    ['KHV', 'grave'], ['Úlceras bacterianas', 'moderada'], ['Parásitos en branquias', 'moderada']
  ],
  'ovinos' => [
    ['Clostridiosis', 'grave'], ['Timpanismo', 'grave'], ['Miasis', 'grave'],
    ['Anemia parasitaria', 'moderada'], ['Pododermatitis (footrot)', 'moderada'], ['Mastitis', 'moderada'],
    ['Neumonía', 'grave'], ['Parto distócico', 'grave'], ['Acidosis ruminal', 'moderada'],
    ['Orf (ectima)', 'moderada'], ['Listeriosis', 'grave'], ['Coccidiosis', 'moderada']
  ],
  'caprinos' => [
    ['Timpanismo', 'grave'], ['Mastitis', 'moderada'], ['Parásitos internos', 'moderada'],
    ['Listeriosis', 'grave'], ['Bloqueo urinario', 'grave'], ['Parto distócico', 'grave'],
    ['Neumonía', 'grave'], ['Orf (ectima)', 'moderada'], ['Acidosis ruminal', 'moderada'],
    ['Coccidiosis', 'moderada'], ['Caprine arthritis encephalitis', 'grave'], ['Anemia parasitaria', 'moderada']
  ],
  'camelidos' => [
    ['Cólico', 'grave'], ['Anemia parasitaria', 'moderada'], ['Meningeal worm', 'grave'],
    ['Golpe de calor', 'grave'], ['Neumonía', 'grave'], ['Parásitos internos', 'moderada'],
    ['Raquitismo', 'moderada'], ['Polioencefalomalacia', 'grave'], ['Urolitiasis', 'moderada'],
    ['Contusión articular', 'leve'], ['Enteritis', 'moderada'], ['Parto distócico', 'grave']
  ],
  'roedores' => [
    ['Wet tail (proliferativa)', 'grave'], ['Maloclusión dental', 'moderada'], ['Neumonía', 'grave'],
    ['Escorbuto', 'grave'], ['Tumores', 'moderada'], ['Insulinoma', 'grave'],
    ['Pododermatitis', 'moderada'], ['Parásitos externos', 'leve'], ['Moquillo (hurón)', 'grave'],
    ['Cálculos urinarios', 'grave'], ['Prolapso rectal', 'moderada'], ['Obesidad', 'moderada']
  ]
}.freeze

BREED_EXTRA = {
  'shih_tzu' => { historia: 'Raza tibetana criada en la corte imperial china como perro de compañía. Llegó a Occidente en el siglo XX.', caracteristicas: 'Pelaje largo y sedoso, hocico corto, ojos grandes. Colores variados. Peso 4-7 kg.', aptitudes: 'Compañía, perro de terapia, exposición.', altura: '20-28 cm a la cruz', emergencias: 'BOAS, hipoglucemia, prolapso ocular y golpe de calor.' },
  'boxer' => { historia: 'Desarrollado en Alemania a finales del siglo XIX a partir del Bullenbeisser. Nombre por su estilo de boxear con patas delanteras.', caracteristicas: 'Cuerpo musculoso cuadrado, hocico corto, mandíbula prognata. Pelaje corto atigrado o leonado. Peso 25-32 kg.', aptitudes: 'Guarda, compañía familiar, perro de servicio, boxeo canino deportivo.', altura: '53-63 cm a la cruz', emergencias: 'Torsión gástrica, arritmias, BOAS y cardiomiopatía arritmogénica.' },
  'rottweiler' => { historia: 'Desciende de perros romanos usados para pastoreo y guarda en Rottweil (Alemania). Reconocido como perro policial y de rescate.', caracteristicas: 'Cuerpo potente negro con marcas fuego. Cabeza amplia, mandíbula fuerte. Peso 35-60 kg.', aptitudes: 'Guarda, policía, rescate, pastoreo, compañía con entrenamiento adecuado.', altura: '56-69 cm a la cruz', emergencias: 'Torsión gástrica, osteosarcoma, displasia de cadera y agresión por dolor.' },
  'devon_rex' => { historia: 'Mutación natural en Devon (Inglaterra) en 1960. Pelaje rizado único por mutación genética diferente al Cornish Rex.', caracteristicas: 'Pelaje rizado corto, orejas enormes, rostro elfo. Peso 2,5-4 kg.', aptitudes: 'Compañía, exposición, perro-gato por temperamento activo.', altura: '25-28 cm a la cruz', emergencias: 'Hipoglucemia, problemas de piel y frío extremo por poco pelaje.' },
  'alpaca' => { historia: 'Domesticada en los Andes hace más de 6000 años. Principal productor de fibra fina (18-24 micras).', caracteristicas: 'Camélido pequeño sin joroba, fibra lanuda variada. Peso 55-80 kg.', aptitudes: 'Producción de fibra, carne, ecoturismo, terapia asistida.', altura: '81-99 cm a la cruz', emergencias: 'Golpe de calor, anemia por parásitos, parto distócico y enterotoxemia.' },
  'capibara' => { historia: 'El roedor más grande del mundo, nativo de Sudamérica. Cada vez más popular en zoos y santuario como animal educativo.', caracteristicas: 'Cuerpo masivo semiacuático, patas palmeadas, pelaje corto. Peso 35-65 kg.', aptitudes: 'Ecoturismo, educación ambiental, terapia (donde legal).', altura: '50-62 cm a la cruz', emergencias: 'Deshidratación, problemas dentales, hipotermia y estrés por aislamiento social.' }
}.freeze
