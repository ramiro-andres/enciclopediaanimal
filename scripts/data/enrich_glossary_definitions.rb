# frozen_string_literal: true

# Amplía definiciones cortas del glosario médico a un formato educativo
# (definición + contexto clínico + alcance por especie/sistema + nota).
# No inventa dosis ni protocolos peligrosos: solo información general.
#
# Uso:
#   ruby scripts/data/enrich_glossary_definitions.rb
#   ruby scripts/data/enrich_glossary_definitions.rb --dry-run

require 'json'

module GlossaryEnrich
  ROOT = File.expand_path('../..', __dir__)
  RICH_THRESHOLD = 200
  TARGET_MIN = 140
  NOTE = 'Uso educativo; no sustituye la valoración de un veterinario colegiado.'

  # Plantillas por categoría (se interpolan con el término y la definición base).
  CATEGORY_TEMPLATES = {
    'sintomas' => lambda { |term, base|
      "#{base} En clínica se registra como hallazgo subjetivo u objetivo según el " \
        "caso y ayuda a orientar el diagnóstico diferencial de «#{term}». " \
        "Su interpretación depende de especie, edad y contexto productivo o de compañía. #{NOTE}"
    },
    'enfermedades' => lambda { |term, base|
      "#{base} La relevancia de «#{term}» varía según especie, manejo y factores de " \
        'riesgo ambientales o genéticos; la ficha clínica de la enciclopedia detalla ' \
        "síntomas, pruebas y enfoques terapéuticos generales. #{NOTE}"
    },
    'farmacos_protocolo' => lambda { |term, base|
      "#{base} «#{term}» aparece en protocolos de referencia de esta enciclopedia; " \
        'la dosis, vía y duración las define el veterinario según especie, peso y ' \
        "estado clínico. No automedicar. #{NOTE}"
    },
    'farmacia' => lambda { |term, base|
      "#{base} En farmacología veterinaria, «#{term}» forma parte del lenguaje de " \
        "prescripción, dispensación o seguimiento terapéutico. #{NOTE}"
    },
    'examenes' => lambda { |term, base|
      "#{base} Como prueba o parámetro, «#{term}» aporta datos objetivos que se " \
        'interpretan junto con la exploración física y la anamnesis, nunca de forma aislada. ' \
        "#{NOTE}"
    },
    'anatomia' => lambda { |term, base|
      "#{base} Conocer «#{term}» facilita localizar lesiones, interpretar imagenología " \
        "y comunicar hallazgos entre clínicos y cuidadores. #{NOTE}"
    },
    'infecciosas' => lambda { |term, base|
      "#{base} En enfermedades infecciosas, «#{term}» se relaciona con transmisión, " \
        "inmunidad o control poblacional según la especie afectada. #{NOTE}"
    },
    'reproduccion' => lambda { |term, base|
      "#{base} En reproducción, «#{term}» influye en fertilidad, gestación, parto o " \
        "neonatología y debe interpretarse según la fisiología de cada especie. #{NOTE}"
    },
    'nutricion' => lambda { |term, base|
      "#{base} En nutrición clínica o productiva, «#{term}» se usa para diseñar raciones, " \
        "evaluar condición corporal y prevenir deficiencias o excesos. #{NOTE}"
    },
    'produccion' => lambda { |term, base|
      "#{base} En sistemas productivos, «#{term}» conecta sanidad, bioseguridad y " \
        "rendimiento; su mal manejo puede afectar bienestar y economía de la explotación. #{NOTE}"
    },
    'rumiantes' => lambda { |term, base|
      "#{base} En rumiantes, «#{term}» se interpreta considerando la fisiología del " \
        "rumen, el manejo del rodeo y los riesgos metabólicos o infecciosos típicos. #{NOTE}"
    },
    'acuicultura' => lambda { |term, base|
      "#{base} En peces y organismos acuáticos, «#{term}» depende de calidad de agua, " \
        "densidad y temperatura; pequeños cambios ambientales agravan cuadros clínicos. #{NOTE}"
    },
    'aves' => lambda { |term, base|
      "#{base} En aves, «#{term}» se valora junto con manejo de alojamiento, muda, " \
        "alimentación y signos respiratorios o digestivos propios de la especie. #{NOTE}"
    },
    'clinica_especializada' => lambda { |term, base|
      "#{base} En clínica especializada, «#{term}» suele requerir criterios diagnósticos " \
        "y seguimiento más detallados que un hallazgo aislado. #{NOTE}"
    },
    'ficha_enfermedad' => lambda { |term, base|
      "#{base} Este campo estructura la ficha clínica: permite comparar casos y " \
        "entender qué información buscar ante «#{term}». #{NOTE}"
    },
    'ficha_raza' => lambda { |term, base|
      "#{base} En fichas de raza, «#{term}» orienta prevención, cribado y manejo " \
        "adaptado a predisposiciones y necesidades de esa población. #{NOTE}"
    }
  }.freeze

  # Expansiones curadas por slug normalizado (sin acentos, minúsculas).
  TERM_EXPANSIONS = {
    'sintomas' =>
      'Signos observables del animal enfermo: cambios de conducta, apariencia, apetito, ' \
      'movimiento, producción o eliminaciones. El cuidador suele notarlos primero; el ' \
      'veterinario los tipifica y prioriza según gravedad. Incluyen manifestaciones ' \
      "específicas e inespecíficas. #{NOTE}",
    'causas' =>
      'Factores que originan la enfermedad: infecciones, parásitos, traumatismos, genética, ' \
      'nutrición o manejo deficiente. Distinguir causa primaria de factores predisponentes ' \
      "mejora el plan diagnóstico y preventivo. #{NOTE}",
    'diagnostico' =>
      'Proceso para identificar la enfermedad mediante anamnesis, examen físico y pruebas ' \
      'complementarias. Se construye por hipótesis sucesivas y diagnóstico diferencial, ' \
      "no por un único hallazgo. #{NOTE}",
    'tratamiento' =>
      'Medidas terapéuticas: medicación, cirugía, fluidos, dieta, reposo o cambios ' \
      'ambientales. El plan se individualiza por especie, gravedad y comorbilidades; ' \
      "siempre bajo criterio veterinario. #{NOTE}",
    'vacunacion' =>
      'Administración de vacunas para inducir inmunidad protectora frente a agentes ' \
      'infecciosos relevantes. El calendario varía por especie, edad, riesgo epidemiológico ' \
      "y normativa local. #{NOTE}",
    'desparasitacion' =>
      'Control de parásitos internos (helmintos, protozoos) y externos (pulgas, garrapatas, ' \
      'ácaros) con productos y intervalos adecuados a la especie y al entorno. Reduce ' \
      "carga parasitaria y riesgo zoonótico en algunos casos. #{NOTE}",
    'anestesia' =>
      'Estado controlado de inconsciencia o sedación profunda que permite cirugía o ' \
      'procedimientos dolorosos. Requiere evaluación previa, monitorización y recuperación ' \
      "supervisada por personal veterinario. #{NOTE}",
    'antibiotico' =>
      'Fármaco que inhibe o elimina bacterias sensibles. Su uso racional evita resistencias: ' \
      'indicación clara, dosis correcta y duración completa según prescripción. No trata ' \
      "infecciones víricas por sí solo. #{NOTE}",
    'aine' =>
      'Antiinflamatorio no esteroideo: reduce dolor e inflamación al modular prostaglandinas. ' \
      'En veterinaria se eligen moléculas y dosis por especie; el uso incorrecto puede ' \
      "dañar riñón, hígado o tubo digestivo. #{NOTE}",
    'antiinflamatorio no esteroideo (aine)' =>
      'Antiinflamatorio no esteroideo (AINE): reduce dolor e inflamación al modular ' \
      'prostaglandinas. En veterinaria se eligen moléculas y dosis por especie; el uso ' \
      "incorrecto puede dañar riñón, hígado o tubo digestivo. #{NOTE}",
    'mastitis' =>
      'Inflamación de la glándula mamaria, frecuente en hembras productoras de leche. ' \
      'Puede ser infecciosa o no infecciosa; afecta bienestar, calidad de leche y ' \
      "producción. El diagnóstico y la terapia los define el veterinario. #{NOTE}",
    'neumonia' =>
      'Inflamación del parénquima pulmonar por bacterias, virus, hongos, aspiración o ' \
      'irritantes. Cursa con dificultad respiratoria, tos o fiebre según especie. Es un ' \
      "cuadro potencialmente grave que requiere evaluación clínica pronta. #{NOTE}",
    'diarrea' =>
      'Aumento de frecuencia o fluidez de las heces. Puede deberse a dieta, parásitos, ' \
      'infecciones, toxinas o enfermedad inflamatoria. La deshidratación es el riesgo ' \
      "principal, sobre todo en jóvenes. #{NOTE}",
    'fiebre' =>
      'Elevación de la temperatura corporal por encima del rango normal de la especie, ' \
      'suele indicar respuesta inflamatoria o infecciosa. Se confirma con termometría y ' \
      "se interpreta junto con el resto del examen clínico. #{NOTE}",
    'anemia' =>
      'Disminución de glóbulos rojos o hemoglobina que reduce el transporte de oxígeno. ' \
      'Causas: pérdida, destrucción o menor producción. Se investiga con hemograma y ' \
      "pruebas dirigidas según la sospecha. #{NOTE}",
    'sepsis' =>
      'Respuesta sistémica grave a una infección que puede comprometer órganos vitales. ' \
      'Es una urgencia: letargo marcado, mucosas alteradas, taquicardia o shock. Requiere ' \
      "atención veterinaria inmediata. #{NOTE}",
    'zoonosis' =>
      'Enfermedad transmisible de forma natural entre animales y humanos. El control ' \
      'incluye higiene, vacunación cuando aplica, manejo seguro de excretas y consulta ' \
      "ante exposición de riesgo. #{NOTE}",
    'bioseguridad' =>
      'Conjunto de prácticas para impedir entrada y diseminación de agentes patógenos en ' \
      'granjas, clínicas o hogares con varios animales. Incluye cuarentena, higiene, ' \
      "control de visitas y eliminación segura de residuos. #{NOTE}",
    'fluidoterapia' =>
      'Administración de líquidos (oral, subcutánea o intravenosa) para corregir ' \
      'deshidratación, shock o desequilibrios electrolíticos. El tipo de fluido y la vía ' \
      "los decide el clínico según el paciente. #{NOTE}",
    'ecografia' =>
      'Técnica de imagen por ultrasonidos que visualiza órganos blandos en tiempo real. ' \
      'Útil en abdomen, corazón (ecocardiografía), reproducción y guiado de punciones, ' \
      "sin radiación ionizante. #{NOTE}",
    'radiografia' =>
      'Imagen por rayos X para evaluar huesos, tórax y algunas estructuras abdominales. ' \
      'Complementa el examen físico; la interpretación considera proyecciones, especie y ' \
      "hallazgos clínicos. #{NOTE}",
    'hemograma' =>
      'Análisis de células sanguíneas: glóbulos rojos, blancos y plaquetas. Orienta sobre ' \
      'anemia, infección, inflamación o trastornos de coagulación, siempre en contexto ' \
      "clínico. #{NOTE}",
    'obesidad' =>
      'Exceso de grasa corporal con riesgo metabólico, ortopédico y de menor calidad de ' \
      'vida. Se valora con condición corporal (BCS) y peso ideal. El plan combina dieta, ' \
      "ejercicio y seguimiento veterinario. #{NOTE}",
    'diabetes mellitus' =>
      'Alteración del metabolismo de la glucosa por déficit o resistencia a la insulina. ' \
      'Cursa con poliuria, polidipsia y pérdida de peso; el control requiere diagnóstico ' \
      "confirmatorio y plan individualizado. #{NOTE}",
    'insuficiencia renal' =>
      'Pérdida de función de los riñones para filtrar toxinas y regular líquidos y ' \
      'electrolitos. Puede ser aguda o crónica; el estadiaje y el manejo dependen de ' \
      "analítica, imagen y especie. #{NOTE}",
    'parvovirosis' =>
      'Enfermedad vírica grave, especialmente en cachorros no vacunados, con vómito, ' \
      'diarrea hemorrágica y leucopenia. Es altamente contagiosa en el entorno; la ' \
      "prevención vacunal es clave. #{NOTE}",
    'moquillo' =>
      'Infección vírica multisistémica del perro (y otros carnívoros) que puede afectar ' \
      'vías respiratorias, digestivo y sistema nervioso. La vacunación reduce ' \
      "drásticamente la incidencia. #{NOTE}",
    'rabia' =>
      'Encefalitis vírica casi siempre mortal y de declaración obligatoria en muchas ' \
      'regiones. Se transmite sobre todo por saliva de animales infectados; la vacunación ' \
      "y el manejo de mordeduras son prioritarios. #{NOTE}",
    'tiña' =>
      'Infección fúngica de piel y pelo (dermatofitosis), a menudo zoonótica. Produce ' \
      'alopecia circular y descamación; el diagnóstico se confirma con cultivo o ' \
      "técnicas específicas. #{NOTE}",
    'sarna' =>
      'Infestación por ácaros que provoca prurito intenso y lesiones cutáneas. Algunas ' \
      'formas son zoonóticas. El tratamiento acaricida y el manejo del entorno deben ' \
      "indicarlos el veterinario. #{NOTE}",
    'laminitis' =>
      'Inflamación de los tejidos sensibles del casco o pezuña, muy dolorosa, frecuente ' \
      'en equinos y rumiantes. Factores: nutrición, sobrecarga, endotoxemia. Es una ' \
      "urgencia ortopédica. #{NOTE}",
    'timpanismo' =>
      'Acúmulo excesivo de gas en el rumen (meteorismo) que distiende el abdomen y puede ' \
      'comprometer la respiración. Relacionado con dietas fermentables y manejo del ' \
      "pastoreo; puede ser emergencia. #{NOTE}",
    'distocia' =>
      'Parto difícil o imposible de completar sin ayuda. Riesgo para madre y crías; ' \
      'requiere evaluación rápida para decidir maniobras asistidas o cesárea según ' \
      "especie y causa. #{NOTE}",
    'colico' =>
      'Síndrome de dolor abdominal, clásico en equinos pero también en otras especies. ' \
      'Las causas van de gases a obstrucciones graves. Cualquier cólico intenso es ' \
      "urgencia veterinaria. #{NOTE}",
    'golpe de calor' =>
      'Hipertermia por fallo de la termorregulación (calor ambiental, braquicefalia, ' \
      'ejercicio). Puede causar fallo multiorgánico. Enfriamiento controlado y atención ' \
      "urgente son esenciales. #{NOTE}",
    'urolitiasis' =>
      'Formación de cálculos en vías urinarias que pueden obstruir, sobre todo en machos. ' \
      'Se asocia a dieta, pH urinario y predisposición. La obstrucción es una emergencia. ' \
      "#{NOTE}",
    'calculos urinarios' =>
      'Formación de cálculos en vías urinarias (urolitiasis) que pueden irritar u obstruir. ' \
      'Dieta, hidratación y especie influyen en el riesgo. La dificultad para orinar ' \
      "exige atención inmediata. #{NOTE}",
    'otitis externa' =>
      'Inflamación del conducto auditivo externo por alergias, cuerpos extraños, ' \
      'parásitos o bacterias/hongos. El prurito y el olor son frecuentes; el tratamiento ' \
      "debe basarse en citología y causa subyacente. #{NOTE}",
    'dermatitis atopica' =>
      'Enfermedad alérgica crónica de la piel con prurito recurrente. Requiere manejo ' \
      'multimodal (alergias, infección secundaria, barrera cutánea) bajo criterio ' \
      "dermatológico veterinario. #{NOTE}",
    'psitacosis' =>
      'Infección por Chlamydia psittaci en aves (clamidiosis), potencialmente zoonótica. ' \
      'Puede cursar con signos respiratorios o sistémicos; higiene y diagnóstico ' \
      "laboratorio son importantes. #{NOTE}",
    'pododermatitis' =>
      'Inflamación o ulceración de la planta/almohadillas, común en animales de jaula o ' \
      'sobrepeso. Relacionada con sustrato, humedad e infección secundaria; el manejo ' \
      "combina causa y cuidado local. #{NOTE}",
    'muda' =>
      'Renovación periódica de plumas, pelo o exoesqueleto (ecdisis en reptiles). Una ' \
      'muda incompleta o retenida indica problemas de humedad, nutrición o enfermedad. ' \
      "#{NOTE}",
    'oxigeno disuelto' =>
      'Concentración de oxígeno disponible en el agua (OD), crítica en acuicultura. ' \
      'Valores bajos provocan estrés y mortalidad; se monitorea junto con temperatura y ' \
      "amoniaco. #{NOTE}",
    'periodo de retirada' =>
      'Tiempo mínimo tras administrar un fármaco antes de destinar leche, huevos o carne ' \
      'al consumo humano. Cumplir el periodo evita residuos y cumple normativa ' \
      "sanitaria. #{NOTE}"
  }.freeze

  # Patrones de nombre → texto educativo (enfermedades/síntomas genéricos).
  NAME_PATTERNS = [
    [/parvo/i, 'enfermedad vírica digestiva grave, típica de cánidos jóvenes no inmunizados'],
    [/moquillo|distemper/i, 'infección vírica multisistémica prevenible por vacunación'],
    [/leucemia felina|felv/i, 'infección vírica felina con inmunosupresión y riesgo oncológico'],
    [/peritonitis infecciosa|fip/i, 'enfermedad coronavírica felina de curso variable y a menudo grave'],
    [/displasia/i, 'malformación del desarrollo articular con cojera y artrosis secundaria'],
    [/cardiomiopat|miocardiopat/i, 'enfermedad del músculo cardíaco que altera la función de bombeo'],
    [/renal|ri[nñ][oó]n|poliquist/i, 'proceso que compromete la filtración renal y el equilibrio hídrico-electrolítico'],
    [/otitis/i, 'inflamación del oído que puede ser externa, media o interna según la extensión'],
    [/dermatitis|piodermia|sarna|ti[nñ]a/i, 'alteración cutánea inflamatoria, infecciosa o parasitaria'],
    [/par[aá]sito|[aá]caro|piojo|gusano|helmint/i, 'condición asociada a parásitos externos o internos'],
    [/virus|viral|herpes|calici|circovirus|pcv/i, 'enfermedad de origen vírico con impacto clínico variable'],
    [/tumor|neoplasia|c[aá]ncer|sarcoma|linfoma|melanoma|lipoma/i, 'proliferación celular anormal, benigna o maligna'],
    [/obesidad/i, 'exceso de adiposidad con consecuencias metabólicas y locomotoras'],
    [/diabetes/i, 'trastorno del control glucémico que requiere diagnóstico y seguimiento'],
    [/fractura|trauma|luxaci[oó]n|hernia|disc/i, 'lesión mecánica de huesos, discos, tejidos o articulaciones'],
    [/neumon|respirator/i, 'afección de vías respiratorias o pulmón con riesgo de hipoxemia'],
    [/mastitis|metritis|agalact/i, 'proceso inflamatorio del aparato mamario o reproductor'],
    [/timpanismo|meteorismo|c[oó]lico/i, 'trastorno digestivo con distensión o dolor abdominal'],
    [/anemia/i, 'reducción de la capacidad de transportar oxígeno en sangre'],
    [/epilep|convul/i, 'trastorno neurológico con crisis que exige estudio de causas'],
    [/glaucoma|uve[ií]tis|retina|ojo/i, 'alteración ocular que puede amenazar la visión'],
    [/urinari|urolit|c[aá]lculo|vejiga|bloqueo urin/i, 'trastorno de vías urinarias con riesgo de obstrucción'],
    [/hepat|h[ií]gado|pancreat/i, 'afección de hígado o páncreas con repercusión metabólica'],
    [/intoxic|toxic|envenen/i, 'cuadro por exposición a sustancias tóxicas o residuales'],
    [/prolapso/i, 'salida anormal de un órgano o mucosa a través de un orificio natural'],
    [/absceso/i, 'colección localizada de pus por infección bacteriana'],
    [/artritis|artrosis|osteo/i, 'inflamación o degeneración articular con dolor y limitación'],
    [/muda|ecdisis|disecdisis/i, 'alteración del ciclo de muda de piel, plumas o cutícula']
  ].freeze

  module_function

  def normalize_slug(text)
    String(text).to_s
      .unicode_normalize(:nfd)
      .gsub(/\p{Mn}/, '')
      .downcase
      .strip
  end

  def already_rich?(definicion)
    String(definicion).length >= RICH_THRESHOLD
  end

  def educational_note?(definicion)
    String(definicion).include?('no sustituye')
  end

  def pattern_gloss(name)
    NAME_PATTERNS.each do |re, gloss|
      return gloss if name.match?(re)
    end
    nil
  end

  def build_disease_enrichment(term, base, cat_id)
    gloss = pattern_gloss(term)
    core = if base.start_with?('Enfermedad o condición documentada')
             if gloss
               "«#{term}» es #{gloss}."
             else
               "«#{term}» es una condición clínica documentada en las fichas de esta enciclopedia."
             end
           elsif base.length < 80 && gloss
             "#{base.sub(/\.\z/, '')}. En términos generales, se trata de #{gloss}."
           else
             base
           end

    related = []
    if term =~ /\(([^)]+)\)/
      related << "También se menciona como #{$1.strip}"
    end
    syn_bit = related.empty? ? '' : "#{related.join('. ')}. "

    "#{core} #{syn_bit}Revisa la ficha de la enfermedad para síntomas, diagnóstico diferencial y " \
      "enfoque terapéutico orientativo según especie. #{NOTE}"
  end

  def build_drug_enrichment(term, base)
    cleaned = base.sub(/\APrincipio activo usado en protocolos de la enciclopedia\.?\s*/i, '')
    "#{term} es un principio activo citado en protocolos de referencia de esta enciclopedia. " \
      "#{cleaned.empty? ? '' : "#{cleaned} "}" \
      'La indicación, dosis, vía y duración las establece el veterinario; no se incluyen aquí ' \
      "pautas de automedicación. #{NOTE}"
  end

  SHORT_PATTERN_PREFIXES = [
    'Enfermedad o condición documentada',
    'Condición causada por parásitos',
    'Inflamación o infección de la piel',
    'Crecimiento celular anormal',
    'Proceso que afecta la función renal',
    'Enfermedad causada por virus',
    'Lesión mecánica de huesos',
    'Exceso de grasa corporal',
    'Inflamación del oído',
    'Alteración del metabolismo de la glucosa',
    'Principio activo usado'
  ].freeze

  def short_pattern_definition?(definicion)
    d = String(definicion)
    SHORT_PATTERN_PREFIXES.any? { |p| d.start_with?(p) }
  end

  def enrich_definition(term, definicion, cat_id)
    base = String(definicion).strip
    return base if already_rich?(base) && educational_note?(base)
    return base if already_rich?(base) && base.length > 280

    slug = normalize_slug(term)
    return TERM_EXPANSIONS[slug] if TERM_EXPANSIONS.key?(slug)

    # Coincidencia parcial con expansiones (p. ej. cálculos urinarios (urolitiasis)).
    TERM_EXPANSIONS.each do |key, text|
      next if key.length < 5
      return text if slug.include?(key) || (key.length >= 8 && key.include?(slug))
    end

    if cat_id == 'farmacos_protocolo' || base.start_with?('Principio activo usado')
      return build_drug_enrichment(term, base)
    end

    if cat_id == 'enfermedades' || short_pattern_definition?(base)
      return build_disease_enrichment(term, base, cat_id)
    end

    # Definiciones cortas: plantilla por categoría.
    if base.length < TARGET_MIN
      gloss = pattern_gloss(term)
      if gloss && %w[sintomas infecciosas rumiantes acuicultura aves].include?(cat_id)
        return build_disease_enrichment(term, base, cat_id)
      end

      template = CATEGORY_TEMPLATES[cat_id]
      if template
        enriched = template.call(term, base)
        return enriched if enriched.length >= TARGET_MIN
      end

      return "#{base} El término «#{term}» forma parte del vocabulario clínico veterinario " \
             "y debe interpretarse en el contexto de la especie y el caso concreto. #{NOTE}"
    end

    # Definición intermedia: añadir nota si falta.
    return "#{base} #{NOTE}" if base.length < RICH_THRESHOLD && !educational_note?(base)

    base
  end

  def enrich_dictionary!(dict)
    before_lens = []
    after_lens = []
    enriched = 0
    preserved = 0

    (dict['categorias'] || []).each do |cat|
      cat_id = cat['id'].to_s
      (cat['terminos'] || []).each do |term|
        old = String(term['definicion'])
        before_lens << old.length
        neu = enrich_definition(term['termino'], old, cat_id)
        if neu != old
          term['definicion'] = neu
          enriched += 1
        else
          preserved += 1
        end
        after_lens << String(term['definicion']).length
      end
    end

    {
      enriched: enriched,
      preserved: preserved,
      before_mean: mean(before_lens),
      after_mean: mean(after_lens),
      before_median: median(before_lens),
      after_median: median(after_lens),
      after_under_target: after_lens.count { |l| l < TARGET_MIN },
      total: after_lens.length
    }
  end

  def mean(arr)
    return 0 if arr.empty?

    (arr.sum.to_f / arr.length).round(1)
  end

  def median(arr)
    return 0 if arr.empty?

    s = arr.sort
    mid = s.length / 2
    s.length.odd? ? s[mid] : ((s[mid - 1] + s[mid]) / 2.0).round
  end

  def run!(root: ROOT, dry_run: false)
    path = File.join(root, 'data', 'diccionario_medicos.json')
    dict = JSON.parse(File.read(path))
    stats = enrich_dictionary!(dict)

    unless dry_run
      File.write(path, JSON.pretty_generate(dict) + "\n")
    end

    stats.merge(dry_run: dry_run, path: path)
  end
end

if __FILE__ == $PROGRAM_NAME
  dry = ARGV.include?('--dry-run')
  stats = GlossaryEnrich.run!(dry_run: dry)
  mode = dry ? 'DRY-RUN' : 'APLICADO'
  puts "enrich_glossary_definitions [#{mode}]"
  puts "  términos enriquecidos: #{stats[:enriched]} (preservados ricos: #{stats[:preserved]})"
  puts "  longitud media: #{stats[:before_mean]} → #{stats[:after_mean]} chars"
  puts "  mediana: #{stats[:before_median]} → #{stats[:after_median]} chars"
  puts "  por debajo de #{GlossaryEnrich::TARGET_MIN} chars: #{stats[:after_under_target]}/#{stats[:total]}"
end
