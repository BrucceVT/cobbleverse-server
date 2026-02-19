# Cobbleverse 1.7.3 — Instrucciones de Setup

## Servidor (Local o VPS)

### Primera vez

```bash
# 1. Crear archivo de entorno
cp .env.example .env

# 2. Editar .env (mínimo configurar RCON_PASSWORD)
nano .env   # o: code .env

# 3. Dar permisos a scripts
chmod +x scripts/*.sh

# 4. Arrancar el servidor
./scripts/up.sh

# 5. Seguir logs hasta ver "Done!"
./scripts/logs.sh
#    Primera vez tarda ~5-10 min (descarga modpack + 13 mods, ~1 GB)

# 6. Aplicar configs y datapacks al mundo
./scripts/apply-extras.sh

# 7. Reiniciar para que carguen los cambios
./scripts/down.sh && ./scripts/up.sh
```

### Operación diaria

```bash
./scripts/up.sh        # Arrancar
./scripts/down.sh      # Parar
./scripts/logs.sh      # Ver logs (Ctrl+C para salir)
./scripts/status.sh    # Estado, salud, mods, datapacks
./scripts/backup.sh    # Backup comprimido (mantiene últimos 5)
```

### Si cambias configs en extras/

```bash
./scripts/down.sh
./scripts/apply-extras.sh
./scripts/up.sh
```

---

## Cliente (cada jugador)

### Modpack base

Instalar **Cobbleverse 1.7.3** desde Modrinth usando uno de:
- [Modrinth App](https://modrinth.com/app)
- [Prism Launcher](https://prismlauncher.org/)

### Mods extra (obligatorios en cliente)

Los siguientes mods están en el servidor y **también deben instalarse en el cliente** para que funcionen correctamente. Descargarlos desde Modrinth y colocarlos en la carpeta `mods/` de la instancia del modpack:

| Mod | Versión | Link |
|-----|---------|------|
| Collective | 8.13 | [Modrinth](https://modrinth.com/mod/collective) |
| Oritech | 0.19.7 | [Modrinth](https://modrinth.com/mod/oritech) |
| Refined Storage | 2.0.0 | [Modrinth](https://modrinth.com/mod/refined-storage) |
| Refined Storage REI | 1.0.0 | [Modrinth](https://modrinth.com/mod/refinedstorage-rei-integration) |
| Gacha Machine | 2.0.2 | [Modrinth](https://modrinth.com/mod/gachamachine) |
| Cobblemon Raid Dens | 0.7.5 | [Modrinth](https://modrinth.com/mod/cobblemon-raid-dens) |
| Cobbled Gacha | 2.1.1 | [Modrinth](https://modrinth.com/mod/cobbledgacha) |
| Falling Tree | 1.21.1.11 | [Modrinth](https://modrinth.com/mod/fallingtree) |
| TerraBlender | 4.1.0.8 | [Modrinth](https://modrinth.com/mod/terrablender) |
| Chipped | 4.0.2 | [Modrinth](https://modrinth.com/mod/chipped) |
| Cobblemon Alphas | 1.4.1 | [Modrinth](https://modrinth.com/mod/cobblemon-alphas) |
| CobbleStats | 1.9.2 | [Modrinth](https://modrinth.com/mod/cobblestats) |

> **C2ME** es solo server-side (performance), no se instala en cliente.

### Resourcepacks (opcionales)

Distribuir a jugadores por Discord, Drive, etc. Copiar a `.minecraft/resourcepacks/`:
- Animon Voices (Ambient)
- cobble_cats
- Skins

### Shaderpacks (opcionales)

Copiar a `.minecraft/shaderpacks/`:
- Photon v1.2a

---

## Diagnóstico de errores

```bash
# Ver errores en logs
docker compose logs | grep -iE "error|fail|crash|incompatible"

# Verificar mods cargados
./scripts/status.sh
```
