#!/bin/bash
# Script para calcular a produtividade diária
# O arredondamento é aplicado somente na média final

# Pergunta 1: Horas trabalhadas (ideal 8 horas)
read -p "quanto horas eu trabalhei hoje? " horas_trabalhadas
porc_horas=$(awk "BEGIN {print (($horas_trabalhadas/8)*100)}")

# Pergunta 2: Porcentagem dos hábitos realizados (valor já em %)
read -p "quantos porcento dos habitos você realizou hoje? " habitos_realizados

# Pergunta 3: Tarefas registradas e concluídas
read -p "quantas tarefas foram registradas hoje? " tarefas_registradas
read -p "quantas tarefas foram concluidas? " tarefas_concluidas
if [ "$tarefas_registradas" -gt 0 ]; then
    porc_tarefas=$(awk "BEGIN {print (($tarefas_concluidas/$tarefas_registradas)*100)}")
else
    porc_tarefas=0
fi

# Pergunta 4: Horas estudadas (ideal 4 horas)
read -p "quantas horas você estudou hoje? " horas_estudadas
porc_estudo=$(awk "BEGIN {print (($horas_estudadas/4)*100)}")

# Calcula a média das porcentagens sem arredondamento prévio,
# aplicando o arredondamento apenas na média final:
media=$(awk -v p1="$porc_horas" -v p2="$habitos_realizados" -v p3="$porc_tarefas" -v p4="$porc_estudo" 'BEGIN {media=(p1+p2+p3+p4)/4; print int(media+0.5)}')

# Exibe o resultado final
echo "a produtividade de hoje foi ${media}%"
