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

  def generic_definition?(definicion)
    String(definicion).start_with?(GENERIC_DEF_PREFIX)
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
          score: term_score(term, cat['id'])
        }
      end
    end
    entries
  end

  # Deduplica el diccionario in-place. Devuelve métricas y mapa de aliases
  # (forma descartada → forma canónica) para sinónimos de búsqueda.
  def dedupe_dictionary!(dict)
    before = (dict['categorias'] || []).sum { |c| (c['terminos'] || []).length }
    entries = collect_term_entries(dict)

    by_soft = entries.group_by { |e| e[:soft] }
    drop = {} # object_id del hash término → true
    aliases = {} # soft/slug descartado → término canónico

    by_soft.each_value do |group|
      next if group.length < 2
      next if group.first[:soft].empty?

      winner = group.max_by { |e| [e[:score], e[:term]['termino'].to_s.length] }
      group.each do |e|
        next if e.equal?(winner) || e[:term].equal?(winner[:term])

        # Si es el mismo objeto (no debería), saltar.
        next if e[:cat].object_id == winner[:cat].object_id && e[:idx] == winner[:idx]

        drop[[e[:cat].object_id, e[:idx]]] = true
        discarded = e[:term]['termino'].to_s
        kept = winner[:term]['termino'].to_s
        aliases[normalize(discarded)] = kept unless normalize(discarded) == normalize(kept)
      end
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

    # Segunda pasada por slug exacto por si soft_key falló en algún caso.
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
    link_stats = dedupe_links!(links, dict)
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
end
