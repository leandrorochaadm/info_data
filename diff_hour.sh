#!/bin/bash

# Arquivo onde será salvo o total de minutos
ARQUIVO="tempo_total.txt"

# Função para converter HH:MM para minutos totais
to_minutes() {
  local hora=${1%:*}
  local minuto=${1#*:}
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

echo "Diferença calculada: $horas horas e $minutos minutos."

# Lê o valor anterior do arquivo (se existir), senão considera 0
if [ -f "$ARQUIVO" ]; then
  totalAnterior=$(<"$ARQUIVO")
else
  totalAnterior=0
fi

# Soma o tempo atual com o anterior
totalAtualizado=$((totalAnterior + difMin))

# Salva o novo total no arquivo
echo "$totalAtualizado" > "$ARQUIVO"

# Mostra o acumulado
horasTotal=$((totalAtualizado / 60))
minutosTotal=$((totalAtualizado % 60))

echo "Tempo acumulado: $horasTotal horas e $minutosTotal minutos."
