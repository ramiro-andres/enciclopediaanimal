#!/usr/bin/env ruby
# frozen_string_literal: true
# Pruebas E2E reales en navegador usando Safari WebDriver (sin gemas extra)
require 'net/http'
require 'json'
require 'uri'

ROOT = File.expand_path('..', __dir__)
PORT = ENV['TEST_PORT'] || '8080'
BASE = "http://localhost:#{PORT}"

def http_get(url)
  uri = URI(url)
  Net::HTTP.get_response(uri)
end

def ensure_server!
  begin
    res = http_get("#{BASE}/index.html")
    return if res.code == '200'
  rescue StandardError
    # servidor no disponible — arrancar abajo
  end

  puts 'Iniciando servidor...'
  pid = spawn("cd #{ROOT} && ruby -run -e httpd . -p #{PORT}", %i[out err] => '/dev/null')
  Process.detach(pid)
  10.times do
    sleep 0.5
    begin
      return if http_get("#{BASE}/index.html").code == '200'
    rescue StandardError
      next
    end
  end
  abort 'No se pudo iniciar el servidor'
end

def safaridriver_running?
  http_get('http://localhost:4444/status').code == '200'
rescue StandardError
  false
end

def start_safaridriver!
  return if safaridriver_running?

  pid = spawn('safaridriver --port 4444', %i[out err] => '/dev/null')
  Process.detach(pid)
  15.times do
    sleep 0.5
    return if safaridriver_running?
  end
end

def wd_request(method, path, body = nil)
  uri = URI("http://localhost:4444#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  req = case method
        when :post then Net::HTTP::Post.new(uri)
        when :delete then Net::HTTP::Delete.new(uri)
        else Net::HTTP::Get.new(uri)
        end
  req['Content-Type'] = 'application/json; charset=utf-8'
  req.body = body.to_json if body
  res = http.request(req)
  JSON.parse(res.body) rescue {}
rescue Errno::ECONNREFUSED
  {}
end

def run_functional_fallback
  tests = []
  index = http_get("#{BASE}/index.html")
  js_data = http_get("#{BASE}/data/enciclopedia.js")
  js_app = http_get("#{BASE}/js/app.js")
  css = http_get("#{BASE}/css/styles.css")

  tests << ['index.html responde 200', index.code == '200']
  tests << ['enciclopedia.js responde 200', js_data.code == '200']
  tests << ['app.js responde 200', js_app.code == '200']
  tests << ['styles.css responde 200', css.code == '200']
  tests << ['index carga enciclopedia.js', index.body.include?('data/enciclopedia.js')]
  tests << ['index carga app.js', index.body.include?('js/app.js')]
  tests << ['index tiene breedGrid', index.body.include?('id="breedGrid"')]
  tests << ['enciclopedia.js define datos', js_data.body.include?('window.ENCICLOPEDIA_DATA')]
  tests << ['enciclopedia.js tiene perros', js_data.body.include?('"perros"')]
  tests << ['enciclopedia.js tiene gatos', js_data.body.include?('"gatos"')]
  tests << ['app.js exporta E2E state', js_app.body.include?('__E2E_STATE__')]

  json = js_data.body.sub(/^window\.ENCICLOPEDIA_DATA\s*=\s*/, '').sub(/;\s*$/, '')
  data = JSON.parse(json)
  tests << ['datos JS: 13 animales', data['animales'].length == 13]
  breeds = data['animales'].flat_map { |a| %w[pequena mediana grande].flat_map { |s| a.dig('razas', s) || [] } }
  tests << ['datos JS: 355 razas', breeds.length == 355]

  { tests: tests, fallback: true }
end

def run_safari_e2e
  tests = []
  start_safaridriver!

  # Crear sesión Safari
  session = wd_request(:post, '/session', {
    capabilities: { alwaysMatch: { browserName: 'safari', acceptInsecureCerts: true } }
  })

  sid = session.dig('value', 'sessionId')
  return run_functional_fallback unless sid

  begin
    wd_request(:post, "/session/#{sid}/url", { url: "#{BASE}/index.html" })
    sleep 2

    # Esperar que la app cargue
    state = nil
    20.times do
      r = wd_request(:post, "/session/#{sid}/execute/sync", {
        script: 'return window.__E2E_STATE__ || null',
        args: []
      })
      state = r.dig('value')
      break if state&.dig('ready')
      sleep 0.3
    end

    tests << ['App carga sin error', state&.dig('ready') == true]
    tests << ['Vista inicio por defecto', state&.dig('welcomeActive') == true]
    tests << ['13 tipos de animales', state&.dig('animales') == 13]
    tests << ['355 razas totales', state&.dig('razas') == 355]
    tests << ['2099 enfermedades', state&.dig('enfermedades') == 2099]
    tests << ['0 tarjetas en inicio', state&.dig('breedCards') == 0]
    tests << ['14 botones navegación', state&.dig('navItems') == 14]

    # Entrar a exploración Perros
    wd_request(:post, "/session/#{sid}/execute/sync", {
      script: 'document.querySelector("#welcomeCategoryCards [data-animal=perros]").click(); return true;',
      args: []
    })
    sleep 0.3
    r = wd_request(:post, "/session/#{sid}/execute/sync", {
      script: 'return document.getElementById("resultsCount").textContent',
      args: []
    })
    tests << ['Filtro Perros: 43 razas', r['value'] == '43']

    # Búsqueda (requiere vista home)
    wd_request(:post, "/session/#{sid}/execute/sync", {
      script: 'document.getElementById("btnExploreAll").click(); return true;',
      args: []
    })
    sleep 0.2
    wd_request(:post, "/session/#{sid}/execute/sync", {
      script: 'const s=document.getElementById("searchInput");s.value="chihuahua";s.dispatchEvent(new Event("input",{bubbles:true}));return true;',
      args: []
    })
    sleep 0.3
    r = wd_request(:post, "/session/#{sid}/execute/sync", {
      script: 'return document.getElementById("resultsCount").textContent',
      args: []
    })
    tests << ['Búsqueda Chihuahua: 1 raza', r['value'] == '1']

    # Detalle raza
    wd_request(:post, "/session/#{sid}/execute/sync", {
      script: 'document.getElementById("searchInput").value="";document.getElementById("searchInput").dispatchEvent(new Event("input",{bubbles:true}));document.getElementById("btnExploreAll").click();return true;',
      args: []
    })
    sleep 0.2
    wd_request(:post, "/session/#{sid}/execute/sync", {
      script: 'document.querySelector(".breed-card").click(); return true;',
      args: []
    })
    sleep 0.3
    r = wd_request(:post, "/session/#{sid}/execute/sync", {
      script: 'return document.getElementById("detailView").classList.contains("active")',
      args: []
    })
    tests << ['Vista detalle se abre', r['value'] == true]

    r = wd_request(:post, "/session/#{sid}/execute/sync", {
      script: 'return document.querySelectorAll("#breedDetail .disease-card").length >= 3',
      args: []
    })
    tests << ['Detalle tiene enfermedades', r['value'] == true]

    # Enfermedad
    wd_request(:post, "/session/#{sid}/execute/sync", {
      script: 'document.querySelector("#breedDetail .disease-card").click(); return true;',
      args: []
    })
    sleep 0.3
    r = wd_request(:post, "/session/#{sid}/execute/sync", {
      script: 'return document.getElementById("diseaseView").classList.contains("active")',
      args: []
    })
    tests << ['Vista enfermedad se abre', r['value'] == true]

    r = wd_request(:post, "/session/#{sid}/execute/sync", {
      script: 'return document.getElementById("diseaseDetail").textContent.includes("Tratamiento")',
      args: []
    })
    tests << ['Enfermedad muestra tratamiento', r['value'] == true]

  ensure
    wd_request(:delete, "/session/#{sid}") if sid
  end

  { tests: tests }
end

# --- Main ---
ensure_server!
puts "🌐 Pruebas E2E en Safari WebDriver"
puts "   Página: #{BASE}/index.html"
puts ""

result = run_safari_e2e

if result[:error]
  puts "⚠️  #{result[:error]}"
  exit 2
end

if result[:fallback]
  puts "⚠️  Safari WebDriver no disponible — ejecutando pruebas funcionales de página"
  puts ""
end

passed = 0
failed = 0
result[:tests].each do |name, ok|
  puts "#{ok ? '✓' : '✗'} #{name}"
  ok ? passed += 1 : failed += 1
end

puts ""
if failed.zero?
  label = result[:fallback] ? 'funcionales de página' : 'E2E navegador'
  puts "✅ Pruebas #{label}: #{passed}/#{passed + failed} pasaron"
  exit 0
else
  puts "❌ #{failed} pruebas fallaron de #{passed + failed}"
  exit 1
end
