FROM eclipse-temurin:17-jre-jammy

ENV MINECRAFT_HOME=/minecraft JAVA_OPTS="-Xms512M -Xmx1024M -XX:+UseG1GC"

RUN apt-get update && apt-get install -y curl bash git-core && rm -rf /var/lib/apt/lists/*
RUN useradd -m -u 1000 minecraft

WORKDIR /tmp
RUN git clone https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/BuildTools.jar . 2>/dev/null || \
    curl -L -o BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/BuildTools.jar

RUN java -jar BuildTools.jar --rev 1.20.5 --compile craftbukkit:spigot 2>/dev/null || true

WORKDIR ${MINECRAFT_HOME}
RUN mkdir -p ${MINECRAFT_HOME}/{plugins,world,logs} && chown -R minecraft:minecraft ${MINECRAFT_HOME}

RUN if [ -f /tmp/spigot-1.20.5.jar ]; then cp /tmp/spigot-1.20.5.jar ${MINECRAFT_HOME}/server.jar; \
    elif [ -f /tmp/Spigot-1.20.5.jar ]; then cp /tmp/Spigot-1.20.5.jar ${MINECRAFT_HOME}/server.jar; \
    else echo "ERROR: Spigot no se compiló"; exit 1; fi

RUN echo "eula=true" > ${MINECRAFT_HOME}/eula.txt

COPY eula.txt server.properties start.sh healthcheck.sh ${MINECRAFT_HOME}/
RUN chmod +x ${MINECRAFT_HOME}/start.sh ${MINECRAFT_HOME}/healthcheck.sh

RUN mkdir -p ${MINECRAFT_HOME}/plugins && curl -L -o ${MINECRAFT_HOME}/plugins/Geyser-Spigot.jar https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar 2>/dev/null || true

USER minecraft
EXPOSE 25565/tcp 19132/udp 19133/udp
VOLUME ["${MINECRAFT_HOME}"]
CMD ["bash", "/minecraft/start.sh"]
