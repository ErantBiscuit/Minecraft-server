#!/bin/bash
echo "=========================================="
echo "🎮 Iniciando servidor Minecraft..."
echo "=========================================="
echo "eula=true" > eula.txt
echo "✅ EULA aceptado"
if [ ! -d "plugins" ]; then
    echo "📁 Creando carpeta plugins..."
    mkdir -p plugins
fi
echo "⏳ Buscando Geyser..."
GEYSER_JAR="plugins/Geyser-Spigot.jar"
if [ ! -f "$GEYSER_JAR" ]; then
    echo "📥 Descargando Geyser-Spigot..."
    curl -o "$GEYSER_JAR" https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/Spigot
    if [ -f "$GEYSER_JAR" ]; then
        echo "✅ Geyser descargado"
    else
        echo "❌ Error descargando Geyser"
    fi
else
    echo "✅ Geyser ya existe"
fi
echo "=========================================="
echo "🚀 Iniciando servidor..."
echo ""
java -Xmx512M -Xms256M -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -jar paper-server.jar nogui
echo ""
echo "=========================================="
echo "🛑 Servidor detenido"
echo "=========================================="