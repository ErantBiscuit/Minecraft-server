#!/bin/bash

MINECRAFT_HOME="${MINECRAFT_HOME:=/minecraft}"
SERVER_PORT="${SERVER_PORT:=25565}"

check_port() {
    if nc -z localhost "${SERVER_PORT}" 2>/dev/null; then
        return 0
    fi
    return 1
}

check_logs() {
    local log_file="${MINECRAFT_HOME}/logs/latest.log"
    if [ -f "${log_file}" ]; then
        if ! tail -100 "${log_file}" | grep -i "fatal\|crash" >/dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

if check_port; then
    echo "✅ Puerto ${SERVER_PORT} está abierto"
    exit 0
fi

if check_logs; then
    echo "✅ Logs verificados"
    exit 0
fi

echo "⚠️ Servidor no está respondiendo"
exit 1
