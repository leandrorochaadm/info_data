#!/usr/bin/env bash

# Verifica se foi passado argumento
if [ "$#" -ne 1 ]; then
  echo "Uso: bash gera_imagem.sh YYMMDD"
  exit 1
fi

DATA="$1"
ARQUIVO_TEXTO="./results/resultado.txt"
ARQUIVO_IMAGEM="./results/resultado.jpg"

# Executa o script date.sh e salva saída em texto
bash date.sh "$DATA" > "$ARQUIVO_TEXTO"

# Gera imagem com fundo preto e texto branco
convert -background black -fill white -font PT-Mono-Bold -pointsize 18 label:@"$ARQUIVO_TEXTO" "$ARQUIVO_IMAGEM"

# Mostra mensagem final
echo "Imagem gerada: $ARQUIVO_IMAGEM"
