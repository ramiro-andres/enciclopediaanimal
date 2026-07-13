# frozen_string_literal: true

# Sprint 13 — US-CON-06: +100 términos al diccionario médico (527 → 627).
# Se integra en build_medical_dictionary.rb vía EXTRA_TERMS_SPRINT13.

def sprint13_term(termino, definicion, ejemplo = nil)
  { 'termino' => termino, 'definicion' => definicion, 'ejemplo' => ejemplo }.compact
end

EXTRA_TERMS_SPRINT13 = {
  'ficha_enfermedad' => [
    sprint13_term('Estadiaje clínico', 'Clasificación de extensión y gravedad de una enfermedad para orientar pronóstico y tratamiento.'),
    sprint13_term('Escala de dolor (ESAS)', 'Herramienta visual para estimar intensidad del dolor en animales según conducta y postura.'),
    sprint13_term('Plan terapéutico multimodal', 'Combinación de fármacos, nutrición, fisioterapia y manejo ambiental en un mismo caso.'),
    sprint13_term('Seguimiento postoperatorio', 'Controles tras cirugía: herida, dolor, apetito, eliminaciones y signos de infección.'),
    sprint13_term('Consentimiento informado', 'Documento donde el propietario acepta procedimientos, riesgos y alternativas tras explicación veterinaria.'),
    sprint13_term('Historia clínica electrónica', 'Registro digital de consultas, tratamientos y resultados de laboratorio del paciente.'),
    sprint13_term('Pronóstico reservado', 'Expectativa incierta; evolución depende de respuesta al tratamiento y comorbilidades.'),
    sprint13_term('Alta hospitalaria', 'Momento en que el paciente puede continuar recuperación en casa con instrucciones escritas.')
  ],
  'ficha_raza' => [
    sprint13_term('Certificado de salud de exportación', 'Documento oficial que acredita estado sanitario para movilización internacional de animales.'),
    sprint13_term('Cuarentena de ingreso', 'Aislamiento temporal de animales nuevos para detectar enfermedades antes de integrarlos al rebaño.'),
    sprint13_term('Programa de bienestar animal', 'Conjunto de prácticas que minimizan estrés, dolor y sufrimiento en explotaciones.'),
    sprint13_term('Trazabilidad individual', 'Identificación única que permite seguir historial sanitario y productivo de cada animal.'),
    sprint13_term('Protocolo de desinfección de instalaciones', 'Limpieza y desinfección programada de corrales, jaulas o establos.'),
    sprint13_term('Manejo en manga o brete', 'Restricción física segura para examen, vacunación o tratamiento sin sedación.'),
    sprint13_term('Registro genealógico', 'Documentación de linaje y pureza racial en razas con asociación oficial.')
  ],
  'nutricion' => [
    sprint13_term('Energía metabolizable (EM)', 'Energía disponible tras digestión y absorción; base para formular raciones.'),
    sprint13_term('Proteína bruta digestible', 'Fracción de proteína que el animal puede utilizar metabólicamente.'),
    sprint13_term('Relación calcio:fósforo', 'Balance mineral crítico en huesos, huevos y producción láctea; desequilibrio causa osteodistrofias.'),
    sprint13_term('Fibra detergente neutra (FDN)', 'Fracción fibrosa del forraje que limita el consumo en rumiantes.'),
    sprint13_term('Materia seca (MS)', 'Porción del alimento sin agua; permite comparar raciones con distinta humedad.'),
    sprint13_term('Aditivo probiótico', 'Microorganismos vivos que modulan la microbiota intestinal y mejoran digestión.'),
    sprint13_term('Prebiótico', 'Sustrato no digerible que favorece el crecimiento de bacterias beneficiosas en el intestino.')
  ],
  'produccion' => [
    sprint13_term('Densidad de carga animal', 'Número de animales por hectárea o unidad de instalación; afecta sanidad y rendimiento.'),
    sprint13_term('Índice de conversión alimenticia (ICA)', 'Kg de alimento por kg de producto obtenido; indicador de eficiencia productiva.'),
    sprint13_term('Mortalidad pre-destete', 'Porcentaje de crías que mueren antes del destete; alerta de manejo o sanidad.'),
    sprint13_term('Intervalo entre partos (IEP)', 'Días entre dos partos consecutivos en hembras productivas.'),
    sprint13_term('Tasa de preñez', 'Porcentaje de hembras gestantes tras servicio o inseminación en un periodo.'),
    sprint13_term('Plan sanitario de granja', 'Calendario anual de vacunas, desparasitación y controles según especie y sistema.'),
    sprint13_term('Registro de tratamientos (withdrawal)', 'Anotación de fármacos y periodos de retiro antes de sacrificio o ordeño.')
  ],
  'farmacia' => [
    sprint13_term('Vía subcutánea (SC)', 'Inyección bajo la piel; absorción moderada; común en vacunas y fluidos.'),
    sprint13_term('Vía intramuscular (IM)', 'Inyección en músculo; absorción rápida; evitar nervios y vasos.'),
    sprint13_term('Vía intravenosa (IV)', 'Inyección directa en vena; acción inmediata; requiere técnica aséptica.'),
    sprint13_term('Vía oral (PO)', 'Administración por boca: comprimidos, jarabes o mezcla en alimento.'),
    sprint13_term('Vía tópica', 'Aplicación sobre piel, oído u ojo: ungüentos, gotas o sprays.'),
    sprint13_term('Antimicrobiano de amplio espectro', 'Activo contra muchas bacterias; uso prudente para reducir resistencia.'),
    sprint13_term('Antiinflamatorio no esteroideo (AINE)', 'Reduce dolor e inflamación; vigilar función renal y gastrointestinal.'),
    sprint13_term('Periodo de retiro (withdrawal)', 'Tiempo mínimo entre última dosis y consumo de carne, leche o huevos.')
  ],
  'examenes' => [
    sprint13_term('Citología de impresión', 'Extendido de células de lesión sobre portaobjetos para diagnóstico rápido.'),
    sprint13_term('Urocultivo', 'Cultivo de orina para identificar bacteria y antibiograma en infecciones urinarias.'),
    sprint13_term('Coprocultivo', 'Cultivo de heces para detectar enteropatógenos bacterianos.'),
    sprint13_term('Electrocardiograma (ECG)', 'Registro de actividad eléctrica cardíaca; arritmias y cardiopatías.'),
    sprint13_term('Ecocardiografía', 'Ultrasonido del corazón para evaluar contractilidad y válvulas.'),
    sprint13_term('Radiografía digital (DR)', 'Imagen radiográfica en formato digital con menor exposición y mejor contraste.'),
    sprint13_term('Tomografía computarizada (TC)', 'Imagen en cortes tridimensionales; útil en trauma y tumores complejos.'),
    sprint13_term('Resonancia magnética (RM)', 'Imagen de tejidos blandos: cerebro, médula y articulaciones.')
  ],
  'sintomas' => [
    sprint13_term('Ortopnea', 'Postura con cuello extendido para facilitar respiración; común en distress respiratorio.'),
    sprint13_term('Abducción de codos', 'Separación de codos al respirar; signo de esfuerzo respiratorio.'),
    sprint13_term('Petequias', 'Manchas rojas puntiformes por hemorragia capilar en mucosas o piel.'),
    sprint13_term('Equimosis', 'Moretón visible por acumulación de sangre bajo la piel.'),
    sprint13_term('Nictalopía / ceguera nocturna', 'Dificultad para ver con poca luz; déficit de vitamina A en aves.'),
    sprint13_term('Bruxismo', 'Rechinar de dientes o mandíbula; dolor abdominal o estrés en equinos y roedores.'),
    sprint13_term('Fasciculaciones musculares', 'Contracciones finas visibles bajo la piel; electrolitos o neuromuscular.'),
    sprint13_term('Estridor inspiratorio', 'Ruido agudo al inhalar; obstrucción de vías aéreas superiores.')
  ],
  'anatomia' => [
    sprint13_term('Peritoneo', 'Membrana que recubre cavidad abdominal y órganos internos.'),
    sprint13_term('Mesenterio', 'Pliegue peritoneal que sostiene intestino y aporta vasos sanguíneos.'),
    sprint13_term('Diafragma', 'Músculo que separa tórax y abdomen; esencial en respiración.'),
    sprint13_term('Glándula tiroides', 'Regula metabolismo mediante hormonas T3 y T4.'),
    sprint13_term('Glándula paratiroides', 'Controla calcio sérico mediante parathormona.'),
    sprint13_term('Suprarrenal', 'Produce cortisol y adrenalina; estrés y equilibrio electrolítico.'),
    sprint13_term('Médula ósea', 'Tejido interior del hueso; produce células sanguíneas.')
  ],
  'reproduccion' => [
    sprint13_term('Celo silencioso', 'Ovulación sin signos externos evidentes; dificulta la monta en algunas especies.'),
    sprint13_term('Servicio natural', 'Monta con macho entero para fecundación.'),
    sprint13_term('Inseminación artificial (IA)', 'Depósito de semen en tracto reproductivo sin monta.'),
    sprint13_term('Transferencia de embriones (TE)', 'Implante de embriones de alta genética en receptoras.'),
    sprint13_term('Prostaglandina F2α', 'Hormona para sincronizar celo o tratar piometra en hembras.'),
    sprint13_term('Retención de lóquios', 'Restos placentarios o secreciones postparto retenidos en útero.'),
    sprint13_term('Metritis puerperal', 'Infección uterina tras el parto con fiebre y secreción fetida.')
  ],
  'infecciosas' => [
    sprint13_term('Zoonosis emergente', 'Enfermedad transmitible animal-humano de aparición reciente o expansión nueva.'),
    sprint13_term('Reservorio silvestre', 'Especie salvaje que mantiene un patógeno sin enfermar gravemente.'),
    sprint13_term('Portador asintomático', 'Animal infectado que elimina el agente sin signos clínicos evidentes.'),
    sprint13_term('Biosseguridad nivel 2', 'Medidas de contención para patógenos moderados con vacunas o tratamiento disponible.'),
    sprint13_term('Cadena de frío vacunal', 'Mantenimiento de vacunas entre 2-8 °C hasta su administración.'),
    sprint13_term('Seroconversión', 'Aparición de anticuerpos en sangre tras infección o vacunación.'),
    sprint13_term('Título de anticuerpos', 'Concentración de anticuerpos medida en laboratorio; indica inmunidad o exposición.'),
    sprint13_term('Enfermedad de notificación obligatoria', 'Condición que debe reportarse a autoridades sanitarias por riesgo epidemiológico.')
  ],
  'acuicultura' => [
    sprint13_term('Oxígeno disuelto (OD)', 'Concentración de O₂ en agua; crítico para supervivencia de peces.'),
    sprint13_term('Amonio no ionizado (NH₃)', 'Forma tóxica del nitrógeno en agua; sube con pH alto y temperatura.'),
    sprint13_term('Nitrito (NO₂)', 'Compuesto nitrogenado tóxico que dificulta transporte de oxígeno en sangre.'),
    sprint13_term('Densidad de siembra', 'Número de alevinos o juveniles por m³ de agua en cultivo.'),
    sprint13_term('Biomasa por unidad de volumen', 'Peso total de peces por m³; guía manejo y alimentación.'),
    sprint13_term('Muda (ecdisis)', 'Renovación del exoesqueleto en crustáceos; periodo de vulnerabilidad.'),
    sprint13_term('Laricultura', 'Fase de cría de larvas en hatchery antes del engorde.')
  ],
  'aves' => [
    sprint13_term('Gallinas de reemplazo', 'Aves jóvenes destinadas a convertirse en ponedoras comerciales.'),
    sprint13_term('Muda forzada', 'Interrupción controlada de la puesta para renovar plumaje y tracto reproductivo.'),
    sprint13_term('Espray vacunal', 'Aplicación de vacuna en aerosol para inmunización masiva de aves.'),
    sprint13_term('Pododermatitis (úlcera de planta)', 'Lesión inflamatoria en almohadilla plantar por humedad o perchas inadecuadas.'),
    sprint13_term('Coccidiosis aviar', 'Infección por Eimeria spp. que daña intestino y reduce conversión.'),
    sprint13_term('Esclerosis de la cáscara', 'Endurecimiento anormal del huevo por estrés o infección.'),
    sprint13_term('Pico corto (despicado)', 'Recorte parcial del pico para reducir canibalismo en gallineros.')
  ],
  'rumiantes' => [
    sprint13_term('Alimentación restrictiva preparto', 'Control de energía antes del parto para prevenir cetosis y hipocalcemia.'),
    sprint13_term('Ordeño mecánico', 'Extracción de leche con máquina; requiere higiene y calibración.'),
    sprint13_term('CMT (California Mastitis Test)', 'Prueba rápida en leche para detectar mastitis subclínica.'),
    sprint13_term('Secado de vaca', 'Periodo sin ordeño antes del parto para regenerar ubre y prevenir mastitis.'),
    sprint13_term('Destete precoz', 'Separación temprana de cría para manejo intensivo o venta.'),
    sprint13_term('Suplementación con urea', 'Fuente de nitrógeno no proteico en rumiantes; requiere adaptación gradual.'),
    sprint13_term('Bloque mineral proteico', 'Suplemento lick para pastoreo extensivo con proteína y minerales.')
  ],
  'clinica_especializada' => [
    sprint13_term('Anestesia balanceada', 'Combinación de inductor, analgesia y mantenimiento para cirugía segura.'),
    sprint13_term('Fluidoterapia de mantenimiento', 'Líquidos IV para cubrir pérdidas basales y evitar deshidratación.'),
    sprint13_term('Transfusión sanguínea', 'Administración de sangre o componentes para anemia o coagulopatía.'),
    sprint13_term('Oxigenoterapia', 'Suministro de O₂ en cánula, mascarilla o cámara para hipoxemia.'),
    sprint13_term('Ventilación mecánica', 'Soporte respiratorio asistido en pacientes críticos bajo anestesia o UCI.'),
    sprint13_term('Drenaje de tórax', 'Tubo para evacuar aire o líquido del espacio pleural.'),
    sprint13_term('Lavado peritoneal', 'Irrigación de cavidad abdominal en sepsis o pancreatitis.'),
    sprint13_term('Endoscopia digestiva', 'Visualización de esófago, estómago o intestino con endoscopio flexible.'),
    sprint13_term('Artroscopia', 'Cirugía mínimamente invasiva de articulaciones con cámara.'),
    sprint13_term('Quimioterapia veterinaria', 'Fármacos citotóxicos para neoplasias; protocolos adaptados por especie.'),
    sprint13_term('Fisioterapia animal', 'Ejercicios, masaje y electroterapia para rehabilitación musculoesquelética.'),
    sprint13_term('Medicina del comportamiento', 'Diagnóstico y tratamiento de trastornos conductuales y bienestar mental.')
  ]
}.freeze

# Verificación al ejecutar directamente
if $PROGRAM_NAME == __FILE__
  total = EXTRA_TERMS_SPRINT13.values.flatten.length
  puts "expand_dictionary_sprint13: #{total} términos en #{EXTRA_TERMS_SPRINT13.keys.length} categorías"
  abort "Se requieren exactamente 100 términos nuevos" unless total == 100
end
