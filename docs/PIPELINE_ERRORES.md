# Análisis de errores en pipelines CI/CD — Enciclopedia Animal

> **Fecha del informe:** 12 de julio de 2026  
> **Rama analizada:** `main` (hasta merge del PR #23)  
> **Repositorio:** [ramiro-andres/enciclopediaanimal](https://github.com/ramiro-andres/enciclopediaanimal)  
> **Sitio:** https://ramiro-andres.github.io/enciclopediaanimal/

Este documento resume fallos recientes en los workflows de GitHub Actions que afectan despliegue a `main` y GitHub Pages, sus causas raíz y su correlación con el backlog en [SCRUM.md](SCRUM.md) y [TRAZADO_RUTA.md](TRAZADO_RUTA.md).

---

## Resumen ejecutivo

| Área | Estado actual (post PR #21–#23) |
|------|----------------------------------|
| **Desplegar en GitHub Pages** (`deploy-pages.yml`) | Verde en los últimos merges; el sitio publica correctamente. |
| **e2e** (`e2e.yml`) | Verde tras PR #22 (scroll instantáneo + bumps Dependabot). |
| **test** (`test.yml`) | **Rojo** en el último push a `main` (PR #23): paso JSON→JS detectó `enciclopedia.js` desactualizado respecto a `enciclopedia.json`. |
| **preview** (`preview.yml`) | Sin fallos recientes en el muestreo; solo corre en PRs. |

**Hallazgos principales:**

1. **Pages (arranque del día):** siete fallos consecutivos por GitHub Pages no habilitado / `configure-pages` sin sitio (`Not Found`). Resuelto con activación manual de Pages y ajuste de permisos (Sprint 0, US-DEV-01).
2. **Sintaxis en `js/app.js`:** merge de Sprint 3 + calculadora dejó un `},` duplicado; la app no inicializaba en producción aunque **deploy-pages seguía en verde** (el workflow no ejecuta tests JS). Corregido en PR #21.
3. **E2E glosario:** clic en `.disease-term-link` bloqueado por scroll `smooth` y superposición del encabezado «Términos del glosario relacionados». Corregido en PR #22.
4. **JSON→JS (F4-02 / US-DEV-03):** el paso de CI **funciona** y bloqueó el merge limpio de PR #23: se actualizó `enciclopedia.json` (rutas de imágenes) sin regenerar `enciclopedia.js` en el mismo commit.
5. **Dependabot:** los PRs de bump de Actions pasaron `test` pero fallaron `e2e` hasta aplicar el fix de scroll; los bumps se integraron vía PR #22.

**Despliegue vs calidad:** `deploy-pages.yml` solo copia archivos a `_site` y publica; no valida JS ni datos. Un `main` con `test` rojo puede seguir desplegando contenido desincronizado (riesgo de producción con datos viejos en `.js`).

---

## Inventario de workflows

| Archivo | Disparadores | Jobs / propósito |
|---------|--------------|------------------|
| `deploy-pages.yml` | `push` a `main`, `workflow_dispatch` | `build` (artefacto estático) → `deploy` (Pages) → health check `curl` (F4-06) |
| `test.yml` | PR y `push` a `main` | Ruby minitest, validación clínica, imágenes (F4-03), JSON→JS, integridad |
| `e2e.yml` | PR y `push` a `main` | Playwright Chromium, `file://`, artefacto de reporte |
| `preview.yml` | PR a `main` | Integridad + artefacto `_site` (US-DEV-09) |

Permisos: `deploy-pages` requiere `pages: write` e `id-token: write`; el resto usa `contents: read` (US-DEV-08).

---

## Tabla de errores (runs fallidos relevantes)

| Fecha (UTC) | Run ID | Workflow | Evento / título | Job · paso fallido | Clasificación | Fix |
|-------------|--------|----------|-----------------|-------------------|---------------|-----|
| 2026-07-12 16:01–16:18 | 29199635733 … 29199874187 | Desplegar en GitHub Pages | Push inicial / merges tempranos | `build` → `actions/configure-pages` | **Permisos / Pages no habilitado** (`Get Pages site failed`, `Not Found`) | Activar Pages (origen: GitHub Actions); permisos en workflow; commits de corrección hasta run exitoso ~16:25 |
| 2026-07-12 17:39 | 29202405734 | e2e | Merge sprint-2 | `e2e` → Playwright | **E2E UI** — timeout en clic glosario (`h4` intercepta eventos) | PR #22 (`showView` scroll `auto`) |
| 2026-07-12 17:41 | 29202456754 | e2e | Merge sprint-3 | `e2e` → Playwright | Mismo patrón glosario | PR #22 |
| 2026-07-12 17:42 | 29202505381 | e2e | Merge dose-calculator | `e2e` → `abrirAtlas` (5 tests) | **Sintaxis JS** — `app.js` roto, `__E2E_STATE__.ready` no alcanzado | PR #21 |
| 2026-07-12 19:29 | 29205884432 | e2e | Merge PR #21 | `e2e` → atlas.spec.js:91 | **E2E UI** glosario (app ya cargaba) | PR #22 |
| 2026-07-12 19:30–19:31 | 29205915603 … | e2e | PRs Dependabot | `e2e` → glosario / timeout | **E2E** (misma causa; no regresión de Actions) | Integrado en #22 |
| 2026-07-12 19:35 | 29206104946 | e2e | PR fix/debug-post-merge (intento 1) | `e2e` | E2E glosario | Segundo push en #22 → verde |
| 2026-07-12 20:21–20:24 | 29207582236, 29207647395 | test | PR #23 (PR + merge main) | `test` → **Validar sincronización JSON → JS** | **JSON→JS** — diff en `data/enciclopedia.js` | **Pendiente:** regenerar con `actualizar_datos.sh` y commitear (incluido en PR de este informe) |

Runs consultados: `gh run list --branch main --limit 30`, y listas por workflow `deploy-pages.yml`, `test.yml`, `e2e.yml` (límite 20).

---

## Causas raíz por categoría

### 1. GitHub Pages sin habilitar (histórico)

- **Síntoma:** fallo en `configure-pages` o deploy con HTTP ≠ 200.
- **Raíz:** repositorio nuevo sin sitio Pages configurado para «GitHub Actions».
- **Backlog:** US-DEV-01 (Hecho), F4-06 health check añadido después.

### 2. Error de sintaxis en `js/app.js`

- **Síntoma:** sitio en blanco / sin razas; E2E falla en `abrirAtlas`.
- **Raíz:** conflicto de merge (Sprint 3 + calculadora de dosis).
- **Backlog:** DoD exige tests verdes, pero **deploy no depende de `test`** → despliegue «exitoso» con app rota.
- **Fix:** PR #21.

### 3. E2E — navegación enfermedad → glosario

- **Síntoma:** `locator.click` timeout; mensaje «element is not stable» / `h4` intercepta pointer events.
- **Raíz:** `scrollIntoView({ behavior: 'smooth' })` durante transición de vista.
- **Backlog:** US-DEV-04 (marcado Hecho en Sprint 2); prueba en `tests/e2e/atlas.spec.js:80`.
- **Fix:** PR #22.

### 4. Desincronización JSON → JS

- **Síntoma:** `git diff --exit-code` falla tras `actualizar_datos.sh` en CI.
- **Raíz:** PR #23 modificó `enciclopedia.json` (rutas `images/*.jpg`) sin commitear `enciclopedia.js`.
- **Backlog:** F4-02, US-DEV-03 (implementado en `test.yml`; entrada en SCRUM aún dice «Pendiente» — deuda de documentación).
- **Prevención:** ejecutar `bash actualizar_datos.sh` antes de cada commit que toque `data/*.json`; añadir recordatorio en checklist de PR.

### 5. Imágenes (F4-03)

- **Síntoma potencial:** paso «Verificar imágenes de razas» con `list_missing_images.rb`.
- **Estado:** PR #23 dejó 0 faltantes en imágenes; el fallo en CI fue solo JSON→JS, no F4-03.

### 6. Dependabot

- **Síntoma:** PRs de bump con `e2e` rojo, `test` verde.
- **Raíz:** E2E preexistente, no incompatibilidad de Actions (checkout v7, etc.).
- **Backlog:** F4-01; bumps mergeados en #22.

---

## Correlación con backlog SCRUM / TRAZADO_RUTA

| ID backlog | Relación con fallos observados |
|------------|--------------------------------|
| **US-DEV-01** | Pages estable tras configuración inicial |
| **US-DEV-02** | Pipeline `test` — único fallo reciente en main (#23) |
| **US-DEV-03 / F4-02** | Paso JSON→JS evitó silenciosamente datos viejos en JS; requiere alinear estado SCRUM a «Hecho» |
| **US-DEV-04** | E2E expuso regresiones de UI y JS; job separado `e2e.yml` en push a main |
| **US-DEV-09** | `preview.yml` valida integridad en PR (no sustituye JSON→JS en merge) |
| **US-DEV-08** | Permisos mínimos en preview/test vs pages en deploy |
| **US-UX-04** | Escenario E2E de enlaces cruzados glosario ↔ enfermedades |
| **F4-03** | Job de imágenes en `test.yml` |
| **F4-06** | Health check post-deploy en `deploy-pages.yml` |
| **F4-05** | Pendiente — badges CI en README para visibilidad de `test` rojo en main |

**Tareas de backlog que habrían evitado fallos:**

| Prioridad | Tarea sugerida | Evita |
|-----------|----------------|-------|
| Alta | **Gate de deploy:** `deploy-pages` con `needs` de workflow `test` + `e2e` (o `workflow_run`) | Publicar con `test` rojo o app rota |
| Alta | **US-DEV-03 doc:** marcar Hecho en SCRUM + checklist en CONTRIBUIR | Repetición PR #23 |
| Media | **F4-05** badges en README | No detectar `test` rojo en main sin abrir Actions |
| Media | **US-DEV-05** limpieza ramas Dependabot mergeadas | Ruido en PRs |
| Baja | **F4-04** optimización artefactos deploy | No es causa de fallos actuales |

---

## Estado post-fixes (#21, #22, #23, Dependabot)

| PR | Contenido | deploy-pages | test | e2e |
|----|-----------|--------------|------|-----|
| #21 | Fix sintaxis `app.js` | OK | OK | Falló (glosario) |
| #22 | Scroll E2E + bumps Actions | OK | OK | OK |
| #23 | Imágenes JPG + JSON | OK | **Falló** (JSON→JS) | OK |

**Conclusión:** producción (Pages) y E2E están alineados; la **calidad de datos en runtime** en `main` puede seguir desincronizada hasta regenerar `enciclopedia.js`. El paso F4-06 (curl) no detecta contenido JS obsoleto.

---

## Recomendaciones de backlog priorizadas

1. **P0 — Sincronizar `enciclopedia.js` en `main`** (fix inmediato, 1 línea de diff típico tras `actualizar_datos.sh`).
2. **P1 — Requerir CI verde para deploy** (nueva historia DevOps o extensión US-DEV-02): evitar el caso PR #21 (deploy verde, app rota).
3. **P1 — Actualizar SCRUM:** US-DEV-03 y US-DEV-04 coherentes con Sprint 2/3 entregado; añadir lección aprendida PR #23 en retrospectiva.
4. **P2 — F4-05** badges `test` / `deploy-pages` / `e2e` en README.
5. **P2 — Pre-commit o plantilla PR:** «Si tocaste `data/*.json`, corre `actualizar_datos.sh`».

---

## Checklist de prevención (mantenedor / contribuidor)

- [ ] Tras editar `data/*.json`, ejecutar `bash actualizar_datos.sh` y commitear los `.js` generados.
- [ ] Antes de merge, verificar los tres workflows en la PR: `test`, `e2e`, `preview` (si aplica).
- [ ] Tras merges grandes (varias features), abrir el sitio y comprobar `__E2E_STATE__` o carga de razas — no confiar solo en deploy verde.
- [ ] Revisar PRs Dependabot con `e2e`, no solo `test`.
- [ ] Si `deploy-pages` falla en health check (F4-06), esperar propagación CDN o revisar URL de Pages en ajustes del repo.
- [ ] Mantener `docs/DESPLIEGUE.md` alineado con permisos y activación de Pages.

---

## Referencias

- Workflows: `.github/workflows/`
- Comandos útiles:
  - `gh run list --branch main --limit 30`
  - `gh run view <id> --log-failed`
- Documentación relacionada: [DESPLIEGUE.md](DESPLIEGUE.md), [SCRUM.md](SCRUM.md), [TRAZADO_RUTA.md](TRAZADO_RUTA.md) (fase F4).

---

*Generado en el marco del análisis de backlog de pipelines — rama `docs/pipeline-backlog-analysis`.*
