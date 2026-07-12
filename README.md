# Enciclopedia Animal

Atlas veterinario con razas, nutrición, enfermedades y diccionario médico.

## Sitio publicado

https://ramiro-andres.github.io/enciclopediaanimal/

## Desarrollo local

```bash
bash iniciar.sh
# Abrir http://localhost:8080
```

## Regenerar datos

```bash
bash actualizar_datos.sh
```

## Pruebas

```bash
bash ejecutar_pruebas.sh
```

## Despliegue

El workflow `.github/workflows/deploy-pages.yml` publica en GitHub Pages.

### Activar Pages (obligatorio)

1. Repo **público** (GitHub Pages gratis en cuentas personales).
2. **Settings → Pages → Build and deployment → Source: GitHub Actions**.
3. **Settings → Actions → General → Workflow permissions → Read and write permissions**.

Luego en **Actions** ejecuta **Desplegar en GitHub Pages → Run workflow** si hace falta relanzar.

Sitio: https://ramiro-andres.github.io/enciclopediaanimal/
