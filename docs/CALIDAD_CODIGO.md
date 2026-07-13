# Auditoría de calidad de código

**Fecha:** 2026-07-13  
**Rama:** `docs/calidad-codigo-audit`  
**Base:** `main` @ `296c2dc`  
**Alcance:** frontend estático (`js/`, `css/`, `index.html`, `sw.js`), scripts Ruby de datos, suite de tests.  
**Enfoque:** diagnóstico honesto + fixes mínimos de alto riesgo. Sin mega-refactor.  
**Seguimiento pre-merge:** hallazgos accionables corregidos / mitigados / diferidos (esta revisión).

---

## Resumen ejecutivo

**Salud general: 🟡 amarillo (aceptable para continuar features, con deuda de modularización parcialmente mitigada).**

Enciclopedia Animal es un sitio estático en GitHub Pages **sin bundler ni framework**. En ese contexto, un `app.js` monolítico **no es automáticamente “espagueti malo”**: reduce tooling, facilita el precache del service worker y mantiene el despliegue simple. Sí sigue siendo una **bomba de mantenibilidad creciente**, pero el primer corte vertical (`js/utils.js` + `js/tools.js`) ya empezó a bajar riesgo sin romper UX.

Lo positivo pesa: hay `esc()` completo (en `AtlasUtils`), suite de seguridad estática, i18n ES/EN con parity tests, SW versionado (`atlas-v17`), chunks de datos, y pipeline Ruby + tests por sprint + contratos JS (`node --check`).

**¿Hay que parar features para un refactor urgente?** No. Se puede seguir entregando valor. Conviene **seguir extrayendo verticales en sprints futuros** (urgency/search/catalog) y no dejar crecer `app.js`/`styles.css` sin freno.

### Fixes aplicados (auditoría + seguimiento pre-merge)

| Riesgo | Estado | Fix |
|--------|--------|-----|
| `esc()` no escapaba `"` / `'` | **CORREGIDO** | Escape completo en `js/utils.js` (`AtlasUtils.esc`); `App.esc` delega |
| `onerror` interpolaba rutas en JS inline | **CORREGIDO** | `data-fallback` + `getAttribute` |
| Nombres/ids sin `esc()` en nav/chips/cards | **CORREGIDO** | Escape consistente (rama auditoría) |
| `renderPanel(title)` sin escape | **CORREGIDO** | `this.esc(title)` |
| Strings UI hardcodeados ES | **MITIGADO** | Claves i18n en vistas tocadas; puede quedar residual |
| Monolito `app.js` | **MITIGADO** | Extraídos `js/utils.js` + `js/tools.js` (cálculos); App fachada |
| CSS monolítico | **DIFERIDO** | Sin fragmentar (tests acoplados a `styles.css`; sin bundler) |
| Tests runtime JS débiles | **MITIGADO** | `tests/test_js_contracts.rb` (`node --check`, esc runtime, smoke App) |
| Ruby `clinical_disease_extended.rb` duplicado | **CORREGIDO** | Stub DEPRECATED → `clinical_disease_extended_data.rb` |
| Función muerta `nameMatches` | **CORREGIDO** | Eliminada |

---

## Métricas

| Artefacto | Métrica | Valor |
|-----------|--------|------:|
| `js/app.js` | Líneas | ~4573 (bajó vs ~4643 tras extracción) |
| `js/utils.js` | Líneas | ~50 |
| `js/tools.js` | Líneas | ~120 |
| `js/app.js` | Métodos en `App` | ~200 |
| `js/app.js` | Métodos `render*` | 48 |
| `js/app.js` | Usos de `innerHTML` | ~60 |
| `js/app.js` | Llamadas a `.esc(` | ~454 |
| `js/i18n.js` | Líneas | ~1057 |
| `css/styles.css` | Líneas | ~6304 |
| `css/styles.css` | Variables en `:root` | ~27+ (más overrides por tema) |
| `index.html` | Líneas | ~630 |
| `sw.js` | Caché | `atlas-v17` |
| `scripts/data/*.rb` | Archivos | 44 (1 stub deprecated) |
| `tests/test_*.rb` | Archivos | 17 |

### Métodos más grandes (`app.js`)

| Líneas (aprox.) | Método |
|----------------:|--------|
| 157 | `bindEvents` |
| 127 | `renderFlashcards` |
| 124 | `openRouteFromHash` |
| 123 | `showBreedDetail` |
| 120 | `renderSearchResults` |
| 117 | `renderTriaje` |
| 102 | `showDiseaseDetail` |

---

## Buenas prácticas que SÍ hay

1. **Escape HTML consciente (`esc`)** — en `AtlasUtils` + fachada `App.esc`; tests de seguridad y contratos JS.
2. **I18n (`js/i18n.js`)** — ES/EN, `data-i18n*`, parity en tests, evento `atlas:langchange`.
3. **Service Worker** — precache de shell + datos críticos + módulos nuevos, caché de imágenes SWR, versión `atlas-v*`.
4. **Seguridad estática** — `tests/test_security.rb` (secretos, `eval`/`document.write`, payloads en JSON, `rel=noopener`).
5. **Arquitectura de datos offline** — JSON fuente → scripts Ruby → JS globales / chunks; documentado en `docs/ARQUITECTURA.md`.
6. **Variables CSS y tema** — `:root` + dark mode; `AtlasUtils.resolveTheme`.
7. **Suite de regresión por sprint** — tests Minitest + `ejecutar_pruebas.sh` + validadores de integridad/clínico.
8. **Separación analytics** — `analytics.js` / `analytics-config.js` pequeños y opcionales.
9. **Routing por hash** con flag `isRoutingFromHash` (evita bucles básicos).
10. **Contexto Pages sin bundler** — decisión coherente con el objetivo del producto.
11. **Módulos verticales sin bundler** — `utils.js` / `tools.js` cargados por `<script>` ordenados.

---

## Hallazgos por severidad

### Alta

#### A1. `esc()` incompleto para atributos — **CORREGIDO**

**Antes:** solo `&`, `<`, `>`. Valores en `data-*`, `alt`, `href` generados con `esc()` seguían vulnerables a breakout con `"` / `'` si un dato malicioso entraba al repo.

**Ahora:** `AtlasUtils.esc` escapa también `&quot;` y `&#39;`. `App.esc` delega. Tests de seguridad + `test_js_contracts.rb` verifican ambos.

**Riesgo residual:** datos siguen siendo confianza en el repo (no hay backend). Defensa en profundidad mejorada.

#### A2. `onerror` con path interpolado en JS — **CORREGIDO**

`renderDiseaseImage` / `renderBreedImage` usan `data-fallback="${this.esc(...)}"` + `this.src=this.getAttribute('data-fallback')`.

---

### Media

#### M1. Monolito `App` (~4.6k LOC) — **MITIGADO** (extracción incremental)

Extraído sin bundler:

- `js/utils.js` — `esc`, reduced-motion, theme resolve  
- `js/tools.js` — RER/MER factors, fluid profiles, BCS scores, dose math  

`App` sigue siendo fachada (mismos métodos públicos). **Pendiente (P1):** `app-search.js`, `app-urgency.js`, `app-catalog.js`.

#### M2. CSS monolítico (~6300 líneas) — **DIFERIDO**

**Por qué no ahora:** sin bundler, varios `<link>` o `@import` encarecen SW/precache y **decenas de tests de sprint leen variables directamente desde `styles.css`**. Comentario de aplazamiento en la cabecera del archivo. Partir en sprints con concatenación de deploy o actualizar tests en bloque.

#### M3. UI + datos mezclados — **DIFERIDO** (parcialmente ayudado por tools)

Los `render*` siguen mezclando filtro + HTML + listeners. La lógica pura de calculadoras ya vive en `AtlasTools`.

#### M4. Cobertura de tests runtime JS — **MITIGADO**

Añadido `tests/test_js_contracts.rb`: `node --check` de `js/*` + SW/datos, esc runtime en Node, smoke de métodos App, cableado de módulos, stub Ruby deprecated. Playwright e2e sigue siendo la red de comportamiento DOM.

#### M5. Scripts Ruby duplicados — **CORREGIDO**

`clinical_disease_extended.rb` es stub DEPRECATED que `require_relative` a `clinical_disease_extended_data.rb` (fuente activa). Datos activos intactos.

#### M6. Estado global mutable — **DIFERIDO**

Sigue siendo coherente con SPA sin framework. No urgente.

---

### Baja

#### B1. Función muerta `nameMatches` — **CORREGIDO**

Eliminada de `app.js`.

#### B2. Strings / i18n inconsistentes — **MITIGADO** / residual **DIFERIDO**

Parte corregida en auditoría; grep periódico sigue en P5.

#### B3. Mix ES/EN dominio vs API — **DIFERIDO** (aceptable)

#### B4. Magic numbers / strings — **DIFERIDO** (parcialmente centralizado en `AtlasTools`)

#### B5. `index.html` denso — **DIFERIDO**

#### B6. Dependencias circulares — N/A (sin módulos ES)

---

## ¿Es “código espagueti”?

**Veredicto:** **deuda estructural moderada, no caos** (sin cambio tras esta pasada).

| Señal de espagueti | ¿Presente? |
|--------------------|------------|
| Funciones anónimas interminables anidadas | Poco: métodos grandes pero planos |
| Copy-paste masivo sin abstracción | Parcial (muchos `render*` similares) |
| Estado global inmanejable | Sí, creciente |
| Sin escape / sin tests | No |
| Imposible seguir el flujo | No: hash routing + vistas con nombres claros |

---

## Recomendaciones priorizadas (sprints futuros)

### P0 — hecho / mantener

- [x] Mantener y endurecer `esc()` + tests de seguridad.
- [x] No interpolar datos en handlers JS inline.
- [x] Seguir pasando `ejecutar_pruebas.sh` en cada PR.
- [x] Contratos JS (`node --check` + smoke App).

### P1 — refactor incremental — **en curso**

1. [x] `js/utils.js` + `js/tools.js` (esta pasada)  
2. [ ] `js/app-search.js` — búsqueda / index / synonyms  
3. [ ] `js/app-urgency.js` — tox, emergencias, triaje  
4. [ ] `js/app-catalog.js` — razas / enfermedades / compare / favoritos  

Regla: **cada PR de feature que toque un área grande debe reducir o no aumentar LOC de `app.js`**.

### P2 — CSS — **DIFERIDO**

- Partir `styles.css` cuando exista concatenación en deploy o se actualicen tests.
- Auditar `!important` y duplicados responsive.

### P3 — datos / Ruby

- [x] Deprecar `clinical_disease_extended.rb` duplicado.
- [ ] Índice `scripts/data/README` de scripts vivos vs one-shot.
- [ ] Reforzar `update_enciclopedia_full.rb` como puerta oficial.

### P4 — tests

- [x] Contratos JS mínimos.
- [ ] Ampliar e2e Playwright a routing hash, búsqueda y 1 calculadora.

### P5 — i18n hygiene — **DIFERIDO** (proceso continuo)

---

## Decisión de producto / engineering

| Pregunta | Respuesta |
|----------|-----------|
| ¿Refactor urgente antes de features? | **No** |
| ¿Se puede continuar el backlog? | **Sí**, con disciplina de no hinchar el monólito |
| ¿Prioridad de higiene en próximos 2–3 sprints? | Extraer search/urgency; partir CSS con tooling; README de scripts |
| Salud | **🟡** — sólido en seguridad/datos; modularidad front iniciada |

---

## Checklist de revisión continua

- [ ] ¿Nuevo HTML dinámico usa `this.esc(...)` / `AtlasUtils.esc` en texto y atributos?
- [ ] ¿Handlers inline evitan interpolar datos?
- [ ] ¿Nueva vista añade método a `App` o a un módulo extraído (`tools`/`utils`/…)?
- [ ] ¿Claves i18n ES+EN + test parity?
- [ ] ¿SW `CACHE_VERSION` bump si cambia shell?
- [ ] ¿`bash ejecutar_pruebas.sh` verde?
