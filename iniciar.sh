#!/bin/bash
# Inicia la enciclopedia en el navegador (servidor local)
PORT="${1:-8080}"
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "🐾 Enciclopedia Animal"
echo "Servidor: http://localhost:$PORT"
echo "Presiona Ctrl+C para detener"
echo ""

URL="http://localhost:$PORT"

if command -v ruby >/dev/null 2>&1; then
  (sleep 1 && open "$URL" 2>/dev/null) &
  ruby -run -e httpd . -p "$PORT"
elif command -v python3 >/dev/null 2>&1; then
  (sleep 1 && open "$URL" 2>/dev/null) &
  python3 -m http.server "$PORT"
else
  echo "Abriendo directamente en el navegador..."
  open "file://$DIR/index.html" 2>/dev/null || xdg-open "file://$DIR/index.html" 2>/dev/null
fi
