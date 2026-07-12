# frozen_string_literal: true
# Extensión de la biblioteca clínica — enfermedades adicionales por especie

EXTENDED_ENTRIES = {
    'Enfermedad periodontal' => {
      sintomas: ['Mal aliento (halitosis) progresivo', 'Encías inflamadas, rojas o sangrantes al cepillado', 'Sarro visible (placa mineralizada) en dientes', 'Dolor al comer o masticar (preferencia por alimento blando)', 'Pérdida de dientes o movilidad dental', 'Pus o secreción alrededor de la línea gingival', 'Encías retraídas exponiendo raíces', 'Babeo excesivo'],
      diagnostico: 'Examen oral bajo sedación/anestesia: sondaje de bolsas periodontales (profundidad >3 mm = enfermedad), radiografías dentales digitales (pérdida ósea >25% = periodontitis), movilidad dental (grado I-III), índice de placa y sarro. Evaluar bacteriemia secundaria (cardiopatía, renal).',
      tratamiento: 'Profilaxis dental bajo anestesia: ultrasonido + pulido + extracciones si movilidad grado III o pérdida ósea >50%. Antibiótico pre/post si infección severa (clindamicina 11 mg/kg c/12h x 7-14 días). Analgesia (meloxicam). Cepillado diario postoperatorio con pasta enzimática. Snacks dentales VOHC.',
      prevencion: 'Cepillado dental diario desde cachorro/gatito. Profilaxis profesional cada 12-24 meses. Snacks dentales certificados VOHC. Agua aditivada con hexetidina (coadyuvante). Evitar dieta exclusivamente blanda.',
      diagnostico_diferencial: ['Gingivitis sin periodontitis', 'Estomatitis ulcerativa crónica (gatos)', 'Cuerpo extraño oral', 'Neoplasia oral', 'Enfermedad renal (uremia → ulcera)', 'Leishmaniosis (gingivitis proliferativa)'],
      criterios_diagnostico: 'Profundidad de bolsa periodontal >3 mm + pérdida de inserción + radiográfica con pérdida ósea = periodontitis confirmada.',
      clasificacion: 'Grado 1 (gingivitis) → Grado 2 (bolsas <25% pérdida ósea) → Grado 3 (25-50% pérdida) → Grado 4 (>50%, movilidad, extracción indicada).',
      contraindicaciones: ['Extracciones sin radiografía dental previa', 'Cepillado agresivo con encías sangrantes activas', 'Antibióticos sin limpieza dental (ineficaz)'],
      referencias: ['WSAVA Global Dental Guidelines', 'AAHA Dental Care Guidelines for Dogs and Cats', 'VOHC (Veterinary Oral Health Council)'],
      notas_clinicas: 'El 80% de perros y gatos >3 años tienen enfermedad periodontal. La bacteriemia crónica afecta riñón, corazón e hígado. Es la enfermedad más subestimada en mascotas.'
    },
    'Colapso traqueal' => {
      sintomas: ['Tos seca, perruna ("honk" como ganso)', 'Episodios de tos con excitación, tirón de correa o bebida', 'Dificultad respiratoria en episodios agudos', 'Cianosis de encías en crisis severa', 'Intolerancia al ejercicio', 'Síncope en casos graves', 'Respiración abdominal', 'Estridor inspiratorio'],
      diagnostico: 'Auscultación: estridor inspiratorio cervical. Radiografía lateral: colapso de tráquea intratorácica (aplaamiento >50% del diámetro). Fluoroscopia dinámica (colapso con inspiración). Endoscopia traqueal: grado de colapso (I-IV). Descartar cardiomegalia, neumonía.',
      tratamiento: 'Grado I-II: manejo conservador (arnés, control de peso, evitar irritantes, maropitant 2 mg/kg c/24h como antitusígeno). Grado III-IV: butorfanol 0,2-0,4 mg/kg c/6-8h, terbutalina 0,01 mg/kg c/8h, prednisolona 0,5 mg/kg c/24h (descenso). Stent traqueal quirúrgico en refractarios. Cirugía de anillos (colocación de anillos externos) en colapso extratorácico.',
      prevencion: 'Arnés en lugar de collar SIEMPRE. Control estricto de peso (obesidad empeora). Evitar humo, polvo, aerosoles, perfumes. Aire acondicionado en verano. Reducir situaciones de excitación. Elevación de comederos si mejora respiración.',
      diagnostico_diferencial: ['Laringitis', 'Parálisis de cuerdas vocales', 'Enfermedad cardíaca (tos cardíaca)', 'Tracheobronquitis infecciosa', 'Cuerpo extraño traqueal', 'Neoplasia traqueal', 'Síndrome braquicefálico'],
      criterios_diagnostico: 'Tos característica + radiografía/fluoroscopia con colapso traqueal >50% del lumen = confirmado. Grado I-IV según severidad.',
      clasificacion: 'Grado I: colapso 25% → Grado II: 50% → Grado III: 75% → Grado IV: colapso total con plegamiento de cartílagos.',
      contraindicaciones: ['Collar y correa (empeoran colapso)', 'Sedantes sin monitorización en grado IV', 'Cirugía de anillos en colapso intratorácico'],
      referencias: ['ACVIM Consensus on Tracheal Collapse', 'BSAVA Manual of Canine and Feline Thoracic Surgery', 'Merck Veterinary Manual'],
      notas_clinicas: 'Muy frecuente en Yorkshire, Pomerania, Chihuahua, Poodle toy. El 70% responde a manejo médico. El stent traqueal tiene complicaciones (granulomas, tos persistente).'
    },
    'Dermatitis atópica' => {
      sintomas: ['Prurito (picor) estacional o perenne', 'Lamer patas, rascarse orejas y axilas', 'Piel eritematosa en axilas, ingles, abdomen', 'Alopecia por rascado/lija', 'Otitis externa recurrente (40% de casos)', 'Pies inflamados (pododermatitis)', 'Cara frotada contra muebles', 'Recurrencia tras corticoides (rebote)'],
      diagnostico: 'Historia: prurito, estacionalidad, respuesta a corticoides. Descartar sarna (raspado negativo), alergia alimentaria (dieta de eliminación 8 semanas), dermatitis por pulgas. Test intradérmico o IgE sérica (sensibilización). Cytología: cocáceas, Malassezia secundarios.',
      tratamiento: 'Primer escalón: control de pulgas estricto + baños con clorhexidina. Segundo: oclacitinib (Apoquel) 0,4-0,6 mg/kg c/12h o ciclosporina (Atopica) 5 mg/kg c/24h. Tercero: inmunoterapia (vacuna autógena según test). Antibióticos si infección secundaria. Shampoo medicado 2 veces/semana.',
      prevencion: 'Control de pulgas todo el año. Baños regulares con champú hipoalergénico. Dieta de mantenimiento de calidad. Evitar alérgenos identificados (ácaros del polvo: fundas antiácaros, lavar cama a 60 °C). Inmunoterapia como prevención a largo plazo.',
      diagnostico_diferencial: ['Alergia alimentaria', 'Dermatitis por pulgas (FAD)', 'Sarna sarcóptica', 'Dermatitis por contacto', 'Infección fúngica (Malassezia)', 'Seborrea primaria', 'Hipotiroidismo (dermatosis)'],
      criterios_diagnostico: 'Prurito + exclusión de sarna, pulgas y alimentaria + sensibilización IgE o test intradérmico positivo = dermatitis atópica.',
      clasificacion: 'Leve (prurito sin lesiones) → Moderada (eritema, alopecia leve) → Severa (lichenificación, hiperpigmentación, otitis crónica) → Crónica severa (infecciones secundarias recurrentes).',
      contraindicaciones: ['Corticoides crónicos sin monitorización (diabetes, Cushing iatrogénico)', 'Ciclosporina sin control TA y función renal', 'Baños con champú humano (irritación)'],
      referencias: ['International Committee on Allergic Diseases of Animals (ICADA)', 'AAVA Dermatology Guidelines', 'BSAVA Manual of Canine and Feline Dermatology'],
      notas_clinicas: 'Afecta al 10-15% de perros. La alergia alimentaria se descarta ANTES de diagnosticar atopia. Apoquel y ciclosporina han revolucionado el tratamiento vs. corticoides crónicos.'
    },
    'Diabetes mellitus' => {
      sintomas: ['Polidipsia y poliuria (PUPD) marcada', 'Polifagia con pérdida de peso', 'Letargo, debilidad muscular', 'Cataratas (gatos y perros, rápido en gatos)', 'Piel seca, pelaje de mal aspecto', 'Cetoacidosis: vómitos, anorexia, aliento dulce (cetosis)', 'Neuropatía periférica (gatos: postura plantígrada)', 'Infecciones recurrentes (urinarias, cutáneas)'],
      diagnostico: 'Glucemia >250 mg/dL persistente (ayunas o casual). Glucosuria. Fructosamina elevada (>400 μmol/L). Curva glucémica (si duda). Descartar hiperadrenocorticismo, acromegalia (gatos), pancreatitis. Cetoacidosis: pH <7,3, cetonas en sangre/orina.',
      tratamiento: 'Gatos: insulina glargina (Lantus) 0,25-0,5 UI/kg SC c/12h + dieta baja en carbohidratos (Diabetic DS). Perros: insulina lenta (NPH, Vetsulin) 0,5-1 UI/kg SC c/12h. Curva glucémica a las 2, 4, 6, 8, 10, 12 h post-dosis. Cetoacidosis: fluidoterapia + insulina IV + potasio. Monitorizar glucemia domiciliaria.',
      prevencion: 'Peso ideal (obesidad es factor de riesgo #1 en gatos). Dieta alta en proteína, baja en carbohidratos. Ejercicio regular. Esterilización en gatos (gatas enteras más riesgo). Cribado glucemia anual en seniors obesos.',
      diagnostico_diferencial: ['Diabetes insípida', 'Hiperadrenocorticismo', 'Hipertiroidismo (gatos)', 'Insulinoma (hipoglucemia, no hiper)', 'Estrés hiperglucemia (gatos en consulta)', 'Acromegalia felina'],
      criterios_diagnostico: 'Glucemia >250 mg/dL en 2 ocasiones + glucosuria + signos clínicos = diabetes mellitus. Cetoacidosis: glucemia + cetonemia + acidosis.',
      clasificacion: 'Compensada (glucemia <300, sin cetonas) → Descompensada (glucemia >300, poliuria severa) → Cetoacidosis diabética (emergencia) → Remisión (gatos, 20-40% con tratamiento temprano).',
      contraindicaciones: ['Insulina sin curva glucémica inicial', 'Dieta alta en carbohidratos en gatos diabéticos', 'Corticoides (empeoran resistencia insulínica)', 'Suspender insulina abruptamente'],
      referencias: ['AAFP Diabetes Management Guidelines', 'ACVIM Consensus on Diabetes in Dogs and Cats', 'ISFM Diabetes Guidelines'],
      notas_clinicas: 'En gatos, la remisión es posible con insulina glargina + dieta baja en carbohidratos (hasta 40%). En perros, diabetes es generalmente permanente. Cataratas en gatos pueden resolverse con control glucémico.'
    },
    'Asma felino' => {
      sintomas: ['Tos seca, paroxística (parece "vomitar pelo")', 'Dificultad respiratoria con postura de cuello extendido', 'Aleteo nasal', 'Respiración abdominal', 'Sibilancias a la auscultación', 'Episodios agudos (crisis asmática)', 'Vómito de espuma tras tos', 'Cianosis en crisis severa'],
      diagnostico: 'Radiografía torácica: patrones peribronquiales ("donuts", "tram tracks"), hiperinsuflación. Cytología de lavado traqueal: eosinófilos >10%. Descartar parásitos pulmonares (Baermann), infección, cardiomegía. IgE sérica para alérgenos ambientales.',
      tratamiento: 'Agudo: salbutamol inhalado (aerochamber felino) 1-2 puff + prednisolona 1-2 mg/kg c/12h. Crónico: fluticasona inhalada (Flovent) 1 puff c/12h + salbutamol de rescate. Alternativa oral: prednisolona 1 mg/kg c/24h con descenso. Ciclosporina si intolerancia a corticoides.',
      prevencion: 'Eliminar alérgenos: no perfumes, aerosoles, polvo (arena sin polvo, aspirar frecuente). Filtro HEPA. No fumar en casa. Control de pulgas y ácaros del polvo. Peso ideal. Evitar estrés.',
      diagnostico_diferencial: ['Bronquitis infecciosa', 'Parásitos pulmonares (Aelurostrongylus)', 'Cardiomegía/ICC', 'Cuerpo extraño', 'Neoplasia pulmonar', 'Tromboembolismo'],
      criterios_diagnostico: 'Tos crónica + patrón peribronquial radiográfico + eosinófilos en lavado traqueal = asma felina.',
      clasificacion: 'Leve (tos intermitente, sin dificultad respiratoria) → Moderada (tos frecuente, sibilancias ocasionales) → Severa (crisis asmáticas recurrentes) → Crítica (crisis con cianosis, hospitalización).',
      contraindicaciones: ['Prednisona (usar prednisolona en gatos)', 'Inyecciones de depomedrol repetidas (diabetes, Cushing)', 'AINE (empeoran asma)'],
      referencias: ['ACVIM Feline Bronchial Disease Guidelines', 'ISFM Asthma Guidelines', 'Journal of Feline Medicine and Surgery'],
      notas_clinicas: 'El asma felino es la enfermedad respiratoria crónica #1 en gatos. La inhaloterapia con aerochamber reduce efectos sistémicos de corticoides. Las crisis asmáticas son emergencias.'
    },
    'Laminitis' => {
      sintomas: ['Cojera aguda en varios miembros (peor delanteros)', 'Postura de "sentado" trasero (descargar delanteros)', 'Pulsos digitales fuertes y palpables', 'Cascos calientes al tacto', 'Reluctancia a moverse, caminar rígido', 'Dolor al levantar un pie (contralateral empeora)', 'Anillo de crecimiento concéntrico en casco', 'Recumbencia prolongada en casos graves'],
      diagnostico: 'Palpación: pulsos digitales aumentados, dolor a la presión con pinzas en zona del borde solar. Radiografía lateral: rotación del pedúnculo (P3), hundimiento. Analítica: ACTH si sospecha PPID, insulina si síndrome metabólico. Historia: sobrealimentación, estrés, endotoxemia.',
      tratamiento: 'URGENTE: confinamiento en box profundo de arena/arena fina. AINE: fenilbutazona 4,4 mg/kg c/12h x 5 días (máximo). Furosemida 1 mg/kg IV si edema. Enfriamiento de cascos (hielo 24-48 h). Corrección causa (retirar concentrado, tratar PPID). Talonera o zapatos terapéuticos. Descanso absoluto 6-12 semanas.',
      prevencion: 'Evitar sobrealimentación de concentrado y pasto alto en fructanos. Peso ideal. Tratar PPID (pergolida) y síndrome metabólico. Herraje correcto. Evitar estrés (transporte, enfermedad sistémica). Limitar pasto en primavera (picos de fructanos).',
      diagnostico_diferencial: ['Absceso de casco', 'Cólico (dolor referido)', 'Cervicalgia', 'Fractura de P3', 'Osteomielitis de P3', 'Síndrome del borde blanco'],
      criterios_diagnostico: 'Dolor en cascos + pulsos digitales aumentados + radiografía con rotación/hundimiento de P3 = laminitis confirmada.',
      clasificacion: 'Grado I (dolor, sin cambios radiográficos) → Grado II (alguna rotación P3) → Grado III (rotación significativa) → Grado IV (hundimiento de P3, penumbra).',
      contraindicaciones: ['Fenilbutazona >5 días (úlcera GI, aplasia medular)', 'Caminar forzado en fase aguda', 'Herraje agresivo sin analgesia', 'Corticoides en equinos metabólicos'],
      referencias: ['AAEP Laminitis Guidelines', 'BEVA Laminitis Consensus Statement', 'Merck Veterinary Manual — Equine Laminitis'],
      notas_clinicas: 'La laminitis es la 2ª causa de eutanasia en equinos. El síndrome metabólico (obesidad + insulinemia) es la causa #1 en ponis y caballos de pasto. El pronóstico depende de la velocidad de intervención.'
    },
    'Timpanismo' => {
      sintomas: ['Distensión del flanco izquierdo (rumen/retículo)', 'Dolor abdominal, inquietud', 'Rechazo del alimento', 'Reducción o ausencia de rumia', 'Frecuencia cardíaca elevada (>90 lpm)', 'Respiración superficial rápida', 'Recumbencia y patadas al abdomen', 'Shock en casos graves'],
      diagnostico: 'Auscultación: timpanismo en hemiabdomen izquierdo (sonido metálico a la percusión). Sonda esofágica: imposibilidad de liberar gas en timpanismo espumoso. Diferenciar: timpanismo libre (gas) vs. espumoso (líquido + gas). Analítica: hipocalcemia, hipocloremia.',
      tratamiento: 'Timpanismo libre: sonda esofágica para liberar gas + antiespumante (simeticona/dimeticona 100-200 ml VO o por sonda). Espumoso: antiespumante IV/VO + fluidoterapia. Analgesia: flunixin 2,2 mg/kg IV. En grave: troacar ruminal (último recurso). Corregir dieta (evitar leguminosas frescas, concentrado excesivo).',
      prevencion: 'Adaptación gradual a pastos ricos en leguminosas. No pastorear con rocío/humedad. Acceso gradual a concentrado. Bloques minerales con ionóforos (monensina). Evitar cambios bruscos de dieta. Agua disponible permanentemente.',
      diagnostico_diferencial: ['Obstrucción esofágica', 'Cólico intestinal', 'Peritonitis', 'Abomaso desplazado (bovinos)', 'Rumén paralítico', 'Intoxicación'],
      criterios_diagnostico: 'Distensión del flanco izquierdo + timpanismo a la percusión + ausencia de rumia = timpanismo. Sonda confirma tipo (libre vs. espumoso).',
      clasificacion: 'Leve (distensión sin dolor severo) → Moderado (dolor, taquicardia) → Grave (shock, recumbencia) → Crítico (compresión diafragmática, muerte).',
      contraindicaciones: ['Troacar ruminal sin intentar sonda primero', 'Forzar alimentación', 'Ejercicio forzado'],
      referencias: ['FAO Ruminant Health Manual', 'Merck Veterinary Manual — Bloat', 'Veterinary Clinics: Food Animal Practice'],
      notas_clinicas: 'El timpanismo espumoso es más grave que el libre. En ovinos y bovinos es emergencia. La simeticona es el tratamiento de elección para espumoso. Prevención dietética es clave.'
    },
    'Enfermedad ósea metabólica' => {
      sintomas: ['Deformidades óseas (mandíbula blanda, lordosis)', 'Fracturas patológicas con mínimo trauma', 'Temblores musculares (hipocalcemia)', 'Letargo, debilidad', 'Anorexia', 'Dificultad para masticar (mandíbula blanda)', 'Cojera, artralgia', 'Convulsiones (hipocalcemia severa)'],
      diagnostico: 'Radiografía: fracturas patológicas, osteopenia generalizada, deformidades. Analítica: calcio bajo, fósforo alto, PTH elevada, vitamina D baja. Historia: dieta deficiente, sin UVB, captividad inadecuada. Diferenciar de nutricional secundaria vs. renal.',
      tratamiento: 'Suplementación de calcio (gluconato cálcico oral/IM) + vitamina D3 (cholecalciferol) con precaución (toxicidad). Corrección ambiental: UVB 10-12 h/día (lámpara específica, cambiar cada 6 meses). Dieta balanceada con Ca:P 2:1. Fluidoterapia si deshidratado. Fisioterapia.',
      prevencion: 'UVB de calidad 10-12 h/día a 30 cm de distancia. Dieta con relación Ca:P 2:1. Suplemento de calcio sin fósforo. Exposición solar directa (con precaución de sobrecalentamiento). Lámpara UVB específica para reptiles (no luz negra).',
      diagnostico_diferencial: ['Fractura traumática', 'Gota (hiperuricemia)', 'Osteomielitis', 'Neoplasia ósea', 'Hipocalcemia por oviposición', 'Secuestro de vitamina D'],
      criterios_diagnostico: 'Deformidades óseas + osteopenia radiográfica + calcio sérico bajo + historial de mala iluminación/dieta = EOM.',
      clasificacion: 'Leve (osteopenia sin fracturas) → Moderada (deformidades, fracturas parciales) → Severa (fracturas múltiples, hipocalcemia) → Crítica (convulsiones, recumbencia).',
      contraindicaciones: ['Sobredosis de vitamina D3 (hipercalcemia, nefrocalcinosis)', 'Calcio sin vitamina D (ineficaz sin metabolismo)', 'Lámparas UVB genéricas (espectro incorrecto)'],
      referencias: ['ARAV Metabolic Bone Disease Guidelines', 'BSAVA Manual of Reptiles, 3rd ed.', 'Journal of Herpetological Medicine and Surgery'],
      notas_clinicas: 'La EOM es la enfermedad #1 en reptiles cautivos. La UVB es OBLIGATORIA — no es opcional. El espectro 290-320 nm es crítico. La recuperación es lenta (meses).'
    },
    'Moquillo \(hurón\)' => {
      sintomas: ['Secreción purulenta ocular y nasal', 'Fiebre, letargo, anorexia', 'Dermatitis plantar (almohadillas inflamadas)', 'Erupción cutánea (barba, abdomen)', 'Convulsiones (formas neurológicas)', 'Parálisis progresiva', 'Hiperkeratosis de almohadillas', 'Muerte en 2-4 semanas sin tratamiento'],
      diagnostico: 'PCR de hisopado conjuntival/nasal para virus del moquillo. Serología (anticuerpos IgM/IgG). Citología: inclusiones de Cowdry tipo A. Historia: hurón no vacunado, contacto con perros/gatos infectados. Hallazgos clínicos característicos.',
      tratamiento: 'Soporte intensivo: fluidoterapia SC, alimentación asistida (soup, Critical Care). Antibióticos para infección secundaria (enrofloxacina 10 mg/kg c/12h). Analgesia. Aislamiento estricto. Prevención: vacunación con Purevax Ferret Distemper anual. NO hay tratamiento antiviral específico eficaz.',
      prevencion: 'Vacunación anual OBLIGATORIA con vacuna específica para hurones (Purevax Ferret, NO vacuna canina). Evitar contacto con animales no vacunados. Cuarentena de hurones nuevos 14 días. No llevar a parques con perros.',
      diagnostico_diferencial: ['Influenza hurón', 'Infección bacteriana respiratoria', 'Alergia', 'Insulinoma (debilidad)', 'Enfermedad adrenal'],
      criterios_diagnostico: 'Signos clínicos compatibles + PCR positivo para moquillo canino = confirmado. Alta mortalidad en no vacunados.',
      clasificacion: 'Forma respiratória → Forma cutánea → Forma neurológica (peor pronóstico) → Muerte.',
      contraindicaciones: ['Vacuna canina estándar en hurones (puede causar moquillo)', 'NO suspender vacunación anual', 'Contacto con mustélidos silvestres'],
      referencias: ['AEMV (Association of Exotic Mammal Veterinarians) Ferret Guidelines', 'AAV Mustelid Medicine', 'Merck Veterinary Manual — Ferrets'],
      notas_clinicas: 'El moquillo es 100% mortal en hurones no vacunados. La vacunación es obligatoria por ley en muchos países. Usar SOLO vacuna aprobada para hurones. Mortalidad >50% incluso con tratamiento.'
    },
    'Wet tail \(proliferativa\)' => {
      sintomas: ['Diarrea acuosa profusa con mal olor', 'Mojado de la zona perianal ("cola húmeda")', 'Letargo, postura encorvada', 'Anorexia total', 'Deshidratación rápida (piel turgente perdida)', 'Bruxismo (rechinar dientes)', 'Temblores, debilidad', 'Muerte en 24-72 h si no se trata'],
      diagnostico: 'Historia: hámster joven (<12 semanas), estrés reciente (transporte, cambio de jaula). Diarrea característica con mal olor. Cultivo: Lawsonia intracellularis, Campylobacter, E. coli. Diferenciar de diarrea simple por dieta.',
      tratamiento: 'URGENTE: fluidoterapia SC (20-40 ml/kg/día Lactato Ringer). Antibióticos: enrofloxacina 10 mg/kg c/12h o metronidazol 20 mg/kg c/12h. Analgesia (meloxicam 0,5 mg/kg). Aislamiento, calor suplementario (30-32 °C). Alimentación asistida. Desinfección completa de jaula.',
      prevencion: 'Reducir estrés: no cambiar jaula/ambiente bruscamente. Higiene de jaula (limpiar diario). No sobrepoblar. Dieta de calidad sin verduras en exceso. Cuarentena de hámsters nuevos. Evitar transporte en crías.',
      diagnostico_diferencial: ['Diarrea por dieta (verduras excesivas)', 'Salmonelosis', 'Giardiasis', 'Tyzzer disease', 'Intoxicación'],
      criterios_diagnostico: 'Diarrea acuosa maloliente + deshidratación + hámster joven estresado = wet tail probable. Cultivo confirma.',
      clasificacion: 'Leve (diarrea blanda, activo) → Moderada (diarrea acuosa, letargo) → Grave (deshidratación, anorexia) → Crítica (muerte inminente).',
      contraindicaciones: ['NO bañar al hámster (hipotermia)', 'NO forzar alimentación oral si debilitado', 'NO antibióticos sin fluidoterapia concurrente'],
      referencias: ['BSAVA Manual of Rodents and Ferrets', 'AEMV Small Mammal Guidelines', 'Merck Veterinary Manual — Hamsters'],
      notas_clinicas: 'Wet tail es la enfermedad más fatal en hámsters jóvenes. La mortalidad sin tratamiento es >90%. El estrés es el desencadenante principal. Tratar como emergencia.'
    }
}.freeze
