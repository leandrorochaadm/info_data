#!/bin/bash
# Script para calcular a produtividade diária
# O arredondamento é aplicado somente na média final

#######################################
# Pergunta se quer abrir a planilha
#######################################
read -p "Deseja abrir a planilha de hábitos agora? (s/n) " abrir
if [[ "$abrir" =~ ^[sS]$ ]]; then
  open -a "/Volumes/Dock/Applications/Brave Browser Nightly.app" \
       "https://docs.google.com/spreadsheets/d/1aCwUVosRLNoH_TAg4aITkdi5I0dmnXvOPoz5EGl7N5s" &
fi

# Garante separador decimal como ponto
export LC_NUMERIC=C

#######################################
# Função utilitária
# Converte “HH:mm” (ou só “H”) em horas decimais.
# Ex.: "1:30" → 1.5   |   "4" → 4
#######################################
to_decimal_hours() {
  local input="$1"
  if [[ -z "$input" ]]; then
    echo 0
  elif [[ "$input" == *:* ]]; then
    IFS=: read -r h m <<< "$input"
    echo "$(awk "BEGIN {print $h + $m/60}")"
  else
    echo "$input"
  fi
}

#######################################
# Perguntas ao usuário (Enter = 0)
#######################################

# 1) Horas trabalhadas
read -p "Quanto horas eu trabalhei hoje? (ideal ≥8) (formato HH:mm) " trabalho
trabalho=${trabalho:-0}
horas_trabalhadas=$(to_decimal_hours "$trabalho")
porc_horas=$(awk "BEGIN {print ($horas_trabalhadas/8)*100}")

# 2) Porcentagem dos hábitos
read -p "Quantos porcento dos hábitos você realizou hoje? (ideal 100) " habitos_realizados
habitos_realizados=${habitos_realizados:-0}

# 3) Tarefas
read -p "Quantas tarefas foram registradas hoje? " tarefas_registradas
tarefas_registradas=${tarefas_registradas:-0}
read -p "Quantas tarefas foram concluídas? " tarefas_concluidas
tarefas_concluidas=${tarefas_concluidas:-0}
if (( tarefas_registradas > 0 )); then
  porc_tarefas=$(awk "BEGIN {print ($tarefas_concluidas/$tarefas_registradas)*100}")
else
  porc_tarefas=0
fi

# 4) Horas de estudo
read -p "Quantas horas você estudou hoje? (ideal ≥4) (formato HH:mm) " estudo
estudo=${estudo:-0}
horas_estudadas=$(to_decimal_hours "$estudo")
porc_estudo=$(awk "BEGIN {print ($horas_estudadas/4)*100}")

# 5) Uso de celular
read -p "Quantas horas inúteis você ficou no celular hoje? (ideal ≤4) (formato HH:mm) " celular
celular=${celular:-0}
horas_celular=$(to_decimal_hours "$celular")
porc_celular=$(awk "BEGIN {print (1 - ($horas_celular/4)) * 100}")
if (( $(awk "BEGIN {print ($porc_celular < 0)}") )); then porc_celular=0; fi

# 6) Água
read -p "Quantos ml de água foram consumidos hoje? (ideal 3000) " agua
agua=${agua:-0}
porc_agua=$(awk "BEGIN {print ($agua/3000)*100}")

#######################################
# Média final (arredondada)
#######################################
media=$(awk -v p1="$porc_horas" -v p2="$habitos_realizados" \
                 -v p3="$porc_tarefas" -v p4="$porc_estudo" \
                 -v p5="$porc_celular" -v p6="$porc_agua" \
            'BEGIN {printf "%.0f", (p1+p2+p3+p4+p5+p6)/6}')

#######################################
# Resumo e resultado
#######################################
echo -e "\nResumo do dia:"
printf "• Horas trabalhadas:          %.0f%%\n" "$porc_horas"
printf "• Hábitos realizados:         %.0f%%\n" "$habitos_realizados"
printf "• Produtividade nas tarefas:  %.0f%%\n" "$porc_tarefas"
printf "• Horas de estudo:            %.0f%%\n" "$porc_estudo"
printf "• Meta de uso do celular:     %.0f%%\n" "$porc_celular"
printf "• Água consumida:             %.0f%%\n" "$porc_agua"

echo -e "\nA produtividade média de hoje foi ${media}%"
