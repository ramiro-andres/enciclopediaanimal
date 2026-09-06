# SonarQube Cloud

Análisis estático del atlas en [SonarQube Cloud](https://sonarcloud.io/dashboard?id=ramiro-andres_enciclopediaanimal)  
(proyecto `ramiro-andres_enciclopediaanimal`, org `ramiro-andres`).

## Método actual: Automatic Analysis

Sonar analiza `main` y PRs al detectar pushes (sin workflow propio de scanner).

**Importante:** Automatic Analysis **ignora** `sonar-project.properties`.  
La configuración desde código que sí aplica es:

| Archivo | Uso |
|---------|-----|
| [`.sonarcloud.properties`](../.sonarcloud.properties) | Scope para Automatic Analysis |
| [`sonar-project.properties`](../sonar-project.properties) | Scope si algún día se usa análisis por CI |

### Scope actual (`.sonarcloud.properties`)

```properties
sonar.sources=index.html,css,js,sw.js,manifest.webmanifest
sonar.tests=tests
```

Quedan fuera del NCLOC de producto: `data/`, `scripts/`, `docs/`, `sitemap.xml`, imágenes, etc.

## Análisis por CI (opcional)

Para que el scanner respete `sonar-project.properties` al 100 %:

1. Crear token en SonarCloud → secret `SONAR_TOKEN` en el repo.
2. Desactivar Automatic Analysis: proyecto → **Administration → Analysis Method**.
3. Añadir un workflow con `SonarSource/sonarqube-scan-action` (no mantener AA y CI a la vez: chocan).

## Quality Gate en PRs

El check **SonarCloud Code Analysis** puede bloquear el merge si el Security/Reliability rating de código nuevo no es A. Corregir hallazgos o ajustar el gate en SonarCloud.
