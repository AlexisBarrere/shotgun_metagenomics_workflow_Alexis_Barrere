#!/bin/bash

BASE_DIR=~/Stage_Copenhague/trimming/clean_reads

find "$BASE_DIR" -type f -name "*.fq.gz" | while read FILE; do
    DIR=$(dirname "$FILE")
    NAME=$(basename "$FILE")

    # Récupère le nom du dossier sample_XX
    SAMPLE=$(basename "$(dirname "$DIR")")

    # Si le fichier n'est pas déjà préfixé par sample_XX_
    if [[ "$NAME" != ${SAMPLE}_* ]]; then
        NEW_NAME="${SAMPLE}_${NAME}"
        mv -v "$FILE" "$DIR/$NEW_NAME"
    fi
done
