#!/bin/bash
set -e

# Définir l'adresse du fichier CSV contenant les URLs
CSV_FILE="$HOME/Stage_Copenhague/zr11927_Rawdatalinks_250506.csv" # Variable permettant de
#  stocker le chemin du fichier csv.

# Rappel : $HOME est une variable environnement contenant le chemin absolu du répertoire
# personnel (sur mon pc c'est : /home/alexis)

# Créer un dossier de destination pour tester le téléchargement du fichier
TEST_DIR="$HOME/Stage_Copenhague/raw_data_test"
mkdir -p "$TEST_DIR"

# Lire les deux premières lignes de données (après l'en-tête), correspondant aux deux premiers
# échantillons :
lines=$(tail -n +2 "$CSV_FILE" | head -n 2)

# Initialiser un compteur d'échantillons (samples)
sample_num=1

# Lire ligne par ligne
echo "$lines" | while IFS=',' read -r sample_id customer_label read1_url read2_url
	# Nettoyage des retours chariot
    	read1_url=$(echo "$read1_url" | tr -d '\r')
    	read2_url=$(echo "$read2_url" | tr -d '\r')

	# Vérifie qu'on a bien toutes les données nécessaires
	if [[ -z "$read1_url" || -z "$read2_url" || -z "$sample_id" ]]; then
    		echo "Incomplete or empty line - the loop is exited cleanly."
    		break
	fi

do
	echo "sample processing $sample_num : $sample_id"

	# Dossiers de sortie
	SAMPLE_DIR="$TEST_DIR/sample_$sample_num"
	mkdir -p "$SAMPLE_DIR"

	# ---- Télécharger Read1 ----
	echo "Downloading Read1..."
	wget -c -O "$SAMPLE_DIR/read1.fastq.gz" "$read1_url"

	# ---- Extraire les 1000 premiers reads (4000 lignes) ----
	echo "Extraction of Read1"
	zcat "$SAMPLE_DIR/read1.fastq.gz" | head -n 4000 > "$SAMPLE_DIR/${sample_id}_read1.fastq"
	rm "$SAMPLE_DIR/read1.fastq.gz"


	# ---- Télécharger Read2 ----
	echo "Downloading Read2..."
	wget -c -O "$SAMPLE_DIR/read2.fastq.gz" "$read2_url"

	# ---- Extraire les 1000 premiers reads (4000 lignes) ----
	echo "Extraction of Read2"
	zcat "$SAMPLE_DIR/read2.fastq.gz" | head -n 4000 > "$SAMPLE_DIR/${sample_id}_read2.fastq"
	rm "$SAMPLE_DIR/read2.fastq.gz"


	echo "Sample $sample_num treated."
	echo

	sample_num=$((sample_num + 1))
done



