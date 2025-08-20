# Step 3 - Assembly 
This step aimed to reconstruct contiguous genomic sequences (**contigs**) from the cleaned and decontaminated reads. Assemblies were performed both individually (one per sample) and as co-assemblies (one per group), using `MEGAHIT`, an [ultra-fast and memory-efficient NGS assembler optimized for metagenomic data but also working well on generic single genome assembly.](https://github.com/voutcn/megahit)

For the co-assembly step, the 24 samples were grouped into 6 distinct groups based on sampling time and fertilization condition. Each group consisted of 4 samples and was defined in the [`coassembly_groups.tsv`](coassembly_groups.tsv) file.

Contigs were then renamed and filtered using `Anvi'o` to ensure compatibility with downstream tools (e.g., binning and anvi’o databases). Finally, assemblies were assessed using `MetaQUAST`, which provided basic metrics such as N50, total length, and number of contigs above thresholds.

---
## Environment & Software Versions
All commands were executed on the **Thoth server** running :
Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-126-generic x86_64).

The tools used during this step are managed via 3 Conda environments defined in :
- [`envs/megahit_env.yml`](../envs/megahit_env.yml)
- [`envs/anvio8_env.yml`](../envs/anvio8_env.yml)
- [`envs/quast_env.yml`](../envs/quast_env.yml)

| Tool         | Version          | Installation method    |
|--------------|------------------|------------------------|
| MEGAHIT      | 1.2.9            | Conda (`bioconda`)     |
| (Meta)QUAST  | 5.0.2            | Conda (`bioconda`)     |
| Anvi'o       | 8.0              | Conda (`bioconda`)     |
| GNU Parallel | 20210822         |                        |

### Environment creation
To recreate the environments from the root of the repository : 
```bash
# For the Assembly
conda env create -f envs/megahit_env.yml
conda activate megahit_env

# For the renaming of contigs
conda env create -f envs/anvio8_env.yml
conda activate anvio8_env

# For quality control of assemblies
conda env create -f envs/quast_env.yml
conda activate quast_env
```

--- 
## Scripts
### (i) Individual assemblies
- [`assembly_sample_01.sh`](assembly_sample_01.sh)  
⭢ MEGAHIT assembly on sample 01 using paired and unpaired reads (preset : `meta-sensitive`).

- [`parallel_assembly.sh`](parallel_assembly.sh)  
⭢ Parallelized MEGAHIT assemblies on samples 01 to 24 (preset : `meta-large`). 

### (ii) Co-assemblies
- [`parallel_coassembly.sh`](parallel_coassembly.sh)  
⭢ Parallel co-assemblies of six groups defined in a TSV file ([`coassembly_groups.tsv`](coassembly_groups.tsv)). Uses all paired and unpaired reads from 4 samples per group.

### (iii) Renaming & filtering contigs 
- [`renaming_contigs.sh`](renaming_contigs.sh)  
⭢ Renames contigs from individual assemblies (final.contigs.fa) with `Anvi’o` to simplify headers and apply a length threshold (≥ 1000 bp). New contig files (`*_contigs_fixed.fa`) are generated with simplified IDs and tracked in a conversion report.

- [`renaming_contigs_coassembly.sh`](renaming_contigs_coassembly.sh)  
⭢ Same as above but applied to all co-assemblies. 

### (iv) Quality assessment 
- [`quast_all_samples.sh`](quast_all_samples.sh)  
⭢ Runs MetaQUAST on all individual assemblies. 

- [`metaquast_coassembly.sh`](metaquast_coassembly.sh)  
⭢ Runs MetaQUAST on all co-assemblies. Reports are saved on the server in `~/Stage_Copenhague/assembly/{GROUP}/metaquast_results/`.

All the metaQUAST results can be found in this GitHub repository here : `3_assembly/metaquast_results/`.

---
## Inputs
The input data for this step consisted of cleaned and decontaminated reads, located in the following directory :  
`~/Stage_Copenhague/decontamination/sample_xx/contaminant_free/`

Each sample folder contained : 
| File name pattern                               | Description            | 
|-------------------------------------------------|------------------------|
| sample_xx_contaminant_free_read1_paired.fq.gz   | Forward, paired read   |
| sample_xx_contaminant_free_read2_paired.fq.gz   | Reverse, paired read   |
| sample_xx_contaminant_free_read1_unpaired.fq.gz | Forward, unpaired read | 
| sample_xx_contaminant_free_read2_unpaired.fq.gz | Reverse, unpaired read |

These reads were used as input for :

- individual assemblies (scripts [`assembly_sample_01.sh`](assembly_sample_01.sh), [`parallel_assembly.sh`](parallel_assembly.sh))

- co-assemblies (script [`parallel_coassembly.sh`](parallel_coassembly.sh))

The co-assembly grouping file was also used as input :
- [`coassembly_groups.tsv`](coassembly_groups.tsv) defines 6 groups of 4 samples based on sampling time and fertilization condition. 

---
## Outputs
### Assemblies 
Each MEGAHIT assembly generates a folder containing :

| File name          | Description                            | 
|--------------------|----------------------------------------|
| `final.contigs.fa` | Output FASTA file of assembled contigs |
| `log`              | Log file from MEGAHIT run              |

These are located in : 
- `~/Stage_Copenhague/assembly/sample_xx/` for individual assemblies
- `~/Stage_Copenhague/assembly/{GROUP}/` for co-assemblies

After renaming with `Anvi'o`, the contigs were saved in the same folders as : 

| File name pattern            | Description                                          | 
|------------------------------|------------------------------------------------------|
| `sample_xx_contigs_fixed.fa` | Renamed contigs from individual assembly (≥ 1000 bp) |
| `{GROUP}_contigs_fixed.fa`   | Renamed contigs from co-assembly (≥ 1000 bp)         |
| `name_conversions.txt`       | Mapping between old and new IDs                      |

### MetaQUAST reports 
Each assembly (individual or co-) was evaluated using metaquast. The resulting reports are stored on the **Thoth** server in : 
- Single-assemblies : 
  - `~/Stage_Copenhague/assembly/sample_xx/metaquast_results/`
- Co-assemblies :
  - `~/Stage_Copenhague/assembly/{GROUP}/metaquast_results/`

All metaQUAST reports are also available in this GitHub repository by following this link : [Index for HTML reports](https://alexisbarrere.github.io/shotgun_metagenomics_workflow_Alexis_Barrere/)  


Each report contains : 
 
| File name              | Description                                                | 
|------------------------|------------------------------------------------------------|
| `report.txt`           | Main summary of assembly metrics (N50, total length, etc.) |
| `report.tsv`           | Tabulated version for integration into spreadsheets        |
| `report.html` / `.pdf` | Interactive and printable reports with plots and graphs    |  

⭢ Other auxiliary files (e.g., `.log`, `.tex`, `transposed_*`, `icarus.html`) were generated but not used in the main analysis.

---
## Execution 
The assembly workflow was performed in four main phases : (i) individual assemblies and (ii) co-assemblies using `MEGAHIT`, (iii) contig renaming and filtering, and (iv) quality assessment using `MetaQUAST`.

### (i) Individual assemblies
**Objective :** To reconstruct contigs separately for each sample, based on decontaminated and cleaned reads.
1. A test assembly was first carried out on sample 01 using : 
```bash
assembly_sample_01.sh
``` 
⭢ The `meta-sensitive` preset was applied to sample 01. 

2. The remaining samples (02 to 24) were assembled in parallel using : 
```bash
parallel_assembly.sh
```
⭢ Assemblies were performed using the `meta-large` preset of `MEGAHIT`, which was specifically designed for large and complex metagenomes, such as those encountered in soil environments. It relies on a targeted range of longer k-mers, optimized to improve the assembly of diverse microbial communities while reducing chimeric contigs. Sample 01 was reassembled with the `meta-large` parameter.   
Assemblies were stored in `~/Stage_Copenhague/assembly/sample_xx/`, each containing the `final.contigs.fa` file and `MEGAHIT` logs.

### (ii) Co-assemblies
**Objective :** To generate representative contig assemblies from groups of four samples sharing the same sampling time and fertilization condition.
Six groups were defined in [`coassembly_groups.tsv`](coassembly_groups.tsv), and co-assemblies were generated in parallel using :
```bash
parallel_coassembly.sh
```
⭢ `MEGAHIT` was run using the `meta-large` preset with 16 threads. Each co-assembly was saved in a separate folder under `~/Stage_Copenhague/assembly/{GROUP}/`.

### (iii) Renaming and filtering contigs
**Objective :** To standardize contig headers and filter out sequences shorter than 1000 bp.

1. For individual assemblies :
```bash
renaming_contigs.sh
```
2. For co-assemblies :
```bash
renaming_contigs_coassembly.sh
```
⭢ The `anvi-script-reformat-fasta` utility from `Anvi’o` was used with the options `--simplify-names` `--min-len 1000`, and a report of ID changes was generated for traceability (`name_conversions.txt`).

_**Example of contig name simplification :**_ we go from `k141_162070 flag=1 multi=1.0000 len=1356` to `sample_01_contig_000000000001`. 

### (iv) Quality assessment
**Objective :** To assess the quality of the assemblies using `MetaQUAST` metrics.
1. MetaQUAST was first run on samples 01 to 24 with the following contig length thresholds :
```yaml
1000, 5000, 10000, 25000
```
2. It was then relaunched on a subset of samples (10, 17, 18, 20-24) using finer thresholds adapted to their length distributions :
```yaml
1000, 1200, 1679, 2500, 5000, 10000, 25000
```

Commands were executed via : 
```bash
quast_all_samples.sh
```

3. For the co-assemblies, quality reports were generated using :
```bash
metaquast_coassembly.sh
```
All results were saved in `~/Stage_Copenhague/assembly/sample_xx/metaquast_results/` or `~/Stage_Copenhague/assembly/{GROUP}/metaquast_results/`. Key metrics were extracted from report.txt, and summary visuals were available via the HTML reports.

---
## Parameters
### MEGAHIT
*Documentation : [Megahit Documentation](https://www.metagenomics.wiki/tools/assembly/megahit)*

Assemblies were performed using two different presets of MEGAHIT during the project :

- `meta-large`_*(used for all final assemblies)*_
```bash
--min-count 2 --k-list 27,37,47,57,67,77,87
```
This preset is specifically optimized for **complex and large/diverse metagenomes**, such as those found in **soil environments**. It uses **longer k-mers** with moderate step sizes, which enhances specificity, reduces the formation of chimeric contigs, and improves contig assembly in samples with **high microbial richness**.

This preset was applied to :
- All **co-assemblies** (6 groups of 4 samples)
- All **individual samples** (01 to 24) in the final version of the pipeline

- `meta-sensitive` _**(used only for testing sample_01)**_
```bash
--min-count 2 --k-list 21,31,41,51,61,71,81,91,99
```
This preset offers higher sensitivity, aiming to recover contigs from **low-abundance organisms**. It uses smaller and more numerous k-mers, making it more permissive but also slower and potentially more error-prone in complex metagenomes.

It was initially tested on sample_01, but later replaced by the `meta-large` preset to ensure consistency and robustness across all samples.

- Common options used : 
  - `--min-contig-len 1000`  
  ⭢ Contigs shorter than 1000 bp were excluded from the final output.
  - `-t 8` or `-t 16`  
  ⭢ Number of threads depending on the script and parallelization level.

### MetaQUAST
_Documentation : [MetaQUAST documentation](https://quast.sourceforge.net/docs/manual.html)_

MetaQUAST was used to evaluate assembly quality, particularly contig length distributions and N50 statistics.

#### Parameters used : 
**First run (samples 01 to 24) :**
```bash
--min-contig 1000 --thresholds 1000,5000,10000,25000
```
**Second run (samples 10, 17, 18, 20-24) :**
```bash
--min-contig 1000 --thresholds 1000,1200,1679,2500,5000,10000,25000
```
The second run used finer thresholds tailored to the contig length distributions of selected samples, in order to better interpret their assembly profiles.

---
## Notes
- The scripts use `GNU Parallel` to process multiple samples or groups simultaneously.  
- All scripts use relative paths anchored to `~/Stage_Copenhague`.





































