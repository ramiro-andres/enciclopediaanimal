# frozen_string_literal: true

# Perfiles clínicos detallados por especie y raza
module BreedClinicalProfiles
  SPECIES_PROFILES = {
    'perros' => {
      parametros_salud: 'Constantes vitales caninas de referencia: T° rectal 38,0-39,2 °C (fiebre >39,5 °C). FC 60-140 lpm (razas pequeñas en rango alto, 100-140). FR 10-30 rpm en reposo. TRC 1-2 s. Mucosas rosadas y húmedas. Presión arterial sistólica 110-140 mmHg. Glucemia 75-120 mg/dL. Tiempo de coagulación 2-4 min.',
      vacunacion: 'Calendario WSAVA: Cachorros — primovacunación a las 6-8, 10-12 y 14-16 semanas (moquillo CDV, parvovirus CPV-2, adenovirus CAV-1/CAV-2, parainfluenza, opcional Leptospira). Rabia según normativa local (generalmente ≥12 semanas). Refuerzo a los 12 meses, luego cada 1-3 años según vacuna y estilo de vida. Opcionales: Bordetella (pensión/grooming), Leptospira anual en zonas endémicas, Lyme en áreas con garrapatas.',
      vacunacion_detallada: ['6-8 semanas: MLV moquillo, parvo, adeno, parainfluenza (primera dosis)', '10-12 semanas: Segunda dosis MLV + Leptospira (si endémica)', '14-16 semanas: Tercera dosis MLV + rabia (según ley local)', '12 meses: Refuerzo de todas las vacunas', 'Adulto: Refuerzo trienal (CDV, CPV, CAV) o anual según título de anticuerpos', 'Bordetella: cada 6-12 meses si contacto con otros perros'],
      desparasitacion: 'Interna: cachorros cada 2 semanas hasta las 12 semanas, luego mensual hasta los 6 meses, después cada 1-3 meses (fenbendazol 50 mg/kg x 3 días o praziquantel+febantel). Externa: isoxazolinas (fluralaner, afoxolaner, sarolaner) cada 1-3 meses según producto. Prevención de dirofilariosis (heartworm) mensual en zonas endémicas.',
      revisiones: 'Cachorros: cada 3-4 semanas durante primovacunación. Adultos 1-7 años: revisión anual con analítica básica (hemograma, bioquímica, urianálisis), examen dental, palpación abdominal. Seniors >7 años: cada 6 meses con analítica ampliada (T4, SDMA, ecografía abdominal).',
      cribado_salud_recomendado: ['Ortopedia: radiografías de cadera (OFA/PennHIP) y codo a los 24 meses en razas predispuestas', 'Cardiología: auscultación anual; ecocardiografía a los 3-5 años en razas de riesgo (Doberman, Cavalier, Boxer)', 'Oftalmología: examen OFA anual en razas predispuestas (Cocker, Poodle, Schnauzer)', 'Genético: test MDR1 (pastores), PRA, DM (pastor alemán), HUU (dálmata)', 'Dental: profilaxis bajo anestesia cada 1-2 años'],
      nutricion_clinica: 'Pienso certificado AAFCO/FEDIAF según etapa vital (cachorro, adulto, senior). Proteína 22-32% DM en adultos. Razas grandes: crecimiento controlado (calcio 1-1,2%, no sobrealimentar). Razas pequeñas: riesgo de hipoglucemia — comidas frecuentes. BCS objetivo 4-5/9. Evitar xilitol, chocolate, uvas, cebolla.',
      manejo_clinico: 'Identificación con microchip ISO 11784/11785. Seguro veterinario recomendado. Primeros auxilios: botiquín con gasas, suero fisiológico, miel (hipoglucemia), collar isabelino. Transporte seguro en accidentes (tabla rígida). Arnés en lugar de collar en razas braquicéfalas y con colapso traqueal.',
      contraindicaciones_especie: ['Ibuprofeno y paracetamol (tóxicos)', 'Ivermectina en portadores MDR1/ABCB1 (pastor australiano, border collie)', 'Xilitol (hipoglucemia grave)', 'Grapas (toxicosis macro y microcítica)'],
      fuentes_bibliograficas: ['WSAVA Global Vaccination Guidelines 2024', 'AAHA Canine Life Stage Guidelines', 'Merck Veterinary Manual — Dogs', 'BSAVA Manual of Canine and Feline Clinical Procedures']
    },
    'gatos' => {
      parametros_salud: 'Constantes vitales felinas: T° 38,0-39,2 °C (fiebre >39,5 °C). FC 140-220 lpm. FR 20-30 rpm (¡>40 rpm en reposo = urgencia!). TRC 1-2 s. Mucosas rosadas. Presión arterial sistólica <160 mmHg (hipertensión >160). Glucemia 70-120 mg/dL. Dolor: escala FGS (Feline Grimace Scale).',
      vacunacion: 'Calendario AAFP/WSAVA: Gatitos — FVRCP (panleucopenia, calicivirus, rinotraqueitis) a las 6-8, 10-12 y 14-16 semanas. Rabia según ley local. FeLV (leucemia felina) si acceso al exterior o contacto con gatos FeLV+. Refuerzo FVRCP a los 12 meses, luego cada 1-3 años (protocolo 3-year para adultos de interior).',
      vacunacion_detallada: ['6-8 semanas: FVRCP primera dosis', '10-12 semanas: FVRCP segunda + FeLV (si riesgo)', '14-16 semanas: FVRCP tercera + rabia', '12 meses: Refuerzo FVRCP + FeLV + rabia', 'Adulto interior: FVRCP cada 3 años (titulación opcional)', 'FeLV: solo gatos con riesgo de exposición'],
      desparasitacion: 'Interna: gatitos cada 2 semanas hasta 12 semanas, luego mensual x 3, después cada 3 meses (fenbendazol o praziquantel). Externa: isoxazolinas mensuales si acceso al exterior. Toxoplasma: evitar carne cruda, limpiar arenero diariamente (embarazadas).',
      revisiones: 'Gatitos: cada 3-4 semanas con vacunas. Adultos 1-10 años: anual con analítica (hemograma, bioquímica, urianálisis, UPC). Seniors >10 años: cada 6 meses con SDMA, T4, TA, ecografía renal. Dental: profilaxis bajo anestesia si gingivitis.',
      cribado_salud_recomendado: ['Cardiología: ecocardiografía en Maine Coon, Ragdoll, Sphynx, British a los 1, 3 y 5 años', 'Renal: creatinina + SDMA anual a partir de los 7 años', 'Retroviral: test FeLV/FIV al adoptar y si enfermedad', 'Genético: HCM (MyBPC3), PKD (Persa), PRA (Abisinio)', 'TA: anual en seniors (hipertensión secundaria a IRC/HCM)', 'Dental: examen oral anual (enfermedad periodontal >70% en gatos >3 años)'],
      nutricion_clinica: 'Obligatorio taurina en dieta (deficiencia → DCM). Proteína alta (≥30% DM). Dieta húmeda preferible (hidratación renal). Cuidado con dieta cruda (Salmonella, Toxoplasma). BCS 5/9. Lilies (lirios) son NEFROTÓXICOS fatales. Evitar cebolla, ajo, chocolate.',
      manejo_clinico: 'Caja de transporte acostumbrada desde cachorro. Enriquecimiento ambiental (rascadores, altura, escondites). Multi-cat: 1 arenero + 1 extra, 1 bebedero + 1 extra. Feliway (feromonas) en estrés. Nunca medicar con medicamentos caninos.',
      contraindicaciones_especie: ['AINE (meloxicam máximo 3-5 días, dosis felina estricta)', 'Acetaminofén/paracetamol (FATAL — methemoglobinemia)', 'Permetrina canina (tremores, convulsiones)', 'Lilies/lirios (insuficiencia renal aguda)', 'Prednisona (usar prednisolona — conversión hepática deficiente)'],
      fuentes_bibliograficas: ['AAFP Feline Life Stage Guidelines 2021', 'ISFM Consensus Guidelines', 'WSAVA Global Vaccination Guidelines', 'Merck Veterinary Manual — Cats']
    },
    'aves' => {
      parametros_salud: 'Constantes aviares: T° 40-42 °C (¡hipotermia grave <38 °C!). FC 250-500 lpm (varía enormemente por especie). FR 20-40 rpm en reposo. Mucosas/trabeculado oral rosado. Peso: control semanal con báscula de gramos (cambio >10% = alerta). Hematocrito 35-55%.',
      vacunacion: 'Según especie y país: poliomavirus (psitácidas jóvenes), enfermedad de Newcastle (aves de corral, zoos), poxvirus (pavo real). No hay vacunas universales para aves ornamentales. Cuarentena 30-45 días obligatoria para aves nuevas.',
      vacunacion_detallada: ['Poliomavirus: psitácidas a las 4, 6 y 8 semanas (si disponible)', 'Newcastle: aves de corral según normativa local', 'Cuarentena: 30-45 días antes de introducir al grupo', 'Test psitacosis (Chlamydia) antes de mezclar'],
      desparasitacion: 'Interna: coproscopia semestral, fenbendazol 20-50 mg/kg x 5 días si positiva. Externa: ivermectina 0,2 mg/kg (¡contraindicada en periquitos australianos!). Ácaros: selamectina tópica. Limpieza y desinfección de jaula semanal.',
      revisiones: 'Examen anual por veterinario AAV (Association of Avian Veterinarians). Peso semanal en casa. Analítica anual (hemograma, bioquímica, psitacosis, PBFD en cacatúas). Radiografía si respiratorio. Examen oral (psitacosis, candidiasis).',
      cribado_salud_recomendado: ['Psitacosis (Chlamydia psittaci): PCR al ingreso', 'PBFD (circovirus): test ADN en cacatúas', 'Poliomavirus: PCR en crías de psitácidas', 'Peso semanal: báscula digital en gramos', 'Coproscopia semestral', 'Radiografía torácica anual en especies grandes'],
      nutricion_clinica: 'Dieta formulada (pellets) 60-80% + verduras frescas 20-30% + frutas con moderación. Evitar: aguacate (persina, tóxico), chocolate, cafeína, sal. Loros grandes: dieta baja en grasa. Néctar para lorikeets. Calcio/vitamina A según especie.',
      manejo_clinico: 'Vuelo diario en ambiente seguro. Baños regulares (humedad). Luz UVB 10-12 h/día. Enriquecimiento (juguetes destructibles, foraging). Ventilación sin corrientes. Temperatura ambiente 20-27 °C. Mascarilla al limpiar jaulas (zoonosis psitacosis).',
      contraindicaciones_especie: ['Ivermectina en periquitos australianos (Parakeets)', 'Doxiciclina con lácteos (quelación)', 'Cobre en aves sensibles', 'Aspirina (metabolismo lento, toxicidad)'],
      fuentes_bibliograficas: ['Association of Avian Veterinarians (AAV) Guidelines', 'OIE Terrestrial Manual — Avian', 'Manual of Exotic Pet Practice — Avian', 'LafeberVet Clinical Resources']
    },
    'conejos' => {
      parametros_salud: 'Constantes lagomorfas: T° 38,5-40,0 °C (¡<38 °C = urgencia!). FC 180-250 lpm. FR 30-60 rpm. TRC 1-2 s. DEBE producir heces continuamente (¿50-300 heces/día). Dolor: postura encorvada, bruxismo, ojos semicerrados. Glucemia 75-150 mg/dL.',
      vacunacion: 'RHDV1/RHDV2 (calicivirus hemorrágico): vacuna mensual en zonas endémicas (Europa, Australia). Mixomatosis: vacuna anual en zonas endémicas (Europa, Australia). No disponible en todas las regiones — consultar veterinario local.',
      vacunacion_detallada: ['RHDV2: cada 6-12 meses según vacuna y zona', 'Mixomatosis: anual en zonas endémicas', 'Primera dosis: desde las 5-10 semanas', 'Refuerzo según prospecto del fabricante'],
      desparasitacion: 'Interna: coproscopia anual, fenbendazol 20 mg/kg x 5 días si positiva. Externa: selamectina si pulgas/ácaros. Prevención de E. cuniculi: higiene, evitar orina de roedores silvestres.',
      revisiones: 'Anual por veterinario de exóticos. Control dental cada 6 meses (maloclusión es la enfermedad #1). Peso semanal. Analítica anual (bioquímica, E. cuniculi serología).',
      cribado_salud_recomendado: ['Dental: examen de incisivos y molares cada 6 meses', 'E. cuniculi: serología anual', 'Peso: báscula semanal', 'Radiografía dental anual', 'Palpación abdominal mensual'],
      nutricion_clinica: 'Heno (timothy, césped) LIBRE 24/7 (>80% dieta). Pellets 1/4 taza/2,25 kg/día máximo. Verduras frescas 1-2 tazas/día (sin iceberg). Frutas como premio (<5%). Agua en botella limpia diariamente. Calcio del heno, no suplementar sin indicación.',
      manejo_clinico: 'Nunca levantar por las orejas. Superficie antideslizante. Escondite obligatorio. Compañía de su especie (castrados). Temperatura 15-22 °C (sensibles al calor >25 °C). Sin baños (estrés). Cepillado en mudas.',
      contraindicaciones_especie: ['Antibióticos orales de amplio espectro sin motilidad GI (clindamicina, lincomicina, ampicilina oral → estasis fatal)', 'Corticoides (inmunosupresión + estasis)', 'Aspirina (úlcera gástrica)', 'Catnip y plantas tóxicas'],
      fuentes_bibliograficas: ['BSAVA Manual of Rabbit Medicine, 2nd ed.', 'House Rabbit Society — Health', 'World Rabbit Science Association', 'WSAVA Exotic Companion Mammal Guidelines']
    },
    'equinos' => {
      parametros_salud: 'Constantes equinas: T° 37,2-38,3 °C (fiebre >38,5 °C, >39,5 °C = urgencia). FC 28-44 lpm en reposo (>60 = dolor/cólico/shock). FR 8-16 rpm (>30 = dolor respiratorio). TRC <2 s. Motilidad intestinal: 1-3 ruidos/cuadrante/min. Mucosas rosadas, húmedas.',
      vacunacion: 'Tétanos: anual (toxoide). Influenza + rinoneumonitis (EHV-1/4): cada 6 meses si contacto con otros equinos. Rabia: anual en zonas endémicas. Potros: serie inicial desde 4-6 meses. West Nile: según zona geográfica.',
      vacunacion_detallada: ['Potros: tétanos, influenza, EHV a los 4-6 meses (x3 con intervalo 4 semanas)', 'Adultos: tétanos anual', 'Influenza + EHV: cada 6 meses (competición, pensión)', 'Rabia: anual según zona', 'West Nile: anual en zonas endémicas'],
      desparasitacion: 'Programa estratégico basado en coproscopia (no calendario fijo). Ivermectina 0,2 mg/kg o moxidectina. Rotar principios activos (benzimidazoles, pirantel, ivermectina). Fecal egg count reduction test (FECRT) para detectar resistencias.',
      revisiones: 'Herraje cada 6-8 semanas. Dental anual (más frecuente en mayores de 15). Examen clínico semestral. Analítica anual (bioquímica, CBC). Ecografía tendinosa si deporte de alto nivel.',
      cribado_salud_recomendado: ['Dental: examen anual con speculum', 'Oftalmología: examen anual (uveítis, cataratas)', 'Ortopedia: radiografías si cojera recurrente', 'Cardiología: auscultación anual (soplos)', 'Coproscopia: 2-4 veces/año', 'Herraje: cada 6-8 semanas'],
      nutricion_clinica: 'Forraje de calidad como base (>1,5% peso corporal en heno). Concentrado según trabajo (no sobrealimentar → cólico, laminitis). Agua limpia abundante (no congelada en invierno). Electrolytos post-ejercicio intenso. Evitar pasto alto en fructanos (laminitis).',
      manejo_clinico: 'Botiquín de emergencia: termómetro, estetoscopio, sonda nasogástrica, pinzas. Conocer signos de cólico. Plan de evacuación veterinaria. Registro de peso y condición corporal (BCS 4-6/9). Descanso post-ejercicio.',
      contraindicaciones_especie: ['Más de 1 dosis de flunixin (úlcera GI/renal)', 'Fenilbutazona prolongada (úlcera, aplasia medular)', 'Dexametasona en gestantes (aborto)', 'Laxantes sin diagnóstico de cólico'],
      fuentes_bibliograficas: ['AAEP (American Association of Equine Practitioners) Guidelines', 'BSAVA Manual of Equine Practice', 'Merck Veterinary Manual — Equine']
    },
    'peces' => {
      parametros_salud: 'Parámetros de agua (más importantes que signos vitales): Temperatura según especie (tropical 24-28 °C, goldfish 18-22 °C). pH 6,5-7,5 (según especie). Amoniaco NH3 = 0 ppm (tóxico >0,25). Nitrito NO2 = 0 ppm. Nitrato NO3 <40 ppm. Oxígeno disuelto >5 mg/L.',
      vacunacion: 'No existen vacunas para peces ornamentales. Prevención mediante cuarentena, calidad de agua y bioseguridad.',
      vacunacion_detallada: ['Cuarentena: 2-4 semanas en acuario hospital', 'Baño profiláctico opcional con sal 1-3 g/L', 'Test de parásitos con microscopio antes de introducir'],
      desparasitacion: 'Cuarentena 2-4 semanas para peces nuevos. Baño profiláctico con praziquantel o formalina. No medicar acuario principal sin diagnóstico. Tratar en acuario hospital separado.',
      revisiones: 'Test de agua semanal (amoniaco, nitrito, nitrato, pH). Inspección diaria de aletas, ojos, comportamiento. Limpieza de filtro mensual. Cambio de agua 20-30% semanal.',
      cribado_salud_recomendado: ['Test de agua semanal (tiras reactivas + líquido de ensayo)', 'Microscopio: raspado de piel/aletas si síntomas', 'Peso/longitud mensual', 'Inspección de branquias (color, movimiento)', 'Cuarentena obligatoria peces nuevos'],
      nutricion_clinica: 'Alimento específico por especie (tamaño de partícula adecuado). Frecuencia: 1-2 veces/día, lo que coman en 2-3 min. Ayuno 1 día/semana opcional. Variedad: flocos, pellets, congelado, vivo (con moderación). No sobrealimentar (amoniaco).',
      manejo_clinico: 'Aclimatación: flotar bolsa 15-20 min, añadir agua del acuario gradualmente. Nunca liberar peces a ecosistemas naturales. Red de peces para captura segura. Acuario hospital para tratamientos. Remover carbón del filtro durante medicación.',
      contraindicaciones_especie: ['Cobre con invertebrados y peces sin escamas', 'Formalina con escala-less (corydoras, loaches)', 'Cambios bruscos de T° (>2 °C/hora)', 'Mezclar peces incompatibles (agresión, parásitos)'],
      fuentes_bibliograficas: ['FAO Fish Health Manual', 'UF/IFAS Extension — Ornamental Fish', 'Aquarium Science Association', 'Fish Vet Group Clinical Resources']
    },
    'bovinos' => {
      parametros_salud: 'Constantes bovinas: T° 38,0-39,3 °C (fiebre >39,5 °C). FC 60-80 lpm. FR 15-35 rpm. Rumia: 50-70 masticaciones/bolo. TRC 1-2 s.',
      vacunacion: 'Clostridiales anual. IBR/BVD según manejo. Leptospirosis y brucelosis según normativa.',
      vacunacion_detallada: ['Terneros 2-4 meses: clostridiales', '4-6 meses: refuerzo + IBR/BVD', 'Anual: clostridiales + respiratorio'],
      desparasitacion: 'Programa estratégico con coproscopia. Ivermectina 0,2 mg/kg. Rotar anthelmínticos.',
      revisiones: 'Inspección diaria. Revisión veterinaria mensual en lactación. Pezuñas trimestral.',
      cribado_salud_recomendado: ['CMT mensual en lactación', 'Locomotion score trimestral', 'BCS trimestral', 'Coproscopia 2-4 veces/año'],
      nutricion_clinica: 'Forraje de calidad + concentrado según producción. Agua 60-100 L/día en lactante.',
      manejo_clinico: 'Identificación individual. Bioseguridad. Registros de producción y tratamientos.',
      contraindicaciones_especie: ['Respetar periodos de retirada de antibióticos en leche/carne'],
      fuentes_bibliograficas: ['National Mastitis Council', 'OIE Terrestrial Manual — Bovine', 'FAO Animal Health Manual']
    },
    'porcinos' => {
      parametros_salud: 'T° 38,5-39,5 °C. FC 70-90 lpm. FR 15-30 rpm. Consumo de agua 2-3× pienso.',
      vacunacion: 'Mycoplasma, PCV2, parvovirus, erisipela según sistema productivo.',
      vacunacion_detallada: ['Lechones 3-4 sem: Mycoplasma + PCV2', '6-8 sem: erisipela + parvovirus', 'Anual: erisipela en reproductoras'],
      desparasitacion: 'Ivermectina 0,3 mg/kg cada 3-4 meses. Control de moscas y roedores.',
      revisiones: 'Inspección diaria. Revisión veterinaria mensual.',
      cribado_salud_recomendado: ['Monitorización respiratoria', 'Índices de conversión', 'Cojera mensual', 'Bioseguridad de reemplazos'],
      nutricion_clinica: 'Pienso por fase. Agua fresca permanente. Control de temperatura en naves.',
      manejo_clinico: 'Bioseguridad estricta. Ventilación adecuada. Registros sanitarios.',
      contraindicaciones_especie: ['Medicar lote completo sin diagnóstico'],
      fuentes_bibliograficas: ['AASV Guidelines', 'OIE Terrestrial Manual — Swine', 'Merck Veterinary Manual — Swine']
    },
    'ovinos' => {
      parametros_salud: 'T° 38,5-40,0 °C. FC 70-90 lpm. FR 12-20 rpm. FAMACHA para anemia.',
      vacunacion: 'CD-T anual. Ectima y rabia según zona.',
      vacunacion_detallada: ['Corderos 6-8 sem: CD-T', '12 sem: refuerzo', 'Anual: CD-T en rebaño'],
      desparasitacion: 'FAMACHA + coproscopia. Desparasitar selectivamente. Rotar anthelmínticos.',
      revisiones: 'Inspección semanal. Pezuñas cada 6-8 semanas.',
      cribado_salud_recomendado: ['FAMACHA mensual', 'Coproscopia estacional', 'BCS trimestral', 'Pezuñas cada 6-8 semanas'],
      nutricion_clinica: 'Pastoreo + suplemento en gestación/lactación. Sales minerales.',
      manejo_clinico: 'Esquileo anual. Identificación. Refugio en mal tiempo.',
      contraindicaciones_especie: ['Desparasitar todo el rebaño sin FAMACHA'],
      fuentes_bibliograficas: ['FAO Sheep Health Manual', 'OIE Terrestrial Manual — Ovine']
    },
    'caprinos' => {
      parametros_salud: 'T° 38,5-40,5 °C. FC 70-90 lpm. FR 15-30 rpm. FAMACHA (cuidado en razas negras).',
      vacunacion: 'CD-T anual. Rabia según zona.',
      vacunacion_detallada: ['Cabritas 6-8 sem: CD-T', '12 sem: refuerzo', 'Anual: CD-T'],
      desparasitacion: 'FAMACHA + coproscopia. Desparasitación selectiva.',
      revisiones: 'Control de ubre semanal. Pezuñas cada 6-8 semanas.',
      cribado_salud_recomendado: ['FAMACHA mensual', 'CMT en lactación', 'Pezuñas cada 6-8 semanas', 'Coproscopia estacional'],
      nutricion_clinica: 'Pastoreo + suplemento en lactación. Sales minerales. Agua limpia.',
      manejo_clinico: 'Refugio climático. Vigilar bloqueo urinario en machos.',
      contraindicaciones_especie: ['Concentrado sin adaptación (timpanismo)'],
      fuentes_bibliograficas: ['American Consortium for Small Ruminant Parasite Control', 'OIE Terrestrial Manual — Caprine']
    },
    'camelidos' => {
      parametros_salud: 'T° 37,5-39,0 °C. FC 60-90 lpm. FR 10-30 rpm. Sensibles al calor >27 °C.',
      vacunacion: 'CD-T según zona. Consultar veterinario de camélidos.',
      vacunacion_detallada: ['Crías 3-4 meses: CD-T', '6 meses: refuerzo', 'Anual: CD-T'],
      desparasitacion: 'Coproscopia + FAMACHA. Ivermectina estratégica.',
      revisiones: 'Semestral. Peso trimestral. Uñas cada 2-3 meses.',
      cribado_salud_recomendado: ['FAMACHA mensual', 'Peso trimestral', 'Meningeal worm en zonas endémicas', 'Condición corporal trimestral'],
      nutricion_clinica: 'Pasto + heno. Suplemento mineral. Agua limpia.',
      manejo_clinico: 'Sombra en verano. Esquileo anual. Manejo con mínimo estrés.',
      contraindicaciones_especie: ['Calor extremo sin sombra'],
      fuentes_bibliograficas: ['International Camelid Institute', 'Merck Veterinary Manual — Camelids']
    },
    'roedores' => {
      parametros_salud: 'T° 37,5-39,5 °C. FC 250-600 lpm. FR 40-120 rpm. Ocultan enfermedad.',
      vacunacion: 'Hurón: moquillo y rabia obligatorios (Purevax Ferret). Otros: sin vacunas rutinarias.',
      vacunacion_detallada: ['Hurón: Purevax Ferret anual + rabia', 'Cuarentena 14 días para nuevos'],
      desparasitacion: 'Interna si coproscopia positiva. Higiene de jaula semanal.',
      revisiones: 'Anual por veterinario de exóticos. Peso quincenal.',
      cribado_salud_recomendado: ['Peso quincenal', 'Dientes mensual', 'Heces diarias', 'Hurón: glucosa y adrenal anual'],
      nutricion_clinica: 'Dieta específica por especie. Cobayas: vitamina C obligatoria.',
      manejo_clinico: 'Jaula espaciosa. Temperatura 18-24 °C. Enriquecimiento.',
      contraindicaciones_especie: ['Vacuna canina en hurones', 'Cedar bedding', 'Aspirina'],
      fuentes_bibliograficas: ['BSAVA Manual of Rodents and Ferrets', 'AEMV Guidelines', 'Merck Veterinary Manual — Small Mammals']
    },
    'reptiles' => {
      parametros_salud: 'Ectotermos: T° corporal = ambiente. Gradiente térmico obligatorio. Vigilar muda, apetito, heces.',
      vacunacion: 'No hay vacunas comerciales. Prevención por cuarentena e higiene.',
      vacunacion_detallada: ['Cuarentena 60-90 días', 'Coproscopia al ingreso'],
      desparasitacion: 'Coproscopia anual. Fenbendazol si positivo.',
      revisiones: 'Anual por veterinario de exóticos. Peso mensual.',
      cribado_salud_recomendado: ['Peso mensual', 'Coproscopia anual', 'Muda completa', 'Parámetros T°/humedad/UVB semanal'],
      nutricion_clinica: 'Herbívoros: verduras + calcio. Carnívoros: presa entera. Ca:P 2:1.',
      manejo_clinico: 'Gradiente térmico + UVB. Humedad según especie. Manejo mínimo.',
      contraindicaciones_especie: ['UVB insuficiente', 'Sobredosis vitamina D3', 'Hibernación forzada'],
      fuentes_bibliograficas: ['BSAVA Manual of Reptiles', 'ARAV Guidelines', 'Merck Veterinary Manual — Reptiles']
    }
  }.freeze

  # Perfiles específicos por raza (predisposiciones genéticas documentadas)
  BREED_OVERRIDES = {
    'chihuahua' => {
      predisposiciones_geneticas: ['Hipoglucemia (cachorros y adultos toy)', 'Luxación de rótula (grado I-IV)', 'Colapso traqueal', 'Hidrocefalia congénita', 'Shunt portosistémico (PSS)', 'Enfermedad periodontal (apiñamiento dental)'],
      emergencias: 'Hipoglucemia con convulsiones (miel en encías + urgencia), prolapso ocular (mantener húmedo + urgencia), colapso traqueal con cianosis, golpe de calor (braquicéfalo), fracturas por caídas.'
    },
    'labrador' => {
      predisposiciones_geneticas: ['Displasia de cadera y codo (poligénica)', 'Obesidad (gen POMC)', 'Atrofia progresiva de retina (APR)', 'Ejercicio Induced Collapse (EIC)', 'Torsión gástrica (pecho profundo)', 'Enfermedad del músculo (CMS)'],
      emergencias: 'Torsión gástrica (distensión + arcadas → cirugía inmediata), EIC post-ejercicio (colapso, hipertermia), intoxicación por cuerpos extraños (ingiere todo), golpe de calor.'
    },
    'pastor_aleman' => {
      predisposiciones_geneticas: ['Displasia de cadera y codo', 'Mielopatía degenerativa (DM)', 'Cardiomiopatía dilatada', 'Pancreatitis exocrina (EPI)', 'Hemangiosarcoma esplénico', 'MDR1 (sensibilidad a ivermectina)'],
      emergencias: 'Parálisis progresiva de patas traseras (DM), hemorragia abdominal (hemangiosarcoma), torsión gástrica, reacción a fármacos MDR1 (ivermectina, loperamida).'
    },
    'persa' => {
      predisposiciones_geneticas: ['Enfermedad renal poliquística (PKD1)', 'Enfermedad periodontal severa', 'Displasia epifisaria (dwarfism)', 'Cardiomiopatía hipertrófica', 'Cálculos urinarios (oxalato)', 'Problemas respiratorios (braquicefalia)'],
      emergencias: 'Dificultad respiratoria aguda (síndrome braquicefálico), obstrucción urinaria, insuficiencia renal aguda, úlceras corneales por exoftalmia.'
    },
    'maine_coon' => {
      predisposiciones_geneticas: ['Cardiomiopatía hipertrófica (MyBPC3-A31P)', 'Displasia de cadera', 'Atrofia muscular espinal (SMA)', 'Policitemia', 'Enfermedad periodontal'],
      emergencias: 'Parálisis súbita de patas traseras (TEA por HCM), dificultad respiratoria (ICC), muerte súbita (HCM no diagnosticada).'
    },
    'sphynx' => {
      predisposiciones_geneticas: ['Cardiomiopatía hipertrófica', 'Dermatitis seborreica', 'Urticaria pigmentosa', 'Deficiencia de vitamina K dependiente', 'Hipotermia', 'Quemaduras solares'],
      emergencias: 'Hipotermia (<38 °C), quemaduras solares, HCM con ICC, deshidratación cutánea severa.'
    },
    'conejo_angora' => {
      predisposiciones_geneticas: ['Tricobezoares (pelo largo)', 'Pododermatitis (pododinia)', 'Maloclusión dental', 'Estasis gastrointestinal', 'Pasteurelosis'],
      emergencias: 'Estasis GI (>6 h sin heces), tricobezoar obstructivo, pododermatitis ulcerativa, maloclusión con anorexia.'
    }
  }.freeze

  def self.enrich_breed(breed, animal_id, size = 'mediana')
    b = breed.dup
    species = SPECIES_PROFILES[animal_id] || {}
    override = BREED_OVERRIDES[b['id']] || {}

    species.each do |key, value|
      b[key.to_s] = value
    end

    override.each { |key, value| b[key.to_s] = value }

    b['nutricion_detallada'] = BreedNutritionProfiles.generate(b, animal_id, size)

    # Derivar predisposiciones de las enfermedades asignadas si no hay override
    unless b['predisposiciones_geneticas']
      b['predisposiciones_geneticas'] = (b['enfermedades'] || []).map { |e| e['nombre'] }.first(6)
    end

    # Mejorar descripción si es genérica
    if b['descripcion']&.match?(/requiere un tutor informado/)
      b['descripcion'] = "#{b['nombre']} es una raza de #{animal_id} originaria de #{b['origen']}. #{b['caracteristicas']&.split('.')&.first}. Peso habitual: #{b['peso']}. Esperanza de vida: #{b['esperanza_vida']}. Temperamento: #{b['temperamento']}."
    end

    b
  end
end
