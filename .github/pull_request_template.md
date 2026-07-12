## Descripción

<!-- ¿Qué cambia este PR y por qué? -->

## Tipo de cambio

- [ ] Contenido / datos (razas, enfermedades, diccionario)
- [ ] Interfaz o estilos
- [ ] Scripts o automatización
- [ ] Documentación
- [ ] CI/CD o DevOps
- [ ] Otro

## Checklist general

- [ ] Trabajo en una rama distinta de `main` (p. ej. `feature/mi-cambio`)
- [ ] `bash ejecutar_pruebas.sh` pasa en local
- [ ] No incluyo secretos, tokens ni credenciales
- [ ] Las imágenes/datos nuevos respetan licencias y tamaño razonable

## Checklist de contenido clínico (si tocaste `data/`)

- [ ] Ejecuté `bash actualizar_datos.sh` tras modificar JSON
- [ ] Las dosis en protocolos son **orientativas** y el disclaimer educativo sigue visible
- [ ] Cada enfermedad nueva tiene `urgencia`, `pronostico` y `protocolo_farmacologico` (≥3 entradas)
- [ ] Las rutas de imagen existen (JPG >8 KB o SVG de respaldo)
- [ ] Revisé coherencia de `gravedad`, `sintomas` y `referencias`

## Checklist de UI (si tocaste `js/` o `css/`)

- [ ] Navegación usable en móvil (≤768px)
- [ ] Sin rutas de imagen rotas en las vistas tocadas
- [ ] El modal de aviso educativo sigue funcionando

## Notas para revisión

<!-- Contexto extra para @ramiro-andres -->
