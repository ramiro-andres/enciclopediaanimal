---
name: enciclopedia-contexto
description: >-
  Contexto del atlas Enciclopedia Animal (PWA estática, GitHub Pages, español).
  Usar al trabajar en este repo, al añadir features UI/datos, o al dudar de
  arquitectura, paths, tests o despliegue.
---

# Enciclopedia Animal — contexto

Sitio **estático** (sin bundler ni backend): `index.html` + `css/` + `js/` + `data/*.js` embebidos + PWA (`sw.js`, `manifest.webmanifest`).

Publicación: https://ramiro-andres.github.io/enciclopediaanimal/

## Reglas fijas

- Responder al usuario en **español**.
- UI solo en **español** (`js/i18n.js`). No reintroducir switcher EN ni API de traducción en runtime.
- Tras tocar `data/*.json`: `bash actualizar_datos.sh` y commitear JSON **y** `.js` generados.
- No añadir secretos al repo. Sin `eval` / `document.write`. Escape con `esc()` / `AtlasUtils.esc`.
- Commits/PRs solo si el usuario lo pide; estilo de mensajes: por qué, no inventario de archivos.

## Paths clave

| Área | Dónde |
|------|--------|
| App | `js/app.js`, `js/utils.js`, `js/tools.js`, `js/i18n.js` |
| Datos | `data/*.json` → `data/*.js` vía `actualizar_datos.sh` |
| Tests | `bash ejecutar_pruebas.sh`, `bash ejecutar_e2e.sh` |
| CI/CD | `.github/workflows/` |
| Docs | `docs/` (índice en `docs/README.md`) |
| Sonar AA | `.sonarcloud.properties` (no `sonar-project.properties`) |

## Skills relacionadas

- [sync-datos-js](../sync-datos-js/SKILL.md) — regenerar datos
- [ci-deploy-ramas](../ci-deploy-ramas/SKILL.md) — PR, Pages, cleanup
- [sonar-automatic-analysis](../sonar-automatic-analysis/SKILL.md) — SonarCloud
- [i18n-espanol](../i18n-espanol/SKILL.md) — cadenas UI
- [fix-sonar-calidad](../fix-sonar-calidad/SKILL.md) — hallazgos Sonar/calidad
