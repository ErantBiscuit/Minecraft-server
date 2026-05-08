#!/bin/bash

set -e

MINECRAFT_HOME="${MINECRAFT_HOME:=/minecraft}"
JAVA_OPTS="${JAVA_OPTS:--Xms512M -Xmx1024M -XX:+UseG1GC -XX:MaxGCPauseMillis=200}"
JAR_FILE="${MINECRAFT_HOME}/paper.jar"
LOG_FILE="${MINECRAFT_HOME}/logs/latest.log"

mkdir -p "${MINECRAFT_HOME}/logs"

echo "========================================"
echo "🎮 Iniciando Minecraft Server"
echo "========================================"
echo "📍 Directorio: ${MINECRAFT_HOME}"
echo "☕ Java Options: ${JAVA_OPTS}"
echo "📦 JAR File: ${JAR_FILE}"
echo "🔌 Puerto Java (TCP): 25565"
echo "🎮 Puerto Bedrock (UDP): 19132"
echo "========================================"
echo ""

if [ ! -f "${JAR_FILE}" ]; then
    echo "❌ ERROR: ${JAR_FILE} no encontrado"
    exit 1
fi

if [ ! -r "${JAR_FILE}" ]; then
    echo "❌ ERROR: No se tienen permisos para ${JAR_FILE}"
    exit 1
fi

if [ ! -f "${MINECRAFT_HOME}/eula.txt" ]; then
    echo "📝 Creando eula.txt..."
    echo "eula=true" > "${MINECRAFT_HOME}/eula.txt"
fi

echo "✅ Validaciones completadas"
echo "🚀 Iniciando servidor..."
echo ""

exec java ${JAVA_OPTS} -jar "${JAR_FILE}" nogui
