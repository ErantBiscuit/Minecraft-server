FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
RUN curl -L -o paper-server.jar \
    https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar && \
    java -jar BuildTools.jar --rev 1.20.5
COPY server.properties .
COPY start.sh .
COPY eula.txt .
RUN chmod +x start.sh
RUN mkdir -p plugins world logs
EXPOSE 25565
EXPOSE 19132/udp
EXPOSE 19133/udp
CMD ["./start.sh"]
