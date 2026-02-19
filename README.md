# 🟢 Cobbleverse 1.7.3 — Deployment Guide

Servidor de Minecraft con el modpack **Cobbleverse 1.7.3** (Modrinth) usando Docker Compose.

**Filosofía del proyecto:**
* Cero trabajo manual
* Cero redistribución de `.jar`
* Reproducibilidad total
* Local → VPS sin cambios de arquitectura

---

## SECCIÓN A — Estructura final del proyecto

```
cobbleverse-server/
├── compose.yaml              ← Servicio Docker (itzg/minecraft-server)
├── .env.example              ← Plantilla de variables de entorno
├── .env                      ← Tu copia local (NO se sube a git)
├── .gitignore                ← Exclusiones de git
├── README.md                 ← Info general del repo
├── README_DEPLOY.md          ← Este documento
├── extras/
│   ├── modrinth-mods.txt     ← Mods extra vía Modrinth (slugs)
│   └── mods-urls.txt         ← Mods extra vía URLs directas
├── scripts/
│   ├── up.sh                 ← Arranca el servidor
│   ├── down.sh               ← Para el servidor
│   ├── logs.sh               ← Logs en tiempo real
│   ├── status.sh             ← Estado, salud y recursos
│   └── backup.sh             ← Backup comprimido con rotación
├── data/                     ← Datos del servidor (mundo, mods, configs)
└── backups/                  ← Backups generados automáticamente
```

---

## SECCIÓN B — Contenido de cada archivo

### `compose.yaml`

Servicio único `mc` basado en `itzg/minecraft-server:java21`:
- **Modpack**: se descarga automáticamente desde la URL directa del `.mrpack`.
- **Mods extra (Modrinth)**: lee `extras/modrinth-mods.txt` montado en `/extras`.
- **Mods extra (URLs)**: lee `extras/mods-urls.txt` montado en `/extras`.
- **Persistencia**: `./data` → `/data`.
- **Health check**: `mc-health` con periodo de arranque de 5 min.
- Todas las configuraciones se inyectan desde `.env`.

### `.env.example`

| Variable              | Default                                         | Descripción                       |
| --------------------- | ----------------------------------------------- | --------------------------------- |
| `MODPACK_URL`         | `https://cdn.modrinth.com/.../COBBLEVERSE...`   | URL directa del `.mrpack`        |
| `MEMORY`              | `4G`                                            | RAM del servidor                  |
| `SERVER_PORT`         | `25565`                                         | Puerto de juego (host)            |
| `RCON_PORT`           | `25575`                                         | Puerto RCON (host)                |
| `RCON_PASSWORD`       | `changeme-rcon-password`                        | Contraseña RCON                   |
| `MAX_PLAYERS`         | `20`                                            | Jugadores máximos                 |
| `MOTD`                | `§6Cobbleverse §7— §aCatch them all!`          | Mensaje del servidor              |
| `DIFFICULTY`          | `normal`                                        | Dificultad                        |
| `MODE`                | `survival`                                      | Modo de juego                     |
| `VIEW_DISTANCE`       | `10`                                            | Chunks de renderizado             |
| `SIMULATION_DISTANCE` | `8`                                             | Chunks de simulación              |
| `ONLINE_MODE`         | `true`                                          | Verificación Mojang               |
| `WHITELIST`           | *(vacío)*                                       | Jugadores permitidos (comas)      |
| `OPS`                 | *(vacío)*                                       | Operadores (comas)                |
| `MC_IMAGE_TAG`        | `java21`                                        | Tag de la imagen Docker           |
| `TZ`                  | `America/Bogota`                                | Zona horaria                      |

### `extras/modrinth-mods.txt`

Archivo de texto con un slug de Modrinth por línea. Soporta versionado:
```
chunky:1.4.16
ledger
spark:1.10.73
```

### `extras/mods-urls.txt`

Archivo de texto con una URL directa por línea (para mods fuera de Modrinth):
```
https://github.com/author/mod/releases/download/v1.0.0/mod-1.0.0.jar
```

### Scripts

| Script           | Función                                              |
| ---------------- | ---------------------------------------------------- |
| `scripts/up.sh`  | `docker compose up -d` + mensajes de ayuda           |
| `scripts/down.sh`| `docker compose down` (parada limpia)                |
| `scripts/logs.sh`| `docker compose logs -f --tail=N` (default 100)      |
| `scripts/status.sh` | Estado del contenedor, salud, recursos y mods     |
| `scripts/backup.sh` | Backup `tar.gz` con RCON save-off y rotación (5)  |

---

## SECCIÓN C — Prueba local paso a paso (Windows + Docker Desktop)

### Prerrequisitos
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado y corriendo.
- Git Bash o WSL para ejecutar scripts `.sh`.
- Launcher de Minecraft con Cobbleverse 1.7.3 instalado (para conectar al servidor).

### Pasos

```bash
# 1. Ir al directorio del proyecto
cd /d/Proyectos/Juegos/cobbleverse-server

# 2. Crear .env desde la plantilla
cp .env.example .env

# 3. (Opcional) Editar .env — defaults están bien para local
#    code .env

# 4. Dar permisos de ejecución (solo una vez)
chmod +x scripts/*.sh

# 5. Verificar que compose resuelve correctamente
docker compose config

# 6. Arrancar el servidor
./scripts/up.sh

# 7. Ver logs (primera vez tarda ~5-10 min descargando modpack)
./scripts/logs.sh

# 8. Esperar "Done!" en los logs → servidor listo

# 9. Conectar desde Minecraft: localhost:25565

# 10. Verificar estado
./scripts/status.sh
```

### Verificación post-arranque

```bash
# Verificar que el .mrpack se instaló
ls data/mods/
# Debe mostrar docenas de archivos .jar (los mods del modpack)

# Verificar mods extra de extras/modrinth-mods.txt
# (solo si descomentaste algún mod)
./scripts/logs.sh 50
# Buscar líneas como: "Downloading modrinth project chunky"

# Hacer un backup de prueba
./scripts/backup.sh

# Parar el servidor
./scripts/down.sh

# Verificar que los datos persisten
ls data/world/
# Debe existir si entraste al mundo
```

### Troubleshooting local

| Problema                        | Solución                                          |
| ------------------------------- | ------------------------------------------------- |
| Puerto 25565 ocupado            | Cambiar `SERVER_PORT` en `.env`                   |
| Se queda en "Starting…" mucho   | Normal la primera vez (descarga ~1 GB)            |
| `docker compose` no encontrado  | Actualizar Docker Desktop                         |
| Out of memory                   | Reducir `MEMORY=2G` en `.env`                     |
| Mod no se descargó              | Verificar slug en modrinth.com y compatibilidad   |

---

## SECCIÓN D — Entrega limpia para VPS

### Archivos que SÍ se copian

| Archivo/Carpeta            | Motivo                                    |
| -------------------------- | ----------------------------------------- |
| `compose.yaml`             | Definición del servicio                   |
| `.env.example`             | Plantilla de configuración                |
| `.gitignore`               | Exclusiones                               |
| `README.md`                | Documentación general                     |
| `README_DEPLOY.md`         | Guía de despliegue                        |
| `extras/`                  | Listas de mods extra                      |
| `scripts/`                 | Comandos operativos                       |

### Archivos que NO se copian

| Archivo/Carpeta | Motivo                                              |
| --------------- | --------------------------------------------------- |
| `.env`          | Contiene secretos — se crea nuevo en cada entorno   |
| `data/`         | Datos del servidor — ~GB de tamaño, no versionable  |
| `backups/`      | Backups locales — no relevantes para otro entorno   |

### Método 1: Git (recomendado)

```bash
# En local
cd /d/Proyectos/Juegos/cobbleverse-server
git init && git add -A && git commit -m "Cobbleverse 1.7.3 — Docker setup"
git remote add origin git@github.com:TU_USUARIO/cobbleverse-server.git
git push -u origin main
```

### Método 2: rsync directo

```bash
rsync -avz --exclude='data/' --exclude='backups/' --exclude='.env' \
  ./ usuario@tu-vps:/opt/cobbleverse-server/
```

---

## SECCIÓN E — Despliegue en VPS (Ubuntu 22.04 / 24.04)

### 1. Instalar Docker

```bash
sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
newgrp docker
docker --version && docker compose version
```

### 2. Clonar el proyecto

```bash
cd /opt
sudo mkdir -p cobbleverse-server && sudo chown $USER:$USER cobbleverse-server
git clone git@github.com:TU_USUARIO/cobbleverse-server.git cobbleverse-server
cd cobbleverse-server
```

### 3. Configurar entorno producción

```bash
cp .env.example .env
nano .env
```

Cambios típicos para VPS:
```env
MEMORY=6G
RCON_PASSWORD=una-password-segura-de-produccion
OPS=tu_username
MOTD=§6Cobbleverse §7— §bProduction
```

### 4. Firewall

```bash
sudo ufw allow 25565/tcp
# NO abrir RCON (25575) a internet — solo acceso local
sudo ufw enable
sudo ufw status
```

### 5. Arrancar

```bash
chmod +x scripts/*.sh
./scripts/up.sh
./scripts/logs.sh
# Esperar "Done!" en logs
```

### 6. Verificación externa

```bash
# Desde otra máquina:
# 1. Abrir Minecraft con Cobbleverse 1.7.3
# 2. Agregar servidor: IP_VPS:25565
# 3. Conectar y verificar que el mundo carga con mods
```

### 7. (Opcional) Arranque automático con systemd

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
sudo systemctl start cobbleverse
```

### 8. (Opcional) Backup automático con cron

```bash
(crontab -l 2>/dev/null; echo "0 4 * * * /opt/cobbleverse-server/scripts/backup.sh >> /var/log/cobbleverse-backup.log 2>&1") | crontab -
```

---

## SECCIÓN F — Gestión reproducible de mods extra (server-side)

### Dos mecanismos disponibles

| Mecanismo                        | Archivo                        | Cuándo usar                                |
| -------------------------------- | ------------------------------ | ------------------------------------------ |
| **Modrinth slugs**               | `extras/modrinth-mods.txt`     | Mod disponible en Modrinth (preferido)     |
| **URLs directas**                | `extras/mods-urls.txt`         | Mod no disponible en Modrinth              |

### Cómo agregar un mod

**Opción A — Mod en Modrinth:**

1. Buscar el mod en [modrinth.com](https://modrinth.com).
2. Copiar el slug de la URL (ejemplo: `modrinth.com/mod/chunky` → slug: `chunky`).
3. Agregar al archivo `extras/modrinth-mods.txt`:
   ```
   chunky
   ```
4. Reiniciar: `./scripts/down.sh && ./scripts/up.sh`

**Opción B — Mod fuera de Modrinth:**

1. Obtener la URL directa al `.jar` (GitHub Releases, sitio oficial).
2. Agregar al archivo `extras/mods-urls.txt`:
   ```
   https://github.com/author/mod/releases/download/v1.0.0/mod-1.0.0.jar
   ```
3. Reiniciar: `./scripts/down.sh && ./scripts/up.sh`

### Cómo fijar versiones (reproducibilidad)

**Modrinth** — usar `slug:version_number`:
```
chunky:1.4.16
spark:1.10.73
```

Sin versión fijada, siempre descarga la última release compatible. Esto puede romper cosas entre actualizaciones.

**URLs directas** — usar URLs versionadas:
```
# ✅ Versionado (reproducible)
https://github.com/author/mod/releases/download/v1.0.0/mod-1.0.0.jar

# ❌ Sin versión (no reproducible)
https://example.com/mod-latest.jar
```

### Cómo quitar un mod

1. Eliminar o comentar la línea en `extras/modrinth-mods.txt` o `extras/mods-urls.txt`.
2. **Eliminar manualmente** el `.jar` correspondiente de `./data/mods/`:
   ```bash
   rm ./data/mods/nombre-del-mod-*.jar
   ```
3. Reiniciar: `./scripts/down.sh && ./scripts/up.sh`

> **¿Por qué hay que borrar el .jar manualmente?**
> El contenedor descarga mods solo una vez. Si el `.jar` ya existe en `./data/mods/`, no se re-descarga ni se elimina automáticamente al quitar la entrada del archivo.

### Cómo detectar conflictos en logs

```bash
./scripts/logs.sh 200
```

Buscar patrones como:
```
# Error de compatibilidad entre mods
ERROR: Mod X requires Y version >= 2.0, but found 1.5

# Mod que requiere otro loader
ERROR: Mod X requires Quilt loader

# Mod que requiere cliente
WARN: Mod X is a client-side mod and will be ignored

# Mod duplicado
WARN: Duplicate mod: X found in multiple locations
```

### ¿Qué hacer si un mod requiere cliente?

Los mods server-side se listan en `extras/`. Si un mod requiere instalación en el cliente:

1. **No lo agregues** a `extras/`. No sirve en el servidor.
2. El mod debe instalarse en el **launcher del cliente** (como parte del modpack o manualmente).
3. Revisa la página del mod en Modrinth → pestaña "Environment" para ver si es `server`, `client`, o `both`.

### Resumen del flujo

```
1. Editar extras/modrinth-mods.txt o extras/mods-urls.txt
2. ./scripts/down.sh
3. ./scripts/up.sh
4. ./scripts/logs.sh  → verificar descarga sin errores
5. ./scripts/status.sh → verificar mod count
```
