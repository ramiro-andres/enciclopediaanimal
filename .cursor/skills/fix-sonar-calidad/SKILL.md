---
name: fix-sonar-calidad
description: >-
  Corrige hallazgos SonarQube y deuda de calidad en Enciclopedia Animal (JS
  estático, shells, a11y). Usar al fallar quality gate, issues Security/
  Reliability/Code Smell, o al pedir limpieza Sonar / vulnerabilidades CI.
---

# Corregir Sonar y calidad

Enfoque: **fixes mínimos de alto riesgo**, sin mega-refactor de `app.js`/`styles.css`.

## Patrones que ya aplicamos

| Hallazgo típico | Fix preferido |
|-----------------|---------------|
| Cards/welcome clicables no accesibles | `<button type="button">` (o rol/teclado equivalente) |
| `parseInt` / `parseFloat` | `Number.parseInt` / `Number.parseFloat` con radix |
| Regex con backtracking | Patrones acotados, sin cuantificadores anidados peligrosos |
| Shells con `[` frágil | Preferir `[[ … ]]` en bash donde el estilo del repo lo permita |
| `workflow_run` en deploy | Gate por checks `test`/`e2e` en el mismo SHA, no `workflow_run` |
| XSS / HTML dinámico | Siempre `esc()` / `AtlasUtils.esc`; sin `eval` / `document.write` |
| `onerror` con rutas interpoladas | `data-fallback` + `getAttribute` |
| Enlaces `target="_blank"` | `rel="noopener noreferrer"` |

## Cache del service worker

Al cambiar assets precacheados, subir versión `atlas-v*` en `sw.js` (y alinear tests que aserten la versión).

## Scope Sonar

Antes de “excluir para bajar LOC”: editar **`.sonarcloud.properties`** (AA). Ver [sonar-automatic-analysis](../sonar-automatic-analysis/SKILL.md).

## Verificación

```bash
bash ejecutar_pruebas.sh
# Si tocó UI/navegación:
bash ejecutar_e2e.sh
```

Suite seguridad: `ruby tests/test_security.rb` (también va en la suite completa).

## Docs

- `docs/CALIDAD_CODIGO.md` — auditoría y deuda conocida
- `docs/SONAR.md` — método de análisis
