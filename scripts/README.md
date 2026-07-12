# Scripts — Enciclopedia Animal

Scripts de mantenimiento organizados por propósito. Los datos e imágenes del sitio viven en la raíz (`data/`, `images/`); estos scripts los generan o actualizan.

## Estructura

```
scripts/
├── data/      # Generación y enriquecimiento de enciclopedia.json / diccionario
├── images/    # Descarga y corrección de imágenes de razas y enfermedades
└── setup/     # Configuración del repo y placeholders
```

## data/ — Datos de la enciclopedia

| Script | Uso |
|--------|-----|
| `build_medical_dictionary.rb` | Genera `data/diccionario_medicos.json` (invocado por `actualizar_datos.sh`) |
| `update_enciclopedia_full.rb` | Pipeline completo de actualización de razas y enfermedades |
| `expand_enciclopedia.rb` | Expande contenido clínico y nutricional |
| `enrich_veterinary_content.rb` | Enriquece fichas veterinarias |
| `clinical_disease_library.rb` | Biblioteca de enfermedades clínicas |
| `production_breeds_batch*.rb` | Lotes de razas de producción |
| `more_breeds_batch2.rb`, `new_breeds_data.rb` | Datos adicionales de razas |

Ejemplo:

```bash
ruby scripts/data/update_enciclopedia_full.rb
bash actualizar_datos.sh   # JSON → enciclopedia.js + diccionario_medicos.js
```

## images/ — Imágenes

| Script | Uso |
|--------|-----|
| `download_google_images.rb` | Descarga imágenes vía búsqueda Google |
| `download_disease_google_images.rb` | Imágenes de enfermedades |
| `download_breed_specific.rb` | Fuentes específicas por raza |
| `fix_wikipedia_images.rb` | Corrige imágenes con Wikipedia |
| `list_missing_images.rb` | Lista razas sin imagen válida |
| `apply_image_overrides.rb` | Aplica overrides manuales |

Archivos de apoyo: `breed_searches.json`, `wikipedia_titles.json`.

## setup/

| Script | Uso |
|--------|-----|
| `setup_github_security.sh` | Activa Pages (Actions) y protección de `main` |
| `generate_placeholders.sh` | Genera SVG placeholder para razas sin foto |

```bash
bash scripts/setup/generate_placeholders.sh
bash scripts/setup/setup_github_security.sh
```

## Convención de rutas

Los scripts Ruby usan `ROOT = File.expand_path('../..', __dir__)` para referenciar la raíz del repo (`data/`, `images/`). No ejecutes scripts desde otro directorio sin ajustar rutas.
