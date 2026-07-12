#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "🧪 Pruebas unitarias — Enciclopedia Animal"
echo "==========================================="
echo ""

ruby tests/test_enciclopedia.rb
exit $?
