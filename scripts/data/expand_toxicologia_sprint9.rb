# frozen_string_literal: true

# Sprint 9 (US-TOOL-08): amplía toxicologia.json con sustancias adicionales.
# Uso: ruby scripts/data/expand_toxicologia_sprint9.rb

require 'json'
require 'set'

ROOT = File.expand_path('../..', __dir__)
JSON_PATH = File.join(ROOT, 'data', 'toxicologia.json')

NUEVAS_SUSTANCIAS = [
  {
    'id' => 'difenhidramina',
    'nombre' => 'Difenhidramina y antihistamínicos H1',
    'especies' => %w[perros gatos],
    'categoria' => 'farmaco',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Perros: >4 mg/kg puede causar excitación; gatos muy sensibles',
    'sintomas' => ['Sedación', 'Ataxia', 'Agitación paradójica', 'Midriasis', 'Taquicardia', 'Convulsiones'],
    'mecanismo' => 'Antagonismo de receptores H1 con efectos anticolinérgicos y depresión del SNC.',
    'accion' => 'No administrar productos humanos sin criterio veterinario. Urgencia si hay convulsiones o depresión respiratoria.',
    'antidoto' => 'Soporte sintomático; sin antídoto específico.'
  },
  {
    'id' => 'pseudoefedrina',
    'nombre' => 'Pseudoefedrina / descongestionantes',
    'especies' => %w[perros gatos],
    'categoria' => 'farmaco',
    'toxicidad' => 'alta',
    'umbral_orientativo' => '≥5 mg/kg puede ser tóxico en perros pequeños',
    'sintomas' => ['Hiperactividad', 'Taquicardia', 'Hipertensión', 'Temblores', 'Convulsiones', 'Hipertermia'],
    'mecanismo' => 'Estimulación simpática por liberación de noradrenalina y vasoconstricción.',
    'accion' => 'Emergencia cardiovascular. Llevar el medicamento ingerido (jarabe, pastillas).',
    'antidoto' => 'Sedantes y control de presión arterial bajo supervisión veterinaria.'
  },
  {
    'id' => 'metformina',
    'nombre' => 'Metformina (antidiabéticos orales)',
    'especies' => %w[perros gatos],
    'categoria' => 'farmaco',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Ingestión de varias tabletas en animales pequeños',
    'sintomas' => ['Vómito', 'Letargia', 'Acidosis láctica', 'Hipoglucemia', 'Diarrea'],
    'mecanismo' => 'Inhibición de la gluconeogénesis y posible acidosis láctica en sobredosis.',
    'accion' => 'Consultar de inmediato con cantidad ingerida y peso del animal.',
    'antidoto' => 'Fluidoterapia, corrección de acidosis y monitorización de glucemia.'
  },
  {
    'id' => 'ssri_antidepresivos',
    'nombre' => 'ISRS (fluoxetina, sertralina, paroxetina)',
    'especies' => %w[perros gatos],
    'categoria' => 'farmaco',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Sobredosis de comprimidos humanos; riesgo de síndrome serotoninérgico',
    'sintomas' => ['Agitación', 'Temblores', 'Hipertermia', 'Midriasis', 'Taquicardia', 'Diarrea'],
    'mecanismo' => 'Exceso de serotonina sináptica por inhibición de recaptación.',
    'accion' => 'Urgencia si hay signos neurológicos o hipertermia. Informar medicamento y dosis.',
    'antidoto' => 'Soporte y sedación; antagonistas específicos solo en casos graves bajo criterio especializado.'
  },
  {
    'id' => 'triciclicos_antidepresivos',
    'nombre' => 'Antidepresivos tricíclicos (amitriptilina, clomipramina)',
    'especies' => %w[perros gatos],
    'categoria' => 'farmaco',
    'toxicidad' => 'alta',
    'umbral_orientativo' => '≥5 mg/kg amitriptilina puede ser grave',
    'sintomas' => ['Sedación', 'Arritmias', 'Convulsiones', 'Hipotensión', 'Retención urinaria', 'Midriasis'],
    'mecanismo' => 'Bloqueo de recaptación de monoaminas y efectos anticolinérgicos/cardíacos.',
    'accion' => 'Emergencia cardíaca y neurológica. ECG recomendado.',
    'antidoto' => 'Lípidos IV en casos seleccionados; soporte cardiovascular intensivo.'
  },
  {
    'id' => 'benzodiacepinas',
    'nombre' => 'Benzodiacepinas (diazepam, alprazolam, lorazepam)',
    'especies' => %w[perros gatos],
    'categoria' => 'farmaco',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Depende de dosis y tamaño; gatos sensibles a ciertos excipientes',
    'sintomas' => ['Sedación profunda', 'Ataxia', 'Depresión respiratoria', 'Hipotensión', 'Coma'],
    'mecanismo' => 'Potenciación del GABA en el SNC.',
    'accion' => 'Vigilar vía aérea. No inducir vómito si hay sedación marcada.',
    'antidoto' => 'Flumazenilo en casos graves bajo supervisión veterinaria.'
  },
  {
    'id' => 'anticonceptivos_hormonales',
    'nombre' => 'Anticonceptivos hormonales humanos',
    'especies' => %w[perros gatos],
    'categoria' => 'farmaco',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Ingestión de blíster completo en animales pequeños',
    'sintomas' => ['Anorexia', 'Letargia', 'Anemia', 'Piel eritematosa', 'Alopecia (perros)', 'Infecciones uterinas'],
    'mecanismo' => 'Supresión de médula ósea y alteración endocrina por estrógenos sintéticos.',
    'accion' => 'Consultar aunque el animal parezca bien; analítica recomendada.',
    'antidoto' => 'Soporte transfusional y tratamiento de infecciones secundarias si aplica.'
  },
  {
    'id' => 'vitamina_d_rodenticida',
    'nombre' => 'Rodenticidas con vitamina D3 (colecalciferol)',
    'especies' => %w[perros gatos],
    'categoria' => 'plaguicida',
    'toxicidad' => 'alta',
    'umbral_orientativo' => 'Dosis bajas; hipercalcemia retardada 24–72 h',
    'sintomas' => ['Anorexia', 'Vómito', 'Polidipsia', 'Hipercalcemia', 'Insuficiencia renal', 'Arritmias'],
    'mecanismo' => 'Hipervitaminosis D → absorción excesiva de calcio y mineralización tisular.',
    'accion' => 'Urgencia aunque esté asintomático. Llevar el cebo ingerido.',
    'antidoto' => 'Fluidoterapia, diuréticos, bifosfonatos o calcitonina según protocolo veterinario.'
  },
  {
    'id' => 'sago_cycas',
    'nombre' => 'Palma sago (Cycas revoluta)',
    'especies' => %w[perros gatos equinos],
    'categoria' => 'planta',
    'toxicidad' => 'alta',
    'umbral_orientativo' => 'Cualquier parte de la planta, especialmente semillas',
    'sintomas' => ['Vómito', 'Ictericia', 'Hemorragias', 'Insuficiencia hepática', 'Coagulopatía'],
    'mecanismo' => 'Cicasina y otros compuestos hepatotóxicos que dañan hepatocitos.',
    'accion' => 'Emergencia hepática inmediata. No retrasar atención.',
    'antidoto' => 'Soporte hepático intensivo; sin antídoto específico.'
  },
  {
    'id' => 'azalea_rododendro',
    'nombre' => 'Azalea / rododendro',
    'especies' => %w[perros gatos equinos bovinos],
    'categoria' => 'planta',
    'toxicidad' => 'alta',
    'umbral_orientativo' => 'Pocas hojas pueden ser letales en rumiantes y equinos',
    'sintomas' => ['Salivación', 'Vómito', 'Diarrea', 'Bradicardia', 'Hipotensión', 'Convulsiones', 'Coma'],
    'mecanismo' => 'Grayanotoxinas bloquean canales de sodio en membranas celulares.',
    'accion' => 'Emergencia cardiovascular. Evitar acceso a jardines con estas plantas.',
    'antidoto' => 'Atropina y fluidoterapia según criterio clínico.'
  },
  {
    'id' => 'oleandro',
    'nombre' => 'Adelfa / oleandro (Nerium oleander)',
    'especies' => %w[perros gatos equinos bovinos],
    'categoria' => 'planta',
    'toxicidad' => 'alta',
    'umbral_orientativo' => 'Ingestión de hojas o ramas; agua de florero contaminada',
    'sintomas' => ['Vómito', 'Diarrea', 'Arritmias', 'Bradicardia', 'Hipotensión', 'Muerte súbita'],
    'mecanismo' => 'Glicósidos cardíacos inhiben la bomba Na⁺/K⁺-ATPasa.',
    'accion' => 'Emergencia cardíaca. Llevar muestra de la planta si es posible.',
    'antidoto' => 'Anticuerpos anti-digoxina (Fragmin) en casos graves si está disponible.'
  },
  {
    'id' => 'cicuta_hemlock',
    'nombre' => 'Cicuta / hemlock (Conium, Cicuta)',
    'especies' => %w[perros equinos bovinos],
    'categoria' => 'planta',
    'toxicidad' => 'alta',
    'umbral_orientativo' => 'Raíces y semillas muy tóxicas',
    'sintomas' => ['Salivación', 'Temblores', 'Convulsiones', 'Parálisis respiratoria', 'Muerte rápida'],
    'mecanismo' => 'Alcaloides neurotóxicos que actúan como agonistas del receptor GABA.',
    'accion' => 'Emergencia neurológica inmediata. Proteger vía aérea.',
    'antidoto' => 'Soporte respiratorio; sin antídoto específico.'
  },
  {
    'id' => 'ricino',
    'nombre' => 'Ricino (Ricinus communis)',
    'especies' => %w[perros gatos equinos bovinos],
    'categoria' => 'planta',
    'toxicidad' => 'alta',
    'umbral_orientativo' => 'Semillas masticadas; la ricina se libera al romper la cáscara',
    'sintomas' => ['Vómito severo', 'Dolor abdominal', 'Diarrea sanguinolenta', 'Deshidratación', 'Shock'],
    'mecanismo' => 'Ricina inhibe la síntesis proteica en células del tracto GI.',
    'accion' => 'Urgencia por vómito profuso y deshidratación. Estimar número de semillas.',
    'antidoto' => 'Fluidoterapia agresiva y antieméticos; sin antídoto específico.'
  },
  {
    'id' => 'nuez_moscada',
    'nombre' => 'Nuez moscada',
    'especies' => %w[perros],
    'categoria' => 'alimento',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => '≥5 g en perros medianos',
    'sintomas' => ['Alucinaciones', 'Temblores', 'Taquicardia', 'Deshidratación', 'Dolor abdominal'],
    'mecanismo' => 'Miristicina con efectos psicoactivos y estimulación del SNC.',
    'accion' => 'Consultar si hay signos neurológicos. Evitar repostería condimentada.',
    'antidoto' => 'Soporte sintomático.'
  },
  {
    'id' => 'hongo_silvestre',
    'nombre' => 'Hongos silvestres (Amanita, Galerina)',
    'especies' => %w[perros gatos],
    'categoria' => 'planta',
    'toxicidad' => 'alta',
    'umbral_orientativo' => 'Cualquier ingestión de hongo no identificado',
    'sintomas' => ['Vómito', 'Hepatotoxicidad', 'Neurotoxicidad', 'Insuficiencia renal', 'Coma'],
    'mecanismo' => 'Amanitinas y otros alcaloides según especie de hongo.',
    'accion' => 'Emergencia. Recoger restos del hongo y vómito para identificación.',
    'antidoto' => 'Silibinina/NAC en Amanita phalloides bajo protocolo especializado.'
  },
  {
    'id' => 'tomate_verde_solano',
    'nombre' => 'Tomate verde / plantas Solanaceae',
    'especies' => %w[perros gatos equinos],
    'categoria' => 'planta',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Hojas y tallos verdes; fruto maduro generalmente seguro en pequeñas cantidades',
    'sintomas' => ['Salivación', 'Vómito', 'Diarrea', 'Letargia', 'Dilatación pupilar', 'Bradicardia'],
    'mecanismo' => 'Solanina y tomatina irritan el tracto GI y afectan el SNC.',
    'accion' => 'Observar si la cantidad fue pequeña; urgencia con signos neurológicos.',
    'antidoto' => 'Soporte sintomático.'
  },
  {
    'id' => 'nuez_negra_juglona',
    'nombre' => 'Nogal negro (juglona)',
    'especies' => %w[perros equinos],
    'categoria' => 'planta',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Cáscaras, hojas y nueces en descomposición',
    'sintomas' => ['Vómito', 'Letargia', 'Convulsiones', 'Insuficiencia hepática'],
    'mecanismo' => 'Juglona daña hepatocitos y puede causar edema laminar en equinos.',
    'accion' => 'Evitar pastoreo bajo nogales. Urgencia en equinos con cojera o edema.',
    'antidoto' => 'Soporte hepático y fluidoterapia.'
  },
  {
    'id' => 'eucalipto_aceite',
    'nombre' => 'Aceite esencial de eucalipto',
    'especies' => %w[perros gatos aves],
    'categoria' => 'quimico',
    'toxicidad' => 'alta',
    'umbral_orientativo' => 'Pequeñas cantidades de aceite concentrado',
    'sintomas' => ['Salivación', 'Vómito', 'Depresión respiratoria', 'Ataxia', 'Hipotermia'],
    'mecanismo' => 'Eucalyptol irrita mucosas y deprime el SNC en altas concentraciones.',
    'accion' => 'No usar difusores de aceites esenciales cerca de mascotas sin ventilación.',
    'antidoto' => 'Soporte respiratorio; sin antídoto específico.'
  },
  {
    'id' => 'limpiador_cloro',
    'nombre' => 'Lejía / hipoclorito de sodio',
    'especies' => %w[perros gatos aves],
    'categoria' => 'quimico',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Ingestión o contacto con concentrados domésticos',
    'sintomas' => ['Irritación oral y GI', 'Vómito', 'Esofagitis', 'Tos', 'Edema laríngeo'],
    'mecanismo' => 'Corrosión alcalina de mucosas y liberación de cloro gaseoso.',
    'accion' => 'No inducir vómito. Enjuague oral con agua. Urgencia si hay dificultad respiratoria.',
    'antidoto' => 'Soporte respiratorio y gastroprotectores.'
  },
  {
    'id' => 'detergente_lavavajillas',
    'nombre' => 'Detergente / lavavajillas',
    'especies' => %w[perros gatos],
    'categoria' => 'quimico',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Ingestión de cápsulas o líquido concentrado',
    'sintomas' => ['Espuma oral', 'Vómito', 'Diarrea', 'Irritación oral', 'Dolor abdominal'],
    'mecanismo' => 'Surfactantes aniónicos irritan mucosas y pueden causar aspiración.',
    'accion' => 'Enjuague oral. Vigilar tos o dificultad respiratoria por aspiración.',
    'antidoto' => 'Soporte sintomático.'
  },
  {
    'id' => 'baterias',
    'nombre' => 'Pilas y baterías (alcalinas, botón)',
    'especies' => %w[perros gatos],
    'categoria' => 'metal',
    'toxicidad' => 'alta',
    'umbral_orientativo' => 'Cualquier batería ingerida; las de botón son especialmente peligrosas',
    'sintomas' => ['Salivación', 'Úlceras orales/esofágicas', 'Vómito', 'Fiebre', 'Obstrucción GI'],
    'mecanismo' => 'Descarga eléctrica local, perforación y liberación de metales pesados.',
    'accion' => 'Radiografía urgente. No dar comida ni inducir vómito sin criterio veterinario.',
    'antidoto' => 'Extracción endoscópica o quirúrgica; tratamiento de úlceras.'
  },
  {
    'id' => 'propilenglicol_anticongelante',
    'nombre' => 'Propilenglicol (anticongelante «pet-safe»)',
    'especies' => %w[perros gatos],
    'categoria' => 'quimico',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Menos tóxico que etilenglicol pero dosis altas pueden afectar riñón y SNC',
    'sintomas' => ['Ataxia', 'Depresión', 'Poliuria', 'Acidosis metabólica'],
    'mecanismo' => 'Metabolismo hepático a ácido láctico y otros metabolitos.',
    'accion' => 'No asumir que es inofensivo. Tratar como intoxicación si la cantidad fue significativa.',
    'antidoto' => 'Fluidoterapia y monitorización renal.'
  },
  {
    'id' => 'lantana',
    'nombre' => 'Lantana (Lantana camara)',
    'especies' => %w[bovinos equinos ovinos caprinos],
    'categoria' => 'planta',
    'toxicidad' => 'alta',
    'umbral_orientativo' => 'Pastoreo de hojas y frutos verdes',
    'sintomas' => ['Fotosensibilización', 'Ictericia', 'Coluria', 'Anorexia', 'Muerte en rumiantes'],
    'mecanismo' => 'Lantadeno A causa colestasis y fotosensibilización.',
    'accion' => 'Retirar del pasto. Proteger de la luz solar directa en rumiantes afectados.',
    'antidoto' => 'Soporte hepático; sin antídoto específico.'
  },
  {
    'id' => 'aloe_vera',
    'nombre' => 'Aloe vera (ingesta de hoja)',
    'especies' => %w[perros gatos],
    'categoria' => 'planta',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Látex y corteza de la hoja; gel interno menos tóxico',
    'sintomas' => ['Vómito', 'Diarrea', 'Letargia', 'Cambio color orina', 'Tremor'],
    'mecanismo' => 'Antraquinonas (aloina) irritan el tracto GI y afectan riñón.',
    'accion' => 'Consultar si ingirió la parte verde de la hoja. Productos tópicos: evitar que se laman.',
    'antidoto' => 'Soporte sintomático y fluidoterapia.'
  },
  {
    'id' => 'aspirina_salicilatos',
    'nombre' => 'Aspirina y salicilatos',
    'especies' => %w[perros gatos],
    'categoria' => 'farmaco',
    'toxicidad' => 'alta',
    'umbral_orientativo' => 'Gatos: extremadamente sensibles; perros: ≥50 mg/kg/día crónico',
    'sintomas' => ['Vómito', 'Úlceras GI', 'Acidosis metabólica', 'Insuficiencia renal', 'Coagulopatía'],
    'mecanismo' => 'Inhibición de COX y acumulación de ácido salicílico.',
    'accion' => 'Nunca administrar aspirina humana a gatos. Emergencia con vómito o letargia.',
    'antidoto' => 'Fluidoterapia alcalina, gastroprotectores; diálisis en casos graves.'
  },
  {
    'id' => 'glucocorticoides_humanos',
    'nombre' => 'Corticosteroides humanos (prednisona, dexametasona)',
    'especies' => %w[perros gatos],
    'categoria' => 'farmaco',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Ingestión aguda de dosis altas o exposición crónica accidental',
    'sintomas' => ['Polidipsia', 'Poliuria', 'Vómito', 'Úlceras GI', 'Inmunosupresión'],
    'mecanismo' => 'Efectos glucocorticoides sistémicos: antiinflamatorio e inmunosupresor.',
    'accion' => 'Informar medicamento y dosis. No suspender bruscamente si hay uso crónico.',
    'antidoto' => 'Reducción gradual bajo supervisión veterinaria si fue crónico.'
  },
  {
    'id' => 'laminita_marihuana',
    'nombre' => 'Marihuana / THC (comestibles, aceites)',
    'especies' => %w[perros gatos],
    'categoria' => 'farmaco',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Comestibles con chocolate aumentan riesgo; perros muy sensibles',
    'sintomas' => ['Ataxia', 'Incontinencia urinaria', 'Bradycardia', 'Hipotermia', 'Temblores', 'Coma'],
    'mecanismo' => 'Agonismo de receptores cannabinoides CB1 en el SNC.',
    'accion' => 'Ser honesto con el veterinario sobre exposición a cannabis. Urgencia si hay coma.',
    'antidoto' => 'Soporte sintomático; lipídicos IV en casos seleccionados.'
  },
  {
    'id' => 'cebo_molusquicida',
    'nombre' => 'Cebo molusquicida (metaldehído alternativo: fosfato férrico)',
    'especies' => %w[perros gatos],
    'categoria' => 'plaguicida',
    'toxicidad' => 'leve',
    'umbral_orientativo' => 'Fosfato férrico: generalmente baja toxicidad; verificar otros ingredientes',
    'sintomas' => ['Vómito', 'Diarrea', 'Anorexia leve'],
    'mecanismo' => 'Depende de la formulación; el fosfato férrico irrita el GI.',
    'accion' => 'Llevar el envase completo: algunos cebos mezclan metaldehído u otros tóxicos.',
    'antidoto' => 'Soporte sintomático; confirmar ingredientes activos.'
  },
  {
    'id' => 'pimienta_cayena',
    'nombre' => 'Pimienta de cayena / capsicum',
    'especies' => %w[perros gatos aves],
    'categoria' => 'alimento',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Comida picante o aceite de chile',
    'sintomas' => ['Irritación oral', 'Vómito', 'Diarrea', 'Estornudos', 'Lagrimeo', 'Dolor ocular'],
    'mecanismo' => 'Capsaicina irrita mucosas y puede causar gastroenteritis.',
    'accion' => 'Leche o agua para enjuague oral (no en aves). Consultar si hay dificultad respiratoria.',
    'antidoto' => 'Soporte sintomático.'
  },
  {
    'id' => 'uva_ursi',
    'nombre' => 'Uva ursi / gayuba (Arctostaphylos)',
    'especies' => %w[perros gatos],
    'categoria' => 'planta',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Suplementos herbales con arbutina',
    'sintomas' => ['Náuseas', 'Vómito', 'Irritación renal', 'Discoloración orina'],
    'mecanismo' => 'Hidroquinona liberada por arbutina puede dañar riñón en sobredosis.',
    'accion' => 'Evitar suplementos humanos en mascotas sin prescripción.',
    'antidoto' => 'Fluidoterapia y monitorización renal.'
  },
  {
    'id' => 'te_verde_concentrado',
    'nombre' => 'Extracto concentrado de té verde',
    'especies' => %w[perros gatos],
    'categoria' => 'alimento',
    'toxicidad' => 'moderada',
    'umbral_orientativo' => 'Cápsulas de suplemento humano con EGCG concentrado',
    'sintomas' => ['Vómito', 'Hepatotoxicidad', 'Letargia', 'Ictericia'],
    'mecanismo' => 'Catequinas en alta concentración pueden dañar hepatocitos en perros.',
    'accion' => 'Urgencia hepática si ingirió suplementos de té verde concentrado.',
    'antidoto' => 'Soporte hepático; sin antídoto específico.'
  }
].freeze

if __FILE__ == $PROGRAM_NAME
  data = JSON.parse(File.read(JSON_PATH))
  existing_ids = data['sustancias'].map { |s| s['id'] }.to_set
  added = 0
  NUEVAS_SUSTANCIAS.each do |s|
    next if existing_ids.include?(s['id'])

    data['sustancias'] << s
    added += 1
  end
  File.write(JSON_PATH, JSON.pretty_generate(data) + "\n")
  puts "toxicologia.json: +#{added} sustancias (#{data['sustancias'].length} total)"
end
