FROM eclipse-temurin:17-jre-jammy

# Variables de entorno
ENV MINECRAFT_HOME=/minecraft \
    JAVA_OPTS="-Xms512M -Xmx1024M -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    curl \
    bash \
    netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario no-root
RUN useradd -m -u 1000 minecraft

# Crear estructura de directorios
WORKDIR ${MINECRAFT_HOME}
RUN mkdir -p ${MINECRAFT_HOME}/{plugins,world,logs,backups} && \
    chown -R minecraft:minecraft ${MINECRAFT_HOME}

# Descargar Paper Server 1.20.5 desde CDN oficial
RUN echo "📥 Descargando Paper Server 1.20.5..." && \
  curl -L --connect-timeout 30 --max-time 300 \
-o ${MINECRAFT_HOME}/paper.jar \
"https://launcher.mojang.com/v1/objects/e00c4ff3d13056381186c27c46edbe12fd7599e8/server.jar" && \
    "https://cdn.papermc.io/downloads/paper/1.20.5/paper-1.20.5-974.jar" && \
    echo "✅ Paper descargado"

# Crear EULA
RUN echo "eula=true" > ${MINECRAFT_HOME}/eula.txt

# Copiar archivos de configuración
COPY eula.txt ${MINECRAFT_HOME}/
COPY server.properties ${MINECRAFT_HOME}/
COPY start.sh ${MINECRAFT_HOME}/
COPY healthcheck.sh ${MINECRAFT_HOME}/

# Hacer scripts ejecutables
RUN chmod +x ${MINECRAFT_HOME}/start.sh ${MINECRAFT_HOME}/healthcheck.sh

# Descargar Geyser (Bedrock support)
RUN mkdir -p ${MINECRAFT_HOME}/plugins && \
    curl -L --connect-timeout 20 --max-time 60 \
    -o ${MINECRAFT_HOME}/plugins/Geyser-Spigot.jar \
    "https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar" 2>/dev/null || \
    echo "⚠️ Geyser no disponible (opcional)"

# Cambiar a usuario minecraft
USER minecraft

# Exponer puertos
EXPOSE 25565/tcp
EXPOSE 19132/udp
EXPOSE 19133/udp

# Volumen persistente
VOLUME ["${MINECRAFT_HOME}"]

# Iniciar servidor
CMD ["bash", "/minecraft/start.sh"]
