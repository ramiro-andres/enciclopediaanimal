# frozen_string_literal: true

# Genera data/diccionario_medicos.json a partir del contenido de la enciclopedia
# y una biblioteca curada de definiciones.

require 'json'
require_relative 'clinical_disease_library'
require_relative 'pharma_protocols'

ROOT = File.expand_path('../..', __dir__)

def term(termino, definicion, ejemplo = nil)
  { 'termino' => termino, 'definicion' => definicion, 'ejemplo' => ejemplo }.compact
end

def category(id, nombre, descripcion, icono, terminos)
  {
    'id' => id,
    'nombre' => nombre,
    'descripcion' => descripcion,
    'icono' => icono,
    'terminos' => terminos
  }
end

BASE_CATEGORIES = [
  category('ficha_enfermedad', 'Ficha clínica de enfermedad',
           'Campos que verás al abrir el detalle de una enfermedad o condición.', '🩺', [
             term('Síntomas', 'Signos observables del animal enfermo: cambios de conducta, apariencia, apetito, movimiento, producción o eliminaciones.'),
             term('Causas', 'Factores que originan la enfermedad: infecciones, parásitos, traumatismos, genética, nutrición o manejo deficiente.'),
             term('Factores de riesgo', 'Circunstancias que aumentan la probabilidad sin ser la causa directa: edad, raza, ambiente, estrés o historial sanitario.'),
             term('Criterios diagnósticos', 'Hallazgos clínicos y de laboratorio que permiten confirmar la enfermedad con mayor certeza.'),
             term('Diagnóstico diferencial', 'Otras enfermedades con síntomas parecidos que deben descartarse antes de confirmar el diagnóstico.'),
             term('Clasificación / estadiamiento', 'Sistema que describe gravedad, extensión o fase: leve, moderada, grave, aguda o crónica.'),
             term('Diagnóstico', 'Proceso para identificar la enfermedad mediante anamnesis, examen físico y pruebas complementarias.'),
             term('Exámenes complementarios', 'Pruebas de apoyo: sangre, heces, imagen, cultivos, biopsias o monitorización.'),
             term('Tratamiento', 'Medidas terapéuticas: medicación, cirugía, fluidos, dieta, reposo o cambios ambientales.'),
             term('Protocolo farmacológico', 'Tabla con principio activo, dosis mg/kg, vía, frecuencia y duración. Requiere prescripción veterinaria.'),
             term('Medicamentos habituales', 'Fármacos frecuentes para la condición cuando no hay protocolo detallado en la ficha.'),
             term('Prevención', 'Medidas para reducir aparición o propagación: vacunas, bioseguridad, nutrición e higiene.'),
             term('Cuidados en casa', 'Recomendaciones al cuidador durante tratamiento o convalecencia bajo supervisión veterinaria.'),
             term('Evolución', 'Cómo suele progresar la enfermedad con o sin tratamiento en el corto y mediano plazo.'),
             term('Pronóstico', 'Expectativa de resultado: recuperación, manejo crónico, secuelas o riesgo vital.'),
             term('Contraindicaciones', 'Situaciones o fármacos que no deben usarse por riesgo de empeorar el cuadro.'),
             term('Notas clínicas', 'Observaciones prácticas sobre seguimiento, matices del caso o particularidades de especie/raza.'),
             term('Urgencia', 'Señales que exigen atención veterinaria inmediata sin esperar evolución en casa.'),
             term('Gravedad', 'Nivel de impacto clínico en la ficha: leve, moderada o grave.'),
             term('Anamnesis', 'Entrevista clínica donde se recogen antecedentes, síntomas, alimentación, vacunas y exposición a riesgos.'),
             term('Examen físico', 'Inspección, palpación, auscultación y valoración neurológica/ortopédica del paciente.'),
             term('Hallazgo clínico', 'Dato objetivo detectado por el veterinario durante la exploración.'),
             term('Signo clínico', 'Manifestación observable de enfermedad; puede ser específico o inespecífico.'),
             term('Síndrome', 'Conjunto de signos que aparecen juntos y orientan hacia un grupo de diagnósticos.'),
             term('Agudo', 'Inicio rápido y evolución corta (horas a días).'),
             term('Crónico', 'Proceso prolongado o recurrente (semanas a años).'),
             term('Idiopático', 'De causa desconocida tras descartar causas identificables.'),
             term('Congénito', 'Presente desde el nacimiento o desarrollo fetal.'),
             term('Adquirido', 'Aparece después del nacimiento por infección, trauma, nutrición o desgaste.'),
             term('Recidiva', 'Reaparición de la enfermedad tras haber mejorado o curado.'),
             term('Secuela', 'Consecuencia permanente o prolongada tras una enfermedad o tratamiento.')
           ]),
  category('ficha_raza', 'Salud y manejo de la raza',
           'Conceptos de las fichas de raza sobre prevención, cribado y bienestar.', '🐾', [
             term('Parámetros de salud', 'Valores fisiológicos de referencia: temperatura, pulso, respiración y otros indicadores.'),
             term('Vacunación', 'Administración de vacunas para inmunidad protectora contra enfermedades infecciosas.'),
             term('Calendario de vacunación', 'Cronograma de edades o fechas para cada vacuna y refuerzos.'),
             term('Desparasitación', 'Control de parásitos internos (helmintos, protozoos) y externos (pulgas, garrapatas, ácaros).'),
             term('Predisposiciones genéticas', 'Enfermedades o rasgos con mayor probabilidad en cierta raza por herencia.'),
             term('Cribado de salud', 'Pruebas antes de reproducción o en controles para detectar enfermedades hereditarias.'),
             term('Nutrición clínica', 'Alimentación con enfoque sanitario: peso ideal, dietas terapéuticas y nutrientes críticos.'),
             term('Manejo clínico', 'Identificación, transporte, primeros auxilios y cuidados orientados a la salud.'),
             term('Señales de alerta', 'Cambios que deben motivar consulta aunque no sean emergencia absoluta.'),
             term('Revisiones veterinarias', 'Controles programados de estado general, vacunas, parásitos y detección precoz.'),
             term('Emergencias frecuentes', 'Situaciones urgentes habituales en la raza o especie.'),
             term('Microchip', 'Identificación electrónica implantada bajo la piel (ISO 11784/11785).'),
             term('Collar isabelino', 'Protector rígido que evita que el animal se lama o mordisquee heridas o suturas.'),
             term('Botiquín veterinario básico', 'Gasas, suero fisiológico, vendas, miel (hipoglucemia) y datos de urgencias.'),
             term('Enriquecimiento ambiental', 'Estímulos físicos y mentales que reducen estrés y mejoran bienestar.')
           ]),
  category('nutricion', 'Nutrición',
           'Términos de alimentación y nutrición detallada por raza.', '🥗', [
             term('Tipos de dieta', 'Modalidades: pienso comercial, casera balanceada, BARF, forraje, suplementos o ración productiva.'),
             term('Frecuencia de alimentación', 'Número de comidas diarias según edad, tamaño y actividad.'),
             term('Porción diaria', 'Cantidad diaria en gramos, % del peso vivo o medidas prácticas.'),
             term('Requerimientos nutricionales', 'Necesidades de proteína, grasa, fibra, vitaminas y minerales.'),
             term('Dietas por etapa', 'Pautas para cachorro/cria, adulto, gestación, lactación o geriatría.'),
             term('Nutrición productiva', 'Alimentación orientada a leche, huevos, carne, lana o crecimiento en explotación.'),
             term('Alimentos a evitar', 'Ingredientes tóxicos o de riesgo para la especie.'),
             term('BARF', 'Dieta cruda biológicamente apropiada; requiere formulación veterinaria para equilibrio.'),
             term('Pienso seco', 'Alimento industrial extrusionado o peletizado con nutrientes balanceados.'),
             term('Condición corporal (BCS)', 'Escala visual 1-9 del graso corporal; ideal suele ser 4-5/9.'),
             term('Conversión alimenticia', 'Kg de alimento necesarios para producir 1 kg de ganancia de peso o biomasa.'),
             term('Ración', 'Cantidad total de alimento formulado para un periodo o grupo animal.'),
             term('Suplementación', 'Aporte de vitaminas, minerales, electrolitos o aminoácidos además de la dieta base.'),
             term('Dieta terapéutica', 'Alimento formulado para enfermedad específica: renal, hepática, obesidad, cristales urinarios.'),
             term('Ayuno prequirúrgico', 'Periodo sin comida antes de anestesia para reducir riesgo de aspiración.')
           ]),
  category('produccion', 'Producción y bioseguridad',
           'Vocabulario de razas productivas y manejo en granja.', '🏭', [
             term('Sistema productivo', 'Modelo de explotación: extensivo, semiintensivo, intensivo, jaula o estanque.'),
             term('Rendimiento productivo', 'Cantidad y calidad de leche, carne, huevos, lana o biomasa.'),
             term('Indicadores productivos', 'Métricas: conversión, mortalidad, fertilidad, prolificidad o persistencia de postura.'),
             term('Bioseguridad', 'Medidas para prevenir entrada y diseminación de enfermedades en la explotación.'),
             term('Cuarentena', 'Aislamiento temporal de animales nuevos o enfermos antes de integrarlos al grupo.'),
             term('Bienestar animal', 'Condiciones que permiten comportamientos naturales y evitan sufrimiento innecesario.'),
             term('Registros productivos', 'Anotaciones de producción, tratamientos, mortalidad y eventos sanitarios.'),
             term('Todo dentro / todo fuera', 'Principio de no mezclar lotes de edades sin cuarentena para reducir enfecciones.'),
             term('Periodo de retirada', 'Tiempo obligatorio tras un fármaco antes de consumir leche, huevos o carne.'),
             term('Ordeño', 'Extracción de leche; la higiene reduce mastitis.'),
             term('Lactancia', 'Periodo de producción de leche tras el parto.'),
             term('Gestación', 'Embarazo; requiere nutrición y manejo específicos.'),
             term('Destete', 'Separación de cría de la madre; momento crítico de estrés e infecciones.'),
             term('Engorde', 'Fase de acumulación de peso para faena o venta.'),
             term('Postura', 'Producción de huevos en aves.'),
             term('Prolificidad', 'Número de crías por parto o camada.'),
             term('Mortalidad', 'Porcentaje de animales que mueren en un lote o periodo; indicador sanitario clave.')
           ]),
  category('farmacia', 'Farmacología veterinaria',
           'Términos de protocolos, dosis y prescripción.', '💊', [
             term('mg/kg', 'Miligramos de fármaco por kilogramo de peso vivo; unidad estándar de dosis.'),
             term('Principio activo', 'Sustancia que produce el efecto terapéutico, independiente del nombre comercial.'),
             term('Vía de administración', 'Oral, subcutánea (SC), intramuscular (IM), intravenosa (IV) o tópica.'),
             term('Analgesia', 'Tratamiento del dolor; puede combinar AINE, opioides y otros.'),
             term('AINE', 'Antiinflamatorio no esteroideo; contraindicado en deshidratación, riñón o hígado grave.'),
             term('Gastroprotector', 'Protege mucosa gástrica; frecuente con AINE o úlceras.'),
             term('Condroprotector', 'Suplemento articular (glucosamina, condroitina) en artrosis o predisposición ortopédica.'),
             term('Antibiótico', 'Fármaco antibacteriano; completar ciclo y respetar cultivo/antibiograma cuando exista.'),
             term('Antiparasitario', 'Contra parásitos internos o externos; depende de especie y parásito.'),
             term('Antifúngico', 'Contra hongos; ej. itraconazol, nistatina según localización.'),
             term('Antiemético', 'Reduce vómitos y náuseas; ej. maropitant.'),
             term('Procinético', 'Estimula motilidad gastrointestinal; útil en estasis o íleo.'),
             term('Fluidoterapia', 'Líquidos IV o SC para deshidratación, shock o soporte sistémico.'),
             term('Corticosteroide', 'Potente antiinflamatorio inmunosupresor; descenso gradual obligatorio.'),
             term('IECA', 'Inhibidor de la enzima convertidora de angiotensina; usado en insuficiencia cardíaca y proteinuria.'),
             term('Inotrópico positivo', 'Aumenta contractilidad cardíaca; ej. pimobendan.'),
             term('Diurético', 'Aumenta eliminación de líquidos; monitorizar electrolitos y riñón.'),
             term('Anticoagulante / antiagregante', 'Reduce formación de coágulos; ej. clopidogrel en cardiopatía felina.'),
             term('Antihistamínico', 'Alivia reacciones alérgicas; útil en dermatitis atópica como coadyuvante.'),
             term('Quelante de fósforo', 'Reduce absorción de fósforo en enfermedad renal crónica.'),
             term('Periodo de retirada (fármaco)', 'Tiempo mínimo entre última dosis y consumo de producto animal.')
           ]),
  category('examenes', 'Exámenes y pruebas diagnósticas',
           'Pruebas que aparecen en las fichas clínicas de la enciclopedia.', '🔬', [
             term('Hemograma completo', 'Cuenta de glóbulos rojos, blancos y plaquetas; detecta anemia, infección o inflamación.'),
             term('Perfil bioquímico', 'Evalúa hígado, riñón, electrolitos, proteínas y glucosa en sangre.'),
             term('Perfil bioquímico hepático', 'ALT, ALP, bilirrubina y otros marcadores de función hepática.'),
             term('Glucosa en sangre', 'Mide azúcar sanguíneo; esencial en hipoglucemia, diabetes o crisis metabólicas.'),
             term('Radiografía', 'Imagen por rayos X; útil en huesos, tórax, abdomen y cálculos radiopacos.'),
             term('Radiografía torácica', 'Evalúa corazón, pulmones y estructuras torácicas.'),
             term('Ecografía abdominal', 'Imagen en tiempo real de órganos abdominales, masas y líquido libre.'),
             term('Ecocardiografía Doppler', 'Estudio del corazón: tamaño, contractilidad, válvulas y presiones.'),
             term('Electrocardiograma (ECG)', 'Registra actividad eléctrica cardíaca; detecta arritmias.'),
             term('NT-proBNP', 'Biomarcador cardíaco en sangre; útil en sospecha de insuficiencia cardíaca.'),
             term('Presión arterial', 'Control en cardiopatía, renal crónica o hipertensión sistémica.'),
             term('Coproscopia / análisis de heces', 'Detecta parásitos, sangre oculta o agentes infecciosos en heces.'),
             term('Cultivo bacteriano y antibiograma', 'Identifica bacteria y antibióticos efectivos.'),
             term('Citología', 'Estudio microscópico de células en secreciones, masas o extendidos.'),
             term('Biopsia', 'Muestra de tejido para diagnóstico histopatológico definitivo.'),
             term('Prueba genética', 'Detecta mutaciones asociadas a enfermedad hereditaria según raza.'),
             term('Artroscopia', 'Exploración quirúrgica mínimamente invasiva de articulaciones.'),
             term('Clasificación OFA / PennHIP', 'Sistemas de evaluación radiográfica de displasia de cadera en perros.'),
             term('Palpación rectal', 'Exploración rectal en rumiantes y equinos; evalúa rumen, útero o colon.'),
             term('Auscultación', 'Escucha de corazón, pulmones e intestinos con fonendoscopio.'),
             term('Otoscopia', 'Examen del conducto y oído medio con otoscopio.'),
             term('PCV (hematocrito)', 'Porcentaje de glóbulos rojos; detecta anemia o hemoconcentración.'),
             term('Lactato sérico', 'Marcador de perfusión tisular; elevado en shock o isquemia (ej. torsión gástrica).'),
             term('SDMA', 'Biomarcador renal que detecta pérdida de función antes que creatinina.'),
             term('UPC (proteinuria)', 'Relación proteína/creatinina en orina; estadia enfermedad renal.'),
             term('Curva glucémica', 'Mediciones seriadas de glucosa; diagnóstico y control de diabetes.'),
             term('Abdominocentesis', 'Punción abdominal para analizar líquido libre.'),
             term('Sonda nasogástrica', 'Tubo por nariz al estómago para descompresión o alimentación.'),
             term('Exploración ortopédica', 'Valoración de huesos, articulaciones, ligamentos y marcha.'),
             term('Exploración oral / dental', 'Evaluación de dientes, encías y cavidad oral bajo sedación si es necesario.'),
             term('Monitorización de temperatura', 'Control de fiebre o hipotermia durante enfermedad o postoperatorio.'),
             term('Pruebas de imagen', 'Término general para radiografía, ecografía, TC o resonancia según caso.')
           ]),
  category('sintomas', 'Síntomas y signos clínicos',
           'Manifestaciones frecuentes en las fichas de enfermedades.', '📌', [
             term('Anorexia', 'Pérdida total o marcada del apetito.'),
             term('Letargo', 'Decaimiento, poca respuesta al entorno y tendencia a dormir más de lo normal.'),
             term('Vómitos', 'Expulsión activa del contenido gástrico; distinguir de regurgitación.'),
             term('Diarrea', 'Heces líquidas o blandas con mayor frecuencia.'),
             term('Cojera', 'Alteración de la marcha por dolor o lesión en extremidad.'),
             term('Tos', 'Expulsión brusca de aire; puede ser cardíaca, respiratoria o traqueal.'),
             term('Jadeo', 'Respiración rápida con boca abierta; normal en perros tras ejercicio, anormal en reposo.'),
             term('Poliuria y polidipsia (PUPD)', 'Orina y bebe más de lo normal; orienta a renal, diabetes o endocrino.'),
             term('Fiebre', 'Temperatura elevada; en muchas especies >39,5 °C indica proceso inflamatorio o infeccioso.'),
             term('Convulsiones', 'Crisis neurológicas con movimientos involuntarios; urgencia si prolongadas.'),
             term('Deshidratación', 'Pérdida de líquidos; encías secas, pliegue cutáneo persistente, ojos hundidos.'),
             term('Ictericia', 'Coloración amarilla de mucosas por acumulación de bilirrubina (hígado o hemólisis).'),
             term('Ascitis', 'Líquido en el abdomen; puede asociarse a insuficiencia cardíaca derecha o hígado.'),
             term('Edema', 'Acumulación de líquido en tejidos; puede verse en extremidades o submandibular.'),
             term('Disnea', 'Dificultad respiratoria evidente; urgencia si severa.'),
             term('Estridor', 'Ruido agudo al inspirar; común en vías aéreas estrechas o obstrucción urinaria felina.'),
             term('Halitosis', 'Mal aliento; puede indicar enfermedad dental, renal o metabólica.'),
             term('Prurito', 'Picor intenso con rascado, lamido o frotamiento.'),
             term('Alopecia', 'Pérdida de pelo localizada o generalizada.'),
             term('Distensión abdominal', 'Abdomen inflado; puede ser gas, líquido, masa o torsión.'),
             term('Shock', 'Fallo circulatorio con mucosas pálidas, pulso débil y colapso; emergencia.'),
             term('Síncope', 'Pérdida breve de consciencia por bajo flujo cerebral.'),
             term('Hematuria', 'Sangre en la orina.'),
             term('Secreción nasal u ocular', 'Moco o pus en nariz u ojos; infección, alergia o irritación.'),
             term('Babeo (sialorrea)', 'Salivación excesiva; dolor oral, náuseas o intoxicación.'),
             term('Temblores', 'Movimientos involuntarios finos; pueden indicar hipoglucemia, frío o dolor.'),
             term('Rumia ausente', 'En rumiantes, dejar de rumiar indica dolor, fiebre o trastorno digestivo grave.'),
             term('Baja producción láctea', 'Caída de leche en hembras productivas; frecuente con mastitis o estrés.'),
             term('Muerte súbita', 'Fallecimiento inesperado sin signos prolongados; cardíaca, tóxica o infecciosa.')
           ]),
  category('anatomia', 'Anatomía y fisiología',
           'Términos anatómicos y funcionales usados en diagnóstico.', '🫀', [
             term('Rumen / panza', 'Primer estómago del rumiante donde fermenta el forraje.'),
             term('Retículo', 'Segundo compartimento ruminal; participa en eructo y trituración.'),
             term('Abomaso', 'Cuarto estómago ruminal; digestión ácida similar a monogástricos.'),
             term('Rótula', 'Hueso sesamoideo en la rodilla; su luxación causa cojera.'),
             term('Cadera (articulación coxofemoral)', 'Unión pelvis-fémur; displasia afecta esta articulación.'),
             term('Vías aéreas superiores', 'Nariz, faringe y laringe; críticas en síndrome braquicefálico.'),
             term('Tráquea', 'Conducto del aire al pulmón; colapso traqueal estrecha su luz.'),
             term('Glándula mamaria / ubre', 'Produce leche; la mastitis inflama estos tejidos.'),
             term('Vejiga natatoria', 'Órgano de flotación en peces; su trastorno causa nado anormal.'),
             term('Branquias', 'Órganos respiratorios de peces; sensibles a baja oxigenación y parásitos.'),
             term('Cloaca', 'Apertura común digestiva, urinaria y reproductiva en aves y reptiles.'),
             term('Branquias espirales (sacos aéreos)', 'Sistema respiratorio aviar de alta eficiencia.'),
             term('Córnea', 'Capa transparente del ojo; úlceras y glaucoma la afectan.'),
             term('Píloro', 'Salida del estómago al intestino; obstrucciones causan vómitos.'),
             term('Bazo', 'Órgano linfático y sangre; puede romperse en traumatismos (hemangiosarcoma).')
           ]),
  category('reproduccion', 'Reproducción y obstetricia',
           'Términos de gestación, parto y cría.', '🍼', [
             term('Gestación / preñez', 'Periodo de embarazo desde la concepción hasta el parto.'),
             term('Parto distócico', 'Parto difícil que requiere asistencia o cesárea.'),
             term('Inercia uterina', 'Útero sin contracciones efectivas durante el parto.'),
             term('Retención de placenta', 'Placenta no expulsada tras el parto; riesgo de infección uterina.'),
             term('Metritis', 'Infección del útero tras parto o celo.'),
             term('Piometra', 'Acumulación de pus en el útero; urgencia en hembras intactas.'),
             term('Celo / estro', 'Periodo fértil de la hembra.'),
             term('Lactancia', 'Producción y secreción de leche tras el parto.'),
             term('Agalactia', 'Ausencia o fallo de producción de leche.'),
             term('Egg binding', 'Retención de huevo en aves hembras; urgencia si obstruye.'),
             term('Oxitocina', 'Hormona que estimula contracciones uterinas y eyección de leche.'),
             term('Cesárea', 'Extracción quirúrgica de fetos por vía abdominal.'),
             term('Castración / esterilización', 'Extirpación de gónadas o ligadura para control reproductivo y salud.'),
             term('Destete', 'Separación de cría; reduce transmisión de parásitos y estrés materno.')
           ]),
  category('infecciosas', 'Enfermedades infecciosas y parasitarias',
           'Agentes y procesos infecciosos frecuentes en la enciclopedia.', '🦠', [
             term('Vacuna', 'Preparado que induce inmunidad sin causar enfermedad plena.'),
             term('Inmunidad', 'Defensa del organismo contra patógenos; puede ser natural o por vacuna.'),
             term('Zoonosis', 'Enfermedad transmisible del animal al humano (ej. psitacosis, rabia).'),
             term('Bacteria', 'Microorganismo unicelular; causa mastitis, abscesos, septicemia.'),
             term('Virus', 'Agente infeccioso intracelular; parvovirus, moquillo, herpesvirus.'),
             term('Hongo / micosis', 'Infección fúngica; dermatofitosis, aspergilosis.'),
             term('Parásito interno', 'Vive dentro del hospedador: lombrices, giardia, coccidios.'),
             term('Parásito externo', 'Pulgas, garrapatas, ácaros, piojos.'),
             term('Helmintos', 'Gusanos parásitos intestinales o tisulares.'),
             term('Protozoos', 'Parásitos microscópicos unicelulares; giardia, coccidiosis.'),
             term('Coccidiosis', 'Infección por coccidios; diarrea en aves, conejos y rumiantes jóvenes.'),
             term('Giardiasis', 'Diarrea por Giardia; zoonótica potencial.'),
             term('Leptospirosis', 'Bacteria transmitida por orina de roedores; afecta riñón e hígado.'),
             term('Rabia', 'Enfermedad viral mortal zoonótica; vacunación obligatoria en muchas zonas.'),
             term('Parvovirus canino', 'Virus intestinal grave en perros; vómitos y diarrea hemorrágica.'),
             term('Moquillo (distemper)', 'Virus sistémico canino con signos respiratorios, neurológicos y cutáneos.'),
             term('Psitacosis (clamidiosis)', 'Infección bacteriana de aves; zoonótica.'),
             term('Aspergilosis', 'Infección fúngica respiratoria en aves.'),
             term('Endoparasitosis', 'Infestación por parásitos internos.'),
             term('Ectoparasitosis', 'Infestación por parásitos externos.'),
             term('Bioseguridad sanitaria', 'Conjunto de barreras contra patógenos en granja o hogar.')
           ]),
  category('acuicultura', 'Salud en peces y acuicultura',
           'Términos de piscicultura presentes en la enciclopedia.', '🐟', [
             term('Calidad del agua', 'Parámetros críticos: oxígeno disuelto, amoniaco, nitritos, pH y temperatura.'),
             term('Oxígeno disuelto', 'Debe mantenerse en rango óptimo; la baja causa asfixia.'),
             term('Amoniaco / nitritos', 'Productos nitrogenados tóxicos; intoxicación por mala filtración o sobrepoblación.'),
             term('Ich (punto blanco)', 'Parásito Ichthyophthirius con manchas blancas y rascado.'),
             term('Columnaris', 'Bacteriosis con lesiones blanquecinas y ulceras en piel y aletas.'),
             term('Dropsy / hidropesia', 'Ascitis en peces; abdomen distendido y escamas erectas.'),
             term('Podredumbre de aletas', 'Infección bacteriana que destruye tejido de aletas.'),
             term('Velvet (Oodinium)', 'Enfermedad por dinoflagelado con polvo dorado en piel.'),
             term('Costia (Ichthyobodo)', 'Parásito que causa mucosa espesa y letargo.'),
             term('Enfermedad del herpesvirus koi (KHV)', 'Virus grave en carpas; mortalidad alta y fiebre.'),
             term('Cuarentena en pecera', 'Aislamiento de peces nuevos 2-4 semanas antes de mezclar.'),
             term('Densidad de siembra', 'Número de peces por volumen; el exceso empeora calidad de agua.'),
             term('Aireación', 'Suministro de oxígeno en estanques o acuarios intensivos.')
           ]),
  category('aves', 'Salud aviar',
           'Términos específicos de aves de corral y ornato.', '🐔', [
             term('Newcastle (viruela aviar)', 'Enfermedad viral altamente contagiosa; vacunación en producción.'),
             term('Bronquitis infecciosa', 'Virus respiratorio en pollos; tos y baja postura.'),
             term('Enfermedad de Marek', 'Herpesvirus que causa tumores y parálisis en pollos.'),
             term('Coccidiosis aviar', 'Parásito intestinal; diarrea sanguinolenta en crías.'),
             term('Picaje', 'Arrancado de plumas por estrés, densidad o parásitos.'),
             term('Enfermedad del pico y plumas (PBFD)', 'Virus en psitácidas; plumas y pico deformes.'),
             term('Proventriculitis (PDD)', 'Dilatación neurológica/digestiva en psitácidas.'),
             term('Postura / ponedora', 'Ave o fase productiva orientada a huevos.'),
             term('Muda', 'Renovación de plumas; periodo de estrés metabólico.'),
             term('Traslado de yema (sacro)', 'Huevo con mancha de yema en cáscara; indica estrés o infección.'),
             term('Bioseguridad aviar', 'Control estricto de acceso, desinfección y lotes en avicultura.')
           ]),
  category('rumiantes', 'Salud en rumiantes',
           'Términos bovinos, ovinos y caprinos.', '🐄', [
             term('Mastitis', 'Inflamación de la ubre; leche alterada y baja producción.'),
             term('Mastitis gangrenosa', 'Forma grave con tejido necrótico y shock; urgencia.'),
             term('Timpanismo / meteorismo', 'Acumulación excesiva de gas en rumen.'),
             term('Cólico', 'Dolor abdominal en equinos; también se usa para urgencias digestivas.'),
             term('Acidosis ruminal', 'Exceso de carbohidratos fermentables; rumen ácido y animal decaído.'),
             term('Cetosis', 'Acumulación de cuerpos cetónicos en vacas lecheras de alta producción.'),
             term('Hipocalcemia (fiebre de leche)', 'Caída de calcio al inicio de lactancia; urgencia en vacas.'),
             term('Retención de placenta', 'Placenta retenida >12-24 h postparto.'),
             term('BRD (enfermedad respiratoria bovina)', 'Complejo infeccioso respiratorio en feedlot.'),
             term('Clostridiosis', 'Infección por Clostridium; enterotoxemia y muerte rápida.'),
             term('Pododermatitis / footrot', 'Infección de pezuña en ovinos; cojera y separación de uñas.'),
             term('Miasis (bichera)', 'Infestación por larvas de moscas en heridas o heces.'),
             term('CAEV (artritis-encefalitis caprina)', 'Virus caprino que afecta articulaciones y sistema nervioso.'),
             term('FAMACHA', 'Método visual de anemia por parásitos en ovinos (color de mucosa).'),
             term('Laminitis', 'Inflamación de la corona del casco en equinos; muy dolorosa.')
           ])
].freeze

def disease_definition(name, entry)
  if entry
    parts = []
    parts << entry[:sintomas]&.first
    parts << entry[:diagnostico]&.slice(0, 200)
    snippet = parts.compact.join('. ')
    return snippet unless snippet.empty?
  end

  case name
  when /displasia/i then 'Malformación del desarrollo articular que produce cojera y artrosis.'
  when /cardiomiopat/i then 'Enfermedad del músculo cardíaco que afecta la contractilidad.'
  when /renal|riñón/i then 'Proceso que afecta la función renal y la eliminación de toxinas.'
  when /otitis/i then 'Inflamación del oído externo o medio.'
  when /dermatitis|piodermia|alergia cutánea/i then 'Inflamación o infección de la piel.'
  when /parásito|ácaro|piojo/i then 'Condición causada por parásitos externos o internos.'
  when /virus|viral|herpes|parvo|moquillo/i then 'Enfermedad causada por virus.'
  when /tumor|neoplasia|cáncer|sarcoma|linfoma/i then 'Crecimiento celular anormal; benigno o maligno.'
  when /obesidad/i then 'Exceso de grasa corporal con riesgo metabólico y ortopédico.'
  when /diabetes/i then 'Alteración del metabolismo de la glucosa.'
  when /fractura|trauma|luxación|hernia/i then 'Lesión mecánica de huesos, tejidos o articulaciones.'
  else
    "Enfermedad o condición documentada en la enciclopedia para esta especie. Consulta la ficha clínica completa para síntomas, diagnóstico y tratamiento."
  end
end

def collect_diseases(data)
  names = []
  data['animales'].each do |animal|
    animal['razas'].values.flatten.each do |raza|
      (raza['enfermedades'] || []).each { |d| names << d['nombre'] }
    end
  end
  names.uniq.sort
end

def collect_drugs
  drugs = {}
  PharmaProtocols::DRUGS.each_value do |species|
    species.each_value do |drug|
      pa = drug[:principio_activo]
      next if pa.nil? || pa.empty?
      drugs[pa] ||= {
        definicion: "Principio activo usado en protocolos de la enciclopedia. #{drug[:notas]}",
        ejemplo: "#{drug[:dosis_mg_kg]} vía #{drug[:via]} — #{drug[:nombre_comercial]}"
      }
    end
  end
  drugs.sort_by { |k, _| k }
end

def build
  data = JSON.parse(File.read(File.join(ROOT, 'data', 'enciclopedia.json')))
  categories = BASE_CATEGORIES.map(&:dup)

  # Enfermedades documentadas
  disease_terms = collect_diseases(data).map do |name|
    entry = ClinicalDiseaseLibrary::ENTRIES[name]
    term(name, disease_definition(name, entry))
  end
  categories << category(
    'enfermedades',
    'Enfermedades documentadas en la enciclopedia',
    "Las #{disease_terms.length} condiciones clínicas registradas en las fichas de razas.",
    '📋',
    disease_terms
  )

  # Fármacos de protocolos
  drug_terms = collect_drugs.map do |pa, info|
    term(pa, info[:definicion], info[:ejemplo])
  end
  categories << category(
    'farmacos_protocolo',
    'Fármacos de los protocolos clínicos',
    'Principios activos con dosis orientativas presentes en las tablas farmacológicas.',
    '💉',
    drug_terms
  )

  total = categories.sum { |c| c['terminos'].length }

  {
    'titulo' => 'Diccionario de términos médicos',
    'introduccion' => "Glosario veterinario con #{total} entradas extraídas y explicadas a partir de las fichas de razas, enfermedades, nutrición y protocolos de esta enciclopedia. Uso educativo; no sustituye la consulta con un veterinario colegiado.",
    'categorias' => categories,
    'total_terminos' => total
  }
end

output = build
path = File.join(ROOT, 'data', 'diccionario_medicos.json')
File.write(path, JSON.pretty_generate(output) + "\n")
puts "diccionario_medicos.json generado (#{output['total_terminos']} términos, #{output['categorias'].length} categorías)"
