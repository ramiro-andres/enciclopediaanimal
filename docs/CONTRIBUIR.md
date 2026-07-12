# Contribuir

Ver [.github/CONTRIBUTING.md](../.github/CONTRIBUTING.md) para el flujo de PR, reglas de `main` y revisión por CODEOWNERS.

## Reportar problemas o proponer cambios

Al abrir un issue en GitHub puedes elegir entre plantillas guiadas:

- **Reporte de error** — fallos en UI, datos, imágenes o CI
- **Solicitud de contenido** — nuevas razas, enfermedades o términos del glosario
- **Solicitud de funcionalidad** — mejoras de producto o infraestructura

Las plantillas están en [`.github/ISSUE_TEMPLATE/`](../.github/ISSUE_TEMPLATE/):

- `bug_report.yml` — errores reproducibles del sitio, datos o CI
- `content_request.yml` — razas, enfermedades, imágenes o términos médicos
- `feature_request.yml` — mejoras de UX, documentación o flujo de desarrollo

## Documentación relacionada

| Tipo de cambio | Ubicación |
|----------------|-----------|
| Contenido de razas/enfermedades | `data/enciclopedia.json` + `actualizar_datos.sh` |
| Estilos | `css/` |
| Lógica UI | `js/app.js` |
| Imagen de raza | `images/` + opcional script en `scripts/images/` |
| Script de datos | `scripts/data/` |
| Script de imágenes | `scripts/images/` |
| Documentación | `docs/` |

## Contribuir contenido

Para proponer **razas**, **enfermedades** o **términos del glosario**:

1. Abre un issue con la plantilla [Solicitud de contenido](../.github/ISSUE_TEMPLATE/content_request.yml)
2. Incluye fuentes bibliográficas verificables
3. Si implementas el cambio tú mismo:
   - Añade la raza en `scripts/data/` (batch existente o nuevo)
   - Ejecuta `ruby scripts/data/update_enciclopedia_full.rb` y `bash actualizar_datos.sh`
   - Genera SVG con `bash scripts/setup/generate_placeholders.sh` si no hay JPG
   - Verifica con `bash ejecutar_pruebas.sh`

### Formato mínimo de raza en JSON

Cada raza requiere: `id`, `nombre`, `descripcion`, `imagen`, `origen`, campos clínicos base y ≥5 `enfermedades` con protocolo farmacológico completo. El script `expand_enciclopedia.rb` enriquece campos automáticamente para entradas nuevas.

## Checklist antes del PR

- [ ] `bash ejecutar_pruebas.sh` pasa en local
- [ ] Si tocaste JSON, ejecutaste `bash actualizar_datos.sh`
- [ ] Si cambiaste datos derivados, `git diff -- data/*.js` no muestra cambios pendientes tras regenerar
- [ ] No commitear logs, `_site/`, `.env`
- [ ] README o docs actualizados si cambiaste paths o flujos

## Contribuir contenido (razas y enfermedades)

### Formato de una raza nueva

Cada raza vive en `animales[].razas.{pequena|mediana|grande}` con campos mínimos: `id`, `nombre`, `descripcion`, `imagen`, `origen`, `enfermedades` (≥5).

Opcional: `region` para filtro LATAM (`Colombia`, `México`, `Argentina`, `Chile`).

### Pipeline recomendado

```bash
ruby scripts/data/update_enciclopedia_full.rb
ruby scripts/data/apply_region_tags.rb
bash scripts/setup/generate_placeholders.sh
bash actualizar_datos.sh
bash ejecutar_pruebas.sh
```

### Enfermedades: esquema mínimo

Incluir `urgencia`, `pronostico`, `protocolo_farmacologico` (≥3 fármacos), `referencias` (≥2) e `imagen`. Las dosis son orientativas.

## Etiquetas de GitHub

`content`, `bug`, `ui`, `ci`, `docs`, `good first issue`. Crear con:

```bash
bash scripts/setup/setup_github_labels.sh
```
