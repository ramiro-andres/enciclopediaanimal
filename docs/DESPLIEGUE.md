# Despliegue

Enciclopedia Animal se publica en **GitHub Pages** con **GitHub Actions** (sin Jekyll).

## URL de producción

https://ramiro-andres.github.io/enciclopediaanimal/

## Workflow de despliegue

Archivo: `.github/workflows/deploy-pages.yml`

**Disparadores:**

- Push a `main`
- Ejecución manual (`workflow_dispatch`)

**Pasos:**

1. Checkout del repositorio
2. Crear `_site/` y copiar:
   - `index.html`, `.nojekyll`
   - `css/`, `js/`, `data/`, `images/`
3. Subir artefacto y desplegar con `actions/deploy-pages`

No hay paso de build de bundler: el sitio es estático. Los `.js` en `data/` deben estar actualizados en el repo antes del merge a `main`.

## CI de pruebas

Archivo: `.github/workflows/test.yml`

- Se ejecuta en PRs y pushes a `main`
- Instala Ruby 3.3 y minitest
- Corre `ruby tests/test_enciclopedia.rb`

El contexto del check requerido en protección de rama es **`test`**.

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

- **`main` protegida**: cambios solo vía PR aprobado.
- **Repo público**: Pages gratuito requiere visibilidad pública.
- **Tamaño**: muchas imágenes aumentan el artefacto; el workflow lista tamaño y conteo de archivos.
- **No modificar paths de assets en raíz** sin actualizar `deploy-pages.yml`.

## Rollback

Revertir el merge problemático en `main` o restaurar un commit anterior vía PR. El workflow redeployará la versión fusionada.
