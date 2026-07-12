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
2. Genera `enciclopedia.js` y `diccionario_medicos.js` desde los JSON

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

```bash
bash ejecutar_pruebas.sh
```

Equivale a `ruby tests/test_enciclopedia.rb` (integridad de JSON, HTML, JS). Es el mismo check que corre en CI.

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
| Imagen rota | Comprueba `images/{id}.jpg\|svg`; usa `list_missing_images.rb` |
| Ruby no encontrado | Instala Ruby 3.x (`brew install ruby`) |
