# Minecraft Server Dockerfile para ARM64 (Render.com)
# Soporta Java Edition (Paper 1.20.5) + Bedrock Edition (Geyser)

FROM eclipse-temurin:17-jre-jammy

# Metadata
LABEL maintainer="ErantBiscuit"
LABEL description="Minecraft Server with Paper 1.20.5 + Geyser for Bedrock support on ARM64"

# Variables de entorno
ENV MINECRAFT_HOME=/minecraft \
    JAVA_OPTS="-Xms512M -Xmx1024M -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:G1NewCollectionHeuristicPercent=30 -XX:G1ReservePercent=20 -XX:G1HeapRegionSize=32M" \
    SERVER_PORT=25565 \
    BEDROCK_PORT=19132 \
    DEBIAN_FRONTEND=noninteractive

# Instalar herramientas necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    netcat-openbsd \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario no-root para seguridad
RUN useradd -m -u 1000 minecraft

# Crear directorio de trabajo y estructura
WORKDIR ${MINECRAFT_HOME}
RUN mkdir -p ${MINECRAFT_HOME}/{plugins,world,logs,backups} && \
    chown -R minecraft:minecraft ${MINECRAFT_HOME}

# Descargar Paper Server 1.20.5 (Build 974 - estable y verificado)
RUN echo "📥 Descargando Paper Server 1.20.5..." && \
    wget --tries=3 --waitretry=5 --timeout=30 \
    -O ${MINECRAFT_HOME}/paper.jar \
    "https://papermc.io/api/v2/projects/paper/versions/1.20.5/builds/974/downloads/paper-1.20.5-974.jar" && \
    if [ ! -f ${MINECRAFT_HOME}/paper.jar ] || [ ! -s ${MINECRAFT_HOME}/paper.jar ]; then \
        echo "❌ ERROR: Descarga de Paper fallida o archivo vacío"; \
        exit 1; \
    fi && \
    echo "✅ Paper Server descargado correctamente"

# Aceptar EULA
RUN echo "eula=true" > ${MINECRAFT_HOME}/eula.txt

# Copiar archivos de configuración
COPY --chown=minecraft:minecraft eula.txt ${MINECRAFT_HOME}/
COPY --chown=minecraft:minecraft server.properties ${MINECRAFT_HOME}/
COPY --chown=minecraft:minecraft start.sh ${MINECRAFT_HOME}/
COPY --chown=minecraft:minecraft healthcheck.sh ${MINECRAFT_HOME}/

# Permisos ejecutables
RUN chmod +x ${MINECRAFT_HOME}/start.sh ${MINECRAFT_HOME}/healthcheck.sh

# Descargar Geyser (puente Java-Bedrock)
RUN echo "📥 Descargando Geyser plugin..." && \
    wget --tries=2 --waitretry=5 --timeout=30 \
    -O ${MINECRAFT_HOME}/plugins/Geyser-Spigot.jar \
    "https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar" && \
    if [ ! -f ${MINECRAFT_HOME}/plugins/Geyser-Spigot.jar ] || [ ! -s ${MINECRAFT_HOME}/plugins/Geyser-Spigot.jar ]; then \
        echo "⚠️  WARNING: Geyser download failed, continuando sin Bedrock support..."; \
    else \
        echo "✅ Geyser descargado correctamente"; \
    fi

# Cambiar usuario a minecraft (no-root)
USER minecraft

# Exponer puertos
# Puerto 25565 (TCP): Java Edition
EXPOSE 25565/tcp

# Puertos para Bedrock Edition (UDP)
# 19132: Conexiones de clientes
# 19133: IPv6 (si se requiere)
EXPOSE 19132/udp
EXPOSE 19133/udp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD bash ${MINECRAFT_HOME}/healthcheck.sh || exit 1

# Volumen para persistencia de datos
VOLUME ["${MINECRAFT_HOME}"]

# Comando de inicio
ENTRYPOINT ["bash", "${MINECRAFT_HOME}/start.sh"]
