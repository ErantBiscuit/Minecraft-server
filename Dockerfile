FROM eclipse-temurin:21-jre

ENV MINECRAFT_HOME=/minecraft
ENV JAVA_OPTS="-Xms1G -Xmx1G -XX:+UseG1GC"

RUN apt-get update && \
    apt-get install -y curl jq bash && \
    rm -rf /var/lib/apt/lists/*

WORKDIR ${MINECRAFT_HOME}

RUN mkdir -p plugins world logs

# Descargar última build estable de Paper automáticamente
RUN PAPER_VERSION=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions[-1]') && \
    BUILD=$(curl -s https://api.papermc.io/v2/projects/paper/versions/${PAPER_VERSION} | jq '.builds[-1]') && \
    JAR_NAME="paper-${PAPER_VERSION}-${BUILD}.jar" && \
    curl -fsSL -o server.jar \
    "https://api.papermc.io/v2/projects/paper/versions/${PAPER_VERSION}/builds/${BUILD}/downloads/${JAR_NAME}"

RUN echo "eula=true" > eula.txt

COPY server.properties start.sh ./

RUN chmod +x start.sh

USER minecraft

EXPOSE 25565/tcp
EXPOSE 19132/udp
EXPOSE 19133/udp

CMD ["bash", "/minecraft/start.sh"]
