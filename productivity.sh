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

####################################################################################################################
# 1) Horas trabalhadas
read -p "Quanto horas eu trabalhei hoje? (ideal ≥8) (formato HH:mm) " trabalho
trabalho=${trabalho:-0}
horas_trabalhadas=$(to_decimal_hours "$trabalho")
porc_horas=$(awk "BEGIN {print ($horas_trabalhadas/8)*100}")

####################################################################################################################
# 2) Porcentagem dos hábitos
read -p "Quantos porcento dos hábitos você realizou hoje? (ideal 100) " habitos_realizados
habitos_realizados=${habitos_realizados:-0}

####################################################################################################################
# 3) Tarefas (ponderado por prioridade e quantidade)
echo -e "\nVamos calcular as tarefas por prioridade:"

echo -e "\nPrioridade 1:"
read -p "registradas? " tarefas_registradas_p1
read -p "concluídas? " tarefas_concluidas_p1

echo -e "\nPrioridade 2:"
read -p "registradas? " tarefas_registradas_p2
read -p "concluídas? " tarefas_concluidas_p2

echo -e "\nPrioridade 3:"
read -p "registradas? " tarefas_registradas_p3
read -p "concluídas? " tarefas_concluidas_p3

echo -e "\nPrioridade 4:"
read -p "registradas? " tarefas_registradas_p4
read -p "concluídas? " tarefas_concluidas_p4

# Garantir que todos são números
for var in tarefas_registradas_p1 tarefas_registradas_p2 tarefas_registradas_p3 tarefas_registradas_p4 \
           tarefas_concluidas_p1 tarefas_concluidas_p2 tarefas_concluidas_p3 tarefas_concluidas_p4; do
  eval "$var=\${$var:-0}"
done

# Calcula percentual por prioridade com proteção contra divisão por zero
porc_tarefas_p1=$(awk "BEGIN {print ($tarefas_registradas_p1>0)?(($tarefas_concluidas_p1*400)/$tarefas_registradas_p1) : 0}")
porc_tarefas_p2=$(awk "BEGIN {print ($tarefas_registradas_p2>0)?(($tarefas_concluidas_p2*300)/$tarefas_registradas_p2) : 0}")
porc_tarefas_p3=$(awk "BEGIN {print ($tarefas_registradas_p3>0)?(($tarefas_concluidas_p3*200)/$tarefas_registradas_p3) : 0}")
porc_tarefas_p4=$(awk "BEGIN {print ($tarefas_registradas_p4>0)?(($tarefas_concluidas_p4*100)/$tarefas_registradas_p4) : 0}")

echo "porc_tarefas_p1 $porc_tarefas_p1"
echo "porc_tarefas_p2 $porc_tarefas_p2"
echo "porc_tarefas_p3 $porc_tarefas_p3"
echo "porc_tarefas_p4 $porc_tarefas_p4"

# Soma apenas os porc_tarefas maiores que 0
soma=0
peso=0

if (( $(awk "BEGIN {print ($tarefas_registradas_p1 > 0)}") )); then
  soma=$(awk "BEGIN {print $soma + $porc_tarefas_p1}")
  peso=$((peso + 4))
fi

if (( $(awk "BEGIN {print ($tarefas_registradas_p2 > 0)}") )); then
  soma=$(awk "BEGIN {print $soma + $porc_tarefas_p2}")
  peso=$((peso + 3))
fi

if (( $(awk "BEGIN {print ($tarefas_registradas_p3 > 0)}") )); then
  soma=$(awk "BEGIN {print $soma + $porc_tarefas_p3}")
  peso=$((peso + 2))
fi

if (( $(awk "BEGIN {print ($tarefas_registradas_p4 > 0)}") )); then
  soma=$(awk "BEGIN {print $soma + $porc_tarefas_p4}")
  peso=$((peso + 1))
fi

if (( peso > 0 )); then
  porc_tarefas_produtividade=$(awk "BEGIN {print ($soma / $peso)}")
else
  porc_tarefas_produtividade=0
fi

echo "soma $soma"
echo "soma $peso"
echo "porc_tarefas_produtividade $porc_tarefas_produtividade"

####################################################################################################################
# 4) Horas de estudo
read -p "Quantas horas você estudou hoje? (ideal ≥4) (formato HH:mm) " estudo
estudo=${estudo:-0}
horas_estudadas=$(to_decimal_hours "$estudo")
porc_estudo=$(awk "BEGIN {print ($horas_estudadas/4)*100}")

####################################################################################################################
# 5) Uso de celular
read -p "Quantas horas inúteis você ficou no celular hoje? (ideal ≤4) (formato HH:mm) " celular
celular=${celular:-0}
horas_celular=$(to_decimal_hours "$celular")
porc_celular=$(awk "BEGIN {print (1 - ($horas_celular/4)) * 100}")
if (( $(awk "BEGIN {print ($porc_celular < 0)}") )); then porc_celular=0; fi

####################################################################################################################
# 6) Água
read -p "Quantos ml de água foram consumidos hoje? (ideal 3000) " agua
agua=${agua:-0}
porc_agua=$(awk "BEGIN {print ($agua/3000)*100}")

####################################################################################################################
# 7) Horas de sono
read -p "Quantas horas você dormiu hoje? (ideal 9 horas) (formato HH:mm) " sono
sono=${sono:-0}
horas_sono=$(to_decimal_hours "$sono")

# Calcula diferença absoluta
dif_sono=$(awk "BEGIN { diff = $horas_sono - 9; if (diff < 0) diff = -diff; print diff }")

# Calcula a porcentagem: (9 - dif_sono) * 100 / 9
porc_sono=$(awk "BEGIN {print (9 - $dif_sono) * 100 / 9}")

#######################################
# Média final (arredondada)
#######################################
media=$(awk -v p1="$porc_horas" -v p2="$habitos_realizados" \
                 -v p3="$porc_tarefas_produtividade" -v p4="$porc_estudo" \
                 -v p5="$porc_celular" -v p6="$porc_agua" -v p7="$porc_sono" \
            'BEGIN {printf "%.0f", (p1+p2+p3+p4+p5+p6+p7)/7}')

#######################################
# Resumo e resultado
#######################################
echo -e "\nResumo do dia:"
printf "• Horas trabalhadas:          %.0f%%\n" "$porc_horas"
printf "• Hábitos realizados:         %.0f%%\n" "$habitos_realizados"
printf "• Produtividade nas tarefas:  %.0f%%\n" "$porc_tarefas_produtividade"
printf "• Horas de estudo:            %.0f%%\n" "$porc_estudo"
printf "• Meta de uso do celular:     %.0f%%\n" "$porc_celular"
printf "• Água consumida:             %.0f%%\n" "$porc_agua"
printf "• Qualidade do sono:          %.0f%%\n" "$porc_sono"

echo -e "\nA produtividade média de hoje foi ${media}%"
