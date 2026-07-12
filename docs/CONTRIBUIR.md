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

- [DESARROLLO.md](DESARROLLO.md) — entorno local y pruebas
- [ESTRUCTURA.md](ESTRUCTURA.md) — dónde colocar archivos nuevos
- [ARQUITECTURA.md](ARQUITECTURA.md) — cómo encajan datos, JS y frontend

## Dónde poner cambios nuevos

| Tipo de cambio | Ubicación |
|----------------|-----------|
| Contenido de razas/enfermedades | `data/enciclopedia.json` + `actualizar_datos.sh` |
| Estilos | `css/` |
| Lógica UI | `js/app.js` |
| Imagen de raza | `images/` + opcional script en `scripts/images/` |
| Script de datos | `scripts/data/` |
| Script de imágenes | `scripts/images/` |
| Documentación | `docs/` |

## Checklist antes del PR

- [ ] `bash ejecutar_pruebas.sh` pasa en local
- [ ] Si tocaste JSON, ejecutaste `bash actualizar_datos.sh`
- [ ] Si cambiaste datos derivados, `git diff -- data/*.js` no muestra cambios pendientes tras regenerar
- [ ] No commitear logs, `_site/`, `.env`
- [ ] README o docs actualizados si cambiaste paths o flujos
