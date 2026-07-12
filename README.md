# Enciclopedia Animal

Atlas veterinario con razas, nutrición, enfermedades y diccionario médico.

## Sitio publicado

https://ramiro-andres.github.io/enciclopediaanimal/

## Activar GitHub Pages (una sola vez)

El error `Get Pages site failed` significa que Pages **no está activado** en el repositorio.
`enablement: true` **no funciona** con el token por defecto de Actions; hay que activarlo manualmente:

1. Repo **público** (Settings → General → Change visibility).
2. **Settings → Pages → Build and deployment → Source: `GitHub Actions`**.
3. **Settings → Actions → General → Workflow permissions → `Read and write permissions`**.
4. **Actions → Desplegar en GitHub Pages → Run workflow**.

Tras el primer despliegue exitoso, cada push a `main` publica automáticamente.

O ejecuta (con [GitHub CLI](https://cli.github.com/) autenticado):

```bash
bash scripts/setup_github_security.sh
```

## Contribuir con seguridad

- Ramas `feature/*` → Pull Request → aprobación de **@ramiro-andres**
- Ver [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md)

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
