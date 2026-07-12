# Desarrollo local

Guía para trabajar en Enciclopedia Animal en tu máquina.

## Requisitos

- **Ruby** 3.x (scripts y pruebas)
- **Git** y **GitHub CLI** (`gh`) para PRs

## Ver el sitio

El sitio es estático y se publica en GitHub Pages. Para previsualizar cambios:

- Abre `index.html` directamente en el navegador (los datos se cargan desde `data/enciclopedia.js`), o
- Visita https://ramiro-andres.github.io/enciclopediaanimal/

> **Nota:** Si abres `index.html` con `file://` y ves pantalla vacía, ejecuta `bash actualizar_datos.sh` para regenerar los `.js` embebidos.

## Regenerar datos

Tras editar `data/enciclopedia.json` o ejecutar scripts de datos:

```bash
bash actualizar_datos.sh
```

Esto:

1. Ejecuta `scripts/data/build_medical_dictionary.rb` → actualiza `diccionario_medicos.json`
2. Ejecuta `scripts/data/build_cross_links.rb` → genera `enlaces_clinicos.json` (enlaces bidireccionales diccionario ↔ enfermedades)
3. Genera `enciclopedia.js`, `diccionario_medicos.js` y `enlaces_clinicos.js` desde los JSON

> **Importante:** CI falla si commiteas cambios en los JSON sin regenerar los `.js`. Ejecuta siempre `bash actualizar_datos.sh` antes de abrir la PR.

**Importante:** Si modificas cualquier `data/*.json`, debes ejecutar este script y commitear **tanto el JSON como los `.js` generados**. CI ejecuta `actualizar_datos.sh` y falla si los `.js` no están sincronizados con los JSON.

**Importante:** Si modificas cualquier `data/*.json`, debes ejecutar este script y commitear **tanto el JSON como los `.js` generados**. CI ejecuta `actualizar_datos.sh` y falla si los `.js` no están sincronizados con los JSON.

### Pipeline completo de enciclopedia

Para regenerar contenido desde los scripts de lote:

```bash
ruby scripts/data/update_enciclopedia_full.rb
bash actualizar_datos.sh
```

Otros scripts útiles están listados en [scripts/README.md](../scripts/README.md).

## Imágenes

```bash
# Placeholders SVG para razas sin foto
bash scripts/setup/generate_placeholders.sh

# Descargas (ejemplos)
ruby scripts/images/download_google_images.rb
ruby scripts/images/list_missing_images.rb
```

Los logs de descarga (`*.log`) se escriben en la raíz o cwd y están en `.gitignore`.

## Pruebas

### Pruebas unitarias (Ruby)

```bash
bash ejecutar_pruebas.sh
```

Ejecuta todos los archivos `tests/test_*.rb` (integridad de JSON, HTML, JS y enlaces clínicos) y la validación de integridad `scripts/setup/validar_integridad.rb`. Es el mismo check que corre en el workflow `test`.

### Pruebas E2E de navegador (sin servidor)

Las pruebas end-to-end usan [Playwright](https://playwright.dev) y cargan `index.html` mediante `file://` (los datos van embebidos como `<script>`, así que **no se necesita servidor**). Requieren Node.js ≥ 18.

```bash
bash ejecutar_e2e.sh          # instala dependencias la primera vez y corre las pruebas
```

En CI se ejecutan en el workflow `e2e`. Los escenarios cubren: carga inicial + aviso educativo, raza → enfermedad, enlaces cruzados del glosario y búsqueda global.

### Vista previa de una PR

El workflow `preview` valida la integridad de datos/enlaces y publica un artefacto descargable `vista-previa-sitio` con el `_site` construido, para revisar la PR sin desplegar.

## Flujo de contribución

1. Rama desde `main`: `feature/mi-cambio`
2. Cambios + `bash ejecutar_pruebas.sh`
3. Pull request → revisión → merge
4. Deploy automático a Pages

Detalle en [.github/CONTRIBUTING.md](../.github/CONTRIBUTING.md).

## Solución de problemas

| Problema | Solución |
|----------|----------|
| Pantalla vacía / sin datos | Ejecuta `bash actualizar_datos.sh`; verifica que existan `data/*.js` |
| CI falla en `Validar datos JS derivados` | Ejecuta `bash actualizar_datos.sh`, revisa `git diff` y commitea los `.js` regenerados |
| Imagen rota | Comprueba `images/{id}.jpg\|svg`; usa `list_missing_images.rb` |
| Ruby no encontrado | Instala Ruby 3.x (`brew install ruby`) |

## Mantenimiento del repositorio

Tras mergear PRs, elimina ramas remotas obsoletas para mantener solo `main` activa:

```bash
git fetch --prune origin
gh api repos/OWNER/REPO/branches --jq '.[].name'
```

Ramas mergeadas pueden borrarse con `gh api -X DELETE repos/OWNER/REPO/git/refs/heads/NOMBRE-RAMA`.
