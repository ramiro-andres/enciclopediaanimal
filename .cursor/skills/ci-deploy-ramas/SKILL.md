---
name: ci-deploy-ramas
description: >-
  Flujo de PR, CI, GitHub Pages y limpieza de ramas en Enciclopedia Animal.
  Usar al crear PRs, tocar workflows, deploy Pages, gate test/e2e, o borrar
  ramas mergeadas / cleanup / prune_merged_branches. Pipeline único: ci.yml.
---

# CI, deploy y ramas

## Contribución

1. Rama desde `main` (`feature/…`, `fix/…`, `chore/…`, `docs/…`).
2. Cambios + `bash ejecutar_pruebas.sh` (+ `bash ejecutar_e2e.sh` si toca UI).
3. PR → checks verdes → merge.
4. Deploy automático a Pages tras gate.

## Workflow

Un solo archivo: [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml).

| Job | Cuándo | Rol |
|-----|--------|-----|
| `test` | push/PR | Ruby, integridad, seguridad estática |
| `e2e` | push/PR | Playwright (`file://`, sin servidor) |
| `lighthouse` | PR / manual | Accesibilidad ≥ 90 |
| `preview` | PR / manual | Artefacto `_site` |
| `build` + `deploy` | push `main` / manual | Pages; **needs** `test` + `e2e` verdes |

Cleanup de ramas: [`.github/workflows/cleanup.yml`](../../.github/workflows/cleanup.yml) (solo `pull_request` closed), para no relanzar CI al mergear.

Checks requeridos en branch protection: **`CI / test`** y **`CI / e2e`**.

## Deploy Pages

- Sin Jekyll; copia shell + `css/`, `js/`, `data/`, `images/` a `_site/`.
- Gate con `needs: [test, e2e]` (sin `workflow_run` ni polling de API).
- Post-deploy: curl HTTP 200 a la URL de Pages.

## Ramas

- Repo: `delete_branch_on_merge=true`.
- Jobs de cleanup en `cleanup.yml`: solo mismo repo (no forks); nunca `main`/`master`.
- Manual: `bash scripts/setup/prune_merged_branches.sh` (`--dry-run` primero).
- Script con `set -u`: manejar arrays vacíos (sin fallar si no hay candidatas).
- Worktrees no se borran solos: `git worktree remove`.

## Al crear PR con `gh`

Seguir reglas del usuario: status/diff/log en paralelo, push `-u` si hace falta, body con Summary + Test plan.
