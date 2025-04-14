#!/bin/bash
# Script para chamar productivity.sh e/ou date.sh, de acordo com os parâmetros passados.
# Exemplo de uso:
#   ./meu_script.sh p         → executa somente productivity.sh
#   ./meu_script.sh 250414    → executa somente date.sh com o parâmetro 250414
#   ./meu_script.sh p 250414  → executa productivity.sh e depois date.sh 250414

# Função para verificar se um parâmetro é um número inteiro
is_integer() {
  [[ $1 =~ ^[0-9]+$ ]]
}

# Verifica se ao menos um parâmetro foi passado
if [ "$#" -eq 0 ]; then
  echo "Uso: $0 [p] [numero_inteiro]"
  exit 1
fi

# Variável para armazenar o eventual parâmetro numérico
param_num=""

# Se o primeiro parâmetro for "p", executa o script productivity.sh
if [ "$1" = "p" ]; then
  if [ -x "./productivity.sh" ]; then
    ./productivity.sh
  else
    echo "Script 'productivity.sh' não encontrado ou sem permissão de execução."
  fi

  # Se houver segundo parâmetro, é considerado o número para date.sh
  if [ -n "$2" ]; then
    param_num="$2"
  fi
else
  # Se o primeiro parâmetro não for "p", ele é considerado para o date.sh
  param_num="$1"
fi

# Se houver um parâmetro numérico informado, verifica se ele é inteiro e chama date.sh
if [ -n "$param_num" ]; then
  if is_integer "$param_num"; then
    if [ -x "./date.sh" ]; then
      ./date.sh "$param_num"
    else
      echo "Script 'date.sh' não encontrado ou sem permissão de execução."
      exit 1
    fi
  else
    echo "O parâmetro '$param_num' não é um número inteiro válido."
    exit 1
  fi
fi
