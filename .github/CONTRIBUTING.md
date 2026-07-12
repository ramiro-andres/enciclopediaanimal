# Contribuir a Enciclopedia Animal

Gracias por mejorar el atlas veterinario. Este repositorio es **público** y `main` está protegida: los cambios llegan solo mediante **pull requests** aprobados por el propietario.

## Flujo de trabajo

1. **Fork** del repositorio (colaboradores externos) o crea una rama desde `main` (colaboradores con acceso).
2. Crea una rama con nombre descriptivo:
   - `feature/nombre-corto`
   - `fix/descripcion`
   - `docs/tema`
3. Haz commits pequeños y claros en esa rama (no commits directos a `main`).
4. Antes de abrir el PR, ejecuta las pruebas:
   ```bash
   bash ejecutar_pruebas.sh
   ```
5. Abre un **Pull Request** hacia `main` y espera la revisión de `@ramiro-andres` (CODEOWNERS).
6. Tras la aprobación y el merge, el workflow **Desplegar en GitHub Pages** publica el sitio automáticamente.

## Reglas de la rama `main`

- No se permiten **force push** ni borrado de la rama.
- Los merges requieren **al menos una aprobación** del code owner.
- Debe pasar el check de CI **`test / test`** (workflow `.github/workflows/test.yml`).
- Solo el propietario puede hacer push directo a `main` (cuando la protección de rama lo permite en el plan de GitHub).

## Desarrollo local

```bash
bash iniciar.sh          # servidor en http://localhost:8080
bash actualizar_datos.sh # regenerar JS desde JSON
bash ejecutar_pruebas.sh # pruebas unitarias + E2E
```

Documentación detallada: [docs/DESARROLLO.md](../docs/DESARROLLO.md) y [docs/ESTRUCTURA.md](../docs/ESTRUCTURA.md).

## Activar GitHub Pages (mantenedores)

Si Pages aún no está activo, un mantenedor con `gh` autenticado puede ejecutar:

```bash
bash scripts/setup/setup_github_security.sh
```

O manualmente: **Settings → Pages → Build and deployment → Source: GitHub Actions**, y **Settings → Actions → General → Workflow permissions → Read and write permissions**.

## Preguntas

Abre un issue en GitHub describiendo la idea o el problema antes de cambios grandes (nuevas seccions, muchas imágenes, etc.).
