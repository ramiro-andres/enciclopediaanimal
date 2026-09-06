---
name: sonar-automatic-analysis
description: >-
  Configura y mantiene SonarQube Cloud con Automatic Analysis en Enciclopedia
  Animal. Usar al tocar Sonar, NCLOC, quality gate, exclusiones, o
  .sonarcloud.properties / sonar-project.properties.
---

# SonarQube Cloud (Automatic Analysis)

Proyecto: `ramiro-andres_enciclopediaanimal` (org `ramiro-andres`).

## Hecho crítico

**Automatic Analysis ignora `sonar-project.properties`.**  
La config desde código que sí aplica es **`.sonarcloud.properties`**.

## Scope actual

```properties
sonar.sources=index.html,css,js,sw.js,manifest.webmanifest
sonar.tests=tests
```

- Sin comodines (restricción de AA).
- Fuera del NCLOC de producto: `data/`, `scripts/`, `docs/`, imágenes, etc.
- `sonar-project.properties` se mantiene solo por si algún día hay scanner CI.

## Qué no hacer

- No añadir workflow Sonar CI **sin** secret `SONAR_TOKEN` y **sin** desactivar AA en la UI de Sonar (chocan).
- No esperar que exclusiones en `sonar-project.properties` bajen NCLOC con AA activo.
- No usar `workflow_run` en deploy solo para “gate” Sonar: reglas S7630/S7631 y superficie innecesaria.

## Quality Gate en PRs

El check **SonarCloud Code Analysis** puede bloquear merge (Security/Reliability de código nuevo ≠ A). Corregir hallazgos; ver skill [fix-sonar-calidad](../fix-sonar-calidad/SKILL.md).

## Docs

Detalle humano: `docs/SONAR.md`.
