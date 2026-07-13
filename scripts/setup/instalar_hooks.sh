#!/bin/bash
# US-DEV-12 — Instala los git hooks del repositorio (pre-commit JSON → JS).
# Uso: bash scripts/setup/instalar_hooks.sh
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"
SRC="$REPO_ROOT/scripts/setup/pre-commit"

if [ ! -d "$HOOKS_DIR" ]; then
  echo "❌ No se encontró .git/hooks. ¿Estás dentro del repositorio?" >&2
  exit 1
fi

cp "$SRC" "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"

echo "✅ Hook pre-commit instalado en .git/hooks/pre-commit"
echo "   A partir de ahora, editar data/*.json regenerará y validará los .js derivados."
