#!/bin/bash

# Arquivo onde será salvo o total de minutos
ARQUIVO="time_accumulated.txt"

# Função para converter HH:MM para minutos totais
to_minutes() {
  local hora=${1%:*}
  local minuto=${1#*:}
  echo $((10#$hora * 60 + 10#$minuto))
}

# Se quiser apenas ver o acumulado
if [ "$#" -eq 1 ] && [ "$1" = "t" ]; then
  if [ -f "$ARQUIVO" ]; then
    totalAnterior=$(<"$ARQUIVO")
    horasTotal=$((totalAnterior / 60))
    minutosTotal=$((totalAnterior % 60))
    echo "Tempo acumulado: $horasTotal horas e $minutosTotal minutos."
  else
    echo "Nenhum tempo acumulado encontrado."
  fi
  exit 0
fi

# --- Nova lógica: perguntar horários ao usuário ---
echo "Digite o primeiro horário (formato HH:MM):"
read inicio

echo "Digite o segundo horário (formato HH:MM):"
read fim

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

# Pergunta se quer salvar o resultado
echo "Deseja salvar esse resultado no total acumulado? (s/n)"
read resposta

if [ "$resposta" = "s" ] || [ "$resposta" = "S" ]; then
  if [ -f "$ARQUIVO" ]; then
    totalAnterior=$(<"$ARQUIVO")
  else
    totalAnterior=0
  fi

  totalAtualizado=$((totalAnterior + difMin))

  # Salva o novo total
  echo "$totalAtualizado" > "$ARQUIVO"

  # Mostra o novo acumulado
  horasTotal=$((totalAtualizado / 60))
  minutosTotal=$((totalAtualizado % 60))

  echo "Novo tempo acumulado: $horasTotal horas e $minutosTotal minutos."
else
  echo "Resultado não foi salvo no acumulado."
fi
