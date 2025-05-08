#!/bin/bash

#Alarme pomodoro 40/20

# Pega o caminho completo do script
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

# Se não estiver em background, reinicia em background
if [[ "$RUNNING_IN_BG" != "1" ]]; then
    echo "Iniciando em segundo plano..."
    RUNNING_IN_BG=1 "$SCRIPT_PATH" "$1" &
    exit 0
fi

# Lógica principal
if [ "$1" == "p" ]; then
    echo "Modo pausa: esperando 20 minutos..."
    sleep $((20*60))
    afplay /System/Library/Sounds/Ping.aiff
elif [ "$1" == "g" ]; then
    echo "Modo trabalho: esperando 40 minutos..."
    sleep $((40*60))
    afplay /System/Library/Sounds/Glass.aiff
else
    echo "Uso: $0 [p|g]"
    echo "  p = espera 20 minutos e toca som Ping"
    echo "  g = espera 40 minutos e toca som Glass"
    exit 1
fi
