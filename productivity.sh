#!/bin/bash
# Script para calcular a produtividade diária
# O arredondamento é aplicado somente na média final

# Garante que o separador decimal seja ponto, evitando erro no awk
export LC_NUMERIC=C

#######################################
# Função utilitária
# Converte “HH:mm” (ou só “H”) em horas decimais.
# Ex.:  "1:30" → 1.5   |   "4" → 4
#######################################
to_decimal_hours() {
  local input="$1"
  if [[ "$input" == *:* ]]; then              # formato HH:mm
    IFS=: read -r h m <<< "$input"
    echo "$(awk "BEGIN {print $h + $m/60}")"
  else                                        # apenas horas inteiras
    echo "$input"
  fi
}

#######################################
# Perguntas ao usuário
#######################################

# Pergunta 1: Horas trabalhadas (ideal 8 horas)
read -p "Quanto horas eu trabalhei hoje? (ideal >8) (formato HH:mm) " trabalho
horas_trabalhadas=$(to_decimal_hours "$trabalho")
porc_horas=$(awk "BEGIN {print ($horas_trabalhadas/8)*100}")

# Pergunta 2: Porcentagem dos hábitos realizados
read -p "Quantos porcento dos hábitos você realizou hoje? (ideal =100) " habitos_realizados

# Pergunta 3: Tarefas registradas e concluídas
read -p "Quantas tarefas foram registradas hoje? " tarefas_registradas
read -p "Quantas tarefas foram concluídas? " tarefas_concluidas
if (( tarefas_registradas > 0 )); then
  porc_tarefas=$(awk "BEGIN {print ($tarefas_concluidas/$tarefas_registradas)*100}")
else
  porc_tarefas=0
fi

# Pergunta 4: Horas estudadas (ideal 4 horas)
read -p "Quantas horas você estudou hoje? (ideal >4) (formato HH:mm) " estudo
horas_estudadas=$(to_decimal_hours "$estudo")
porc_estudo=$(awk "BEGIN {print ($horas_estudadas/4)*100}")

# Pergunta 5: Horas no celular (limite saudável: 4 h)
read -p "Quantas horas inúteis você ficou no celular hoje? (ideal <4) (formato HH:mm) " celular
horas_celular=$(to_decimal_hours "$celular")
porc_celular=$(awk "BEGIN {print (1 - ($horas_celular/4)) * 100}")
# Impede valor negativo caso tempo de celular > 4 h
if (( $(awk "BEGIN {print ($porc_celular < 0)}") )); then porc_celular=0; fi

#######################################
# Cálculo da média final (arredondada)
#######################################
media=$(awk -v p1="$porc_horas" -v p2="$habitos_realizados" \
                 -v p3="$porc_tarefas" -v p4="$porc_estudo" \
                 -v p5="$porc_celular" \
            'BEGIN {printf "%.0f", (p1+p2+p3+p4+p5)/5}')

#######################################
# Exibe resumo e resultado final
#######################################
echo -e "\nResumo do dia"
echo "• Horas trabalhadas:          $(printf '%.0f' "$porc_horas")%"
echo "• Hábitos realizados:         $(printf '%.0f' "$habitos_realizados")%"
echo "• Produtividade nas tarefas:  $(printf '%.0f' "$porc_tarefas")%"
echo "• Horas de estudo:            $(printf '%.0f' "$porc_estudo")%"
echo "• Uso inútil do celular: $(printf '%.0f' "$porc_celular")%"

echo -e "\nA produtividade de hoje foi ${media}%"
