# Cobbleverse 1.7.3 — Instrucciones de Setup

## Prerrequisitos

### Windows (local)
1. Instalar [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. Abrirlo y esperar a que el motor Docker inicie (icono verde en bandeja)
3. **Verificar RAM asignada**: Settings → Resources → Memory
   - Mínimo: `8 GB` (para `MEMORY=6G` en `.env`)
   - Recomendado: `12+ GB` (para `MEMORY=8G+`)
   - La RAM de Docker Desktop **debe ser mayor** que el valor de `MEMORY`
4. Git Bash o WSL disponible

### Ubuntu VPS
```bash
sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER && newgrp docker
docker --version && docker compose version
```

---

## Servidor (Local o VPS)

### Primera vez

```bash
# 1. Crear archivo de entorno
cp .env.example .env

# 2. Editar .env
#    OBLIGATORIO: RCON_PASSWORD
#    AJUSTAR: MEMORY según tu RAM disponible
#       Docker Desktop 8GB  → MEMORY=6G
#       Docker Desktop 12GB → MEMORY=8G
#       VPS 16GB+           → MEMORY=12G
nano .env   # o: code .env

# 3. Dar permisos a scripts
chmod +x scripts/*.sh

# 4. Arrancar el servidor
./scripts/up.sh

# 5. Seguir logs hasta ver "Done!"
./scripts/logs.sh
#    Primera vez: ~5-10 min (descarga modpack + 12 mods, ~1 GB)
#    Arranques siguientes: ~30-60s (verificación cacheada)

# 6. Esperar parche automático (init.d)
#    → Copia extras/config/ a data/config/
#    → Copia extras/datapack/ a data/world/datapacks/
#    → Parchea OPAC y Xaero automáticamente
#    (El servidor se encarga de esto mientras arranca)

# 7. ¡Listo para jugar!
```

### Operación diaria

./scripts/up.sh                    # Arrancar (~30-60s, verificación cacheada)
./scripts/down.sh                  # Parar (mundo se guarda automáticamente)
./scripts/logs.sh                  # Ver logs (Ctrl+C salir)
./scripts/status.sh                # Estado, salud, mods, datapacks
./scripts/backup.sh                # Backup comprimido (últimos 5)

### Persistencia de datos

- **Todo persiste** en `./data/` entre reinicios (mundo, mods, configs)
- `./scripts/down.sh` para el servidor; `./scripts/up.sh` lo reanuda
- El servidor siempre verifica modpack + mods al arrancar (~30s), pero **no re-descarga** lo que ya tiene
- Puedes apagar por la noche y encender al día siguiente sin perder nada

### Si cambias compose.yaml o .env

```bash
# Necesitas recrear el contenedor:
docker compose down    # (destruye contenedor, datos en ./data/ persisten)
./scripts/up.sh        # Crea nuevo contenedor con la nueva config
```

### Si cambias configs en extras/

```bash
./scripts/down.sh
./scripts/up.sh
# El contenedor detectará el arranque y copiará los cambios usando init.d
```

### Verificar Xaero

```bash
grep everyone_tracks data/config/xaero/lib/*.txt
# Debe mostrar: everyone_tracks_everyone:true
```

---

## Cliente (cada jugador)

### Modpack base

Instalar **Cobbleverse 1.7.3** desde Modrinth usando uno de:
- [Modrinth App](https://modrinth.com/app)
- [Prism Launcher](https://prismlauncher.org/)

### Mods extra (obligatorios en cliente)

Los siguientes mods están en el servidor y **también deben instalarse en el cliente**. Descargarlos desde Modrinth y colocarlos en `mods/` de la instancia:

| Mod | Versión | Link |
|-----|---------|------|
| Collective | 8.13 | [Modrinth](https://modrinth.com/mod/collective) |
| Oritech | 1.0.1 | [Modrinth](https://modrinth.com/mod/oritech) |
| Refined Storage | 2.0.1 | [Modrinth](https://modrinth.com/mod/refined-storage) |
| Refined Storage REI | 1.0.0 | [Modrinth](https://modrinth.com/mod/refinedstorage-rei-integration) |
| Gacha Machine | 2.0.2 | [Modrinth](https://modrinth.com/mod/gachamachine) |
| Cobblemon Raid Dens | 0.7.5 | [Modrinth](https://modrinth.com/mod/cobblemon-raid-dens) |
| Cobbled Gacha | 2.1.1 | [Modrinth](https://modrinth.com/mod/cobbledgacha) |
| Falling Tree | 1.21.1.11 | [Modrinth](https://modrinth.com/mod/fallingtree) |
| TerraBlender | 4.1.0.8 | [Modrinth](https://modrinth.com/mod/terrablender) |
| Chipped | 4.0.2 | [Modrinth](https://modrinth.com/mod/chipped) |
| Cobblemon Alphas | 1.4.1 | [Modrinth](https://modrinth.com/mod/cobblemon-alphas) |

> **C2ME** es solo server-side (performance), no se instala en cliente.
> **CobbleStats** está deshabilitado por incompatibilidad.

---

## Diagnóstico de errores

```bash
# Ver errores en logs
docker compose logs | grep -iE "error|fail|crash|incompatible"

# Verificar mods cargados
./scripts/status.sh

# Verificar datapacks
ls data/world/datapacks/
```

### Errores comunes

| Problema | Causa | Solución |
|----------|-------|----------|
| `exitCode: -1` inmediato | JVM no puede asignar RAM | Reducir `MEMORY` en `.env` (debe ser < RAM de Docker) |
| Puerto 25565 ocupado | Otro proceso usa el puerto | Cambiar `SERVER_PORT` en `.env` |
| Crash loop (reinicio constante) | Mod incompatible o RAM insuficiente | Ver logs, ajustar MEMORY |
| API version mismatch | Docker Desktop desactualizado | Reiniciar Docker Desktop o actualizar |
