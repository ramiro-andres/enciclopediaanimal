# frozen_string_literal: true

# Elimina términos duplicados del glosario médico y enlaces cruzados redundantes
# (mismo término → misma enfermedad / alias de enfermedad, pares bidireccionales
# duplicados, huérfanos). Pensado para ejecutarse tras el build o de forma
# independiente; también se puede requerir desde build_medical_dictionary.rb.
#
# Uso:
#   ruby scripts/data/dedupe_glossary_and_links.rb
#   ruby scripts/data/dedupe_glossary_and_links.rb --dry-run

require 'json'
require 'set'

module GlossaryDedupe
  ROOT = File.expand_path('../..', __dir__)

  module_function

  GENERIC_DEF_PREFIX = 'Enfermedad o condición documentada en la enciclopedia'

  # Categorías preferidas al empatar (menor índice = más preferida).
  CATEGORY_PRIORITY = %w[
    ficha_enfermedad ficha_raza clinica_especializada sintomas farmacia
    infecciosas rumiantes acuicultura reproduccion nutricion produccion
    anatomia diagnostico farmacos_protocolo enfermedades
  ].freeze

  def normalize(text)
    String(text).to_s
      .unicode_normalize(:nfd)
      .gsub(/\p{Mn}/, '')
      .downcase
      .strip
  end

  # Clave suave: acentos, puntuación y plural leve.
  def soft_term_key(text)
    words = normalize(text)
      .gsub(/[^a-z0-9\s]/, ' ')
      .gsub(/\s+/, ' ')
      .strip
      .split
    words.map do |w|
      if w.length > 4 && w.end_with?('es')
        w[0...-2]
      elsif w.length > 3 && w.end_with?('s')
        w[0...-1]
      else
        w
      end
    end.join(' ')
  end

  # Agrupa "Psitacosis" y "Psitacosis (clamidiosis)" como el mismo destino.
  def disease_alias_key(name)
    normalize(name)
      .gsub(/\s*\([^)]*\)\s*/, ' ')
      .gsub(%r{\s*/\s*}, ' ')
      .gsub(/\s+/, ' ')
      .strip
  end

  def strip_parentheticals(text)
    String(text).gsub(/\s*\([^)]*\)\s*/, ' ').gsub(/\s+/, ' ').strip
  end

  # Clave tras quitar paréntesis (para Psitacosis vs Psitacosis (clamidiosis)).
  def alias_base_key(text)
    soft_term_key(strip_parentheticals(text))
  end

  # Núcleo semántico: quita "enfermedad de/del", "síndrome de", etc.
  def core_term_key(text)
    soft_term_key(text)
      .sub(/\Aenfermedad (de la |de las |de los |del |de )?/, '')
      .sub(/\Asindrome (de la |de las |de los |del |de )?/, '')
      .sub(/\Acondicion (de la |de las |de los |del |de )?/, '')
      .strip
  end

  # Contenido entre paréntesis que actúa como sinónimo/acrónimo (no subtipo clínico).
  def synonym_parenthetical?(paren_content)
    c = paren_content.to_s.strip
    return false if c.empty?
    return true if c.match?(/\A[A-Z0-9]{2,12}\z/)
    return false if c.match?(/\by\b/i)
    return false if c.match?(
      /complejo|lactato|laminitis|lipoma|resistencia|nitrito|ancla|piojo|gusano|corvejon|planta|dermatitis digital/i
    )
    # Especificadores de especie/grupo, no sinónimos.
    return false if soft_term_key(c).match?(
      /\A(ave|aves|perro|perros|gato|gatos|equino|equinos|bovino|bovinos|porcino|porcinos|pez|peces|reptil|reptiles|felino|canino)\z/
    )

    synonym_like = %w[
      farmaco clamidiosis urolitiasis od ecdisis bichera pkd circovirus
      proliferativa disecdisis neumonía neumonia
    ]
    soft = soft_term_key(c)
    return true if synonym_like.include?(soft)
    return true if soft.match?(
      /\A(deficiencia de vitamina c|boca podrida|parelaphostrongylus|meteorismo ruminal|bolas de pelo|cnemidocopte|arrancado de pluma|mancha gangrena gaseosa|clamidiosi)\z/
    )

    # 1–3 palabras sin conectores de lista → suele ser alias.
    words = soft.split
    words.length.between?(1, 3)
  end

  def extract_parentheticals(text)
    String(text).scan(/\(([^)]+)\)/).flatten
  end

  # Pares canónicos adicionales (sinónimos cruzados / ortografía).
  # Cada grupo lista soft_term_key exactos de las formas a fusionar.
  EXPLICIT_SYNONYM_GROUPS = [
    [
      'mma metritis mastitis agalactia',
      'mastitis metritis agalactia mma'
    ],
    [
      'wet tail proliferativa',
      'enfermedad de la cola humeda proliferativa'
    ],
    [
      'discopatia intervertebral',
      'enfermedad de disco intervertebral',
      'enfermedad del disco intervertebral'
    ],
    [
      'circovirosis porcina pcv2',
      'pcv2 circovirus'
    ],
    [
      'muda incompleta disecdisis',
      'muda retenida'
    ],
    [
      'intoxicacion por amoniaco',
      'intoxicacion por amoniaco nitrito'
    ]
  ].freeze

  def explicit_group_key(text)
    soft = soft_term_key(text)
    base = alias_base_key(text)
    EXPLICIT_SYNONYM_GROUPS.each_with_index do |group, idx|
      norms = group.map { |g| soft_term_key(g) }
      return "explicit:#{idx}" if norms.include?(soft) || norms.include?(base)
    end
    nil
  end

  def acronym_from_term(text)
    m = String(text).match(/\(([A-Z0-9]{2,12})\)/)
    m ? normalize(m[1]) : nil
  end

  def generic_definition?(definicion)
    d = String(definicion)
    d.start_with?(GENERIC_DEF_PREFIX) ||
      d == 'Condición causada por parásitos externos o internos.' ||
      d == 'Inflamación o infección de la piel.' ||
      d == 'Crecimiento celular anormal; benigno o maligno.' ||
      d == 'Proceso que afecta la función renal y la eliminación de toxinas.' ||
      d == 'Enfermedad causada por virus.' ||
      d == 'Lesión mecánica de huesos, tejidos o articulaciones.' ||
      d == 'Exceso de grasa corporal con riesgo metabólico y ortopédico.' ||
      d == 'Inflamación del oído externo o medio.' ||
      d == 'Alteración del metabolismo de la glucosa.'
  end

  def definitions_nearly_identical?(a, b)
    da = String(a).strip
    db = String(b).strip
    return true if da == db
    return true if generic_definition?(da) && generic_definition?(db)

    ta = soft_term_key(da).split.reject { |w| w.length < 3 }.to_set
    tb = soft_term_key(db).split.reject { |w| w.length < 3 }.to_set
    return false if ta.size < 4 || tb.size < 4

    inter = (ta & tb).size
    union = (ta | tb).size
    inter.to_f / union >= 0.9
  end

  def category_rank(cat_id)
    idx = CATEGORY_PRIORITY.index(cat_id)
    idx.nil? ? CATEGORY_PRIORITY.length : idx
  end

  # Mayor puntuación = conservar esta entrada.
  def term_score(term, cat_id)
    def_text = String(term['definicion'])
    score = 0
    score += 10_000 unless generic_definition?(def_text)
    score += def_text.length
    score += 200 if term['ejemplo'] && !term['ejemplo'].to_s.empty?
    score -= category_rank(cat_id) * 10
    score
  end

  def collect_term_entries(dict)
    entries = []
    (dict['categorias'] || []).each do |cat|
      (cat['terminos'] || []).each_with_index do |term, idx|
        entries << {
          cat: cat,
          idx: idx,
          term: term,
          soft: soft_term_key(term['termino']),
          slug: normalize(term['termino']),
          alias_base: alias_base_key(term['termino']),
          core: core_term_key(term['termino']),
          score: term_score(term, cat['id'])
        }
      end
    end
    entries
  end

  def merge_term_fields!(winner_term, discarded_term)
    # Conservar definición más rica.
    w_def = String(winner_term['definicion'])
    d_def = String(discarded_term['definicion'])
    if d_def.length > w_def.length && !generic_definition?(d_def)
      winner_term['definicion'] = d_def
    elsif generic_definition?(w_def) && !generic_definition?(d_def)
      winner_term['definicion'] = d_def
    end

    if discarded_term['ejemplo'] && winner_term['ejemplo'].to_s.empty?
      winner_term['ejemplo'] = discarded_term['ejemplo']
    end

    syns = Array(winner_term['sinonimos']).map(&:to_s)
    [discarded_term['termino'], *Array(discarded_term['sinonimos'])].each do |s|
      next if s.to_s.empty?
      next if soft_term_key(s) == soft_term_key(winner_term['termino'])
      next if syns.any? { |x| soft_term_key(x) == soft_term_key(s) }

      syns << s.to_s
    end
    winner_term['sinonimos'] = syns unless syns.empty?
  end

  def mark_group_drops!(group, drop, aliases)
    return if group.length < 2

    winner = group.max_by { |e| [e[:score], e[:term]['termino'].to_s.length] }
    group.each do |e|
      next if e.equal?(winner)
      next if e[:cat].object_id == winner[:cat].object_id && e[:idx] == winner[:idx]

      merge_term_fields!(winner[:term], e[:term])
      drop[[e[:cat].object_id, e[:idx]]] = true
      discarded = e[:term]['termino'].to_s
      kept = winner[:term]['termino'].to_s
      aliases[normalize(discarded)] = kept unless normalize(discarded) == normalize(kept)
    end
  end

  # ¿Es seguro fusionar variantes solo por alias entre paréntesis?
  def parenthetical_mergeable_group?(group)
    return false if group.length < 2

    defs = group.map { |e| e[:term]['definicion'] }
    identicalish = defs.combination(2).all? { |a, b| definitions_nearly_identical?(a, b) }
    return false unless identicalish || group.any? { |e| extract_parentheticals(e[:term]['termino']).empty? }

    # Si hay formas con paréntesis, todos los contenidos deben ser sinónimos/acrónimos
    # (no subtipos clínicos como "complejo respiratorio bovino").
    paren_entries = group.select { |e| extract_parentheticals(e[:term]['termino']).any? }
    return false if paren_entries.empty? && !identicalish

    paren_entries.all? do |e|
      extract_parentheticals(e[:term]['termino']).all? { |p| synonym_parenthetical?(p) }
    end
  end

  # Deduplica el diccionario in-place. Devuelve métricas y mapa de aliases
  # (forma descartada → forma canónica) para sinónimos de búsqueda.
  def dedupe_dictionary!(dict)
    before = (dict['categorias'] || []).sum { |c| (c['terminos'] || []).length }
    drop = {}
    aliases = {}

    # Pasada 1: soft key exacto (plural leve / acentos).
    entries = collect_term_entries(dict)
    entries.group_by { |e| e[:soft] }.each_value do |group|
      next if group.length < 2 || group.first[:soft].empty?

      mark_group_drops!(group, drop, aliases)
    end

    # Pasada 2: base sin paréntesis (Psitacosis ↔ Psitacosis (clamidiosis)).
    entries = collect_term_entries(dict).reject { |e| drop[[e[:cat].object_id, e[:idx]]] }
    entries.group_by { |e| e[:alias_base] }.each_value do |group|
      next if group.length < 2 || group.first[:alias_base].empty?
      next unless parenthetical_mergeable_group?(group)

      mark_group_drops!(group, drop, aliases)
    end

    # Pasada 3: núcleo semántico (enfermedad del disco ↔ discopatía).
    entries = collect_term_entries(dict).reject { |e| drop[[e[:cat].object_id, e[:idx]]] }
    entries.group_by { |e| e[:core] }.each_value do |group|
      next if group.length < 2
      next if group.first[:core].to_s.length < 8

      defs_ok = group.combination(2).all? { |a, b| definitions_nearly_identical?(a[:term]['definicion'], b[:term]['definicion']) }
      next unless defs_ok

      mark_group_drops!(group, drop, aliases)
    end

    # Pasada 4: grupos explícitos de sinónimos cruzados.
    entries = collect_term_entries(dict).reject { |e| drop[[e[:cat].object_id, e[:idx]]] }
    by_explicit = {}
    entries.each do |e|
      key = explicit_group_key(e[:term]['termino'])
      next unless key

      (by_explicit[key] ||= []) << e
    end
    by_explicit.each_value do |group|
      next if group.length < 2

      mark_group_drops!(group, drop, aliases)
    end

    # Pasada 5: acrónimo en paréntesis ↔ entrada solo-acrónimo (AINE).
    entries = collect_term_entries(dict).reject { |e| drop[[e[:cat].object_id, e[:idx]]] }
    acronym_owners = {}
    entries.each do |e|
      acr = acronym_from_term(e[:term]['termino'])
      next unless acr

      (acronym_owners[acr] ||= []) << e
    end
    entries.each do |e|
      bare = e[:slug].gsub(/[^a-z0-9]/, '')
      next unless e[:soft].match?(/\A[a-z0-9]{2,12}\z/) && bare == e[:soft]
      next unless acronym_owners[bare]

      group = (acronym_owners[bare] + [e]).uniq
      mark_group_drops!(group, drop, aliases)
    end

    removed = 0
    (dict['categorias'] || []).each do |cat|
      next unless cat['terminos']

      kept_terms = []
      cat['terminos'].each_with_index do |term, idx|
        if drop[[cat.object_id, idx]]
          removed += 1
        else
          kept_terms << term
        end
      end
      cat['terminos'] = kept_terms
    end

    # Pasada final: slug exacto por si quedó algún residuo.
    seen_slug = {}
    (dict['categorias'] || []).each do |cat|
      cat['terminos'] = (cat['terminos'] || []).reject do |term|
        slug = normalize(term['termino'])
        if seen_slug[slug]
          removed += 1
          aliases[slug] ||= seen_slug[slug]
          true
        else
          seen_slug[slug] = term['termino']
          false
        end
      end
    end

    after = (dict['categorias'] || []).sum { |c| (c['terminos'] || []).length }
    dict['total_terminos'] = after
    if dict['introduccion'].is_a?(String)
      dict['introduccion'] = dict['introduccion'].sub(/\d+ entradas/, "#{after} entradas")
    end

    {
      before: before,
      after: after,
      removed: before - after,
      aliases: aliases
    }
  end

  # Reasigna por_termino / por_enfermedad cuando un término se fusionó en otro.
  def remap_links_for_aliases!(links, aliases)
    return 0 if aliases.nil? || aliases.empty?

    por_termino = links['por_termino'] || {}
    remapped = 0

    aliases.each do |discarded_slug, canonical|
      # Buscar claves del índice que correspondan al descartado.
      keys = por_termino.keys.select do |k|
        info = por_termino[k]
        name = info.is_a?(Hash) ? (info['termino'] || k) : k
        soft_term_key(name) == soft_term_key(discarded_slug) ||
          normalize(name) == normalize(discarded_slug) ||
          soft_term_key(k) == soft_term_key(discarded_slug)
      end
      next if keys.empty?

      canon_soft = soft_term_key(canonical)
      canon_key = por_termino.keys.find do |k|
        info = por_termino[k]
        name = info.is_a?(Hash) ? (info['termino'] || k) : k
        soft_term_key(name) == canon_soft
      end
      canon_key ||= normalize(canonical)

      keys.each do |old_key|
        old = por_termino.delete(old_key)
        next unless old.is_a?(Hash)

        remapped += 1
        if por_termino[canon_key]
          ejemplos = Array(por_termino[canon_key]['ejemplos']) + Array(old['ejemplos'])
          por_termino[canon_key]['ejemplos'], = dedupe_ejemplos!(ejemplos)
          por_termino[canon_key]['total'] = [
            por_termino[canon_key]['total'].to_i,
            old['total'].to_i,
            por_termino[canon_key]['ejemplos'].length
          ].max
        else
          old['termino'] = canonical
          por_termino[canon_key] = old
        end
      end
    end

    links['por_termino'] = por_termino
    remapped
  end

  def dedupe_ejemplos!(ejemplos)
    return [[], 0] unless ejemplos.is_a?(Array)

    best = {}
    removed = 0
    ejemplos.each do |ej|
      name = ej.is_a?(Hash) ? ej['nombre'] : ej.to_s
      key = disease_alias_key(name)
      if best.key?(key)
        removed += 1
        # Conservar el nombre más específico (más largo) y ficha más completa.
        current = best[key]
        cur_name = current.is_a?(Hash) ? current['nombre'] : current.to_s
        if name.length > cur_name.length
          best[key] = ej
        end
      else
        best[key] = ej
      end
    end
    [best.values, removed]
  end

  def dedupe_terminos_enlace!(terminos)
    return [[], 0] unless terminos.is_a?(Array)

    best = {}
    removed = 0
    terminos.each do |t|
      name = t.is_a?(Hash) ? t['termino'] : t.to_s
      key = soft_term_key(name)
      if best.key?(key)
        removed += 1
        cur = best[key]
        cur_name = cur.is_a?(Hash) ? cur['termino'] : cur.to_s
        best[key] = t if name.length > cur_name.length
      else
        best[key] = t
      end
    end
    [best.values, removed]
  end

  # Deduplica índices de enlaces in-place. Opcionalmente filtra términos
  # huérfanos respecto al diccionario.
  def dedupe_links!(links, dict = nil)
    por_termino = links['por_termino'] || {}
    por_enfermedad = links['por_enfermedad'] || {}

    before_pairs = count_link_pairs(por_termino, por_enfermedad)
    removed_ejemplos = 0
    removed_term_refs = 0
    removed_orphan_terms = 0
    removed_orphan_diseases = 0

    dict_slugs = nil
    if dict
      dict_slugs = Set.new
      (dict['categorias'] || []).each do |cat|
        (cat['terminos'] || []).each { |t| dict_slugs << soft_term_key(t['termino']) }
      end
    end

    # Deduplicar ejemplos por término (mismo destino / alias).
    por_termino.each do |key, info|
      ejemplos, rem = dedupe_ejemplos!(info['ejemplos'])
      removed_ejemplos += rem
      info['ejemplos'] = ejemplos
      # Ajustar total: no puede ser menor que ejemplos únicos, conservar
      # cobertura real si venía de matches amplios.
      info['total'] = [info['total'].to_i, ejemplos.length].max if info.key?('total')
    end

    # Quitar términos huérfanos (no están en glosario).
    if dict_slugs
      por_termino.keys.each do |key|
        soft = soft_term_key(por_termino[key]['termino'] || key)
        next if dict_slugs.include?(soft) || dict_slugs.include?(soft_term_key(key))

        por_termino.delete(key)
        removed_orphan_terms += 1
      end
    end

    # Deduplicar términos por enfermedad + sincronizar con por_termino.
    live_term_keys = Set.new(por_termino.keys.map { |k| soft_term_key(k) })
    por_enfermedad.each_value do |entry|
      terminos, rem = dedupe_terminos_enlace!(entry['terminos'])
      removed_term_refs += rem
      # Filtrar referencias a términos ya eliminados del índice.
      terminos = terminos.select do |t|
        name = t.is_a?(Hash) ? t['termino'] : t.to_s
        live_term_keys.include?(soft_term_key(name)) || por_termino.key?(normalize(name))
      end
      entry['terminos'] = terminos.sort_by { |t| (t.is_a?(Hash) ? t['termino'] : t).to_s.downcase }
    end

    # Eliminar enfermedades sin términos o con destinos inventados.
    por_enfermedad.keys.each do |key|
      entry = por_enfermedad[key]
      if entry['terminos'].nil? || entry['terminos'].empty?
        por_enfermedad.delete(key)
        removed_orphan_diseases += 1
      end
    end

    # Eliminar pares term→enfermedad duplicados exactos ya cubiertos por alias.
    # (dedupe_ejemplos ya lo hace; aquí recalculamos totales.)
    links['por_termino'] = por_termino
    links['por_enfermedad'] = por_enfermedad
    links['total_terminos_enlazados'] = por_termino.length
    links['total_enfermedades_enlazadas'] = por_enfermedad.length

    after_pairs = count_link_pairs(por_termino, por_enfermedad)

    {
      before_pairs: before_pairs,
      after_pairs: after_pairs,
      removed_pairs: before_pairs[:total] - after_pairs[:total],
      removed_ejemplos: removed_ejemplos,
      removed_term_refs: removed_term_refs,
      removed_orphan_terms: removed_orphan_terms,
      removed_orphan_diseases: removed_orphan_diseases
    }
  end

  def count_link_pairs(por_termino, por_enfermedad)
    from_term = Set.new
    por_termino.each do |key, info|
      term_n = soft_term_key(info['termino'] || key)
      (info['ejemplos'] || []).each do |ej|
        name = ej.is_a?(Hash) ? ej['nombre'] : ej.to_s
        from_term << "#{term_n}=>#{disease_alias_key(name)}"
      end
    end

    from_enf = Set.new
    por_enfermedad.each do |key, info|
      dis_n = disease_alias_key(info['nombre'] || key)
      (info['terminos'] || []).each do |t|
        name = t.is_a?(Hash) ? t['termino'] : t.to_s
        from_enf << "#{soft_term_key(name)}=>#{dis_n}"
      end
    end

    {
      from_term: from_term.size,
      from_enf: from_enf.size,
      total: from_term.size + from_enf.size,
      intersection: (from_term & from_enf).size
    }
  end

  # Añade formas descartadas como sinónimos de la forma canónica.
  def merge_aliases_into_synonyms!(synonyms, aliases)
    return 0 if aliases.nil? || aliases.empty?
    return 0 unless synonyms.is_a?(Hash) && synonyms['terms'].is_a?(Hash)

    added = 0
    terms = synonyms['terms']
    aliases.each do |discarded_slug, canonical|
      canon_key = soft_term_key(canonical).tr(' ', '_')
      # Buscar clave canónica existente o por coincidencia de sinónimos.
      target_key = terms.keys.find { |k| soft_term_key(k) == soft_term_key(canonical) }
      target_key ||= terms.keys.find do |k|
        Array(terms[k]).any? { |s| soft_term_key(s) == soft_term_key(canonical) }
      end
      target_key ||= canon_key

      list = Array(terms[target_key]).map(&:to_s)
      [discarded_slug, canonical].each do |candidate|
        next if candidate.to_s.empty?
        next if list.any? { |s| soft_term_key(s) == soft_term_key(candidate) }

        list << candidate.to_s.tr('_', ' ')
        added += 1
      end
      terms[target_key] = list.uniq
    end

    if synonyms['stats'].is_a?(Hash)
      synonyms['stats']['canonical_terms'] = terms.length
      synonyms['stats']['synonym_entries'] = terms.values.flatten.uniq.length
    end
    added
  end

  def run!(root: GlossaryDedupe::ROOT, dry_run: false)
    dict_path = File.join(root, 'data', 'diccionario_medicos.json')
    links_path = File.join(root, 'data', 'enlaces_clinicos.json')
    syn_path = File.join(root, 'data', 'search_synonyms.json')

    dict = JSON.parse(File.read(dict_path))
    links = JSON.parse(File.read(links_path))
    synonyms = File.exist?(syn_path) ? JSON.parse(File.read(syn_path)) : nil

    dict_stats = dedupe_dictionary!(dict)
    remapped = remap_links_for_aliases!(links, dict_stats[:aliases])
    link_stats = dedupe_links!(links, dict)
    link_stats[:remapped_aliases] = remapped
    syn_added = synonyms ? merge_aliases_into_synonyms!(synonyms, dict_stats[:aliases]) : 0

    unless dry_run
      File.write(dict_path, JSON.pretty_generate(dict) + "\n")
      File.write(links_path, JSON.pretty_generate(links) + "\n")
      if synonyms
        File.write(syn_path, JSON.pretty_generate(synonyms) + "\n")
        File.write(File.join(root, 'data', 'search_synonyms.js'),
                   "window.SEARCH_SYNONYMS = #{synonyms.to_json};\n")
      end
    end

    {
      dictionary: dict_stats,
      links: link_stats,
      synonyms_added: syn_added,
      dry_run: dry_run
    }
  end
end

if __FILE__ == $PROGRAM_NAME
  dry = ARGV.include?('--dry-run')
  stats = GlossaryDedupe.run!(dry_run: dry)
  d = stats[:dictionary]
  l = stats[:links]
  mode = dry ? 'DRY-RUN' : 'APLICADO'
  puts "dedupe_glossary_and_links [#{mode}]"
  puts "  glosario: #{d[:before]} → #{d[:after]} (eliminados #{d[:removed]} duplicados)"
  puts "  pares enlace: #{l[:before_pairs][:total]} → #{l[:after_pairs][:total]} (eliminados #{l[:removed_pairs]})"
  puts "    ejemplos redundantes: #{l[:removed_ejemplos]}"
  puts "    refs término redundantes: #{l[:removed_term_refs]}"
  puts "    términos huérfanos: #{l[:removed_orphan_terms]}"
  puts "    enfermedades vacías: #{l[:removed_orphan_diseases]}"
  puts "  sinónimos añadidos: #{stats[:synonyms_added]}"
  puts "  enlaces reasignados por alias: #{l[:remapped_aliases]}" if l[:remapped_aliases]
end
