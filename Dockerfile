FROM eclipse-temurin:17-jre-jammy

ENV MINECRAFT_HOME=/minecraft \
    JAVA_OPTS="-Xms512M -Xmx1024M -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

RUN apt-get update && apt-get install -y curl bash netcat-traditional && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 minecraft

WORKDIR ${MINECRAFT_HOME}
RUN mkdir -p ${MINECRAFT_HOME}/{plugins,world,logs,backups} && chown -R minecraft:minecraft ${MINECRAFT_HOME}

RUN echo "Descargando servidor..." && \
    curl -L -o ${MINECRAFT_HOME}/paper.jar "https://launcher.mojang.com/v1/objects/e00c4ff3d13056381186c27c46edbe12fd7599e8/server.jar"

RUN echo "eula=true" > ${MINECRAFT_HOME}/eula.txt

COPY eula.txt ${MINECRAFT_HOME}/
COPY server.properties ${MINECRAFT_HOME}/
COPY start.sh ${MINECRAFT_HOME}/
COPY healthcheck.sh ${MINECRAFT_HOME}/

RUN chmod +x ${MINECRAFT_HOME}/start.sh ${MINECRAFT_HOME}/healthcheck.sh

RUN mkdir -p ${MINECRAFT_HOME}/plugins && \
    curl -L -o ${MINECRAFT_HOME}/plugins/Geyser-Spigot.jar \
    "https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar" 2>/dev/null || true

USER minecraft

EXPOSE 25565/tcp
EXPOSE 19132/udp
EXPOSE 19133/udp

VOLUME ["${MINECRAFT_HOME}"]

CMD ["bash", "/minecraft/start.sh"]
