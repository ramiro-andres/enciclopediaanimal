# Contribuir

Ver [.github/CONTRIBUTING.md](../.github/CONTRIBUTING.md) para el flujo de PR, reglas de `main` y revisión por CODEOWNERS.

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
- [ ] No commitear logs, `_site/`, `.env`
- [ ] README o docs actualizados si cambiaste paths o flujos
