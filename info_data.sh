#!/bin/bash

# Força um locale neutro
export LC_ALL=C
export LANG=C

# Verifica se o parâmetro foi passado
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 data no formato YYMMDD (ex: 250404)"
    exit 1
fi

# Script de produtividade
# Se for passado o parâmetro "p", executa o script produtividade.sh

if [ "$1" = "p" ]; then
    if [ -x "./productivity.sh" ]; then
        ./productivity.sh
    else
        echo "Script 'productivity.sh' não encontrado ou sem permissão de execução."
        exit 1
    fi
    exit 0
fi

input="$1"

# Extrai ano, mês e dia a partir do parâmetro (assumindo século 21)
ano="20${input:0:2}"
mes="${input:2:2}"
dia="${input:4:2}"

dataStr="$ano-$mes-$dia"

# Data alvo para cálculo (18/07/2025)
dataAlvo="2025-07-18"

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

    # --- Cálculo da diferença em dias até 18/07/2025 ---
    tsData=$(date -d "$dataStr" +%s)
    tsAlvo=$(date -d "$dataAlvo" +%s)
    diffSegundos=$(( tsAlvo - tsData ))
    if [ $diffSegundos -lt 0 ]; then
        diasRestantes="0"
        mensagem="A data informada já passou de 18/07/25."
    else
        diasRestantes=$(( diffSegundos / 86400 ))
        mensagem="Dias restantes para 18/07/25: $diasRestantes"
    fi

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

    # --- Cálculo da diferença em dias até 18/07/2025 ---
    tsData=$(date -j -f "%Y-%m-%d" "$dataStr" +%s)
    tsAlvo=$(date -j -f "%Y-%m-%d" "$dataAlvo" +%s)
    diffSegundos=$(( tsAlvo - tsData ))
    if [ $diffSegundos -lt 0 ]; then
        diasRestantes="0"
        mensagem="A data informada já passou de 18/07/25."
    else
        diasRestantes=$(( diffSegundos / 86400 ))
        mensagem="Dias restantes para 18/07/25: $diasRestantes dias"
    fi
fi

# Exibe os resultados
echo "Dia da semana: $nomeDiaSemana | Data: $dataStr | ${percentualMesInt}% do mês percorrido"
echo "Número da semana: $numeroSemana | Dia do ano: $diaDoAno | ${percentualAnoFormatado}% do ano percorrido"
echo "$mensagem"
