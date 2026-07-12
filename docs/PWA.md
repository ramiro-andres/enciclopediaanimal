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
- `sw.js` — estrategia **cache-first con actualización en red** para mismo origen
- Precaché: HTML, CSS, JS, `data/*.js`, iconos base
- Imágenes de razas: se cachean bajo demanda al visitarlas (no en install)

## Criterios Lighthouse

- Manifest válido e instalable en Chrome/Android
- Service worker registrado en `index.html`
- Contenido principal (navegación + datos) disponible offline tras primera carga

## Mantenimiento

Tras cambios mayores en assets, incrementar `CACHE_VERSION` en `sw.js`.
