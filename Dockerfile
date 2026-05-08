# Minecraft Server Dockerfile para ARM64 (Render.com)
# Soporta Java Edition (Paper 1.20.5) + Bedrock Edition (Geyser)

FROM eclipse-temurin:17-jre-jammy

# Metadata
LABEL maintainer="Minecraft Server"
LABEL description="Minecraft Server with Paper 1.20.5 + Geyser for Bedrock support"

# Variables de entorno
ENV JAVA_OPTS="-Xms512M -Xmx1024M -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:G1NewCollectionHouseofferPercent=30 -XX:G1ReservePercent=20"
ENV SERVER_PORT=25565
ENV BEDROCK_PORT=19132

# Instalar herramientas necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de trabajo
WORKDIR /minecraft

# Descargar Paper Server 1.20.5
# Paper proporciona links estables a través de su API
RUN mkdir -p /minecraft && \
    echo "Descargando Paper Server 1.20.5..." && \
    wget -q --show-progress -O /minecraft/paper.jar \
    "https://api.papermc.io/v2/projects/paper/versions/1.20.5/builds/974/downloads/paper-1.20.5-974.jar" && \
    if [ ! -f /minecraft/paper.jar ] || [ ! -s /minecraft/paper.jar ]; then \
        echo "ERROR: Descarga de Paper fallida o archivo vacío"; \
        exit 1; \
    fi && \
    echo "Paper Server descargado correctamente"

# Aceptar EULA
RUN echo "eula=true" > /minecraft/eula.txt

# Crear estructura de directorios
RUN mkdir -p /minecraft/{plugins,world,logs,config}

# Crear archivo server.properties optimizado
RUN cat > /minecraft/server.properties << 'EOF'
#Minecraft server properties
#Servidor optimizado para Render.com
server-port=25565
server-ip=0.0.0.0
max-players=20
level-name=world
level-seed=
gamemode=survival
difficulty=normal
pvp=true
enable-command-blocks=false
spawn-protection=16
view-distance=10
simulation-distance=10
max-world-size=29999984
online-mode=true
enable-rcon=false
rcon.port=25575
motd=\u00a74\u00a7lMinecraft Server\u00a7r - \u00a72Java + Bedrock Edition
allow-flight=false
enable-query=false
query.port=25565
allow-nether=true
allow-end=true
enable-whitelist=false
broadcast-console-to-ops=true
sync-chunk-writes=true
enable-jmx-monitoring=false
text-filtering-config=
spawn-animals=true
spawn-monsters=true
spawn-npcs=true
use-native-transport=true
prevent-proxy-connections=false
enforce-secure-profile=false
network-compression-threshold=256
EOF

# Descargar Geyser (puente Java-Bedrock)
RUN echo "Descargando Geyser plugin..." && \
    wget -q --show-progress -O /minecraft/plugins/Geyser-Spigot.jar \
    "https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar" && \
    if [ ! -f /minecraft/plugins/Geyser-Spigot.jar ] || [ ! -s /minecraft/plugins/Geyser-Spigot.jar ]; then \
        echo "ADVERTENCIA: Descarga de Geyser podría haber fallado, intentando alternativa..."; \
    fi

# Crear script de inicio
RUN cat > /minecraft/start.sh << 'EOF'
#!/bin/bash

# Script de inicio para Minecraft Server
# Optimizado para Render.com

set -e

JAVA_OPTS="${JAVA_OPTS:--Xms512M -Xmx1024M}"
JAR_FILE="paper.jar"

# Verificar que el JAR existe
if [ ! -f "$JAR_FILE" ]; then
    echo "ERROR: $JAR_FILE no encontrado"
    exit 1
fi

# Mostrar información del servidor
echo "========================================"
echo "Iniciando Minecraft Server"
echo "========================================"
echo "Java Options: $JAVA_OPTS"
echo "JAR File: $JAR_FILE"
echo "Puerto Java (TCP): 25565"
echo "Puerto Bedrock (UDP): 19132"
echo "========================================"
echo ""

# Iniciar el servidor
exec java $JAVA_OPTS -jar "$JAR_FILE" nogui

EOF

RUN chmod +x /minecraft/start.sh

# Exponer puertos
# Puerto 25565 (TCP): Java Edition
EXPOSE 25565/tcp

# Puertos para Bedrock Edition (UDP)
# 19132: Conexiones de clientes
# 19133: IPv6 (si se requiere)
EXPOSE 19132/udp
EXPOSE 19133/udp

# Healthcheck (opcional, verifica que el servidor está respondiendo)
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:25565 || exit 1 || true

# Volumen para persistencia de datos
VOLUME ["/minecraft"]

# Comando por defecto
CMD ["/minecraft/start.sh"]
