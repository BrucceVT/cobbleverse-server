# Cobbleverse 1.7.3 — Instrucciones de Setup

## Prerrequisitos

### Windows (local)
1. Instalar [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. Abrirlo y esperar a que el motor Docker inicie (icono verde en bandeja)
3. Git Bash o WSL disponible

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

# 2. Editar .env (obligatorio: RCON_PASSWORD, ajustar MEMORY)
#    MEMORY: 8G para 1-5 jugadores, 16G para 10+
nano .env   # o: code .env

# 3. Dar permisos a scripts
chmod +x scripts/*.sh

# 4. Arrancar el servidor
./scripts/up.sh

# 5. Seguir logs hasta ver "Done!"
./scripts/logs.sh
#    Primera vez tarda ~5-10 min (descarga modpack + 12 mods, ~1 GB)

# 6. Aplicar configs, datapacks y parche Xaero
./scripts/apply-extras.sh
#    → Copia extras/config/ a data/config/
#    → Copia extras/datapack/ a data/world/datapacks/
#    → Parchea everyone_tracks_everyone:true en Xaero

# 7. Reiniciar para que carguen los cambios
./scripts/down.sh && ./scripts/up.sh
```

### Operación diaria

```bash
./scripts/up.sh                    # Arrancar
./scripts/down.sh                  # Parar
./scripts/logs.sh                  # Ver logs (Ctrl+C salir)
./scripts/status.sh                # Estado, salud, mods, datapacks
./scripts/backup.sh                # Backup comprimido (últimos 5)
./scripts/apply-extras.sh          # Re-aplicar configs + datapacks + Xaero
./scripts/apply-xaero-config.sh    # Solo parche Xaero (independiente)
```

### Si cambias configs en extras/

```bash
./scripts/down.sh
./scripts/apply-extras.sh
./scripts/up.sh
```

### Verificar Xaero

```bash
# Confirmar que el parche se aplicó
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
