#!/bin/bash

# Força o locale neutro (em inglês) para padronizar a saída do comando date
export LC_ALL=C
export LANG=C

# Verifica se o parâmetro foi passado
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 data no formato YYMMDD (ex: 250404)"
    exit 1
fi

input="$1"

# Extrai ano, mês e dia (assumindo século 21)
ano="20${input:0:2}"
mes="${input:2:2}"
dia="${input:4:2}"
dataStr="$ano-$mes-$dia"

# Cria variável com data no formato "dia/mês/ano" (ex: 14/04/25)
dataStrFormatted="${dia}/${mes}/${ano:2:2}"

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

    # --- Obtém dia da semana e demais percentuais ---
    diaSemanaNum=$(date -d "$dataStr" +%u)
    nomeDiaSemana=$(date -d "$dataStr" +%A)
    percentualSemana=$(echo "scale=2; ($diaSemanaNum/7)*100" | bc)
    percentualSemanaInt=$(echo "$percentualSemana" | awk '{printf "%.0f", $1}')

    diaDoMes=$(date -d "$dataStr" +%d | sed 's/^0*//')
    # Último dia do mês
    ultimoDiaMes=$(date -d "$(date -d "$ano-$mes-01" +%Y-%m-%d) +1 month -1 day" +%d | sed 's/^0*//')
    percentualMes=$(echo "scale=2; ($diaDoMes/$ultimoDiaMes)*100" | bc)
    percentualMesInt=$(echo "$percentualMes" | awk '{printf "%.0f", $1}')

    diaDoAno=$(date -d "$dataStr" +%j | sed 's/^0*//')
    totalDiasAno=$(date -d "$ano-12-31" +%j | sed 's/^0*//')
    percentualAno=$(echo "scale=4; ($diaDoAno/$totalDiasAno)*100" | bc)
    percentualAnoFormatado=$(echo "$percentualAno" | awk '{printf "%.2f", $1}')

    numeroSemana=$(date -d "$dataStr" +%V)

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

    diaSemanaNum=$(date -j -f "%Y-%m-%d" "$dataStr" +%w)
    if [ "$diaSemanaNum" -eq 0 ]; then
        diaSemanaNum=7
    fi
    nomeDiaSemana=$(date -j -f "%Y-%m-%d" "$dataStr" +%A)
    percentualSemana=$(echo "scale=2; ($diaSemanaNum/7)*100" | bc)
    percentualSemanaInt=$(echo "$percentualSemana" | awk '{printf "%.0f", $1}')

    diaDoMes=$(date -j -f "%Y-%m-%d" "$dataStr" +%d | sed 's/^0*//')
    ultimoDiaMes=$(date -j -v+1m -v-1d -f "%Y-%m-%d" "$ano-$mes-01" "+%d" | sed 's/^0*//')
    percentualMes=$(echo "scale=2; ($diaDoMes/$ultimoDiaMes)*100" | bc)
    percentualMesInt=$(echo "$percentualMes" | awk '{printf "%.0f", $1}')

    diaDoAno=$(date -j -f "%Y-%m-%d" "$dataStr" +%j | sed 's/^0*//')
    totalDiasAno=$(date -j -f "%Y-%m-%d" "$ano-12-31" +%j | sed 's/^0*//')
    percentualAno=$(echo "scale=4; ($diaDoAno/$totalDiasAno)*100" | bc)
    percentualAnoFormatado=$(echo "$percentualAno" | awk '{printf "%.2f", $1}')

    numeroSemana=$(date -j -f "%Y-%m-%d" "$dataStr" +%V)

    tsData=$(date -j -f "%Y-%m-%d" "$dataStr" +%s)
    tsAlvo=$(date -j -f "%Y-%m-%d" "$dataAlvo" +%s)
    diffSegundos=$(( tsAlvo - tsData ))
    if [ $diffSegundos -lt 0 ]; then
        diasRestantes="0"
        mensagem="A data informada já passou de 18/07/25."
    else
        diasRestantes=$(( diffSegundos / 86400 ))
        mensagem="Dias que faltam para casamento: $diasRestantes dias"
    fi
fi

# Mapeamento do nome do dia da semana para português com if/else
if [ "$nomeDiaSemana" = "Monday" ]; then
    nomeDiaSemana="Segunda-feira"
elif [ "$nomeDiaSemana" = "Tuesday" ]; then
    nomeDiaSemana="Terça-feira"
elif [ "$nomeDiaSemana" = "Wednesday" ]; then
    nomeDiaSemana="Quarta-feira"
elif [ "$nomeDiaSemana" = "Thursday" ]; then
    nomeDiaSemana="Quinta-feira"
elif [ "$nomeDiaSemana" = "Friday" ]; then
    nomeDiaSemana="Sexta-feira"
elif [ "$nomeDiaSemana" = "Saturday" ]; then
    nomeDiaSemana="Sábado"
elif [ "$nomeDiaSemana" = "Sunday" ]; then
    nomeDiaSemana="Domingo"
fi

# Exibe os resultados com a data formatada em "dia/mês/ano"
echo "Dia da semana: $nomeDiaSemana"
echo "Data: $dataStrFormatted"
echo "Dia do ano: $diaDoAno"
echo "Número da semana: $numeroSemana"
echo "Mês percorrido: ${percentualMesInt}%"
echo "Ano percorrido: ${percentualAnoFormatado}%"
echo ""
echo "-------------------------------"
echo ""
echo "Quantos dias falta para o final do mês?: $((ultimoDiaMes-diaDoMes))"
echo "Quanto falta para o final do ano?"
echo "Dias: $((365 - diaDoAno))"
echo "Semanas: $((52 - numeroSemana))"
echo ""
echo "-------------------------------"
echo ""
echo "$mensagem"
