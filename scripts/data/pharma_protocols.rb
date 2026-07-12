# frozen_string_literal: true

# Generador de protocolo_farmacologico por especie y enfermedad
module PharmaProtocols
  DRUGS = {
    perros: {
      meloxicam: { principio_activo: 'Meloxicam', nombre_comercial: 'Metacam', dosis_mg_kg: '0,1 mg/kg', via: 'Oral', frecuencia: 'Cada 24 h', duracion: '5-7 días', notas: 'Con alimento. Contraindicado en insuficiencia renal. Usar gastroprotector en tratamientos prolongados.' },
      carprofeno: { principio_activo: 'Carprofeno', nombre_comercial: 'Rimadyl', dosis_mg_kg: '4 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: '7-10 días', notas: 'Evitar en hepatopatías. Monitorizar enzimas hepáticas en uso crónico.' },
      amoxicilina_clav: { principio_activo: 'Amoxicilina + Ácido clavulánico', nombre_comercial: 'Synulox', dosis_mg_kg: '12,5 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: '10-14 días', notas: 'Completar el ciclo antibiótico. Seguro en la mayoría de razas.' },
      cephalexin: { principio_activo: 'Cefalexina', nombre_comercial: 'Rilexine', dosis_mg_kg: '22 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: '10-14 días', notas: 'Primera línea en infecciones cutáneas. Ajustar en insuficiencia renal severa.' },
      gabapentina: { principio_activo: 'Gabapentina', nombre_comercial: 'Neurontin', dosis_mg_kg: '10 mg/kg', via: 'Oral', frecuencia: 'Cada 8-12 h', duracion: 'Según respuesta clínica', notas: 'Útil en dolor neuropático. Reducir dosis gradualmente al suspender.' },
      omeprazol: { principio_activo: 'Omeprazol', nombre_comercial: 'Losec', dosis_mg_kg: '1 mg/kg', via: 'Oral', frecuencia: 'Cada 24 h', duracion: '14-28 días', notas: 'Gastroprotector con AINE. Administrar 30 min antes de la comida.' },
      prednisolona: { principio_activo: 'Prednisolona', nombre_comercial: 'Prednisolona genérica', dosis_mg_kg: '0,5-1 mg/kg', via: 'Oral', frecuencia: 'Cada 12-24 h', duracion: '5-10 días con descenso', notas: 'Descenso gradual obligatorio. Contraindicado con infecciones no controladas.' },
      enalapril: { principio_activo: 'Enalapril', nombre_comercial: 'Enacard', dosis_mg_kg: '0,5 mg/kg', via: 'Oral', frecuencia: 'Cada 12-24 h', duracion: 'Crónico', notas: 'Monitorizar creatinina y potasio. IECA de elección en insuficiencia cardíaca.' },
      pimobendan: { principio_activo: 'Pimobendan', nombre_comercial: 'Vetmedin', dosis_mg_kg: '0,25 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: 'Crónico', notas: 'Inotrópico positivo. Administrar 1 h antes de la comida.' },
      furosemida: { principio_activo: 'Furosemida', nombre_comercial: 'Lasix', dosis_mg_kg: '2 mg/kg', via: 'Oral/IV', frecuencia: 'Cada 8-12 h', duracion: 'Según congestión', notas: 'Monitorizar electrolitos y función renal. Riesgo de deshidratación.' },
      tramadol: { principio_activo: 'Tramadol', nombre_comercial: 'Tramadol genérico', dosis_mg_kg: '3-5 mg/kg', via: 'Oral', frecuencia: 'Cada 8-12 h', duracion: '5-10 días', notas: 'Analgesia de segundo escalón. Puede causar sedación leve.' },
      maropitant: { principio_activo: 'Maropitant', nombre_comercial: 'Cerenia', dosis_mg_kg: '2 mg/kg', via: 'Oral/SC', frecuencia: 'Cada 24 h', duracion: '3-5 días', notas: 'Antiemético y antitusígeno. Eficaz en vómitos por múltiples causas.' },
      clindamicina: { principio_activo: 'Clindamicina', nombre_comercial: 'Antirobe', dosis_mg_kg: '11 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: '7-14 días', notas: 'Excelente penetración ósea. Primera línea en infecciones dentales.' },
      levotiroxina: { principio_activo: 'Levotiroxina sódica', nombre_comercial: 'Thyforon', dosis_mg_kg: '20 mcg/kg', via: 'Oral', frecuencia: 'Cada 24 h', duracion: 'De por vida', notas: 'Administrar en ayunas. Control T4 cada 4-6 semanas al inicio.' },
      fenobarbital: { principio_activo: 'Fenobarbital', nombre_comercial: 'Garoin', dosis_mg_kg: '2,5 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: 'Crónico', notas: 'Monitorizar niveles séricos. Inductor enzimático hepático.' },
      dextrosa: { principio_activo: 'Dextrosa 5%', nombre_comercial: 'Suero glucosado', dosis_mg_kg: '2-5 ml/kg', via: 'IV', frecuencia: 'Bolo seguido de infusión', duracion: 'Hasta estabilización', notas: 'Urgencia en hipoglucemia. Monitorizar glucosa cada 30-60 min.' },
      condroprotector: { principio_activo: 'Glucosamina + Condroitina', nombre_comercial: 'Cosequin', dosis_mg_kg: '15-30 mg/kg', via: 'Oral', frecuencia: 'Cada 24 h', duracion: 'Crónico', notas: 'Suplemento de soporte articular. Efecto a partir de 4-6 semanas.' },
      butorfanol: { principio_activo: 'Butorfanol', nombre_comercial: 'Torbugesic', dosis_mg_kg: '0,2-0,4 mg/kg', via: 'SC/IV', frecuencia: 'Cada 6-8 h', duracion: '2-3 días', notas: 'Antitusígeno y analgesia leve. Puede causar sedación.' }
    },
    gatos: {
      meloxicam: { principio_activo: 'Meloxicam', nombre_comercial: 'Metacam Felino', dosis_mg_kg: '0,05 mg/kg', via: 'Oral', frecuencia: 'Cada 24 h', duracion: '3-5 días máximo', notas: 'Dosis felina estricta. Contraindicado en deshidratación o IR.' },
      amoxicilina_clav: { principio_activo: 'Amoxicilina + Ácido clavulánico', nombre_comercial: 'Synulox', dosis_mg_kg: '12,5 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: '10-14 días', notas: 'Suspensión palatable. Completar ciclo antibiótico.' },
      buprenorfina: { principio_activo: 'Buprenorfina', nombre_comercial: 'Vetergesic', dosis_mg_kg: '0,02 mg/kg', via: 'Oral transmucosa', frecuencia: 'Cada 8-12 h', duracion: '3-7 días', notas: 'Analgesia opioide de elección en gatos. Absorción bucal.' },
      prednisolona: { principio_activo: 'Prednisolona', nombre_comercial: 'Prednisolona genérica', dosis_mg_kg: '1-2 mg/kg', via: 'Oral', frecuencia: 'Cada 12-24 h', duracion: '5-10 días con descenso', notas: 'Usar prednisolona, no prednisona (conversión hepática deficiente en gatos).' },
      enalapril: { principio_activo: 'Enalapril', nombre_comercial: 'Enacard', dosis_mg_kg: '0,25-0,5 mg/kg', via: 'Oral', frecuencia: 'Cada 12-24 h', duracion: 'Crónico', notas: 'Monitorizar función renal. IECA en cardiopatía felina.' },
      pimobendan: { principio_activo: 'Pimobendan', nombre_comercial: 'Vetmedin', dosis_mg_kg: '1,25 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: 'Crónico', notas: 'Aprobado en HCM felina. Mejora contractilidad.' },
      clopidogrel: { principio_activo: 'Clopidogrel', nombre_comercial: 'Plavix', dosis_mg_kg: '18,75 mg total/día', via: 'Oral', frecuencia: 'Cada 24 h', duracion: 'Crónico', notas: 'Antiagregante en riesgo de tromboembolismo cardíaco.' },
      maropitant: { principio_activo: 'Maropitant', nombre_comercial: 'Cerenia', dosis_mg_kg: '1 mg/kg', via: 'Oral/SC', frecuencia: 'Cada 24 h', duracion: '3-5 días', notas: 'Antiemético seguro en gatos.' },
      clindamicina: { principio_activo: 'Clindamicina', nombre_comercial: 'Antirobe', dosis_mg_kg: '11 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: '7-14 días', notas: 'Infecciones dentales y abscesos.' },
      insulina: { principio_activo: 'Insulina glargina', nombre_comercial: 'Lantus', dosis_mg_kg: '0,25-0,5 UI/kg', via: 'SC', frecuencia: 'Cada 12 h', duracion: 'Crónico', notas: 'Primera línea en diabetes felina. Monitorizar curva glucémica.' },
      famotidina: { principio_activo: 'Famotidina', nombre_comercial: 'Pepcid', dosis_mg_kg: '0,5-1 mg/kg', via: 'Oral', frecuencia: 'Cada 24 h', duracion: '14-28 días', notas: 'Gastroprotector. Seguro en gatos.' },
      doxiciclina: { principio_activo: 'Doxiciclina', nombre_comercial: 'Doxirobe', dosis_mg_kg: '5 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: '14-21 días', notas: 'Administrar con agua. Evitar en cachorros <6 meses (perros).' },
      lactulosa: { principio_activo: 'Lactulosa', nombre_comercial: 'Duphalac', dosis_mg_kg: '0,5 ml/kg', via: 'Oral', frecuencia: 'Cada 8-12 h', duracion: 'Según respuesta', notas: 'Laxante osmótico en megacolon y encefalopatía hepática.' },
      gabapentina: { principio_activo: 'Gabapentina', nombre_comercial: 'Neurontin', dosis_mg_kg: '5-10 mg/kg', via: 'Oral', frecuencia: 'Cada 8-12 h', duracion: 'Según respuesta', notas: 'Dolor crónico y ansiedad. Ajustar en insuficiencia renal.' }
    },
    aves: {
      enrofloxacina: { principio_activo: 'Enrofloxacina', nombre_comercial: 'Baytril', dosis_mg_kg: '10-15 mg/kg', via: 'Oral/IM', frecuencia: 'Cada 12 h', duracion: '10-14 días', notas: 'Fluoroquinolona de elección en aves. Evitar en polluelos en crecimiento.' },
      doxiciclina: { principio_activo: 'Doxiciclina', nombre_comercial: 'Doxirobe', dosis_mg_kg: '25-50 mg/kg', via: 'Oral', frecuencia: 'Cada 12-24 h', duracion: '21-45 días', notas: 'Primera línea en psitacosis (Chlamydia). Tratamiento prolongado obligatorio.' },
      itraconazol: { principio_activo: 'Itraconazol', nombre_comercial: 'Sporanox', dosis_mg_kg: '10 mg/kg', via: 'Oral', frecuencia: 'Cada 24 h', duracion: '21-60 días', notas: 'Antifúngico en aspergilosis. Monitorizar función hepática.' },
      meloxicam: { principio_activo: 'Meloxicam', nombre_comercial: 'Metacam', dosis_mg_kg: '0,5-1 mg/kg', via: 'Oral/IM', frecuencia: 'Cada 24 h', duracion: '3-5 días', notas: 'AINE en aves. Usar dosis conservadora.' },
      ivermectina: { principio_activo: 'Ivermectina', nombre_comercial: 'Ivomec', dosis_mg_kg: '0,2 mg/kg', via: 'Oral/Tópica', frecuencia: 'Dosis única, repetir a los 10-14 días', duracion: '2 dosis', notas: 'Contraindicada en algunas especies (collies, periquitos australianos). Verificar especie.' },
      nystatin: { principio_activo: 'Nistatina', nombre_comercial: 'Mycostatin', dosis_mg_kg: '100.000 UI/kg', via: 'Oral', frecuencia: 'Cada 8-12 h', duracion: '7-14 días', notas: 'Antifúngico tópico/bucal en candidiasis. No absorción sistémica.' },
      amphotericin_b: { principio_activo: 'Anfotericina B', nombre_comercial: 'Fungizone', dosis_mg_kg: '1 mg/kg', via: 'Nebulización', frecuencia: 'Cada 12-24 h', duracion: '14-21 días', notas: 'Nebulización en aspergilosis respiratoria. Monitorizar función renal.' },
      metronidazol: { principio_activo: 'Metronidazol', nombre_comercial: 'Flagyl', dosis_mg_kg: '25-50 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: '7-10 días', notas: 'Giardia y anaerobios. Neurotoxicidad en dosis altas.' },
      calcium_gluconate: { principio_activo: 'Gluconato cálcico', nombre_comercial: 'Calcio inyectable', dosis_mg_kg: '50-100 mg/kg', via: 'IM/IV lento', frecuencia: 'Según necesidad', duracion: 'Urgencia', notas: 'Hipocalcemia en puesta (egg binding). Monitorizar ECG.' },
      oxytocin: { principio_activo: 'Oxitocina', nombre_comercial: 'Syntocinon', dosis_mg_kg: '1-2 UI/kg', via: 'IM', frecuencia: 'Dosis única', duracion: 'Urgencia', notas: 'Retención de huevo. Solo si no hay obstrucción.' }
    },
    equinos: {
      flunixin: { principio_activo: 'Flunixin meglumine', nombre_comercial: 'Finadyne', dosis_mg_kg: '1,1 mg/kg', via: 'IV/IM', frecuencia: 'Cada 12-24 h', duracion: '3-5 días', notas: 'AINE de elección en cólico. Máximo 5 días consecutivos.' },
      phenylbutazone: { principio_activo: 'Fenilbutazona', nombre_comercial: 'Equipalazone', dosis_mg_kg: '4,4 mg/kg', via: 'Oral/IV', frecuencia: 'Cada 12 h', duracion: '5-7 días', notas: 'Laminitis y dolor musculoesquelético. Riesgo de úlcera gástrica.' },
      omeprazol: { principio_activo: 'Omeprazol', nombre_comercial: 'GastroGard', dosis_mg_kg: '4 mg/kg', via: 'Oral', frecuencia: 'Cada 24 h', duracion: '28 días', notas: 'Úlcera gástrica. Formulación equina de liberación entérica.' },
      penicillin: { principio_activo: 'Penicilina procainica', nombre_comercial: 'Penicilina equina', dosis_mg_kg: '22.000 UI/kg', via: 'IM', frecuencia: 'Cada 12 h', duracion: '7-10 días', notas: 'Infecciones bacterianas. Rotar sitio de inyección.' },
      ceftiofur: { principio_activo: 'Ceftiofur sódico', nombre_comercial: 'Excenel', dosis_mg_kg: '2,2 mg/kg', via: 'IM/IV', frecuencia: 'Cada 24 h', duracion: '5-7 días', notas: 'Respiratorias y uterinas. Cefalosporina de tercera generación.' },
      dexamethasone: { principio_activo: 'Dexametasona', nombre_comercial: 'Fortecortin', dosis_mg_kg: '0,05-0,1 mg/kg', via: 'IV/IM', frecuencia: 'Cada 24 h', duracion: '1-3 días', notas: 'Antiinflamatorio potente. Riesgo de laminitis en uso prolongado.' },
      furosemida: { principio_activo: 'Furosemida', nombre_comercial: 'Lasix', dosis_mg_kg: '1 mg/kg', via: 'IV', frecuencia: 'Cada 8-12 h', duracion: 'Según edema', notas: 'Edema en laminitis aguda. Monitorizar electrolitos.' },
      pergolide: { principio_activo: 'Pergolida', nombre_comercial: 'Prascend', dosis_mg_kg: '2 mcg/kg', via: 'Oral', frecuencia: 'Cada 24 h', duracion: 'Crónico', notas: 'PPID (síndrome de Cushing equino). Control ACTH cada 3 meses.' },
      xylazine: { principio_activo: 'Xilacina', nombre_comercial: 'Rompun', dosis_mg_kg: '0,5-1 mg/kg', via: 'IV/IM', frecuencia: 'Según procedimiento', duracion: 'Uso único', notas: 'Sedación. Antídoto: yohimbina/atipamezol.' },
      tetanus_antitoxin: { principio_activo: 'Antitoxina tetánica', nombre_comercial: 'Tetanus Antitoxin', dosis_mg_kg: '1500 UI mínimo', via: 'IV/IM', frecuencia: 'Dosis única', duracion: 'Urgencia', notas: 'Profilaxis/tratamiento tetanos. Test de sensibilidad previo.' }
    },
    bovinos: {
      flunixin: { principio_activo: 'Flunixin meglumine', nombre_comercial: 'Finadyne', dosis_mg_kg: '2,2 mg/kg', via: 'IV/IM', frecuencia: 'Cada 24 h', duracion: '3 días', notas: 'Fiebre y dolor. Retirada láctea según normativa local.' },
      oxytetracycline: { principio_activo: 'Oxitetraciclina', nombre_comercial: 'Alamycin', dosis_mg_kg: '20 mg/kg', via: 'IM/SC', frecuencia: 'Cada 24 h', duracion: '3-5 días', notas: 'Amplio espectro. Respetar periodo de retirada en carne y leche.' },
      penicillin: { principio_activo: 'Penicilina procainica', nombre_comercial: 'Penicilina bovina', dosis_mg_kg: '22.000 UI/kg', via: 'IM', frecuencia: 'Cada 12-24 h', duracion: '5 días', notas: 'Mastitis y clostridiosis. Rotar sitio de inyección.' },
      ceftiofur: { principio_activo: 'Ceftiofur cristalina', nombre_comercial: 'Excede', dosis_mg_kg: '6,6 mg/kg', via: 'SC', frecuencia: 'Cada 24 h', duracion: '3-5 días', notas: 'BRD y metritis. Acción prolongada.' },
      calcium_iv: { principio_activo: 'Bolo cálcico IV', nombre_comercial: 'Calciject', dosis_mg_kg: '500 ml vaca adulta', via: 'IV lento', frecuencia: 'Dosis única', duracion: 'Urgencia', notas: 'Hipocalcemia posparto. Monitorizar ritmo cardíaco durante infusión.' },
      dinoprost: { principio_activo: 'Dinoprost trometamina', nombre_comercial: 'Lutalyse', dosis_mg_kg: '25 mg total', via: 'IM', frecuencia: 'Según protocolo', duracion: '1-3 dosis', notas: 'Inducción parto o piometra. No usar en gestación deseada.' },
      ivermectina: { principio_activo: 'Ivermectina', nombre_comercial: 'Ivomec', dosis_mg_kg: '0,2 mg/kg', via: 'SC/Oral', frecuencia: 'Dosis única', duracion: 'Según programa', notas: 'Parásitos internos y externos. Rotar anthelmínticos.' },
      meloxicam: { principio_activo: 'Meloxicam', nombre_comercial: 'Metacam Bovino', dosis_mg_kg: '0,5 mg/kg', via: 'IV/SC', frecuencia: 'Dosis única o cada 24 h', duracion: '1-3 días', notas: 'Analgesia posparto y cojera. Aprobado en bovinos.' },
      sulfametoxazole: { principio_activo: 'Sulfametoxazol + Trimetoprim', nombre_comercial: 'Tribrissen', dosis_mg_kg: '15 mg/kg', via: 'IV/IM', frecuencia: 'Cada 24 h', duracion: '3-5 días', notas: 'Diarrea y respiratorias. Asegurar hidratación.' },
      dexamethasone: { principio_activo: 'Dexametasona', nombre_comercial: 'Fortecortin', dosis_mg_kg: '0,02-0,04 mg/kg', via: 'IM/IV', frecuencia: 'Cada 24 h', duracion: '1-3 días', notas: 'Parto prematuro y inflamación. Uso prudente en gestantes.' }
    },
    porcinos: {
      enrofloxacina: { principio_activo: 'Enrofloxacina', nombre_comercial: 'Baytril', dosis_mg_kg: '2,5-5 mg/kg', via: 'IM/Oral', frecuencia: 'Cada 24 h', duracion: '5 días', notas: 'Respiratorias y septicemia. Respetar periodo de retirada.' },
      penicillin: { principio_activo: 'Penicilina procainica', nombre_comercial: 'Penicilina porcina', dosis_mg_kg: '11.000 UI/kg', via: 'IM', frecuencia: 'Cada 24 h', duracion: '3-5 días', notas: 'Erisipela. Tratamiento de elección.' },
      tiamulin: { principio_activo: 'Tiamulina', nombre_comercial: 'Denagard', dosis_mg_kg: '8,8 mg/kg', via: 'Oral/IM', frecuencia: 'Cada 24 h', duracion: '5-7 días', notas: 'Disentería por Brachyspira. Mezclar en agua de bebida.' },
      flunixin: { principio_activo: 'Flunixin meglumine', nombre_comercial: 'Finadyne', dosis_mg_kg: '2,2 mg/kg', via: 'IM', frecuencia: 'Cada 24 h', duracion: '3 días', notas: 'Fiebre y dolor. Aprobado en porcinos.' },
      oxytocin: { principio_activo: 'Oxitocina', nombre_comercial: 'Syntocinon', dosis_mg_kg: '0,5 ml/50 kg', via: 'IM', frecuencia: 'Según parto', duracion: 'Urgencia', notas: 'Inducción de parto. Solo si cervix dilatado.' },
      iron_dextran: { principio_activo: 'Hierro dextrano', nombre_comercial: 'Uniferon', dosis_mg_kg: '200 mg lechón', via: 'IM', frecuencia: 'Dosis única día 1-3', duracion: 'Profilaxis', notas: 'Anemia ferropénica en lechones. Dosis fija por edad.' },
      ivermectina: { principio_activo: 'Ivermectina', nombre_comercial: 'Ivomec Porcino', dosis_mg_kg: '0,3 mg/kg', via: 'Oral/SC', frecuencia: 'Dosis única', duracion: 'Según programa', notas: 'Parásitos internos. Mezclar en pienso.' },
      amoxicillin: { principio_activo: 'Amoxicilina', nombre_comercial: 'Amoxivet', dosis_mg_kg: '15 mg/kg', via: 'IM/Oral', frecuencia: 'Cada 24 h', duracion: '5 días', notas: 'MMA y mastitis. Amplio espectro.' },
      ketoprofen: { principio_activo: 'Ketoprofeno', nombre_comercial: 'Ketofen', dosis_mg_kg: '3 mg/kg', via: 'IM', frecuencia: 'Cada 24 h', duracion: '3 días', notas: 'AINE en cojera y postparto.' }
    },
    conejos: {
      meloxicam: { principio_activo: 'Meloxicam', nombre_comercial: 'Metacam', dosis_mg_kg: '0,3-0,5 mg/kg', via: 'Oral/SC', frecuencia: 'Cada 24 h', duracion: '3-7 días', notas: 'AINE de elección en conejos. Dosis conservadora.' },
      enrofloxacina: { principio_activo: 'Enrofloxacina', nombre_comercial: 'Baytril', dosis_mg_kg: '10 mg/kg', via: 'Oral/SC', via2: 'SC', frecuencia: 'Cada 12-24 h', duracion: '10-14 días', notas: 'Pasteurelosis y E. cuniculi. Usar con precaución en conejos jóvenes.' },
      metoclopramide: { principio_activo: 'Metoclopramida', nombre_comercial: 'Primperan', dosis_mg_kg: '0,5 mg/kg', via: 'Oral/SC', frecuencia: 'Cada 8-12 h', duracion: 'Hasta resolución', notas: 'Procinético en estasis GI. Esencial en urgencias.' },
      simethicone: { principio_activo: 'Simeticona', nombre_comercial: 'Infacol', dosis_mg_kg: '20 mg/kg', via: 'Oral', frecuencia: 'Cada 8-12 h', duracion: '2-3 días', notas: 'Reducción de gas en estasis. Seguro en conejos.' },
      ranitidine: { principio_activo: 'Ranitidina', nombre_comercial: 'Zantac', dosis_mg_kg: '2-5 mg/kg', via: 'Oral/IV', frecuencia: 'Cada 12 h', duracion: '7-14 días', notas: 'Procinético y gastroprotector en conejos.' },
      buprenorfina: { principio_activo: 'Buprenorfina', nombre_comercial: 'Vetergesic', dosis_mg_kg: '0,03-0,06 mg/kg', via: 'SC', frecuencia: 'Cada 6-12 h', duracion: '3-7 días', notas: 'Analgesia opioide. Seguro en conejos.' },
      trimethoprim_sulfa: { principio_activo: 'Trimetoprim + Sulfametoxazol', nombre_comercial: 'Tribrissen', dosis_mg_kg: '30 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: '10-14 días', notas: 'Infecciones bacterianas. Asegurar hidratación.' },
      fenbendazole: { principio_activo: 'Fenbendazol', nombre_comercial: 'Panacur', dosis_mg_kg: '20 mg/kg', via: 'Oral', frecuencia: 'Cada 24 h', duracion: '28 días', notas: 'E. cuniculi y parásitos. Tratamiento prolongado para E. cuniculi.' },
      fluid_therapy: { principio_activo: 'Fluidoterapia SC (Lactato Ringer)', nombre_comercial: 'Suero fisiológico', dosis_mg_kg: '50-100 ml/kg/día', via: 'SC', frecuencia: 'Cada 24 h', duracion: 'Hasta normalización', notas: 'Esencial en estasis y deshidratación.' },
      chloramphenicol: { principio_activo: 'Cloranfenicol', nombre_comercial: 'Cloranfenicol', dosis_mg_kg: '50 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: '10-14 días', notas: 'Pasteurelosis resistente. Uso bajo prescripción veterinaria.' }
    },
    reptiles: {
      enrofloxacina: { principio_activo: 'Enrofloxacina', nombre_comercial: 'Baytril', dosis_mg_kg: '10 mg/kg', via: 'IM/Oral', frecuencia: 'Cada 48-72 h', duracion: '14-21 días', notas: 'Infecciones bacterianas. Metabolismo lento en ectotermos.' },
      meloxicam: { principio_activo: 'Meloxicam', nombre_comercial: 'Metacam', dosis_mg_kg: '0,2 mg/kg', via: 'IM/Oral', frecuencia: 'Cada 48 h', duracion: '5-7 días', notas: 'Analgesia postquirúrgica. Dosis conservadora.' },
      ceftazidime: { principio_activo: 'Ceftazidima', nombre_comercial: 'Fortaz', dosis_mg_kg: '20 mg/kg', via: 'IM/SC', frecuencia: 'Cada 48-72 h', duracion: '14 días', notas: 'Infecciones graves en reptiles. Pseudomonas.' },
      metronidazol: { principio_activo: 'Metronidazol', nombre_comercial: 'Flagyl', dosis_mg_kg: '20-40 mg/kg', via: 'Oral', frecuencia: 'Cada 48 h', duracion: '7-14 días', notas: 'Protozoos y anaerobios. Giardia y amebas.' },
      fenbendazole: { principio_activo: 'Fenbendazol', nombre_comercial: 'Panacur', dosis_mg_kg: '50 mg/kg', via: 'Oral', frecuencia: 'Cada 24 h x 3 días', duracion: '3 días, repetir a las 2 semanas', notas: 'Parásitos internos. Repetir según coproscopia.' },
      calcium: { principio_activo: 'Gluconato cálcico', nombre_comercial: 'Calcio inyectable', dosis_mg_kg: '100 mg/kg', via: 'IM/Oral', frecuencia: 'Según necesidad', duracion: 'Urgencia', notas: 'Enfermedad ósea metabólica e hipocalcemia. Suplementar con UVB.' },
      vitamin_a: { principio_activo: 'Vitamina A parenteral', nombre_comercial: 'A-Vitan', dosis_mg_kg: '1000 UI/kg', via: 'IM', frecuencia: 'Dosis única', duracion: 'Repetir en 2 semanas si necesario', notas: 'Hipovitaminosis A. Evitar sobredosis (toxicidad).' },
      silver_sulfadiazine: { principio_activo: 'Sulfadiazina de plata', nombre_comercial: 'Flamazine', dosis_mg_kg: 'Capa tópica', via: 'Tópica', frecuencia: 'Cada 24-48 h', duracion: 'Hasta cicatrización', notas: 'Quemaduras y shell rot. Limpiar lesión antes de aplicar.' },
      allopurinol: { principio_activo: 'Alopurinol', nombre_comercial: 'Zyloric', dosis_mg_kg: '10-20 mg/kg', via: 'Oral', frecuencia: 'Cada 24 h', duracion: 'Crónico', notas: 'Gota en reptiles. Reducir proteína dietética.' },
      fluid_therapy: { principio_activo: 'Fluidoterapia (Lactato Ringer)', nombre_comercial: 'Suero fisiológico', dosis_mg_kg: '10-30 ml/kg', via: 'SC/IO/Coelom', frecuencia: 'Cada 24-48 h', duracion: 'Hasta hidratación', notas: 'Deshidratación. Calentar fluidos a temperatura ambiente del reptil.' }
    },
    peces: {
      formalin: { principio_activo: 'Formalina 37%', nombre_comercial: 'Formalin', dosis_mg_kg: '25 ppm baño 30-60 min', via: 'Baño', frecuencia: 'Cada 48-72 h', duracion: '3 tratamientos', notas: 'Ich y parásitos externos. Baño separado con aireación.' },
      malachite_green: { principio_activo: 'Verde de malaquita', nombre_comercial: 'Formalin-MG', dosis_mg_kg: '0,1 mg/L', via: 'Baño', frecuencia: 'Cada 48 h', duracion: '3 tratamientos', notas: 'Ich y hongos. Tóxico si se usa incorrectamente.' },
      praziquantel: { principio_activo: 'Praziquantel', nombre_comercial: 'PraziPro', dosis_mg_kg: '2-5 mg/L', via: 'Baño', frecuencia: 'Dosis única, repetir a los 7 días', duracion: '2 dosis', notas: 'Tembladera y parásitos internos. Seguro en la mayoría de peces.' },
      kanamycin: { principio_activo: 'Kanamicina', nombre_comercial: 'Kanamycin', dosis_mg_kg: '50 mg/L', via: 'Baño', frecuencia: 'Cada 24 h', duracion: '5-7 días', notas: 'Infecciones bacterianas. Remover filtro de carbón.' },
      metronidazol: { principio_activo: 'Metronidazol', nombre_comercial: 'Flagyl', dosis_mg_kg: '5-10 mg/L', via: 'Baño/Alimento', frecuencia: 'Cada 24 h', duracion: '5-7 días', notas: 'Hexamita y anaerobios. Mezclar en alimento para peces comunitarios.' },
      copper: { principio_activo: 'Sulfato de cobre', nombre_comercial: 'Cupramine', dosis_mg_kg: '0,2-0,3 mg/L Cu²⁺', via: 'Baño', frecuencia: 'Cada 48 h', duracion: '3 semanas', notas: 'Ich marino. Tóxico para invertebrados y escala-less.' },
      salt: { principio_activo: 'Cloruro de sodio', nombre_comercial: 'Sal marina', dosis_mg_kg: '1-3 g/L', via: 'Baño', frecuencia: 'Continuo 7-14 días', duracion: '7-14 días', notas: 'Osmorregulación en ich y costia. No usar con escala-less.' },
      acriflavine: { principio_activo: 'Acriflavina', nombre_comercial: 'Acriflavine MS', dosis_mg_kg: '5-10 mg/L', via: 'Baño', frecuencia: 'Cada 48 h', duracion: '3-5 tratamientos', notas: 'Columnaris y hongos. Teñe el agua amarilla.' },
      nitrofurazone: { principio_activo: 'Nitrofurazona', nombre_comercial: 'Furan-2', dosis_mg_kg: '5 mg/L', via: 'Baño', frecuencia: 'Cada 24 h', duracion: '5 días', notas: 'Infecciones bacterianas. Remover filtro de carbón.' },
      epsom_salt: { principio_activo: 'Sulfato de magnesio', nombre_comercial: 'Sal de Epsom', dosis_mg_kg: '1-3 g/L', via: 'Baño', frecuencia: 'Continuo 7 días', duracion: '7 días', notas: 'Hidropesía y estreñimiento. Baño terapéutico.' }
    },
    ovinos: {
      ivermectina: { principio_activo: 'Ivermectina', nombre_comercial: 'Ivomec', dosis_mg_kg: '0,2 mg/kg', via: 'SC/Oral', frecuencia: 'Dosis única', duracion: 'Según programa', notas: 'Parásitos. Usar FAMACHA para desparasitación selectiva.' },
      penicillin: { principio_activo: 'Penicilina procainica', nombre_comercial: 'Penicilina ovina', dosis_mg_kg: '22.000 UI/kg', via: 'IM', frecuencia: 'Cada 24 h', duracion: '5 días', notas: 'Clostridiosis y infecciones. Tratamiento precoz esencial.' },
      flunixin: { principio_activo: 'Flunixin meglumine', nombre_comercial: 'Finadyne', dosis_mg_kg: '2,2 mg/kg', via: 'IV/IM', frecuencia: 'Cada 24 h', duracion: '3 días', notas: 'Fiebre y dolor. Aprobado en ovinos.' },
      oxytetracycline: { principio_activo: 'Oxitetraciclina LA', nombre_comercial: 'Alamycin LA', dosis_mg_kg: '20 mg/kg', via: 'IM', frecuencia: 'Dosis única', duracion: 'Acción 3-5 días', notas: 'Mastitis y footrot. Acción prolongada.' },
      dexamethasone: { principio_activo: 'Dexametasona', nombre_comercial: 'Fortecortin', dosis_mg_kg: '0,1 mg/kg', via: 'IM', frecuencia: 'Cada 24 h', duracion: '1-2 días', notas: 'Parto prematuro. Uso limitado.' },
      calcium_borogluconate: { principio_activo: 'Boro-gluconato cálcico', nombre_comercial: 'Calciject', dosis_mg_kg: '50-100 ml oveja', via: 'SC/IV lento', frecuencia: 'Dosis única', duracion: 'Urgencia', notas: 'Hipocalcemia (parto de tripletes). Monitorizar corazón.' },
      oxytetracycline_spray: { principio_activo: 'Oxitetraciclina aerosol', nombre_comercial: 'Terramycin Spray', dosis_mg_kg: 'Aplicación tópica', via: 'Tópica', frecuencia: 'Cada 24-48 h', duracion: '5-7 días', notas: 'Miasis y heridas cutáneas. Esquilar área afectada.' },
      thiabendazole: { principio_activo: 'Tiabendazol', nombre_comercial: 'Mintezol', dosis_mg_kg: '50-75 mg/kg', via: 'Oral/Drench', frecuencia: 'Dosis única', duracion: 'Repetir según coproscopia', notas: 'Parásitos internos. Rotar anthelmínticos.' }
    },
    caprinos: {
      ivermectina: { principio_activo: 'Ivermectina', nombre_comercial: 'Ivomec', dosis_mg_kg: '0,2 mg/kg', via: 'SC/Oral', frecuencia: 'Dosis única', duracion: 'Según programa', notas: 'Parásitos. Desparasitación selectiva con FAMACHA.' },
      penicillin: { principio_activo: 'Penicilina procainica', nombre_comercial: 'Penicilina caprina', dosis_mg_kg: '22.000 UI/kg', via: 'IM', frecuencia: 'Cada 24 h', duracion: '5 días', notas: 'Listeriosis e infecciones. Alta dosis en listeriosis.' },
      flunixin: { principio_activo: 'Flunixin meglumine', nombre_comercial: 'Finadyne', dosis_mg_kg: '2,2 mg/kg', via: 'IV/IM', frecuencia: 'Cada 24 h', duracion: '3 días', notas: 'Timpanismo y mastitis. Analgesia posparto.' },
      ammonium_chloride: { principio_activo: 'Cloruro de amonio', nombre_comercial: 'Cloruro amónico', dosis_mg_kg: '200 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: '7-14 días', notas: 'Acidificante urinario en urolitiasis. Mezclar en agua.' },
      oxytetracycline: { principio_activo: 'Oxitetraciclina', nombre_comercial: 'Alamycin', dosis_mg_kg: '20 mg/kg', via: 'IM', frecuencia: 'Cada 24 h', duracion: '3-5 días', notas: 'Mastitis y neumonía. Periodo de retirada en leche.' },
      vitamin_b: { principio_activo: 'Complejo B + Cobalto', nombre_comercial: 'Vitamina B12', dosis_mg_kg: '1-2 ml', via: 'IM', frecuencia: 'Cada 24-48 h', duracion: '3-5 días', notas: 'Apetito reducido y acidosis ruminal secundaria.' },
      dexamethasone: { principio_activo: 'Dexametasona', nombre_comercial: 'Fortecortin', dosis_mg_kg: '0,1 mg/kg', via: 'IM', frecuencia: 'Cada 24 h', duracion: '1-2 días', notas: 'Parto prematuro. Precaución en gestantes.' },
      ceftiofur: { principio_activo: 'Ceftiofur sódico', nombre_comercial: 'Excenel', dosis_mg_kg: '2,2 mg/kg', via: 'IM', frecuencia: 'Cada 24 h', duracion: '3-5 días', notas: 'Mastitis gangrenosa y metritis.' }
    },
    camelidos: {
      flunixin: { principio_activo: 'Flunixin meglumine', nombre_comercial: 'Finadyne', dosis_mg_kg: '1,1 mg/kg', via: 'IV/IM', frecuencia: 'Cada 24 h', duracion: '3 días', notas: 'Cólico y dolor. Dosis equina adaptada.' },
      penicillin: { principio_activo: 'Penicilina procainica', nombre_comercial: 'Penicilina', dosis_mg_kg: '22.000 UI/kg', via: 'IM', frecuencia: 'Cada 24 h', duracion: '5 días', notas: 'Infecciones bacterianas. Rotar sitio de inyección.' },
      ivermectina: { principio_activo: 'Ivermectina', nombre_comercial: 'Ivomec', dosis_mg_kg: '0,2 mg/kg', via: 'SC/Oral', frecuencia: 'Dosis única', duracion: 'Según programa', notas: 'Parásitos internos. Meningeal worm en zonas endémicas.' },
      fenbendazole: { principio_activo: 'Fenbendazol', nombre_comercial: 'Panacur', dosis_mg_kg: '10 mg/kg', via: 'Oral', frecuencia: 'Cada 24 h x 3 días', duracion: '3 días', notas: 'Parásitos. Repetir según coproscopia.' },
      vitamin_d: { principio_activo: 'Vitamina D3 + Fósforo', nombre_comercial: 'AD3E', dosis_mg_kg: '2-5 ml', via: 'IM', frecuencia: 'Dosis única', duracion: 'Preventivo estacional', notas: 'Raquitismo en crías. Suplementar en invierno.' },
      oxytetracycline: { principio_activo: 'Oxitetraciclina', nombre_comercial: 'Alamycin', dosis_mg_kg: '20 mg/kg', via: 'IM', frecuencia: 'Cada 24 h', duracion: '3-5 días', notas: 'Infecciones respiratorias y uterinas.' },
      meloxicam: { principio_activo: 'Meloxicam', nombre_comercial: 'Metacam', dosis_mg_kg: '0,5 mg/kg', via: 'SC/IM', frecuencia: 'Cada 24 h', duracion: '3-5 días', notas: 'Analgesia postquirúrgica y cojera.' },
      thiamine: { principio_activo: 'Tiamina (Vitamina B1)', nombre_comercial: 'Bevitina', dosis_mg_kg: '10-20 mg/kg', via: 'IM/SC', frecuencia: 'Cada 8-12 h', duracion: '3-5 días', notas: 'Polioencefalomalacia por estrés. Urgencia neurológica.' }
    },
    roedores: {
      meloxicam: { principio_activo: 'Meloxicam', nombre_comercial: 'Metacam', dosis_mg_kg: '0,5-1 mg/kg', via: 'Oral/SC', frecuencia: 'Cada 24 h', duracion: '3-5 días', notas: 'AINE en roedores. Dosis conservadora.' },
      enrofloxacina: { principio_activo: 'Enrofloxacina', nombre_comercial: 'Baytril', dosis_mg_kg: '10 mg/kg', via: 'Oral/SC', frecuencia: 'Cada 12 h', duracion: '10-14 días', notas: 'Infecciones respiratorias. Mezclar en agua si es posible.' },
      metronidazol: { principio_activo: 'Metronidazol', nombre_comercial: 'Flagyl', dosis_mg_kg: '20 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: '7-10 días', notas: 'Giardia y anaerobios. Wet tail en hámsters.' },
      buprenorfina: { principio_activo: 'Buprenorfina', nombre_comercial: 'Vetergesic', dosis_mg_kg: '0,05-0,1 mg/kg', via: 'SC', frecuencia: 'Cada 8-12 h', duracion: '3-5 días', notas: 'Analgesia. Seguro en roedores.' },
      doxycycline: { principio_activo: 'Doxiciclina', nombre_comercial: 'Doxirobe', dosis_mg_kg: '5-10 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: '14-21 días', notas: 'Mycoplasma y infecciones crónicas.' },
      prednisolona: { principio_activo: 'Prednisolona', nombre_comercial: 'Prednisolona', dosis_mg_kg: '1-2 mg/kg', via: 'Oral', frecuencia: 'Cada 12-24 h', duracion: '5-7 días con descenso', notas: 'Inflamación. Descenso gradual.' },
      fenbendazole: { principio_activo: 'Fenbendazol', nombre_comercial: 'Panacur', dosis_mg_kg: '20 mg/kg', via: 'Oral', frecuencia: 'Cada 24 h x 3 días', duracion: '3 días', notas: 'Parásitos internos. Repetir a las 2 semanas.' },
      vitamin_c: { principio_activo: 'Vitamina C', nombre_comercial: 'Cebion', dosis_mg_kg: '10-30 mg/kg', via: 'Oral', frecuencia: 'Cada 24 h', duracion: 'Crónico en cobayas', notas: 'Esencial en cobayas (escorbuto). No necesaria en hámsters.' },
      fluid_therapy: { principio_activo: 'Fluidoterapia SC', nombre_comercial: 'Lactato Ringer', dosis_mg_kg: '50-100 ml/kg/día', via: 'SC', frecuencia: 'Cada 24 h', duracion: 'Hasta hidratación', notas: 'Deshidratación en wet tail y anorexia.' },
      diazoxide: { principio_activo: 'Diazóxido', nombre_comercial: 'Proglicem', dosis_mg_kg: '10 mg/kg', via: 'Oral', frecuencia: 'Cada 12 h', duracion: 'Crónico', notas: 'Insulinoma en hurones. Control glucémico estrecho.' }
    }
  }.freeze

  DISEASE_DRUG_MAP = {
    /hipoglucemia/i => %i[dextrosa],
    /luxaci|displasia|artri|cojera|osteocondrosis|wobbler/i => %i[meloxicam carprofeno gabapentina condroprotector omeprazol tramadol],
    /periodontal|dental|maloclus/i => %i[clindamicina amoxicilina_clav meloxicam],
    /colapso traqueal|asma|respirator|neumon/i => %i[maropitant prednisolona butorfanol enrofloxacina],
    /cardiomiopat|insuficiencia card/i => %i[enalapril pimobendan furosemida clopidogrel],
    /otitis/i => %i[amoxicilina_clav cephalexin prednisolona],
    /estasis|tricobezoar|megacolon/i => %i[metoclopramide simethicone ranitidine fluid_therapy buprenorfina],
    /cólico|colico/i => %i[flunixin xylazine fluid_therapy dexamethasone],
    /mastitis/i => %i[penicillin ceftiofur oxytetracycline flunixin],
    /torsión|dilatación.*gástrica/i => %i[maropitant fluid_therapy meloxicam],
    /epilep|convuls/i => %i[fenobarbital gabapentina prednisolona],
    /hipotiro/i => %i[levotiroxina meloxicam],
    /diabetes|insulinoma/i => %i[insulina diazoxide meloxicam],
    /obesidad/i => %i[meloxicam prednisolona],
    /psitacosis|clamidia/i => %i[doxiciclina enrofloxacina],
    /aspergilosis|candidiasis|hong/i => %i[itraconazol amphotericin_b nystatin],
    /parásit|parasit|ácar|acar/i => %i[ivermectina fenbendazole praziquantel],
    /laminitis/i => %i[phenylbutazone furosemida flunixin omeprazol],
    /clostrid|timpan/i => %i[penicillin flunixin calcium_iv],
    /disenter|erisipela/i => %i[tiamulin penicillin enrofloxacina],
    /anaplasm|garrapat/i => %i[oxytetracycline flunixin],
    /hipocalcem|milk fever/i => %i[calcium_iv calcium_borogluconate oxytocin],
    /metalosis|intoxic/i => %i[enrofloxacina meloxicam fluid_therapy],
    /ich|columnaris|velvet|costia|koi herpes|khv|dropsy|hidropes/i => %i[formalin malachite_green kanamycin salt metronidazol],
    /miasis|footrot|pododermat/i => %i[oxytetracycline_spray penicillin flunixin ivermectina],
    /listeriosis/i => %i[penicillin dexamethasone flunixin],
    /urolit|obstruc.*urin|bloqueo urin/i => %i[ammonium_chloride meloxicam fluid_therapy buprenorfina],
    /meningeal|parelaphostrongylus/i => %i[ivermectina fenbendazole dexamethasone meloxicam],
    /moquillo|distemper/i => %i[enrofloxacina prednisolona fluid_therapy],
    /wet tail|salmonella/i => %i[metronidazol enrofloxacina fluid_therapy buprenorfina],
    /escorbuto/i => %i[vitamin_c enrofloxacina meloxicam],
    /quemadura|shell rot|muda retenida/i => %i[silver_sulfadiazine meloxicam enrofloxacina calcium],
    /gota|metabolic bone|enfermedad ósea/i => %i[calcium vitamin_a allopurinol fluid_therapy],
    /linfoma|neoplas|mastocit|hemangiosarcoma/i => %i[prednisolona meloxicam enrofloxacina],
    /anemia|imha/i => %i[prednisolona doxiciclina meloxicam],
    /pancreatitis/i => %i[maropitant fluid_therapy meloxicam],
    /shunt porto|encefalopat/i => %i[lactulosa amoxicilina_clav prednisolona],
    /egg binding|retención.*huevo/i => %i[calcium_gluconate oxytocin meloxicam],
    /fractura|traumatismo|trauma/i => %i[meloxicam buprenorfina tramadol cephalexin],
    /prolapso/i => %i[meloxicam enrofloxacina fluid_therapy],
    /glaucoma/i => %i[prednisolona meloxicam],
    /renal|pkd/i => %i[enalapril famotidina amoxicilina_clav],
    /pasteurelosis/i => %i[enrofloxacina trimethoprim_sulfa buprenorfina],
    /retención placenta|metritis/i => %i[ceftiofur oxytetracycline dinoprost flunixin],
    /desplazamiento abomaso/i => %i[calcium_iv flunixin ceftiofur],
    /hypp|trombo/i => %i[clopidogrel enalapril pimobendan furosemida],
    /aflatoxicosis/i => %i[penicillin flunixin vitamin_b],
    /pcv2|circovirus/i => %i[enrofloxacina flunixin iron_dextran],
    /insuficiencia cardíaca/i => %i[furosemida enalapril pimobendan]
  }.freeze

  def self.species_key(animal_id)
    animal_id.to_sym
  end

  def self.default_drugs(animal_id)
    key = species_key(animal_id)
    pool = DRUGS[key] || DRUGS[:perros]
    pool.keys.first(5)
  end

  def self.drugs_for_disease(disease_name, animal_id)
    key = species_key(animal_id)
    pool = DRUGS[key] || DRUGS[:perros]
    selected = []
    DISEASE_DRUG_MAP.each do |pattern, drug_keys|
      next unless disease_name.match?(pattern)
      drug_keys.each do |dk|
        selected << dk if pool.key?(dk)
      end
    end
    selected = default_drugs(animal_id) if selected.empty?
    selected.uniq.first(5)
  end

  def self.generate(disease, animal_id)
    name = disease['nombre']
    key = species_key(animal_id)
    pool = DRUGS[key] || DRUGS[:perros]
    drug_keys = (drugs_for_disease(name, animal_id) + default_drugs(animal_id) + pool.keys).uniq
    entries = []
    drug_keys.each do |dk|
      break if entries.length >= 5
      next unless pool[dk]
      entry = pool[dk].dup
      entry.delete(:via2)
      entries << entry unless entries.any? { |e| e[:principio_activo] == entry[:principio_activo] }
    end
    entries.first([entries.length, 5].min).each_with_object([]) do |e, arr|
      arr << e.transform_keys(&:to_s) if arr.length < 5
    end.then do |result|
      result.length >= 3 ? result.first(5) : result + pool.values.first(3 - result.length).map { |v| v.dup.transform_keys(&:to_s) }
    end
  end
end
