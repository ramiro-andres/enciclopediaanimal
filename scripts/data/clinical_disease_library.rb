# frozen_string_literal: true

# Biblioteca clínica veterinaria — contenido específico por enfermedad
# Basado en guías BSAVA, AAFP, WSAVA, ACVIM y manuales de medicina interna veterinaria

module ClinicalDiseaseLibrary
  GENERIC_FILLER = [
    'El veterinario realizará anamnesis detallada',
    'Se complementará con pruebas específicas según la sospecha clínica',
    'El diagnóstico precoz mejora significativamente el pronóstico',
    'El plan terapéutico se ajustará según la gravedad',
    'Es fundamental completar los tratamientos prescritos',
    'No automedicar: muchos fármacos humanos',
    'Mantener revisiones veterinarias periódicas para detectar factores de riesgo',
    'Registrar cambios en apetito, conducta o eliminaciones',
    'Seguir las recomendaciones de alimentación, ejercicio y manejo específicas',
    'Signo clínico principal de',
    'Plan terapéutico individualizado para',
    'Evaluación clínica completa para',
    'Medidas preventivas específicas para reducir el riesgo'
  ].freeze

  # Entradas por nombre exacto o patrón regex
  ENTRIES = {
    # ── PERROS ──
    'Displasia de cadera' => {
      sintomas: ['Cojera de miembro posterior (intermitente o constante)', 'Dificultad para levantarse tras reposo ("rigidez de arranque")', 'Marcha en conejo (ambas patas traseras avanzan juntas)', 'Reluctancia a subir escaleras, saltar o correr', 'Pérdida de masa muscular en muslo/glúteo', 'Chasquido o "click" coxofemoral al caminar', 'Dolor a la extensión/abducción de cadera', 'Postura asimétrica de la pelvis'],
      diagnostico: 'Exploración ortopédica: maniobra de Ortolani (laxitud palpable en cachorros), rango de movimiento, dolor a la palpación de la articulación coxofemoral. Radiografías en proyección ventrodorsal extendida y lateral: evaluación de laxitud, remodelación acetabular, subluxación y osteoartrosis secundaria. Clasificación OFA (Excelente/Buena/Regular/Débil/Mala) o PennHIP (distraction index). En casos seleccionados: artroscopia diagnóstica o TC.',
      tratamiento: 'Grado I-II (leve-moderado): manejo conservador con control estricto de peso (BCS 4-5/9), ejercicio controlado (natación, paseos en superficies no resbaladizas), fisioterapia, AINE (meloxicam 0,1 mg/kg/día) y condroprotectores (glucosamina/condroitina/ácido hialurónico). Grado III-IV: cirugía — juvenil pubic symphysiodesis (<20 semanas), triple osteotomía pélvica (TPO, 5-12 meses), osteotomía de cabeza femoral (FHO) o prótesis total de cadera (THR). Analgesia multimodal pre y postoperatoria.',
      prevencion: 'Selección genética: solo criar con padres certificados OFA/PennHIP. Evitar crecimiento rápido: pienso para cachorro grande (calcio 1-1,2%, proteína moderada). No forzar ejercicio de alto impacto antes de fisiológicamente maduro (12-18 meses en razas grandes). Mantener peso ideal toda la vida. Suplementar omega-3 (EPA/DHA).',
      diagnostico_diferencial: ['Luxación de rótula', 'Enfermedad de Legg-Calvé-Perthes', 'Ruptura de ligamento cruzado', 'Osteomielitis', 'Neoplasia ósea', 'Miositis', 'Subluxación de sacroilíaca'],
      criterios_diagnostico: 'Ortolani positivo + radiografía con subluxación/osteófitos. PennHIP DI >0,3 indica riesgo elevado. Cojera persistente >2 semanas en cachorro de raza predispuesta.',
      clasificacion: 'OFA: Excelente/Buena/Regular/Débil/Mala. PennHIP: Distraction Index (DI) 0,0-1,0. Artroscópica: grado de daño cartilaginoso.',
      contraindicaciones: ['AINE en animales deshidratados o con IR/insuficiencia renal', 'Ejercicio forzado en cachorros con cojera activa', 'Corticoides crónicos (aceleran degradación cartilaginosa)'],
      referencias: ['Orthopedic Foundation for Animals (OFA) — ofa.org', 'BSAVA Manual of Canine and Feline Musculoskeletal Disorders, 3rd ed.', 'International Elbow and Hip Dysplasia Working Group'],
      notas_clinicas: 'La displasia es poligénica con penetrancia variable. El 60-70% de perros con cambios radiográficos no muestran cojera clínica. El control del peso es el factor modificable más importante.'
    },
    'Hipoglucemia' => {
      sintomas: ['Temblores musculares finos (especialmente cabeza y miembros)', 'Ataxia, tambaleo, desorientación', 'Letargo progresivo o somnolencia', 'Vocalización ansiosa o agresión repentina', 'Convulsiones focales o generalizadas', 'Pérdida de consciencia, coma', 'Encías pálidas, hipotermia', 'Bradicardia en crisis severa'],
      diagnostico: 'Glucemia capilar o venosa: <60 mg/dL (3,3 mmol/L) confirma hipoglucemia; <40 mg/dL es urgencia. Hemograma, bioquímica (ALT, ALP, creatinina, electrolitos), insulina sérica y péptido C si hay recurrencia (descartar insulinoma). Ecografía abdominal para masa pancreática. Curva glucémica si sospecha de insulinoma.',
      tratamiento: 'URGENTE: glucosa oral (miel, jarabe de maíz, gel glucosa) en encías/bucal si consciente; si convulsiona o inconsciente → dextrosa 5% IV 2-5 ml/kg bolo lento, luego infusión 5% continua. Monitorizar glucosa cada 30-60 min. Alimentar pequeñas comidas frecuentes al estabilizar. Si insulinoma: diazóxido 5-30 mg/kg/día VO + dieta baja en carbohidratos simples. Glucagón IM/IV en refractarios.',
      prevencion: 'Alimentación fraccionada cada 4-6 h en cachorros toy (<4 meses). Evitar ayunos >6 h. Dieta con proteína y grasa de calidad, evitar picos glucémicos. En insulinoma: dieta baja en carbohidratos, comidas frecuentes, control glucémico domiciliario.',
      diagnostico_diferencial: ['Intoxicación por xilitol', 'Sepsis', 'Hepatopatía grave', 'Insulinoma', 'Hipoadrenocorticismo', 'Sobredosis de insulina', 'Encefalopatía hepática', 'Intoxicación por organofosforados'],
      criterios_diagnostico: 'Glucemia <60 mg/dL + signos neurológicos compatibles. Mejora clínica en <15 min tras administración de glucosa confirma diagnóstico.',
      clasificacion: 'Leve: 50-60 mg/dL, signos leves. Moderada: 40-50 mg/dL, ataxia. Grave: <40 mg/dL, convulsiones/coma.',
      contraindicaciones: ['NO administrar AINE, corticoides ni antibióticos como tratamiento de primera línea', 'Dextrosa IV demasiado rápida (riesgo de hiperglucemia rebote)', 'Ayuno prolongado en cachorros toy'],
      referencias: ['BSAVA Manual of Canine and Feline Endocrinology, 4th ed.', 'ACVIM consensus on insulinoma in dogs', 'Plumb\'s Veterinary Drug Handbook'],
      notas_clinicas: 'En perros toy, la masa hepática y reservas de glucógeno son limitadas. La hipoglucemia puede simular epilepsia idiopática — siempre medir glucosa en toda convulsión de raza toy.'
    },
    'Torsión gástrica' => {
      sintomas: ['Distensión abdominal progresiva (epigastrio)', 'Intentos de vómito sin producción (arcadas improductivas)', 'Salivación profusa (sialorrea)', 'Inquietud, caminar sin rumbo, no poderse acomodar', 'Respiración rápida y superficial (taquipnea)', 'Encías pálidas → cianosis (shock)', 'Pulso débil y filiforme', 'Colapso cardiovascular'],
      diagnostico: 'Sospecha clínica en raza de pecho profundo con distensión + arcadas. Radiografía lateral: "signo del doble burbuja" (gas en estómago dilatado + esófago), desplazamiento esplénico. Gas en venas porta indica isquemia. Analítica: lactato >6 mmol/L indica necrosis gástrica y peor pronóstico. ECG por riesgo de arritmias ventriculares postoperatorias.',
      tratamiento: 'EMERGENCIA QUIRÚRGICA: descompresión gástrica inmediata (sonda orogástrica o troacar paracostal), fluidoterapia agresiva IV (cristaloides + coloides, 90 ml/kg/h inicial), analgesia (opioides), estabilización y cirugía de urgencia (gastrotomía, reposicionamiento, gastropexia incisional o laparoscópica). Antibióticos IV de amplio espectro. Monitorización cardíaca 48-72 h postoperatoria (VPC).',
      prevencion: 'Gastropexia profiláctica en razas de riesgo (Gran Danés, Pastor Alemán, etc.) durante esterilización. Alimentar 2-3 veces al día (no una comida voluminosa). Comederos elevados NO recomendados (aumentan riesgo). Evitar ejercicio 1-2 h antes y después de comer. Comedero anti-glotón. Reducir estrés en comidas.',
      diagnostico_diferencial: ['Dilatación gástrica sin torsión', 'Obstrucción intestinal', 'Peritonitis', 'Ruptura esplénica', 'Intoxicación', 'Cólico (equinos)'],
      criterios_diagnostico: 'Distensión gástrica radiográfica + signo del doble burbuja + shock = torsión confirmada. Cirugía exploratoria es diagnóstica y terapéutica.',
      clasificacion: 'Dilatación (fase I) → Torsión volvulus 180-270° (fase II) → Necrosis gástrica/esplénica (fase III) → Shock irreversible (fase IV).',
      contraindicaciones: ['NO intentar inducir vómito en casa', 'NO retrasar cirugía por "estabilización prolongada"', 'Evitar AINE como única analgesia en shock'],
      referencias: ['ACVS Position Statement on GDV', 'BSAVA Manual of Canine and Feline Emergency and Critical Care', 'Tufts Cummings GDV Study'],
      notas_clinicas: 'Mortalidad sin cirugía: ~100%. Con cirugía oportuna: 10-28%. Recurrencia sin gastropexia: 80%. Con gastropexia: <5%.'
    },
    'Cardiomiopatía dilatada' => {
      sintomas: ['Intolerancia al ejercicio progresiva', 'Tos (especialmente nocturna, posicional)', 'Jadeo en reposo o con mínimo esfuerzo', 'Abdomen distendido (ascitis por ICC derecha)', 'Síncope o colapso tras excitación', 'Pérdida de apetito y pérdida de peso muscular', 'Frecuencia respiratoria elevada en reposo (>35 rpm)', 'Pulso débil, filiforme o arritmias palpables'],
      diagnostico: 'Auscultación: soplo sistólico (insuficiencia mitral funcional), galope triple (S3), arritmia. Radiografía torácica: cardiomegalia (VHS >10,5 en perros), redistribución vascular, edema pulmonar, derrame pleural. Ecocardiografía: diámetro diastólico VI aumentado, fracción de acortamiento <25%, contractilidad reducida. NT-proBNP elevado. ECG: VPC, FA, taquicardia sinusal.',
      tratamiento: 'Fase preclínica (estadio B1-B2 ACVIM): pimobendan 0,25 mg/kg c/12h + enalapril 0,5 mg/kg c/12h. Fase con ICC (estadio C): añadir furosemida 2-4 mg/kg c/8-12h, espironolactona 2 mg/kg c/12h, dieta baja en sodio. Arritmias: sotalol o mexiletina para VPC. Antiarrítmicos según ECG. Control cada 2-4 semanas al inicio.',
      prevencion: 'Cribado genético en razas predispuestas (Doberman, Boxer, Gran Danés). Ecocardiografía anual a partir de los 3-4 años en razas de riesgo. Evitar taurina-deficient diets. Suplementar taurina/L-carnitina en razas susceptibles (Cocker, Golden).',
      diagnostico_diferencial: ['Miocarditis', 'Pericarditis constrictiva', 'Enfermedad valvular degenerativa', 'Cardiomiopatía arritmogénica (Boxer)', 'Ehrlichiosis', 'Intoxicación por doxorrubicina'],
      criterios_diagnostico: 'Ecocardiografía: VI dilatado + FEVI <40% + signos clínicos de ICC = CMD dilatada. Estadiamiento ACVIM obligatorio.',
      clasificacion: 'ACVIM Estadiamiento: A (predisposición) → B1 (ecocambios sin signos) → B2 (ecocambios + cardiomegalia radiográfica) → C (ICC congestiva) → D (ICC refractaria).',
      contraindicaciones: ['Furosemida sin monitorización renal/electrolítica', 'IECA en deshidratación', 'Digoxina sin monitorización (estrecho margen terapéutico)', 'Ejercicio intenso en estadio C'],
      referencias: ['ACVIM Consensus Guidelines for Canine DCM', 'BSAVA Manual of Canine and Feline Cardiorespiratory Medicine', 'Tufts Veterinary Cardiology'],
      notas_clinicas: 'En Doberman, el 58% desarrollará CMD. La detección preclínica con pimobendan retrasa la ICC en ~15 meses (EPIC trial).'
    },
    'Enfermedad renal crónica' => {
      sintomas: ['Poliuria y polidipsia (PUPD)', 'Pérdida de apetito progresiva (anorexia)', 'Pérdida de peso y masa muscular (caquexia)', 'Vómitos intermitentes', 'Halitosis urémica (olor a orina)', 'Úlceras orales y gingivitis', 'Letargo, debilidad', 'Palidez de mucosas (anemia de ERC)'],
      diagnostico: 'Creatinina sérica elevada persistente (>1,6 mg/dL gatos) + USG inadecuado (<1,035) en gatos. SDMA elevado (detección precoz). Analítica completa: BUN, fosforo, potasio, bicarbonato, hematocrito, PTH. UPC (proteinuria). Presión arterial. Ecografía renal: tamaño, ecogenicidad, corticomedular. Estadiamiento IRIS (1-4 según creatinina y proteinuria).',
      tratamiento: 'Estadio IRIS 1-2: dieta renal (proteína restringida, fosforo bajo, omega-3), hidratación (fuentes de agua múltiples, fuentes corrientes). Estadio 3-4: fluidoterapia SC 100-150 ml/kg/semana, antieméticos (maropitant, ondansetron), quelantes de fosforo (carbonato de lata), eritropoyetina si Hto <20%, IECA si proteinuria (benazepril 0,5-1 mg/kg). Control cada 3-6 meses.',
      prevencion: 'Hidratación adecuada (dieta húmeda preferible). Evitar nefrotóxicos (AINE crónicos, lilies en gatos). Control TA anual en seniors. Dieta de calidad, evitar sobrepeso. Cribado anual creatinina/SDMA en gatos >7 años.',
      diagnostico_diferencial: ['Enfermedad renal aguda', 'Diabetes mellitus (PUPD)', 'Hiperadrenocorticismo', 'Hipercalcemia', 'Pielonefritis', 'Obstrucción urinaria resuelta con daño residual', 'Amiloidosis renal'],
      criterios_diagnostico: 'Creatinina elevada persistente >2 semanas + USG inadecuado + hallazgos ecográficos = ERC. IRIS staging obligatorio para guiar tratamiento.',
      clasificacion: 'IRIS Estadiamiento: 1 (creatinina <1,6) → 2 (1,6-2,8) → 3 (2,9-5,0) → 4 (>5,0). Subestadios por proteinuria (UPC) y presión arterial.',
      contraindicaciones: ['AINE en ERC estadio 3-4 (nefrotóxicos)', 'Dieta hiperproteica en estadio avanzado', 'Furosemida crónica sin monitorización', 'Suplementos de fósforo'],
      referencias: ['IRIS Guidelines (iris-kidney.com)', 'AAFP Feline Senior Care Guidelines', 'ISFM Consensus on Diagnosis and Management of CKD in Cats'],
      notas_clinicas: 'La ERC es la causa principal de muerte en gatos mayores. SDMA detecta pérdida del 40% de función renal antes que creatinina. La proteinuria acelera progresión — tratar con IECA.'
    },
    'Cardiomiopatía hipertrófica' => {
      sintomas: ['Asintomático en fase preclínica (hallazgo ecocardiográfico)', 'Dificultad respiratoria (edema pulmonar, derrame pleural)', 'Parálisis súbita de patas traseras (tromboembolismo aórtico)', 'Intolerancia al ejercicio', 'Aleteo nasal, postura en "perro sentado" con codos abiertos', 'Síncope', 'Vómitos, anorexia (signos de bajo gasto)', 'Muerte súbita sin signos previos'],
      diagnostico: 'Ecocardiografía: engrosamiento del VI (>6 mm diástole, gatos), movimiento sistólico anterior de la válvula mitral (SAM), obstrucción del tracto de salida. Fracción de acortamiento puede ser normal o elevada. Radiografía: cardiomegalia, edema pulmonar. NT-proBNP >100 pmol/L. ECG: HVI, arritmias. Doppler: SAM + gradiente obstructivo.',
      tratamiento: 'Asintomático (estadio B): atenolol 6,25-12,5 mg/gato c/12h o diltiazem si SAM obstructivo. ICC (estadio C): furosemida 1-2 mg/kg c/8-12h, clopidogrel 18,75 mg/gato/día (prevención TEA), pimobendan 1,25 mg/kg c/12h. TEA agudo: analgesia (buprenorfina), anticoagulación, NUNCA trombolisis. Habitación de oxígeno.',
      prevencion: 'Cribado ecocardiográfico en razas predispuestas (Maine Coon, Ragdoll, Sphynx, British). No criar con HCM confirmada. Control ecocardiográfico anual en líneas familiares. Evitar estrés y estimulantes (metilxantinas).',
      diagnostico_diferencial: ['Hipertensión sistémica', 'Hipertiroidismo', 'Cardiomiopatía restrictiva', 'Cardiomiopatía dilatada felina', 'Pericarditis', 'Defecto septal ventricular', 'Feocromocitoma'],
      criterios_diagnostico: 'Engrosamiento parietal VI >6 mm en diástole (gatos adultos) sin otra causa sistémica = HCM. SAM confirma variante obstructiva (HOCM).',
      clasificacion: 'ACVIM Felina: HCM (engrosamiento concéntrico) → HOCM (con SAM) → HCM con ICC → HCM con TEA → HCM terminal.',
      contraindicaciones: ['Furosemida sin monitorización en TEA (deshidratación empeora viscosidad sanguínea)', 'AINE (nefrotóxicos + reducen efecto de diuréticos)', 'Fluidoterapia agresiva en ICC', 'Trombolisis en TEA felino (alto riesgo de muerte)'],
      referencias: ['ACVIM Consensus Statement on HCM in Cats', 'ISFM Guidelines on Feline Cardiomyopathies', 'Maine Coon HCM Screening Protocol (Dr. Kittleson)'],
      notas_clinicas: 'El 15-20% de gatos con HCM desarrollan TEA. Clopidogrel reduce recurrencia en 90%. La muerte súbita es la presentación en 10-15% de HCM felina.'
    },
    'Obstrucción urinaria' => {
      sintomas: ['Estridores repetidos en arenero sin producción de orina', 'Vocalización de dolor al intentar orinar', 'Lamer genitales excesivamente', 'Abdomen tenso, vejiga palpable como "pelota de tenis"', 'Vómitos, anorexia', 'Letargo progresivo', 'Bradicardia e hipotermia (hiperpotasemia)', 'Convulsiones o paro cardíaco (K+ >7 mEq/L)'],
      diagnostico: 'Palpación: vejiga distendida, dolorosa, no vaciable. Analítica URGENTE: potasio (>6 mEq/L = emergencia cardíaca), BUN, creatinina, fósforo. ECG: ondas T picudas, ensanchamiento QRS (hiperpotasemia). Radiografía/ECO: cálculos en uretra/vejiga. Sedimento: cristales (estruvita, oxalato).',
      tratamiento: 'EMERGENCIA: estabilizar hiperpotasemia (gluconato cálcico 10% 0,5-1 ml/kg IV lento, dextrosa + insulina regular, bicarbonato si acidosis). Sedación/analgesia (buprenorfina). Sondaje uretral con catéter 3,5-5 Fr. Lavado vesical. Fluidoterapia IV agresiva. Analgesia (buprenorfina, gabapentina). Cirugía (perineal urethrostomía) si recidiva. Dieta de disolución/prevention de cristales.',
      prevencion: 'Aumentar ingesta de agua (dieta húmeda, fuentes, agua filtrada). Dieta control de cristales según tipo (estruvita, oxalato). Evitar estrés (FLUTD). Peso ideal. Enzima ureasa en dieta si estruvita. Control urinario cada 6 meses en machos con historial.',
      diagnostico_diferencial: ['FLUTD idiopática sin obstrucción', 'Uretritis', 'Cistitis', 'Neoplasia vesical/uretral', 'Trauma uretral', 'Cálculo uretral vs. tapón de detritus'],
      criterios_diagnostico: 'Incapacidad de orinar + vejiga distendida palpable + hiperpotasemia = obstrucción confirmada. Sondaje confirma y trata.',
      clasificacion: 'Obstrucción parcial (gotas) → Obstrucción completa (anuria) → Obstrucción con uremia → Obstrucción con hiperpotasemia/paro cardíaco.',
      contraindicaciones: ['NO forzar sondaje sin sedación (ruptura uretral)', 'NO administrar solo diuréticos', 'NO retrasar sondaje por "intentar en casa"', 'AINE en deshidratación/uremia'],
      referencias: ['ISFM Consensus Guidelines on Urethral Obstruction in Cats', 'AAFP Feline Urethral Obstruction Guidelines', 'Journal of Feline Medicine and Surgery 2021'],
      notas_clinicas: 'La obstrucción felina es EMERGENCIA MORTAL en horas por hiperpotasemia. El 35-50% de machos recidivan en 1 año. La perineal urethrostomía es salvadora pero último recurso.'
    },
    'Estasis gastrointestinal' => {
      sintomas: ['Anorexia total o reducción drástica del apetito', 'Cese de producción de heces (ausencia >12 h es grave)', 'Heces cada vez más pequeñas y secas antes del cese', 'Abdomen distendido, timpánico a la percusión', 'Postura encorvada (posición de "cabra de montaña")', 'Bruxismo (rechinar de dientes por dolor)', 'Temperatura subfebril (37-38 °C)', 'Letargo, debilidad progresiva'],
      diagnostico: 'Palpación abdominal: masa gasosa/distendida en ciego (lado derecho). Radiografía lateral: dilatación gástrica y cecal con gas, heces ausentes. Ecografía: contenido líquido/gaseoso en estómago y ciego, peristalsis ausente. Analítica: leucocitosis, hipoglucemia, elevación de CK (dolor). Temperatura <37,5 °C indica gravedad.',
      tratamiento: 'URGENTE: analgesia (buprenorfina 0,03 mg/kg c/6-8h), fluidoterapia SC/IV (50-100 ml/kg/día Lactato Ringer), procinéticos (metoclopramida 0,5 mg/kg c/8h o cisaprida 0,5 mg/kg c/8h), simeticona (20 mg/kg). Estimulación: movimiento suave, masaje abdominal. Si no responde en 12-24 h: cirugía exploratoria. NUNCA administrar antibióticos orales sin motilidad (empeoran).',
      prevencion: 'Heno libre >80% de la dieta (fibra larga). Agua fresca abundante. Ejercicio diario. Control dental (dolor → no come → estasis). Evitar estrés (cambios bruscos, transporte). Cepillado regular para reducir tricobezoares. No alimentar solo pellets.',
      diagnostico_diferencial: ['Obstrucción intestinal mecánica', 'Torsión intestinal', 'Enteritis', 'Absceso hepático', 'Urolitiasis (dolor → no come)', 'Dolor dental severo', 'Toxoplasmosis'],
      criterios_diagnostico: 'Anorexia >12 h + ausencia de heces + masa gasosa cecal palpable/radiográfica = estasis GI. Diferenciar de obstrucción: obstrucción tiene heces en recto ausentes + dolor desproporcionado + vómitos.',
      clasificacion: 'Estasis leve (come heno, pocas heces) → Estasis moderada (no come, no heces <12h) → Estasis severa (dolor, subfebril) → Estasis crítica (>24h, shock).',
      contraindicaciones: ['NO forzar alimentación oral en estasis activa', 'NO administrar antibióticos orales sin motilidad', 'NO dar solo analgésicos sin procinéticos y fluidos', 'NO masaje abdominal agresivo'],
      referencias: ['BSAVA Manual of Rabbit Medicine, 2nd ed.', 'House Rabbit Society — GI Stasis Protocol', 'World Small Animal Veterinary Association (WSAVA) Exotic Guidelines'],
      notas_clinicas: 'La estasis GI es la emergencia #1 en conejos. La muerte puede ocurrir en 24-48 h. El dolor es la causa más frecuente (dental). La temperatura es el mejor indicador de gravedad.'
    },
    'Cólico' => {
      sintomas: ['Mirarse el flanco repetidamente', 'Patear el abdomen', 'Revolcarse, intentar decúbito y levantarse', 'Sudoración (pelaje húmedo en cuello/flancos)', 'Rolls (tumbarse y rodar — signo de dolor severo)', 'Pulso >60 lpm, respiración >30 rpm', 'Ausencia de rumia y de deposiciones', 'Comportamiento ansioso, no comer'],
      diagnostico: 'Auscultación intestinal en 4 cuadrantes (debe haber 1-3 ruidos/minuto; silencio = grave). Palpación rectal: impactación, distorsión, impalpable. Sonda nasogástrica: reflujo >2 L indica obstrucción. Analítica: PCV, proteína total, lactato (>4 mmol/L = isquemia). Ecografía: motilidad, líquido libre, distorsión intestinal. Rectal: sonda, tacto.',
      tratamiento: 'Leve-espasmódico: flunixin 1,1 mg/kg IV (UNA dosis), buscopan, sonda nasogástrica, caminar, reposición de fluidos. Moderado: fluidoterapia IV (20-40 L/día en adulto), analgesia (flunixin + butorfanol), sonda nasogástrica continua. Grave/cirugía: laparotomía exploratoria (torsión, enterotomía, resección). Monitorizar pulso, mucosas, producción de heces.',
      prevencion: 'Cambios graduales de dieta (7-14 días). Acceso constante a agua limpia. Desparasitación regular. Rutina de alimentación (evitar sobrealimentación de concentrado). Ejercicio diario. Cepillado dental regular. Evitar acceso a arena, corteza, objetos extraños.',
      diagnostico_diferencial: ['Cólico espasmódico', 'Impactación cecal', 'Torsión/dislocación intestinal', 'Enteritis', 'Úlcera gástrica', 'Cólico nefrítico (cálculos)', 'Pleuritis', 'Parto distócico'],
      criterios_diagnostico: 'Dolor abdominal + alteración de motilidad intestinal (ausencia o exceso de ruidos) + alteración conductual = cólico. Lactato >4 mmol/L indica necesidad quirúrgica.',
      clasificacion: 'Leve (dolor leve, ruidos presentes) → Moderado (dolor moderado, ruidos disminuidos) → Grave (dolor severo, rolls, pulso >60) → Crítico (shock, lactato >6, necesidad quirúrgica inmediata).',
      contraindicaciones: ['NO más de 1 dosis de flunixin (úlcera gástrica/renal)', 'NO dar agua si hay sonda nasogástrica con reflujo abundante', 'NO forzar ejercicio en cólico severo', 'NO administrar laxantes sin diagnóstico'],
      referencias: ['AAEP Colic Guidelines', 'BSAVA Manual of Equine Field Surgery', 'ACVS Equine Colic Surgery Guidelines'],
      notas_clinicas: 'El cólico es la causa #1 de muerte en equinos no geriátricos. El 7-10% requiere cirugía. La mortalidad quirúrgica es 5-15%. El lactato sérico es el mejor predictor de necesidad quirúrgica.'
    },
    'Mastitis' => {
      sintomas: ['Ubre caliente, dolorosa e inflamada (unilateral o bilateral)', 'Leche alterada: grumos, floculos, sangre o pus', 'Fiebre >39,5 °C, decaimiento, anorexia', 'Ternera/cordero rechaza el pecho', 'Ganglios mamarios aumentados', 'En gangrenosa: ubre fría, azul-negruzca, mal olor', 'Shock en mastitis grave', 'Baja producción láctea'],
      diagnostico: 'Examen físico de ubre: calor, dolor, consistencia. Cytología de leche: >5 leucocitos/campo + bacterias. Cultivo y antibiograma de leche (Staph. aureus, E. coli, Streptococcus). California Mastitis Test (CMT). Analítica: leucocitosis, PCR elevada. Diferenciar clínica, subclínica y gangrenosa.',
      tratamiento: 'Antibióticos según cultivo: ceftiofur 1 mg/kg IM c/24h, penicilina procainica 22.000 UI/kg IM c/12h, o intramamario (tubos específicos). AINE: flunixin 2,2 mg/kg IV/IM. Ordeño frecuente de cuartos afectados. Hidratación IV en casos sistémicos. En gangrenosa: antibióticos sistémicos + posible amputación de cuartos. Descartar leche durante tratamiento y retirada.',
      prevencion: 'Higiene de ordeño (pre y post-dipping con yodo/glicerina). Ambiente limpio y seco en cubículos. Descanso adecuado del suelo. Tanque de leche frío. Detección precoz con CMT mensual. Secado adecuado de vacas. Vacunación con vacunas autógenas en hatos problemáticos.',
      diagnostico_diferencial: ['Edema de ubre', 'Hematoma mamario', 'Absceso mamario', 'Neoplasia mamaria', 'Linfangitis', 'Congestión por falta de ordeño'],
      criterios_diagnostico: 'Alteración de leche + inflamación de ubre + leucocitos en citología = mastitis. Cultivo confirma agente y guía antibiótico.',
      clasificacion: 'Subclínica (CMT+, sin signos) → Clínica leve (grumos, sin fiebre) → Clínica severa (fiebre, anorexia) → Gangrenosa (necrosis tisular, shock).',
      contraindicaciones: ['NO usar antibióticos sin cultivo en mastitis recurrente', 'Respetar periodos de retirada de leche/carne', 'NO aplicar calor en mastitis gangrenosa'],
      referencias: ['National Mastitis Council (NMC) Guidelines', 'OIE Terrestrial Manual — Bovine Mastitis', 'Food and Agriculture Organization (FAO) Dairy Health'],
      notas_clinicas: 'La mastitis subclínica cuesta más que la clínica en producción perdida. Staph. aureus es difícil de erradicar. La prevención es 10 veces más económica que el tratamiento.'
    },
    'Psitacosis' => {
      sintomas: ['Letargo, anorexia, pérdida de peso', 'Respiración dificultosa, aleteo de cola', 'Secreción nasal y ocular', 'Diarrea verdosa', 'Heces acuosas, voluminosas', 'Temblores, convulsiones (sepsis)', 'Ictericia (hepatitis)', 'Muerte súbita en aves jóvenes'],
      diagnostico: 'PCR de heces, esputo o hisopado cloacal para Chlamydia psittaci (más sensible que cultivo). Serología (complemento fijación, titulación). Radiografía: infiltrados pulmonares, hepatomegalia. Analítica: leucopenia, elevación de enzimas hepáticas. Historia: ave importada, contacto con aves silvestres.',
      tratamiento: 'Doxiciclina 25-50 mg/kg VO c/12-24h durante MÍNIMO 45 días (aunque mejore antes — evita portadores). Alternativa: enrofloxacina 10-15 mg/kg c/12h. Aislamiento del paciente. Ventilación adecuada (riesgo zoonótico). Monitorizar apetito y peso semanalmente. Tratar TODAS las aves del hogar simultáneamente.',
      prevencion: 'Cuarentena de aves nuevas 45 días. Control de importaciones. Desinfección con quaternarios de amonio. Ventilación del ambiente. Uso de mascarilla al limpiar jaulas (zoonosis). No mezclar aves de fuentes desconocidas.',
      diagnostico_diferencial: ['Aspergilosis', 'Mycoplasma', 'Polyomavirus', 'PBFD', 'Intoxicación', 'Deficiencia nutricional', 'Neumonía bacteriana'],
      criterios_diagnostico: 'Signos respiratorios + hepáticos + PCR positivo para C. psittaci = psitacosis confirmada. Seroconversión en pareja.',
      clasificacion: 'Aguda (signos sistémicos rápidos) → Crónica (bajo de peso, respiratorio crónico) → Portador asintomático (shedding intermitente).',
      contraindicaciones: ['NO suspender doxiciclina antes de 45 días', 'NO tratar solo una ave del grupo', 'Fluoroquinolonas en aves en crecimiento (artropatías)', 'Exposición humana sin protección (neumonía atípica)'],
      referencias: ['OIE Terrestrial Manual — Psittacosis', 'Association of Avian Veterinarians (AAV) Guidelines', 'CDC — Psittacosis in Humans (zoonosis)'],
      notas_clinicas: 'Zoonosis de notificación obligatoria. Los humanos desarrollan neumonía atípica. El tratamiento corto genera portadores crónicos. La doxiciclina es el único fármaco que elimina la infección.'
    },
    'Ich \(punto blanco\)' => {
      sintomas: ['Puntos blancos de 0,5-1 mm en aletas, cuerpo y branquias', 'Frotamiento contra decoración y sustrato ("flashing")', 'Respiración rápida en superficie', 'Aletas pegadas al cuerpo (clamped fins)', 'Rechazo al alimento', 'Nado errático, espasmos', 'Opacidad de ojos', 'Mucosa excesiva en branquias'],
      diagnostico: 'Observación clínica: puntos blancos característicos (como sal espolvoreada). Microscopio: Ichthyophthirius multifiliis (trofonte de 0,5-1 mm con núcleo en forma de riñón). Biopsia de piel/aletas con raspado. Temperatura del agua (Ich prolifera a 20-25 °C). Historia: peces nuevos sin cuarentena.',
      tratamiento: 'Baño con formalina 25 ppm durante 30-60 min (repetir cada 48 h x 3-4 tratamientos) o malachite green + formalina. Aumentar temperatura gradualmente a 28-30 °C (acelera ciclo del parásito). Sal 1-3 g/L como coadyuvante. Tratar TODOS los peces del acuario. Cuarentena peces nuevos 2-4 semanas. Remover carbón del filtro durante tratamiento.',
      prevencion: 'Cuarentena obligatoria de peces nuevos (2-4 semanas). No mezclar peces de fuentes diferentes sin cuarentena. Mantener temperatura estable. Evitar estrés (mala calidad de agua, sobrepoblación). Inspección visual diaria.',
      diagnostico_diferencial: ['Velvet (Oodinium)', 'Costia (Ichthyobodo)', 'Lymphocystis (viral, nódulos más grandes)', 'Puntos de pigmento', 'Granulomas bacterianos'],
      criterios_diagnostico: 'Puntos blancos + frotamiento + confirmación microscópica de I. multifiliis = Ich confirmado.',
      clasificacion: 'Leve (<5 puntos, buen apetito) → Moderado (múltiples puntos, leve estrés) → Severo (aletas clamped, anorexia, respiración superficial) → Crítico (mucosa branquial, near death).',
      contraindicaciones: ['Formalina en acuarios con escala-less (corydoras, loaches)', 'Cobre con invertebrados en el acuario', 'Tratamiento parcial (solo peces afectados)', 'Cambios bruscos de temperatura >2 °C/día'],
      referencias: ['FAO Fish Health Manual', 'Aquarium Science Association — Parasitic Diseases', 'UF/IFAS Extension — Ich in Ornamental Fish'],
      notas_clinicas: 'Ich tiene ciclo de vida de 3 etapas: trofonte (visible), tomont (quiste en sustrato), theront (infectivo libre). Solo theronts son susceptibles a tratamiento. Por eso se repiten tratamientos cada 48 h.'
    }
  }.freeze

  # Patrones regex para enfermedades con nombres variantes
  PATTERNS = [
    [/displasia de cadera/i, 'Displasia de cadera'],
    [/hipoglucemia/i, 'Hipoglucemia'],
    [/torsión|dilatación.*gástrica|dilatación-torsión/i, 'Torsión gástrica'],
    [/cardiomiopatía dilatada|cardiomiopatia dilatada/i, 'Cardiomiopatía dilatada'],
    [/cardiomiopatía hipertrófica|cardiomiopatia hipertrofica|HCM/i, 'Cardiomiopatía hipertrófica'],
    [/enfermedad renal crónica|ERC/i, 'Enfermedad renal crónica'],
    [/obstruc.*urinaria|bloqueo urinario/i, 'Obstrucción urinaria'],
    [/estasis gastrointestinal|estasis gi/i, 'Estasis gastrointestinal'],
    [/^cólico$|colico equino/i, 'Cólico'],
    [/mastitis/i, 'Mastitis'],
    [/psitacosis/i, 'Psitacosis'],
    [/ich|punto blanco/i, 'Ich (punto blanco)'],
    [/enfermedad periodontal|periodontal/i, 'Enfermedad periodontal'],
    [/colapso traqueal/i, 'Colapso traqueal'],
    [/dermatitis atópica|dermatitis atopica/i, 'Dermatitis atópica'],
    [/diabetes mellitus/i, 'Diabetes mellitus'],
    [/asma felino/i, 'Asma felino'],
    [/laminitis/i, 'Laminitis'],
    [/timpanismo/i, 'Timpanismo'],
    [/enfermedad ósea metabólica|enfermedad osea metabolica/i, 'Enfermedad ósea metabólica'],
    [/moquillo.*hurón|moquillo.*huron/i, 'Moquillo (hurón)'],
    [/wet tail|cola húmeda|cola humeda/i, 'Wet tail (proliferativa)']
  ].freeze

  def self.merged_entries
    @merged_entries ||= begin
      entries = ENTRIES.dup
      ext = File.join(__dir__, 'clinical_disease_extended_data.rb')
      load ext if File.exist?(ext)
      entries = entries.merge(EXTENDED_ENTRIES) if defined?(EXTENDED_ENTRIES)
      entries
    end
  end

  ANIMAL_TEMPLATES = {
    'perros' => {
      diagnostico_prefix: 'Evaluación veterinaria canina completa:',
      referencias: ['BSAVA Manual of Canine and Feline Clinical Procedures', 'Plumb\'s Veterinary Drug Handbook', 'Merck Veterinary Manual']
    },
    'gatos' => {
      diagnostico_prefix: 'Evaluación veterinaria felina completa:',
      referencias: ['ISFM (International Society of Feline Medicine) Guidelines', 'AAFP (American Association of Feline Practitioners) Guidelines', 'Merck Veterinary Manual']
    },
    'aves' => {
      diagnostico_prefix: 'Evaluación por veterinario especialista en aves (certificado AAV):',
      referencias: ['Association of Avian Veterinarians (AAV) Clinical Guidelines', 'Manual of Exotic Pet Practice — Avian Section', 'OIE Terrestrial Manual']
    },
    'equinos' => {
      diagnostico_prefix: 'Evaluación clínica equina de urgencia o programada:',
      referencias: ['AAEP (American Association of Equine Practitioners) Guidelines', 'BSAVA Manual of Equine Practice', 'Merck Veterinary Manual — Equine']
    },
    'bovinos' => {
      diagnostico_prefix: 'Evaluación veterinaria de producción bovina:',
      referencias: ['National Mastitis Council Guidelines', 'OIE Terrestrial Manual — Bovine Diseases', 'FAO Animal Health Manual']
    },
    'porcinos' => {
      diagnostico_prefix: 'Evaluación veterinaria porcina (salud de granja):',
      referencias: ['AASV (American Association of Swine Veterinarians) Guidelines', 'OIE Terrestrial Manual — Swine', 'Merck Veterinary Manual — Swine']
    },
    'conejos' => {
      diagnostico_prefix: 'Evaluación por veterinario de animales exóticos (especialidad lagomorfos):',
      referencias: ['BSAVA Manual of Rabbit Medicine, 2nd ed.', 'House Rabbit Society Health Resources', 'WSAVA Exotic Companion Mammal Guidelines']
    },
    'reptiles' => {
      diagnostico_prefix: 'Evaluación por veterinario de herpetología clínica:',
      referencias: ['BSAVA Manual of Reptiles, 3rd ed.', 'ARAV (Association of Reptilian and Amphibian Veterinarians) Guidelines', 'Merck Veterinary Manual — Reptiles']
    },
    'peces' => {
      diagnostico_prefix: 'Diagnóstico ichtiológico (peces ornamentales):',
      referencias: ['FAO Fish Health Manual', 'UF/IFAS Extension — Ornamental Fish Disease', 'Aquarium Science Association Guidelines']
    },
    'ovinos' => {
      diagnostico_prefix: 'Evaluación veterinaria ovina (salud de rebaño):',
      referencias: ['FAO Sheep Health Manual', 'OIE Terrestrial Manual — Ovine', 'Veterinary Clinics: Food Animal Practice']
    },
    'caprinos' => {
      diagnostico_prefix: 'Evaluación veterinaria caprina:',
      referencias: ['American Consortium for Small Ruminant Parasite Control', 'OIE Terrestrial Manual — Caprine', 'Merck Veterinary Manual — Goats']
    },
    'camelidos' => {
      diagnostico_prefix: 'Evaluación por veterinario especialista en camélidos sudamericanos:',
      referencias: ['International Camelid Institute Clinical Guidelines', 'Merck Veterinary Manual — Camelids', 'Veterinary Clinics: Food Animal Practice']
    },
    'roedores' => {
      diagnostico_prefix: 'Evaluación por veterinario de pequeños mamíferos exóticos:',
      referencias: ['BSAVA Manual of Rodents, Ferrets and Rabbits', 'AEMV (Association of Exotic Mammal Veterinarians) Guidelines', 'Merck Veterinary Manual — Small Mammals']
    }
  }.freeze

  def self.lookup(name, _animal_id)
    entries = merged_entries
    PATTERNS.each do |pattern, key|
      return entries[key].dup if name.match?(pattern) && entries[key]
    end
    return entries[name].dup if entries[name]
    nil
  end

  def self.clean_filler(text)
    return text unless text.is_a?(String)
    result = text.dup
    GENERIC_FILLER.each do |filler|
      result.gsub!(/#{Regexp.escape(filler)}[^.]*\.?\s*/i, '')
    end
    result.gsub(/\s+/, ' ').strip
  end

  def self.enrich_disease(disease, animal_id, breed_id)
    d = disease.dup
    name = d['nombre']
    clinical = lookup(name, animal_id)
    template = ANIMAL_TEMPLATES[animal_id] || ANIMAL_TEMPLATES['perros']

    if clinical
      clinical.each do |key, value|
        next if key == :drug_keys
        d[key.to_s] = value
      end
    else
      # Mejorar contenido genérico con plantilla específica por especie
      d['diagnostico'] = clean_filler(d['diagnostico'])
      if d['diagnostico'].length < 80
        d['diagnostico'] = "#{template[:diagnostico_prefix]} Anamnesis dirigida a #{name.downcase}, examen físico completo y pruebas complementarias según presentación clínica. En #{animal_id}: considerar enfermedades endémicas de la región y factores de manejo del paciente (#{breed_id})."
      end
      d['tratamiento'] = clean_filler(d['tratamiento'])
      if d['tratamiento'].length < 80
        d['tratamiento'] = "Tratamiento de #{name.downcase} según protocolo veterinario específico para #{animal_id}: estabilización del paciente, terapia dirigida al agente/órgano afectado, analgesia apropiada y monitorización de parámetros vitales. Ajustar dosis al peso exacto. Hospitalización si hay signos sistémicos."
      end
      d['prevencion'] = clean_filler(d['prevencion'])
      if d['prevencion'].length < 80
        d['prevencion'] = "Prevención de #{name.downcase} en #{animal_id}: bioseguridad, manejo adecuado, nutrición equilibrada, vacunación/desparasitación según calendario, cuarentena de animales nuevos y revisiones veterinarias programadas."
      end
      d['referencias'] ||= template[:referencias]
      d['diagnostico_diferencial'] ||= ['Otras enfermedades del mismo órgano/sistema', 'Enfermedades infecciosas concurrentes', 'Intoxicaciones', 'Neoplasias', 'Enfermedades metabólicas']
      d['criterios_diagnostico'] ||= "Confirmación clínica de #{name.downcase} mediante examen físico compatible y al menos una prueba complementaria positiva (laboratorio, imagen o citología)."
      d['notas_clinicas'] ||= "Consultar siempre con un veterinario especializado en #{animal_id} para diagnóstico definitivo y plan terapéutico individualizado."
    end

    # Limpiar relleno genérico de todos los campos
    %w[diagnostico tratamiento prevencion].each do |field|
      d[field] = clean_filler(d[field]) if d[field]
    end

    # Limpiar síntomas genéricos
    if d['sintomas']
      d['sintomas'] = d['sintomas'].reject { |s| s.match?(/signo clínico principal|letargo o cambio de conducta|pérdida de apetito|fiebre o decaimiento|dolor a la palpación|empeoramiento progresivo sin tratamiento/i) }
      d['sintomas'] = clinical[:sintomas] if clinical && clinical[:sintomas] && d['sintomas'].length < 4
    end

    d
  end
end
