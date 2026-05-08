FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
RUN apt-get update && apt-get install -y curl bash && rm -rf /var/lib/apt/lists/*
RUN curl -L -o paper-server.jar https://launcher.mojang.com/v1/objects/e00c4ff3d13056381186c27c46edbe12fd7599e8/server.jar
COPY server.properties .
COPY start.sh .
COPY eula.txt .
RUN chmod +x start.sh
RUN mkdir -p plugins world logs
EXPOSE 25565
EXPOSE 19132/udp
EXPOSE 19133/udp
CMD ["./start.sh"]
