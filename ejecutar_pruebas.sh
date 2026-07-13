#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "🧪 Pruebas unitarias — Enciclopedia Animal"
echo "==========================================="
echo ""

ruby -e 'Dir["tests/test_*.rb"].sort.each { |f| require File.expand_path(f) }' || exit $?

echo ""
echo "🔎 Validación de integridad (datos + enlaces clínicos)"
echo "======================================================"
ruby scripts/setup/validar_integridad.rb
INT=$?

echo ""
echo "🔬 Validación de contenido clínico"
echo "-----------------------------------"
ruby scripts/data/validate_clinical_content.rb
CLIN=$?

echo ""
echo "🔍 Detección de inconsistencias (Sprint 11)"
echo "--------------------------------------------"
ruby scripts/data/detect_inconsistencies.rb
INC=$?

exit $(( INT + CLIN + INC ))
