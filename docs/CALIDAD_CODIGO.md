# Auditoría de calidad de código

**Fecha:** 2026-07-13  
**Rama:** `docs/calidad-codigo-audit`  
**Base:** `main` @ `296c2dc`  
**Alcance:** frontend estático (`js/`, `css/`, `index.html`, `sw.js`), scripts Ruby de datos, suite de tests.  
**Enfoque:** diagnóstico honesto + fixes mínimos de alto riesgo. Sin mega-refactor.

---

## Resumen ejecutivo

**Salud general: 🟡 amarillo (aceptable para continuar features, con deuda de modularización).**

Enciclopedia Animal es un sitio estático en GitHub Pages **sin bundler ni framework**. En ese contexto, un `app.js` monolítico de ~4.6k líneas **no es automáticamente “espagueti malo”**: reduce tooling, facilita el precache del service worker y mantiene el despliegue simple. Sí es una **bomba de mantenibilidad creciente**: demasiadas responsabilidades en un solo objeto, CSS grande, y mezcla UI/datos/estado.

Lo positivo pesa: hay `esc()`, suite de seguridad estática, i18n ES/EN con parity tests, SW versionado, chunks de datos, y pipeline Ruby + tests por sprint.

**¿Hay que parar features para un refactor urgente?** No. Se puede seguir entregando valor. Conviene **planificar extracción modular en sprints futuros** (no un big-bang) y no dejar crecer `app.js`/`styles.css` sin freno.

### Fixes mínimos aplicados en esta auditoría

| Riesgo | Fix |
|--------|-----|
| `esc()` no escapaba `"` / `'` → breakout en atributos HTML | Escape completo para texto y atributos |
| `onerror` interpolaba rutas en JS inline | Fallback vía `data-fallback` + `getAttribute` |
| Nombres/ids de animales sin `esc()` en nav/chips/cards/búsqueda | Escape consistente |
| `renderPanel(title)` sin escape | `this.esc(title)` |
| Strings UI hardcodeados ES en búsqueda / enlaces cruzados | Reuso/añadido de claves i18n |

---

## Métricas

| Artefacto | Métrica | Valor |
|-----------|--------|------:|
| `js/app.js` | Líneas | ~4643 |
| `js/app.js` | Métodos en `App` | ~203 |
| `js/app.js` | Métodos `render*` | 48 |
| `js/app.js` | Usos de `innerHTML` | ~60 |
| `js/app.js` | Llamadas a `.esc(` | ~454 |
| `js/app.js` | Métodos ≥100 líneas | 7 |
| `js/app.js` | Métodos ≥80 líneas | 10 |
| `js/i18n.js` | Líneas | ~1057 |
| `css/styles.css` | Líneas | ~6304 |
| `css/styles.css` | Variables en `:root` | ~27 (más overrides por tema) |
| `css/styles.css` | `!important` | ~23 |
| `index.html` | Líneas | ~628 |
| `index.html` | `id=` | ~130 |
| `sw.js` | Líneas | ~105 |
| `scripts/data/*.rb` | Archivos | 44 |
| `tests/test_*.rb` | Archivos | 16 |

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

1. **Escape HTML consciente (`esc`)** — patrón habitual en plantillas; tests de seguridad exigen su presencia.
2. **I18n (`js/i18n.js`)** — ES/EN, `data-i18n*`, parity en tests, evento `atlas:langchange`.
3. **Service Worker** — precache de shell + datos críticos, caché de imágenes SWR, versión `atlas-v*`.
4. **Seguridad estática** — `tests/test_security.rb` (secretos, `eval`/`document.write`, payloads en JSON, `rel=noopener`).
5. **Arquitectura de datos offline** — JSON fuente → scripts Ruby → JS globales / chunks; documentado en `docs/ARQUITECTURA.md`.
6. **Variables CSS y tema** — `:root` + dark mode; no es un CSS totalmente ad hoc sin tokens.
7. **Suite de regresión por sprint** — tests Minitest + `ejecutar_pruebas.sh` + validadores de integridad/clínico.
8. **Separación analytics** — `analytics.js` / `analytics-config.js` pequeños y opcionales.
9. **Routing por hash** con flag `isRoutingFromHash` (evita bucles básicos).
10. **Contexto Pages sin bundler** — decisión coherente con el objetivo del producto.

---

## Hallazgos por severidad

### Alta

#### A1. `esc()` incompleto para atributos (corregido en esta rama)

**Antes:** solo `&`, `<`, `>`. Valores en `data-*`, `alt`, `href` generados con `esc()` seguían vulnerables a breakout con `"` / `'` si un dato malicioso entraba al repo.

**Ahora:** escapa también `&quot;` y `&#39;`. Tests de seguridad verifican ambos.

**Riesgo residual:** datos siguen siendo confianza en el repo (no hay backend). Defensa en profundidad mejorada.

#### A2. `onerror` con path interpolado en JS (corregido)

`renderDiseaseImage` insertaba el fallback dentro de un string JS en el atributo `onerror`. En atributos HTML las entidades se decodifican antes de ejecutar el handler → el escape solo no bastaba.

**Fix:** `data-fallback="${this.esc(...)}"` + `this.src=this.getAttribute('data-fallback')`.

---

### Media

#### M1. Monolito `App` (~4.6k LOC / ~203 métodos)

Un único objeto mezcla: carga de chunks, routing, búsqueda, diccionario, toxicología, triaje, calculadoras, favoritos, compare, flashcards, SEO/meta, tema, i18n glue, render de casi todas las vistas.

**No es “código espagueti clásico”** (hay métodos nombrados y algo de estructura), pero el **acoplamiento vía estado mutable compartido** es alto (~60 propiedades de estado/config en el mismo objeto).

**Impacto:** onboarding lento, riesgo de regresiones al tocar features lejanas, PRs grandes.

#### M2. CSS monolítico (~6300 líneas)

Un solo `styles.css` concentra welcome, tools, urgencia, dark mode, print, etc. Hay tokens (`:root`), pero también repetición de bloques responsive y ~23 `!important`.

**Impacto:** conflictos visuales, miedo a tocar estilos globales, archivo difícil de revisar en PR.

#### M3. UI + datos mezclados en los mismos métodos

Patrón dominante: `renderX()` filtra datos, construye HTML gigante y hace `addEventListener` en el mismo bloque (`bindEvents` de 157 líneas concentra gran parte del wiring).

**Impacto:** difícil testear lógica pura en el navegador; los tests Ruby cubren contrato estático, no comportamiento DOM de cada vista.

#### M4. Cobertura de tests: fuerte en contrato, débil en runtime JS

Hay buena red de seguridad/regresión/sprint sobre archivos y datos. Playwright existe (`tests/e2e/`), pero la lógica de `App` no está modularizada para unit tests JS.

**Deuda:** falsos negativos posibles en routing, búsqueda y calculadoras hasta que fallen e2e o QA manual.

#### M5. Scripts Ruby de datos: acumulo histórico

44 scripts en `scripts/data/`, varios `production_breeds_batch*`, librerías clínicas grandes, y **duplicado byte-idéntico**:

- `clinical_disease_extended.rb`
- `clinical_disease_extended_data.rb` (el que se `require` de verdad)

El primero parece residual.

#### M6. Estado global mutable

`const App = { ... }` + `window.I18n` + `window.ENCICLOPEDIA_*` + `localStorage` keys `atlas_*`. Coherente con SPA sin framework, pero cualquier feature nueva añade más flags (`triaje*`, `flashcards*`, `fluid*`, …).

---

### Baja

#### B1. Función muerta `nameMatches`

Definida en `app.js` y no referenciada. Baja prioridad; candidata a borrar en limpieza.

#### B2. Strings / i18n inconsistentes (parcialmente mitigado)

Quedaban literales ES en UI dinámica (`Ver raza →`, `Enfermedades relacionadas`). Parte corregida; puede haber más en vistas menos usadas.

#### B3. Mix ES/EN en dominio vs API

API de métodos en inglés (`render`, `load`, `bind`), datos y claves de dominio en español (`enfermedades`, `gravedad`, `razas`). Aceptable y documentable, pero aumenta carga cognitiva.

#### B4. Magic numbers / strings

p.ej. `COMPARE_MAX: 3`, factores de gotas, scores BCS, URLs hardcodeadas (parcialmente centralizadas en constantes del objeto — bien). Algunas literales de región/país en `REGION_MACRO_GROUPS`.

#### B5. `index.html` denso (~130 ids)

Toda la shell SPA vive en un HTML. Funciona, pero complica accesibilidad/revisión. No es bloqueante.

#### B6. Dependencias circulares

No hay módulos ES; no hay ciclos de `import`. El “ciclo” práctico es **hash ↔ render ↔ state** dentro de `App` (acoplamiento interno, no circularidad de paquetes).

---

## ¿Es “código espagueti”?

**Veredicto:** **deuda estructural moderada, no caos**.

| Señal de espagueti | ¿Presente? |
|--------------------|------------|
| Funciones anónimas interminables anidadas | Poco: métodos grandes pero planos |
| Copy-paste masivo sin abstracción | Parcial (muchos `render*` similares) |
| Estado global inmanejable | Sí, creciente |
| Sin escape / sin tests | No |
| Imposible seguir el flujo | No: hash routing + vistas con nombres claros |

Para un atlas estático en Pages, el monólito fue una elección **racional**. El problema es el **crecimiento acumulado post sprints 1–14**, no el diseño inicial.

---

## Recomendaciones priorizadas (sprints futuros)

### P0 — ya hecho / mantener

- Mantener y endurecer `esc()` + tests de seguridad.
- No interpolar datos en handlers JS inline.
- Seguir pasando `ejecutar_pruebas.sh` en cada PR.

### P1 — refactor incremental (sin detener features)

Extraer de `app.js` por **verticales** (archivos globales sin bundler, vía `<script>` ordenados o un solo concatenado en build futuro):

1. `js/app-search.js` — búsqueda / index / synonyms  
2. `js/app-tools.js` — dosis, RER/MER, fluidos, unidades, BCS  
3. `js/app-urgency.js` — tox, emergencias, triaje  
4. `js/app-catalog.js` — razas / enfermedades / compare / favoritos  

Regla: **cada PR de feature que toque un área grande debe reducir o no aumentar LOC de `app.js`**.

### P2 — CSS

- Partir `styles.css` en capas: `base.css`, `layout.css`, `views/*.css`, `theme-dark.css` (concatenar en deploy o varios `<link>`).
- Auditar `!important` y duplicados responsive.

### P3 — datos / Ruby

- Eliminar o consolidar `clinical_disease_extended.rb` si no se usa.
- Índice `scripts/data/README` de scripts “vivos” vs one-shot de sprint.
- Evitar nuevos batches eternamente aditivos sin comando único `update_enciclopedia_full.rb` (ya existe: reforzar como puerta oficial).

### P4 — tests

- Ampliar e2e Playwright a routing hash, búsqueda y 1 calculadora.
- Test unitario mínimo de `esc()` en Ruby (ya parcialmente cubierto) o harness JS ligero si se introducen módulos.

### P5 — i18n hygiene

- Grep periódico de literales ES/EN en `app.js` templates.
- Mantener parity ES/EN obligatoria (ya hay test).

---

## Decisión de producto / engineering

| Pregunta | Respuesta |
|----------|-----------|
| ¿Refactor urgente antes de features? | **No** |
| ¿Se puede continuar el backlog? | **Sí**, con disciplina de no hinchar el monólito |
| ¿Prioridad de higiene en próximos 2–3 sprints? | Extraer tools/urgency; partir CSS; limpiar scripts Ruby muertos |
| Salud | **🟡** — sólido en seguridad/datos; frágil en modularidad front |

---

## Checklist de revisión continua

- [ ] ¿Nuevo HTML dinámico usa `this.esc(...)` en texto y atributos?
- [ ] ¿Handlers inline evitan interpolar datos?
- [ ] ¿Nueva vista añade método a `App` o a un módulo extraído?
- [ ] ¿Claves i18n ES+EN + test parity?
- [ ] ¿SW `CACHE_VERSION` bump si cambia shell?
- [ ] ¿`bash ejecutar_pruebas.sh` verde?
