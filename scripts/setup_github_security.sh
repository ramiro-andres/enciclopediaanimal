#!/bin/bash
# Configura Pages y protección de rama main en GitHub (requiere gh autenticado).
set -euo pipefail

REPO="ramiro-andres/enciclopediaanimal"
OWNER="ramiro-andres"

if ! command -v gh >/dev/null 2>&1; then
  echo "❌ Instala GitHub CLI: https://cli.github.com/"
  echo "   Luego: gh auth login"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "❌ Ejecuta primero: gh auth login"
  exit 1
fi

echo "▶ Activando GitHub Pages (source: GitHub Actions)..."
gh api "repos/${REPO}/pages" -X POST \
  -f build_type=workflow \
  -f source[branch]=main \
  -f source[path]=/ 2>/dev/null \
  || gh api "repos/${REPO}/pages" -X PUT \
  -f build_type=workflow \
  -f source[branch]=main \
  -f source[path]=/

echo "▶ Configurando protección de rama main..."
gh api "repos/${REPO}/branches/main/protection" -X PUT \
  --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["test / test"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 1,
    "require_last_push_approval": true
  },
  "restrictions": {
    "users": ["${OWNER}"],
    "teams": [],
    "apps": []
  },
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true
}
EOF

echo "▶ Permisos de Actions: read and write..."
gh api "repos/${REPO}/actions/permissions" -X PUT \
  -f enabled=true \
  -f allowed_actions=all \
  -f default_workflow_permissions=write

echo ""
echo "✅ Configuración aplicada."
echo "   Pages: https://ramiro-andres.github.io/enciclopediaanimal/"
echo "   Revisa Settings → Branches → main si GitHub pide plan Pro para alguna opción."
