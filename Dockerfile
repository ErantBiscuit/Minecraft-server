FROM eclipse-temurin:17-jre-jammy

ENV MINECRAFT_HOME=/minecraft JAVA_OPTS="-Xms512M -Xmx1024M -XX:+UseG1GC"

RUN apt-get update && apt-get install -y curl bash && rm -rf /var/lib/apt/lists/*
RUN useradd -m -u 1000 minecraft

WORKDIR ${MINECRAFT_HOME}
RUN mkdir -p ${MINECRAFT_HOME}/{plugins,world,logs} && chown -R minecraft:minecraft ${MINECRAFT_HOME}

RUN curl -L -o ${MINECRAFT_HOME}/server.jar https://launcher.mojang.com/v1/objects/125e5df67276cfd191ff5987a41c10146014be16/server.jar

RUN echo "eula=true" > ${MINECRAFT_HOME}/eula.txt

COPY eula.txt server.properties start.sh healthcheck.sh ${MINECRAFT_HOME}/
RUN chmod +x ${MINECRAFT_HOME}/start.sh ${MINECRAFT_HOME}/healthcheck.sh

RUN mkdir -p ${MINECRAFT_HOME}/plugins && curl -L -o ${MINECRAFT_HOME}/plugins/Geyser-Spigot.jar https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar 2>/dev/null || true

USER minecraft
EXPOSE 25565/tcp 19132/udp 19133/udp
VOLUME ["${MINECRAFT_HOME}"]
CMD ["bash", "/minecraft/start.sh"]
