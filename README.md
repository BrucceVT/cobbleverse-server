# 🟢 Cobbleverse 1.7.3 — Deployment Guide

Servidor de Minecraft con **Cobbleverse 1.7.3** (Modrinth) + 12 mods extra de servidor + configs/datapacks personalizados.

---

## SECCIÓN A — Árbol del proyecto

```
cobbleverse-server/
├── compose.yaml                   ← Servicio Docker
├── .env.example                   ← Plantilla de variables
├── .env                           ← Tu copia (NO va a git)
├── .gitignore
├── README.md                      ← Este documento
├── SETUP.md                       ← Instrucciones rápidas
│
├── extras/
│   ├── mods-urls.txt              ← 12 mods extra activos (URLs oficiales)
│   ├── config/                    ← Configs del modpack (cobblemonraiddens, FancyMenu, etc.)
│   └── datapack/                  ← Datapacks .zip
│
├── scripts/
│   ├── up.sh                      ← Arranca el servidor
│   ├── down.sh                    ← Para el servidor
│   ├── logs.sh                    ← Logs en tiempo real
│   ├── status.sh                  ← Estado, salud, recursos, mods, datapacks
│   ├── backup.sh                  ← Backup comprimido con rotación
│   ├── apply-extras.sh            ← Copia config/ y datapacks a ./data
│   └── apply-xaero-config.sh     ← Parchea Xaero (everyone_tracks_everyone)
│
├── data/                          ← Datos del servidor (persisten)
└── backups/                       ← Backups generados
```

---

## SECCIÓN B — Contenido de cada archivo

### `compose.yaml`

- Imagen: `itzg/minecraft-server:java21`
- Modpack: URL directa del `.mrpack` (variable `MODPACK_URL`)
- Mods extra: `MODS_FILE=/extras/mods-urls.txt` (12 URLs activas de Modrinth CDN)
- Volúmenes: `./data:/data` + `./extras:/extras:ro`
- Health check: `mc-health` con 5 min de arranque
- Aikar flags habilitados

### `.env.example`

| Variable              | Default                                          | Descripción                    |
| --------------------- | ------------------------------------------------ | ------------------------------ |
| `MODPACK_URL`         | `https://cdn.modrinth.com/.../COBBLEVERSE...`    | URL del `.mrpack`              |
| `MEMORY`              | `6G` (local) / `12G+` (VPS)                     | RAM JVM (ver nota abajo)       |
| `SERVER_PORT`         | `25565`                                          | Puerto de juego                |
| `RCON_PORT`           | `25575`                                          | Puerto RCON                    |
| `RCON_PASSWORD`       | *(vacío — configurar obligatorio)*               | Contraseña RCON                |
| `MAX_PLAYERS`         | `20`                                             | Jugadores máximos              |
| `VIEW_DISTANCE`       | `10`                                             | Chunks de renderizado          |
| `SIMULATION_DISTANCE` | `8`                                              | Chunks de simulación           |
| `LEVEL`               | `world`                                          | Nombre del mundo               |
| `ONLINE_MODE`         | `true`                                           | Verificación Mojang            |
| `OPS` / `WHITELIST`   | *(vacío)*                                        | Listas de jugadores            |
| `TZ`                  | `America/Bogota`                                 | Zona horaria                   |

> **⚠️ MEMORY debe ser menor que la RAM de Docker.** Si Docker Desktop tiene 8 GB → máximo `MEMORY=6G`. Si pones más, el JVM no arranca (`exitCode: -1`).
>
> | Entorno               | RAM Docker | `MEMORY` recomendado |
> |-----------------------|------------|----------------------|
> | Docker Desktop 8 GB   | ~7.6 GB    | `6G`                 |
> | Docker Desktop 12 GB  | ~11.6 GB   | `8G`                 |
> | VPS 16 GB             | ~15.5 GB   | `12G`                |
> | VPS 32 GB             | ~31 GB     | `16G`                |

### `extras/mods-urls.txt`

12 mods activos + 1 deshabilitado (CobbleStats):

| Mod                           | Versión         | Estado       |
| ----------------------------- | --------------- | ------------ |
| Collective                    | 8.13            | ✅ Activo    |
| Oritech                       | 1.0.1           | ✅ Activo    |
| Refined Storage               | 2.0.1           | ✅ Activo    |
| Refined Storage REI           | 1.0.0           | ✅ Activo    |
| Gacha Machine                 | 2.0.2           | ✅ Activo    |
| Cobblemon Raid Dens           | 0.7.5+1.21.1    | ✅ Activo    |
| Cobbled Gacha                 | 2.1.1           | ✅ Activo    |
| Falling Tree                  | 1.21.1.11       | ✅ Activo    |
| TerraBlender                  | 4.1.0.8         | ✅ Activo    |
| Chipped                       | 4.0.2           | ✅ Activo    |
| Cobblemon Alphas              | 1.4.1           | ✅ Activo    |
| C2ME                          | 0.3.0+alpha     | ✅ Activo    |
| CobbleStats                   | 1.8             | ❌ Disabled  |

### Scripts

| Script                  | Función                                                |
| ----------------------- | ------------------------------------------------------ |
| `up.sh`                 | Arrancar servidor (`docker compose up -d`)             |
| `down.sh`               | Parar servidor (`docker compose stop`)                 |
| `logs.sh`               | `docker compose logs -f --tail=N`                      |
| `status.sh`             | Contenedor + salud + recursos + mods + datapacks       |
| `backup.sh`             | Backup `tar.gz` con RCON save-off y rotación (5)       |
| `apply-extras.sh`       | Copia configs + datapacks + parchea Xaero              |
| `apply-xaero-config.sh` | Parchea `everyone_tracks_everyone:true` en Xaero       |

---

## SECCIÓN C — Prueba local (Windows + Docker Desktop)

### Prerrequisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado y corriendo
- **Verificar RAM asignada**: Settings → Resources → Memory ≥ 8 GB
- Git Bash o WSL

### Pasos

```bash
# 1. Configurar entorno
cp .env.example .env
# Editar .env — obligatorio: RCON_PASSWORD, ajustar MEMORY según tu PC

# 2. Dar permisos a scripts
chmod +x scripts/*.sh

# 3. Verificar compose
docker compose config

# 4. Arrancar el servidor
./scripts/up.sh
./scripts/logs.sh
# Esperar "Done!" (~5-10 min primera vez, descarga ~1 GB)

# 5. Aplicar configs, datapacks y Xaero
./scripts/apply-extras.sh

# 6. Reiniciar para cargar cambios
./scripts/down.sh && ./scripts/up.sh

# 7. Verificar
./scripts/status.sh
ls data/world/datapacks/
grep everyone_tracks data/config/xaero/lib/*.txt
# Conectar: localhost:25565
```

### Troubleshooting

| Problema                           | Solución                                          |
| ---------------------------------- | ------------------------------------------------- |
| Puerto 25565 ocupado               | Cambiar `SERVER_PORT` en `.env`                   |
| Descarga lenta la primera vez      | Normal (~1 GB entre modpack + mods)               |
| `apply-extras.sh` dice "no world"  | Esperar a que el server genere el mundo primero    |
| Mod no se descargó                 | Verificar URL en `extras/mods-urls.txt`           |
| Out of memory                      | Ajustar `MEMORY` en `.env`                        |
| `exitCode: -1` inmediato           | `MEMORY` > RAM de Docker → reducir `MEMORY`       |
| Crash loop (reinicia cada ~45s)    | Verificar RAM o mod incompatible en logs          |
| Xaero config not found             | Iniciar el server primero para generar defaults   |
| Re-init cada arranque (~30s)       | Normal — itzg verifica modpack/mods (cacheado)    |

---

## SECCIÓN D — Entrega para VPS

### SÍ se copian

| Archivo/Carpeta   | Motivo                          |
| ----------------- | ------------------------------- |
| `compose.yaml`    | Definición del servicio         |
| `.env.example`    | Plantilla                       |
| `.gitignore`      | Exclusiones                     |
| `README.md`       | Guía                            |
| `SETUP.md`        | Instrucciones rápidas           |
| `extras/`         | Mods URLs + configs + datapacks |
| `scripts/`        | Comandos operativos             |

### NO se copian

| Archivo/Carpeta  | Motivo                                     |
| ---------------- | ------------------------------------------ |
| `.env`           | Contiene secretos — crear nuevo en VPS     |
| `data/`          | ~GB — datos del servidor                   |
| `backups/`       | Locales                                    |
| `*.zip` (fuente) | Ya extraído en `extras/`                   |

### Git

```bash
git init && git add -A && git commit -m "Cobbleverse 1.7.3 — Docker setup"
git remote add origin git@github.com:TU_USUARIO/cobbleverse-server.git
git push -u origin main
```

### rsync (alternativa)

```bash
rsync -avz --exclude='data/' --exclude='backups/' --exclude='.env' \
  ./ usuario@vps:/opt/cobbleverse-server/
```

---

## SECCIÓN E — Despliegue en VPS (Ubuntu)

### 1. Docker

```bash
sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER && newgrp docker
docker --version && docker compose version
```

### 2. Proyecto

```bash
cd /opt
sudo mkdir -p cobbleverse-server && sudo chown $USER:$USER cobbleverse-server
git clone git@github.com:TU_USUARIO/cobbleverse-server.git cobbleverse-server
cd cobbleverse-server
```

### 3. Configurar

```bash
cp .env.example .env
nano .env
```

Cambios recomendados:
```env
MEMORY=16G
RCON_PASSWORD=password-segura-produccion
OPS=tu_username
```

### 4. Firewall

```bash
sudo ufw allow 25565/tcp
sudo ufw enable
```

### 5. Arrancar

```bash
chmod +x scripts/*.sh
./scripts/up.sh
./scripts/logs.sh
# Esperar "Done!"
```

### 6. Aplicar extras

```bash
./scripts/apply-extras.sh
./scripts/down.sh && ./scripts/up.sh
```

### 7. Verificar

```bash
./scripts/status.sh
grep everyone_tracks data/config/xaero/lib/*.txt
# Conectar: IP_VPS:25565
```

### 8. (Opcional) systemd

```bash
sudo tee /etc/systemd/system/cobbleverse.service > /dev/null <<'EOF'
[Unit]
Description=Cobbleverse Minecraft Server
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/cobbleverse-server
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
User=root

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable cobbleverse
```

### 9. (Opcional) Cron de backup

```bash
(crontab -l 2>/dev/null; echo "0 4 * * * /opt/cobbleverse-server/scripts/backup.sh >> /var/log/cobbleverse-backup.log 2>&1") | crontab -
```

---

## SECCIÓN F — Notas de compatibilidad

### Mods que requieren instalación en cliente

Los 12 mods extra activos del servidor (excepto C2ME) también deben instalarse en el cliente de cada jugador:

| Mod                    | Server | Client | Nota                                    |
| ---------------------- | ------ | ------ | --------------------------------------- |
| Collective             | ✅     | ✅     | Librería                                |
| Oritech                | ✅     | ✅     | Texturas/GUI                            |
| Refined Storage        | ✅     | ✅     | GUI                                     |
| Refined Storage REI    | ✅     | ✅     | Integración REI                         |
| Gacha Machine          | ✅     | ✅     | GUI                                     |
| Cobblemon Raid Dens    | ✅     | ✅     | Entidades                               |
| Cobbled Gacha          | ✅     | ✅     | GUI                                     |
| Falling Tree           | ✅     | ❓     | Posiblemente solo server                |
| TerraBlender           | ✅     | ✅     | Librería                                |
| Chipped                | ✅     | ✅     | Texturas                                |
| Cobblemon Alphas       | ✅     | ✅     | Modelos                                 |
| C2ME                   | ✅     | ❌     | Solo server (performance)               |

### Xaero's Minimap/World Map

La opción `everyone_tracks_everyone:true` se aplica automáticamente via `apply-extras.sh` → `apply-xaero-config.sh`:
- Ubicación nueva: `data/config/xaero/lib/*.txt`
- Ubicación legacy: `data/config/xaerominimap-common.txt` / `xaeroworldmap-common.txt`
- El script es idempotente y maneja ambas ubicaciones.

### Diagnosticar conflictos en logs

```bash
./scripts/logs.sh 300
```

Patrones a buscar:

```bash
# ❌ Dependencia faltante
"requires mod X version >= Y"

# ❌ Versión incompatible
"Mod X is not compatible with Minecraft Y"

# ⚠️ Mod duplicado
"Duplicate mod: X"

# ✅ Éxito
"Done (X.XXs)! For help, type"
```

Filtrar errores:
```bash
docker compose logs | grep -iE "error|fail|crash|exception|incompatible"
```
