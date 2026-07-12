# frozen_string_literal: true

# Perfiles de nutrición detallados por especie, tamaño y raza
module BreedNutritionProfiles
  SIZE_LABELS = {
    'pequena' => 'pequeño',
    'mediana' => 'mediana',
    'grande' => 'grande'
  }.freeze

  TEMPLATES = {
    'perros' => {
      tipos_dietas: [
        'Pienso seco completo certificado (AAFCO/FEDIAF)',
        'Dieta húmeda o mixta (seco + latas/bolsas)',
        'Dieta casera balanceada (solo con formulación veterinaria)',
        'Dieta BARF o cruda (con supervisión y manejo higiénico estricto)'
      ],
      frecuencia: {
        'pequena' => '2-3 comidas al día en adultos; 4-5 en cachorros por riesgo de hipoglucemia.',
        'mediana' => '2 comidas al día en adultos; 3-4 en cachorros hasta los 6-8 meses.',
        'grande' => '2 comidas al día en adultos; 3 en cachorros grandes con crecimiento controlado.'
      },
      porcion: {
        'pequena' => 'Ajustar según etiqueta del fabricante para razas toy/mini. Revisar condición corporal cada 2-4 semanas (BCS 4-5/9).',
        'mediana' => 'Ración diaria según peso, actividad y pienso (aprox. 2-3% del peso corporal en adulto activo).',
        'grande' => 'Pienso específico raza grande. Evitar sobrealimentación en crecimiento. Control mensual de peso.'
      },
      requerimientos: [
        'Proteína 22-32% materia seca en adultos sanos',
        'Grasa 10-20% según actividad y edad',
        'Calcio y fósforo balanceados en cachorros (evitar exceso en razas grandes)',
        'Agua fresca disponible permanentemente',
        'Premios ≤10% de las calorías diarias'
      ],
      recomendados: [
        'Pienso por etapa vital (cachorro, adulto, senior)',
        'Snacks bajos en grasa para entrenamiento',
        'Verduras seguras como premio (zanahoria, calabacín)'
      ],
      evitar: [
        'Chocolate, uvas, pasas, cebolla, ajo',
        'Xilitol (hipoglucemia grave)',
        'Huesos cocidos o muy duros',
        'Comida humana grasa o muy salada'
      ],
      etapas: {
        'Cachorro' => 'Pienso de crecimiento hasta 12-18 meses según tamaño adulto. No suplementar calcio sin indicación.',
        'Adulto' => 'Mantenimiento según actividad. Rutina fija de horarios y medición de ración.',
        'Senior' => 'Pienso senior con proteína moderada-alta y soporte articular/dental si aplica.'
      }
    },
    'gatos' => {
      tipos_dietas: [
        'Pienso seco completo felino',
        'Dieta húmeda (recomendada para hidratación)',
        'Dieta mixta seco + húmedo',
        'Dieta casera felina (requiere taurina y balance mineral)'
      ],
      frecuencia: {
        'pequena' => '2-4 tomas al día o alimentación fraccionada.',
        'mediana' => '2-3 tomas al día; evitar comedero siempre lleno si hay tendencia a obesidad.',
        'grande' => '2-3 tomas al día en razas grandes (Maine Coon, etc.).'
      },
      porcion: {
        'pequena' => 'Ajustar a metabolismo felino: 45-60 kcal/kg/día en interior sedentario.',
        'mediana' => 'Control de peso mensual. Aumentar actividad si BCS >5/9.',
        'grande' => 'Raciones mayores pero vigilando obesidad y articulaciones.'
      },
      requerimientos: [
        'Taurina obligatoria (deficiencia → cardiomiopatía)',
        'Proteína animal alta (≥30% MS en adultos)',
        'Arginina, arachidónico y vitamina A preformada',
        'Alta humedad dietética si predomina seco'
      ],
      recomendados: [
        'Latas o sobres húmedos diarios o alternos',
        'Fuentes de agua múltiples',
        'Pienso por edad (kitten, adult, senior)'
      ],
      evitar: [
        'Lirios (nefrotóxicos fatales)',
        'Cebolla, ajo, chocolate, cafeína',
        'Dieta canina (sin taurina suficiente)',
        'Leche de vaca en adultos (intolerancia frecuente)'
      ],
      etapas: {
        'Gatito' => 'Pienso kitten hasta 12 meses. Energía y proteína elevadas.',
        'Adulto' => 'Mantenimiento. Priorizar hidratación y peso ideal.',
        'Senior' => 'Fórmulas renal/cardíacas si hay patología; control analítico anual.'
      }
    },
    'aves' => {
      tipos_dietas: [
        'Pellets formulados (base principal)',
        'Verduras frescas y germinados',
        'Frutas como complemento',
        'Semillas (solo como premio, no dieta exclusiva)'
      ],
      frecuencia: {
        'pequena' => 'Comida disponible en comedero; renovar pellets y verduras 1-2 veces al día.',
        'mediana' => '1-2 reposiciones diarias. Control de peso semanal en gramos.',
        'grande' => '2 tomas principales + forrajeo. Loros grandes: control de grasa.'
      },
      porcion: {
        'pequena' => '1-2 cucharadas de pellets/día según especie + verduras.',
        'mediana' => 'Porción diaria según especie (consultar tabla del fabricante).',
        'grande' => 'Ración calculada por peso; evitar exceso de semillas grasas.'
      },
      requerimientos: [
        '60-80% pellets de calidad',
        '20-30% verduras frescas',
        'Calcio y vitamina A según especie',
        'Agua limpia diaria'
      ],
      recomendados: ['Verduras de hoja verde', 'Zanahoria, pimientos', 'Germinados', 'Forrajeo con juguetes'],
      evitar: ['Aguacate', 'Chocolate', 'Sal en exceso', 'Semillas solas como dieta única'],
      etapas: {
        'Cría' => 'Fórmulas de cría o pellets finos con mayor demanda proteica.',
        'Adulto' => 'Pellets de mantenimiento + variedad vegetal.',
        'Reproductores' => 'Incremento proteico y calcio bajo supervisión.'
      }
    },
    'conejos' => {
      tipos_dietas: [
        'Heno libre elección (base >80%)',
        'Pellets específicos para conejos',
        'Verduras frescas variadas',
        'Frutas solo como premio ocasional'
      ],
      frecuencia: {
        'pequena' => 'Heno 24/7. Pellets 1 vez al día en ración medida.',
        'mediana' => 'Heno 24/7. Verduras 1-2 veces al día.',
        'grande' => 'Heno 24/7. Control de pellets para evitar obesidad.'
      },
      porcion: {
        'pequena' => '1/8-1/4 taza pellets por 2,25 kg peso corporal.',
        'mediana' => '1/4 taza pellets por 2,25 kg + 1-2 tazas verduras.',
        'grande' => 'Ajustar pellets si hay sobrepeso; heno ilimitado.'
      },
      requerimientos: [
        'Fibra larga permanente (heno timothy/césped)',
        'Bajo almidón y bajo calcio en adultos sanos',
        'Agua en bebedero limpio diario'
      ],
      recomendados: ['Heno timothy', 'Hojas de diente de león', 'Rúcula, cilantro, apio', 'Pellets sin semillas'],
      evitar: ['Lechuga iceberg', 'Golosinas comerciales altas en azúcar', 'Exceso de fruta', 'Heno de alfalfa en adultos'],
      etapas: {
        'Juvenil' => 'Alfalfa moderada + heno. Pellets de crecimiento.',
        'Adulto' => 'Heno de gramíneas + verduras variadas.',
        'Senior' => 'Mantener fibra alta; vigilar dentición y peso.'
      }
    },
    'equinos' => {
      tipos_dietas: [
        'Forraje (heno/pasto) como base',
        'Concentrado o grano según trabajo',
        'Suplementos electrolíticos en esfuerzo',
        'Sales minerales a libre disposición'
      ],
      frecuencia: {
        'pequena' => 'Forraje ad libitum; concentrado 2 veces al día si aplica.',
        'mediana' => 'Pastoreo o heno continuo; grano fraccionado.',
        'grande' => 'Evitar ayunos prolongados; 2-3 tomas de concentrado.'
      },
      porcion: {
        'pequena' => '1,5-2% peso corporal en heno seco.',
        'mediana' => 'Ajustar grano según condición y disciplina.',
        'grande' => 'Raciones individualizadas; riesgo de cólico si cambios bruscos.'
      },
      requerimientos: ['Fibra >1% peso corporal en forraje', 'Agua limpia abundante', 'Sal y minerales', 'Control de fructanos en pasto'],
      recomendados: ['Heno de calidad', 'Cepillos de sal', 'Suplementos articulares en deporte'],
      evitar: ['Cambios bruscos de dieta', 'Pasto rico en fructanos en laminitis', 'Sobrealimentación de grano'],
      etapas: {
        'Potro' => 'Leche materna + creep feed gradual.',
        'Adulto en trabajo' => 'Forraje + concentrado según intensidad.',
        'Senior' => 'Fácil masticación; dentición revisada; forraje blando.'
      }
    },
    'peces' => {
      tipos_dietas: [
        'Flocos o pellets comerciales',
        'Alimento congelado (artemia, chironomidos)',
        'Alimento vivo (con moderación)',
        'Verduras blanqueadas para herbívoros'
      ],
      frecuencia: {
        'pequena' => '1-2 veces al día, cantidad consumida en 2-3 minutos.',
        'mediana' => '1-2 veces al día; ayuno opcional 1 día/semana.',
        'grande' => '1-2 veces al día según especie; peces grandes pueden comer día sí/día no.'
      },
      porcion: {
        'pequena' => 'Partícula acorde a boca del pez.',
        'mediana' => 'Evitar exceso que degrade el agua (amoniaco).',
        'grande' => 'Ración según biomasa del acuario.'
      },
      requerimientos: ['Tamaño de partícula adecuado', 'Variedad proteica', 'No sobrealimentar', 'Retirar restos'],
      recomendados: ['Pellets de sinking/floating según especie', 'Rotación de alimentos', 'Ayuno preventivo'],
      evitar: ['Exceso de alimento vivo sin cuarentena', 'Alimento humano salado', 'Cambiar dieta bruscamente'],
      etapas: {
        'Alevín' => 'Artemia o microalimentos varias veces al día.',
        'Adulto' => 'Dieta estable de mantenimiento.',
        'Reproductores' => 'Mayor proteína y frecuencia temporal.'
      }
    },
    'bovinos' => {
      tipos_dietas: ['Pastoreo', 'Ración total mixta (RTM)', 'Suplemento en establo', 'Sales minerales'],
      frecuencia: { 'pequena' => 'Acceso continuo a forraje.', 'mediana' => '2-3 raciones de concentrado en producción.', 'grande' => 'Dieta por grupos homogéneos.' },
      porcion: { 'pequena' => 'Según peso y producción.', 'mediana' => 'Formulación con nutricionista.', 'grande' => 'Evitar sobrecarga ruminal.' },
      requerimientos: ['Fibra efectiva', 'Proteína degradable', 'Agua 60-100 L/día en lactancia', 'Buffer ruminal si alta concentración'],
      recomendados: ['Análisis de forraje', 'Ración por fisiología (seca, preparto, lactante)'],
      evitar: ['Cambios bruscos de dieta', 'Raciones sin fibra suficiente'],
      etapas: { 'Ternera' => 'Calostro + leche/sucedáneo.', 'Engorde' => 'Forraje + concentrado progresivo.', 'Lactante' => 'Alta energía y proteína protegida.' }
    },
    'porcinos' => {
      tipos_dietas: ['Pienso comercial por fase', 'Ración granja (maíz-soya)', 'Dieta líquida en lactación'],
      frecuencia: { 'pequena' => 'Ad libitum en lechones con control.', 'mediana' => '2-3 tomas en cebo.', 'grande' => 'Programador de comida.' },
      porcion: { 'pequena' => 'Según curva de crecimiento.', 'mediana' => 'Conversión alimenticia controlada.', 'grande' => 'Evitar sobrepeso pre-sacrificio.' },
      requerimientos: ['Lisina y metionina balanceadas', 'Agua abundante', 'Higiene del comedero'],
      recomendados: ['Pienso preinicio, crecimiento, terminación', 'Suplemento vitamínico según fase'],
      evitar: ['Alimentos crudos contaminados', 'Restos de cocina sin control'],
      etapas: { 'Lechón' => 'Preinicio alto en lactosa/proteína.', 'Cebo' => 'Crecimiento-terminación.', 'Cerda lactante' => 'Energía máxima y agua.' }
    },
    'ovinos' => {
      tipos_dietas: ['Pastoreo', 'Heno', 'Suplemento concentrado en gestación/lactación', 'Sales'],
      frecuencia: { 'pequena' => 'Pastoreo continuo.', 'mediana' => 'Suplemento en montaña/invierno.', 'grande' => 'Ración en confinamiento parcial.' },
      porcion: { 'pequena' => 'Según condición corporal.', 'mediana' => 'Incremento pre-parto.', 'grande' => 'Evitar acidosis ruminal.' },
      requerimientos: ['Cobre vigilado (sensibilidad ovina)', 'Agua limpia', 'Forraje fibroso'],
      recomendados: ['Sales específicas para ovinos', 'Suplemento en último tercio gestación'],
      evitar: ['Sales bovinas con cobre alto', 'Cambios bruscos de pasto'],
      etapas: { 'Cordero' => 'Leche + creep feed.', 'Adulto' => 'Pastoreo mantenimiento.', 'Gestante' => 'Flushing y suplemento energético.' }
    },
    'caprinos' => {
      tipos_dietas: ['Pastoreo arbustivo', 'Heno', 'Concentrado en lactación', 'Sales minerales'],
      frecuencia: { 'pequena' => 'Forraje libre + suplemento.', 'mediana' => '2 tomas de concentrado en producción.', 'grande' => 'Dieta por cabra según producción.' },
      porcion: { 'pequena' => 'Ajuste por BCS.', 'mediana' => 'Subir energía pre-parto.', 'grande' => 'Evitar sobrecarga de grano.' },
      requerimientos: ['Fibra larga', 'Calcio en lactación', 'Agua limpia'],
      recomendados: ['Heno de leguminosas moderado', 'Grano en ordeño'],
      evitar: ['Exceso de concentrado', 'Forraje mohoso'],
      etapas: { 'Cabrito' => 'Leche o sustituto.', 'Adulto' => 'Pastoreo.', 'Lactante' => 'Energía y proteína elevadas.' }
    },
    'camelidos' => {
      tipos_dietas: ['Pastoreo andino', 'Heno', 'Suplemento mineral', 'Concentrado en gestación/lactación'],
      frecuencia: { 'pequena' => 'Forraje continuo.', 'mediana' => 'Suplemento estacional.', 'grande' => 'Ración en época seca.' },
      porcion: { 'pequena' => 'Bajo requerimiento vs rumiantes.', 'mediana' => 'Ajuste por BCS.', 'grande' => 'Evitar obesidad.' },
      requerimientos: ['TDN moderado', 'Agua limpia', 'Bales de heno de calidad'],
      recomendados: ['Sales para camelidos', 'Forraje seco en invierno'],
      evitar: ['Dieta muy concentrada', 'Pastos ricos sin adaptación'],
      etapas: { 'Cría' => 'Leche materna prolongada.', 'Adulto' => 'Pastoreo extensivo.', 'Gestante' => 'Suplemento energético.' }
    },
    'roedores' => {
      tipos_dietas: [
        'Pellets específicos por especie',
        'Verduras frescas diarias',
        'Heno (cobayas)',
        'Semillas solo como premio'
      ],
      frecuencia: { 'pequena' => 'Pellets + verduras cada día.', 'mediana' => 'Ración fija; heno libre en cobayas.', 'grande' => 'Control de obesidad (capibara, etc.).' },
      porcion: { 'pequena' => '1-2 cucharadas pellets + verduras.', 'mediana' => 'Según especie y peso.', 'grande' => 'Ración calculada por kg.' },
      requerimientos: ['Vitamina C diaria en cobayas', 'Fibra en herbívoros', 'Proteína moderada en omnívoros'],
      recomendados: ['Verduras variadas', 'Heno timothy', 'Agua en botella limpia'],
      evitar: ['Chocolate', 'Cítricos excesivos en cobayas', 'Semillas como dieta única'],
      etapas: { 'Juvenil' => 'Mayor proteína y calcio controlado.', 'Adulto' => 'Mantenimiento.', 'Senior' => 'Fácil masticación y control de peso.' }
    },
    'reptiles' => {
      tipos_dietas: [
        'Herbívoro: verduras + hojas + calcio',
        'Carnívoro: presa entera (ratones, insectos)',
        'Omnívoro: mezcla vegetal y proteína'
      ],
      frecuencia: { 'pequena' => 'Juveniles: diario. Adultos: cada 2-7 días según especie.', 'mediana' => 'Según metabolismo y estación.', 'grande' => 'Serpientes grandes: intervalos largos.' },
      porcion: { 'pequena' => 'Presa del ancho de la cabeza.', 'mediana' => 'No sobrealimentar tortugas.', 'grande' => 'Ajuste por actividad y temperatura.' },
      requerimientos: ['Relación calcio:fósforo 2:1', 'UVB para herbívoros/omnívoros', 'Suplemento calcio sin D3 si UVB'],
      recomendados: ['Gut-loading de insectos', 'Hojas oscuras', 'Agua y baños según especie'],
      evitar: ['Lechuga iceberg como base', 'Presa demasiado grande', 'Alimentar con temperatura incorrecta'],
      etapas: { 'Juvenil' => 'Más frecuencia y proteína.', 'Adulto' => 'Mantenimiento.', 'Reproductor' => 'Calcio y energía extra.' }
    }
  }.freeze

  BREED_OVERRIDES = {
    'holstein' => {
      resumen: 'Vacas lecheras de alta producción requieren raciones con alta densidad energética y proteína degradable.',
      tipos_dietas: ['Ración total mixta (RTM)', 'Pastoreo suplementado', 'Dieta de establo con silo de maíz'],
      etapas: { 'Ternera' => 'Sucedáneo y arranque ruminal.', 'Vaquilla' => 'Crecimiento con proteína moderada.', 'Lactante' => 'Energía, proteína protegida y agua libre.' }
    },
    'leghorn' => {
      resumen: 'Gallinas ponedoras necesitan dietas con calcio elevado para producción de cáscara.',
      tipos_dietas: ['Pienso comercial ponedoras', 'Mash o pellets', 'Suplemento de conchas'],
      requerimientos: ['Calcio 3,5-4,5% en postura', 'Metionina y lisina adecuadas', 'Agua limpia continua']
    },
    'tilapia_nilotica' => {
      resumen: 'Omnívora de rápido crecimiento; eficiente con piensos comerciales acuícolas.',
      tipos_dietas: ['Pellets acuícolas por fase', 'Alimento flotante', 'Suplemento vegetal en estanques extensivos'],
      frecuencia: '2-3 veces al día según temperatura del agua.'
    },
    'conejo_angora' => {
      resumen: 'Alto requerimiento de fibra por producción de pelo; vigilancia de tricobezoares.',
      recomendados: ['Heno de gramíneas fino', 'Verduras bajas en oxalato', 'Pellets sin semillas']
    },
    'labrador' => {
      resumen: 'Raza con tendencia genética a la obesidad; control estricto de porciones y premios.',
      evitar: ['Sobrealimentación', 'Premios excesivos en entrenamiento', 'Restos de comida humana']
    },
    'persa' => {
      resumen: 'Gato sedentario braquicéfalo; priorizar control de peso y dieta húmeda.',
      tipos_dietas: ['Dieta húmeda predominante', 'Pienso seco en porción medida', 'Fórmulas urinarias si riesgo de cálculos']
    }
  }.freeze

  def self.generate(breed, animal_id, size)
    template = TEMPLATES[animal_id] || TEMPLATES['roedores']
    override = BREED_OVERRIDES[breed['id']] || {}
    size_key = size || 'mediana'
    size_label = SIZE_LABELS[size_key] || 'mediana'

    base_alimentacion = breed['alimentacion'].to_s.strip
    resumen = override[:resumen] || "#{breed['nombre']} (#{size_label}): #{base_alimentacion.empty? ? 'dieta adaptada a la especie, edad y condición corporal.' : base_alimentacion}"

    profile = {
      'resumen' => resumen,
      'tipos_dietas' => override[:tipos_dietas] || template[:tipos_dietas],
      'frecuencia_alimentacion' => override[:frecuencia] || template.dig(:frecuencia, size_key) || template.dig(:frecuencia, 'mediana'),
      'porcion_diaria' => override[:porcion] || template.dig(:porcion, size_key) || template.dig(:porcion, 'mediana'),
      'requerimientos_nutricionales' => override[:requerimientos] || template[:requerimientos],
      'alimentos_recomendados' => override[:recomendados] || template[:recomendados],
      'alimentos_evitar' => override[:evitar] || template[:evitar],
      'dietas_por_etapa' => override[:etapas] || template[:etapas]
    }

    if breed['enfoque_produccion'] && breed['nutricion_productiva']
      profile['produccion'] = breed['nutricion_productiva']
      profile['tipos_dietas'] = (profile['tipos_dietas'] + ['Ración productiva por fase', 'Suplemento mineral/vitamínico']).uniq
    end

    profile
  end
end
