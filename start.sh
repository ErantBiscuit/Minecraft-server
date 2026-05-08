#!/bin/bash

# Script de inicio para Minecraft Server
# Optimizado para Render.com con Paper 1.20.5 + Geyser

set -e

# Variables
MINECRAFT_HOME="${MINECRAFT_HOME:=/minecraft}"
JAVA_OPTS="${JAVA_OPTS:--Xms512M -Xmx1024M -XX:+UseG1GC -XX:MaxGCPauseMillis=200}"
JAR_FILE="${MINECRAFT_HOME}/paper.jar"
LOG_FILE="${MINECRAFT_HOME}/logs/latest.log"

# Crear carpeta de logs si no existe
mkdir -p "${MINECRAFT_HOME}/logs"

# Mostrar información del servidor
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

# Verificar que el JAR existe
if [ ! -f "${JAR_FILE}" ]; then
    echo "❌ ERROR: ${JAR_FILE} no encontrado"
    exit 1
fi

# Verificar permisos
if [ ! -r "${JAR_FILE}" ]; then
    echo "❌ ERROR: No se tienen permisos de lectura para ${JAR_FILE}"
    exit 1
fi

# Verificar EULA
if [ ! -f "${MINECRAFT_HOME}/eula.txt" ]; then
    echo "❌ ERROR: eula.txt no encontrado"
    echo "📝 Creando eula.txt..."
    echo "eula=true" > "${MINECRAFT_HOME}/eula.txt"
fi

# Verificar server.properties
if [ ! -f "${MINECRAFT_HOME}/server.properties" ]; then
    echo "⚠️  server.properties no encontrado, se creará uno por defecto"
fi

# Mensaje de inicio
echo "✅ Validaciones completadas"
echo "🚀 Iniciando servidor..."
echo ""

# Iniciar el servidor
exec java ${JAVA_OPTS} -jar "${JAR_FILE}" nogui
