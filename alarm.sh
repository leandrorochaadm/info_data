#!/bin/bash

# Pega o caminho completo do script
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

# Se não estiver em background, reinicia em background
if [[ "$RUNNING_IN_BG" != "1" ]]; then
    echo "Iniciando em segundo plano..."
    RUNNING_IN_BG=1 "$SCRIPT_PATH" "$1" &
    exit 0
fi

# Função para exibir notificação
enviar_notificacao() {
    local titulo="$1"
    local mensagem="$2"
    osascript -e "display notification \"$mensagem\" with title \"$titulo\""
    osascript -e "display dialog \"$mensagem\" with title \"$titulo\" buttons {\"OK\"} with icon note"
}


# Lógica principal
if [ "$1" == "p" ]; then
    echo "Modo P: esperando 20 minutos..."
    sleep $((20*60))
    afplay /System/Library/Sounds/Ping.aiff
    enviar_notificacao "Alarme P" "Seu cronômetro de 20 minutos terminou!"
elif [ "$1" == "g" ]; then
    echo "Modo G: esperando 40 minutos..."
    sleep $((40*60))
    afplay /System/Library/Sounds/Glass.aiff
    enviar_notificacao "Alarme G" "Seu cronômetro de 40 minutos terminou!"
else
    echo "Uso: $0 [p|g]"
    echo "  p = espera 20 minutos e toca som + notificação"
    echo "  g = espera 40 minutos e toca som + notificação"
    exit 1
fi
