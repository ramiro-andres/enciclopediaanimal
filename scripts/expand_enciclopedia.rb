# frozen_string_literal: true

require 'json'

ROOT = File.expand_path('..', __dir__)
INPUT = File.join(ROOT, 'data', 'enciclopedia.json')
OUTPUT = INPUT

ANIMAL_CONFIG = {
  'perros' => {
    parametros_salud: 'Temperatura rectal normal: 38,0-39,2 °C. Frecuencia cardíaca: 60-140 lpm (razas pequeñas en el rango alto). Frecuencia respiratoria: 10-30 rpm en reposo. Tiempo de llenado capilar: 1-2 segundos. Mucosas: rosadas y húmedas.',
    vacunacion: 'Cachorros: primovacunación a las 6, 9 y 12 semanas (moquillo, parvovirus, hepatitis, leptospirosis, rabia según normativa local). Refuerzo anual o bienal según calendario veterinario y estilo de vida.',
    desparasitacion: 'Interna: cada 1-3 meses según riesgo (cachorros mensual hasta los 6 meses). Externa: pipeta o collar antiparasitario mensual todo el año, especialmente en climas cálidos.',
    revisiones: 'Cachorros: cada 3-4 semanas hasta completar vacunas. Adultos sanos: revisión completa anual; mayores de 7 años: cada 6 meses con analítica básica.',
    senales_base: ['Letargo o apatía persistente más de 24 horas', 'Vómitos o diarrea repetidos', 'Rechazo total del alimento por más de 12 horas', 'Dificultad respiratoria o encías pálidas/azuladas', 'Convulsiones o desmayos', 'Dolor evidente al manipular o cojera severa']
  },
  'gatos' => {
    parametros_salud: 'Temperatura: 38,0-39,2 °C. Frecuencia cardíaca: 140-220 lpm. Frecuencia respiratoria: 20-30 rpm. Mucosas rosadas. El gato enmascara el dolor: vigilar cambios sutiles de conducta.',
    vacunacion: 'Trivalente felina (panleucopenia, calicivirus, rinotraqueitis) a las 8, 12 y 16 semanas; rabia según normativa. Refuerzos anuales o según protocolo veterinario.',
    desparasitacion: 'Interna cada 1-3 meses; externa mensual si sale al exterior o convive con perros. Control de pulgas esencial en gatos de interior con acceso a terraza.',
    revisiones: 'Cachorros: controles cada 3-4 semanas. Adultos: anual con revisión dental. Seniors (>10 años): cada 6 meses con analítica renal y tiroides.',
    senales_base: ['Ausencia de uso del arenero o esfuerzo al orinar', 'Vómitos frecuentes o heces muy blandas persistentes', 'Respiración abierta o con silbidos', 'Encías pálidas o ictericia', 'Pérdida de peso sin causa aparente', 'Ocultamiento prolongado y rechazo al contacto']
  },
  'aves' => {
    parametros_salud: 'Temperatura: 40-42 °C. Frecuencia cardíaca: 250-500 lpm según especie. Respiración: 20-40 rpm en reposo. Peso diario recomendado en aves pequeñas. Plumaje liso y brillo normal.',
    vacunacion: 'Según especie y país: poliomavirus en psitácidas, enfermedad de Newcastle en aves de corral. Consultar calendario aviar local. Cuarentena obligatoria de aves nuevas 30-45 días.',
    desparasitacion: 'Control externo mensual en jaula; antiparasitarios internos cada 3-6 meses tras coproscopia. Desinfección periódica de perchas y comederos.',
    revisiones: 'Examen clínico anual por veterinario especializado en aves; peso mensual en casa. Revisión inmediata ante cambios en el canto, las heces o el plumaje.',
    senales_base: ['Plumaje erizado constante', 'Heces acuosas o cambio brusco de color/textura', 'Respiración con cola que sube y baja', 'Pérdida de peso visible', 'Inactividad en perchas bajas', 'Secreción nasal u ocular']
  },
  'equinos' => {
    parametros_salud: 'Temperatura: 37,2-38,3 °C (fiebre >38,5 °C). Pulso: 28-44 lpm. Respiración: 8-16 rpm. Tiempo de relleno capilar <2 s. Motilidad intestinal: 1-3 ruidos por minuto en cada cuadrante.',
    vacunacion: 'Tétanos anual; influenza equina y rinoneumonitis según manejo; rabia según zona. Potros: serie inicial desde los 4-6 meses con refuerzos.',
    desparasitacion: 'Programa estratégico con coproscopias; rotación de principios activos. Desparasitación cada 6-8 semanas en potros; adultos según conteo de huevos.',
    revisiones: 'Revisiones dentales cada 6-12 meses. Examen clínico completo semestral. Control de cascos cada 6-8 semanas por herrador.',
    senales_base: ['Cólico: mirarse el flanco, revolcarse, sudoración', 'Cojera aguda o empeoramiento brusco', 'Fiebre >38,5 °C', 'Ausencia de deposiciones >12 horas', 'Pulsos digitales fuertes y cascos calientes', 'Disminución brusca del apetito']
  },
  'bovinos' => {
    parametros_salud: 'Temperatura: 38,0-39,3 °C. Pulso: 60-80 lpm. Respiración: 15-35 rpm. Rumia: 50-70 masticaciones por bolo. Mucosas rosadas; tiempo de relleno capilar 1-2 s.',
    vacunacion: 'Clostridiales, IBR/BVD, leptospirosis y brucelosis según normativa y manejo del hato. Vacunación de terneros según calendario del veterinario de producción.',
    desparasitacion: 'Interna estratégica según estación y coproscopia; externa contra moscas y garrapatas en época cálida. Baños garrapaticidas programados.',
    revisiones: 'Revisión del hato cada 2-4 semanas en lactación; examen reproductivo posparto; control de pezuñas y locomoción trimestral.',
    senales_base: ['Caída de producción láctea o rechazo del alimento', 'Fiebre o decaimiento del hato', 'Diarrea en terneros', 'Cojera o inflamación de pezuñas', 'Distensión del flanco izquierdo (timpanismo)', 'Secreción nasal purulenta y tos']
  },
  'porcinos' => {
    parametros_salud: 'Temperatura: 38,5-39,5 °C. Pulso: 70-90 lpm. Respiración: 15-30 rpm. Consumo de agua: 2-3 veces el consumo de pienso. Mucosas rosadas.',
    vacunacion: 'Mycoplasma, circovirus (PCV2), parvovirus porcino, erisipela según sistema productivo. Vacunas en lechones según protocolo de la granja.',
    desparasitacion: 'Antiparasitarios internos en recría y adultos cada 3-4 meses; control de moscas y roedores en instalaciones.',
    revisiones: 'Inspección diaria de actitud, apetito y heces. Revisión veterinaria mensual en granjas comerciales; semanal en cerdas gestantes.',
    senales_base: ['Jadeo intenso y postración (golpe de calor)', 'Tos persistente o dificultad respiratoria', 'Diarrea en lechones', 'Coordinación alterada o convulsiones', 'Piel enrojecida o manchas púrpuras', 'Rechazo del alimento en grupo']
  },
  'conejos' => {
    parametros_salud: 'Temperatura: 38,5-40,0 °C. Frecuencia cardíaca: 180-250 lpm. Respiración: 30-60 rpm. Debe producir heces continuamente; ausencia >12 h es urgente.',
    vacunacion: 'RHDV1/RHDV2 según disponibilidad y normativa local; mixomatosis en zonas endémicas. Refuerzos anuales.',
    desparasitacion: 'Interna cada 3-6 meses si hay acceso a pasto; control de pulgas y ácaros si convive con otros animales.',
    revisiones: 'Examen clínico anual; control dental cada 6 meses. Peso semanal recomendado en casa.',
    senales_base: ['No come ni produce heces >6-12 horas', 'Postura encorvada y dolor abdominal', 'Respiración muy rápida con boca abierta', 'Temblores o debilidad extrema', 'Babeo o dificultad para comer', 'Parálisis de patas traseras']
  },
  'reptiles' => {
    parametros_salud: 'Temperatura corporal dependiente del ambiente (ectotermo). Gradiente térmico según especie. Frecuencia cardíaca variable. Vigilar muda, apetito y heces.',
    vacunacion: 'No existen vacunas comerciales para reptiles domésticos. Prevención basada en cuarentena, higiene y manejo correcto del terrario.',
    desparasitacion: 'Coproscopia anual; desparasitación si se detectan parásitos. Cuarentena de nuevos ejemplares 60-90 días.',
    revisiones: 'Examen anual por veterinario de exóticos; control de peso mensual. Revisión de parámetros ambientales semanalmente.',
    senales_base: ['Rechazo alimentario >2 semanas', 'Muda incompleta o piel retenida en ojos/cola', 'Respiración bucal o silbidos', 'Letargo fuera del periodo normal', 'Diarrea acuosa o heces muy blandas', 'Deformidades óseas o temblores']
  },
  'peces' => {
    parametros_salud: 'Temperatura del agua según especie. pH, amoniaco, nitrito y nitrato dentro de rangos seguros. Oxígeno disuelto adecuado. Comportamiento de nado activo y apetito normal.',
    vacunacion: 'No hay vacunas para peces ornamentales. Prevención mediante cuarentena, calidad de agua y bioseguridad.',
    desparasitacion: 'Cuarentena 2-4 semanas para peces nuevos; baños preventivos si hay historial de parásitos. No medicar acuario completo sin diagnóstico.',
    revisiones: 'Test de agua semanal; inspección diaria de aletas, ojos y comportamiento. Revisión trimestral del sistema de filtración.',
    senales_base: ['Nado errático o en superficie jadeando', 'Puntos blancos, úlceras o aletas deshilachadas', 'Rechazo al alimento >2-3 días', 'Aletas pegadas al cuerpo', 'Escamas erizadas o abdomen hinchado', 'Un pez aislado en un rincón sin moverse']
  },
  'ovinos' => {
    parametros_salud: 'Temperatura: 38,5-40,0 °C. Pulso: 70-90 lpm. Respiración: 12-20 rpm. Rumia normal en rebaño. Método FAMACHA para detectar anemia parasitaria.',
    vacunacion: 'Clostridiales, ectima contagioso y rabia según zona. Corderos: primovacunación con refuerzo según calendario ovino.',
    desparasitacion: 'Estrategia basada en FAMACHA y coproscopia; evitar resistencias rotando anthelmínticos. Esquileo y control de moscas en verano.',
    revisiones: 'Inspección del rebaño semanal; recorte de pezuñas cada 6-8 semanas; revisión pre y post parto.',
    senales_base: ['Cojera o reticencia a levantarse', 'Diarrea o heces muy blandas', 'Mucosas pálidas (anemia)', 'Separación del rebaño y decaimiento', 'Picor intenso o pérdida de lana localizada', 'Distensión abdominal en corderos']
  },
  'caprinos' => {
    parametros_salud: 'Temperatura: 38,5-40,5 °C. Pulso: 70-90 lpm. Respiración: 15-30 rpm. Rumia activa. Mucosas rosadas salvo en razas negras donde usar FAMACHA.',
    vacunacion: 'Clostridiales (CD-T), rabia según zona. Cabritas: serie inicial con refuerzo anual.',
    desparasitacion: 'Coproscopia periódica; desparasitación selectiva según FAMACHA. Control de moscas y garrapatas en pastoreo.',
    revisiones: 'Control semanal de ubre en lactación; recorte de pezuñas cada 6-8 semanas; examen reproductivo en crías.',
    senales_base: ['Distensión del flanco izquierdo (timpanismo)', 'Diarrea en cabritos', 'Cojera o inflamación de pezuñas', 'Ubre caliente o leche con grumos', 'Bloqueo urinario en machos (estirarse, vocalizar)', 'Decaimiento y aislamiento del rebaño']
  },
  'camelidos' => {
    parametros_salud: 'Temperatura: 37,5-39,0 °C. Pulso: 60-90 lpm. Respiración: 10-30 rpm. Masticación del bolo normal. Sensibles al calor por encima de 27 °C con humedad.',
    vacunacion: 'Clostridiales según zona; consultar veterinario de camélidos. No hay vacunas universales estandarizadas.',
    desparasitacion: 'Coproscopia y FAMACHA; desparasitación estratégica. Esquileo antes del verano en zonas cálidas.',
    revisiones: 'Examen clínico semestral; control de peso y condición corporal trimestral; recorte de uñas cada 2-3 meses.',
    senales_base: ['Jadeo y postración por calor', 'Mucosas pálidas o edema submandibular', 'Cojera o rigidez articular', 'Rechazo del alimento >24 horas', 'Diarrea o heces muy blandas', 'Dificultad respiratoria']
  },
  'roedores' => {
    parametros_salud: 'Temperatura: 37,5-39,5 °C según especie. Frecuencia cardíaca: 250-600 lpm. Respiración: 40-120 rpm. Roedores ocultan enfermedad: vigilar apetito y heces diariamente.',
    vacunacion: 'Hurón: moquillo y rabia obligatorios según normativa. Hamsters y cobayas: no hay vacunas rutinarias comerciales.',
    desparasitacion: 'Interna si hay signos o coproscopia positiva; control de pulgas si conviven con perros/gatos. Higiene de la jaula semanal.',
    revisiones: 'Examen anual por veterinario de exóticos; control de peso quincenal. Hurones: analítica anual a partir de los 3 años.',
    senales_base: ['Pérdida de apetito >12 horas', 'Letargo o dificultad respiratoria', 'Diarrea acuosa o heces ausentes', 'Babeo o dificultad para comer', 'Convulsiones o debilidad brusca', 'Bultos palpables que crecen rápido']
  }
}.freeze

BREED_DATA = {
  'chihuahua' => {
    historia: 'Originario del estado mexicano de Chihuahua, desciende del techichi tolteca. Fue popularizado en Estados Unidos a finales del siglo XIX y reconocido por el AKC en 1904. Es la raza de perro más pequeña reconocida oficialmente.',
    caracteristicas: 'Cuerpo compacto con cráneo apple head o deer head. Pelaje corto o largo, colores variados. Orejas grandes erguidas, ojos redondos y expresivos. Peso ideal 1,5-3 kg. Extremidades finas pero ágiles.',
    aptitudes: 'Compañía en espacios reducidos, perro de alerta, terapia asistida y acompañamiento urbano. No apto para niños muy pequeños por fragilidad.',
    altura: '15-23 cm a la cruz',
    emergencias: 'Hipoglucemia con convulsiones, traumatismos por caídas, luxación de rótula severa, hidrocefalia con crisis neurológicas y golpe de calor en verano.'
  },
  'yorkshire' => {
    historia: 'Desarrollado en Yorkshire (Inglaterra) durante el siglo XIX por obreros para cazar ratas en minas y fábricas. Su aspecto elegante lo convirtió en perro de compañía de la alta sociedad victoriana.',
    caracteristicas: 'Pelaje largo, fino y sedoso de color azul acero y fuego dorado. Cuerpo compacto, porte erguido. Cola tradicionalmente corta en países donde está permitido. Peso 2-3,2 kg.',
    aptitudes: 'Compañía urbana, exposición canina, terapia asistida y perro de alerta doméstico. Buen adaptador a apartamentos con ejercicio diario moderado.',
    altura: '18-23 cm a la cruz',
    emergencias: 'Colapso traqueal con cianosis, shunt portosistémico con signos neurológicos postprandiales, hipoglucemia y obstrucción por cuerpos extraños por tamaño pequeño.'
  },
  'pomerania' => {
    historia: 'Proviene de la región de Pomerania (actual Alemania y Polonia). Descendiente de spitz árticos de trineo, fue miniaturizado en el siglo XIX, popularizado por la reina Victoria de Inglaterra.',
    caracteristicas: 'Doble manto abundante con cuello de león. Cola en espiral sobre el lomo. Cabeza de zorro con orejas pequeñas erguidas. Colores variados. Peso 1,9-3,5 kg.',
    aptitudes: 'Compañía, perro de alerta, agility en categoría toy y exposición. Excelente perro urbano con personalidad extrovertida.',
    altura: '18-22 cm a la cruz',
    emergencias: 'Colapso traqueal, hipoglucemia en cachorros, golpe de calor por doble manto denso y luxación de rótula con dolor agudo.'
  },
  'maltes' => {
    historia: 'Una de las razas más antiguas, mencionada por Aristóteles. Originario del Mediterráneo, fue perro de compañía de damas y comerciantes fenicios. Reconocido por el AKC en 1888.',
    caracteristicas: 'Pelaje blanco largo, sedoso y sin subpelo lanoso. Cuerpo compacto, cabeza proporcionada con ojos oscuros. Nariz negra distintiva. Peso 3-4 kg.',
    aptitudes: 'Compañía, perro de terapia, exposición y vida en apartamento. Ideal para personas que buscan un perro afectuoso y elegante.',
    altura: '20-25 cm a la cruz',
    emergencias: 'Hipoglucemia, luxación de rótula, obstrucción intestinal por cuerpos extraños y colapso por calor en días calurosos.'
  },
  'beagle' => {
    historia: 'Sabueso inglés documentado desde el siglo XVI para caza de liebre a pie. El nombre puede derivar del francés "be\'geule" (garganta abierta) por su ladrido de caza. Muy popular en laboratorios y como mascota familiar.',
    caracteristicas: 'Cuerpo compacto y musculoso. Orejas largas y caídas, ojos marrón avellana con expresión suplicante. Pelaje tricolor o bicolor corto y denso. Peso 9-11 kg.',
    aptitudes: 'Caza de rastreo, detección olfativa (aeropuertos, aduanas), perro de familia y compañía activa. Excelente olfato, segundo solo al Bloodhound.',
    altura: '33-41 cm a la cruz',
    emergencias: 'Obstrucción por cuerpos extraños (ingiere todo), crisis epiléptica, torsión gástrica menos frecuente pero posible, y reacciones a medicamentos si hay sensibilidad MDR1.'
  },
  'cocker' => {
    historia: 'Spaniel inglés desarrollado para levantar y cobrar perdices (woodcock). Separado del Springer Spaniel en 1892. Muy popular en Reino Unido y España como perro de compañía y caza.',
    caracteristicas: 'Cuerpo equilibrado, orejas largas y onduladas con flecos. Pelaje sedoso de longitud media en extremidades. Ojos grandes y expresivos. Peso 12-15 kg.',
    aptitudes: 'Caza menor, compañía familiar, perro de terapia y exposición. Buen nadador y recuperador en agua.',
    altura: '38-41 cm a la cruz',
    emergencias: 'Otitis aguda con dolor intenso, hernia discal con parálisis, reacción anafiláctica por alergias y glaucoma agudo.'
  },
  'border_collie' => {
    historia: 'Desarrollado en la frontera anglo-escocesa para pastoreo de ovejas. Considerado el perro más inteligente. El estándar actual se fijó a finales del siglo XIX con el perro Old Hemp como referencia.',
    caracteristicas: 'Cuerpo atlético y ágil. Pelaje medio de dos capas, colores variados (negro-blanco más común). Mirada intensa característica del pastor. Peso 14-20 kg.',
    aptitudes: 'Pastoreo, agility, obediencia, frisbee, perro de rescate y detección. Requiere trabajo mental y físico constante.',
    altura: '46-56 cm a la cruz',
    emergencias: 'Intoxicación por ivermectina (MDR1), convulsiones, hernia discal aguda y golpe de calor por ejercicio excesivo en verano.'
  },
  'bulldog_frances' => {
    historia: 'Creado en París a mediados del siglo XIX cruzando bulldogs ingleses en miniatura con ratters parisinos. Popular entre modistas y artistas del barrio de Montmartre. Símbolo de la vida urbana francesa.',
    caracteristicas: 'Cuerpo musculoso y compacto. Cabeza cuadrada braquicéfala, orejas de murciélago erguidas. Pliegues faciales pronunciados. Pelaje corto y fino. Peso 8-14 kg.',
    aptitudes: 'Compañía urbana, perro de alerta moderado y mascota familiar en espacios reducidos. No apto para deportes de resistencia.',
    altura: '27-35 cm a la cruz',
    emergencias: 'Crisis respiratoria aguda (BOAS), golpe de calor, hernia discal con parálisis y vómitos con posible torsión gástrica.'
  },
  'labrador' => {
    historia: 'Originario de Terranova (Canadá), criado por pescadores para recuperar redes y presas acuáticas. Refinado en Inglaterra en el siglo XIX. Es la raza más popular del mundo desde décadas.',
    caracteristicas: 'Cuerpo fuerte y atlético. Pelaje corto denso con subpelo impermeable. Cola otter tail. Colores negro, chocolate y amarillo. Peso 25-36 kg.',
    aptitudes: 'Caza de cobro, perro guía, asistencia, detección, rescate acuático, terapia y compañía familiar. Excelente nadador.',
    altura: '54-57 cm (hembras), 57-62 cm (machos)',
    emergencias: 'Torsión gástrica, intoxicación por ingestión de objetos, golpe de calor durante ejercicio y crisis epiléptica.'
  },
  'pastor_aleman' => {
    historia: 'Creado por Max von Stephanitz en 1899 a partir de perros pastores alemanes. Estandarizado como perro de trabajo versátil. Usado en ambas guerras mundiales y en policía, ejército y rescate.',
    caracteristicas: 'Cuerpo ligeramente longer que tall. Pelaje doble de longitud media, colores negro y fuego más comunes. Orejas erguidas, cola en gancho. Peso 22-40 kg.',
    aptitudes: 'Pastoreo, protección, policía, ejército, rescate, perro guía y deportes de obediencia. Versátil y con gran capacidad de aprendizaje.',
    altura: '55-60 cm (hembras), 60-65 cm (machos)',
    emergencias: 'Torsión gástrica, mielopatía con debilidad aguda de patas traseras, cojera por displasia severa y convulsiones.'
  },
  'golden_retriever' => {
    historia: 'Desarrollado en las Tierras Altas de Escocia en el siglo XIX por Lord Tweedmouth, cruzando retriever amarillo con tweed water spaniel. Diseñado para caza en terrenos húmedos y escabrosos.',
    caracteristicas: 'Pelaje largo y denso de color dorado en distintos tonos. Cuerpo equilibrado y amigable. Cola con plumas. Peso 25-34 kg. Expresión amable característica.',
    aptitudes: 'Caza de cobro, perro guía, terapia asistida, detección, rescate y compañía familiar. Excelente con niños.',
    altura: '51-56 cm (hembras), 56-61 cm (machos)',
    emergencias: 'Hemorragia interna por hemangiosarcoma, torsión gástrica, convulsiones y insuficiencia cardíaca aguda.'
  },
  'gran_danes' => {
    historia: 'A pesar del nombre, originario de Alemania (Deutsche Dogge). Usado en la Edad Media para cazar jabalíes y como perro de guarda en castillos. Una de las razas más altas del mundo.',
    caracteristicas: 'Cuerpo masivo y elegante. Cabeza rectangular, orejas caídas (tradicionales). Pelaje corto en colores arlequín, azul, leonado y negro. Peso 50-90 kg.',
    aptitudes: 'Guarda, compañía, perro de exposición. Conocido como el "gigante gentil" por su temperamento dócil pese al tamaño.',
    altura: '71-86 cm a la cruz',
    emergencias: 'Torsión gástrica (altísima prioridad), colapso cardíaco, fractura por osteosarcoma y golpe de calor.'
  }
}

NEW_DISEASES = {}
load File.join(__dir__, 'expand_breed_data.rb')

def expand_text(original, extra_sentences)
  base = original.to_s.strip
  return extra_sentences.join(' ') if base.empty?
  "#{base} #{extra_sentences.join(' ')}"
end

def expand_disease(disease, animal_id, breed_id)
  name = disease['nombre']
  d = disease.dup
  existing_sintomas = (d['sintomas'] || []).map(&:to_s)

  extra_sintomas = case name
  when /hipoglucemia/i then ['Temblores musculares finos', 'Ataxia o tambaleo', 'Pérdida de consciencia breve', 'Comportamiento ansioso o agresivo repentino']
  when /luxaci/i then ['Postura en tres patas', 'Inflamación visible de la rodilla', 'Crepitación al flexionar', 'Atrofia muscular de la pata afectada']
  when /periodontal|dental/i then ['Encías retraídas', 'Dolor al tocar el hocico', 'Preferencia por alimento blando', 'Ganglios submandibulares aumentados']
  when /colapso traqueal/i then ['Cianosis de encías en crisis', 'Episodios de síncope tras excitación', 'Tos que empeora con el collar', 'Respiración abdominal marcada']
  when /displasia/i then ['Rigidez matutina', 'Chasquidos articulares', 'Reluctancia a subir escaleras', 'Postura de conejo sentado']
  when /cardiomiopat/i then ['Edema de patas delanteras', 'Pulso débil o irregular', 'Intolerancia al ejercicio leve', 'Respiración abdominal acelerada']
  when /obesidad/i then ['Imposibilidad de palpar costillas', 'Jadeo en reposo', 'Fatiga tras paseos cortos', 'Acumulación grasa en base de cola']
  when /otitis/i then ['Cabeza inclinada hacia el lado afectado', 'Otalgia al tocar la oreja', 'Otros enrojecidos', 'Pérdida de equilibrio en casos crónicos']
  when /cólico/i then ['Ausencia de deposiciones', 'Pata delantera levantada en reposo', 'Rolls repetidos', 'Pulso y respiración elevados']
  when /mastitis/i then ['Leche con coágulos o sangre', 'Ganglios axilares inflamados', 'Fiebre >39,5 °C', 'Rechazo de la cría al pecho']
  when /estasis|tricobezoar/i then ['Reducción del tamaño de las heces', 'Dolor al palpar abdomen', 'Temperatura subfebril', 'Bruxismo (rechinar dientes)']
  else ['Empeoramiento progresivo sin tratamiento', 'Cambio de conducta o apetito', 'Signos que interfieren en actividad diaria', 'Síntomas que reaparecen tras pausar medicación']
  end

  d['sintomas'] = (existing_sintomas + extra_sintomas).uniq.first(8)
  d['sintomas'] = d['sintomas'] + ['Consultar al veterinario ante cualquier signo persistente'] while d['sintomas'].length < 6

  d['diagnostico'] = expand_text(d['diagnostico'], [
    'El veterinario realizará anamnesis detallada sobre inicio, duración y factores desencadenantes.',
    'Se complementará con pruebas específicas según la sospecha clínica y el estado general del animal.',
    'El diagnóstico precoz mejora significativamente el pronóstico y reduce complicaciones secundarias.'
  ])

  d['tratamiento'] = expand_text(d['tratamiento'], [
    'El plan terapéutico se ajustará según la gravedad, la edad y las comorbilidades del paciente.',
    'Es fundamental completar los tratamientos prescritos y acudir a controles de seguimiento.',
    'No automedicar: muchos fármacos humanos o de otras especies son tóxicos.'
  ])

  d['prevencion'] = expand_text(d['prevencion'], [
    'Mantener revisiones veterinarias periódicas para detectar factores de riesgo antes de que aparezcan síntomas.',
    'Registrar cambios en apetito, conducta o eliminaciones para facilitar el diagnóstico temprano.',
    'Seguir las recomendaciones de alimentación, ejercicio y manejo específicas de la raza.'
  ])

  d['causas'] = disease_causes(name, animal_id)
  d['factores_riesgo'] = disease_risk_factors(name, animal_id, breed_id)
  d['examenes'] = disease_exams(name, animal_id)
  d['medicamentos'] = disease_medications(name, animal_id)
  d['cuidados_casa'] = disease_home_care(name, animal_id)
  d['evolucion'] = disease_evolution(name)
  d['pronostico'] = disease_prognosis(d['gravedad'], name)
  d['urgencia'] = disease_urgency(name, d['gravedad'])

  d
end

def disease_causes(name, animal_id)
  case name
  when /hipoglucemia/i then 'Reservas limitadas de glucógeno hepático en animales toy, ayunos prolongados, vómitos/diarrea, ejercicio excesivo sin alimentación, infecciones, tumores pancreáicos (insulinoma) o sobredosis de insulina.'
  when /luxaci/i then 'Predisposición genética con mal alineamiento del surco troclear, traumatismos, deformidades congénitas de las patas, obesidad que sobrecarga la articulación y desarrollo óseo desigual en cachorros.'
  when /periodontal/i then 'Acumulación de placa bacteriana por mala higiene oral, apiñamiento dental en mandíbulas pequeñas, dieta blanda sin acción mecánica, edad avanzada y predisposición genética de razas toy.'
  when /colapso traqueal/i then 'Debilidad congénita de los anillos traqueales de cartílagos, obesidad, irritación crónica por tirón de collar, infecciones respiratorias y edad avanzada.'
  when /displasia/i then 'Herencia poligénica, nutrición desequilibrada en crecimiento, crecimiento rápido, ejercicio excesivo en cachorros y sobrepeso que agrava la laxitud articular.'
  when /cardiomiopat/i then 'Mutaciones genéticas hereditarias, hipertensión, hipertiroidismo (gatos), edad avanzada y posible componente viral en algunas formas.'
  when /torsión|dilatación.*gástrica/i then 'Ingesta rápida de grandes volúmenes, ejercicio intenso postprandial, predisposición de razas grandes de pecho profundo, estrés y anatomía gástrica laxa.'
  when /otitis/i then 'Orejas caídas que retienen humedad, alergias cutáneas, parásitos auriculares, cuerpos extraños, baños frecuentes sin secado y limpieza agresiva del conducto.'
  when /estasis/i then 'Dieta baja en fibra, estrés, dolor dental, deshidratación, motilidad intestinal reducida por medicamentos y acumulación de pelo ingerido.'
  when /cólico/i then 'Cambios bruscos de dieta, parásitos, acumulación de gas, obstrucciones, estrés por transporte y acceso a pastos ricos tras ayuno.'
  else "Causas multifactoriales que incluyen predisposición genética de la raza, factores ambientales, nutrición inadecuada, infecciones, parásitos y envejecimiento. Consultar al veterinario para identificar la causa específica en cada caso de #{name.downcase}."
  end
end

def disease_risk_factors(name, _animal_id, _breed_id)
  base = ['Predisposición genética de la raza', 'Edad avanzada', 'Obesidad o condición corporal inadecuada', 'Historial familiar de la enfermedad', 'Manejo o alimentación inadecuados']
  case name
  when /hipoglucemia/i then ['Raza toy o cachorro menor de 4 meses', 'Ayuno superior a 6-8 horas', 'Vómitos o diarrea activos', 'Ejercicio intenso sin reposición calórica', 'Enfermedades hepáticas o sépticas']
  when /luxaci|displasia/i then ['Sobrepeso crónico', 'Saltos desde muebles o vehículos', 'Superficies resbaladizas en casa', 'Cría sin cribado ortopédico', 'Ejercicio de alto impacto en crecimiento']
  when /periodontal/i then ['No cepillado dental regular', 'Dieta exclusivamente blanda', 'Edad mayor de 3 años sin limpieza profesional', 'Apiñamiento dental congénito', 'Tabaquismo pasivo en el hogar']
  when /colapso traqueal/i then ['Uso de collar en lugar de arnés', 'Obesidad', 'Ambientes con humo o polvo', 'Excitación frecuente con tirones', 'Raza toy braquicéfala o miniatura']
  when /cardiomiopat/i then ['Líneas genéticas sin cribado cardíaco', 'Edad media-avanzada', 'Sedentarismo', 'Hipertiroidismo no tratado (gatos)', 'Obesidad']
  when /torsión|dilatación/i then ['Raza de pecho profundo y gran tamaño', 'Una sola comida voluminosa al día', 'Comer muy rápido', 'Ejercicio vigoroso 1-2 h postprandial', 'Historial familiar de torsión']
  else base
  end
end

def disease_exams(name, _animal_id)
  case name
  when /hipoglucemia/i then ['Glucosa en sangre (posible repetición en ayunas)', 'Hemograma completo', 'Perfil bioquímico hepático', 'Ecografía abdominal si hay sospecha de tumor', 'Medición de insulina si hay hipoglucemia persistente', 'Monitorización continua de glucosa en crisis']
  when /luxaci|displasia/i then ['Exploración ortopédica con palpación', 'Radiografías en posición estándar', 'Clasificación por grados (OFA/PennHIP en displasia)', 'Artroscopia en casos seleccionados', 'Análisis de líquido sinovial si hay inflamación', 'Evaluación de rango articular bajo sedación']
  when /periodontal/i then ['Exploración oral completa bajo sedación', 'Radiografías dentales digitales', 'Sondaje de bolsas periodontales', 'Citología de secreción gingival', 'Hemograma preanestésico', 'Evaluación de movilidad dental']
  when /cardiomiopat/i then ['Ecocardiografía Doppler', 'Electrocardiograma (ECG)', 'Radiografía torácica', 'NT-proBNP en sangre', 'Presión arterial', 'Prueba genética según raza']
  when /otitis/i then ['Otoscopia con otoscopio o endoscopio', 'Citología del exudado auricular', 'Cultivo bacteriano y antibiograma', 'Descarte de cuerpo extraño', 'Evaluación de alergia cutánea subyacente', 'Biopsia en otitis crónicas severas']
  when /cólico/i then ['Auscultación intestinal en 4 cuadrantes', 'Palpación rectal', 'Ecografía abdominal', 'Análisis de sangre (PCV, proteína, lactato)', 'Sonda nasogástrica para reflujo', 'Radiografía/abdominocentesis si hay sospecha de torsión']
  when /estasis/i then ['Palpación abdominal (masa gasosa en ciego)', 'Radiografía lateral y ventrodorsal', 'Ecografía abdominal', 'Hemograma y bioquímica', 'Análisis de heces', 'Monitorización de temperatura y producción de heces']
  else ['Anamnesis y examen físico completo', 'Análisis de sangre básico', 'Pruebas de imagen según órgano afectado', 'Cultivos si hay sospecha infecciosa', 'Pruebas específicas según sospecha clínica', 'Seguimiento seriado de parámetros']
  end
end

def disease_medications(name, _animal_id)
  case name
  when /hipoglucemia/i then ['Glucosa oral (miel, jarabe)', 'Dextrosa IV en crisis', 'Glucagón inyectable', 'Fluidoterapia con electrolitos', 'Alimentación fraccionada de recuperación']
  when /luxaci|displasia/i then ['Meloxicam o carprofeno (AINE)', 'Gabapentina para dolor neuropático', 'Condroprotectores (glucosamina/condroitina)', 'Omeprazol gastroprotector con AINE', 'Tramadol en dolor moderado-severo']
  when /periodontal/i then ['Clindamicina oral', 'Antisépticos bucales (clorhexidina)', 'Antiinflamatorios postextracción', 'Analgesia (buprenorfina)', 'Antibiótico según cultivo']
  when /colapso traqueal/i then ['Butorfanol o maropitant (antitusígeno)', 'Teofilina o terbutalina (broncodilatador)', 'Prednisolona en inflamación', 'Sedantes en crisis de ansiedad', 'Stent traqueal (procedimiento quirúrgico)']
  when /cardiomiopat/i then ['Enalapril o benazepril (IECA)', 'Pimobendan (inotrópico positivo)', 'Furosemida (diurético)', 'Clopidogrel (anticoagulante)', 'Atenolol en taquicardia']
  when /otitis/i then ['Gotas óticas con antibiótico y antifúngico', 'Limpiador auricular ceruminolítico', 'Apoquel o ciclosporina si alergia base', 'Antiparasitarios auriculares (otodectes)', 'Corticoide tópico en inflamación severa']
  when /estasis/i then ['Metoclopramida o cisaprida (procinéticos)', 'Ranitidina o omeprazol', 'Fluidoterapia subcutánea o IV', 'Buprenorfina (analgesia)', 'Simethicona si hay gas']
  else ['Antiinflamatorios según prescripción', 'Antibióticos si hay infección confirmada', 'Analgesia adecuada al peso', 'Suplementos de soporte según déficit', 'Medicación específica tras diagnóstico definitivo']
  end
end

def disease_home_care(name, _animal_id)
  case name
  when /hipoglucemia/i then 'Ofrecer comida frecuente en pequeñas porciones; tener siempre miel o glucosa oral accesible; evitar ayunos prolongados; monitorizar nivel de alerta y coordinación; mantener ambiente cálido y tranquilo durante la recuperación.'
  when /luxaci|displasia/i then 'Mantener peso ideal estricto; usar rampas en lugar de saltos; camas ortopédicas; ejercicio de bajo impacto (natación si es posible); aplicar frío/calor según indicación veterinaria; suplementos condroprotectores si prescritos.'
  when /periodontal/i then 'Cepillado dental diario con pasta enzimática para mascotas; snacks dentales aprobados por VOHC; agua potable siempre disponible; revisiones dentales programadas; evitar juguetes muy duros que fracturen dientes.'
  when /colapso traqueal/i then 'Usar arnés en todos los paseos; evitar ambientes con humo, polvo y aerosoles; mantener peso ideal; usar aire acondicionado en verano; reducir situaciones de excitación extrema; elevar comederos si mejora la respiración.'
  when /cardiomiopat/i then 'Reducir el estrés y la actividad intensa; dieta baja en sodio si indicada; administrar medicación a la misma hora diariamente; monitorizar frecuencia respiratoria en reposo (contar respiraciones dormido); acudir de urgencia si >40 rpm en gatos o >35 en perros.'
  when /estasis/i then 'Ofrecer heno de calidad a libre disposición; estimular movimiento suave; masaje abdominal gentil si el veterinario lo indica; hidratación con verduras frescas; monitorizar producción de heces cada hora; mantener ambiente tranquilo y temperatura estable.'
  else 'Seguir estrictamente las indicaciones del veterinario; registrar evolución de síntomas en un diario; no suspender medicación sin consultar; mantener higiene del entorno; acudir a controles programados; contactar al veterinario ante empeoramiento.'
  end
end

def disease_evolution(name)
  case name
  when /hipoglucemia/i then 'Puede aparecer de forma aguda en minutos tras ayuno o esfuerzo. Sin tratamiento progresa a convulsiones, coma y muerte. Con manejo adecuado la recuperación suele ser rápida, pero las recurrencias indican enfermedad subyacente a investigar.'
  when /luxaci/i then 'Gradualmente empeora desde cojera intermitente (grado I) hasta luxación permanente (grado IV). La artrosis secundaria se desarrolla en meses-años. El tratamiento precoz ralentiza la degeneración articular.'
  when /periodontal/i then 'Progresión lenta en años: placa → sarro → gingivitis → periodontitis → pérdida ósea → movilidad dental. Las bacterias pueden afectar corazón, riñones e hígado por bacteriemia crónica.'
  when /cardiomiopat/i then 'En gatos, fase oculta prolongada seguida de insuficiencia cardíaca aguda o tromboembolismo. En perros, insuficiencia progresiva en meses-años. Requiere ajuste continuo de medicación.'
  when /torsión|dilatación/i then 'Evolución en horas: distensión → torsión → isquemia → shock → muerte. Cada minuto sin tratamiento reduce supervivencia. Más del 30% de recurrencia sin gastropexia.'
  else "Evolución variable según gravedad al diagnóstico y respuesta al tratamiento. En formas leves puede estabilizarse con manejo conservador; en formas graves progresa rápidamente sin intervención veterinaria. El seguimiento periódico es esencial."
  end
end

def disease_prognosis(gravedad, _name = nil)
  case gravedad
  when 'leve' then 'Bueno con manejo adecuado. La mayoría de casos responde bien al tratamiento y mantiene buena calidad de vida. Requiere seguimiento para evitar recurrencias.'
  when 'moderada' then 'Reservado a bueno según respuesta al tratamiento y detección precoz. Puede requerir tratamiento crónico o intervenciones periódicas. Con adherencia al plan veterinario el pronóstico mejora significativamente.'
  when 'grave' then 'Reservado. Requiere intervención veterinaria urgente y tratamiento intensivo. Sin tratamiento oportuno puede ser fatal. Con manejo adecuado algunos pacientes mantienen calidad de vida aceptable a largo plazo.'
  else 'Variable según gravedad, edad del animal y tratamiento instaurado.'
  end
end

def disease_urgency(name, gravedad)
  urgent = ['Acudir INMEDIATAMENTE al veterinario de urgencias si hay convulsiones, dificultad respiratoria severa, colapso, abdomen distendido, sangrado abundante o dolor intenso.']
  case name
  when /hipoglucemia/i then 'Urgencia si hay convulsiones, coma o glucosa <40 mg/dL. En casa: aplicar miel en encías y acudir al veterinario de inmediato.'
  when /torsión|dilatación/i then 'EMERGENCIA ABSOLUTA. Cada minuto cuenta. No esperar: acudir al hospital veterinario 24h con cirugía disponible.'
  when /estasis/i then 'Urgencia si no come ni produce heces >12 horas. No esperar al día siguiente: la estasis puede ser fatal en 24-48 horas.'
  when /cólico/i then 'Urgencia si dolor intenso, ausencia de deposiciones >12 h, pulso >60 lpm o intentos de decúbito sin poderse levantar.'
  when /cardiomiopat/i then 'Urgencia si parálisis súbita de patas traseras, respiración >40 rpm en reposo o colapso.'
  when /obstruc/i then 'Urgencia si no orina >24 h (machos) o esfuerzo sin producir gotas. Obstrucción urinaria felina es mortal en horas.'
  else gravedad == 'grave' ? urgent.first : 'Consultar al veterinario en 24-48 horas si los síntomas persisten o empeoran. Acudir antes si hay signos de dolor intenso, fiebre alta o deterioro rápido.'
  end
end

def expand_breed(breed, animal_id)
  b = breed.dup
  config = ANIMAL_CONFIG[animal_id] || ANIMAL_CONFIG['perros']
  extra = BREED_DATA[b['id']] || {}

  b['descripcion'] = expand_text(b['descripcion'], [
    "Es una raza reconocida por su #{b['temperamento'].split(',').first.downcase.strip}.",
    "Con una esperanza de vida de #{b['esperanza_vida']}, requiere un tutor informado sobre sus necesidades específicas.",
    "Originaria de #{b['origen']}, se ha adaptado tanto a entornos rurales como urbanos según su línea de cría."
  ])

  b['cuidados'] = expand_text(b['cuidados'], [
    'Programar revisiones veterinarias periódicas según la edad y el estado de salud.',
    'Proporcionar enriquecimiento ambiental acorde a su temperamento y nivel de actividad.',
    'Mantener identificación (microchip, placa) y seguro o fondo de emergencias veterinarias.'
  ])

  b['alimentacion'] = expand_text(b['alimentacion'], [
    'Ajustar las raciones según edad, peso, actividad y condición corporal evaluada cada mes.',
    'Garantizar agua fresca limpia disponible permanentemente.',
    'Evitar alimentos tóxicos para la especie y premios que superen el 10% de la ingesta calórica diaria.'
  ])

  b['historia'] = extra[:historia] || "Raza de #{b['origen']} con historia ligada al aprovechamiento tradicional de la especie y posterior selección como animal de compañía o producción. Su desarrollo responde a necesidades locales de clima, terreno y función."
  b['caracteristicas'] = extra[:caracteristicas] || "Ejemplar de #{b['nombre']} con peso habitual de #{b['peso']}. Presenta características morfológicas propias de su grupo zootécnico, con variaciones según la línea de cría y el estándar de la raza."
  b['aptitudes'] = extra[:aptitudes] || "Utilizado tradicionalmente según su categoría (#{animal_id}): compañía, trabajo o producción. Su temperamento #{b['temperamento'].split(',').first.downcase.strip} lo hace apto para tutores que conozcan sus necesidades específicas."
  b['altura'] = extra[:altura] || "Según estándar de raza; consultar medidas oficiales del club especializado. Peso de referencia: #{b['peso']}."
  b['parametros_salud'] = extra[:parametros_salud] || config[:parametros_salud]
  b['vacunacion'] = extra[:vacunacion] || config[:vacunacion]
  b['desparasitacion'] = extra[:desparasitacion] || config[:desparasitacion]
  b['senales_alerta'] = extra[:senales_alerta] || config[:senales_base]
  b['revisiones'] = extra[:revisiones] || config[:revisiones]
  b['emergencias'] = extra[:emergencias] || "Emergencias comunes: trauma, dificultad respiratoria, convulsiones, intoxicación, rechazo alimentario prolongado y colapso. Acudir al servicio de urgencias veterinarias 24 horas ante signos de dolor intenso o deterioro rápido."

  existing_names = b['enfermedades'].map { |e| e['nombre'] }
  new_diseases = (NEW_DISEASES[b['id']] || []).reject { |d| existing_names.include?(d['nombre']) }
  target = 6
  needed = [0, target - b['enfermedades'].length].max
  to_add = new_diseases.first(needed)
  to_add = new_diseases.first(2) if to_add.length < 2 && new_diseases.length >= 2

  all_diseases = b['enfermedades'] + to_add
  b['enfermedades'] = all_diseases.map { |d| expand_disease(d, animal_id, b['id']) }

  b
end

if __FILE__ == $PROGRAM_NAME
  data = JSON.parse(File.read(INPUT))
  data['animales'] = data['animales'].map do |animal|
    animal = animal.dup
    animal['razas'] = animal['razas'].transform_values do |breeds|
      breeds.map { |breed| expand_breed(breed, animal['id']) }
    end
    animal
  end

  File.write(OUTPUT, JSON.pretty_generate(data))
  puts "Expandido: #{OUTPUT}"
  puts "Razas: #{data['animales'].flat_map { |a| a['razas'].values.flatten }.length}"

  JSON.parse(File.read(OUTPUT))
  puts 'JSON válido ✓'
end
