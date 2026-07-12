# Estructura del repositorio

Layout del proyecto tras la reorganización. Los assets del sitio permanecen en la raíz para GitHub Pages.

```
enciclopedia_animal/
├── index.html              # Entrada del sitio (requerido en raíz para Pages)
├── .nojekyll               # Desactiva Jekyll en GitHub Pages
├── css/                    # Estilos
├── js/
│   └── app.js              # Aplicación SPA
├── data/
│   ├── enciclopedia.json   # Fuente de verdad (datos)
│   ├── enciclopedia.js     # Generado — window.ENCICLOPEDIA_DATA
│   ├── diccionario_medicos.json
│   └── diccionario_medicos.js
├── images/                 # Fotos y SVG de razas y enfermedades
├── tests/
│   └── test_enciclopedia.rb    # Pruebas unitarias
├── docs/                   # Documentación del proyecto
├── scripts/
│   ├── README.md           # Índice de scripts
│   ├── data/               # Generación de JSON
│   ├── images/             # Descarga y corrección de imágenes
│   └── setup/              # GitHub Pages, placeholders
├── .github/
│   ├── workflows/
│   │   ├── test.yml        # CI en PRs
│   │   └── deploy-pages.yml
│   └── CONTRIBUTING.md
├── actualizar_datos.sh     # Wrapper UX — JSON → JS
├── ejecutar_pruebas.sh     # Wrapper UX — pruebas unitarias
└── README.md               # Entrada — enlaces a docs/
```

## Qué va en la raíz y por qué

| Elemento | Motivo |
|----------|--------|
| `index.html`, `css/`, `js/`, `data/`, `images/` | GitHub Pages sirve el sitio desde estos paths; el workflow copia tal cual a `_site/`. |
| `actualizar_datos.sh`, `ejecutar_pruebas.sh` | Comandos habituales del día a día; wrappers delgados hacia `scripts/`. |
| `_site/` | Artefacto local/gitignored; en CI lo genera el workflow. |

## Qué no va en la raíz

| Elemento | Ubicación |
|----------|-----------|
| Scripts Ruby de datos | `scripts/data/` |
| Scripts de imágenes | `scripts/images/` |
| Config GitHub / placeholders | `scripts/setup/` |
| Logs de descarga | Gitignored (`*.log`, `download*.log`) |
| Documentación extensa | `docs/` |

## Archivos generados vs versionados

- **Versionados**: `.json` fuente, imágenes finales, `.js` derivados (para que Pages funcione sin paso de build en el visitante).
- **No versionados**: `_site/`, logs, `.DS_Store`, `.env`.
