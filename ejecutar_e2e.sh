#!/bin/bash
# Ejecuta las pruebas E2E de navegador contra los archivos estáticos (sin servidor).
# Requiere Node.js (>=18). En CI se instala automáticamente; en local instala
# dependencias y navegadores la primera vez.
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

if ! command -v node >/dev/null 2>&1; then
  echo "❌ Node.js no está instalado. Instálalo (>=18) para ejecutar las pruebas E2E."
  echo "   Las pruebas unitarias Ruby se ejecutan con: bash ejecutar_pruebas.sh"
  exit 1
fi

echo "🎭 Pruebas E2E — Enciclopedia Animal (Playwright, file://)"
echo "=========================================================="

if [ ! -d node_modules/@playwright ]; then
  echo "📦 Instalando dependencias de Playwright..."
  npm install
  npx playwright install --with-deps chromium
fi

npx playwright test "$@"
