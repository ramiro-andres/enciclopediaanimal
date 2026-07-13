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

## Contribuir contenido clínico

Esta sección describe cómo añadir o corregir **razas**, **enfermedades** y **términos del glosario** con calidad clínica verificable.

### Flujo recomendado

1. Abre un issue con la plantilla [Solicitud de contenido](../.github/ISSUE_TEMPLATE/content_request.yml) e incluye fuentes bibliográficas.
2. Implementa los cambios en `scripts/data/` (batch existente o script dedicado).
3. Regenera datos y valida:

```bash
ruby scripts/data/update_enciclopedia_full.rb
bash actualizar_datos.sh
ruby scripts/data/validate_clinical_content.rb
ruby scripts/images/list_missing_images.rb
ruby scripts/images/list_missing_disease_images.rb
bash ejecutar_pruebas.sh
```

4. Abre PR con etiqueta `content` (y `data` o `images` si aplica).

### Formato mínimo de raza

Cada raza vive en `animales[].razas.{pequena|mediana|grande}`:

| Campo | Requisito |
|-------|-----------|
| `id` | Slug único (`labrador_retriever`) |
| `nombre`, `descripcion`, `imagen`, `origen` | Obligatorios |
| `enfermedades` | ≥5 entradas con esquema clínico completo |
| `region` | Opcional; país o macro-región para filtro LATAM/Europa |

Imagen de raza: JPG >8 KB en `images/{id}.jpg` o SVG generado con `bash scripts/setup/generate_placeholders.sh`.

### Esquema mínimo de enfermedad

Cada enfermedad en la ficha de raza debe incluir:

| Campo | Requisito |
|-------|-----------|
| `nombre` | Nombre clínico reconocible |
| `urgencia` | `alta`, `media` o `baja` |
| `pronostico` | Texto orientativo |
| `sintomas`, `prevencion`, `tratamiento` | Descripción clara para estudiantes/profesionales |
| `protocolo_farmacologico` | ≥3 fármacos con `nombre`, `dosis`, `via`, `frecuencia` |
| `referencias` | ≥2 fuentes (libro, guía o artículo revisado) |
| `imagen` | Ruta `images/enfermedades/{especie}_{slug}.jpg` o SVG de respaldo |

Las dosis son **orientativas**; no sustituyen criterio veterinario. Marca enfermedades zoonóticas cuando corresponda (`scripts/data/mark_zoonotic_diseases.rb`).

### Imágenes de enfermedades

- Verificar faltantes: `ruby scripts/images/list_missing_disease_images.rb`
- Descargar solo las que falten: `ruby scripts/images/download_disease_google_images.rb --only-missing`
- Asignar rutas y placeholders SVG: `ruby scripts/images/download_disease_google_images.rb --assign-only`

Umbral CI: JPG >8 KB o SVG en `images/enfermedades/`. El workflow `test` falla si hay enfermedades únicas sin archivo válido.

### Términos del glosario

- Añadir en `scripts/data/build_medical_dictionary.rb` o script de expansión (`expand_dictionary_sprint*.rb`).
- Regenerar: `bash actualizar_datos.sh`
- Enlaces cruzados glosario↔enfermedad: revisar `data/enlaces_clinicos.json` y `scripts/data/suggest_glossary_links.rb`.

### Validación automática

El script `scripts/data/validate_clinical_content.rb` comprueba campos obligatorios, protocolos farmacológicos y referencias. Se ejecuta en CI en cada PR.

## Checklist antes del PR

- [ ] `bash ejecutar_pruebas.sh` pasa en local
- [ ] Hook pre-commit instalado (`bash scripts/setup/instalar_hooks.sh`) para regenerar/validar JSON → JS
- [ ] Si tocaste JSON, ejecutaste `bash actualizar_datos.sh`
- [ ] Si cambiaste datos derivados, `git diff -- data/*.js` no muestra cambios pendientes tras regenerar
- [ ] Imágenes verificadas con `list_missing_images.rb` y `list_missing_disease_images.rb`
- [ ] No commitear logs, `_site/`, `.env`
- [ ] README o docs actualizados si cambiaste paths o flujos

## Etiquetas de GitHub

Etiquetas estándar del repositorio (F5-04):

| Etiqueta | Uso |
|---------|-----|
| `content` | Razas, enfermedades, diccionario |
| `bug` | Comportamiento incorrecto |
| `ui` | Interfaz, estilos, UX |
| `a11y` | Accesibilidad, contraste, reduced-motion |
| `ci` | Workflows y automatización |
| `data` | JSON, scripts de generación |
| `images` | Imágenes de razas o enfermedades |
| `docs` | Documentación |
| `enhancement` | Mejora de funcionalidad existente |
| `dependencies` | Dependabot npm/actions |
| `community` | Plantillas, gobernanza |
| `good first issue` | Contribución inicial guiada |

Crear o actualizar etiquetas en el remoto:

```bash
bash scripts/setup/setup_github_labels.sh
# otro repo: bash scripts/setup/setup_github_labels.sh owner/repo
```

Requiere [GitHub CLI](https://cli.github.com/) autenticada (`gh auth login`).
