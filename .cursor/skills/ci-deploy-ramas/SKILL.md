---
name: ci-deploy-ramas
description: >-
  Flujo de PR, CI, GitHub Pages y limpieza de ramas en Enciclopedia Animal.
  Usar al crear PRs, tocar workflows, deploy Pages, gate test/e2e, o borrar
  ramas mergeadas / cleanup-branch / prune_merged_branches.
---

# CI, deploy y ramas

## Contribución

1. Rama desde `main` (`feature/…`, `fix/…`, `chore/…`, `docs/…`).
2. Cambios + `bash ejecutar_pruebas.sh` (+ `bash ejecutar_e2e.sh` si toca UI).
3. PR → checks verdes → merge.
4. Deploy automático a Pages tras gate.

## Workflows

| Archivo | Rol |
|---------|-----|
| `test.yml` | Ruby, integridad, seguridad estática |
| `e2e.yml` | Playwright (`file://`, sin servidor) |
| `lighthouse.yml` | Accesibilidad ≥ 90 en PR |
| `preview.yml` | Artefacto `_site` |
| `deploy-pages.yml` | Push `main` / manual; **gate** espera `test` + `e2e` en el mismo SHA |
| `cleanup-branch.yml` | PR mergeado → borra head + `prune_merged_branches.sh` |

## Deploy Pages

- Sin Jekyll; copia shell + `css/`, `js/`, `data/`, `images/` a `_site/`.
- No reintroducir `workflow_run` como gate de Sonar.
- Post-deploy: curl HTTP 200 a la URL de Pages.

## Ramas

- Repo: `delete_branch_on_merge=true`.
- Workflow `cleanup-branch.yml`: solo mismo repo (no forks); nunca `main`/`master`.
- Manual: `bash scripts/setup/prune_merged_branches.sh` (`--dry-run` primero).
- Script con `set -u`: manejar arrays vacíos (sin fallar si no hay candidatas).
- Worktrees no se borran solos: `git worktree remove`.

## Al crear PR con `gh`

Seguir reglas del usuario: status/diff/log en paralelo, push `-u` si hace falta, body con Summary + Test plan.
