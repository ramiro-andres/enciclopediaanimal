# frozen_string_literal: true

# Pruebas de higiene del glosario y enlaces cruzados:
# sin slugs/términos soft-duplicados, sin pares de enlace redundantes,
# y definiciones con longitud educativa mínima.

require 'json'
require 'set'
require 'minitest/autorun'
require_relative '../scripts/data/dedupe_glossary_and_links'
require_relative '../scripts/data/enrich_glossary_definitions'

ROOT = File.expand_path('..', __dir__) unless defined?(ROOT)

class DedupeGlossaryLinksTest < Minitest::Test
  def setup
    @dict = JSON.parse(File.read(File.join(ROOT, 'data', 'diccionario_medicos.json')))
    @links = JSON.parse(File.read(File.join(ROOT, 'data', 'enlaces_clinicos.json')))
    @script = File.join(ROOT, 'scripts', 'data', 'dedupe_glossary_and_links.rb')
    @enrich = File.join(ROOT, 'scripts', 'data', 'enrich_glossary_definitions.rb')
    @actualizar = File.read(File.join(ROOT, 'actualizar_datos.sh'))
  end

  def all_terms
    @dict['categorias'].flat_map { |c| c['terminos'] || [] }
  end

  def test_script_dedupe_existe_y_esta_en_pipeline
    assert File.exist?(@script)
    assert File.exist?(@enrich)
    assert_includes @actualizar, 'dedupe_glossary_and_links.rb'
    assert_includes @actualizar, 'enrich_glossary_definitions.rb'
    build = File.read(File.join(ROOT, 'scripts', 'data', 'build_medical_dictionary.rb'))
    assert_includes build, 'dedupe_glossary_and_links'
    assert_includes build, 'GlossaryDedupe'
  end

  def test_no_hay_slugs_duplicados_en_glosario
    slugs = all_terms.map { |t| GlossaryDedupe.normalize(t['termino']) }
    dupes = slugs.group_by(&:itself).select { |_, v| v.length > 1 }.keys
    assert_empty dupes, "Slugs duplicados en glosario: #{dupes.take(10).join(', ')}"
  end

  def test_no_hay_terminos_soft_duplicados_en_glosario
    soft = all_terms.map { |t| GlossaryDedupe.soft_term_key(t['termino']) }
    dupes = soft.group_by(&:itself).select { |k, v| !k.empty? && v.length > 1 }.keys
    assert_empty dupes, "Términos soft-duplicados: #{dupes.take(10).join(', ')}"
  end

  def test_total_terminos_coincide_con_entradas_unicas
    total = all_terms.length
    assert_equal total, @dict['total_terminos']
    assert_operator total, :>=, 550, "Se esperan ≥550 términos únicos tras dedupe (hay #{total})"
  end

  def test_no_hay_alias_parenteticos_duplicados
    by_base = all_terms.group_by { |t| GlossaryDedupe.alias_base_key(t['termino']) }
    unsafe = by_base.select do |key, group|
      next false if key.empty? || group.length < 2

      GlossaryDedupe.parenthetical_mergeable_group?(
        group.each_with_index.map { |t, i| { term: t, idx: i, cat: { 'id' => 'x' }, soft: key } }
      )
    end
    assert_empty unsafe.keys, "Alias entre paréntesis aún duplicados: #{unsafe.keys.take(8).join(', ')}"
  end

  def test_definiciones_tienen_longitud_minima_mayoritaria
    lengths = all_terms.map { |t| t['definicion'].to_s.length }
    under = lengths.count { |l| l < 120 }
    ratio = under.to_f / lengths.length
    assert_operator ratio, :<=, 0.25, "Más del 25% de definiciones tienen <120 chars (#{under}/#{lengths.length})"
    median = GlossaryEnrich.median(lengths)
    assert_operator median, :>=, 140, "Mediana de longitud demasiado baja: #{median}"
  end

  def test_no_hay_ejemplos_duplicados_por_termino
    @links['por_termino'].each do |key, info|
      aliases = (info['ejemplos'] || []).map { |e| GlossaryDedupe.disease_alias_key(e['nombre']) }
      dupes = aliases.group_by(&:itself).select { |_, v| v.length > 1 }.keys
      assert_empty dupes, "Ejemplos alias-duplicados en '#{key}': #{dupes.join(', ')}"
    end
  end

  def test_no_hay_terminos_duplicados_por_enfermedad
    @links['por_enfermedad'].each do |key, info|
      soft = (info['terminos'] || []).map { |t| GlossaryDedupe.soft_term_key(t['termino']) }
      dupes = soft.group_by(&:itself).select { |_, v| v.length > 1 }.keys
      assert_empty dupes, "Términos duplicados en enfermedad '#{key}': #{dupes.join(', ')}"
    end
  end

  def test_pares_enlace_unicos_term_a_enfermedad
    pairs = []
    @links['por_termino'].each do |key, info|
      term = GlossaryDedupe.soft_term_key(info['termino'] || key)
      (info['ejemplos'] || []).each do |ej|
        pairs << "#{term}=>#{GlossaryDedupe.disease_alias_key(ej['nombre'])}"
      end
    end
    assert_equal pairs.length, pairs.uniq.length, 'Hay pares término→enfermedad duplicados'
  end

  def test_terminos_enlazados_existen_en_diccionario
    dict_soft = all_terms.map { |t| GlossaryDedupe.soft_term_key(t['termino']) }.to_set
    @links['por_termino'].each do |key, info|
      soft = GlossaryDedupe.soft_term_key(info['termino'] || key)
      assert dict_soft.include?(soft), "Término enlazado huérfano: #{key}"
    end
  end
end
