# frozen_string_literal: true

# Genera data/changelog.json desde CHANGELOG.md o, si no existe, desde git log.
# Sprint 12 — US-UX-18

require 'json'
require 'time'

ROOT = File.expand_path('../..', __dir__)
CHANGELOG_MD = File.join(ROOT, 'CHANGELOG.md')
OUT_JSON = File.join(ROOT, 'data', 'changelog.json')
OUT_JS = File.join(ROOT, 'data', 'changelog.js')

def parse_changelog_md(path)
  return [] unless File.exist?(path)

  entries = []
  current = nil
  File.readlines(path, chomp: true).each do |line|
    if line =~ /^## \[?([^\]\n]+)\]?(?:\s+-\s+(\d{4}-\d{2}-\d{2}))?/
      entries << current if current
      current = {
        'version' => Regexp.last_match(1).strip,
        'date' => Regexp.last_match(2),
        'title' => Regexp.last_match(1).strip,
        'items' => []
      }
    elsif current && line =~ /^-\s+(.+)/
      current['items'] << Regexp.last_match(1).strip
    end
  end
  entries << current if current
  entries.reject { |e| e['items'].empty? && e['title'].to_s.empty? }
end

def parse_git_log(limit: 40)
  return [] unless system('git rev-parse --git-dir > /dev/null 2>&1')

  raw = `git log --pretty=format:'%h|%ad|%s' --date=short -n #{limit}`.strip
  return [] if raw.empty?

  raw.lines.map do |line|
    hash, date, subject = line.strip.split('|', 3)
    next unless hash && date && subject

    {
      'version' => hash,
      'date' => date,
      'title' => subject,
      'items' => [subject]
    }
  end.compact
end

md_entries = parse_changelog_md(CHANGELOG_MD)
entries = md_entries.empty? ? parse_git_log : md_entries

payload = {
  'generated_at' => Time.now.utc.iso8601,
  'source' => md_entries.empty? ? 'git' : 'changelog.md',
  'entries' => entries
}

File.write(OUT_JSON, JSON.pretty_generate(payload))
File.write(OUT_JS, "window.ATLAS_CHANGELOG = #{payload.to_json};\n")
puts "changelog.json generado (#{entries.length} entradas) → #{OUT_JSON}"
