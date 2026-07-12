# frozen_string_literal: true

BREED_DATA.merge!({
  'singapura' => {
    historia: 'Descubierta en los años 70 en Singapur, de gatos callejeros de tamaño diminuto. Importada a EE.UU. por Hal y Tommy Meadow. Una de las razas más pequeñas reconocidas.',
    caracteristicas: 'Cuerpo compacto musculoso, pelaje corto sepia (marrón claro con puntas oscuras), ojos grandes verdes o avellana. Peso 2-4 kg.',
    aptitudes: 'Compañía en espacios reducidos, perro-gato por su energía, exposición felina.',
    altura: '15-20 cm a la cruz',
    emergencias: 'Hipoglucemia en cachorros, dificultad en el parto, insuficiencia renal aguda y traumatismos por fragilidad.'
  },
  'bengala' => {
    historia: 'Creada en EE.UU. en los 60 cruzando gato doméstico con gato leopardo asiático (Prionailurus bengalensis). Objetivo: aspecto salvaje con temperamento doméstico.',
    caracteristicas: 'Cuerpo atlético musculoso, pelaje moteado (spotted) o marmolado (marbled), vientre blanco. Glitter en el pelaje. Peso 4-7 kg.',
    aptitudes: 'Agility felino, compañía activa, clicker training, paseos con arnés.',
    altura: '20-25 cm a la cruz',
    emergencias: 'Parálisis por tromboembolismo cardíaco, obstrucción urinaria, convulsiones y golpe de calor.'
  },
  'siames' => {
    historia: 'Raza natural de Tailandia (Siam), documentada en manuscritos del siglo XIV. Llegó a Occidente en el siglo XIX. Uno de los fundadores de las razas orientales modernas.',
    caracteristicas: 'Cuerpo oriental esbelto, cabeza triangular, orejas grandes, ojos azules almendrados. Pelaje corto colorpoint. Peso 3-6 kg.',
    aptitudes: 'Compañía vocal, perro-gato, aprendizaje de trucos, convivencia familiar activa.',
    altura: '20-25 cm a la cruz',
    emergencias: 'Crisis asmática, obstrucción urinaria en machos, insuficiencia hepática por amiloidosis y convulsiones.'
  },
  'persa' => {
    historia: 'Introducido en Europa desde Persia (Irán) en el siglo XVII. Refinado en Inglaterra y EE.UU. con selección del morfotipo braquicéfalo actual.',
    caracteristicas: 'Cuerpo cobby, cabeza redonda braquicéfala, ojos grandes, pelaje largo y denso. Colores variados. Peso 3-5,5 kg.',
    aptitudes: 'Compañía sedentaria, exposición, mascota de interior tranquila.',
    altura: '20-25 cm a la cruz',
    emergencias: 'Dificultad respiratoria aguda, obstrucción urinaria, insuficiencia renal aguda y úlceras corneales.'
  },
  'british_shorthair' => {
    historia: 'Gato británico de pelo corto originario de Roma. Refinado en el siglo XIX. El color azul es el más icónico. Inspiró al Cheshire Cat de Alicia.',
    caracteristicas: 'Cuerpo robusto cobby, cabeza redonda, mejillas llenas, pelaje denso y felpudo. Ojos cobre o azul. Peso 4-8 kg.',
    aptitudes: 'Compañía tranquila, convivencia con niños y perros, mascota de apartamento.',
    altura: '28-30 cm a la cruz',
    emergencias: 'Parálisis por trombo cardíaco, obstrucción urinaria, insuficiencia cardíaca aguda y cetoacidosis por obesidad.'
  },
  'maine_coon' => {
    historia: 'Raza natural de Maine (EE.UU.), posible cruce de gatos europeos con gatos salvajes locales. Reconocida oficialmente en 1861. Una de las razas más grandes.',
    caracteristicas: 'Cuerpo largo y musculoso, pelaje semilargo con collar, orejas con mechones lince, cola esponjosa. Peso 5-11 kg.',
    aptitudes: 'Compañía familiar, caza de roedores, convivencia con perros, paseos con arnés.',
    altura: '25-41 cm a la cruz',
    emergencias: 'Parálisis por trombo, insuficiencia cardíaca, obstrucción urinaria y fracturas por displasia de cadera.'
  },
  'ragdoll' => {
    historia: 'Desarrollada en California en los 60 por Ann Baker a partir de gatos callejeros de temperamento excepcionalmente dócil. Nombre por relajarse completamente al ser cargada.',
    caracteristicas: 'Cuerpo grande semilargo, pelaje sedoso colorpoint, ojos azules intensos. Peso 4,5-9 kg. Relajación completa al ser sostenida.',
    aptitudes: 'Compañía terapéutica, mascota familiar dócil, convivencia con niños.',
    altura: '23-28 cm a la cruz',
    emergencias: 'Obstrucción urinaria (urgencia en machos), parálisis por trombo cardíaco, insuficiencia renal aguda.'
  },
  'canario' => {
    historia: 'Domesticado en las Islas Canarias desde el siglo XV a partir del canario silvestre africano (Serinus canaria). Símbolo de las islas. Muy valorado por su canto.',
    caracteristicas: 'Ave pequeña 12-13 cm, plumaje amarillo (selección) o variado en silvestres. Peso 15-30 g. Pico fino adaptado a semillas.',
    aptitudes: 'Canto, exposición ornitológica, compañía auditiva, cría selectiva por timbre.',
    altura: '12-13 cm de longitud',
    emergencias: 'Dificultad respiratoria por ácaros traqueales, hipotermia, deshidratación y egg binding en hembras.'
  },
  'periquito' => {
    historia: 'Periquito común australiano (Melopsittacus undulatus), domesticado desde mediados del siglo XIX. Una de las aves de compañía más populares del mundo.',
    caracteristicas: 'Loro pequeño 18 cm, plumaje verde amarillento con barras negras en silvestre. Mutaciones de color numerosas. Peso 30-40 g.',
    aptitudes: 'Compañía, imitación de sonidos, cría en aviario, ideal para principiantes.',
    altura: '18 cm de longitud',
    emergencias: 'Dificultad respiratoria, egg binding, sangrado por picaje y deshidratación por diarrea.'
  },
  'cacatua' => {
    historia: 'Familia Cacatuidae de Australia y Oceanía. Domesticadas como mascotas desde el siglo XIX. Muy longevas y demandantes de atención social.',
    caracteristicas: 'Loro mediano-grande con cresta eréctil, pico curvado potente. Plumaje blanco, rosa o negro según especie. Peso 300-1200 g.',
    aptitudes: 'Compañía intensiva, imitación vocal, acrobacias, vínculo profundo con el cuidador.',
    altura: '30-50 cm según especie',
    emergencias: 'Aspergilosis respiratoria aguda, hemorragia por picaje severo, intoxicación por Teflon y prolapso cloacal.'
  },
  'guacamayo' => {
    historia: 'Grandes loros de América tropical, venerados por culturas precolombinas. Domesticados con cautela por su longevidad (50-80 años) y necesidades complejas.',
    caracteristicas: 'Loro grande 80-100 cm con cola larga, plumaje vívido rojo-azul-amarillo. Pico masivo. Peso 900-1700 g.',
    aptitudes: 'Compañía de por vida, exhibición, conservación, educación ambiental.',
    altura: '80-100 cm de longitud total',
    emergencias: 'PDD con regurgitación severa, aspergilosis, intoxicación por metales pesados y hemorragia por golpe con pico.'
  },
  'pony_shetland' => {
    historia: 'Originario de las islas Shetland (Escocia), adaptado al clima duro y pastos escasos. Introducido en minas inglesas en el siglo XIX. Pony más fuerte proporcionalmente.',
    caracteristicas: 'Cuerpo compacto y musculoso, crin y cola abundantes, pelaje grueso invernal. Altura máxima 107 cm. Peso 150-200 kg.',
    aptitudes: 'Monta infantil, tiro ligero, compañía, terapia ecuestre, pastoreo.',
    altura: '71-107 cm a la cruz',
    emergencias: 'Laminitis aguda, cólico, impactación por sobrealimentación y colapso por estrés metabólico.'
  },
  'cuarto_milla' => {
    historia: 'Caballo americano criado para carreras de un cuarto de milla. Desciende de caballos coloniales españoles. Raza más popular de EE.UU. con más de 3 millones registrados.',
    caracteristicas: 'Cuerpo musculoso y compacto, pecho ancho, extremidades fuertes. Altura 142-163 cm. Peso 450-600 kg. Colores variados.',
    aptitudes: 'Carreras, rodeo, ganadería, monta western, doma vaquera y ocio familiar.',
    altura: '142-163 cm a la cruz',
    emergencias: 'Crisis HYPP con parálisis, cólico quirúrgico, rabdomiólisis (PSSM) y fracturas por traumatismo.'
  },
  'caballo_andaluz' => {
    historia: 'Caballo español (PRE) de Andalucía, descendiente del caballo ibérico antiguo. Base de la doma clásica europea. Reconocido por Real Cédula desde el siglo XVI.',
    caracteristicas: 'Cuerpo compacto y elegante, cuello arqueado, crin y cola abundantes. Gris, bayo o negro. Altura 155-170 cm. Peso 500-650 kg.',
    aptitudes: 'Doma clásica, alta escuela, rejoneo, enganches, tauromaquia y ocio.',
    altura: '155-170 cm a la cruz',
    emergencias: 'Cólico con distensión, laminitis, fracturas por patada y hemorragia por sarcoides ulcerados.'
  },
  'hereford' => {
    historia: 'Desarrollada en Herefordshire (Inglaterra) en el siglo XVIII por los hermanos Tom y Ben Tomkins. Reconocida por su rusticidad y carne de calidad. Exportada mundialmente.',
    caracteristicas: 'Cuerpo musculoso de carne, pelaje rojo con cara blanca característica. Sin cuernos en líneas polled. Peso 450-900 kg según variedad.',
    aptitudes: 'Producción de carne, pastoreo extensivo, cruzamiento terminal, banco genético.',
    altura: '120-140 cm a la cruz',
    emergencias: 'Timpanismo con dificultad respiratoria, queratoconjuntivitis severa, parto distócico y intoxicación por nitratos.'
  },
  'angus' => {
    historia: 'Originaria de Aberdeenshire (Escocia) en el siglo XVIII. Angus negro sin cuernos es la raza de carne más extendida del mundo. Introducida en América en 1873.',
    caracteristicas: 'Pelaje negro uniforme (también rojo en variante Red Angus), sin cuernos, cuerpo compacto y musculoso. Peso 550-1000 kg.',
    aptitudes: 'Carne de calidad con marmoleo, pastoreo, cruzamiento, eficiencia alimentaria.',
    altura: '120-140 cm a la cruz',
    emergencias: 'Clostridiosis con muerte súbita, neumonía grave en feedlots, distocia y prolapo vaginal.'
  },
  'holstein' => {
    historia: 'Desarrollada en Holanda y norte de Alemania. Importada masivamente a EE.UU. en el siglo XIX. Representa el 90% de las vacas lecheras comerciales del mundo.',
    caracteristicas: 'Gran tamaño, pelaje blanco y negro (o rojo en Red Holstein). Ubre grande y pendular. Peso 600-900 kg. Alta producción láctea.',
    aptitudes: 'Producción lechera intensiva, mejoramiento genético lácteo, biotecnología reproductiva.',
    altura: '145-165 cm a la cruz',
    emergencias: 'Hipocalcemia posparto, mastitis aguda gangrenosa, torsion uterina y cetosis grave.'
  },
  'cerdo_iberico' => {
    historia: 'Raza autóctona de la península ibérica criada en dehesa desde la antigüedad. Base del jamón ibérico de bellota. Adaptada al ecosistema mediterráneo.',
    caracteristicas: 'Capa oscura, patas negras (pata negra), morro alargado, orejas caídas. Crecimiento lento. Peso adulto 120-180 kg.',
    aptitudes: 'Producción de jamón ibérico, montanera en dehesa, conservación genética, agroturismo.',
    altura: '70-85 cm a la cruz',
    emergencias: 'Golpe de calor, parto distócico, intoxicación por bellotas en exceso y colapso por estrés de transporte.'
  },
  'cerdo_landrace' => {
    historia: 'Desarrollada en Dinamarca a finales del siglo XIX. Famosa por su prolificidad (12-16 lechones/camada) y orejas caídas. Base de cruzamientos comerciales globales.',
    caracteristicas: 'Pelaje blanco, cuerpo largo, orejas grandes caídas que cubren los ojos. Peso 200-320 kg. Excelente aptitud materna.',
    aptitudes: 'Línea materna en cruzamientos, producción intensiva, mejoramiento de prolificidad.',
    altura: '75-90 cm a la cruz',
    emergencias: 'Síndrome de estrés porcino, prolapso rectal/uterino, MMA posparto y eclampsia en lactación.'
  },
  'cerdo_duroc' => {
    historia: 'Originario de EE.UU. (New York/New Jersey) a partir de cerdos rojos de origen africano y europeo. Nombre del Duque de York. Apreciado por carne marmolada y jugosa.',
    caracteristicas: 'Pelaje rojo dorado, cuerpo musculoso y compacto, orejas caídas medias. Peso 300-400 kg. Crecimiento rápido.',
    aptitudes: 'Línea terminal en cruzamientos, carne de calidad, producción extensiva e intensiva.',
    altura: '80-95 cm a la cruz',
    emergencias: 'Golpe de calor, cojera severa por osteocondrosis, PCV2 con colapso y hemorragia digestiva.'
  },
  'conejo_mini' => {
    historia: 'Seleccionado en Europa a partir de razas enanas (Netherland Dwarf, Polish). Creado para compañía en espacios urbanos desde mediados del siglo XX.',
    caracteristicas: 'Cuerpo compacto, cabeza redonda, orejas cortas erguidas. Pelaje corto variado. Peso 0,8-1,5 kg.',
    aptitudes: 'Mascota de compañía, terapia asistida, exposición de conejos enanos.',
    altura: '20-30 cm de longitud',
    emergencias: 'Estasis gastrointestinal, hipotermia, fracturas por caídas y maloclusión con inanición.'
  },
  'conejo_angora' => {
    historia: 'Originario de Ankara (Turquía), criado por su lana (angora) desde el siglo XVIII. Introducido en Europa como mascota y productor de fibra.',
    caracteristicas: 'Pelaje largo lanoso que requiere esquileo cada 3-4 meses. Cuerpo mediano. Peso 2-4 kg. Colores variados.',
    aptitudes: 'Producción de fibra angora, compañía, exposición, artesanía textil.',
    altura: '35-45 cm de longitud',
    emergencias: 'Tricobezoar con estasis, golpe de calor por pelaje denso, pododermatitis y wool block.'
  },
  'conejo_gigante' => {
    historia: 'Creado en Flandes (Bélgica) en el siglo XVI como carne y piel. Gigante de Flandes es una de las razas más grandes, también popular como mascota dócil.',
    caracteristicas: 'Cuerpo masivo y musculoso, cabeza grande, orejas largas caídas. Pelaje denso. Peso 6-10 kg. Color arlequín, gris o blanco.',
    aptitudes: 'Compañía (temperamento dócil), carne, piel, terapia asistida por tamaño.',
    altura: '50-70 cm de longitud',
    emergencias: 'Estasis GI, pododermatitis ulcerada, colapso cardíaco y fracturas por peso excesivo.'
  },
  'serpiente_corn' => {
    historia: 'Serpiente del maíz (Pantherophis guttatus) del sureste de EE.UU. Una de las serpientes más criadas en cautiverio. Docenas de morfos de color seleccionados.',
    caracteristicas: 'Serpiente delgada 90-150 cm, escamas lisas con patrón de manchas. Colores variados por selección. Peso 500-900 g.',
    aptitudes: 'Mascota para principiantes en reptiles, educación, cría de morfos, exhibición.',
    altura: '90-150 cm de longitud',
    emergencias: 'Muda retenida en ojos/cola, estomatitis severa, quemaduras por lámpara y regurgitación crónica.'
  },
  'tortuga' => {
    historia: 'Reptiles con más de 200 millones de años de evolución. Tortugas terrestres (Testudinidae) y acuáticas domesticadas desde la antigüedad. Longevas (30-80+ años).',
    caracteristicas: 'Caparazón óseo protector, extremidades adaptadas (patas con uñas en terrestres, aletas en acuáticas). Tamaño muy variable según especie.',
    aptitudes: 'Compañía longeva, educación ambiental, control biológico de algas (acuáticas).',
    altura: 'Según especie: 15-60 cm de caparazón',
    emergencias: 'Enfermedad ósea metabólica con caparazón blando, infección respiratoria, shell rot con olor fétido y prolapso cloacal.'
  },
  'iguana' => {
    historia: 'Iguana verde (Iguana iguana) de América Central y del Sur. Muy popular como mascota en los 80-90. Requiere instalaciones grandes y manejo especializado.',
    caracteristicas: 'Lagarto verde grande hasta 2 m incluida cola. Cresta dorsal, escamas subtympanicas. Cola con autotomía. Peso 4-8 kg adulto.',
    aptitudes: 'Exhibición, educación, compañía para expertos en reptiles.',
    altura: '150-200 cm incluida cola',
    emergencias: 'Fracturas por caídas, gota con parálisis, quemaduras térmicas y deshidratación severa.'
  },
  'betta' => {
    historia: 'Betta splendens del sudeste asiático, criado en Tailandia desde hace siglos para combates (luchadores de Siam). Seleccionado por aletas espectaculares.',
    caracteristicas: 'Pez laberíntido 5-7 cm con aletas largas en machos. Colores vibrantes. Órgano laberíntico para respirar aire. Machos territoriales.',
    aptitudes: 'Acuario ornamental, exhibición, cría de líneas de aletas, mascota de escritorio.',
    altura: '5-7 cm de longitud',
    emergencias: 'Hidropesía, podredumbre de aletas avanzada, intoxicación por amoniaco y ahogamiento por aletas muy largas.'
  },
  'goldfish' => {
    historia: 'Domesticado en China hace más de 1000 años a partir de la carpa común (Cyprinus carpio). Símbolo de prosperidad. Cientos de variedades morfológicas.',
    caracteristicas: 'Pez de agua fría 15-30 cm según variedad. Cuerpo ovalado o cometa. Colores naranja, blanco, negro, calico. Peso 100-300 g.',
    aptitudes: 'Acuario/estanque ornamental, terapia, tradición cultural, estanques zen.',
    altura: '15-30 cm según variedad',
    emergencias: 'Intoxicación por amoniaco/nitritos, trastorno vejiga natatoria con nado invertido, ich masivo y oxigenación insuficiente.'
  },
  'carpa_koi' => {
    historia: 'Carpa común seleccionada en Japón desde el siglo XIX (Niigata). Símbolo de perseverancia y buena fortuna. Estanques koi son arte japonés tradicional.',
    caracteristicas: 'Pez grande 60-90 cm, cuerpo robusto con escamas o escamas de espejo. Patrones de color blanco, rojo, negro, amarillo. Peso 5-15 kg.',
    aptitudes: 'Estanque ornamental, exposición, cría selectiva de patrones, turismo y cultura.',
    altura: '60-90 cm de longitud',
    emergencias: 'KHV con mortalidad masiva, úlceras bacterianas extensas, hipoxia por algas y parásitos en branquias.'
  },
  'oveja_merino' => {
    historia: 'Desarrollada en España (merino español) y perfeccionada en Australia. Lana fina de máxima calidad. Base de la industria textil mundial durante siglos.',
    caracteristicas: 'Lana fina y densa en pliegues, cuerpo mediano robusto. Sin cuernos en líneas modernas. Peso 45-90 kg. Lana 18-24 micras.',
    aptitudes: 'Producción de lana fina, carne, pastoreo en zonas áridas, conservación de dehesas.',
    altura: '60-70 cm a la cruz',
    emergencias: 'Miasis con larvas en heridas, pedero con cojera severa, parto distócico y intoxicación por plantas.'
  },
  'cabra_nubia' => {
    historia: 'Creada en Inglaterra cruzando cabras británicas con cabras africanas y orientales. Orejas largas caídas distintivas. Leche rica en gruta ideal para quesos.',
    caracteristicas: 'Cuerpo grande, perfil convexo, orejas largas caídas, pelaje corto variado. Peso 50-110 kg. Alta producción lechera.',
    aptitudes: 'Producción lechera, quesos artesanales, carne, control de maleza, agroturismo.',
    altura: '70-85 cm a la cruz',
    emergencias: 'Timpanismo agudo, bloqueo urinario en machos, parto distócico y mastitis gangrenosa.'
  },
  'llama' => {
    historia: 'Domesticada en los Andes hace más de 5000 años junto al alpaca. Animal de carga, fibra y guarda de rebaños. Símbolo cultural andino.',
    caracteristicas: 'Camélido sin joroba, cuello largo, orejas banana. Pelaje lanoso variado. Peso 130-200 kg. Altura 1,7-1,9 m.',
    aptitudes: 'Carga (hasta 30 kg), guarda de ovejas, fibra (llama fiber), trekking, terapia, compañía.',
    altura: '110-130 cm a la cruz',
    emergencias: 'Golpe de calor, anemia severa por parásitos, parto distócico y cólico por calculos.'
  },
  'hamster' => {
    historia: 'Hámster dorado sirio descubierto en Siria en 1930. Domesticado para laboratorio y luego mascota. Especie más popular; también Roborovski, Campbell, chino.',
    caracteristicas: 'Roedor pequeño 13-18 cm, mejillas con bolsas alimentarias, pelaje dorado o variado. Cola corta. Peso 25-200 g según especie.',
    aptitudes: 'Mascota para niños mayores, observación nocturna, cría, investigación.',
    altura: '13-18 cm de longitud',
    emergencias: 'Wet tail con deshidratación, prolapso rectal, torpor por frío extremo y maloclusión con inanición.'
  },
  'cobaya' => {
    historia: 'Domesticada en los Andes hace 7000 años para alimento y rituales. Llegó a Europa en el siglo XVI. Mascota familiar popular por su carácter sociable.',
    caracteristicas: 'Cuerpo robusto sin cola, cabeza grande, patas cortas. Pelaje liso, abisinio o peruano. Peso 700-1200 g. Vocalizaciones variadas.',
    aptitudes: 'Compañía familiar, terapia, detección (tuberculosis en laboratorio), mascota infantil.',
    altura: '20-30 cm de longitud',
    emergencias: 'Escorbuto agudo, maloclusión con inanición, neumonía bacteriana y convulsiones por hipoglucemia.'
  },
  'huron' => {
    historia: 'Domesticado hace más de 2000 años a partir del turón europeo (Mustela putorius) para caza de conejos. Mascota desde los años 80. Requiere vacunación obligatoria en muchos países.',
    caracteristicas: 'Cuerpo alargado flexible, pelaje variado (hurón), ojos oscuros. Peso 0,7-2 kg. Muy olfactivo y curioso.',
    aptitudes: 'Compañía activa, caza de roedores, terapia, obediencia (sí, hurones).',
    altura: '35-50 cm incluida cola',
    emergencias: 'Crisis hipoglucémica por insulinoma, obstrucción urinaria en machos, moquillo (urgencia) y shock anafiláctico.'
  }
})

NEW_DISEASES = {
  'chihuahua' => [
    {'nombre' => 'Traumatismo por caída', 'gravedad' => 'grave', 'sintomas' => ['Fractura de extremidades', 'Dolor al manipular', 'Cojera aguda', 'Hinchazón articular', 'Shock'], 'diagnostico' => 'Radiografías y examen ortopédico.', 'tratamiento' => 'Inmovilización, analgesia y cirugía si es necesario.', 'prevencion' => 'Evitar saltos desde altura y usar transportín seguro.'},
    {'nombre' => 'Colapso traqueal', 'gravedad' => 'moderada', 'sintomas' => ['Tos seca tipo graznido', 'Dificultad respiratoria', 'Cianosis en crisis', 'Intolerancia al ejercicio'], 'diagnostico' => 'Radiografías dinámicas y fluoroscopia.', 'tratamiento' => 'Arnés, control de peso, antitusígenos y cirugía en casos graves.', 'prevencion' => 'Arnés en lugar de collar y mantener peso ideal.'}
  ],
  'yorkshire' => [
    {'nombre' => 'Hipoglucemia', 'gravedad' => 'grave', 'sintomas' => ['Temblores', 'Debilidad', 'Convulsiones', 'Letargo'], 'diagnostico' => 'Glucosa en sangre.', 'tratamiento' => 'Glucosa oral inmediata y alimentación frecuente.', 'prevencion' => 'Comidas frecuentes en cachorros y evitar ayunos.'},
    {'nombre' => 'Atrofia progresiva de retina', 'gravedad' => 'grave', 'sintomas' => ['Ceguera nocturna', 'Torpeza en oscuridad', 'Dilatación pupilar'], 'diagnostico' => 'Examen oftalmológico y prueba genética.', 'tratamiento' => 'Sin cura; adaptación del entorno.', 'prevencion' => 'Prueba genética antes de la cría.'}
  ],
  'pomerania' => [
    {'nombre' => 'Hidrocefalia', 'gravedad' => 'grave', 'sintomas' => ['Cabeza abombada', 'Desorientación', 'Convulsiones', 'Movimientos circulares'], 'diagnostico' => 'RMN y ecografía por fontanela.', 'tratamiento' => 'Medicación para reducir LCR o derivación quirúrgica.', 'prevencion' => 'No criar ejemplares afectados.'},
    {'nombre' => 'Hipoglucemia', 'gravedad' => 'grave', 'sintomas' => ['Temblores', 'Debilidad', 'Convulsiones'], 'diagnostico' => 'Glucosa en sangre.', 'tratamiento' => 'Glucosa oral y estabilización.', 'prevencion' => 'Alimentación frecuente en toy.'}
  ],
  'maltes' => [
    {'nombre' => 'Colapso traqueal', 'gravedad' => 'moderada', 'sintomas' => ['Tos seca', 'Dificultad respiratoria', 'Intolerancia al ejercicio'], 'diagnostico' => 'Radiografías traqueales.', 'tratamiento' => 'Arnés, antitusígenos y control de peso.', 'prevencion' => 'Evitar collar y sobrepeso.'},
    {'nombre' => 'Shunt portosistémico', 'gravedad' => 'grave', 'sintomas' => ['Desorientación postprandial', 'Convulsiones', 'Retraso de crecimiento'], 'diagnostico' => 'Ácidos biliares y ecografía.', 'tratamiento' => 'Dieta baja en proteínas y cirugía.', 'prevencion' => 'No criar portadores.'}
  ],
  'beagle' => [
    {'nombre' => 'Discopatía intervertebral', 'gravedad' => 'grave', 'sintomas' => ['Dolor de espalda', 'Debilidad en patas', 'Parálisis'], 'diagnostico' => 'RMN y examen neurológico.', 'tratamiento' => 'Reposo, AINE o cirugía.', 'prevencion' => 'Control de peso y evitar saltos.'},
    {'nombre' => 'Glaucoma', 'gravedad' => 'grave', 'sintomas' => ['Ojo rojo y doloroso', 'Pupila dilatada', 'Ceguera'], 'diagnostico' => 'Tonometría ocular.', 'tratamiento' => 'Gotas hipotensoras y cirugía.', 'prevencion' => 'Revisiones oftalmológicas.'}
  ],
  'cocker' => [
    {'nombre' => 'Glaucoma', 'gravedad' => 'grave', 'sintomas' => ['Ojo rojo', 'Dolor ocular', 'Pupila dilatada'], 'diagnostico' => 'Tonometría y examen oftalmológico.', 'tratamiento' => 'Medicación y cirugía en casos avanzados.', 'prevencion' => 'Detección temprana en revisiones.'},
    {'nombre' => 'Hipotiroidismo', 'gravedad' => 'moderada', 'sintomas' => ['Aumento de peso', 'Letargo', 'Pérdida de pelo'], 'diagnostico' => 'T4 y TSH en sangre.', 'tratamiento' => 'Levotiroxina de por vida.', 'prevencion' => 'Controles anuales en adultos.'}
  ],
  'border_collie' => [
    {'nombre' => 'Anemia de estres eritrocitario (IMHA)', 'gravedad' => 'grave', 'sintomas' => ['Encías pálidas', 'Letargo', 'Orina oscura', 'Ictericia'], 'diagnostico' => 'Hemograma y Coombs.', 'tratamiento' => 'Inmunosupresores y transfusiones.', 'prevencion' => 'No prevenible; detección temprana.'},
    {'nombre' => 'Osteocondrosis disecante', 'gravedad' => 'moderada', 'sintomas' => ['Cojera', 'Rigidez articular', 'Dolor al ejercicio'], 'diagnostico' => 'Radiografías y artroscopia.', 'tratamiento' => 'Reposo, AINE o cirugía artroscópica.', 'prevencion' => 'Crecimiento controlado y dieta equilibrada.'}
  ],
  'bulldog_frances' => [
    {'nombre' => 'Torsión gástrica', 'gravedad' => 'grave', 'sintomas' => ['Abdomen distendido', 'Arcadas', 'Inquietud', 'Colapso'], 'diagnostico' => 'Radiografía abdominal urgente.', 'tratamiento' => 'Cirugía de emergencia.', 'prevencion' => 'Comidas fraccionadas y reposo postprandial.'},
    {'nombre' => 'Enfermedad del disco intervertebral', 'gravedad' => 'grave', 'sintomas' => ['Dolor de espalda', 'Parálisis de patas traseras'], 'diagnostico' => 'RMN.', 'tratamiento' => 'Reposo, AINE o cirugía.', 'prevencion' => 'Control de peso y evitar saltos.'}
  ],
  'labrador' => [
    {'nombre' => 'Lipoma múltiple', 'gravedad' => 'leve', 'sintomas' => ['Bultos blandos bajo la piel', 'Crecimiento lento'], 'diagnostico' => 'Citología por aspiración.', 'tratamiento' => 'Observación o extirpación si molestan.', 'prevencion' => 'Control de peso; no prevenible genéticamente.'},
    {'nombre' => 'Epilepsia idiopática', 'gravedad' => 'grave', 'sintomas' => ['Convulsiones', 'Pérdida de consciencia', 'Salivación'], 'diagnostico' => 'Descarte de otras causas y RMN.', 'tratamiento' => 'Anticonvulsivantes de por vida.', 'prevencion' => 'No criar afectados.'}
  ],
  'pastor_aleman' => [
    {'nombre' => 'Pancreatitis', 'gravedad' => 'grave', 'sintomas' => ['Vómitos', 'Dolor abdominal', 'Posición de oración'], 'diagnostico' => 'Lipasa pancreática específica (cPLI).', 'tratamiento' => 'Fluidoterapia, ayuno y analgesia.', 'prevencion' => 'Evitar comida grasa y obesidad.'},
    {'nombre' => 'Hemangiosarcoma esplénico', 'gravedad' => 'grave', 'sintomas' => ['Colapso súbito', 'Encías pálidas', 'Abdomen distendido'], 'diagnostico' => 'Ecografía abdominal urgente.', 'tratamiento' => 'Esplenectomía de emergencia y quimioterapia.', 'prevencion' => 'No prevenible; ecografías en seniors.'}
  ],
  'golden_retriever' => [
    {'nombre' => 'Lipoma y mastocitoma', 'gravedad' => 'moderada', 'sintomas' => ['Bultos cutáneos', 'Crecimiento variable', 'Prurito local'], 'diagnostico' => 'Citología y biopsia.', 'tratamiento' => 'Extirpación quirúrgica según tipo.', 'prevencion' => 'Revisiones periódicas de la piel.'},
    {'nombre' => 'Epilepsia idiopática', 'gravedad' => 'grave', 'sintomas' => ['Convulsiones recurrentes', 'Post-ictal prolongado'], 'diagnostico' => 'Descarte neurológico completo.', 'tratamiento' => 'Anticonvulsivantes y seguimiento.', 'prevencion' => 'No criar afectados.'}
  ],
  'gran_danes' => [
    {'nombre' => 'Wobbler syndrome', 'gravedad' => 'grave', 'sintomas' => ['Marcha tambaleante', 'Debilidad cervical', 'Dolor de cuello'], 'diagnostico' => 'RMN cervical.', 'tratamiento' => 'Cirugía o manejo médico.', 'prevencion' => 'Crecimiento controlado.'},
    {'nombre' => 'Hipotiroidismo', 'gravedad' => 'moderada', 'sintomas' => ['Letargo', 'Aumento de peso', 'Piel seca'], 'diagnostico' => 'T4 y TSH.', 'tratamiento' => 'Levotiroxina.', 'prevencion' => 'Controles en adultos.'}
  ],
  'singapura' => [
    {'nombre' => 'Deficiencia de piruvato quinasa', 'gravedad' => 'moderada', 'sintomas' => ['Anemia', 'Letargo', 'Encías pálidas'], 'diagnostico' => 'Prueba genética.', 'tratamiento' => 'Soporte de la anemia.', 'prevencion' => 'Prueba genética en cría.'},
    {'nombre' => 'Asma felino', 'gravedad' => 'moderada', 'sintomas' => ['Tos', 'Respiración con silbidos', 'Postura agachada'], 'diagnostico' => 'Radiografía torácica.', 'tratamiento' => 'Broncodilatadores inhalados.', 'prevencion' => 'Evitar alérgenos ambientales.'}
  ],
  'bengala' => [
    {'nombre' => 'Enfermedad periodontal', 'gravedad' => 'moderada', 'sintomas' => ['Mal aliento', 'Sarro', 'Encías inflamadas'], 'diagnostico' => 'Exploración oral bajo sedación.', 'tratamiento' => 'Limpieza dental profesional.', 'prevencion' => 'Cepillado y revisiones dentales.'},
    {'nombre' => 'Luxación de rótula', 'gravedad' => 'leve', 'sintomas' => ['Cojera intermitente', 'Saltos al caminar'], 'diagnostico' => 'Palpación ortopédica.', 'tratamiento' => 'Control de peso y AINE.', 'prevencion' => 'Evitar sobrepeso.'}
  ],
  'siames' => [
    {'nombre' => 'Neoplasia mamaria', 'gravedad' => 'grave', 'sintomas' => ['Bultos en cadena mamaria', 'Adelgazamiento'], 'diagnostico' => 'Citología y biopsia.', 'tratamiento' => 'Mastectomía y quimioterapia.', 'prevencion' => 'Esterilización temprana reduce riesgo 90%.'},
    {'nombre' => 'Obstrucción urinaria', 'gravedad' => 'grave', 'sintomas' => ['Esfuerzo al orinar', 'Vocalización de dolor', 'Letargo'], 'diagnostico' => 'Palpación de vejiga y ecografía.', 'tratamiento' => 'Sondaje urinario de urgencia.', 'prevencion' => 'Dieta urinaria y buena hidratación.'}
  ],
  'persa' => [
    {'nombre' => 'Enfermedad renal crónica', 'gravedad' => 'grave', 'sintomas' => ['Poliuria/polidipsia', 'Vómitos', 'Adelgazamiento'], 'diagnostico' => 'Creatinina, SDMA y ecografía renal.', 'tratamiento' => 'Dieta renal y fluidoterapia.', 'prevencion' => 'Cribado genético PKD y controles.'},
    {'nombre' => 'Megacolon', 'gravedad' => 'moderada', 'sintomas' => ['Estreñimiento crónico', 'Abdomen distendido', 'Dolor defecatorio'], 'diagnostico' => 'Radiografía abdominal.', 'tratamiento' => 'Laxantes, dieta fibrosa y cirugía.', 'prevencion' => 'Hidratación y dieta adecuada.'}
  ],
  'british_shorthair' => [
    {'nombre' => 'Diabetes mellitus', 'gravedad' => 'moderada', 'sintomas' => ['Polidipsia', 'Poliuria', 'Aumento de apetito con adelgazamiento'], 'diagnostico' => 'Glucosa y fructosamina en sangre.', 'tratamiento' => 'Insulina y dieta baja en carbohidratos.', 'prevencion' => 'Control estricto del peso.'},
    {'nombre' => 'Enfermedad periodontal', 'gravedad' => 'moderada', 'sintomas' => ['Mal aliento', 'Sarro', 'Dificultad para comer'], 'diagnostico' => 'Exploración oral.', 'tratamiento' => 'Limpieza dental.', 'prevencion' => 'Cepillado regular.'}
  ],
  'maine_coon' => [
    {'nombre' => 'Espondilosis deformante', 'gravedad' => 'moderada', 'sintomas' => ['Rigidez', 'Cojera', 'Dificultad para saltar'], 'diagnostico' => 'Radiografías vertebrales.', 'tratamiento' => 'AINE y fisioterapia.', 'prevencion' => 'Control de peso.'},
    {'nombre' => 'Piodermia', 'gravedad' => 'leve', 'sintomas' => ['Costras', 'Picor', 'Pérdida de pelo localizada'], 'diagnostico' => 'Citología cutánea.', 'tratamiento' => 'Antibióticos y champú medicado.', 'prevencion' => 'Buena higiene del pelaje.'}
  ],
  'ragdoll' => [
    {'nombre' => 'Enfermedad periodontal', 'gravedad' => 'moderada', 'sintomas' => ['Mal aliento', 'Sarro', 'Encías sangrantes'], 'diagnostico' => 'Exploración oral.', 'tratamiento' => 'Limpieza dental.', 'prevencion' => 'Cepillado y revisiones.'},
    {'nombre' => 'Obesidad', 'gravedad' => 'moderada', 'sintomas' => ['Aumento de peso', 'Sedentarismo'], 'diagnostico' => 'Evaluación de condición corporal.', 'tratamiento' => 'Dieta controlada y ejercicio.', 'prevencion' => 'Raciones medidas.'}
  ],
  'canario' => [
    {'nombre' => 'Candidiasis', 'gravedad' => 'moderada', 'sintomas' => ['Placas blancas en buche', 'Regurgitación', 'Apatía'], 'diagnostico' => 'Examen bucal y cultivo.', 'tratamiento' => 'Antifúngicos orales.', 'prevencion' => 'Higiene de comederos y dieta fresca.'},
    {'nombre' => 'Psitacosis', 'gravedad' => 'grave', 'sintomas' => ['Secreción nasal', 'Diarrea', 'Apatía'], 'diagnostico' => 'PCR de Chlamydia.', 'tratamiento' => 'Doxiciclina prolongada.', 'prevencion' => 'Cuarentena de aves nuevas.'}
  ],
  'periquito' => [
    {'nombre' => 'Ácaros de patas', 'gravedad' => 'leve', 'sintomas' => ['Costras en patas', 'Deformidad de dedos'], 'diagnostico' => 'Raspado cutáneo.', 'tratamiento' => 'Ivermectina tópica.', 'prevencion' => 'Higiene de jaula.'},
    {'nombre' => 'Obesidad', 'gravedad' => 'moderada', 'sintomas' => ['Aumento de peso', 'Dificultad para volar'], 'diagnostico' => 'Pesaje regular.', 'tratamiento' => 'Dieta y ejercicio.', 'prevencion' => 'Control de semillas grasas.'}
  ],
  'cacatua' => [
    {'nombre' => 'Aspergilosis', 'gravedad' => 'grave', 'sintomas' => ['Dificultad respiratoria', 'Letargo', 'Anorexia'], 'diagnostico' => 'Radiografía y cultivo fúngico.', 'tratamiento' => 'Antifúngicos sistémicos prolongados.', 'prevencion' => 'Ventilación y higiene.'},
    {'nombre' => 'Psitacosis', 'gravedad' => 'grave', 'sintomas' => ['Secreción nasal', 'Diarrea verdosa'], 'diagnostico' => 'PCR.', 'tratamiento' => 'Doxiciclina.', 'prevencion' => 'Cuarentena.'}
  ],
  'guacamayo' => [
    {'nombre' => 'Metalosis por intoxicación', 'gravedad' => 'grave', 'sintomas' => ['Vómitos', 'Convulsiones', 'Parálisis'], 'diagnostico' => 'Radiografía con metal visible.', 'tratamiento' => 'Extracción quirúrgica y quelantes.', 'prevencion' => 'Juguetes sin zinc/plomo.'},
    {'nombre' => 'Psitacosis', 'gravedad' => 'grave', 'sintomas' => ['Secreción nasal', 'Apatía', 'Diarrea'], 'diagnostico' => 'PCR.', 'tratamiento' => 'Doxiciclina.', 'prevencion' => 'Cuarentena e higiene.'}
  ],
  'pony_shetland' => [
    {'nombre' => 'Obesidad y resistencia a insulina', 'gravedad' => 'moderada', 'sintomas' => ['Acúmulos grasos cresta/cola', 'Laminitis recurrente'], 'diagnostico' => 'Insulina en ayunas.', 'tratamiento' => 'Dieta estricta y ejercicio.', 'prevencion' => 'Limitar pasto y controlar raciones.'},
    {'nombre' => 'Parásitos internos resistentes', 'gravedad' => 'moderada', 'sintomas' => ['Adelgazamiento', 'Diarrea', 'Anemia'], 'diagnostico' => 'Coproscopia.', 'tratamiento' => 'Desparasitante según resultado.', 'prevencion' => 'Programa estratégico con coproscopias.'}
  ],
  'cuarto_milla' => [
    {'nombre' => 'Laminitis', 'gravedad' => 'grave', 'sintomas' => ['Cojera', 'Cascos calientes', 'Postura de alivio'], 'diagnostico' => 'Radiografías de casco.', 'tratamiento' => 'Reposo, AINE y soporte de casco.', 'prevencion' => 'Control de peso y dieta.'},
    {'nombre' => 'Artritis degenerativa', 'gravedad' => 'moderada', 'sintomas' => ['Cojera crónica', 'Rigidez matutina'], 'diagnostico' => 'Radiografías articulares.', 'tratamento' => 'AINE y condroprotectores.', 'prevencion' => 'Ejercicio regular y peso ideal.'}
  ],
  'caballo_andaluz' => [
    {'nombre' => 'Melanoma en gris', 'gravedad' => 'moderada', 'sintomas' => ['Nódulos negros bajo cola', 'Crecimiento lento'], 'diagnostico' => 'Biopsia.', 'tratamiento' => 'Cirugía o inmunoterapia.', 'prevencion' => 'No prevenible en caballos grises.'},
    {'nombre' => 'Uveítis recurrente (moon blindness)', 'gravedad' => 'moderada', 'sintomas' => ['Ojo rojo', 'Lagrimeo', 'Opacidad corneal'], 'diagnostico' => 'Examen oftalmológico.', 'tratamiento' => 'Corticoides tópicos.', 'prevencion' => 'Control de parásitos y vacunas.'}
  ],
  'hereford' => [
    {'nombre' => 'Pododermatitis digital', 'gravedad' => 'moderada', 'sintomas' => ['Cojera', 'Lesión interdigital', 'Mal olor'], 'diagnostico' => 'Examen podal.', 'tratamiento' => 'Baños podales y antibióticos.', 'prevencion' => 'Higiene de suelos y baños preventivos.'},
    {'nombre' => 'Anemia parasitaria', 'gravedad' => 'moderada', 'sintomas' => ['Mucosas pálidas', 'Debilidad', 'Edema submandibular'], 'diagnostico' => 'Coproscopia y FAMACHA.', 'tratamiento' => 'Desparasitante y hierro.', 'prevencion' => 'Programa estratégico de desparasitación.'}
  ],
  'angus' => [
    {'nombre' => 'Anaplasmosis', 'gravedad' => 'grave', 'sintomas' => ['Fiebre', 'Anemia', 'Ictericia', 'Debilidad'], 'diagnostico' => 'Frotis sanguíneo.', 'tratamiento' => 'Tetraciclinas.', 'prevencion' => 'Control de garrapatas y vacunación.'},
    {'nombre' => 'Retención de placenta', 'gravedad' => 'moderada', 'sintomas' => ['Placenta no expulsada >24 h', 'Fiebre', 'Secreción fétida'], 'diagnostico' => 'Examen posparto.', 'tratamiento' => 'Antibióticos y extracción manual.', 'prevencion' => 'Buena nutrición preparto.'}
  ],
  'holstein' => [
    {'nombre' => 'Desplazamiento de abomaso', 'gravedad' => 'grave', 'sintomas' => ['Caída de leche', 'Pérdida de apetito', 'Heces escasas'], 'diagnostico' => 'Auscultación con solución fisiológica.', 'tratamiento' => 'Corrección quirúrgica o rolling.', 'prevencion' => 'Dieta posparto equilibrada.'},
    {'nombre' => 'Metritis', 'gravedad' => 'moderada', 'sintomas' => ['Secreción uterina fétida', 'Fiebre', 'Depresión'], 'diagnostico' => 'Examen vaginal.', 'tratamiento' => 'Antibióticos uterinos y sistémicos.', 'prevencion' => 'Higiene del parto.'}
  ],
  'cerdo_iberico' => [
    {'nombre' => 'Aflatoxicosis', 'gravedad' => 'grave', 'sintomas' => ['Ictericia', 'Hemorragias', 'Muerte súbita'], 'diagnostico' => 'Análisis de piensos.', 'tratamiento' => 'Retirar piensos contaminados.', 'prevencion' => 'Control de calidad de piensos.'},
    {'nombre' => 'Disentería porcina', 'gravedad' => 'grave', 'sintomas' => ['Diarrea sanguinolenta', 'Fiebre', 'Debilidad'], 'diagnostico' => 'Necropsia y cultivo.', 'tratamiento' => 'Antibióticos y fluidoterapia.', 'prevencion' => 'Vacunación y bioseguridad.'}
  ],
  'cerdo_landrace' => [
    {'nombre' => 'Disentería porcina', 'gravedad' => 'grave', 'sintomas' => ['Diarrea con sangre', 'Fiebre', 'Debilidad'], 'diagnostico' => 'Cultivo de Brachyspira.', 'tratamiento' => 'Antibióticos específicos.', 'prevencion' => 'Vacunación y higiene.'},
    {'nombre' => 'Erisipela', 'gravedad' => 'grave', 'sintomas' => ['Lesiones cutáneas romboide', 'Fiebre', 'Artritis'], 'diagnostico' => 'Cultivo y signos clínicos.', 'tratamiento' => 'Penicilina.', 'prevencion' => 'Vacunación anual.'}
  ],
  'cerdo_duroc' => [
    {'nombre' => 'Erisipela', 'gravedad' => 'grave', 'sintomas' => ['Placas cutáneas elevadas', 'Fiebre alta'], 'diagnostico' => 'Signos clínicos.', 'tratamiento' => 'Penicilina urgente.', 'prevencion' => 'Vacunación.'},
    {'nombre' => 'Disentería porcina', 'gravedad' => 'grave', 'sintomas' => ['Diarrea sanguinolenta', 'Debilidad'], 'diagnostico' => 'Necropsia.', 'tratamiento' => 'Antibióticos.', 'prevencion' => 'Bioseguridad.'}
  ],
  'conejo_mini' => [
    {'nombre' => 'Fractura por caída', 'gravedad' => 'grave', 'sintomas' => ['No apoya pata', 'Hinchazón', 'Dolor'], 'diagnostico' => 'Radiografías.', 'tratamiento' => 'Inmovilización o cirugía.', 'prevencion' => 'Supervisar al manipular.'},
    {'nombre' => 'Pasteurelosis', 'gravedad' => 'grave', 'sintomas' => ['Secreción nasal', 'Estornudos', 'Anorexia'], 'diagnostico' => 'Cultivo bacteriano.', 'tratamiento' => 'Antibióticos prolongados.', 'prevencion' => 'Evitar estrés y corrientes.'}
  ],
  'conejo_angora' => [
    {'nombre' => 'Estasis gastrointestinal', 'gravedad' => 'grave', 'sintomas' => ['No come', 'Sin heces', 'Apatía'], 'diagnostico' => 'Radiografía.', 'tratamiento' => 'Fluidoterapia y procinéticos.', 'prevencion' => 'Dieta alta en fibra.'},
    {'nombre' => 'Pododermatitis', 'gravedad' => 'moderada', 'sintomas' => ['Llagas en patas', 'Cojera'], 'diagnostico' => 'Examen de patas.', 'tratamiento' => 'Curas y suelo blando.', 'prevencion' => 'Suelo acolchado.'}
  ],
  'conejo_gigante' => [
    {'nombre' => 'Maloclusión dental', 'gravedad' => 'moderada', 'sintomas' => ['Babeo', 'No come', 'Dientes largos'], 'diagnostico' => 'Examen bucal.', 'tratamiento' => 'Limado dental.', 'prevencion' => 'Heno abundante.'},
    {'nombre' => 'Artritis por peso', 'gravedad' => 'moderada', 'sintomas' => ['Rigidez', 'Dificultad para moverse'], 'diagnostico' => 'Radiografías.', 'tratamiento' => 'AINE y control de peso.', 'prevencion' => 'Dieta controlada.'}
  ],
  'serpiente_corn' => [
    {'nombre' => 'Parásitos internos', 'gravedad' => 'moderada', 'sintomas' => ['Regurgitación', 'Adelgazamiento', 'Heces anormales'], 'diagnostico' => 'Coproscopia.', 'tratamiento' => 'Antiparasitarios.', 'prevencion' => 'Cuarentena y coproscopia anual.'},
    {'nombre' => 'Quemaduras térmicas', 'gravedad' => 'moderada', 'sintomas' => ['Escamas blanquecinas', 'Bultos en piel'], 'diagnostico' => 'Examen físico.', 'tratamiento' => 'Antibióticos tópicos y corrección de temperatura.', 'prevencion' => 'Termostato y protección de lámparas.'}
  ],
  'tortuga' => [
    {'nombre' => 'Parásitos internos', 'gravedad' => 'moderada', 'sintomas' => ['Diarrea', 'Adelgazamiento', 'Apatía'], 'diagnostico' => 'Coproscopia.', 'tratamiento' => 'Antiparasitarios.', 'prevencion' => 'Cuarentena y controles.'},
    {'nombre' => 'Prolapso cloacal', 'gravedad' => 'grave', 'sintomas' => ['Tejido rojo protruyendo del cloaca', 'Estrés'], 'diagnostico' => 'Examen físico.', 'tratamiento' => 'Reposición y sutura urgente.', 'prevencion' => 'Calcio adecuado y postura correcta al poner huevos.'}
  ],
  'iguana' => [
    {'nombre' => 'Infección respiratoria', 'gravedad' => 'moderada', 'sintomas' => ['Respiración bucal', 'Secreción nasal', 'Silbidos'], 'diagnostico' => 'Radiografía y cultivo.', 'tratamiento' => 'Antibióticos y calor.', 'prevencion' => 'Temperatura y humedad correctas.'},
    {'nombre' => 'Quemaduras por UV/lámpara', 'gravedad' => 'moderada', 'sintomas' => ['Escamas blanquecinas', 'Bultos cutáneos'], 'diagnostico' => 'Examen físico.', 'tratamiento' => 'Curas tópicas y ajuste de lámparas.', 'prevencion' => 'Distancia correcta de UVB.'}
  ],
  'betta' => [
    {'nombre' => 'Velvet (Oodinium)', 'gravedad' => 'moderada', 'sintomas' => ['Polvo dorado en piel', 'Frotamiento', 'Apatía'], 'diagnostico' => 'Observación microscópica.', 'tratamiento' => 'Antiparasitarios y aumento de temperatura.', 'prevencion' => 'Cuarentena y agua limpia.'},
    {'nombre' => 'Columnaris', 'gravedad' => 'grave', 'sintomas' => ['Lesiones algodonosas', 'Aletas deshilachadas', 'Respiración rápida'], 'diagnostico' => 'Observación de lesiones.', 'tratamiento' => 'Antibióticos en agua.', 'prevencion' => 'Buena calidad de agua.'}
  ],
  'goldfish' => [
    {'nombre' => 'Columnaris', 'gravedad' => 'grave', 'sintomas' => ['Manchas blancas algodonosas', 'Aletas deshilachadas'], 'diagnostico' => 'Signos clínicos.', 'tratamiento' => 'Antibióticos y sal.', 'prevencion' => 'Agua limpia y cuarentena.'},
    {'nombre' => 'Dropsy (hidropesía)', 'gravedad' => 'grave', 'sintomas' => ['Abdomen hinchado', 'Escamas erizadas'], 'diagnostico' => 'Observación clínica.', 'tratamiento' => 'Aislamiento y antibióticos; pronóstico reservado.', 'prevencion' => 'Calidad de agua y dieta.'}
  ],
  'carpa_koi' => [
    {'nombre' => 'Enfermedad del Koi herpesvirus (KHV)', 'gravedad' => 'grave', 'sintomas' => ['Lesiones branquiales', 'Letargo masivo'], 'diagnostico' => 'PCR.', 'tratamiento' => 'No hay cura; bioseguridad.', 'prevencion' => 'Cuarentena estricta.'},
    {'nombre' => 'Costia (Ichthyobodo)', 'gravedad' => 'moderada', 'sintomas' => ['Mucosidad excesiva', 'Frotamiento', 'Respiración en superficie'], 'diagnostico' => 'Raspado microscópico.', 'tratamiento' => 'Formalina o medicación específica.', 'prevencion' => 'Cuarentena y test de agua.'}
  ],
  'oveja_merino' => [
    {'nombre' => 'Clostridiosis', 'gravedad' => 'grave', 'sintomas' => ['Muerte súbita', 'Distensión abdominal'], 'diagnostico' => 'Necropsia.', 'tratamiento' => 'Antibióticos precoces.', 'prevencion' => 'Vacunación clostridial.'},
    {'nombre' => 'Timpanismo', 'gravedad' => 'grave', 'sintomas' => ['Distensión flanco izquierdo', 'Dificultad respiratoria'], 'diagnostico' => 'Examen físico.', 'tratamiento' => 'Sonda esofágica urgente.', 'prevencion' => 'Adaptación gradual a pastos ricos.'}
  ],
  'cabra_nubia' => [
    {'nombre' => 'Listeriosis', 'gravedad' => 'grave', 'sintomas' => ['Circling', 'Parálisis facial', 'Fiebre'], 'diagnostico' => 'Signos neurológicos y cultivo.', 'tratamiento' => 'Penicilina alta dosis.', 'prevencion' => 'Evitar heno mohoso.'},
    {'nombre' => 'Parásitos internos', 'gravedad' => 'moderada', 'sintomas' => ['Diarrea', 'Anemia', 'Adelgazamiento'], 'diagnostico' => 'Coproscopia.', 'tratamiento' => 'Desparasitante según resultado.', 'prevencion' => 'Programa estratégico.'}
  ],
  'llama' => [
    {'nombre' => 'Meningeal worm (Parelaphostrongylus)', 'gravedad' => 'grave', 'sintomas' => ['Ataxia', 'Parálisis progresiva', 'Cabeza inclinada'], 'diagnostico' => 'Signos neurológicos y exclusión.', 'tratamiento' => 'Antiparasitarios y antiinflamatorios.', 'prevencion' => 'Control de ciervos y desparasitación.'},
    {'nombre' => 'Cólico', 'gravedad' => 'grave', 'sintomas' => ['Inquietud', 'Rolls', 'Falta de apetito'], 'diagnostico' => 'Examen clínico.', 'tratamiento' => 'Analgesia y fluidoterapia.', 'prevencion' => 'Dieta estable y agua limpia.'}
  ],
  'hamster' => [
    {'nombre' => 'Insuficiencia cardíaca', 'gravedad' => 'grave', 'sintomas' => ['Respiración rápida', 'Edema', 'Cianosis'], 'diagnostico' => 'Auscultación y radiografía.', 'tratamiento' => 'Diuréticos y soporte.', 'prevencion' => 'Dieta baja en sodio.'},
    {'nombre' => 'Abscesos por mordeduras', 'gravedad' => 'moderada', 'sintomas' => ['Bulto purulento', 'Fiebre', 'Apatía'], 'diagnostico' => 'Examen físico.', 'tratamiento' => 'Drenaje y antibióticos.', 'prevencion' => 'No mezclar hámsters sirios.'}
  ],
  'cobaya' => [
    {'nombre' => 'Cálculos urinarios', 'gravedad' => 'grave', 'sintomas' => ['Sangre en orina', 'Dolor al orinar', 'Vocalización'], 'diagnostico' => 'Radiografía y ecografía.', 'tratamiento' => 'Dieta y analgesia; cirugía si obstrucción.', 'prevencion' => 'Dieta baja en calcio, vitamina C adecuada.'},
    {'nombre' => 'Pododermatitis', 'gravedad' => 'moderada', 'sintomas' => ['Llagas en patas', 'Cojera'], 'diagnostico' => 'Examen de patas.', 'tratamiento' => 'Curas y suelo blando.', 'prevencion' => 'Jaula limpia y seca.'}
  ],
  'huron' => [
    {'nombre' => 'Linfoma', 'gravedad' => 'grave', 'sintomas' => ['Adelgazamiento', 'Linfadenopatía', 'Letargo'], 'diagnostico' => 'Citología y biopsia.', 'tratamiento' => 'Quimioterapia.', 'prevencion' => 'No prevenible; controles anuales.'},
    {'nombre' => 'Moquillo (distemper)', 'gravedad' => 'grave', 'sintomas' => ['Secreción ocular/nasal', 'Convulsiones', 'Hiperqueratosis plantar'], 'diagnostico' => 'PCR y signos clínicos.', 'tratamiento' => 'Soporte; mortalidad alta.', 'prevencion' => 'Vacunación obligatoria anual.'}
  ]
}

# Fix typo in cuarto_milla entry
NEW_DISEASES['cuarto_milla'][1]['tratamiento'] = NEW_DISEASES['cuarto_milla'][1].delete('tratamento') if NEW_DISEASES['cuarto_milla'][1]['tratamento']

load File.join(__dir__, 'more_breed_expand_data.rb') if File.exist?(File.join(__dir__, 'more_breed_expand_data.rb'))
