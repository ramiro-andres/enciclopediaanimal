# Guía de contribución

## Flujo de trabajo (repositorio público)

1. **Haz fork** del repositorio o pide acceso de colaborador.
2. Crea una rama desde `main`:
   ```bash
   git checkout -b feature/mi-cambio
   ```
3. Realiza tus cambios y ejecuta pruebas:
   ```bash
   bash ejecutar_pruebas.sh
   ```
4. Abre un **Pull Request** hacia `main`.
5. Espera la **revisión y aprobación de @ramiro-andres** (CODEOWNERS).
6. Solo tras la aprobación se fusiona a `main` y se despliega en GitHub Pages.

## Reglas de seguridad

- **Nadie externo** debe hacer push directo a `main`.
- No se permiten **force push** ni borrado de `main`.
- Los cambios en `main` requieren **PR + aprobación del propietario**.
- El workflow de pruebas debe pasar antes del merge (cuando la protección de rama esté activa).

## Desarrollo local

```bash
bash iniciar.sh          # http://localhost:8080
bash actualizar_datos.sh # regenerar JS
```
