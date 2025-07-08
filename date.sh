#!/usr/bin/env bash
# Script para análise de datas e prazos
# Autor: Otimizado - Versão 2.0

# Força uso de Bash
if [ -z "${BASH_VERSION-}" ]; then
  echo "Use Bash para rodar este script:"
  echo "  bash $0 $*"
  exit 1
fi

export LC_ALL=C
export LANG=C

# === CONSTANTES E CONFIGURAÇÕES ===
readonly CONTRATO3_DATA="2025-10-14"
readonly CONTRATO2_DATA="2025-04-15"
readonly GRAVIDEZ_DATA="2025-12-25"
readonly GRAVIDEZ_INICIO="2025-03-18"

# === FUNÇÕES UTILITÁRIAS ===

# Mostra ajuda e sai
mostrar_ajuda() {
  echo "Uso: $0 data no formato YYMMDD (ex: 250417) ou 'h' para hoje"
  exit 1
}

# Calcula timestamp a partir de uma data ISO
get_timestamp() {
  local data="$1"
  date -j -f "%Y-%m-%d" "$data" +%s 2>/dev/null || {
    echo "Data inválida: $data" >&2
    exit 1
  }
}

# Traduz dia da semana para português
traduzir_dia() {
  case "$1" in
    Monday)    echo "segunda-feira" ;;
    Tuesday)   echo "terça-feira" ;;
    Wednesday) echo "quarta-feira" ;;
    Thursday)  echo "quinta-feira" ;;
    Friday)    echo "sexta-feira" ;;
    Saturday)  echo "sábado" ;;
    Sunday)    echo "domingo" ;;
    *)         echo "$1" ;;
  esac
}

# Calcula último dia do mês
ultimo_dia_mes() {
  local ano=$1
  local mes=$2
  
  case "$mes" in
    01|03|05|07|08|10|12) echo 31 ;;
    04|06|09|11)         echo 30 ;;
    02)
      if (( (ano%400==0) || (ano%4==0 && ano%100!=0) )); then
        echo 29
      else
        echo 28
      fi
      ;;
    *) echo "Mês inválido: $mes" >&2; exit 1 ;;
  esac
}

# Converte dias em formato "X sem e Y dias"
formatar_periodo() {
  local dias=$1
  local semanas=$((dias / 7))
  local resto=$((dias % 7))
  echo "${semanas} sem e ${resto} dias"
}

# Calcula percentual com precisão
calcular_percentual() {
  local numerador=$1
  local denominador=$2
  local precisao=${3:-1}
  
  if [ "$denominador" -eq 0 ]; then
    echo "0.0"
    return
  fi
  
  awk "BEGIN { printf \"%.${precisao}f\", ($numerador * 100) / $denominador }"
}

# === FUNÇÕES DE CÁLCULO ===

# Extrai informações da data
extrair_info_data() {
  local data_iso="$1"
  
  # Extrai todas as informações em uma única chamada
  local info
  info=$(date -j -f "%Y-%m-%d" "$data_iso" "+%A %u %j %V" 2>/dev/null) || {
    echo "Data inválida: $data_iso" >&2
    exit 1
  }
  
  read -r nome_dia dia_sem_num dia_ano semana_num <<< "$info"
  
  # Ajusta domingo (0 -> 7)
  [ "$dia_sem_num" -eq 0 ] && dia_sem_num=7
  
  # Converte para base 10
  dia_ano=$((10#$dia_ano))
  semana_num=$((10#$semana_num))
  
  # Traduz dia da semana
  local nome_dia_pt
  nome_dia_pt=$(traduzir_dia "$nome_dia")
  
  # Exporta as variáveis
  export DIA_NOME_PT="$nome_dia_pt"
  export DIA_ANO="$dia_ano"
  export SEMANA_NUM="$semana_num"
}

# Calcula progresso de período
calcular_progresso() {
  local data_atual="$1"
  local data_alvo="$2"
  local data_inicio="$3"
  local tipo="$4"  # "passado" ou "restante"
  
  local ts_inicio ts_alvo ts_atual
  ts_inicio=$(get_timestamp "$data_inicio")
  ts_alvo=$(get_timestamp "$data_alvo")
  ts_atual=$(get_timestamp "$data_atual")
  
  local dias_totais dias_calculados
  dias_totais=$(( (ts_alvo - ts_inicio) / 86400 ))
  
  if [ "$tipo" = "passado" ]; then
    dias_calculados=$(( (ts_atual - ts_inicio) / 86400 ))
    [ "$dias_calculados" -lt 0 ] && dias_calculados=0
  else
    dias_calculados=$(( (ts_alvo - ts_atual) / 86400 ))
    [ "$dias_calculados" -lt 0 ] && dias_calculados=0
  fi
  
  local percentual
  percentual=$(calcular_percentual "$dias_calculados" "$dias_totais")
  
  echo "$dias_calculados $percentual"
}

# === FUNÇÕES DE EXIBIÇÃO ===

# Imprime linha de separação da tabela
imprimir_linha_separacao() {
  local g1=$1 g2=$2 g3=$3 g4=$4
  printf "|%s|%s|%s|%s|\n" \
    "$(printf '%-*s' $((g1 + 2)) '' | tr ' ' '-')" \
    "$(printf '%-*s' $((g2 + 2)) '' | tr ' ' '-')" \
    "$(printf '%-*s' $((g3 + 2)) '' | tr ' ' '-')" \
    "$(printf '%-*s' $((g4 + 2)) '' | tr ' ' '-')"
}

# Imprime linha da tabela
imprimir_linha_tabela() {
  local g1=$1 g2=$2 g3=$3 g4=$4
  local col1="$5" col2="$6" col3="$7" col4="$8"
  
  printf "| %-*s | %-*s | %-*s | %-*s |\n" \
    "$g1" "$col1" \
    "$g2" "$col2" \
    "$g3" "$col3" \
    "$g4" "$col4"
}

# Mostra tabela de prazos especiais
mostrar_tabela_prazos() {
  local data_iso="$1"
  
  # Larguras das colunas
  local g1=29 g2=4 g3=17 g4=10
  
  echo
  echo "-------------------------------------------------------------------------"
  echo "             Informações dos prazos de gravidez/casamento"
  echo "-------------------------------------------------------------------------"
  
  # Cabeçalho
  imprimir_linha_tabela $g1 $g2 $g3 $g4 "Evento" "Dias" "Periodo" "Percentual"
  imprimir_linha_separacao $g1 $g2 $g3 $g4
  
  # Dados dos prazos
  local dados_prazo periodo_fmt
  
  # Inicio do 3º contrato
  dados_prazo=($(calcular_progresso "$data_iso" "$CONTRATO3_DATA" "$CONTRATO2_DATA" "restante"))
  periodo_fmt=$(formatar_periodo "${dados_prazo[0]}")
  imprimir_linha_tabela $g1 $g2 $g3 $g4 "3º contrato (tempo que falta)" "${dados_prazo[0]}" "$periodo_fmt" "${dados_prazo[1]}%"
  imprimir_linha_separacao $g1 $g2 $g3 $g4
  
  # Gravidez
  dados_prazo=($(calcular_progresso "$data_iso" "$GRAVIDEZ_DATA" "$GRAVIDEZ_INICIO" "passado"))
  periodo_fmt=$(formatar_periodo "${dados_prazo[0]}")
  imprimir_linha_tabela $g1 $g2 $g3 $g4 "Gravidez (tempo que passou)" "${dados_prazo[0]}" "$periodo_fmt" "${dados_prazo[1]}%"
  imprimir_linha_separacao $g1 $g2 $g3 $g4
  
  # Nascimento
  dados_prazo=($(calcular_progresso "$data_iso" "$GRAVIDEZ_DATA" "$GRAVIDEZ_INICIO" "restante"))
  periodo_fmt=$(formatar_periodo "${dados_prazo[0]}")
  imprimir_linha_tabela $g1 $g2 $g3 $g4 "Nascimento (tempo que falta)" "${dados_prazo[0]}" "$periodo_fmt" "${dados_prazo[1]}%"
}

# Mostra tabela de calendário
mostrar_tabela_calendario() {
  local data_iso="$1"
  local ano="$2"
  local mes="$3"
  local dia="$4"
  
  # Larguras das colunas
  local c1=13 c2=4 c3=6 c4=19
  
  echo
  echo "-------------------------------------------------------"
  echo "    Informações do calendário tempo percorrido"
  echo "-------------------------------------------------------"
  
  # Cabeçalho
  imprimir_linha_tabela $c1 $c2 $c3 $c4 "Periodo" "Dias" "%" "Falta para acabar"
  imprimir_linha_separacao $c1 $c2 $c3 $c4
  
  # Cálculos
  local dia_mes ult_mes pct_mes
  dia_mes=$((10#$dia))
  ult_mes=$(ultimo_dia_mes "$ano" "$mes")
  pct_mes=$(calcular_percentual "$dia_mes" "$ult_mes" 0)
  
  # Mês
  imprimir_linha_tabela $c1 $c2 $c3 $c4 "Mes ($mes)" "$dia_mes" "${pct_mes}%" "$(( ult_mes - dia_mes )) dias"
  imprimir_linha_separacao $c1 $c2 $c3 $c4
  
  # Trimestre
  local tri mes_inicio ts_inicio ts_fim total_dias_tri dias_decorridos pct_tri
  tri=$(( (10#$mes - 1) / 3 + 1 ))
  mes_inicio=$(( (tri - 1) * 3 + 1 ))
  
  local data_inicio_tri data_fim_tri
  data_inicio_tri="$ano-$(printf "%02d" $mes_inicio)-01"
  
  local mes_fim ult_dia_tri
  mes_fim=$(( tri * 3 ))
  ult_dia_tri=$(ultimo_dia_mes "$ano" "$(printf "%02d" $mes_fim)")
  data_fim_tri="$ano-$(printf "%02d" $mes_fim)-$(printf "%02d" $ult_dia_tri)"
  
  ts_inicio=$(get_timestamp "$data_inicio_tri")
  ts_fim=$(get_timestamp "$data_fim_tri")
  local ts_atual
  ts_atual=$(get_timestamp "$data_iso")
  
  total_dias_tri=$(( (ts_fim - ts_inicio) / 86400 + 1 ))
  dias_decorridos=$(( (ts_atual - ts_inicio) / 86400 + 1 ))
  pct_tri=$(calcular_percentual "$dias_decorridos" "$total_dias_tri")
  
  local dias_restantes_tri
  dias_restantes_tri=$(( (ts_fim - ts_atual) / 86400 ))
  
  imprimir_linha_tabela $c1 $c2 $c3 $c4 "Trimestre ($tri)" "$dias_decorridos" "${pct_tri}%" "$dias_restantes_tri dias ou $(( dias_restantes_tri/7 )) sem."
  imprimir_linha_separacao $c1 $c2 $c3 $c4
  
  # Ano
  local total_dias_ano pct_ano
  total_dias_ano=$(date -j -f "%Y-%m-%d" "$ano-12-31" +%j)
  total_dias_ano=$((10#$total_dias_ano))
  pct_ano=$(calcular_percentual "$DIA_ANO" "$total_dias_ano" 2)
  
  imprimir_linha_tabela $c1 $c2 $c3 $c4 "Ano ($ano)" "$DIA_ANO" "${pct_ano}%" "$(( total_dias_ano - DIA_ANO )) dias ou $((52 - SEMANA_NUM)) sem."
}

# === FUNÇÃO PRINCIPAL ===

main() {
  # Validação de entrada
  [ "$#" -ne 1 ] && mostrar_ajuda
  
  local input="$1"
  local ano mes dia
  
  # Processa entrada
  if [ "$input" = "h" ]; then
    ano=$(date "+%Y")
    mes=$(date "+%m")
    dia=$(date "+%d")
  else
    # Valida formato YYMMDD
    if [[ ! "$input" =~ ^[0-9]{6}$ ]]; then
      echo "Formato inválido. Use YYMMDD ou 'h'" >&2
      exit 1
    fi
    
    ano="20${input:0:2}"
    mes="${input:2:2}"
    dia="${input:4:2}"
  fi
  
  local data_iso data_br
  data_iso="$ano-$mes-$dia"
  data_br="${dia}/${mes}/${ano:2:2}"
  
  # Extrai informações da data
  extrair_info_data "$data_iso"
  
  # Exibe informações
  echo
  echo "Hoje é $DIA_NOME_PT, dia $data_br, semana do ano $SEMANA_NUM"
  
  mostrar_tabela_prazos "$data_iso"
  mostrar_tabela_calendario "$data_iso" "$ano" "$mes" "$dia"
  
  echo
}

# Executa o programa
main "$@"
