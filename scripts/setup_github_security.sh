#!/bin/bash
# Configura Pages y protección de rama main en GitHub (requiere gh autenticado).
set -euo pipefail

REPO="ramiro-andres/enciclopediaanimal"
CHECK_CONTEXT="test / test"
PAGES_JSON='{"build_type":"workflow","source":{"branch":"main","path":"/"}}'

if ! command -v gh >/dev/null 2>&1; then
  echo "❌ Instala GitHub CLI: https://cli.github.com/"
  echo "   macOS: brew install gh && gh auth login"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "❌ Ejecuta primero: gh auth login"
  exit 1
fi

VISIBILITY="$(gh api "repos/${REPO}" --jq .visibility)"
if [[ "${VISIBILITY}" == "private" ]]; then
  echo "⚠️  El repo es privado: GitHub Pages (gratis) y algunas reglas requieren repo público."
  echo "   Cambia en Settings → General → Change visibility, o:"
  echo "   gh api repos/${REPO} -X PATCH -f visibility=public"
  exit 1
fi

echo "▶ Activando GitHub Pages (source: GitHub Actions)..."
if ! gh api "repos/${REPO}/pages" -X POST --input - <<<"${PAGES_JSON}" 2>/dev/null; then
  gh api "repos/${REPO}/pages" -X PUT --input - <<<"${PAGES_JSON}" 2>/dev/null \
    || echo "   (Pages ya estaba activo)"
fi

echo "▶ Permisos de Actions: read and write..."
gh api "repos/${REPO}/actions/permissions" -X PUT --input - <<'JSON'
{"enabled":true,"allowed_actions":"all","default_workflow_permissions":"write"}
JSON

echo "▶ Protección de rama main..."
# En repos personales no se pueden restringir pushes por usuario (solo orgs).
gh api "repos/${REPO}/branches/main/protection" -X PUT --input - <<JSON
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["${CHECK_CONTEXT}"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 1,
    "require_last_push_approval": true
  },
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true
}
JSON

echo ""
echo "✅ Configuración aplicada."
echo "   Pages: https://ramiro-andres.github.io/enciclopediaanimal/"
echo "   Nota: en repos personales, 'solo el owner puede push a main' se cumple vía PR + CODEOWNERS,"
echo "   no con 'Restrict who can push' (solo disponible en organizaciones)."
