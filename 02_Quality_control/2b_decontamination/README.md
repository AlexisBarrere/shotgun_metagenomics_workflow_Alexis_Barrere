# Step 2b - Decontamination
This step aimed to remove contaminant reads from wheat (*Triticum aestivum*), human (*Homo sapiens*), and PhiX control sequences. Decontamination was performed in three sequential steps using `Bowtie2` in alignment + `--un` mode to retain only the unaligned reads (i.e. those that are not contaminants).

---
## Environment & Software Versions
All commands were executed on the **Thoth server** running :  
`Ubuntu 22.04.5 LTS` (GNU/Linux 5.15.0-126-generic x86_64).

The tools used during this step are managed via a Conda environment defined in [`envs/bowtie2_env.yml`](../../envs/bowtie2_env.yml)

### Software versions (as per `bowtie2_env.yml`) : 
| Tool         | Version  | Installation method |
|--------------|----------|---------------------|
| Bowtie2      | 2.5.4    | Conda (`bioconda`)  |
| GNU Parallel | 20210822 | ------------------- |

### Environment creation
To recreate the environment from the root of the repository :

```bash
conda env create -f envs/bowtie2_env.yml
conda activate bowtie2_env
```

---

## Scripts 
- [`reads_decontamination_sample_01.sh`](reads_decontamination_sample_01.sh)  
⭢ Decontamination pipeline applied to sample 01 only (used for testing and optimization).

- [`reads_decontamination_samples_02_to_24.sh`](reads_decontamination_samples_02_to_24.sh)  
⭢ Script that applies the full decontamination pipeline (wheat ⭢ human ⭢ PhiX) to all paired and unpaired reads of samples 02 to 24, using GNU Parallel.

- [`unpaired_reads_decontamination_samples_01_to_24.sh`](unpaired_reads_decontamination_samples_01_to_24.sh)  
⭢ Script that re-applies decontamination only on the unpaired reads generated after additional trimming (in `clean_reads_final/`). This replaces previous unpaired read versions in `decontamination/`.

- [`rename_paired_files.sh`](rename_paired_files.sh)  
⭢ Script for renaming paired read files generated after decontamination, in a format compatible with FastQC and MultiQC. 

- [`counting_reads_after_decontamination.sh`](counting_reads_after_decontamination.sh)  
⭢ This script counts the number of reads remaining at each stage of the decontamination pipeline (before and after each contaminant removal step) for all 24 samples.

All scripts are available in this folder for reproducibility.

---

## Inputs 

### Reference genomes & index building
To remove host and laboratory contaminants, the following genomes were downloaded and indexed with `bowtie2-build`:

#### 1. Wheat _(Triticum aestivum)_
- Source : [Ensembl Plants - Triticum aestivum, release 61](https://ftp.ensemblgenomes.ebi.ac.uk/pub/plants/release-61/fasta/triticum_aestivum/dna/)
- File used : `Triticum_aestivum.IWGSC.dna_sm.toplevel.fa`
- Commands : 
```bash 
mkdir -p ~/Stage_Copenhague/contaminants/wheat

cd ~/Stage_Copenhague/contaminants/wheat

wget https://ftp.ensemblgenomes.ebi.ac.uk/pub/plants/release-61/fasta/triticum_aestivum/dna/Triticum_aestivum.IWGSC.dna_sm.toplevel.fa.gz

gunzip Triticum_aestivum.IWGSC.dna_sm.toplevel.fa.gz

# To create the index : 
bowtie2-build Triticum_aestivum.IWGSC.dna_sm.toplevel.fa wheat_index
```

#### 2. Human _(Homo sapiens)_
- Genome : GRCh38 – primary assembly
- Source : [Ensembl - release 114](https://ftp.ensembl.org/pub/release-114/fasta/homo_sapiens/dna/)
- File used : `Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz`
- Commands : 
```bash
mkdir -p ~/Stage_Copenhague/contaminants/human

cd ~/Stage_Copenhague/contaminants/human

wget https://ftp.ensembl.org/pub/release-114/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz

gunzip Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz

# To create the index :
bowtie2-build Homo_sapiens.GRCh38.dna.primary_assembly.fa human_index
```

#### 3. PhiX control
- Source : [NCBI genome - PhiX174](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000819615.1/)
- File used : on the source link, click on `Download` ⭢ `Select file source` ⭢ `All` ⭢ `select file types` ⭢ `Genome sequences (FASTA)` ⭢ we obtain a compressed folder (`ncbi_dataset`) containing the PhiX genome file : `GCF_000819615.1_ViralProj14015_genomic.fna` in the `GCF_000819615.1` folder.
- Commands : 

```bash 
mkdir -p ~/Stage_Copenhague/contaminants/PhiX

# Place the downloaded file GCF_000819615.1_ViralProj14015_genomic.fna manually in the PhiX folder.

cd ~/Stage_Copenhague/contaminants/PhiX

# To create the index :
bowtie2-build GCF_000819615.1_ViralProj14015_genomic.fna phix_index
```

### Cleaned reads used as input
The input reads used for decontamination were the cleaned reads obtained after the trimming step (adapter removal and quality filtering). These reads are located in :
- For the first decontamination carried out (paired + unpaired reads from samples 01–24) :
`~/Stage_Copenhague/trimming/clean_reads/sample_xx/after_fastp/`

- For the second decontamination carried out (unpaired reads only from samples 01-24) :
`~/Stage_Copenhague/trimming/clean_reads_final/sample_xx/` 

Each sample folder contains :

| File name pattern | Description |
|--------------------|-------------|
| `sample_xx_read1_paired_cleaned.fq.gz` | Forward read, paired |
| `sample_xx_read2_paired_cleaned.fq.gz` | Reverse read, paired |
| `sample_xx_read1_unpaired_cleaned.fq.gz` | Forward read, unpaired |
| `sample_xx_read2_unpaired_cleaned.fq.gz` | Reverse read, unpaired |

These files were used as inputs for the decontamination scripts.

---
## Output
Each sample’s output is stored under :
`~/Stage_Copenhague/decontamination/sample_xx/`, and contains three subfolders : 

| Folder      | Description
|-------------|----------------|
| `no_wheat/` | Reads after wheat contaminant removal| 
| `no_human/` | Reads after additional human contaminant removal | 
| `contaminant_free/` | Final cleaned reads (after PhiX removal) |

The final read files (completely cleaned and decontaminated) are located in the following folders : `~/Stage_Copenhague/decontamination/sample_xx/contaminant_free`.  

Each folder contains : 
| File name pattern | Description |
|--------------------|-------------|
| `sample_xx_contaminant_free_read1_paired.fq.gz` | Forward read, paired |
| `sample_xx_contaminant_free_read2_paired.fq.gz` | Reverse read, paired |
| `sample_xx_contaminant_free_read1_unpaired.fq.gz` | Forward read, unpaired |
| `sample_xx_contaminant_free_read2_unpaired.fq.gz` | Reverse read, unpaired |

---
## Execution
- Firstly, the decontamination pipeline (wheat ⭢ human ⭢ PhiX) was tested on sample 01 to see if everything was working properly by running the following script :
```bash
reads_decontamination_sample_01.sh
```
- Secondly, decontamination was carried out on samples 02 to 24 :
```bash
reads_decontamination_samples_02_to_24.sh
```
- Thirdly, given that the adapters were trimmed again with different parameters on the unpaired read files (see the `a_trimming` folder), decontamination also had to be performed again on the new cleaned unpaired read files :
```bash
unpaired_reads_decontamination_samples_01_to_24.sh
```
- Fourthly, Bowtie2 generates paired read files in the following format : `sample_xx_contaminant_free_paired.fq.1.gz` for forward reads and `sample_xx_contaminant_free_paired.fq.2.gz` for reverse reads. However, this format does not allow FastQC and MultiQC to identify paired reads 1 and 2. The following script therefore renames the paired read files obtained at the end of decontamination into a format recognisable by `FastQC` and `MultiQC`: `sample_xx_contaminant_free_read1_paired.fq.gz` and `sample_xx_contaminant_free_read2_paired.fq.gz` :
```bash
rename_paired_files.sh
```
- Finally, a script to count the number of reads remaining after each decontamination step was run. It helps to quantify the effectiveness of each filtering step (wheat, human, and PhiX) by computing the number of reads retained at each level. For each sample (01–24), it reports:
  - The number of reads before any decontamination (`clean_reads_final/`)
  - The number of reads after wheat decontamination (`no_wheat/`)
  - The number of reads after human decontamination (`no_human/`)
  - The number of reads after PhiX decontamination (`contaminant_free/`)
```bash
counting_reads_after_decontamination.sh
```
All read counts are written in a structured output file : [`read_counts_decontamination.tsv`](read_counts_decontamination.tsv)

I imported this `.tsv` file into Excel and added calculations of the percentage of lost reads to better visualise the effectiveness of the decontamination process. You can see the result in the following file : [`final_read_counts_decontamination.xlsx`](final_read_counts_decontamination.xlsx)

---
## Parameters
The same parameters were applied in the three reads decontamination scripts.

### Bowtie2

*Documentation : [Bowtie 2 - Fast and sensitive read alignment](https://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#preset-options-in---end-to-end-mode)*  

Example for decontamination of the wheat genome :

```bash
    # For PAIRED reads :
	 bowtie2 -x $WHEAT_INDEX \
	 -1 $R1_PAIRED -2 $R2_PAIRED \
	 --very-sensitive -p 4 \
	 --un-conc-gz "$OUT_DIR/no_wheat/sample_${i}_no_wheat_paired.fq.gz" \
	 -S /dev/null

	# For UNPAIRED reads1 :
	bowtie2 -x $WHEAT_INDEX \
 	 -U $R1_UNPAIRED \
 	 --very-sensitive -p 4 \
 	 --un-gz "$OUT_DIR/no_wheat/sample_${i}_no_wheat_read1_unpaired.fq.gz" \
 	 -S /dev/null

	# For UNPAIRED reads 2 :
	bowtie2 -x $WHEAT_INDEX \
 	 -U $R2_UNPAIRED \
 	 --very-sensitive -p 4 \
 	 --un-gz "$OUT_DIR/no_wheat/sample_${i}_no_wheat_read2_unpaired.fq.gz" \
 	 -S /dev/null
```
**Explanation** :

- `-x` : Option that specifies the basename of the index for the reference genome. The basename is the name of any of the index files up to but not including the final *.1.bt2* / *.rev.1.bt2* / *etc.* Bowtie2 looks for the specified index first in the current directory, then in the directory specified in the environment variable after the *-x*.

- `-1` and `-2` : **paired inputs** : Used to indicate paired read files (forward and reverse reads that are paired).

- `-U` : Option that specifies a comma-separated list of files containing unpaired reads to be aligned. 

- `--very-sensitive` : set of optimised parameters to align more reads, at the cost of slightly reduced speed.   
_Running Bowtie 2 with the **--very-sensitive** option is the same as running with options : -D 20 -R 3 -N 0 -L 20 -i S,1,0.50._

- `-p 4` : This option allows Bowtie 2 to launch a specified number of parallel search threads (here 4). Each thread runs on a different processor/core, and all threads search for alignments in parallel, increasing the alignment throughput by approximately a multiple of the number of threads (although in practice, the acceleration is slightly less than linear). 

- `--un-conc-gz` : Write paired-end reads that fail to align concordantly to file(s) located at the specified path right after. 

- `--un-gz` : Write unpaired reads that fail to align to file(s) located at the specified path right after. 

- `-S` : Option that allows to specify the name and the path of the file in which Bowtie2 will write the alignments. The format is SAM, a standard text format used to represent alignments of reads to a genome or contig. As in the case of decontamination, we do not want to keep the aligned read files, so we specify that Bowtie2 should write these files to `/dev/null`, a special file in Unix/Linux systems that acts as a data sink. Any output written to this file is discarded immediately. It is commonly used to suppress unwanted output or to avoid generating unnecessary files during program execution.

---
## Notes
- The scripts use `GNU Parallel` to process multiple samples or files simultaneously.  
- All scripts use relative paths anchored to `~/Stage_Copenhague`.
