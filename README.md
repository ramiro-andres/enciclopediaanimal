# Enciclopedia Animal

Atlas veterinario interactivo con razas, nutrición, enfermedades y diccionario médico.

**Sitio publicado:** https://ramiro-andres.github.io/enciclopediaanimal/

## Inicio rápido

```bash
bash actualizar_datos.sh     # regenerar JS desde JSON
bash ejecutar_pruebas.sh     # pruebas unitarias
```

Para ver el sitio localmente, abre `index.html` en el navegador o usa la URL de GitHub Pages arriba.

## Documentación

| Documento | Contenido |
|-----------|-----------|
| [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) | Flujo de datos, frontend y scripts |
| [docs/ESTRUCTURA.md](docs/ESTRUCTURA.md) | Layout del repositorio |
| [docs/DESARROLLO.md](docs/DESARROLLO.md) | Desarrollo, datos e imágenes |
| [docs/DESPLIEGUE.md](docs/DESPLIEGUE.md) | GitHub Pages y CI/CD |
| [scripts/README.md](scripts/README.md) | Índice de scripts por categoría |

## Contribuir

Los cambios a `main` solo vía **pull request**. Lee [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md).

## Mantenedores

Configuración inicial de GitHub Pages y protección de rama:

```bash
bash scripts/setup/setup_github_security.sh
```

Requiere [GitHub CLI](https://cli.github.com/) autenticada (`gh auth login`).
