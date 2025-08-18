# Step 9 – Dereplication of MAGs

In this step, I performed **dereplication of MAGs** using **dRep**. It is the process of identifying sets of genomes that are the "same" in a list of genomes, and removing all but the "best" genome from each redundant set.  
The goal was to cluster highly similar MAGs, keep only the best-quality representative genomes, and thus reduce redundancy across all Archaeal MAGs generated in **Step 8**.  
This process also produced a consolidated taxonomy table for Archaeal MAGs.

---

## Environment & Software Versions

All commands were executed on the **Thoth** server (Ubuntu 22.04.5 LTS, GNU/Linux 5.15.0-126-generic x86_64).  

The dereplication was carried out with a dedicated Conda environment : [`envs/drep_env.yml`](../envs/drep_env.yml)

| Tool         | Version | Installation method |
|--------------|---------|---------------------|
| dRep         | 3.6.2    | Conda (`bioconda`)  |
| Python       | 3.10.18    | Conda               |

Environment creation :
```bash
conda env create -f envs/drep_env.yml
conda activate drep_env
```

---

## Scripts
- [`generate_MAGs_taxonomy_table.sh`](generate_MAGs_taxonomy_table.sh)  
  ⭢ Before dereplication, I generated a consolidated **taxonomy table** of the 70 Archaeal MAGs (available in this repository : [archaea_MAGs_taxonomy.xlsx](archaea_MAGs_taxonomy.xlsx) ⭢ _Right-click and download the file_), parsing `Anvi'o`'s SCG taxonomy files.

- [`create_fasta_files_directory.sh`](create_fasta_files_directory.sh)  
  ⭢ I ran this script to collect all **Archaeal MAG fasta files** (from Step 8 summaries) and create symbolic links in a single directory for dereplication.

- [`drep_without_reference.sh`](drep_without_reference.sh)  
  ⭢ I executed this script to **dereplicate the genomes** using `dRep`, with minimum quality thresholds (≥ 50% completeness, ≤ 10% contamination, and 95% ANI for secondary clustering).


---

## Inputs

- MAG taxonomy files (from SCG taxonomy results in Step 8) :  
  `~/Stage_Copenhague/visualisation_anvio/*/anvi_summarize/*_MAGs_summarize/bin_by_bin/*/*-scg_taxonomy_details.txt`

- MAG fasta files produced in Step 8 (from `anvi-summarize` outputs) :  
  `~/Stage_Copenhague/visualisation_anvio/*/anvi_summarize/*_MAGs_summarize/bin_by_bin/*/*-contigs.fa`

---

## Outputs

- **Table built manually on Excel to count the number of Archaeal MAGs before dereplication** :  
[Summary_of_bins_before_drep.xlsx](Summary_of_bins_before_drep.xlsx)  

- **Archaeal MAGs taxonomy table** :  
  `~/Stage_Copenhague/archaea_MAGs_taxonomy.tsv`
  Also available in this repository : [archaea_MAGs_taxonomy.xlsx](archaea_MAGs_taxonomy.xlsx)

- **Symlinked genomes directory** (input for dRep) :  
  `~/Stage_Copenhague/drep_analysis/genomes_symlinks_without_reference/`

- **dRep results folder** :  
  `~/Stage_Copenhague/drep_analysis/drep_output_without_reference/`  
  (includes dereplication clustering results, winning genomes, and quality metrics)



---

## Execution

### 1. Count the number of Archean MAGs obtained by single assemblies and co-assemblies
I manually counted the number of Archean MAGs obtained across all my assemblies (**70**) which I reported in this file : [Summary_of_bins_before_drep.xlsx](Summary_of_bins_before_drep.xlsx).

### 2. Generate Archaeal MAGs taxonomy table
```bash
bash generate_MAGs_taxonomy_table.sh
```
Before dereplication, I summarized SCG taxonomy annotations across all MAGs (Out of 70 Archean MAGs in total) into a single .tsv file. The script extracted the highest-scoring taxonomy line per MAG and wrote it to [archaea_MAGs_taxonomy.xlsx](archaea_MAGs_taxonomy.xlsx).


### 3. Create a central fasta directory
```bash
bash create_fasta_files_directory.sh
```
This script searched for all `*-contigs.fa` MAG files in the Step 8 summaries and created symbolic links in `~/Stage_Copenhague/drep_analysis/genomes_symlinks_without_reference/`.

### 4. Run dRep dereplication
```bash
bash drep_without_reference.sh
```
I launched `dRep dereplicate` with the parameters explained in the "**Parameters**" section.

This generated a non-redundant set of representative MAGs (12 in total).

---
## Parameters 
_Documentation : [drep documentation](https://drep.readthedocs.io/en/latest/overview.html#genome-comparison)_
- `-g` : specifies the folder containing the genomes to be dereplicated
- `-comp 50` : ≥ 50% completeness  
- `-con 10` : ≤ 10% contamination  
- `-sa 0.95` : secondary ANI threshold at 95%  
- `-p 8` : specifies the number of threads used in parallel 


---

## Notes

- dRep was run **without reference genomes** [`drep_without_reference.sh`](drep_without_reference.sh).  
- Completeness and contamination thresholds followed common standards for medium-quality MAGs (MIMAG criteria).  
- Taxonomy was extracted from `Anvi'o` SCG taxonomy results, sorted by confidence score, and stored in a single file for downstream analyses.  
- Before dereplication, I compiled `Summary_of_bins_before_drep.xlsx` to record the total number of bins per sample and co-assembly.
- Scripts use relative paths from `~/Stage_Copenhague`.  


