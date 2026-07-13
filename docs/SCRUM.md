# Backlog Scrum — Enciclopedia Animal

> **Última actualización:** 13 de julio de 2026 (Sprint 12 en progreso)  
> **Sitio en producción:** https://ramiro-andres.github.io/enciclopediaanimal/  
> **Repositorio:** [ramiro-andres/enciclopediaanimal](https://github.com/ramiro-andres/enciclopediaanimal)

Documento de planificación ágil con épicas, historias de usuario, tareas técnicas y criterios de aceptación. Complementa el [trazado de ruta por fases](TRAZADO_RUTA.md).

---

## Convenciones

| Campo | Valores |
|-------|---------|
| **Estado** | Hecho · En progreso · Pendiente · Backlog |
| **Prioridad** | Alta · Media · Baja |
| **Story points** | Fibonacci: 1, 2, 3, 5, 8 |

**Formato de historias:** Como **[rol]**, quiero **[acción]**, para **[beneficio]**.

---

## Definition of Ready (DoR)

Una historia entra al sprint solo si cumple **todas** estas condiciones:

- [ ] Tiene criterios de aceptación claros y verificables.
- [ ] Las dependencias técnicas están resueltas o identificadas (scripts, datos, CI).
- [ ] El alcance cabe en un sprint (≤8 puntos) o está descompuesta en historias más pequeñas.
- [ ] Existe criterio de prueba: test Ruby, verificación manual documentada o checklist de CI.
- [ ] No requiere secretos no configurados en el repositorio o en GitHub Actions.
- [ ] Impacto en datos documentado (`enciclopedia.json`, `diccionario_medicos.json`, imágenes).

---

## Definition of Done (DoD)

Una historia se marca **Hecho** solo si cumple **todas** estas condiciones:

- [ ] Código mergeado en `main` (o PR aprobado y listo para merge).
- [ ] `bash ejecutar_pruebas.sh` pasa localmente.
- [ ] Workflow `test` en GitHub Actions verde.
- [ ] Si hay cambios en `data/*.json`, se regeneraron los `.js` con `actualizar_datos.sh`.
- [ ] Sin rutas de imágenes rotas en las entradas tocadas.
- [ ] Documentación actualizada si cambia flujo de desarrollo, despliegue o contribución.
- [ ] Despliegue en GitHub Pages exitoso cuando el cambio afecta el sitio publicado.
- [ ] Criterios de aceptación de la historia verificados.

---

## Sprint 0 — Completado

**Objetivo del sprint:** Entregar la enciclopedia veterinaria estática con contenido enriquecido, despliegue automatizado y base de gobernanza del repositorio.

**Duración:** Iteraciones acumuladas (PRs #1–#7, mergeadas el 12 jul 2026).

**Velocidad entregada:** ~89 story points (estimación retrospectiva).

### Retrospectiva

| Qué salió bien | Qué mejorar | Acciones |
|----------------|-------------|----------|
| CI/CD con test + deploy-pages operativo desde el inicio | Falta validación automática JSON → JS en CI | Backlog: US-DEV-03 |
| 355 razas, 2 099 enfermedades y diccionario de 527 términos | Términos del diccionario no enlazan a secciones clínicas | Backlog: US-UX-04 |
| Reorganización clara (`scripts/`, `docs/`) | Ramas locales obsoletas sin limpiar | Backlog: US-DEV-05 |
| Modal de disclaimer cumple requisito legal/educativo | Aparece en cada carga (puede ser intrusivo) | Evaluar persistencia por sesión en sprint futuro |
| Sitio 100 % estático, sin servidor local | Sin PWA ni analytics | Backlog: US-UX-06, US-DEV-06 |
| Todos los PRs mergeados; producción al día | Sin tests E2E en navegador | Backlog: US-DEV-04 |

---

## Épicas entregadas (Sprint 0)

### EP-01 — Contenido y conocimiento veterinario

#### US-CON-01 · Diccionario médico interactivo

**Como** estudiante o profesional veterinario, **quiero** consultar un glosario con búsqueda y filtros por categoría, **para** entender términos clínicos mientras exploro razas y enfermedades.

| Campo | Valor |
|-------|-------|
| Estado | Hecho |
| Prioridad | Alta |
| Story points | 8 |

**Tareas técnicas:**
- [x] Script `scripts/data/build_medical_dictionary.rb` genera `data/diccionario_medicos.json`
- [x] 527 términos en 15 categorías médicas
- [x] Vista glosario en `js/app.js` con búsqueda y filtro por categoría
- [x] Enlace «Glosario» en cabecera del sitio
- [x] Build JS vía `actualizar_datos.sh` → `data/diccionario_medicos.js`

**Criterios de aceptación:**
- [x] Glosario accesible desde cualquier vista
- [x] Búsqueda por texto filtra términos en tiempo real
- [x] Filtro por categoría muestra solo términos de esa categoría
- [x] Test `test_diccionario_medicos` pasa en suite Ruby

---

#### US-CON-02 · Razas productivas de Colombia (batch 6)

**Como** productor agropecuario colombiano, **quiero** encontrar razas locales con fichas completas e imágenes, **para** tomar decisiones informadas sobre especies productivas en mi región.

| Campo | Valor |
|-------|-------|
| Estado | Hecho |
| Prioridad | Alta |
| Story points | 5 |

**Tareas técnicas:**
- [x] Script `scripts/data/production_breeds_batch6_colombia.rb`
- [x] 22 razas colombianas añadidas al dataset
- [x] Imágenes descargadas o placeholder SVG por raza
- [x] Integración en `enciclopedia.json` vía pipeline de datos

**Criterios de aceptación:**
- [x] Razas colombianas visibles en explorador por categoría animal
- [x] Cada raza tiene imagen (JPG >8 KB o SVG)
- [x] Ficha incluye descripción y datos básicos

---

#### US-CON-03 · Nutrición detallada por raza

**Como** veterinario o nutricionista animal, **quiero** ver perfiles nutricionales específicos por raza, **para** recomendar dietas acordes a cada especie.

| Campo | Valor |
|-------|-------|
| Estado | Hecho |
| Prioridad | Media |
| Story points | 5 |

**Tareas técnicas:**
- [x] Script `scripts/data/breed_nutrition_profiles.rb`
- [x] Campos de nutrición en estructura de raza del JSON
- [x] Renderizado de sección nutrición en vista detalle de raza

**Criterios de aceptación:**
- [x] Vista de raza muestra bloque de nutrición cuando hay datos
- [x] Información coherente con categoría animal de la raza

---

#### US-CON-04 · Imágenes en tarjetas de enfermedades

**Como** usuario de la enciclopedia, **quiero** ver imágenes representativas en las fichas de enfermedades, **para** identificar visualmente condiciones clínicas.

| Campo | Valor |
|-------|-------|
| Estado | Hecho |
| Prioridad | Media |
| Story points | 3 |

**Tareas técnicas:**
- [x] Script `scripts/images/download_disease_google_images.rb`
- [x] Rutas `images/enfermedades/*.jpg` en entradas de enfermedades
- [x] Componente de tarjeta de enfermedad muestra imagen o fallback

**Criterios de aceptación:**
- [x] Tarjetas de enfermedad muestran imagen cuando existe archivo
- [x] Fallback graceful si falta imagen (placeholder o sin rotura de layout)

---

### EP-02 — Experiencia de usuario (UX)

#### US-UX-01 · Diseño responsive móvil

**Como** usuario en smartphone, **quiero** navegar la enciclopedia con layout adaptado, **para** consultar información en campo sin zoom manual.

| Campo | Valor |
|-------|-------|
| Estado | Hecho |
| Prioridad | Alta |
| Story points | 5 |

**Tareas técnicas:**
- [x] Media queries y ajustes en `css/styles.css` (PR #5)
- [x] Sidebar, grid de razas y modal adaptados a ≤768px
- [x] Touch targets y tipografía legible en móvil

**Criterios de aceptación:**
- [x] Navegación usable en viewport 375px–768px
- [x] Sin scroll horizontal no deseado
- [x] Modal de disclaimer usable en pantalla pequeña

---

#### US-UX-02 · Modal de aviso educativo veterinario

**Como** visitante del sitio, **quiero** ver un aviso claro de que el contenido es educativo y no sustituye consulta veterinaria, **para** usar la información de forma responsable.

| Campo | Valor |
|-------|-------|
| Estado | Hecho |
| Prioridad | Alta |
| Story points | 3 |

**Tareas técnicas:**
- [x] Modal HTML/CSS en `index.html` y `css/styles.css` (PR #6)
- [x] Lógica de visualización en `js/app.js` (PR #7)
- [x] Texto de disclaimer revisable en markup

**Criterios de aceptación:**
- [x] Modal visible en cada carga de página
- [x] Usuario puede cerrar el modal y continuar navegando
- [x] Mensaje indica naturaleza educativa del contenido

---

### EP-03 — Infraestructura y despliegue

#### US-DEV-01 · Despliegue en GitHub Pages

**Como** mantenedor, **quiero** publicar el sitio estático automáticamente en cada push a `main`, **para** que los usuarios accedan siempre a la versión más reciente.

| Campo | Valor |
|-------|-------|
| Estado | Hecho |
| Prioridad | Alta |
| Story points | 5 |

**Tareas técnicas:**
- [x] Workflow `.github/workflows/deploy-pages.yml`
- [x] Artefacto `_site/` generado en CI
- [x] URL pública: https://ramiro-andres.github.io/enciclopediaanimal/

**Criterios de aceptación:**
- [x] Push a `main` dispara deploy
- [x] Sitio accesible públicamente sin servidor local
- [x] Workflow `Desplegar en GitHub Pages` verde tras merge

---

#### US-DEV-02 · Pipeline CI de pruebas

**Como** desarrollador, **quiero** que las pruebas se ejecuten en cada PR y push, **para** detectar regresiones antes del merge.

| Campo | Valor |
|-------|-------|
| Estado | Hecho |
| Prioridad | Alta |
| Story points | 3 |

**Tareas técnicas:**
- [x] Workflow `.github/workflows/test.yml`
- [x] Suite Ruby en `tests/test_enciclopedia.rb`
- [x] Script `ejecutar_pruebas.sh` para ejecución local

**Criterios de aceptación:**
- [x] CI ejecuta tests en PRs hacia `main`
- [x] Fallo de test bloquea merge (con branch protection)
- [x] Tests no requieren servidor HTTP local

---

#### US-DEV-07 · Sitio 100 % estático (sin servidor local)

**Como** contribuidor, **quiero** abrir `index.html` o GitHub Pages directamente, **para** desarrollar y probar sin levantar un servidor Ruby.

| Campo | Valor |
|-------|-------|
| Estado | Hecho |
| Prioridad | Media |
| Story points | 2 |

**Tareas técnicas:**
- [x] Eliminación de `iniciar.sh` y flujo local obsoleto (PR #4)
- [x] Tests simplificados sin dependencia de servidor
- [x] Documentación en `docs/DESARROLLO.md`

**Criterios de aceptación:**
- [x] No hay scripts de arranque de servidor en el repo
- [x] Flujo documentado: generar datos → abrir estático o usar Pages

---

### EP-04 — Gobernanza y organización del repositorio

#### US-GOV-01 · Seguridad y protección del repositorio

**Como** mantenedor, **quiero** reglas de contribución y protección de rama principal, **para** evitar cambios no revisados en producción.

| Campo | Valor |
|-------|-------|
| Estado | Hecho |
| Prioridad | Alta |
| Story points | 5 |

**Tareas técnicas:**
- [x] Branch protection en `main` (reviews + CI required)
- [x] `.github/CONTRIBUTING.md`, `.github/CODEOWNERS`
- [x] Script `scripts/setup/setup_github_security.sh`
- [x] PR #1 corrige script de setup

**Criterios de aceptación:**
- [x] Merge a `main` requiere PR aprobado y CI verde
- [x] CODEOWNERS asigna revisores por área
- [x] Guía de contribución accesible desde docs

---

#### US-GOV-02 · Reorganización del repositorio

**Como** desarrollador nuevo, **quiero** una estructura de carpetas clara, **para** encontrar scripts, datos y documentación rápidamente.

| Campo | Valor |
|-------|-------|
| Estado | Hecho |
| Prioridad | Media |
| Story points | 3 |

**Tareas técnicas:**
- [x] `scripts/data/`, `scripts/images/`, `scripts/setup/`
- [x] Carpeta `docs/` con guías técnicas (PR #3)
- [x] `docs/ESTRUCTURA.md` describe layout

**Criterios de aceptación:**
- [x] Scripts agrupados por función (datos, imágenes, setup)
- [x] Documentación centralizada en `docs/`
- [x] README principal enlaza a docs

---

## Backlog — Próximo sprint

**Objetivo propuesto:** Consolidar producción post-Sprint 0, mejorar descubribilidad (SEO, URLs) y reforzar CI.

**Capacidad sugerida:** ~21 story points.

**Nota:** Todos los PRs (#1–#7) están mergeados. No hay PRs pendientes de integración.

---

### EP-05 — Calidad, SEO y navegación

#### US-UX-03 · Meta tags SEO y Open Graph

**Como** usuario que comparte enlaces, **quiero** previews ricos en redes sociales, **para** atraer más visitantes al atlas.

| Campo | Valor |
|-------|-------|
| Estado | Pendiente |
| Prioridad | Alta |
| Story points | 3 |

**Tareas técnicas:**
- [ ] Añadir `<meta name="description">` en `index.html`
- [ ] Tags Open Graph (`og:title`, `og:description`, `og:image`, `og:url`)
- [ ] Twitter Card equivalente
- [ ] Imagen OG estática en `images/` o raíz

**Criterios de aceptación:**
- [ ] Facebook/Twitter/LinkedIn debugger muestra preview correcto
- [ ] Descripción refleja propósito educativo veterinario

---

#### US-UX-04 · Enlaces cruzados diccionario ↔ enfermedades

**Como** estudiante, **quiero** que los términos del glosario enlacen a enfermedades relacionadas, **para** profundizar en contexto clínico sin buscar manualmente.

| Campo | Valor |
|-------|-------|
| Estado | Backlog |
| Prioridad | Alta |
| Story points | 5 |

**Tareas técnicas:**
- [ ] Mapear términos del diccionario a IDs de enfermedades (script o metadata en JSON)
- [ ] Renderizar enlaces en vista glosario y en fichas de enfermedad
- [ ] Navegación hash `#enfermedad/{id}` desde término

**Criterios de aceptación:**
- [ ] Al menos 50 términos con enlace bidireccional verificable
- [ ] Enlace roto no aparece si no hay enfermedad asociada
- [ ] Test de integridad de referencias en CI (opcional fase 2)

---

#### US-UX-05 · URLs compartibles con hash

**Como** usuario, **quiero** compartir un enlace directo a una raza o enfermedad, **para** que otros vean exactamente la misma ficha.

| Campo | Valor |
|-------|-------|
| Estado | Pendiente |
| Prioridad | Alta |
| Story points | 5 |

**Tareas técnicas:**
- [ ] Routing por hash `#raza/{id}`, `#enfermedad/{id}`, `#glosario`
- [ ] Restaurar vista al recargar página con hash
- [ ] Actualizar hash al navegar internamente

**Criterios de aceptación:**
- [ ] Recargar con hash mantiene vista correcta
- [ ] Copiar URL desde barra de direcciones funciona en producción

---

#### US-UX-06 · Evaluación e implementación PWA

**Como** usuario frecuente, **quiero** instalar la enciclopedia como app, **para** consultarla offline en campo.

| Campo | Valor |
|-------|-------|
| Estado | Backlog |
| Prioridad | Baja |
| Story points | 8 |

**Tareas técnicas:**
- [ ] Spike: documento de decisión PWA sí/no
- [ ] `manifest.webmanifest` + iconos múltiples resoluciones
- [ ] Service worker con cache de assets estáticos
- [ ] Lighthouse PWA ≥ instalable

**Criterios de aceptación:**
- [ ] Decisión documentada en `docs/`
- [ ] Si se implementa: instalable en Chrome/Android y Safari/iOS
- [ ] Contenido principal disponible offline tras primera visita

---

### EP-06 — DevOps y pruebas

#### US-DEV-03 · Validar sincronización JSON → JS en CI

**Como** mantenedor, **quiero** que CI falle si alguien commitea JSON sin regenerar JS, **para** evitar desincronización en producción.

| Campo | Valor |
|-------|-------|
| Estado | Pendiente |
| Prioridad | Alta |
| Story points | 3 |

**Tareas técnicas:**
- [ ] Paso en `test.yml`: ejecutar `actualizar_datos.sh` y `git diff --exit-code data/*.js`
- [ ] Documentar requisito en `docs/DESARROLLO.md`

**Criterios de aceptación:**
- [ ] PR con JSON modificado y JS desactualizado falla CI
- [ ] PR con ambos sincronizados pasa

---

#### US-DEV-04 · Tests E2E sin servidor local

**Como** desarrollador, **quiero** pruebas de navegador automatizadas contra archivos estáticos, **para** validar flujos UI sin levantar servidor.

| Campo | Valor |
|-------|-------|
| Estado | Backlog |
| Prioridad | Media |
| Story points | 5 |

**Tareas técnicas:**
- [ ] Evaluar Playwright o similar con `file://` o servidor efímero en CI
- [ ] Escenarios: home → raza → enfermedad → glosario → disclaimer
- [ ] Integrar job opcional en `test.yml`

**Criterios de aceptación:**
- [ ] ≥3 flujos E2E pasan en CI
- [ ] No requiere servidor Ruby persistente local

---

#### US-DEV-05 · Limpieza de ramas mergeadas

**Como** mantenedor, **quiero** eliminar ramas remotas y locales obsoletas, **para** reducir confusión en el repositorio.

| Campo | Valor |
|-------|-------|
| Estado | Pendiente |
| Prioridad | Media |
| Story points | 1 |

**Tareas técnicas:**
- [ ] Borrar ramas remotas: `feature/disclaimer-modal`, `fix/mobile-responsive`, `fix/disclaimer-always-show`, `chore/*`
- [ ] Prune local: `git fetch --prune`

**Criterios de aceptación:**
- [ ] Solo `main` activa en remoto (salvo ramas de trabajo en curso)
- [ ] Documentado en changelog o nota de mantenimiento

---

#### US-DEV-06 · Analytics de uso (privacy-friendly)

**Como** product owner, **quiero** métricas básicas de visitas, **para** priorizar contenido según interés real.

| Campo | Valor |
|-------|-------|
| Estado | Backlog |
| Prioridad | Baja |
| Story points | 2 |

**Tareas técnicas:**
- [ ] Evaluar Plausible, GoatCounter o GitHub Pages insights
- [ ] Snippet mínimo sin cookies invasivas (si aplica)
- [ ] Documentar en política de privacidad / disclaimer

**Criterios de aceptación:**
- [ ] Dashboard accesible para mantenedor
- [ ] Cumple preferencia de privacidad documentada

---

#### US-DEV-08 · Permisos de workflow GitHub Actions

**Como** mantenedor, **quiero** permisos mínimos explícitos en workflows, **para** seguir el principio de least privilege.

| Campo | Valor |
|-------|-------|
| Estado | Backlog |
| Prioridad | Media |
| Story points | 2 |

**Tareas técnicas:**
- [ ] Añadir bloque `permissions:` en `test.yml` y `deploy-pages.yml`
- [ ] `contents: read` para test; `pages: write` + `id-token: write` solo en deploy

**Criterios de aceptación:**
- [ ] Workflows siguen funcionando tras restricción
- [ ] Sin permisos `write-all` innecesarios

---

### EP-07 — Expansión de contenido

#### US-CON-05 · Ampliar catálogo de razas (+50)

**Como** usuario internacional, **quiero** más razas documentadas, **para** ampliar la cobertura del atlas más allá de Colombia.

| Campo | Valor |
|-------|-------|
| Estado | Backlog |
| Prioridad | Media |
| Story points | 8 |

**Tareas técnicas:**
- [ ] Nuevo batch en `scripts/data/` (batch 7+)
- [ ] Imágenes vía pipeline existente
- [ ] Regenerar JSON/JS y validar tests de cantidad mínima

**Criterios de aceptación:**
- [ ] ≥405 razas en dataset
- [ ] Todas con imagen y ≥5 enfermedades
- [ ] CI verde

---

#### US-CON-06 · Expandir diccionario médico (+100 términos)

**Como** profesional de salud animal, **quiero** un glosario más completo, **para** cubrir terminología especializada adicional.

| Campo | Valor |
|-------|-------|
| Estado | Backlog |
| Prioridad | Media |
| Story points | 5 |

**Tareas técnicas:**
- [ ] Ampliar fuentes en `build_medical_dictionary.rb`
- [ ] Balancear 15 categorías existentes
- [ ] Regenerar JS

**Criterios de aceptación:**
- [ ] ≥627 términos totales
- [ ] Test de diccionario actualizado y pasando

---

#### US-CON-07 · Contenido regional LATAM

**Como** productor en México, Argentina o Chile, **quiero** razas relevantes de mi país, **para** identificar opciones productivas locales.

| Campo | Valor |
|-------|-------|
| Estado | Backlog |
| Prioridad | Baja |
| Story points | 8 |

**Tareas técnicas:**
- [ ] Scripts batch por país (≥10 razas c/u)
- [ ] Metadato `region` o tag en JSON de raza
- [ ] Filtro opcional por región en UI

**Criterios de aceptación:**
- [ ] ≥30 razas LATAM nuevas documentadas
- [ ] Filtro por región funcional en explorador

---

### EP-08 — Internacionalización y accesibilidad

#### US-UX-07 · Internacionalización (i18n) ES/EN

**Como** usuario angloparlante, **quiero** consultar la enciclopedia en inglés, **para** ampliar el alcance educativo internacional.

| Campo | Valor |
|-------|-------|
| Estado | Backlog |
| Prioridad | Baja |
| Story points | 8 |

**Tareas técnicas:**
- [ ] Spike: estrategia i18n (JSON paralelo vs claves i18n)
- [ ] Selector de idioma en cabecera
- [ ] Traducción UI estática (mínimo); contenido clínico fase 2

**Criterios de aceptación:**
- [ ] UI navegable en ES y EN
- [ ] Preferencia persiste en `localStorage`
- [ ] Decisión documentada para traducción de 355+ fichas

---

#### US-UX-08 · Auditoría de accesibilidad WCAG 2.1 AA

**Como** usuario con discapacidad visual o motriz, **quiero** navegar con teclado y lector de pantalla, **para** acceder al contenido en igualdad de condiciones.

| Campo | Valor |
|-------|-------|
| Estado | Backlog |
| Prioridad | Media |
| Story points | 5 |

**Tareas técnicas:**
- [ ] Auditoría axe/Lighthouse en vistas principales
- [ ] Roles ARIA en modal, navegación y tarjetas
- [ ] Contraste y foco visible en CSS

**Criterios de aceptación:**
- [ ] Navegación completa solo con teclado
- [ ] Lighthouse Accessibility ≥90
- [ ] Sin errores críticos en axe

---

### EP-09 — Comunidad y contribución

#### US-GOV-03 · Plantillas de issues GitHub

**Como** contribuidor externo, **quiero** plantillas guiadas para reportar bugs o proponer contenido, **para** enviar información completa desde el primer mensaje.

| Campo | Valor |
|-------|-------|
| Estado | Backlog |
| Prioridad | Alta |
| Story points | 2 |

**Tareas técnicas:**
- [ ] `.github/ISSUE_TEMPLATE/bug_report.yml`
- [ ] `.github/ISSUE_TEMPLATE/content_request.yml`
- [ ] `.github/ISSUE_TEMPLATE/feature_request.yml`

**Criterios de aceptación:**
- [ ] ≥3 plantillas disponibles al crear issue
- [ ] Enlazadas desde `docs/CONTRIBUIR.md`

---

## Tablero resumen

| Epic | Historias | Hecho | Pendiente | Backlog | Puntos hechos | Puntos backlog |
|------|-----------|-------|-----------|---------|---------------|----------------|
| EP-01 Contenido | 4 | 4 | 0 | 3 | 21 | 21 |
| EP-02 UX | 2 | 2 | 0 | 4 | 8 | 26 |
| EP-03 Infra | 3 | 3 | 0 | 0 | 10 | 0 |
| EP-04 Gobernanza | 2 | 2 | 0 | 1 | 8 | 2 |
| EP-05 Calidad/SEO | — | — | 2 | 2 | — | 21 |
| EP-06 DevOps | — | — | 2 | 3 | — | 13 |
| **Total Sprint 0** | **11** | **11** | — | — | **~47** | — |
| **Backlog activo** | **14** | — | **4** | **10** | — | **~83** |

---

## Sprint propuesto (Sprint 1)

| Orden | ID | Historia | Puntos | Prioridad |
|-------|-----|----------|--------|-----------|
| 1 | US-DEV-05 | Limpieza de ramas | 1 | Media |
| 2 | US-DEV-03 | Validar JSON→JS en CI | 3 | Alta |
| 3 | US-UX-03 | Meta tags SEO | 3 | Alta |
| 4 | US-UX-05 | URLs con hash | 5 | Alta |
| 5 | US-GOV-03 | Plantillas de issues | 2 | Alta |
| 6 | US-DEV-08 | Permisos workflow | 2 | Media |
| | | **Total** | **16** | |

---

## Sprint 2 — Entregado (navegación clínica y DevOps de calidad)

**Objetivo del sprint:** Conectar el conocimiento clínico (glosario ↔ enfermedades) y reforzar la calidad con pruebas E2E sin servidor y una vista previa validada por PR. Segundo grupo lógico del backlog tras Sprint 1 (épicas EP-05/EP-06).

| Orden | ID | Historia | Puntos | Estado |
|-------|-----|----------|--------|--------|
| 1 | US-UX-04 | Enlaces cruzados diccionario ↔ enfermedades | 5 | Hecho |
| 2 | US-DEV-04 | Tests E2E sin servidor local (Playwright, `file://`) | 5 | Hecho |
| 3 | US-DEV-09 | Vista previa de PR + validaciones de integridad y sincronización JSON→JS | 3 | Hecho |
| | | **Total** | **13** | |

**Entregables técnicos:**

- `scripts/data/build_cross_links.rb` → genera `data/enlaces_clinicos.json` (234 términos y 179 enfermedades enlazados de forma bidireccional).
- UI: chips «Enfermedades relacionadas» en el glosario y «Términos del glosario relacionados» en cada ficha de enfermedad (`js/app.js`, `css/styles.css`).
- Playwright: `package.json`, `playwright.config.js`, `tests/e2e/atlas.spec.js` (5 flujos), `ejecutar_e2e.sh` y workflow `.github/workflows/e2e.yml`.
- Workflow `.github/workflows/preview.yml` (artefacto `vista-previa-sitio`) y `scripts/setup/validar_integridad.rb`.
- Validación de sincronización JSON→JS (incluye enlaces) integrada en `test.yml` y `ejecutar_pruebas.sh`.

> **US-DEV-09** es una historia nueva derivada del grupo de DevOps del backlog («preview PR» y «validaciones»), complementaria a US-DEV-03/US-DEV-08.

## Sprint 3 — Completado (rama `sprint-3/pwa-i18n-contenido-comunidad`)

**Objetivo:** PWA offline, comparador de razas, accesibilidad WCAG, i18n ES/EN, expansión de contenido (+76 razas netas), analytics privacy-friendly, validación clínica en CI y comunidad.

| ID | Historia | Estado |
|----|----------|--------|
| US-UX-06 | PWA (manifest + service worker) | Hecho |
| — | Comparador de razas (hasta 3) | Hecho |
| US-UX-08 | Accesibilidad WCAG 2.1 AA básica | Hecho |
| US-UX-07 | i18n UI ES/EN | Hecho |
| US-CON-05 | +50 razas (431 total) | Hecho |
| US-DEV-06 | Analytics GoatCounter (opt-in) | Hecho |
| — | Validación contenido clínico en CI | Hecho |
| US-GOV-03 / EP-09 | Plantillas issues + guía contenido | Hecho |

**Métricas:** 431 razas · 2 555 enfermedades · 60 tests verdes

---

## Sprint 4 — En progreso (rama `sprint-4/ep-12-produccion-confiable`)

### EP-12 — Producción confiable y offline real

**Objetivo:** cerrar las brechas detectadas en [PIPELINE_ERRORES.md](PIPELINE_ERRORES.md): evitar despliegues con CI rojo (caso PR #21), lograr offline real en la PWA, prevenir desincronización JSON→JS y auditar accesibilidad de forma automática.

| ID | Historia | Puntos | Estado |
|----|----------|--------|--------|
| US-DEV-10 | Gate de deploy: publicar solo con `test` + `e2e` verdes | 3 | Hecho |
| US-DEV-11 | Service Worker completo (precache datos JS + imágenes SWR) | 5 | Hecho |
| US-DEV-12 | Hook pre-commit que regenera/valida JSON→JS | 2 | Hecho |
| US-DEV-13 | Lighthouse CI en PR con umbral A11y ≥ 90 | 3 | Hecho |
| | | **13** | |

#### US-DEV-10 · Gate de deploy

**Como** mantenedor, **quiero** que el despliegue a Pages solo ocurra si `test` y `e2e` están verdes, **para** no publicar una app rota (caso PR #21: deploy verde con app rota).

**Tareas técnicas:**
- [x] `deploy-pages.yml` deja de dispararse en `push` a `main`; usa `workflow_run` sobre `["test", "e2e"]`.
- [x] Job `gate` verifica vía API (`actions: read`) que el último run completado de `test` **y** `e2e` para el `head_sha` sea `success`.
- [x] `build`/`deploy` condicionados a `should_deploy == 'true'`; `workflow_dispatch` permite deploy manual.

**Criterios de aceptación:**
- [x] Un `main` con `test` o `e2e` rojo no despliega.
- [x] Cuando ambos terminan en éxito, el segundo en completar dispara el deploy.

#### US-DEV-11 · Service Worker completo

**Como** usuario en campo, **quiero** que la app funcione offline tras la primera visita, **para** consultar razas y enfermedades sin conexión.

**Tareas técnicas:**
- [x] Precache de `data/enlaces_clinicos.js` (además de enciclopedia y diccionario) y app shell.
- [x] Estrategia stale-while-revalidate para imágenes en caché aparte (`IMAGE_CACHE`).
- [x] `CACHE_VERSION` → `atlas-v3`; limpieza de cachés `atlas-*` obsoletas en `activate`.
- [x] `docs/PWA.md` actualizado.

**Criterios de aceptación:**
- [x] Los tres `data/*.js` críticos quedan disponibles offline.
- [x] Bump de versión invalida cachés previas.

#### US-DEV-12 · Hook pre-commit JSON→JS

**Como** mantenedor, **quiero** que un commit que toca `data/*.json` regenere y valide los `.js`, **para** evitar la desincronización del PR #23 antes de llegar a CI.

**Tareas técnicas:**
- [x] `scripts/setup/pre-commit` regenera con `actualizar_datos.sh` y bloquea si los `.js` quedan desactualizados.
- [x] `scripts/setup/instalar_hooks.sh` instala el hook.
- [x] Documentado en `docs/DESARROLLO.md`, `docs/CONTRIBUIR.md` y plantilla de PR.

**Criterios de aceptación:**
- [x] Commit con JSON modificado y JS viejo se bloquea con mensaje claro.
- [x] Commit con ambos sincronizados pasa.

#### US-DEV-13 · Lighthouse CI

**Como** equipo, **quiero** auditar accesibilidad en cada PR, **para** mantener A11y ≥ 90.

**Tareas técnicas:**
- [x] Workflow `.github/workflows/lighthouse.yml` construye `_site` y corre Lighthouse CI.
- [x] `lighthouserc.json` con aserción `categories:accessibility` como `error`, `minScore` 0.90.
- [x] Auditoría sobre artefacto estático (`staticDistDir`), sin servidor persistente.

**Criterios de aceptación:**
- [x] PR con accesibilidad < 90 falla el check `lighthouse`.
- [x] Reporte disponible como artefacto / almacenamiento temporal público.

**Entregables técnicos:**
- `.github/workflows/deploy-pages.yml` (gate `workflow_run` + verificación de conclusiones).
- `sw.js` (`atlas-v3`, precache ampliado, SWR de imágenes), `docs/PWA.md`.
- `scripts/setup/pre-commit`, `scripts/setup/instalar_hooks.sh`.
- `.github/workflows/lighthouse.yml`, `lighthouserc.json`.
- `tests/test_sprint4.rb` (SW, gate, hook, Lighthouse).

---

## Sprint 5 — Completado (rama `sprint-5/ep-10-herramientas-clinicas`, PR #26)

### EP-10 — Herramientas clínicas de bolsillo

| ID | Historia | Puntos | Estado |
|----|----------|--------|--------|
| US-TOOL-01 | Calculadora RER/MER con kg/lb | 3 | Hecho |
| US-TOOL-02 | Índice de toxicología por especie | 5 | Hecho |
| US-TOOL-03 | Compartir/copiar enlace de ficha | 2 | Hecho |
| US-TOOL-04 | Badges zoonóticos + calendario vacunación | 5 | Hecho |
| | | **15** | |

**Entregables:** `data/toxicologia.json`, `data/calendario_vacunacion.json`, vistas herramientas, `tests/test_sprint5.rb`.

---

## Sprint 6 — Completado (rama `sprint-6/ep-11-seo-sharing`, PR #27)

### EP-11 — SEO, sharing y descubrimiento

**Objetivo:** Mejorar el descubrimiento del atlas (sitemap, metadatos dinámicos, datos estructurados) y facilitar el reporte de errores de contenido hacia GitHub.

| ID | Historia | Puntos | Estado |
|----|----------|--------|--------|
| US-SEO-01 | sitemap.xml con rutas del atlas | 3 | Hecho |
| US-SEO-02 | OG dinámicos (título, descripción, imagen de raza) | 5 | Hecho |
| US-SEO-03 | JSON-LD (Schema.org) en enfermedad/glosario | 3 | Hecho |
| US-SEO-04 | Reportar error con un clic hacia GitHub | 2 | Hecho |
| | | **13** | |

#### US-SEO-01 · sitemap.xml

**Tareas técnicas:**
- [x] `scripts/data/build_sitemap.rb` → `sitemap.xml` (home + hash routes).
- [x] Integrado en `actualizar_datos.sh` y workflows de build/deploy.
- [x] `robots.txt` + `<link rel="sitemap">` en `index.html`.

#### US-SEO-02 · OG dinámicos por ruta

**Tareas técnicas:**
- [x] `updatePageMeta` / `resetPageMeta` (og:*, twitter:*, canonical).
- [x] Actualización en fichas de raza/enfermedad y glosario; reset en `goWelcome`.
- [x] Limitación documentada en `docs/SEO.md` (crawlers sin JS).

#### US-SEO-03 · JSON-LD

**Tareas técnicas:**
- [x] `MedicalWebPage` + `MedicalCondition` en enfermedades.
- [x] `DefinedTerm` en términos del glosario (`#glosario/{slug}`).
- [x] Bloque `#atlas-jsonld` reemplazado al cambiar de vista.

#### US-SEO-04 · Reportar error

**Tareas técnicas:**
- [x] Botón en ficha de raza y enfermedad → issue con `content_request.yml`.
- [x] Campos prellenados: nombre, URL con hash, categoría animal.
- [x] i18n ES/EN y estilos accesibles.

**Entregables técnicos:**
- `scripts/data/build_sitemap.rb`, `sitemap.xml`, `robots.txt`.
- Metadatos dinámicos y JSON-LD en `js/app.js`; `docs/SEO.md`.
- `tests/test_sprint6.rb`.

---

## Sprint 7 — Completado (EP-13: UX Atlas público)

**Objetivo:** Mejorar la experiencia móvil y de consulta del atlas educativo: navegación inferior, favoritos locales, impresión de fichas, disclaimer por sesión y fuentes bibliográficas visibles.

| ID | Historia | Puntos | Estado |
|----|----------|--------|--------|
| US-UX-09 | Tab bar móvil (Inicio, Explorar, Glosario, Urgencias, Herramientas) | 5 | Hecho |
| US-UX-10 | Favoritos en localStorage + panel en welcome | 3 | Hecho |
| US-UX-11 | Vista `@media print` + botón «Imprimir ficha» | 3 | Hecho |
| US-UX-12 | Disclaimer una vez por sesión (sessionStorage) | 2 | Hecho |
| US-CON-08 | Fuentes bibliográficas en diseaseView | 2 | Hecho |
| | | **15** | |

---

## Sprint 8 — Completado (EP-13: UX Atlas público, continuación)

**Objetivo:** Ampliar herramientas clínicas educativas, mapa de predisposiciones genéticas, búsqueda tolerante y tour de bienvenida.

| ID | Historia | Puntos | Estado |
|----|----------|--------|--------|
| US-UX-13 | Búsqueda con sinónimos y typos | 5 | Hecho |
| US-TOOL-05 | Calculadora fluidoterapia de mantenimiento | 3 | Hecho |
| US-CON-09 | Mapa de predisposiciones genéticas | 5 | Hecho |
| US-TOOL-06 | Conversor de unidades clínicas | 3 | Hecho |
| US-UX-14 | Tour de bienvenida (primera visita / sesión) | 2 | Hecho |
| | | **18** | |

#### US-TOOL-05 · Calculadora fluidoterapia

**Tareas técnicas:**
- [x] Vista `#fluidoterapia` con peso kg/lb y especie
- [x] ml/kg/día de mantenimiento y bolos de shock educativos documentados
- [x] Disclaimer veterinario e i18n ES/EN
- [x] Enlace desde hub `#herramientas`

#### US-CON-09 · Mapa de predisposiciones genéticas

**Tareas técnicas:**
- [x] Vista `#predisposiciones` cruzando `predisposiciones_geneticas` de 431 razas
- [x] Filtro por categoría animal y búsqueda por condición
- [x] Enlaces a fichas de raza y tarjeta en welcome

#### US-TOOL-06 · Conversor de unidades clínicas

**Tareas técnicas:**
- [x] mg↔g, mg/kg→mg total, °C↔°F, ml↔gotas (factores 20/60 documentados)
- [x] Panel en hub herramientas y enlace desde calculadora de dosis

#### US-UX-14 · Tour de bienvenida

**Tareas técnicas:**
- [x] 5 pasos en primera visita de la sesión (`sessionStorage` `atlas_welcome_tour_done`)
- [x] Destaca categorías, búsqueda, glosario, herramientas y favoritos

**Entregables técnicos:**
- Vistas fluidoterapia, unidades y predisposiciones en `index.html`, `css/styles.css`, `js/app.js`
- i18n en `js/i18n.js`; tour `WelcomeTour` en `js/app.js`
- `tests/test_sprint8.rb`; rutas en `scripts/data/build_sitemap.rb`; `sw.js` atlas-v7

---

## Sprint 9 — Completado (EP-14: Contenido y herramientas atlas)

**Objetivo:** Ampliar contenido clínico de referencia (BCS, toxicología, emergencias LATAM) y modo estudio del glosario con flashcards.

| ID | Historia | Puntos | Estado |
|----|----------|--------|--------|
| US-TOOL-07 | Guía visual condición corporal BCS (1–9 perro/gato, 1–5 equino) | 5 | Hecho |
| US-TOOL-08 | Ampliar toxicología (+30 sustancias) | 3 | Hecho |
| US-CON-10 | Directorio emergencias LATAM (sin geolocalización) | 5 | Hecho |
| US-UX-15 | Flashcards modo estudio del glosario | 5 | Hecho |
| | | **18** | |

---

## Sprint 10 — Completado (EP-15: Atlas clínico avanzado)

**Objetivo:** Triaje educativo por síntomas, bibliografía ampliada, modo lectura nocturno y resúmenes modo estudio pregenerados.

| ID | Historia | Puntos | Estado |
|----|----------|--------|--------|
| US-TOOL-09 | Asistente triaje educativo por síntomas (`#triaje`) | 5 | Hecho |
| US-CON-11 | Ampliar fuentes bibliográficas (≥30 % enfermedades con referencia) | 3 | Hecho |
| US-UX-16 | Modo lectura nocturno (toggle + `prefers-color-scheme`) | 3 | Hecho |
| US-CON-12 | Resúmenes modo estudio (`resumen_1min` en build script) | 3 | Hecho |
| | | **14** | |

**Entregables:** PR #33 mergeado 13 jul 2026.

---

## Sprint 11 — Completado (EP-16: Contenido clínico y rendimiento atlas)

**Objetivo:** Rangos de laboratorio consultables, destacado semanal de razas, carga diferida de la enciclopedia (431 razas) y detección de inconsistencias en CI.

**Rama:** `sprint-11/lab-rendimiento` (PR #34 mergeado 13 jul 2026)

| ID | Historia | Puntos | Estado |
|----|----------|--------|--------|
| US-CON-13 | Rangos de referencia de laboratorio por especie (`#laboratorio`) | 5 | Hecho |
| US-UX-17 | «Raza de la semana» en welcomeView (rotación por semana del año) | 3 | Hecho |
| US-DEV-14 | Carga diferida: chunks por `animalId` + manifest + índice búsqueda | 8 | Hecho |
| US-DEV-15 | Script CI: dosis fuera de rango, campos vacíos, descripciones duplicadas | 3 | Hecho |
| | | **19** | |

#### US-CON-13 · Rangos de laboratorio

**Tareas técnicas:**
- [x] `data/lab_reference.json` + `build_lab_reference.rb` (hemograma y bioquímica básica)
- [x] Vista `#laboratorio` con tablas responsive e imprimibles
- [x] Enlace desde hub `#herramientas` y botón en glosario
- [x] Disclaimer educativo (valores varían por laboratorio)
- [x] i18n ES/EN

#### US-UX-17 · Raza de la semana

**Tareas técnicas:**
- [x] Panel `#breedOfWeekPanel` en `welcomeView`
- [x] Selección determinística: `(año × 53 + semana) % total_razas` sobre `search_index`
- [x] Enlace a ficha de raza; carga chunk bajo demanda
- [x] i18n ES/EN

#### US-DEV-14 · Carga diferida (lazy load)

**Tareas técnicas:**
- [x] `scripts/data/build_chunks.rb` → `data/chunks/{animalId}.json` + `manifest.json`
- [x] `data/search_index.json` para búsqueda global sin cargar todos los chunks
- [x] `app.js`: `loadChunk` al seleccionar categoría; `preloadAllChunks` en background
- [x] `index.html` carga `manifest.js` + `search_index.js` (no `enciclopedia.js` en arranque)
- [x] `actualizar_datos.sh` integra `build_chunks.rb`
- [x] `sw.js` atlas-v10 precache manifest + search_index + lab_reference
- [x] Tests verifican chunks y manifest coherentes

#### US-DEV-15 · Detección inconsistencias CI

**Tareas técnicas:**
- [x] `scripts/data/detect_inconsistencies.rb`
- [x] Integrado en `ejecutar_pruebas.sh` y `.github/workflows/test.yml`
- [x] Alerta dosis mg/kg fuera de rango, campos clínicos vacíos, descripciones duplicadas (≥3 razas)

**Entregables técnicos:**
- Vista laboratorio en `index.html`, `css/styles.css`, `js/app.js`
- `data/lab_reference.json`, `data/chunks/*`, `data/search_index.json`
- `tests/test_sprint11.rb`; ruta `#laboratorio` en `build_sitemap.rb`
- Test E2E Sprint 11 en `tests/e2e/atlas.spec.js`

---

## Sprint 12 — En progreso (EP-17: Comunidad y expansión contenido atlas)

**Objetivo:** Changelog público, +50 razas internacionales/LATAM (batch 8), sección «Contribuye» en footer y script CI de sugerencias de enlaces glosario↔enfermedad.

**Rama:** `sprint-12/comunidad-contenido`

| ID | Historia | Puntos | Estado |
|----|----------|--------|--------|
| US-UX-18 | Changelog público `#changelog` desde CHANGELOG.md o git log | 3 | En progreso |
| US-CON-15 | +50 razas batch 8 internacional/LATAM (≥481 razas) | 8 | En progreso |
| US-GOV-04 | Footer «Contribuye»: GitHub, guía CONTRIBUIR, stats dinámicos | 3 | En progreso |
| US-DEV-16 | Script CI sugerencias enlaces glosario↔enfermedad → `sugerencias_enlaces.json` | 3 | En progreso |
| | | **17** | |

#### US-UX-18 · Changelog público

**Tareas técnicas:**
- [x] `scripts/data/build_changelog.rb` desde `CHANGELOG.md` o `git log`
- [x] `data/changelog.json` + `changelog.js` vía `actualizar_datos.sh`
- [x] Vista `#changelog` en `index.html`, `js/app.js`, `css/styles.css`
- [x] Enlace desde footer y welcome; i18n ES/EN
- [x] Ruta en `build_sitemap.rb`; precache PWA `sw.js` atlas-v11

#### US-CON-15 · Batch 8 razas

**Tareas técnicas:**
- [x] `scripts/data/production_breeds_batch8.rb` (Perú, Ecuador, Bolivia, Venezuela, Uruguay, Paraguay, Centroamérica, Caribe, Brasil)
- [x] Integración en `update_enciclopedia_full.rb`
- [x] Regeneración chunks, search_index, sitemap
- [x] Placeholders SVG para nuevas razas

#### US-GOV-04 · Footer Contribuye

**Tareas técnicas:**
- [x] `#footerContribute` con stats desde `manifest` / `getCatalogStats()`
- [x] Enlaces: repositorio GitHub, `docs/CONTRIBUIR.md`, issues `good-first-issue`
- [x] i18n ES/EN

#### US-DEV-16 · Sugerencias enlaces CI

**Tareas técnicas:**
- [x] `scripts/data/suggest_glossary_links.rb` (similitud Jaccard + texto clínico)
- [x] Salida `data/sugerencias_enlaces.json` para revisión manual
- [x] Integrado en `ejecutar_pruebas.sh` y `.github/workflows/test.yml`

**Entregables técnicos:**
- Vista changelog y footer contribuye en `index.html`, `css/styles.css`, `js/app.js`
- `CHANGELOG.md`, `data/changelog.json`, `data/sugerencias_enlaces.json`
- `scripts/data/production_breeds_batch8.rb`, `build_changelog.rb`, `suggest_glossary_links.rb`
- `tests/test_sprint12.rb`; E2E Sprint 12 en `tests/e2e/atlas.spec.js`

---

## Sprint 10 (histórico detalle EP-15)

**Objetivo:** Triaje educativo por síntomas, bibliografía ampliada, modo lectura nocturno y resúmenes modo estudio pregenerados.

| ID | Historia | Puntos | Estado |
|----|----------|--------|--------|
| US-TOOL-09 | Asistente triaje educativo por síntomas (`#triaje`) | 5 | Hecho |
| US-CON-11 | Ampliar fuentes bibliográficas (≥30 % enfermedades con referencia) | 3 | Hecho |
| US-UX-16 | Modo lectura nocturno (toggle + `prefers-color-scheme`) | 3 | Hecho |
| US-CON-12 | Resúmenes modo estudio (`resumen_1min` en build script) | 3 | Hecho |
| | | **14** | |

#### US-TOOL-09 · Triaje educativo

**Tareas técnicas:**
- [x] Vista `#triaje` con árbol estático 3–4 niveles (síntoma → causas → gravedad → acción)
- [x] `data/triaje.json` + `build_triaje.rb`; sin diagnóstico automático
- [x] Enlace desde hub `#herramientas` y `#urgencias`
- [x] i18n ES/EN

#### US-CON-11 · Bibliografía ampliada

**Tareas técnicas:**
- [x] `scripts/data/expand_bibliografia_sprint10.rb` valida y enriquece referencias
- [x] Referencias objeto `{ titulo, url }` en enfermedades comunes
- [x] Cobertura ≥30 % enfermedades con al menos 1 referencia
- [x] Visualización en `diseaseView` vía `renderBibliographicSources`

#### US-UX-16 · Modo lectura nocturno

**Tareas técnicas:**
- [x] Toggle `#themeToggleBtn` en cabecera
- [x] Variables CSS en `:root[data-theme="dark"]` y `@media (prefers-color-scheme: dark)`
- [x] Persistencia `localStorage` clave `atlas_theme`

#### US-CON-12 · Resúmenes modo estudio

**Tareas técnicas:**
- [x] `scripts/data/build_resumen_estudio_sprint10.rb` genera `resumen_1min`
- [x] Plantilla: síntomas + gravedad + acción
- [x] Bloque `.study-summary` en ficha de enfermedad

**Entregables técnicos:**
- Vista triaje en `index.html`, `css/styles.css`, `js/app.js`
- `data/triaje.json`, scripts sprint10 en `scripts/data/`
- `tests/test_sprint10.rb`; ruta `#triaje` en `build_sitemap.rb`; `sw.js` atlas-v9

---

## Sprint 9 (histórico detalle EP-14)

**Objetivo:** Ampliar contenido clínico de referencia (BCS, toxicología, emergencias LATAM) y modo estudio del glosario con flashcards.

| ID | Historia | Puntos | Estado |
|----|----------|--------|--------|
| US-TOOL-07 | Guía visual condición corporal BCS (1–9 perro/gato, 1–5 equino) | 5 | En progreso |
| US-TOOL-08 | Ampliar toxicología (+30 sustancias) | 3 | En progreso |
| US-CON-10 | Directorio emergencias LATAM (sin geolocalización) | 5 | En progreso |
| US-UX-15 | Flashcards modo estudio del glosario | 5 | En progreso |
| | | **18** | |

#### US-TOOL-07 · Guía visual BCS

**Tareas técnicas:**
- [x] Vista `#bcs` con siluetas SVG y selector de especie (perro, gato, equino)
- [x] Escalas 1–9 (perro/gato) y 1–5 (equino) con descripciones i18n ES/EN
- [x] Enlace desde hub `#herramientas`

#### US-TOOL-08 · Toxicología ampliada

**Tareas técnicas:**
- [x] `scripts/data/expand_toxicologia_sprint9.rb` → ≥50 sustancias en `data/toxicologia.json`
- [x] Plantas, alimentos y medicamentos humanos adicionales
- [x] Regeneración vía `build_toxicologia.rb`

#### US-CON-10 · Directorio emergencias LATAM

**Tareas técnicas:**
- [x] `data/emergencias_latam.json` + `build_emergencias_latam.rb`
- [x] Vista `#emergencias-latam` y enlace desde `#urgencias`
- [x] ≥8 países con colegios/asociaciones y líneas de referencia

#### US-UX-15 · Flashcards del glosario

**Tareas técnicas:**
- [x] Vista `#flashcards` con revelar definición, barajar y progreso `localStorage`
- [x] Acceso desde glosario (`#glosario`) y ruta hash dedicada
- [x] i18n ES/EN

**Entregables técnicos:**
- Vistas BCS, flashcards y emergencias LATAM en `index.html`, `css/styles.css`, `js/app.js`
- `data/emergencias_latam.json`, `scripts/data/expand_toxicologia_sprint9.rb`
- `tests/test_sprint9.rb`; rutas en `build_sitemap.rb`; `sw.js` atlas-v8

---

## Sprint 8 (histórico US-UX-13) — Búsqueda con sinónimos

**Objetivo:** Mejorar la descubribilidad del contenido clínico con búsqueda tolerante a sinónimos y errores tipográficos.

| ID | Historia | Puntos | Estado |
|----|----------|--------|--------|
| US-UX-13 | Búsqueda con sinónimos y typos (razas, enfermedades, glosario) | 5 | Hecho |

#### US-UX-13 · Búsqueda con sinónimos y typos

**Como** usuario del atlas educativo, **quiero** buscar razas, enfermedades y términos del glosario usando sinónimos comunes y con tolerancia a errores de escritura, **para** encontrar contenido aunque no recuerde el nombre exacto.

| Campo | Valor |
|-------|-------|
| Estado | Hecho |
| Prioridad | Alta |
| Story points | 5 |

**Tareas técnicas:**
- [x] Índice precomputado `data/search_synonyms.json` + `search_synonyms.js` vía `scripts/data/build_search_index.rb`
- [x] Integración en `actualizar_datos.sh` e `index.html`
- [x] `matchesSearch` en `js/app.js`: normalización, sinónimos y Levenshtein ligero
- [x] Resultados globales incluyen glosario; UI muestra «Coincide por sinónimo» / «Coincidencia aproximada»
- [x] i18n ES/EN (`search.synonym_match`, `search.typo_match`, etc.)
- [x] Precache PWA en `sw.js`
- [x] Tests `tests/test_search_synonyms.rb`

**Criterios de aceptación:**
- [x] Índice de sinónimos en `data/` generado por script Ruby
- [x] Búsqueda global coincide por sinónimos (ej. parvovirus ↔ parvovirosis; mastitis ↔ inflamación mamaria)
- [x] Tolerancia ligera a typos (Levenshtein en cliente + normalización de acentos)
- [x] UI indica el término buscado y el motivo de coincidencia por sinónimo o aproximación
- [x] Búsqueda por nombre directo sigue funcionando
- [x] i18n ES/EN en mensajes de búsqueda
- [x] `bash ejecutar_pruebas.sh` sin fallos

---

#### US-UX-09 · Tab bar móvil

**Tareas técnicas:**
- [x] `<nav id="mobileTabBar">` con 5 pestañas y `aria-current="page"`.
- [x] Visible solo ≤768px; `safe-area-inset-bottom` para notch/home indicator.
- [x] `bindMobileTabBar` / `updateMobileTabBar` sincronizados con vista activa.
- [x] i18n ES/EN (`tab.*`).

#### US-UX-10 · Favoritos

**Tareas técnicas:**
- [x] `localStorage` clave `atlas_favorites` (máx. 50).
- [x] Botón estrella en ficha de raza y enfermedad (`aria-pressed`).
- [x] Panel «Mis favoritos» en welcome con enlace a hash guardado.
- [x] i18n ES/EN (`favorites.*`).

#### US-UX-11 · Impresión

**Tareas técnicas:**
- [x] `@media print` oculta chrome (header, sidebar, tab bar, botones).
- [x] Botón «Imprimir ficha» en raza/enfermedad → `window.print()`.
- [x] Disclaimer educativo al pie de la ficha impresa.

#### US-UX-12 · Disclaimer por sesión

**Tareas técnicas:**
- [x] `sessionStorage` clave `atlas_disclaimer_accepted` al pulsar «Entendido».
- [x] Modal no se muestra si ya fue aceptado en la sesión.

#### US-CON-08 · Fuentes bibliográficas

**Tareas técnicas:**
- [x] `renderBibliographicSources()` en `diseaseView` con `fuentes_bibliograficas` o `referencias`.
- [x] Soporta strings y objetos `{ titulo, autor, doi, url }`.
- [x] i18n `sources.title`.

**Entregables técnicos:**
- Tab bar, favoritos, impresión y disclaimer en `index.html`, `css/styles.css`, `js/app.js`.
- i18n en `js/i18n.js`.
- `tests/test_sprint7.rb`.

---

## Referencias

- [TRAZADO_RUTA.md](TRAZADO_RUTA.md) — Roadmap por fases
- [DESARROLLO.md](DESARROLLO.md) — Entorno y pruebas
- [DESPLIEGUE.md](DESPLIEGUE.md) — GitHub Pages y CI/CD
- [CONTRIBUIR.md](CONTRIBUIR.md) — Guía de contribución

---

## Historial de cambios

| Fecha | Cambio |
|-------|--------|
| 2026-07-12 | Creación inicial del backlog Scrum (post-Sprint 0, PRs #1–#7 mergeados) |
| 2026-07-12 | Sprint 3 entregado: PWA, i18n, comparador, contenido y comunidad |
| 2026-07-12 | [PIPELINE_ERRORES.md](PIPELINE_ERRORES.md): análisis de fallos CI/CD (Pages, E2E, JSON→JS, PR #21–#23) |
| 2026-07-12 | Sprint 2 entregado: US-UX-04 (enlaces cruzados), US-DEV-04 (E2E sin servidor), US-DEV-09 (preview + validaciones) |
| 2026-07-12 | Sprint 4 (EP-12): gate de deploy (US-DEV-10), SW offline real (US-DEV-11), hook pre-commit JSON→JS (US-DEV-12), Lighthouse CI A11y≥90 (US-DEV-13) |
| 2026-07-12 | Sprint 5 (EP-10): RER/MER, toxicología, compartir fichas, zoonóticas y calendario vacunación (PR #26) |
| 2026-07-12 | Sprint 6 (EP-11): sitemap, OG dinámicos, JSON-LD y reporte de errores vía GitHub |
| 2026-07-13 | Sprint 11 (EP-16): laboratorio, raza de la semana, lazy load chunks, inconsistencias CI (PR #34) |
| 2026-07-13 | Pre-Sprint 14: auditoría de cobertura, `tests/test_security.rb` + `tests/test_regression.rb`, 3 E2E nuevos (toxicología, región, favoritos) |
| 2026-07-13 | Sprint 9 (EP-14): BCS visual, toxicología ampliada, directorio emergencias LATAM, flashcards glosario |
| 2026-07-12 | Sprint 7 (EP-13): tab bar móvil, favoritos, impresión, disclaimer por sesión y fuentes bibliográficas |
