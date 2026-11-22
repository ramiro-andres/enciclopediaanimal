# frozen_string_literal: true

# Curación de contenido de razas (idempotente).
#
# 1. Corrige errores de traducción conocidos ("Grapas" → uvas y pasas).
# 2. Separa frases pegadas sin punto y elimina frases repetidas en cuidados/alimentación
#    (artefacto de expand_enciclopedia.rb al ejecutarse más de una vez).
# 3. Amplía descripciones demasiado cortas (< 45 caracteres).
# 4. Sustituye historia, características, aptitudes y altura genéricas por texto propio
#    en perros y gatos.
#
# Uso: ruby scripts/data/curar_contenido_razas.rb && bash actualizar_datos.sh

require 'json'

ROOT = File.expand_path('../..', __dir__)
ENC_PATH = File.join(ROOT, 'data', 'enciclopedia.json')

TRADUCCIONES = {
  'Grapas (toxicosis macro y microcítica)' => 'Uvas y pasas (insuficiencia renal aguda)'
}.freeze

VERBOS_FRASE = %w[Programar Ajustar Garantizar Proporcionar Mantener Evitar].freeze

DESCRIPCIONES = {
  'cornish_rex' => 'Gato de pelo rizado fino y cuerpo atlético, originario de Cornualles (Inglaterra) en 1950. Su pelo carece de capa externa, por lo que es muy suave y sensible al frío; es activo, sociable y juguetón.',
  'caique' => 'Loro mediano de gran personalidad y colorido, nativo de la cuenca amazónica. Muy juguetón y acrobático; necesita varias horas diarias fuera de la jaula y enriquecimiento constante.',
  'lorikeet_arcoiris' => 'Lori nectarívoro de plumaje multicolor, nativo de Australia e Indonesia. Su lengua en cepillo está adaptada a néctar y polen, por lo que necesita una dieta específica; las heces líquidas son normales.',
  'pavo_narragansett' => 'Pavo barrado de granja para carne de calidad, desarrollado en Rhode Island (EE.UU.) en el siglo XIX. Raza patrimonial de crecimiento lento, buena forrajera y de carácter tranquilo.',
  'guacamayo_azul_dorado' => 'Gran guacamayo de plumaje azul y amarillo, nativo de Sudamérica tropical. Muy inteligente y longevo (más de 50 años); requiere espacio amplio, compañía diaria y dieta variada.',
  'normanda' => 'Bovino francés de Normandía para leche quesera y carne. Su leche, rica en proteína y con alta frecuencia de kappa-caseína B, es muy valorada para quesos; raza rústica de doble propósito.',
  'berkshire_intl' => 'Cerdo negro de carne premium y marmolada, originario del condado de Berkshire (Inglaterra). Negro con seis puntos blancos (patas, cara y punta de la cola); en Japón su carne se comercializa como kurobuta.',
  'mini_lop_intl' => 'Conejo enano de orejas caídas muy popular como mascota. Cuerpo compacto y musculoso; las orejas caídas favorecen la otitis, por lo que conviene revisarlas con frecuencia.',
  'champagne_argent' => 'Conejo plateado para carne y piel, una de las razas más antiguas de Francia. Nace negro y su pelo se aclara hasta el plateado hacia los 4 meses de edad.',
  'satin' => 'Conejo de doble aptitud carne y piel originado en EE.UU. en la década de 1930. Su mutación satinada da al pelo un brillo intenso y una textura muy suave.',
  'angora_frances' => 'Conejo de pelo largo para lana y compañía, originario de Francia. Su lana requiere cepillado frecuente o esquila cada 3-4 meses para evitar nudos y tricobezoares.',
  'rambouillet' => 'Merino de gran tamaño para lana fina y carne, desarrollado en la granja real de Rambouillet (Francia) desde 1786. Muy adaptable al pastoreo extensivo.',
  'awassi' => 'Oveja de cola grasa para leche, carne y lana, originaria de Oriente Medio. Muy resistente al calor y a la escasez de forraje; las líneas mejoradas destacan en producción lechera.',
  'malaguena' => 'Raza caprina española de la provincia de Málaga, orientada a leche y cabrito. De capa rubia y alta producción lechera, adaptada a sistemas semiextensivos mediterráneos.',
  'boer_intl' => 'Cabra de carne más utilizada en el mundo, desarrollada en Sudáfrica a inicios del siglo XX. Cuerpo blanco con cabeza roja, crecimiento rápido y gran rendimiento de canal.',
  'alpine_intl' => 'Cabra lechera de montaña de alta producción, originaria de los Alpes franceses y suizos. Muy adaptable a distintos climas y sistemas; capa de colores variados.',
  'alpaca_huacaya' => 'Alpaca de vellón esponjoso para fibra textil, la variedad más común (cerca del 90 % de la población). Nativa de los Andes de Perú y Bolivia; su fibra fina carece de lanolina.'
}.freeze

# id => [historia, caracteristicas, aptitudes, altura]
FICHAS = {
  # ── Perros ──
  'shih_tzu' => [
    'Se desarrolló en los palacios imperiales chinos a partir de perros tibetanos regalados a la corte Qing. Tras 1949 casi desapareció en China; la raza se reconstruyó con unos pocos ejemplares llevados a Inglaterra en la década de 1930 y el AKC la reconoció en 1969.',
    'Perro toy de cuerpo más largo que alto, cabeza redonda y hocico corto (braquicéfalo). Doble capa de pelo largo y denso de cualquier color; ojos grandes y oscuros, cola en penacho sobre el dorso.',
    'Perro de compañía para pisos y familias tranquilas; apto para personas mayores. Por su braquicefalia hay que evitar el ejercicio intenso con calor.',
    '20-28 cm a la cruz'
  ],
  'papillon' => [
    'Desciende de los spaniels enanos continentales que aparecen en cuadros de Tiziano y Rubens desde el siglo XVI, favoritos de las cortes de Francia y España. Su nombre («mariposa») alude a las orejas erguidas y con flecos; la variedad de orejas caídas se llama phalène.',
    'Toy de huesos finos y cuerpo algo más largo que alto. Pelo largo y sedoso sin subpelo; fondo blanco con manchas de color. Orejas grandes con flecos y cola en penacho.',
    'Compañía activa; destaca en agility y obediencia por su inteligencia. Se adapta a pisos si recibe estímulo mental diario.',
    '20-28 cm a la cruz'
  ],
  'bichon_frances' => [
    'Desciende de los perros tipo barbet del Mediterráneo que viajaban con marinos españoles e italianos. Fue perro de corte en Francia en el siglo XVI, después perro de circo y de calle, y la FCI lo reconoció como Bichón Frisé en 1933.',
    'Pequeño y compacto, de pelo blanco, rizado y abundante con subpelo suave que muda poco. Ojos y trufa negros; cola curvada sobre el dorso.',
    'Compañía familiar; convive bien con niños y otros animales. Su pelo requiere cepillado frecuente y peluquería cada 4-6 semanas.',
    '25-29 cm a la cruz'
  ],
  'pinscher_miniatura' => [
    'Raza alemana documentada desde hace siglos como cazadora de ratas en establos y granjas. Comparte ancestros con el pinscher alemán y no es una versión reducida del dobermann, que es posterior. Su estándar se fijó a finales del siglo XIX.',
    'Perro cuadrado, de líneas limpias y paso elevado («hackney»). Pelo corto, duro y brillante, negro y fuego o rojo. Musculatura seca y elegante.',
    'Perro de alerta y compañía; muy enérgico, necesita juego diario. Tolera poco el frío.',
    '25-30 cm a la cruz'
  ],
  'pekines' => [
    'Perro sagrado de la corte imperial china, reservado a la familia del emperador durante siglos. Tras el saqueo del Palacio de Verano en 1860, soldados británicos llevaron cinco ejemplares a Inglaterra, uno de ellos para la reina Victoria, y desde allí se difundió por Occidente.',
    'Toy pesado para su tamaño, de cabeza ancha y plana, hocico muy corto y abundante melena de «león». Patas delanteras cortas y arqueadas; marcha ondulante.',
    'Compañía tranquila y muy independiente. Por su braquicefalia y su pelaje denso es sensible al calor y no apto para ejercicio intenso.',
    '15-23 cm a la cruz'
  ],
  'west_highland' => [
    'Seleccionado en Poltalloch (Escocia) en el siglo XIX por el coronel Edward Malcolm a partir de terriers de pelo claro, para que no se confundieran con el zorro durante la caza. Se reconoció con su nombre actual en 1907.',
    'Terrier pequeño y compacto, de pecho profundo. Capa doble, exterior dura de unos 5 cm y subpelo suave, siempre blanca. Orejas erguidas y puntiagudas; cola corta y recta.',
    'Compañía y alerta; conserva el instinto de caza de alimañas. Predispuesto a dermatitis atópica, por lo que conviene vigilar la piel.',
    '25-28 cm a la cruz'
  ],
  'schnauzer_miniatura' => [
    'Se obtuvo en Alemania a finales del siglo XIX cruzando schnauzers medianos con razas pequeñas como el affenpinscher y probablemente el caniche, para cazar ratas en granjas. El primer ejemplar registrado data de 1888.',
    'Perro cuadrado y robusto, con barba y cejas pobladas. Pelo duro de alambre en sal y pimienta, negro, negro y plata o blanco; muda escasa con stripping.',
    'Compañía y alerta, adaptable a pisos; inteligente y fácil de adiestrar. Riesgo de hiperlipidemia y pancreatitis: dieta baja en grasa.',
    '30-35 cm a la cruz'
  ],
  'boxer' => [
    'Se desarrolló en Múnich a finales del siglo XIX a partir del Bullenbeisser, un moloso de caza mayor, cruzado con bulldogs ingleses. El primer club se fundó en 1895 y la raza sirvió como perro mensajero y de guardia en las guerras mundiales.',
    'Moloso de talla mediana, cuadrado y musculoso, con hocico corto y prognatismo inferior. Pelo corto y brillante, leonado o atigrado, con o sin marcas blancas.',
    'Familiar, guardián y perro de trabajo (policía, asistencia). Muy activo y juguetón hasta edad avanzada; sensible al calor por su braquicefalia.',
    '53-63 cm a la cruz'
  ],
  'shiba_inu' => [
    'Una de las razas más antiguas de Japón, usada para cazar aves y caza menor en zonas de montaña. Japón la declaró monumento natural en 1936; tras la Segunda Guerra Mundial y una epidemia de moquillo se reconstruyó a partir de pocas líneas regionales.',
    'Spitz pequeño, compacto y musculoso, con orejas triangulares erguidas y cola enroscada. Doble capa densa en rojo, sésamo o negro y fuego, con zonas claras (urajiro).',
    'Compañía para tutores con experiencia; muy independiente y con fuerte instinto de presa, debe ir con correa en zonas abiertas. Muda intensa estacional.',
    '35-41 cm a la cruz'
  ],
  'samoyedo' => [
    'Lleva el nombre del pueblo samoyedo (nenets) de Siberia, que lo usaba para pastorear renos, tirar de trineos y dar calor. Exploradores polares como Nansen y Amundsen lo llevaron en sus expediciones y llegó a Inglaterra a finales del siglo XIX.',
    'Spitz mediano, fuerte y elegante, con doble capa blanca o crema muy densa y la «sonrisa samoyeda» de comisuras curvadas. Cola en rulo sobre el dorso.',
    'Familiar y de trineo; muy sociable y mal guardián. Requiere ejercicio diario y cepillado frecuente; tolera mal el calor.',
    '46-60 cm a la cruz'
  ],
  'pointer_ingles' => [
    'Se formó en Inglaterra en los siglos XVII y XVIII a partir de perros de muestra españoles, probablemente cruzados con foxhounds y lebreles, para señalar liebres y aves a los cazadores.',
    'Atlético y elegante, de cabeza cincelada con stop marcado. Pelo corto, fino y liso; blanco con manchas limón, naranja, hígado o negro.',
    'Caza de muestra; necesita mucho ejercicio diario. Como mascota requiere espacio y actividad o tiende a la ansiedad.',
    '61-69 cm a la cruz'
  ],
  'australian_shepherd' => [
    'Pese a su nombre, se desarrolló en el oeste de Estados Unidos en el siglo XIX, probablemente a partir de perros pastores llegados con rebaños desde Australia y de pastores europeos. Se popularizó en los rodeos tras la Segunda Guerra Mundial.',
    'Mediano, algo más largo que alto y ágil. Pelo semilargo con melena en azul mirlo, rojo mirlo, negro o rojo, con o sin fuego. Ojos de cualquier color, a veces con heterocromía.',
    'Pastoreo, agility, obediencia y búsqueda; necesita trabajo físico y mental diario. Portador frecuente de la mutación MDR1: precaución con ivermectina y otros fármacos.',
    '46-58 cm a la cruz'
  ],
  'corgi_gales' => [
    'Perro de arreo de ganado vacuno en Pembrokeshire (Gales) desde hace siglos: mordisquea los talones del ganado y esquiva las coces por su baja altura. Se separó oficialmente del Corgi de Cardigan en 1934 y se hizo famoso por la reina Isabel II.',
    'Perro bajo y largo, robusto, de orejas erguidas y expresión de zorro. Pelo doble de longitud media en rojo, sable, leonado o tricolor, con marcas blancas.',
    'Pastoreo y compañía activa. Tiende al sobrepeso, que agrava los problemas de columna: controlar las raciones.',
    '25-30 cm a la cruz'
  ],
  'weimaraner' => [
    'Se desarrolló en el siglo XIX en la corte del gran duque Carlos Augusto de Sajonia-Weimar para cazar caza mayor y, después, aves. El club alemán controló estrictamente su cría y su exportación hasta mediados del siglo XX.',
    'Perro de muestra grande y atlético, de pelo corto gris plateado, corzo o ratón. Ojos de ámbar a gris azulado; existe una variedad de pelo largo.',
    'Caza polivalente, rastreo y deporte canino. Muy apegado, tolera mal la soledad. Tórax profundo con riesgo de dilatación-torsión gástrica.',
    '57-70 cm a la cruz'
  ],
  'bull_terrier' => [
    'Lo creó James Hinks en Birmingham hacia 1860 cruzando bulldog inglés con el extinto terrier inglés blanco, buscando un perro más elegante. Más tarde se seleccionó como perro de compañía.',
    'Musculoso y compacto, con la cabeza ovoide («en forma de huevo») sin stop y ojos pequeños triangulares. Pelo corto, duro y brillante, blanco o de color.',
    'Compañía para tutores firmes y con experiencia; muy enérgico y testarudo. Los ejemplares blancos tienen más riesgo de sordera congénita: pedir prueba BAER.',
    '45-55 cm a la cruz (el estándar no fija límite)'
  ],
  'vizsla' => [
    'Perro de caza de los magiares, citado en crónicas húngaras desde la Edad Media. Estuvo cerca de extinguirse tras las guerras mundiales y se recuperó con ejemplares sacados del país por emigrantes húngaros.',
    'Perro de muestra de talla media, atlético y ligero. Pelo corto, denso y liso de color rubio dorado; trufa, ojos y uñas armonizan con el pelaje.',
    'Caza de muestra y cobro, también en agua, y deporte canino. Muy afectuoso («perro velcro»): necesita compañía y ejercicio intenso.',
    '54-64 cm a la cruz'
  ],
  'springer_spaniel' => [
    'Spaniel británico usado desde al menos el siglo XVII para levantar («spring») la caza ante el cazador. Se diferenció del cocker por el peso dentro de las mismas camadas y el Kennel Club lo reconoció como raza en 1902.',
    'Spaniel mediano y compacto, de patas más largas que el cocker. Pelo de longitud media, liso o algo ondulado, hígado y blanco o negro y blanco, con flecos en orejas y patas.',
    'Caza de levantar y cobro, detección de explosivos y drogas, y compañía familiar. Necesita ejercicio y limpieza regular de oídos.',
    '48-51 cm a la cruz'
  ],
  'rottweiler' => [
    'Desciende de los molosos que acompañaban a las legiones romanas conduciendo ganado. Se asentó en la ciudad alemana de Rottweil, donde arreaba ganado y tiraba de carros de carniceros; en el siglo XX pasó a ser perro de policía y protección.',
    'Moloso grande, robusto y poderoso. Pelo corto, duro y denso, negro con marcas fuego bien definidas en cara, pecho y patas.',
    'Guarda, protección, policía, rescate y pastoreo. Requiere socialización temprana y adiestramiento constante. Riesgo de displasia y osteosarcoma.',
    '56-69 cm a la cruz'
  ],
  'husky_siberiano' => [
    'Lo crió el pueblo chukchi del noreste de Siberia como perro de trineo resistente. Llegó a Alaska en 1909 para carreras de trineo y se hizo famoso en 1925 al llevar suero antidiftérico a Nome.',
    'Perro de trineo mediano, ágil y ligero. Doble capa densa de longitud media, de cualquier color, con máscaras faciales típicas; ojos azules, marrones o de distinto color.',
    'Tiro, trineo, canicross y compañía activa. Muy escapista y poco guardián; necesita mucho ejercicio y tolera mal el calor.',
    '50-60 cm a la cruz'
  ],
  'san_bernardo' => [
    'Los monjes del hospicio del Gran San Bernardo, en los Alpes suizos, lo usaron desde el siglo XVII para guiar y rescatar viajeros en la nieve. El más célebre, Barry, salvó a más de 40 personas a inicios del siglo XIX.',
    'Moloso gigante de cabeza maciza y expresión amable, en variedades de pelo corto y pelo largo. Blanco con manchas rojizas y máscara oscura.',
    'Compañía familiar tranquila. Crece muy rápido: controlar dieta y ejercicio en cachorros. Tolera mal el calor y babea mucho.',
    '65-90 cm a la cruz'
  ],
  'doberman' => [
    'Lo creó hacia 1890 en Apolda (Alemania) Karl Friedrich Louis Dobermann, recaudador de impuestos que buscaba un perro protector. Probablemente mezcló pinscher alemán, rottweiler, pastores y lebreles.',
    'Perro grande, elegante y musculoso, de silueta cuadrada. Pelo corto, duro y pegado, negro o marrón con marcas fuego.',
    'Guarda, protección, policía y compañía; muy inteligente y sensible. Cribado cardíaco anual por miocardiopatía dilatada y prueba de von Willebrand.',
    '63-72 cm a la cruz'
  ],
  'newfoundland' => [
    'Originario de la isla de Terranova (Canadá), donde ayudaba a los pescadores a tirar de las redes y rescataba personas del agua. Se exportó a Inglaterra en el siglo XVIII y allí se fijó como raza.',
    'Perro gigante y fuerte, con doble capa impermeable y aceitosa, negra, marrón o blanca y negra (Landseer). Membranas interdigitales que facilitan el nado.',
    'Salvamento acuático y compañía familiar, muy paciente con niños. Tolera mal el calor; frecuentes estenosis subaórtica y displasia.',
    '66-71 cm a la cruz'
  ],
  'mastiff_ingles' => [
    'Uno de los molosos más antiguos de Gran Bretaña, usado como guardián de fincas. Casi desapareció tras la Segunda Guerra Mundial y se recuperó con ejemplares importados de Norteamérica.',
    'Perro gigante y macizo, de cabeza ancha con máscara negra. Pelo corto leonado, albaricoque o atigrado; es uno de los perros más pesados del mundo.',
    'Guardián tranquilo y compañía. Necesita espacio, crecimiento controlado y ejercicio moderado; su esperanza de vida es corta por el tamaño.',
    '70-80 cm a la cruz'
  ],
  'irish_setter' => [
    'Se desarrolló en Irlanda en el siglo XVIII a partir de setters rojo y blanco, seleccionando el color rojo sólido. Se usaba para señalar aves de caza en terreno abierto.',
    'Perro de muestra grande, esbelto y elegante. Pelo sedoso rojo caoba con flecos en orejas, pecho, patas y cola.',
    'Caza de muestra y compañía muy activa; madura tarde y conserva un carácter juguetón. Riesgo de dilatación-torsión gástrica.',
    '58-67 cm a la cruz'
  ],
  'gran_perro_montana' => [
    'Es la mayor de las cuatro razas boyeras suizas (sennenhunde). Tiraba de carros, arreaba ganado y guardaba granjas en los Alpes. Casi desapareció a finales del siglo XIX y se recuperó a partir de 1908 gracias a Franz Schertenleib y Albert Heim.',
    'Perro grande, robusto y de hueso fuerte. Pelo corto y denso tricolor: negro con marcas fuego y blancas simétricas en cara, pecho y patas.',
    'Tiro, guarda y compañía familiar. Crecimiento lento; propenso a displasias y a dilatación-torsión gástrica.',
    '60-72 cm a la cruz'
  ],
  # ── Gatos (altura aproximada a la cruz: los estándares felinos no la fijan) ──
  'devon_rex' => [
    'Surgió en 1960 en Buckfastleigh (Devon, Inglaterra) a partir de un gatito de pelo rizado llamado Kirlee. Su mutación es distinta de la del Cornish Rex, aunque al principio se intentó cruzarlos.',
    'Gato de cuerpo fino, orejas muy grandes de implantación baja y ojos grandes. Pelo corto, ondulado y suave, con muda escasa.',
    'Compañía muy sociable y juguetona; tolera mal el frío. Riesgo de miopatía hereditaria y frecuencia alta de grupo sanguíneo B (tipificar antes de transfundir o criar).',
    '25-30 cm a la cruz (aprox.)'
  ],
  'munchkin' => [
    'La raza parte de Blackberry, una gata de patas cortas encontrada en Luisiana en 1983. TICA la reconoció en 2003; otras asociaciones, como la FIFe, no la reconocen por motivos de bienestar.',
    'Gato de tamaño medio con patas muy cortas por una mutación autosómica dominante. Pelo corto o largo, de cualquier color.',
    'Compañía. Controlar el peso y vigilar lordosis y artrosis; no cruzar dos munchkins por el riesgo letal en homocigosis.',
    '13-18 cm a la cruz (aprox.)'
  ],
  'abisinio' => [
    'La tradición lo vincula a Zula, una gata llevada de Abisinia (Etiopía) a Inglaterra en 1868, aunque los estudios genéticos apuntan a un origen en la costa del océano Índico y el sudeste asiático.',
    'Gato esbelto y musculoso, de cabeza en cuña y orejas grandes. Pelo corto con ticking (cada pelo con bandas de color) en rojizo, canela, azul o cervato.',
    'Compañía activa y curiosa; necesita juego y lugares altos. Riesgo de amiloidosis renal y atrofia progresiva de retina.',
    '25-30 cm a la cruz (aprox.)'
  ],
  'siberiano' => [
    'Gato de los bosques de Rusia y Siberia, presente en el folclore ruso desde hace siglos. La cría organizada empezó en la década de 1980 y los primeros ejemplares llegaron a Estados Unidos en 1990.',
    'Gato grande y robusto, de maduración lenta (hasta los 5 años). Triple capa de pelo semilargo e impermeable, con collar en el cuello.',
    'Compañía familiar; tolera bien el frío. Algunos producen menos alérgeno Fel d 1, pero ningún gato es hipoalergénico garantizado.',
    '28-33 cm a la cruz (aprox.)'
  ],
  'exotico' => [
    'Se creó en Estados Unidos en la década de 1960 cruzando persas con American Shorthair y después con Burmés, para obtener un «persa de pelo corto». La CFA lo reconoció en 1967.',
    'Gato braquicéfalo de cuerpo cobby, cabeza redonda y ojos grandes. Pelo corto, denso y afelpado, en todos los colores del persa.',
    'Compañía tranquila de interior; necesita menos cepillado que el persa. Vigilar braquicefalia, epífora y poliquistosis renal (PKD).',
    '25-30 cm a la cruz (aprox.)'
  ],
  'burmes' => [
    'Desciende de Wong Mau, una gata marrón llevada de Birmania a San Francisco en 1930 por el doctor Joseph Thompson y cruzada con siameses. Hay líneas americana y europea con distinto tipo de cabeza.',
    'Gato compacto, musculoso y pesado para su tamaño. Pelo corto, satinado y pegado; color sable clásico y también azul, chocolate y lila. Ojos dorados.',
    'Compañía muy sociable y vocal. Riesgo de hipopotasemia, diabetes mellitus y síndrome de dolor orofacial en algunas líneas.',
    '25-30 cm a la cruz (aprox.)'
  ],
  'scottish_fold' => [
    'Parte de Susie, una gata de orejas plegadas hallada en una granja de Escocia en 1961. Las asociaciones británicas dejaron de registrarlo por los problemas articulares ligados a la mutación.',
    'Gato redondeado de tamaño medio con orejas plegadas hacia delante por una mutación (TRPV4) que afecta al cartílago. Pelo corto o largo.',
    'Compañía tranquila. Todos los ejemplares plegados tienen algún grado de osteocondrodisplasia y dolor articular; nunca cruzar plegado con plegado.',
    '20-25 cm a la cruz (aprox.)'
  ],
  'russian_blue' => [
    'Se cree que procede del puerto de Arcángel, en el norte de Rusia, desde donde marineros lo llevaron a Inglaterra hacia 1860. Se presentó en el Crystal Palace en 1875 como «gato de Arcángel».',
    'Gato elegante de cuerpo fino y largo. Doble capa corta y densa, azul uniforme con puntas plateadas; ojos verde intenso.',
    'Compañía de interior, reservado con extraños y muy apegado a su familia. Tiende al sobrepeso si no juega lo suficiente.',
    '25-30 cm a la cruz (aprox.)'
  ],
  'oriental' => [
    'Se desarrolló en Reino Unido y Estados Unidos en las décadas de 1950 y 1960 a partir del siamés, buscando su tipo corporal en colores sólidos y patrones sin puntos de color.',
    'Gato esbelto y tubular, de cabeza en cuña larga y orejas muy grandes. Pelo corto y brillante en más de 300 combinaciones de color; ojos verdes.',
    'Compañía muy vocal y dependiente de las personas. Como el siamés, riesgo de amiloidosis y atrofia progresiva de retina.',
    '23-28 cm a la cruz (aprox.)'
  ],
  'bombay' => [
    'Lo creó Nikki Horner en Louisville (Kentucky) en la década de 1950 cruzando Burmés sable con American Shorthair negro para lograr una «pantera en miniatura». La CFA lo reconoció en 1976.',
    'Gato de tamaño medio, musculoso y pesado. Pelo corto y satinado, negro hasta la raíz; ojos cobre o dorados.',
    'Compañía sociable y juguetona. Puede heredar defectos craneofaciales y miocardiopatía hipertrófica.',
    '23-28 cm a la cruz (aprox.)'
  ],
  'american_shorthair' => [
    'Desciende de los gatos que viajaron con los colonos europeos a Norteamérica para controlar roedores en barcos y granjas. Se reconoció como raza a inicios del siglo XX y en 1966 cambió su nombre de Domestic Shorthair al actual.',
    'Gato robusto y de hueso fuerte, de cabeza ancha y mejillas llenas. Pelo corto, denso y duro; el tabby plateado clásico es el patrón más conocido.',
    'Compañía familiar equilibrada y buen cazador. Tiende al sobrepeso; cribado de miocardiopatía hipertrófica.',
    '25-30 cm a la cruz (aprox.)'
  ],
  'balinese' => [
    'Surgió en Estados Unidos en la década de 1940 por mutaciones de pelo largo en camadas de siameses. Se llamó balinés por la gracia de los bailarines de Bali y se reconoció en la década de 1960.',
    'Siamés de pelo semilargo y sedoso, sin subpelo, con cola en penacho. Patrón colorpoint y ojos azules.',
    'Compañía muy sociable y vocal. Hereda los riesgos del siamés (atrofia progresiva de retina, amiloidosis).',
    '23-28 cm a la cruz (aprox.)'
  ],
  'birman' => [
    'Según la leyenda era el gato sagrado de los templos de Birmania. Su cría documentada empieza en Francia en la década de 1920; casi desapareció en la Segunda Guerra Mundial y se reconstruyó con cruces.',
    'Gato colorpoint de pelo semilargo y sedoso, cuerpo largo y robusto. Ojos azules y «guantes» blancos en las cuatro patas, su rasgo distintivo.',
    'Compañía tranquila y afectuosa; su pelo se enreda poco. Cribado de enfermedad renal.',
    '20-25 cm a la cruz (aprox.)'
  ],
  'bosque_noruego' => [
    'Gato natural de los bosques escandinavos, presente en la mitología nórdica. Casi desapareció a mediados del siglo XX; un programa de cría noruego lo recuperó y la FIFe lo reconoció en 1977.',
    'Gato grande y robusto, de perfil recto y orejas con penachos. Doble capa semilarga impermeable con collar y «pantalones»; cola larga y poblada.',
    'Compañía familiar y gran trepador; tolera bien el frío. Riesgo de glucogenosis tipo IV y miocardiopatía hipertrófica.',
    '30-40 cm a la cruz (aprox.)'
  ],
  'savannah' => [
    'Nació en 1986 en Estados Unidos del cruce de un serval africano macho con una gata siamesa. Las primeras generaciones (F1-F3) están restringidas en muchos países; TICA lo reconoció como raza en 2012.',
    'Gato alto, esbelto y de patas largas, con orejas grandes y pelaje moteado sobre fondo dorado, plata o negro. Los F1 pueden superar los 10 kg.',
    'Compañía para tutores con experiencia y espacio; muy activo, gran saltador y atraído por el agua. Revisar la legislación local antes de adquirirlo.',
    '35-43 cm a la cruz (aprox.)'
  ],
  'norwegian_forest' => [
    'Línea de cría de Bosque de Noruega seleccionada por mayor tamaño y estructura ósea, dentro del mismo estándar de la raza nativa escandinava reconocida por la FIFe en 1977.',
    'Ejemplares en el extremo alto del estándar: cuerpo largo y musculoso, cola muy poblada y doble capa semilarga impermeable. Machos claramente más grandes que las hembras.',
    'Compañía familiar; necesita estructuras para trepar y control de peso. Mismos cribados que la raza (glucogenosis tipo IV, miocardiopatía hipertrófica).',
    '30-40 cm a la cruz (aprox.)'
  ],
  'turkish_van' => [
    'Procede de la región del lago Van, en el este de Turquía, donde es conocido por nadar. Llegó a Reino Unido en 1955 con las fotógrafas Laura Lushington y Sonia Halliday.',
    'Gato grande y musculoso, de pelo semilargo sin subpelo y tacto de cachemir. Patrón van: cuerpo blanco con color solo en la cabeza y la cola.',
    'Compañía activa; le gusta el agua y el juego. Madura despacio (3-5 años).',
    '30-35 cm a la cruz (aprox.)'
  ]
}.freeze

def separar_frases_pegadas(texto)
  patron = /([[:lower:]0-9)%])\s+(#{VERBOS_FRASE.join('|')})\s/
  texto.gsub(patron) { "#{Regexp.last_match(1)}. #{Regexp.last_match(2)} " }
end

def quitar_frases_repetidas(texto)
  vistas = {}
  frases = texto.split(/(?<=\.)\s+/).reject do |f|
    clave = f.strip.downcase
    repetida = vistas.key?(clave)
    vistas[clave] = true
    repetida
  end
  frases.join(' ')
end

def limpiar_texto(texto)
  return texto unless texto.is_a?(String)

  quitar_frases_repetidas(separar_frases_pegadas(texto))
end

data = JSON.parse(File.read(ENC_PATH))
stats = Hash.new(0)

data['animales'].each do |animal|
  %w[pequena mediana grande].each do |size|
    (animal.dig('razas', size) || []).each do |raza|
      (raza['contraindicaciones_especie'] || []).map! do |c|
        nuevo = TRADUCCIONES.fetch(c, c)
        stats[:traducciones] += 1 if nuevo != c
        nuevo
      end

      %w[cuidados alimentacion].each do |campo|
        limpio = limpiar_texto(raza[campo])
        next if limpio == raza[campo]

        raza[campo] = limpio
        stats[:frases_limpiadas] += 1
      end

      if (desc = DESCRIPCIONES[raza['id']]) && raza['descripcion'] != desc
        raza['descripcion'] = desc
        stats[:descripciones] += 1
      end

      ficha = FICHAS[raza['id']]
      next unless ficha

      %w[historia caracteristicas aptitudes altura].zip(ficha).each do |campo, valor|
        next if raza[campo] == valor

        raza[campo] = valor
        stats[:campos_ficha] += 1
      end
    end
  end
end

File.write(ENC_PATH, JSON.pretty_generate(data))
puts "Curación de razas: #{stats.map { |k, v| "#{k}=#{v}" }.join(', ')}"
