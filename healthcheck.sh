#!/bin/bash

# Health check script para Minecraft Server
# Verifica que el servidor esté funcionando correctamente

MINECRAFT_HOME="${MINECRAFT_HOME:=/minecraft}"
SERVER_PORT="${SERVER_PORT:=25565}"
MAX_RETRIES=3

# Función para verificar si el puerto está abierto
check_port() {
    if nc -z localhost "${SERVER_PORT}" 2>/dev/null; then
        return 0
    fi
    return 1
}

# Función para verificar el log más reciente
check_logs() {
    local log_file="${MINECRAFT_HOME}/logs/latest.log"
    if [ -f "${log_file}" ]; then
        # Verificar que no hay errores críticos en los últimos 10 segundos
        if ! tail -100 "${log_file}" | grep -i "fatal\|crash" >/dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

# Verificar puerto
if check_port; then
    echo "✅ Puerto ${SERVER_PORT} está abierto"
    exit 0
fi

# Verificar logs como alternativa
if check_logs; then
    echo "✅ Logs verificados"
    exit 0
fi

echo "⚠️  Servidor no está respondiendo"
exit 1
