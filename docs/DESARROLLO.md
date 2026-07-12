# Desarrollo local

Guía para trabajar en Enciclopedia Animal en tu máquina.

## Requisitos

- **Ruby** 3.x (servidor local, scripts, pruebas)
- **Python 3** (opcional; algunos scripts legacy de imágenes)
- **curl** (descarga de imágenes shell)
- **Git** y **GitHub CLI** (`gh`) para PRs

## Servidor local

```bash
bash iniciar.sh
# http://localhost:8080
```

Usa `ruby -run -e httpd` o `python3 -m http.server` según disponibilidad. Abre el navegador automáticamente en macOS.

Puerto alternativo:

```bash
bash iniciar.sh 3000
```

> **Nota:** Abrir `index.html` con `file://` puede fallar por CORS al cargar datos; usa siempre un servidor HTTP.

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

Incluye:

1. **Unitarias** — `ruby tests/test_enciclopedia.rb` (integridad de JSON, HTML, JS)
2. **E2E** — `scripts/shell/ejecutar_pruebas_navegador.sh` (requiere servidor en el puerto de prueba)

Solo unitarias (como en CI):

```bash
ruby tests/test_enciclopedia.rb
```

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
| E2E falla | Asegura que nada use el puerto 8080 o pasa otro: `TEST_PORT=9090 bash ejecutar_pruebas.sh` |
| Ruby no encontrado | Instala Ruby 3.x (`brew install ruby`) |
