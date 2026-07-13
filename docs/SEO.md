# SEO y metadatos dinámicos

## Sitemap y robots

- `sitemap.xml` se genera con `ruby scripts/data/build_sitemap.rb` (también vía `bash actualizar_datos.sh`).
- Incluye la home, vistas estáticas (`#glosario`, `#herramientas`, …) y rutas hash por raza, enfermedad y término del glosario.
- `robots.txt` referencia el sitemap en la URL de producción (GitHub Pages).

## Open Graph y Twitter Cards dinámicos

Al navegar a una ficha de raza o enfermedad, `js/app.js` actualiza en el cliente:

- `og:title`, `og:description`, `og:image`, `og:url`
- Equivalentes `twitter:*`
- `<link rel="canonical">` y `<meta name="description">`

Al volver al inicio (`goWelcome`) se restauran los valores por defecto de `index.html`.

### Limitación conocida

Los crawlers de redes sociales y buscadores **no ejecutan JavaScript** en la mayoría de los casos. El preview al compartir una URL con hash (`#raza/...`) seguirá mostrando los metadatos estáticos del `index.html` para bots clásicos.

- **Compartir en apps que sí ejecutan JS** (algunos clientes móviles, navegadores) puede beneficiarse de la actualización dinámica.
- **Descubrimiento para buscadores:** el `sitemap.xml` lista las rutas hash como referencia; la indexación profunda de SPAs con hash sigue siendo limitada frente a HTML por ruta en servidor.

Para previews fiables en todas las plataformas haría falta pre-renderizado o páginas estáticas por ficha (fuera del alcance actual).

## JSON-LD (Schema.org)

- **Enfermedad:** `MedicalWebPage` con `about` → `MedicalCondition` (síntomas, tratamiento).
- **Glosario (término):** `DefinedTerm` dentro de un `DefinedTermSet`.

El bloque `<script type="application/ld+json" id="atlas-jsonld">` se reemplaza al cambiar de vista.

## Reportar error de contenido

Botón en fichas de raza y enfermedad que abre un issue en GitHub con la plantilla `content_request.yml` y campos prellenados (nombre, URL con hash, categoría animal).
