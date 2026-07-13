#!/bin/bash
# Crea etiquetas de GitHub para contribuciones (F5-04).
set -euo pipefail

REPO="${1:-ramiro-andres/enciclopediaanimal}"

labels=(
  "content|Contenido: razas, enfermedades, diccionario|0E8A16"
  "bug|Algo no funciona como se espera|D73A4A"
  "ui|Interfaz, estilos o experiencia de usuario|1D76DB"
  "ci|CI/CD, workflows o automatización|FBCA04"
  "docs|Documentación|0075CA"
  "good first issue|Buena primera contribución|7057FF"
  "dependencies|Actualización de dependencias|0366D6"
  "community|Plantillas, gobernanza o contribución|C5DEF5"
  "a11y|Accesibilidad, contraste o reduced-motion|FEF2C0"
  "data|Datos JSON, scripts de generación o validación|BFDADC"
  "images|Imágenes de razas o enfermedades|F9D0C4"
  "enhancement|Mejora de funcionalidad existente|A2EEEF"
)

for entry in "${labels[@]}"; do
  IFS='|' read -r name description color <<< "$entry"
  gh label create "$name" --repo "$REPO" --description "$description" --color "$color" 2>/dev/null \
    || gh label edit "$name" --repo "$REPO" --description "$description" --color "$color"
  echo "✓ $name"
done

echo "Etiquetas listas en $REPO"
