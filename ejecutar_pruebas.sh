#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "🧪 Pruebas unitarias + E2E — Enciclopedia Animal"
echo "================================================="
echo ""

echo "▶ 1/2 Pruebas de datos y estructura..."
ruby tests/test_enciclopedia.rb
UNIT=$?

echo ""
echo "▶ 2/2 Pruebas E2E en navegador (página real)..."
chmod +x scripts/shell/ejecutar_pruebas_navegador.sh
bash scripts/shell/ejecutar_pruebas_navegador.sh
E2E=$?

echo ""
if [ $UNIT -eq 0 ] && [ $E2E -eq 0 ]; then
  echo "✅ TODAS las pruebas pasaron (unitarias + navegador)"
  exit 0
elif [ $UNIT -ne 0 ]; then
  echo "❌ Fallaron pruebas unitarias"
  exit $UNIT
else
  echo "❌ Fallaron pruebas E2E del navegador"
  exit $E2E
fi
