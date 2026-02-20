FROM itzg/minecraft-server:java21

# Metadata opcional
LABEL maintainer="Frank"
LABEL description="Cobbleverse Minecraft Server"

# Variables por defecto (pueden sobreescribirse en runtime)
ENV EULA=TRUE \
    TYPE=MODRINTH \
    VERSION=LATEST \
    USE_AIKAR_FLAGS=true \
    TZ=UTC \
    MODS_FILE=/extras/mods-urls.txt

# Exponer puertos (documentación, no los publica automáticamente)
EXPOSE 25565 25575

# Healthcheck
HEALTHCHECK --start-period=5m --interval=30s --timeout=10s --retries=6 \
    CMD mc-health
