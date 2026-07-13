#!/usr/bin/env bash
# Sprint 13 — US-DEV-05: elimina ramas remotas ya mergeadas en main (excepto main).
# Uso: bash scripts/setup/prune_merged_branches.sh [--dry-run]
# Requiere: gh autenticado con permisos de escritura en el repo.

set -euo pipefail

DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$DIR"

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

REPO="${GITHUB_REPOSITORY:-}"
if [[ -z "$REPO" ]]; then
  REMOTE_URL="$(git remote get-url origin 2>/dev/null || true)"
  if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+/[^/.]+) ]]; then
    REPO="${BASH_REMATCH[1]%.git}"
  fi
fi

if [[ -z "$REPO" ]]; then
  echo "No se pudo detectar el repositorio. Exporta GITHUB_REPOSITORY o configura origin."
  exit 1
fi

GH="${GH_BIN:-/opt/homebrew/bin/gh}"
if ! command -v "$GH" >/dev/null 2>&1; then
  GH="gh"
fi

echo "🔧 Limpieza de ramas mergeadas — $REPO"
echo "========================================"

git fetch --prune origin

CURRENT_BRANCH="$(git branch --show-current)"
PROTECTED="main master $CURRENT_BRANCH"

MERGED=()
while IFS= read -r branch; do
  [[ -n "$branch" ]] && MERGED+=("$branch")
done < <("$GH" api "repos/$REPO/branches" --paginate -q '.[] | select(.name != "main" and .name != "master") | .name' 2>/dev/null || true)

deleted=0
skipped=0

for branch in "${MERGED[@]}"; do
  [[ -z "$branch" ]] && continue
  for p in $PROTECTED; do
    if [[ "$branch" == "$p" ]]; then
      skipped=$((skipped + 1))
      continue 2
    fi
  done

  # Comprobar si la rama está mergeada en main
  if git branch -r --merged origin/main | grep -q "origin/${branch}$"; then
    if $DRY_RUN; then
      echo "  [dry-run] eliminaría: $branch"
    else
      echo "  eliminando: $branch"
      "$GH" api -X DELETE "repos/$REPO/git/refs/heads/$branch" >/dev/null 2>&1 || {
        echo "  ⚠ no se pudo eliminar $branch (puede requerir permisos)"
        continue
      }
    fi
    deleted=$((deleted + 1))
  else
    skipped=$((skipped + 1))
  fi
done

echo ""
echo "Ramas mergeadas procesadas: $deleted"
echo "Ramas conservadas/omitidas: $skipped"
if $DRY_RUN; then
  echo "(modo dry-run — ninguna rama eliminada)"
fi
