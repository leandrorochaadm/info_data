#!/bin/bash
# Script para calcular a produtividade diária
# O arredondamento é aplicado somente na média final

# Pergunta 1: Horas trabalhadas (ideal 8 horas)
read -p "Quanto horas eu trabalhei hoje? (formato HH:mm) " trabalho
# Converte HH:mm para horas fracionadas
horas_trabalhadas=$(echo $trabalho | awk -F: '{print $1 + $2/60}')
porc_horas=$(awk "BEGIN {print (($horas_trabalhadas/8)*100)}")

# Pergunta 2: Porcentagem dos hábitos realizados (valor já em %)
read -p "Quantos porcento dos hábitos você realizou hoje? " habitos_realizados

# Pergunta 3: Tarefas registradas e concluídas
read -p "Quantas tarefas foram registradas hoje? " tarefas_registradas
read -p "Quantas tarefas foram concluídas? " tarefas_concluidas
if [ "$tarefas_registradas" -gt 0 ]; then
    porc_tarefas=$(awk "BEGIN {print (($tarefas_concluidas/$tarefas_registradas)*100)}")
else
    porc_tarefas=0
fi

# Pergunta 4: Horas estudadas (ideal 4 horas)
read -p "Quantas horas você estudou hoje? (formato HH:mm) " estudo
# Converte HH:mm para horas fracionadas
horas_estudadas=$(echo $estudo | awk -F: '{print $1 + $2/60}')
porc_estudo=$(awk "BEGIN {print (($horas_estudadas/4)*100)}")

# Pergunta 5: Horas no celular (formato HH:mm)
read -p "Quantas horas você ficou no celular hoje? (formato HH:mm) " celular
# Converte HH:mm para horas fracionadas
horas_celular=$(echo $celular | awk -F: '{print $1 + $2/60}')

# Calcula a porcentagem de tempo gasto no celular
porc_celular=$(awk "BEGIN {print ((1 - ($horas_celular/4)) * 100)}")

# Calcula a média das porcentagens sem arredondamento prévio,
# aplicando o arredondamento apenas na média final:
media=$(awk -v p1="$porc_horas" -v p2="$habitos_realizados" -v p3="$porc_tarefas" -v p4="$porc_estudo" -v p5="$porc_celular" 'BEGIN {media=(p1+p2+p3+p4+p5)/5; print int(media+0.5)}')

# Exibe o resultado final
echo "A produtividade de hoje foi ${media}%"
