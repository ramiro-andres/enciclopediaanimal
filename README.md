# Enciclopedia Animal

Atlas veterinario con razas, nutrición, enfermedades y diccionario médico.

## Sitio publicado

https://ramiro-andres.github.io/enciclopediaanimal/

## Contribuir

Lee [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md): cambios a `main` solo vía **pull request** con aprobación del propietario. CI ejecuta `.github/workflows/test.yml` en cada PR.

## GitHub Pages y seguridad (mantenedores)

Tras clonar, con [GitHub CLI](https://cli.github.com/) autenticada (`gh auth login`):

```bash
bash scripts/setup_github_security.sh
```

Eso activa **Pages con GitHub Actions** y la protección de `main`. Si prefieres la UI:

1. **Settings → Pages → Build and deployment → Source: `GitHub Actions`**
2. **Settings → Actions → General → Workflow permissions → `Read and write permissions`**
3. **Settings → Branches → Add rule** para `main` (PR obligatorio, sin force push, revisión CODEOWNERS)

Luego ejecuta **Actions → Desplegar en GitHub Pages → Run workflow** una vez si hace falta el primer despliegue.

## Desarrollo local

```bash
bash iniciar.sh
# http://localhost:8080
```

## Regenerar datos

```bash
bash actualizar_datos.sh
```

## Pruebas

```bash
bash ejecutar_pruebas.sh
```
