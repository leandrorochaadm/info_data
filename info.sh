#!/bin/bash
# Script para chamar productivity.sh, date.sh ou diff_hour.sh, de acordo com os parâmetros.

# Função para verificar se um parâmetro é um número inteiro
is_integer() {
  [[ $1 =~ ^[0-9]+$ ]]
}

# Verifica se ao menos um parâmetro foi passado
if [ "$#" -eq 0 ]; then
  echo "Uso: $0 [p] [número ou h ou d]"
  exit 1
fi

# Variável para armazenar o eventual parâmetro
param="$1"

# Se o primeiro parâmetro for "p", executa o script productivity.sh
if [ "$param" = "p" ]; then
  if [ -x "./productivity.sh" ]; then
    ./productivity.sh
  else
    echo "Script 'productivity.sh' não encontrado ou sem permissão de execução."
  fi

  # Se houver segundo parâmetro, processa
  if [ -n "$2" ]; then
    param="$2"
  else
    exit 0
  fi
fi

# Se o parâmetro for "d", chama diff_hour.sh
if [ "$param" = "d" ]; then
  if [ -x "./diff_hour.sh" ]; then
    ./diff_hour.sh
  else
    echo "Script 'diff_hour.sh' não encontrado ou sem permissão de execução."
    exit 1
  fi
  exit 0
fi

# Se o parâmetro for número ou "h", chama date.sh
if is_integer "$param" || [ "$param" = "h" ]; then
  if [ -x "./date.sh" ]; then
    ./date.sh "$param"
  else
    echo "Script 'date.sh' não encontrado ou sem permissão de execução."
    exit 1
  fi
else
  echo "Parâmetro inválido: '$param'"
  echo "Uso permitido: p, número (YYMMDD), h ou d"
  exit 1
fi
