# Despliegue — Enciclopedia Animal

Sitio en GitHub Pages: https://ramiro-andres.github.io/enciclopediaanimal/

## Pipeline

Archivo único: [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)

Se dispara en:

- Push a `main`
- Pull requests hacia `main`
- Ejecución manual (`workflow_dispatch`)

**Puerta de calidad:** el job `build` declara `needs: [test, e2e]` y solo corre si ambos terminaron en éxito y el evento es push a `main` (o manual).

### Jobs

| Job | Evento | Qué hace |
|-----|--------|----------|
| `test` | push / PR | Pruebas Ruby, integridad, imágenes |
| `e2e` | push / PR | Playwright (file://) |
| `lighthouse` | PR | Accesibilidad ≥ 90 |
| `preview` | PR | Artefacto `_site` descargable |
| `build` → `deploy` | push `main` | Publicar Pages si CI verde |

Cleanup (workflow aparte `cleanup.yml`): PR mergeado → borrar rama head + prune. Separado de CI para no duplicar el pipeline al cerrar el PR.

Checks de protección de rama: **`CI / test`**, **`CI / e2e`**.

## Pasos del deploy

1. `test` + `e2e` verdes
2. Construir `_site` (sitemap + assets)
3. Subir artefacto y desplegar con `actions/deploy-pages`
4. Health check `curl` HTTP 200 (F4-06)

## Activar Pages (una vez)

- Settings → Pages → Build and deployment → **GitHub Actions**
- Permisos de workflow read/write

Alternativa: `bash scripts/setup/setup_github_security.sh`

## Manual

1. **Actions → CI → Run workflow**
2. Eso corre test/e2e y, si pasan, despliega

## Notas

- **Ramas**: se borran al mergear (setting del repo + jobs de cleanup en `ci.yml`).
- **Tamaño**: muchas imágenes aumentan el artefacto; el job lista tamaño y conteo.
- **No modificar paths de assets en raíz** sin actualizar el job `build` en `ci.yml`.
- Tras cambiar el pipeline, actualizar los **required status checks** de `main` a `CI / test` y `CI / e2e`.
