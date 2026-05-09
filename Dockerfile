FROM openjdk:17-slim
WORKDIR /app
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
RUN curl -o paper-server.jar https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/517/downloads/paper-1.20.4-517.jar
COPY server.properties .
COPY start.sh .
COPY eula.txt .
RUN chmod +x start.sh
RUN mkdir -p plugins world logs
EXPOSE 25565
EXPOSE 19132/udp
EXPOSE 19133/udp
CMD ["./start.sh"]
