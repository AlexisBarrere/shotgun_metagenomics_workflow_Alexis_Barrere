# Step 10b - Generate pangenome database with MAGs and NCBI genomes

This step consisted in extending the **`Anvi'o` pangenome** analysis by combining the **12 dereplicated Archaeal MAGs** (from Step 10a) with a curated set of **30 publicly available NCBI Archaeal genomes**.  
The aim was to compare my reconstructed MAGs with closely related reference genomes (same family) and with distant Archaean genomes (other family but same order, other order, other class), in order to explore their genomic diversity and evolutionary associations.

This workflow included : reformatting downloaded NCBI genomes, creating and annotating `Anvi'o` contigs databases for each genome, generating an `external-genomes` file (linking genome names to contigs DBs), merging MAGs (`internal-genomes`) and NCBI genomes into a single genomes storage file, and finally computing a **combined pangenome**.

> ⚠️ This step assumes that Step 10a has been completed (with the MAGs contigs DB, merged profile DB, and [internal-genomes_MAGs.txt](../10a_MAGs_pangenome_analysis/MAGs_data/internal-genomes_MAGs.txt) available).

---

## Environment & Software Versions
All commands were executed on the **Thoth** server running : Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-126-generic x86_64).

The tools used during this step are managed via a Conda environment defined in : [`envs/anvio8_env.yml`](../../envs/anvio8_env.yml)  

| Tool                 | Version | Installation method           |  
|----------------------|---------|-------------------------------|
| Anvi'o               | 8.0     | Conda (`bioconda`)            |
| ncbi-genome-download | 0.3.3   | `pip`                         |
| gimme_taxa.py        | latest  | Installed with `Anvi'o` tools |
| TrimAl               | 1.5     | Installed with `Anvi'o` tools |
| IQ-TREE              | 2.4.0   | Installed with `Anvi'o` tools |

---

## Scripts

- [`2_reformat_fasta_NCBI.sh`](2_reformat_fasta_NCBI.sh)  
⭢ Reformats downloaded NCBI FASTA files with simplified headers, ensuring compatibility with `Anvi'o` (adds `NCBI_` prefix, generates report files, cleans fasta_final.txt).  

- [`3_create_and_annotate_contigs_db_NCBI.sh`](3_create_and_annotate_contigs_db_NCBI.sh)  
⭢ Creates an `Anvi'o` contigs database for each NCBI genome, detects SCGs with `anvi-run-hmms`, assigns functions with `anvi-run-ncbi-cogs`, and estimates taxonomy with `anvi-run-scg-taxonomy`.  

- [`4_generate_external_genomes_file.sh`](4_generate_external_genomes_file.sh)  
⭢ Generates the [external-genomes_NCBI.txt](external-genomes_NCBI.txt) file listing each NCBI genome and its contigs DB path (used in pangenomics).  

- [`5a_generate_genomes_and_PAN_databases.sh`](5a_generate_genomes_and_PAN_databases.sh)  
⭢ Combines internal (MAGs) and external (NCBI) genomes into a single **genomes storage database** (`~/Stage_Copenhague/downstream_analysis/NCBI_metapangenome/PAN/MAGs_NCBI-GENOMES.db`), computes the combined pangenome with `anvi-pan-genome`, and outputs the PAN database (`~/Stage_Copenhague/downstream_analysis/NCBI_metapangenome/PAN/PAN_db/MAGs_vs_NCBI-PAN.db`).  

- [`5d_add_sources_to_layers_misc_data.sh`](5d_add_sources_to_layers_misc_data.sh)  
⭢ Allows to add the origin (which I called here "source") of each genome : **MAG** or **NCBI**.

- [`5dbis_add_sources_to_layers_misc_data.sh`](5dbis_add_sources_to_layers_misc_data.sh)
⭢ Same script as the one above, but a version containing fewer external genomes from NCBI.
---

## Inputs

### Internal genomes (from Step 10a)
- MAGs internal genomes file :  
  `~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/pangenome/internal-genomes_MAGs.txt`

### External genomes (downloaded from NCBI)
- Downloaded NCBI genomes :  
  `~/Stage_Copenhague/downstream_analysis/NCBI_pangenome/NCBI_genomes/NCBI-GENOMES/*.fa`
- Reformatted FASTA files :  
  `~/Stage_Copenhague/downstream_analysis/NCBI_pangenome/NCBI_genomes/NCBI-GENOMES-REFORMATTED/*.fa`

---

## Outputs

- Reformatted FASTA.txt file with corrected paths :  
  `~/Stage_Copenhague/downstream_analysis/NCBI_pangenome/NCBI_genomes/fasta_final_reformatted.txt`
- Annotated NCBI contigs databases (one per genome) :  
  `~/Stage_Copenhague/downstream_analysis/NCBI_pangenome/contigs_db/`
- External genomes file :  
  `~/Stage_Copenhague/downstream_analysis/NCBI_pangenome/external-genomes_NCBI.txt`
- Combined genomes storage file :  
  `~/Stage_Copenhague/downstream_analysis/NCBI_pangenome/PAN/MAGs_NCBI-GENOMES.db`
- PAN database (MAGs + NCBI genomes) :  
  `~/Stage_Copenhague/downstream_analysis/NCBI_pangenome/PAN/PAN_db/MAGs_vs_NCBI-PAN.db`

You can find all the figures generated with `Anvi'o` by clicking here : [Index for HTML reports & PDF/SVG files (figures)](https://alexisbarrere.github.io/shotgun_metagenomics_workflow_Alexis_Barrere/) > `anvio_figures`

---

## Execution

To complete this step, I followed the following 2 tutorials from the creators of `Anvi'o` :
- [Accessing and including NCBI genomes in omics analyses in `Anvi'o`](https://merenlab.org/2019/03/14/ncbi-genome-download-magic/)

- [Pangenomics, Phylogenomics, and ANI of Spiroplasma genomes](https://merenlab.org/data/spiroplasma-pangenome)

### 1. Download external Archeal genomes (from NCBI)
First I created the working folder for this step, then after activating the [anvio8_env](../../envs/anvio8_env.yml) environment I installed the `ncbi-genome-download` command :
```bash 
# Create working directory
mkdir -p ~/Stage_Copenhague/downstream_analysis/NCBI_pangenome

# Activate Anvi'o environment 
conda activate anvio8_env

# Install the command for downloading the NCBI genomes
pip install ncbi-genome-download
```

Then, I identified archaeal genomes from NCBI that are taxonomically close or distant to my MAGs :
- The same family ([Nitrososphaeraceae](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Undef&id=1033997&lvl=3&p=has_linkout&p=blast_url&p=genome_blast&srchmode=1&keep=1&unlock))
- A different family ([Candidatus Methylarchaceae](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Tree&id=2913632&lvl=3&p=has_linkout&p=blast_url&p=genome_blast&lin=f&keep=1&srchmode=1&unlock)) but within the same order ([Nitrososphaerales](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=1033996&lvl=3&p=has_linkout&p=blast_url&p=genome_blast&lin=f&keep=1&srchmode=1&unlock))
- The same class ([Nitrososphaeria](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=1643678&lvl=3&p=has_linkout&p=blast_url&p=genome_blast&lin=f&keep=1&srchmode=1&unlock)) but belonging to other orders ([Candidatus Nitrosocaldales](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Tree&id=1968909&lvl=3&p=has_linkout&p=blast_url&p=genome_blast&lin=f&keep=1&srchmode=1&unlock) and [Nitrosopumilales](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Tree&id=31932&lvl=3&p=has_linkout&p=blast_url&p=genome_blast&lin=f&keep=1&srchmode=1&unlock))
- A different class ([Conexivisphaeria](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Tree&id=2798274&lvl=3&p=has_linkout&p=blast_url&p=genome_blast&lin=f&keep=1&srchmode=1&unlock))

In order to obtain the taxonomic identifiers of the genomes belonging to these different taxa, I executed the following commands :
```bash
# Set working directory
cd ~/Stage_Copenhague/downstream_analysis/NCBI_pangenome/NCBI_genomes

# Create a folder for the taxids.txt files
mkdir -p taxids

# Create the taxids.txt files
# Nitrososphaeraceae (same family)
gimme_taxa.py 1033997 -o taxids/nitrososphaeraceae_taxids.txt --just-taxids 

# Candidatus Methylarchaeaceae (other family,same order)
gimme_taxa.py 2913632 -o taxids/candidatus_methylarchaeaceae_taxids.txt --just-taxids

# Nitrosopumilales (other order)
gimme_taxa.py 31932 -o taxids/nitrosopumilales_taxids.txt --just-taxids

# Candidatus Nitrosocaldales (other order)
gimme_taxa.py 1968909 -o taxids/candidatus_nitrosocaldales_taxids.txt --just-taxids

# Conexivisphaeria (other class)
gimme_taxa.py 2798274 -o taxids/conexivisphaeria_taxids.txt --just-taxids

# create the folder necessary for the next step
mkdir -p metadata
```

Next, I ran the `ncbi-genome-download` command in "**dry-run**" mode allowing me to display the number of genomes that will be downloaded :

- **Nitrososphaeraceae** (same family as MAGs) :
```bash
ncbi-genome-download archaea -t nitrososphaeraceae_taxids.txt -l complete,chromosome -s refseq --metadata metadata/nitrososphaeraceae_metadata.txt --dry-run
```
Output : 
```bash
Considering the following 6 assemblies for download:
GCF_000698785.1 Nitrososphaera viennensis EN76  EN76
GCF_000303155.1 Candidatus Nitrososphaera gargensis Ga9.2       na
GCF_000802205.1 Candidatus Nitrosocosmicus oleophilus   MY3
GCF_000730285.1 Candidatus Nitrososphaera evergladensis SR1     na
GCF_900696045.1 Candidatus Nitrosocosmicus franklandianus       na
GCF_001870125.1 Candidatus Nitrosocosmicus hydrocola    G61 
```

- **Candidatus Methylarchaeaceae** (other family, same order) :
```bash 
ncbi-genome-download archaea -t candidatus_methylarchaeaceae_taxids.txt -s genbank --metadata metadata/candidatus_methylarchaeaceae_metadata.txt --dry-run
```

Output :
```
Considering the following 4 assemblies for download:
GCA_024256245.1 Candidatus Methylarchaceae archaeon HK01M       na
GCA_024256205.1 Candidatus Methylarchaceae archaeon HK01B       na
GCA_024256185.1 Candidatus Methylarchaceae archaeon HK02M1      na
GCA_024256165.1 Candidatus Methylarchaceae archaeon HK02M2      na  
```

- **Nitrosopumilales** (other order) :
```bash
ncbi-genome-download archaea -t nitrosopumilales_taxids.txt -l complete,chromosome -s refseq --metadata metadata/nitrosopumilales_metadata.txt --dry-run
```

Output : 
```
GCF_000018465.1 Nitrosopumilus maritimus SCM1   SCM1
GCF_025998175.1 Nitrosopumilus zosterae NM25
GCF_000299365.1 Candidatus Nitrosopumilus koreensis AR1 AR1
GCF_000299395.1 Candidatus Nitrosopumilus sediminis     AR2
GCF_013407145.1 Nitrosopumilus cobalaminigenes  HCA1
GCF_013407185.1 Nitrosopumilus ureiphilus       PS0
GCF_000956175.1 Nitrosopumilus adriaticus       NF5
GCF_041431065.1 Nitrosopumilus adriaticus       CCS1
GCF_000875775.1 Nitrosopumilus piranensis       D3C
GCF_002156965.1 Candidatus Nitrosomarinus catalinensis  SPOT01
GCF_013407165.1 Nitrosopumilus oxyclinae        HCE1
GCF_963457545.1 Nitrosopumilus sp.      na
GCF_965262695.1 Nitrosopumilus sp.      na
GCF_965263415.1 Nitrosopumilus sp.      na
GCF_013407385.1 Nitrosarchaeum sp. AC2  AC2
GCF_006740685.1 Candidatus Nitrosopumilus sp. SW        SW
GCF_018128925.1 Nitrosopumilus sp. K4   K4 
```

- **Candidatus Nitrosocaldales** (other order) :
```bash
ncbi-genome-download archaea -t candidatus_nitrosocaldales_taxids.txt -l complete,chromosome -s refseq --metadata metadata/candidatus_nitrosocaldales.txt --dry-run
```

Output : 
```
GCF_002906215.1 Candidatus Nitrosocaldus islandicus     na
GCF_900248165.1 Candidatus Nitrosocaldus cavascurensis  SCU2 
```

- **Conexivisphaeria** (other class) :
```bash
ncbi-genome-download archaea -t conexivisphaeria_taxids.txt -l complete,chromosome -s genbank --metadata metadata/conexivisphaeria_metadata.txt --dry-run
```

Output : 
```
GCA_013340765.1 Conexivisphaera calida  NAS-02
```

I then downloaded all these genomes :
```bash
# Nitrososphaeraceae
ncbi-genome-download archaea -t nitrososphaeraceae_taxids.txt -l complete,chromosome -s refseq --metadata metadata/nitrososphaeraceae_metadata.txt 

# Candidatus Methylarchaeaceae
ncbi-genome-download archaea -t candidatus_methylarchaeaceae_taxids.txt -s genbank --metadata metadata/candidatus_methylarchaeaceae_metadata.txt 

# Nitrosopumilales
ncbi-genome-download archaea -t nitrosopumilales_taxids.txt -l complete,chromosome -s refseq --metadata metadata/nitrosopumilales_metadata.txt 

# Candidatus Nitrosocaldales
ncbi-genome-download archaea -t candidatus_nitrosocaldales_taxids.txt -l complete,chromosome -s refseq --metadata metadata/candidatus_nitrosocaldales_metadata.txt 

# Conexivisphaeria
ncbi-genome-download archaea -t conexivisphaeria_taxids.txt -l complete,chromosome -s genbank --metadata metadata/conexivisphaeria_metadata.txt 
```

After that, I ran the `anvi-script-process-genbank-metadata` command to remove unnecessary information from the `fasta.txt` files for each taxon, and put all NCBI genomes in one folder (`NCBI-GENOMES`) : 
```bash
# Create one folder for the NCBI-GENOMES
mkdir NCBI-GENOMES

anvi-script-process-genbank-metadata -m metadata/nitrososphaeraceae_metadata.txt -o NCBI-GENOMES --output-fasta-txt metadata/nitrososphaeraceae_fasta.txt --exclude-gene-calls-from-fasta-txt

anvi-script-process-genbank-metadata -m metadata/candidatus_methylarchaeaceae_metadata.txt -o NCBI-GENOMES --output-fasta-txt metadata/candidatus_methylarchaeaceae_fasta.txt --exclude-gene-calls-from-fasta-txt

anvi-script-process-genbank-metadata -m metadata/nitrosopumilales_metadata.txt -o NCBI-GENOMES --output-fasta-txt metadata/nitrosopumilales_fasta.txt --exclude-gene-calls-from-fasta-txt

anvi-script-process-genbank-metadata -m metadata/candidatus_nitrosocaldales_metadata.txt -o NCBI-GENOMES --output-fasta-txt metadata/candidatus_nitrosocaldales_fasta.txt --exclude-gene-calls-from-fasta-txt

anvi-script-process-genbank-metadata -m metadata/conexivisphaeria_metadata.txt -o NCBI-GENOMES --output-fasta-txt metadata/conexivisphaeria_fasta.txt --exclude-gene-calls-from-fasta-txt
```

To concatenate all `fasta.txt` files into a single file :
```bash
cat metadata/*fasta.txt > fasta_final.txt
```
_**N.B. :** This `fasta.txt` file was needed when I ran the [`Anvi'o` snakemake pangenomics workflows](https://merenlab.org/2018/07/09/anvio-snakemake-workflows/#pangenomics-workflow) provided by the creators of `Anvi'o`. I repeated all these steps manually, but I still left the steps for creating the `fasta.txt` file in case the reader ever wants to use the automatic workflow._

### 2. Reformat FASTA files
I reformatted the downloaded NCBI FASTA files (adding `NCBI_` prefix, simplifying headers, and producing report files).  
```bash
2_reformat_fasta_NCBI.sh
```
_This script also fixed the paths in `fasta_final.txt`, producing `fasta_final_reformatted.txt`._

### 3. Create and annotate contigs DBs for NCBI genomes
For each NCBI genome, I generated a contigs DB, ran HMMs to detect SCGs, annotated genes against COGs, and estimated the genomes taxonomy (from SCGs) :
```bash
3_create_and_annotate_contigs_db_NCBI.sh
```

### 4. Generate external genomes file
I produced the [external-genomes_NCBI.txt](external-genomes_NCBI.txt) file linking each NCBI genome to its contigs DB :
```bash
4_generate_external_genomes_file.sh
```

### 5. Compute combined pangenome (MAGs + NCBI genomes)
#### 5. a) Generate the genomes and pan databases
Finally, I created a genomes storage database (`MAGs_NCBI-GENOMES.db`) from both internal and external genomes, then computed the pangenome with `anvi-pan-genome` :
```bash
5a_generate_genomes_and_PAN_databases.sh
```

#### 5. b) Compute the average nucleotide identity (ANI) estimates across genomes
In order to obtain a heatmap that shows the average nucleotide identity (ANI) estimates across genomes, I ran the `anvi-compute-genome-similarity` command, which uses `PyANI` program in the background and adds the ANI information into the pan database automatically :
```bash
# Set working directory
cd ~/Stage_Copenhague/downstream_analysis/NCBI_pangenome

# Activate the Anvi'o environment 
conda activate anvio8_env

# Compute the similarity (ANI) between genomes 
anvi-compute-genome-similarity -e external-genomes_NCBI.txt \
-i ~/Stage_Copenhague/downstream_analysis/MAGs_metapangenome/pangenome/internal-genomes_MAGs.txt  \
-o ANI \
-p PAN/PAN_db/MAGs_vs_NCBI-PAN.db \
-T 24
```
_**N.B :** Before running the previous command, I manually renamed the `PAN.db` because I found that the name was too long : from `Pangenome_12_Archaeal_MAGs_31_NCBI_genomes-PAN.db` to : `MAGs_vs_NCBI-PAN.db`_ 

#### 5. c) Infer evolutionnary associations between genomes in the pangenome
To infer evolutionary associations between the 42 genomes in my pangenome, I used single-copy core genes (SCGs) across all genomes for a phylogenomic analysis. 

To recover a FASTA file for individually aligned and concatenated SCGs specific to the pangenome, I ran the following command :
```bash
anvi-get-sequences-for-gene-clusters -p PAN/PAN_db/MAGs_vs_NCBI-PAN.db \ 
-g PAN/MAGs_NCBI-GENOMES.db \  
--min-num-genomes-gene-cluster-occurs 42 \
--max-num-genes-from-each-genome 1 \
--concatenate-gene-clusters \
--output-file PAN/MAGs_vs_NCBI-SCGs.fa
```
This resulted in a FASTA file, which we first cleaned up by removing nucleotide positions that were gap characters in more than 50% of the sequences using [trimAl](https://github.com/inab/trimal) :

```bash 
trimal -in PAN/MAGs_vs_NCBI-SCGs.fa \
-out PAN/MAGs_vs_NCBI-SCGs-clean.fa \
-gt 0.50
```

Then I ran the phylogenomic analysis using [IQ-TREE](https://iqtree.github.io/) with the "**WAG**" general matrix model to infer a maximum likelihood tree :
```bash
iqtree -s PAN/MAGs_vs_NCBI-SCGs-clean.fa \
-nt 16 \
-m WAG \
-bb 1000
```

#### 5. d) Organize misc-data
In order to organize genomes in the pangenome during the visualization step, I generated a "layers order" file (the format of which is explained [here](https://merenlab.org/2017/12/11/additional-data-tables/)), and imported it into the pan database : 
```bash
# Set working directory
cd ~/Stage_Copenhague/downstream_analysis/NCBI_pangenome

# Create the folder for misc data
mkdir -p misc_data

# Create the folder for layer orders misc data
mkdir -p misc_data/layer_orders

# generate the file
echo -e "item_name\tdata_type\tdata_value" > misc_data/layer_orders/MAGs_vs_NCBI-phylogenomic-layer-order.txt

# add the newick tree as an order
echo -e "SCGs_Bayesian_Tree\tnewick\t`cat PAN/MAGs_vs_NCBI-SCGs-clean.fa.contree`" >> misc_data/layer_orders/MAGs_vs_NCBI-phylogenomic-layer-order.txt

# import the layers order file
anvi-import-misc-data -p PAN/PAN_db/MAGs_vs_NCBI-PAN.db \
-t layer_orders \
misc_data/layer_orders/MAGs_vs_NCBI-phylogenomic-layer-order.txt 
```

Then, I transferred my new `downstream_analysis/` folder to my **local WSL Ubuntu** session : 
```bash
scp -r alexis@thoth:/home/alexis/Stage_Copenhague/downstream_analysis /home/alexis/Stage_Copenhague
```

Next, I ran several commands to generate the folders containing the misc data for `layers` and `items`, and then export them to see their format :
```bash
# Set working directory
cd ~/Stage_Copenhague/downstream_analysis/NCBI_pangenome

# Create folders 
mkdir -p misc_data/items
mkdir -p misc_data/layers

# Activate the Anvi'o environment 
conda activate anvio-8

# Export the misc data to see their format 
anvi-export-misc-data -p PAN/PAN_db/MAGs_vs_NCBI-PAN.db -t items -o misc_data/items/items_original_file.txt

anvi-export-misc-data -p PAN/PAN_db/MAGs_vs_NCBI-PAN.db -t layers -o misc_data/layers/layers_original_file.txt

anvi-export-misc-data -p PAN/PAN_db/MAGs_vs_NCBI-PAN.db -t layer_orders -o misc_data/layer_orders/layer_orders_actual_file.txt
```

On my computer (WSL Ubuntu session), I wrote and ran this script to add the origin/source of each genome (MAG or NCBI) in the `PAN.db` :
```bash
5d_add_sources_to_layers_misc_data.sh
```

I obtained the [layers_modified_with_sources.txt](misc_data/layers_modified_with_sources.txt) file.

Finally I imported this file into the `PAN.db` :
```bash
anvi-import-misc-data misc_data/layers/layers_modified_with_sources.txt \
-p PAN/PAN_db/MAGs_vs_NCBI-PAN.db \
-t layers
```

#### 5. e) Polishing the pangenome
To display the pangenome I ran the following command on my local WSL Ubuntu terminal :
```bash
anvi-display-pan -p PAN/PAN_db/MAGs_vs_NCBI-PAN.db \
-g PAN/MAGs_NCBI-GENOMES.db
```

After opening the pangenome via my Chrome browser (by typing: `http://localhost:8080`), I modified a lot of parameters to be able to improve the display of my pangenome, and to be able to add the phylogenetic tree and the heatmap based on the ANI calculation (ANI estimates computed and stored in the pan database previously) : 
- I clicked `Draw` after the interface first opens
- I clicked `Layers` > `Layer Groups` > and ticked `ANI_percentage_identity` to display the **ANI heatmap**.
- I selected **all ANI layers** by selecting `ANI_percentage_identity` from `Settings` > `Layers` > `Select all layers in a group`
- I Increased the minimum values for each ANI layer all at once by entering `0.7` in `Settings` > `Layers` > `Edit attributes for multiple layers` > `Min`
- I clicked `Settings` > `Layers` > `Redraw layer data` to see changes
- I selected `SCGs_Bayesian_Tree` from `Settings` > `Layers` > `Order by`, to order genomes by the phylogenomic tree
- I increased the **radius** of the dendrogram in the center by entering `6000` in `Settings` > `Main` > `Show Additional Settings` > `Dendrogram` > `Radius`
- I increased the height of the phylogenomic tree on the right-top by entering `2000` in `Settings` > `Layers` > `Tree/Dendrogram` > `Height`
- I increased the size and selections layer by entering `400` in `Settings` > `Main` > `Additional Settings` > `Selections` > `Height`
- I clicked `Settings` > `Main` > `Show Additional Settings` > `Custom margins` to enable custom margins
- I used `Settings` > `Main` > `Layers` to increase genome / group distances using the `margin column`
- I did a `command-right-click` to the branch of singletons and clicked `Collapse` from the menu
- I reduced the opacity of layer backgrounds by setting `0.15` to `Settings` > `Main` > `Show Additional Settings` > `Layers` > `Background opacity`
- I increased the maximum font size by entering `240` in `Settings` > `Main` > `Show Additional Settings` > `Layer Labels` > `Max. Font Size`
- And finally I clicked on `Draw` to see all the changes

I realized that the "color" column in the file [layers_modified_with_sources.txt](misc_data/layers_modified_with_sources.txt) was useless (because `Anvi'o` already assigns a different color to the different origins/sources), so I removed it from the `PAN.db` via the following command :
```bash

anvi-delete-misc-data -p PAN/PAN_db/MAGs_vs_NCBI-PAN.db \
--target-data-table layers \
--keys-to-remove color
```

### a remake of the same figure but with fewer genomes
All steps in section _**5. Compute combined pangenome (MAGs + NCBI genomes)**_ have been redone, but reducing the number of genomes from NCBI and adding detailed information on **isolation sources** (wheat_rhizosphere, mangrove_sediment, etc.) and more **general isolation categories** (soil, sediment, hot_spring, ...) for all genomes. The files used to create this new figure are : 
- [external-genomes_NCBI_2.txt](external-genomes_NCBI_2.txt)
- [layers_modified_with_sources_2.txt](layers_modified_with_sources_2.txt)
- and [layers_misc_data_environments_isolation_source_2.txt](layers_misc_data_environments_isolation_source_2.txt)


## Parameters

### ncbi-genome-download _([documentation](https://github.com/kblin/ncbi-genome-download))_
- `archaea` : specifies the domain of life (Archaea) to download.  
- `-t <taxids.txt>` : provides a text file with NCBI taxonomy identifiers.  
- `-l complete,chromosome` : restricts downloads to "complete genomes" or "chromosome-level" assemblies.  
- `-s <refseq|genbank>` : specifies the source database (`refseq` or `genbank`).  
- `--metadata <file>` : saves the genomes metadata (`*_metadata.txt`) to the given file.  
- `--dry-run` : prints which genomes would be downloaded without downloading them.  

### gimme_taxa.py _([documentation](https://github.com/kblin/ncbi-genome-download?tab=readme-ov-file#contributed-scripts-gimme_taxapy))_
- `<taxid>` : numeric NCBI taxonomy identifier.  
- `-o <output_file>` : writes the list of all descendant taxids to a file.  
- `--just-taxids` : outputs only taxid numbers without additional metadata.  

### anvi-script-process-genbank-metadata _([documentation](https://anvio.org/help/7/programs/anvi-script-process-genbank-metadata/))_
- `-m <metadata.txt>` : input metadata table generated by `ncbi-genome-download`.  
- `-o <output_dir>` : folder to store FASTA files.  
- `--output-fasta-txt <file>` : generates a text file listing FASTA file paths.  
- `--exclude-gene-calls-from-fasta-txt` : removes unnecessary gene-call information from the `fasta.txt` file (function & source).  

### 2_reformat_fasta_NCBI.sh
This script reformats all downloaded NCBI FASTA files to make them compatible with `Anvi'o` and generates report files. It also updates the global `fasta_final.txt` file to point to the reformatted files.

#### anvi-script-reformat-fasta _([documentation](https://anvio.org/help/main/programs/anvi-script-reformat-fasta/))_
- `<input.fa>` : FASTA file to reformat.  
- `-o <output.fa>` : output reformatted FASTA file.  
- `--simplify-names` : shortens contig names to simple identifiers (removes long headers).  
- `--report-file <file.txt>` : generates a report describing how names were simplified.  
- `--prefix <string>` : adds a prefix to each contig name (here `NCBI_<genome_name>`).  

#### sed
- `sed 's|/NCBI-GENOMES/|/NCBI-GENOMES-REFORMATTED/|'` : replaces old path by the new reformatted directory.  
- `sed 's/-contigs.fa$/.fa/'` : replaces suffix `-contigs.fa` with `.fa` in the `fasta_final.txt`, giving the `fasta_final_reformatted.txt`. 

### 3_create_and_annotate_contigs_db_NCBI.sh
#### anvi-gen-contigs-database *([documentation](https://anvio.org/help/main/programs/anvi-gen-contigs-database/))*  
- `-f <fasta.fa>` : input genome FASTA file.  
- `-o <contigs.db>` : output contigs database.  
- `-n <name>` : assigns a name to the contigs database.  

#### anvi-run-hmms *([documentation](https://anvio.org/help/main/programs/anvi-run-hmms/))*  
- `-c <contigs.db>` : contigs database to annotate with HMMs.  
- `-T` : number of threads

#### anvi-run-ncbi-cogs *([documentation](https://anvio.org/help/main/programs/anvi-run-ncbi-cogs/))*
- `-c <contigs.db>` : contigs database to annotate.  
- `--cog-data-dir` : path to COG 2020 database 
- `-T` : number of CPU threads to use. 

#### anvi-run-scg-taxonomy *([documentation](https://anvio.org/help/7/programs/anvi-run-scg-taxonomy/))*  
- `-c <contigs.db>` : contigs database to analyze.  
- `-T` : number of CPU threads.

### 4_generate_external_genomes_file.sh
Generates [external-genomes_NCBI.txt](external-genomes_NCBI.txt)  with columns :  
- `name` : genome identifier.  
- `contigs_db_path` : absolute path to its contigs database.  

### 5a_generate_genomes_and_PAN_databases.sh
#### anvi-gen-genomes-storage *([documentation](https://anvio.org/help/7/programs/anvi-gen-genomes-storage/))* 
- `-i` : internal genomes file. 
- `-e` : external genomes file. 
- `-o` : output file (genomes-storage database).   

#### anvi-pan-genome *([documentation](https://anvio.org/help/main/programs/anvi-pan-genome/))*  
- `-g <MAGs_NCBI-GENOMES.db>` : input genomes storage.  
- `--use-ncbi-blast` : uses NCBI BLAST for sequence similarity.  
- `--minbit 0.5` : sets minimum bit score ratio (filters weak hits).  
- `--mcl-inflation 10` : controls clustering granularity in MCL (higher = tighter clusters).  
- `--project-name` : assigns a name to the project.  
- `--num-threads 20` : number of parallel threads.  
- `-o <output_dir>` : output directory for pangenome database.  
- `--min-occurrence` : defines the minimum number of genomes in which a gene must appear for it to be included in the pangenome _(I excluded **singletons** by putting 2 because the number of genomes was far too high and the gene clustering was always skipped)_.

#### anvi-compute-genome-similarity *([documentation](https://anvio.org/help/7/programs/anvi-compute-genome-similarity/))*
- `-e <external-genomes.txt>` : external genomes file.  
- `-i <internal-genomes.txt>` : internal genomes file.  
- `-o <ANI_dir>` : output directory for similarity results.  
- `-p <PAN.db>` : input pangenome database.  
- `-T <threads>` : number of threads.  

### anvi-get-sequences-for-gene-clusters *([documentation](https://anvio.org/help/main/programs/anvi-get-sequences-for-gene-clusters/))*
- `-p <PAN.db>` : pangenome database.  
- `-g <GENOMES.db>` : genomes storage file.  
- `--min-num-genomes-gene-cluster-occurs 42` : restricts to clusters found in all 42 genomes (SCGs).  
- `--max-num-genes-from-each-genome 1` : ensures only one gene per genome is selected.  
- `--concatenate-gene-clusters` : concatenates aligned SCGs into a supermatrix.  
- `--output-file <file.fa>` : writes output FASTA.  

### trimal *([documentation](https://github.com/inab/trimal))*
- `-in <file.fa>` : input multiple sequence alignment.  
- `-out <file.fa>` : output alignment file cleaned (without nucleotide positions that were gap characters in more than 50% of the sequences).  
- `-gt 0.50` : removes alignment columns with >50% gaps.  

### iqtree *([documentation](https://iqtree.github.io/))*
- `-s <file.fa>` : input alignment.  
- `-nt <threads>` : number of threads.  
- `-m WAG` : evolutionary substitution model (WAG).  
- `-bb 1000` : ultrafast bootstrap with 1000 replicates.  

### anvi-import-misc-data *([documentation](https://anvio.org/help/main/programs/anvi-import-misc-data/))* 
- `-p <PAN.db>` : input pangenome database.  
- `-t <table>` : misc-data table type (`items`, `layers`, or `layer_orders`).  
- `<file.txt>` : tab-delimited file to import.  

### anvi-export-misc-data *([documentation](https://anvio.org/help/main/programs/anvi-export-misc-data/))*
- `-p <PAN.db>` : input pangenome database.  
- `-t <table>` : type of misc-data to export (`items`, `layers`, `layer_orders`).  
- `-o <file.txt>` : output file.  

### 5d_add_sources_to_layers_misc_data.sh
This script modifies the `layers` misc-data table :  
- Adds a `source` column identifying genome origin (MAG vs NCBI).  
- Produces [layers_modified_with_sources.txt](misc_data/layers_modified_with_sources.txt).  

### anvi-delete-misc-data *([documentation](https://anvio.org/help/7.1/programs/anvi-delete-misc-data/))*
- `-p <PAN.db>` : input pangenome database.  
- `--target-data-table layers` : specifies the type of misc-data table (`items`, `layers`, `layer_orders`).  
- `--keys-to-remove color` : deletes the `color` column.  

### anvi-display-pan *([documentation](https://anvio.org/help/7/programs/anvi-display-pan/))*
- `-p <PAN.db>` : input pangenome database.  
- `-g <GENOMES.db>` : genomes storage file.  

--- 

## Notes
- Some NCBI genomes were only available in **GenBank** (not RefSeq), which explains why both `-s refseq` and `-s genbank` were used in `ncbi-genome-download`.  
- The `--min-occurrence 2` option in `anvi-pan-genome` excludes singletons (gene clusters found in only one genome). This was necessary because the analysis **kept crashing due to the very large number of singleton gene clusters**, so I restricted the pangenome to clusters present in at least two genomes.  
- I manually **renamed the PAN database file** (from `Pangenome_12_Archaeal_MAGs_31_NCBI_genomes-PAN.db` to `MAGs_vs_NCBI-PAN.db`) because the initial name that I had chosen was excessively long.  
- The `fasta_final.txt` file was still generated (for reproducibility and in case one uses the official Snakemake workflow), but I ended up not relying on it for my manual workflow.  
- While adding misc-data, I realized the `color` column in the file `layers_modified_with_sources.txt` was unnecessary since `Anvi'o` automatically assigns different colors to groups (MAG vs NCBI). I therefore deleted this column from the database with `anvi-delete-misc-data`.  
- During `anvi-display-pan`, several **manual adjustments** were required (margins, tree radius, ANI thresholds, collapsing singletons, etc.) to obtain a clear and interpretable visualization. These are not scripted but documented in the execution section.  
- SCG-based phylogenomics (`anvi-get-sequences-for-gene-clusters` + `trimal` + `iqtree`) provided a robust evolutionary framework, but the choice of the **WAG substitution model** was empirical (it is a common general model for proteins).  
- Scripts use relative paths from `~/Stage_Copenhague`.  










