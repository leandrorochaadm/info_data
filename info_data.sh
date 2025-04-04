#!/bin/bash
# Verifica se o parâmetro foi passado
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 data no formato YYMMDD (ex: 250404)"
    exit 1
fi

input="$1"

# Extrai ano, mês e dia a partir do parâmetro (assumindo século 21)
ano="20${input:0:2}"
mes="${input:2:2}"
dia="${input:4:2}"

dataStr="$ano-$mes-$dia"

# Função para testar se o GNU date está disponível
is_gnu_date() {
    date --version >/dev/null 2>&1 && return 0 || return 1
}

if is_gnu_date; then
    # GNU date (Linux)
    if ! date -d "$dataStr" >/dev/null 2>&1; then
        echo "Data inválida: $dataStr"
        exit 1
    fi

    # --- Dia da semana e percentual da semana ---
    diaSemanaNum=$(date -d "$dataStr" +%u)
    nomeDiaSemana=$(date -d "$dataStr" +%A)
    percentualSemana=$(echo "scale=2; ($diaSemanaNum/7)*100" | bc)
    percentualSemanaInt=$(echo "$percentualSemana" | awk '{printf "%.0f", $1}')

    # --- Dia do mês e percentual do mês ---
    diaDoMes=$(date -d "$dataStr" +%d | sed 's/^0*//')
    # Obtém o último dia do mês a partir do primeiro dia do mês
    ultimoDiaMes=$(date -d "$(date -d "$ano-$mes-01" +%Y-%m-%d) +1 month -1 day" +%d | sed 's/^0*//')
    percentualMes=$(echo "scale=2; ($diaDoMes/$ultimoDiaMes)*100" | bc)
    percentualMesInt=$(echo "$percentualMes" | awk '{printf "%.0f", $1}')

    # --- Dia do ano e percentual do ano (arredondado para 2 casas decimais) ---
    diaDoAno=$(date -d "$dataStr" +%j | sed 's/^0*//')
    totalDiasAno=$(date -d "$ano-12-31" +%j | sed 's/^0*//')
    percentualAno=$(echo "scale=4; ($diaDoAno/$totalDiasAno)*100" | bc)
    percentualAnoFormatado=$(echo "$percentualAno" | awk '{printf "%.2f", $1}')

    # --- Número da semana ---
    numeroSemana=$(date -d "$dataStr" +%V)

else
    # BSD date (macOS)
    if ! date -j -f "%Y-%m-%d" "$dataStr" +"%Y" >/dev/null 2>&1; then
        echo "Data inválida: $dataStr"
        exit 1
    fi

    # --- Dia da semana e percentual da semana ---
    diaSemanaNum=$(date -j -f "%Y-%m-%d" "$dataStr" +%w)
    if [ "$diaSemanaNum" -eq 0 ]; then
        diaSemanaNum=7
    fi
    nomeDiaSemana=$(date -j -f "%Y-%m-%d" "$dataStr" +%A)
    percentualSemana=$(echo "scale=2; ($diaSemanaNum/7)*100" | bc)
    percentualSemanaInt=$(echo "$percentualSemana" | awk '{printf "%.0f", $1}')

    # --- Dia do mês e percentual do mês ---
    diaDoMes=$(date -j -f "%Y-%m-%d" "$dataStr" +%d | sed 's/^0*//')
    # Calcula o último dia do mês usando a ordem correta dos parâmetros do BSD date
    ultimoDiaMes=$(date -j -v+1m -v-1d -f "%Y-%m-%d" "$ano-$mes-01" "+%d" | sed 's/^0*//')
    percentualMes=$(echo "scale=2; ($diaDoMes/$ultimoDiaMes)*100" | bc)
    percentualMesInt=$(echo "$percentualMes" | awk '{printf "%.0f", $1}')

    # --- Dia do ano e percentual do ano (arredondado para 2 casas decimais) ---
    diaDoAno=$(date -j -f "%Y-%m-%d" "$dataStr" +%j | sed 's/^0*//')
    totalDiasAno=$(date -j -f "%Y-%m-%d" "$ano-12-31" +%j | sed 's/^0*//')
    percentualAno=$(echo "scale=4; ($diaDoAno/$totalDiasAno)*100" | bc)
    percentualAnoFormatado=$(echo "$percentualAno" | awk '{printf "%.2f", $1}')

    # --- Número da semana ---
    numeroSemana=$(date -j -f "%Y-%m-%d" "$dataStr" +%V)
fi

# Exibe os resultados
echo "Data: $dataStr"
echo "Dia da semana: $nomeDiaSemana - ${percentualSemanaInt}% da semana percorrida"
echo "Dia do mês: $diaDoMes de $ultimoDiaMes - ${percentualMesInt}% do mês percorrido"
echo "Dia do ano: $diaDoAno de $totalDiasAno - ${percentualAnoFormatado}% do ano percorrido"
echo "Número da semana: $numeroSemana"
