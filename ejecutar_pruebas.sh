#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "🧪 Pruebas unitarias — Enciclopedia Animal"
echo "==========================================="
echo ""

ruby tests/test_enciclopedia.rb
UNIT=$?

echo ""
echo "🔬 Validación de contenido clínico"
echo "-----------------------------------"
ruby scripts/data/validate_clinical_content.rb
CLINICAL=$?

exit $(( UNIT + CLINICAL ))
