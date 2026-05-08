# Minecraft Server Dockerfile para ARM64 (Render.com)
# Soporta Java Edition (Paper 1.20.5) + Bedrock Edition (Geyser)
# ✅ Descarga desde CDN oficial de Paper - SIN ERRORES SSL

FROM eclipse-temurin:17-jre-jammy

# Metadata
LABEL maintainer="ErantBiscuit"
LABEL description="Minecraft Server Paper 1.20.5 + Geyser para Bedrock en ARM64"

# Variables de entorno
ENV MINECRAFT_HOME=/minecraft \
    JAVA_OPTS="-Xms512M -Xmx1024M -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:G1NewCollectionHeuristicPercent=30 -XX:G1ReservePercent=20 -XX:G1HeapRegionSize=32M" \
    SERVER_PORT=25565 \
    BEDROCK_PORT=19132 \
    DEBIAN_FRONTEND=noninteractive

# Instalar herramientas necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    bash \
    netcat-openbsd \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario no-root
RUN useradd -m -u 1000 minecraft

# Crear estructura de directorios
WORKDIR ${MINECRAFT_HOME}
RUN mkdir -p ${MINECRAFT_HOME}/{plugins,world,logs,backups} && \
    chown -R minecraft:minecraft ${MINECRAFT_HOME}

# ✅ Descargar Paper Server 1.20.5 desde CDN oficial (BUILD 974)
# CDN oficial es 100% confiable - sin problemas SSL
RUN echo "📥 Descargando Paper Server 1.20.5 Build 974..." && \
    curl -L --connect-timeout 30 --max-time 300 \
    -o ${MINECRAFT_HOME}/paper.jar \
    "https://cdn.papermc.io/downloads/paper/1.20.5/paper-1.20.5-974.jar" && \
    echo "✅ Verificando descarga..." && \
    if [ ! -f ${MINECRAFT_HOME}/paper.jar ] || [ ! -s ${MINECRAFT_HOME}/paper.jar ]; then \
        echo "❌ ERROR: Descarga fallida - Intentando URL alternativa..."; \
        curl -L --connect-timeout 30 --max-time 300 \
        -o ${MINECRAFT_HOME}/paper.jar \
        "https://api.papermc.io/v2/projects/paper/versions/1.20.5/builds/974/downloads/paper-1.20.5-974.jar" || \
        (echo "❌ FATAL: No se pudo descargar Paper desde ninguna fuente" && exit 1); \
    fi && \
    FILE_SIZE=$(stat -f%z ${MINECRAFT_HOME}/paper.jar 2>/dev/null || stat -c%s ${MINECRAFT_HOME}/paper.jar) && \
    echo "✅ Paper descargado - Tamaño: $FILE_SIZE bytes"

# Crear EULA automáticamente
RUN echo "eula=true" > ${MINECRAFT_HOME}/eula.txt

# Copiar archivos de configuración
COPY --chown=minecraft:minecraft eula.txt ${MINECRAFT_HOME}/
COPY --chown=minecraft:minecraft server.properties ${MINECRAFT_HOME}/
COPY --chown=minecraft:minecraft start.sh ${MINECRAFT_HOME}/
COPY --chown=minecraft:minecraft healthcheck.sh ${MINECRAFT_HOME}/

# Hacer scripts ejecutables
RUN chmod +x ${MINECRAFT_HOME}/start.sh ${MINECRAFT_HOME}/healthcheck.sh

# Descargar Geyser (plugin Bedrock) - sin fallar si no descarga
RUN echo "📥 Descargando Geyser..." && \
    mkdir -p ${MINECRAFT_HOME}/plugins && \
    curl -L --connect-timeout 20 --max-time 60 \
    -o ${MINECRAFT_HOME}/plugins/Geyser-Spigot.jar \
    "https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar" 2>/dev/null || \
    echo "⚠️  Geyser no disponible (opcional)"

# Cambiar usuario a minecraft (seguridad)
USER minecraft

# Exponer puertos
EXPOSE 25565/tcp      # Java Edition
EXPOSE 19132/udp      # Bedrock Edition
EXPOSE 19133/udp      # Bedrock IPv6

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD bash ${MINECRAFT_HOME}/healthcheck.sh || exit 1

# Volumen persistente
VOLUME ["${MINECRAFT_HOME}"]

# Iniciar servidor
ENTRYPOINT ["bash", "${MINECRAFT_HOME}/start.sh"]
