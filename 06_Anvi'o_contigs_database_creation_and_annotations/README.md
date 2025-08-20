# Step 6 - Anvi'o Contigs Database creation & annotations

This step consisted in creating `Anvi'o` **contigs databases** for all assemblies (**individual** and **co-assemblies**) and performing functional and taxonomic annotations.  

Annotations included :  
- **Single-copy gene detection** and HMM-based annotation (`anvi-run-hmms`)  
- **Functional annotation** against NCBI's COGs 2020 (`anvi-run-ncbi-cogs`)  
- **Taxonomic annotation** at the gene level using **Centrifuge** (`anvi-get-sequences-for-gene-calls` + `centrifuge` + `anvi-import-taxonomy-for-genes`)  
- **SCG-based taxonomy** (`anvi-run-scg-taxonomy`)  

> ⚠️ The installation of **COG 2020 database**, **Centrifuge** and its database, as well as the configuration for `anvi-run-scg-taxonomy`, is described step-by-step in the [installation.md](../installation.md) file of this repository.  
> In this README, only the additional commands required **before running specific steps** are indicated.

---

## Environment & Software Versions
All commands were executed on the Thoth server running : Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-126-generic x86_64).

The tools used during this step are managed via 2 Conda environments defined in :  
- [`envs/anvio8_env.yml`](../envs/anvio8_env.yml)
- [`envs/centrifuge_env.yml`](../envs/centrifuge_env.yml)

| Tool        | Version | Installation method     |
|-------------|---------|-------------------------|
| Anvi'o      | 8.0     | Conda (`bioconda`)      |
| DIAMOND     | 2.1.12   | Included with `Anvi'o` |
| Centrifuge  | 1.0.4.2   | Conda (`bioconda`)    |

### Environment creation
To recreate the environments from the root of the repository : 
```bash
# Anvi'o environment
conda env create -f envs/anvio8_env.yml
conda activate anvio8_env

# Centrifuge environment
conda env create -f envs/centrifuge_env.yml
conda activate centrifuge_env
```
---

## Scripts

- [`create_contig_db.sh`](create_contig_db.sh)  
⭢ Creates `Anvi'o` contigs databases for **all individual assemblies**.

- [`create_contig_db_coassembly.sh`](create_contig_db_coassembly.sh)  
⭢ Creates `Anvi'o` contigs databases for **all co-assemblies**.

- [`run_annotations_all_samples.sh`](run_annotations_all_samples.sh)  
⭢ After copying the contigs databases (single-assemblies), runs in parallel the following annotation steps for **all individual assemblies** :  
    1. `anvi-run-hmms` (to search for single-copy genes and rRNAs)  
    2. `anvi-run-ncbi-cogs` (functional annotation with `DIAMOND` against NCBI's COGs)  
    3. `centrifuge` (gene export, classification, import in `Anvi'o`)  
    4. `anvi-run-scg-taxonomy` (to affiliate single-copy core genes in an anvi'o contigs database with taxonomic names)

- [`run_annotations_coassemblies.sh`](run_annotations_coassemblies.sh)  
⭢ After copying the contigs databases (coassemblies), it did the same as above, applied to **co-assembly contigs databases**.

---

## Inputs

### Contigs  
Assembled and renamed contigs (≥ 1000 bp) :  
- Individual assemblies :  
`~/Stage_Copenhague/assembly/sample_xx/sample_xx_contigs_fixed.fa`
- Co-assemblies :  
`~/Stage_Copenhague/assembly/{GROUP}/{GROUP}_contigs_fixed.fa`

### External databases  
- **COG 2020** data directory : `~/anvio_cogs/`  
- **Centrifuge database** : `~/Stage_Copenhague/databases/centrifuge_db/p_compressed+h+v`

---
## Outputs

### Contigs databases  
- Individual assemblies :  
`~/Stage_Copenhague/anvio_db/anvio_contigs_db/sample_xx_contigs.db`
- Co-assemblies :  
`~/Stage_Copenhague/anvio_db/anvio_contigs_db/{GROUP}_contigs.db`

### Centrifuge results  
Located in `~/Stage_Copenhague/centrifuge_results/sample_xx/` or `centrifuge_results/{GROUP}/` :  
| File name                          | Description                           |
|------------------------------------|---------------------------------------|
| `*_gene_calls.fa`                  | Exported gene sequences for Centrifuge|
| `*_centrifuge_hits.tsv`            | Detailed classification results       |
| `*_centrifuge_report.tsv`          | Summary report                        |

---

## Execution

### (i) Create contigs databases
To create `Anvi'o` contigs databases for all assemblies :  
```bash
create_contig_db.sh
create_contig_db_coassembly.sh
```

### (ii) Before running `anvi-run-ncbi-cogs` 
I installed the COG 2020 database (see the [`installation.md`](../installation.md) file) and ran :  
```bash
anvi-setup-ncbi-cogs --cog-data-dir ~/anvio_cogs --just-do-it -T 4
```

### (iii) Before using centrifuge 
I installed Centrifuge and its database (see the [`installation.md`](../installation.md) file)

### (iv) Before running `anvi-run-scg-taxonomy`  
I configured the SCG taxonomy database (see the [`installation.md`](../installation.md) file) by running :  
```bash
anvi-setup-scg-taxonomy
```

### (v) Run annotations
To annotate contig databases : 
- For all individual assemblies :  
```bash
run_annotations_all_samples.sh
```
- For all co-assemblies :  
```bash
run_annotations_coassemblies.sh
```

---

## Parameters

### Anvi'o  
- `anvi-gen-contigs-database` *([documentation](https://anvio.org/help/main/programs/anvi-gen-contigs-database/))* 
    - `-f` : input contigs FASTA file  
    - `-o` : output `.db` file  
    - `-n` : assembly name  

- `anvi-run-hmms` *([documentation](https://anvio.org/help/main/programs/anvi-run-hmms/))*
    - `-c` : path to the `contigs.db` file
    - `-T` : number of threads  

- `anvi-run-ncbi-cogs` *([documentation](https://anvio.org/help/main/programs/anvi-run-ncbi-cogs/))*
    - `-c` : path to the `contigs.db` file    
    - `--cog-data-dir` : path to COG 2020 database  
    - `-T` : number of threads  

- `anvi-import-taxonomy-for-genes` *([documentation](https://anvio.org/help/7/programs/anvi-import-taxonomy-for-genes/))*
    - `-c` : path to the `contigs.db` file
    - `-i` : paths to the centrifuge detailed classification results and summary report files
    - `p` : specifies the classification tool (it can also be Kaiju for example)

- `anvi-run-scg-taxonomy` *([documentation](https://anvio.org/help/7/programs/anvi-run-scg-taxonomy/))*   
    - `-c` : path to the `contigs.db` file
    - `-T` : number of threads  

### Centrifuge *([documentation](https://ccb.jhu.edu/software/centrifuge/manual.shtml))*  
- `-x` : path to the Centrifuge database index  
- `-U` : sequences to classify (`*_gene_calls.fa`)
- `-S` : path to detailed classification results file (`*_centrifuge_hits.tsv`) 
- `--report-file` : path to summary report file (`*_centrifuge_report.tsv`) 
- `-p` : number of threads  

---

## Notes
- The scripts use `GNU Parallel` to process multiple samples or groups simultaneously.  
- Contigs databases are duplicated as `*_contigs_copy.db` before annotation to preserve the original.  
- Large external database downloads and installations (COG 2020, Centrifuge DB, SCG taxonomy setup) are documented in [`installation.md`](../installation.md).  
- Default parameters were used for all `Anvi'o` commands except when specified.
- Scripts use relative paths from `~/Stage_Copenhague`.
