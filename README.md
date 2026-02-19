# 🟢 Cobbleverse 1.7.3 — Deployment Guide

Servidor de Minecraft con **Cobbleverse 1.7.3** (Modrinth) + 13 mods extra de servidor + configs/datapacks personalizados.

---

## SECCIÓN A — Árbol del proyecto final

```
cobbleverse-server/
├── compose.yaml                   ← Servicio Docker
├── .env.example                   ← Plantilla de variables
├── .env                           ← Tu copia (NO va a git)
├── .gitignore
├── README.md               ← Este documento
│
├── extras/
│   ├── mods-urls.txt              ← 13 mods extra (URLs oficiales)
│   ├── config/                    ← Configs del modpack (del zip)
│   ├── datapack/                  ← Datapacks .zip (del zip)
│   ├── resourcepacks/             ← Para distribución a jugadores
│   └── shaderpacks/               ← Para distribución a jugadores
│
├── scripts/
│   ├── up.sh                      ← Arranca el servidor
│   ├── down.sh                    ← Para el servidor
│   ├── logs.sh                    ← Logs en tiempo real
│   ├── status.sh                  ← Estado, salud, mods, datapacks
│   ├── backup.sh                  ← Backup comprimido con rotación
│   └── apply-extras.sh            ← Copia config/ y datapacks a ./data
│
├── data/                          ← Datos del servidor (persisten)
└── backups/                       ← Backups generados
```

---

## SECCIÓN B — Contenido de cada archivo

### `compose.yaml`

- Imagen: `itzg/minecraft-server:java21`
- Modpack: descargado desde URL directa del `.mrpack` (variable `MODPACK_URL`)
- Mods extra: `MODS_FILE=/extras/mods-urls.txt` (13 URLs de Modrinth CDN)
- Volúmenes: `./data:/data` + `./extras:/extras:ro`
- Health check: `mc-health` con 5 min de arranque

### `.env.example`

| Variable              | Default                                          | Descripción                    |
| --------------------- | ------------------------------------------------ | ------------------------------ |
| `MODPACK_URL`         | `https://cdn.modrinth.com/.../COBBLEVERSE...`    | URL del `.mrpack`              |
| `MEMORY`              | `4G`                                             | RAM del servidor               |
| `SERVER_PORT`         | `25565`                                          | Puerto de juego                |
| `RCON_PORT`           | `25575`                                          | Puerto RCON                    |
| `RCON_PASSWORD`       | `changeme-rcon-password`                         | Contraseña RCON                |
| `MAX_PLAYERS`         | `20`                                             | Jugadores máximos              |
| `VIEW_DISTANCE`       | `10`                                             | Chunks de renderizado          |
| `SIMULATION_DISTANCE` | `8`                                              | Chunks de simulación           |
| `LEVEL`               | `world`                                          | Nombre del mundo               |
| `ONLINE_MODE`         | `true`                                           | Verificación Mojang            |
| `OPS` / `WHITELIST`   | *(vacío)*                                        | Listas de jugadores            |
| `TZ`                  | `America/Bogota`                                 | Zona horaria                   |

### `extras/mods-urls.txt`

13 mods server-side con URLs fijadas (Modrinth CDN):

| Mod                           | Versión         |
| ----------------------------- | --------------- |
| Collective                    | 8.13            |
| Oritech                       | 0.19.7          |
| Refined Storage               | 2.0.0           |
| Refined Storage REI           | 1.0.0           |
| Gacha Machine                 | 2.0.2           |
| Cobblemon Raid Dens           | 0.7.5+1.21.1    |
| Cobbled Gacha                 | 2.1.1           |
| Falling Tree                  | 1.21.1.11       |
| TerraBlender                  | 4.1.0.8         |
| Chipped                       | 4.0.2           |
| Cobblemon Alphas              | 1.4.1           |
| CobbleStats                   | 1.9.2+1.21.1    |
| C2ME                          | 0.3.0+alpha     |

### Scripts

| Script               | Función                                                |
| -------------------- | ------------------------------------------------------ |
| `up.sh`              | `docker compose up -d`                                 |
| `down.sh`            | `docker compose down`                                  |
| `logs.sh`            | `docker compose logs -f --tail=N`                      |
| `status.sh`          | Contenedor + salud + recursos + mods + datapacks       |
| `backup.sh`          | Backup `tar.gz` con RCON save-off y rotación (5)       |
| `apply-extras.sh`    | Copia `extras/config/` → `data/config/` y datapacks    |

---

## SECCIÓN C — Prueba local paso a paso (Windows + Docker Desktop)

### Prerrequisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado y corriendo.
- Git Bash o WSL.
- El archivo `cobbleverse-extras.zip` disponible.

### Paso 1: Extraer el ZIP a extras/

```bash
cd /d/Proyectos/Juegos/cobbleverse-server

# Extraer el zip (sin sobreescribir mods-urls.txt)
# El zip contiene: config/, datapack/, resourcepacks/, shaderpacks/
unzip -o cobbleverse-extras.zip -d extras/

# Si el zip contiene una carpeta mods/, ignorarla:
# (los mods se descargan automáticamente desde mods-urls.txt)
rm -rf extras/mods/
```

Verifica la estructura:
```bash
ls extras/
# config/  datapack/  mods-urls.txt  resourcepacks/  shaderpacks/
```

### Paso 2: Preparar entorno

```bash
cp .env.example .env
chmod +x scripts/*.sh
```

### Paso 3: Verificar compose

```bash
docker compose config
# Debe resolver sin errores
```

### Paso 4: Arrancar el servidor

```bash
./scripts/up.sh
./scripts/logs.sh
# Esperar "Done!" (~5-10 min la primera vez)
```

### Paso 5: Aplicar configs y datapacks

```bash
# Una vez que el mundo existe (después de "Done!"):
./scripts/apply-extras.sh
```

Salida esperada:
```
📁 Applying configs → ./data/config/
📁 Applying datapacks → ./data/world/datapacks/
✅ Applied 2 extra(s) to ./data/.
   Restart the server to load changes:
   ./scripts/down.sh && ./scripts/up.sh
```

### Paso 6: Reiniciar para cargar cambios

```bash
./scripts/down.sh
./scripts/up.sh
./scripts/logs.sh
```

### Paso 7: Verificar

```bash
# Verificar mods instalados
./scripts/status.sh
# Debe mostrar ~XX mods (modpack + 13 extras)

# Verificar datapacks
ls data/world/datapacks/
# Debe mostrar los .zip copiados

# Conectar desde Minecraft: localhost:25565
# (Launcher con Cobbleverse 1.7.3 instalado)
```

### Troubleshooting

| Problema                           | Solución                                          |
| ---------------------------------- | ------------------------------------------------- |
| Puerto 25565 ocupado               | Cambiar `SERVER_PORT` en `.env`                   |
| Descarga lenta la primera vez      | Normal (~1 GB entre modpack + mods)               |
| `apply-extras.sh` dice "no world"  | Esperar a que el server genere el mundo primero    |
| Mod no se descargó                 | Verificar URL en `extras/mods-urls.txt`           |
| Out of memory                      | Reducir `MEMORY=2G` en `.env`                     |

---

## SECCIÓN D — Entrega limpia para VPS

### SÍ se copian

| Archivo/Carpeta            | Motivo                                    |
| -------------------------- | ----------------------------------------- |
| `compose.yaml`             | Definición del servicio                   |
| `.env.example`             | Plantilla                                 |
| `.gitignore`               | Exclusiones                               |
| `README.md`         | Guía                                      |
| `extras/`                  | Mods URLs + configs + datapacks           |
| `scripts/`                 | Comandos operativos                       |

### NO se copian

| Archivo/Carpeta  | Motivo                                              |
| ---------------- | --------------------------------------------------- |
| `.env`           | Contiene secretos — se crea nuevo en el VPS         |
| `data/`          | ~GB — datos del servidor, no versionable            |
| `backups/`       | Locales, no relevantes para otro entorno            |
| `*.zip` (fuente) | Ya extraído en `extras/`                            |

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
MEMORY=6G
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
# Conectar desde Minecraft: IP_VPS:25565
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

### Mods que pueden requerir cliente

Varios mods de la lista son `server + client` o solo `client`. Los mods del modpack base `.mrpack` se instalan automáticamente en el cliente desde el launcher (Modrinth / Prism Launcher).

Para los **13 mods extra**, verificar en Modrinth la columna "Environment":

| Mod                    | Server | Client | Nota                                    |
| ---------------------- | ------ | ------ | --------------------------------------- |
| Collective             | ✅     | ✅     | Librería — también en cliente           |
| Oritech                | ✅     | ✅     | Texturas/GUI — también en cliente       |
| Refined Storage        | ✅     | ✅     | GUI — también en cliente                |
| Refined Storage REI    | ✅     | ✅     | Integración REI — también en cliente    |
| Gacha Machine          | ✅     | ✅     | GUI — también en cliente                |
| Cobblemon Raid Dens    | ✅     | ✅     | Verificar en Modrinth                   |
| Cobbled Gacha          | ✅     | ✅     | Verificar en Modrinth                   |
| Falling Tree           | ✅     | ❓     | Solo server si no tiene animación       |
| TerraBlender           | ✅     | ✅     | Librería — también en cliente           |
| Chipped                | ✅     | ✅     | Texturas — también en cliente           |
| Cobblemon Alphas       | ✅     | ✅     | Verificar en Modrinth                   |
| CobbleStats            | ✅     | ❓     | Verificar en Modrinth                   |
| C2ME                   | ✅     | ❌     | Solo server (performance)               |

> **Acción requerida**: Los mods marcados como `client` también deben ser instalados en el launcher de cada jugador. Distribuir los `.jar` o indicar a los jugadores que los descarguen desde Modrinth.

### Resourcepacks y Shaderpacks

Los archivos en `extras/resourcepacks/` y `extras/shaderpacks/` son **solo para clientes**:

- **No se aplican automáticamente** al servidor.
- Distribuirlos a los jugadores por:
  1. **Google Drive / OneDrive** — compartir enlace.
  2. **GitHub Releases** — adjuntar como assets.
  3. **Instrucciones en Discord** — indicar dónde colocar los archivos.

El jugador debe copiarlos a su carpeta `.minecraft/resourcepacks/` o `.minecraft/shaderpacks/` respectivamente.

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

# ❌ Loader incorrecto
"requires Quilt/Forge loader"

# ⚠️ Mod duplicado
"Duplicate mod: X"

# ⚠️ Mod de cliente en servidor
"is a client-side mod"

# ✅ Éxito
"Done (X.XXs)! For help, type"
```

Para filtrar solo errores:
```bash
docker compose logs | grep -iE "error|fail|crash|exception|incompatible"
```
