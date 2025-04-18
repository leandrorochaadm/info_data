#!/usr/bin/env bash
# Força uso de Bash
if [ -z "${BASH_VERSION-}" ]; then
  echo "Use Bash para rodar este script:"
  echo "  bash $0 $*"
  exit 1
fi

export LC_ALL=C
export LANG=C

# --- Validação de entrada ---
if [ "$#" -ne 1 ]; then
  echo "Uso: $0 data no formato YYMMDD (ex: 250417)"
  exit 1
fi

input="$1"
ano="20${input:0:2}"
mes="${input:2:2}"
dia="${input:4:2}"
dataISO="$ano-$mes-$dia"            # YYYY-MM-DD
dataBR="${dia}/${mes}/${ano:2:2}"   # DD/MM/YY
alvo="2025-07-18"

# --- Função para timestamp (BSD date no macOS) ---
get_ts(){
  date -j -f "%Y-%m-%d" "$1" +%s 2>/dev/null \
    || { echo "Data inválida: $1"; exit 1; }
}

# --- Extrai infos da data ---
nomeDia=$(date -j -f "%Y-%m-%d" "$dataISO" +%A 2>/dev/null) || exit 1
diaSemNum=$(date -j -f "%Y-%m-%d" "$dataISO" +%u)
[ "$diaSemNum" -eq 0 ] && diaSemNum=7
diaAno=$(date -j -f "%Y-%m-%d" "$dataISO" +%j)
semanaNum=$(date -j -f "%Y-%m-%d" "$dataISO" +%V)

# Converte dia do mês em inteiro (remove zero à esquerda)
diaMes=$((10#$dia))

# --- Tradução do dia da semana ---
case "$nomeDia" in
  Monday)    nomeDia="Segunda-feira" ;;
  Tuesday)   nomeDia="Terça-feira"   ;;
  Wednesday) nomeDia="Quarta-feira"  ;;
  Thursday)  nomeDia="Quinta-feira"  ;;
  Friday)    nomeDia="Sexta-feira"   ;;
  Saturday)  nomeDia="Sábado"        ;;
  Sunday)    nomeDia="Domingo"       ;;
esac

# --- Último dia do mês ---
case "$mes" in
  01|03|05|07|08|10|12) ultMes=31 ;;
  04|06|09|11)         ultMes=30 ;;
  02)
    if (( (ano%400==0) || (ano%4==0 && ano%100!=0) )); then
      ultMes=29
    else
      ultMes=28
    fi
    ;;
  *) echo "Mês inválido: $mes"; exit 1 ;;
esac

# --- Percentuais ---
pctMesInt=$(( diaMes * 100 / ultMes ))
totAno=$(date -j -f "%Y-%m-%d" "$ano-12-31" +%j)
pctAnoFmt=$(awk "BEGIN{ printf \"%.2f\", $diaAno/$totAno*100 }")

# --- Dias até 18/07/2025 ---
tsData=$(get_ts "$dataISO")
tsAlvo=$(get_ts "$alvo")
deltaDias=$(( (tsAlvo - tsData) / 86400 ))
if [ "$deltaDias" -lt 0 ]; then
  msgAlvo="Já passou de 18/07/25."
else
  msgAlvo="Dias até o casamento: $deltaDias"
fi

# --- Cálculo de trimestre ---
tri=$(( (10#$mes - 1) / 3 + 1 ))
mesFim=$(( tri * 3 ))

# Último dia do mês final do trimestre
case $mesFim in
  1|3|5|7|8|10|12) ldTri=31 ;;
  4|6|9|11)       ldTri=30 ;;
  2)
    if (( (ano%400==0) || (ano%4==0 && ano%100!=0) )); then ldTri=29; else ldTri=28; fi
    ;;
esac

dataFimTri="$ano-$(printf "%02d" $mesFim)-$(printf "%02d" $ldTri)"
tsFimTri=$(get_ts "$dataFimTri")
diasTri=$(( (tsFimTri - tsData) / 86400 ))

# --- Percentual do trimestre percorrido (1 casa decimal truncada) ---
mesInicio=$(( (tri - 1) * 3 + 1 ))
dataStartTri="$ano-$(printf "%02d" $mesInicio)-01"
tsStartTri=$(get_ts "$dataStartTri")
totalDiasTri=$(( (tsFimTri - tsStartTri) / 86400 + 1 ))
diasDecorridos=$(( (tsData - tsStartTri) / 86400 + 1 ))
pctTri=$(awk \
  "BEGIN {
     v = $diasDecorridos * 100 / $totalDiasTri;
     t = int(v * 10) / 10;
     printf(\"%.1f\", t)
  }")

# --- Saída ---
echo "Dia da semana: $nomeDia"
echo "Data: $dataBR"
echo "Dia do ano: $diaAno"
echo "Semana: $semanaNum"
echo "Trimestre: $tri"
echo ""
echo "Porcentagem percorrido:"
echo "  Mês: ${pctMesInt}%"
echo "  Trimestre: ${pctTri}%"
echo "  Ano: ${pctAnoFmt}%"
echo ""
echo "Falta para o fim de:"
echo "  Mês: $(( ultMes - diaMes )) dias"
echo "  Trimestre: $diasTri dias ou $((diasTri/7)) semanas"
echo "  Ano: $(( 365 - diaAno )) dias ou $(( 52 - semanaNum )) semanas"
echo ""
echo "$msgAlvo"
