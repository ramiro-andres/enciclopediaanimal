# Despliegue

Enciclopedia Animal se publica en **GitHub Pages** con **GitHub Actions** (sin Jekyll).

## URL de producción

https://ramiro-andres.github.io/enciclopediaanimal/

## Workflow de despliegue

Archivo: `.github/workflows/deploy-pages.yml`

**Disparadores:**

- Push a `main`
- Ejecución manual (`workflow_dispatch`)

**Puerta de calidad:** el job `gate` espera a que los workflows `test` y `e2e` estén en éxito para el mismo commit (`github.sha`) antes de construir y publicar.

**Pasos (si el gate abre):**

1. Checkout del commit validado
2. Crear `_site/` y copiar shell + `css/`, `js/`, `data/`, `images/`
3. Subir artefacto y desplegar con `actions/deploy-pages`
4. Verificar HTTP 200 en la URL de Pages

No hay bundler: el sitio es estático. Los `.js` en `data/` deben estar actualizados en el repo antes del merge a `main`.

## Workflows de CI

| Workflow | Cuándo | Rol |
|----------|--------|-----|
| `test.yml` | PR / push `main` | Pruebas Ruby, integridad, imágenes |
| `e2e.yml` | PR / push `main` | Playwright (file://) |
| `lighthouse.yml` | PR | Accesibilidad ≥ 90 |
| `preview.yml` | PR | Artefacto `_site` descargable |
| `deploy-pages.yml` | push `main` | Publicar Pages si CI verde |
| `cleanup-branch.yml` | PR cerrado mergeado | Borrar rama head + prune |

El contexto del check requerido en protección de rama suele ser **`test`** (y opcionalmente Sonar / e2e).

## Configuración inicial (mantenedores)

Con [GitHub CLI](https://cli.github.com/) autenticada:

```bash
bash scripts/setup/setup_github_security.sh
```

Configura:

- Pages con fuente **GitHub Actions**
- Permisos de workflow read/write
- Protección de `main` (PR, check CI, sin force push)

Alternativa manual: **Settings → Pages → Build and deployment → GitHub Actions**.

## Primer despliegue

Tras activar Pages:

1. Merge a `main`, o
2. **Actions → Desplegar en GitHub Pages → Run workflow**

## Consideraciones

- **`main` protegida**: cambios solo vía PR.
- **Ramas**: se borran al mergear (setting del repo + workflow `cleanup-branch`).
- **Repo público**: Pages gratuito requiere visibilidad pública.
- **Tamaño**: muchas imágenes aumentan el artefacto; el workflow lista tamaño y conteo de archivos.
- **Verificación post-deploy (F4-06)**: tras publicar, el job `deploy` hace `curl` a la URL de Pages y falla si no responde HTTP 200 en ~50 s.
- **No modificar paths de assets en raíz** sin actualizar `deploy-pages.yml`.
- **Calidad estática**: ver [SONAR.md](SONAR.md).

## Rollback

Revertir el merge problemático en `main` o restaurar un commit anterior vía PR. El workflow redeployará la versión fusionada.
