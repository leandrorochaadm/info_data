#!/bin/bash

# Script para calcular diferença de tempo em horas e minutos

# Função para converter HH:MM em minutos totais
to_minutes() {
  local hora=${1%:*}  # pega tudo antes dos dois pontos
  local minuto=${1#*:}  # pega tudo depois dos dois pontos
  echo $((10#$hora * 60 + 10#$minuto))
}

# Verificação de argumentos
if [ "$#" -ne 2 ]; then
  echo "Uso: $0 horário_inicial horário_final (ex: ./calc_tempo.sh 12:00 12:47)"
  exit 1
fi

inicio="$1"
fim="$2"

# Converter horários para minutos
minInicio=$(to_minutes "$inicio")
minFim=$(to_minutes "$fim")

# Calcular diferença
if [ "$minFim" -lt "$minInicio" ]; then
  echo "O horário final não pode ser menor que o horário inicial no mesmo dia."
  exit 1
fi

difMin=$((minFim - minInicio))
horas=$((difMin / 60))
minutos=$((difMin % 60))

# Exibir o resultado
echo "Diferença: $horas horas e $minutos minutos."
