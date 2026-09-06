---
name: i18n-espanol
description: >-
  Internacionalización de la UI de Enciclopedia Animal (solo español). Usar al
  añadir textos de interfaz, tocar js/i18n.js, data-i18n, o proponer inglés /
  traducción automática.
---

# i18n — solo español

## Estado

- Mapa plano en `js/i18n.js` (clave → texto ES).
- HTML: `data-i18n`, `data-i18n-html`, `data-i18n-placeholder`, `data-i18n-aria`.
- JS: `I18n.t(key)` / `App.t(key)`.
- **Sin** conmutador ES/EN en la UI.

## Al añadir UI

1. Nueva cadena → clave en `js/i18n.js` + atributo/`t()` en el sitio de uso.
2. No hardcodear textos de UI en `app.js` si ya hay patrón i18n en esa vista.
3. Contenido clínico en datos: español; no autotraducir fichas sin revisión veterinaria.

## Prohibido (PWA offline)

- API de traducción en el **navegador** (DeepL/Google en runtime): rompe offline, añade red/coste y no ayuda a Sonar NCLOC de forma útil.

## Si se vuelve a pedir inglés

1. Locales `data/i18n/es.json` + `en.json` (o build-time).
2. Cargar solo el idioma activo; precachear en SW.
3. Traducir claves nuevas en **CI/build**, nunca en runtime.
4. Documentar en `docs/I18N.md`.
