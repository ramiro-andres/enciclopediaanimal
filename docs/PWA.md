# Decisión PWA — Atlas Animal

**Fecha:** 12 de julio de 2026  
**Historia:** US-UX-06  
**Decisión:** **Implementar PWA** con manifest y service worker de caché estática.

## Contexto

El atlas es 100 % estático (GitHub Pages). Los usuarios frecuentes — estudiantes y productores en campo — se benefician de acceso offline tras la primera visita.

## Alternativas evaluadas

| Opción | Pros | Contras |
|--------|------|---------|
| **PWA con SW** | Instalable, offline para assets y datos JS | Tamaño de caché (~MB de imágenes no precacheadas todas) |
| Solo bookmark | Cero mantenimiento | Sin offline ni icono en pantalla de inicio |
| App nativa | Mejor UX móvil | Fuera de alcance del repo estático |

## Implementación

- `manifest.webmanifest` con iconos SVG 192/512
- `sw.js` — dos estrategias por tipo de recurso (mismo origen):
  - **App shell y datos JS**: cache-first con actualización en red (`STATIC_CACHE`).
  - **Imágenes** (`*.png|jpg|svg|webp|gif|avif`): **stale-while-revalidate** en caché aparte (`IMAGE_CACHE`), para servir al instante y renovar en segundo plano.
- Precaché en `install` (app shell + datos críticos para offline real):
  - `index.html`, `css/styles.css`, `js/app.js`, `js/i18n.js`, `js/analytics*.js`
  - `data/enciclopedia.js`, `data/diccionario_medicos.js`, **`data/enlaces_clinicos.js`**
  - `manifest.webmanifest`, iconos SVG base
- Imágenes de razas/enfermedades: se cachean bajo demanda (stale-while-revalidate), no en install.

### Versionado de caché (US-DEV-11)

`CACHE_VERSION` es `atlas-v3`. En `activate`, el SW borra cualquier caché `atlas-*` que no esté en `CURRENT_CACHES` (`STATIC_CACHE` + `IMAGE_CACHE`), evitando datos obsoletos tras un despliegue.

## Criterios Lighthouse

- Manifest válido e instalable en Chrome/Android
- Service worker registrado en `index.html`
- Contenido principal (navegación + datos) disponible offline tras primera carga

## Mantenimiento

Tras cambios mayores en assets, incrementar `CACHE_VERSION` en `sw.js` (p. ej. `atlas-v3` → `atlas-v4`). El bump invalida las cachés previas en la siguiente activación.
