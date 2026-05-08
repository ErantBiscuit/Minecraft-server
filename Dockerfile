FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
RUN apt-get update && apt-get install -y curl bash && rm -rf /var/lib/apt/lists/*
RUN curl -L -o paper-server.jar https://api.purpurmc.org/v2/purpur/1.20.5/latest/download
COPY server.properties .
COPY start.sh .
COPY eula.txt .
RUN chmod +x start.sh
RUN mkdir -p plugins world logs
EXPOSE 25565
EXPOSE 19132/udp
EXPOSE 19133/udp
CMD ["./start.sh"]
