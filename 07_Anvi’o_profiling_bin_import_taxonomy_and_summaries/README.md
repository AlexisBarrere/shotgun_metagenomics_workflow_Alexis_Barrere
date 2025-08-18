# Step 7 - Anvi'o profiling, bin import & taxonomy

This step consisted in generating `Anvi'o` **profile databases** from mapped reads (single assemblies and co-assemblies), importing refined bins as **collections**, assigning **SCG-based taxonomy**, and producing **summary reports** for downstream analyses.

> ⚠️ This step assumes that (i) **mapping** (Step 4) and (ii) **contigs database creation & annotation** (Step 6) are already completed.  
> Paths and file names below follow the project structure set in previous steps.

---

## Environment & Software Versions
All commands were executed on the Thoth server running : Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-126-generic x86_64).

The tools used during this step are managed via a Conda environment defined in : [`envs/anvio8_env.yml`](../envs/anvio8_env.yml)

| Tool       | Version | Installation method |
|------------|---------|---------------------|
| Anvi'o     | 8.0     | Conda (`bioconda`)  |


### Environment creation
To recreate the environment from the root of the repository :
```bash
# Anvi'o environment
conda env create -f envs/anvio8_env.yml
conda activate anvio8_env
```
---

## Scripts

- [`latest_analyses_all_samples.sh`](latest_analyses_all_samples.sh)  
⭢ For **single assemblies** (samples 01-24) :  
  1. Runs `anvi-profile` on each BAM file.  
  2. Imports MetaWRAP refined bins as a collection (dots in bin names replaced by underscores).  
  3. Runs `anvi-estimate-scg-taxonomy` on the collection.  
  4. Runs `anvi-summarize` to produce summary reports (with amino acid sequences).

- [`step_05_coassemblies.sh`](step_05_coassemblies.sh)  
⭢ For **co-assemblies**:  
  Runs `anvi-profile` for each of the 4 samples in a group (min contig length 1000).

- [`step_05_bis_coassemblies.sh`](step_05_bis_coassemblies.sh)  
⭢ Merges the 4 per-sample profile databases of a co-assembly group into a single multi-profile DB using `anvi-merge` (Hierarchical Clustering skipped).

- [`steps_06_to_08_coassemblies.sh`](steps_06_to_08_coassemblies.sh)  
⭢ For **co-assemblies** after merge :  
  1. Formats and imports `MetaWRAP` refined bins as a collection (random RGB colors assigned).  
  2. Runs `anvi-estimate-scg-taxonomy` on the collection.  
  3. Runs `anvi-summarize` to produce summary reports (with amino acid sequences).

---

## Inputs

### Single assemblies
- BAM files :  
  `~/Stage_Copenhague/mapping/sample_xx/sam_and_bam/sample_xx.bam`
- Contigs DB :  
  `~/Stage_Copenhague/anvio_db/anvio_contigs_db/sample_xx_contigs_copy.db`
- MetaWRAP refined bins :  
  `~/Stage_Copenhague/binning/sample_xx/bin_refinement/metawrap_1_1000_bins.contigs/`

### Co-assemblies
- BAM files :  
  `~/Stage_Copenhague/mapping/{GROUP}/sam_and_bam/sample_xx.bam`
- Contigs DB :  
  `~/Stage_Copenhague/anvio_db/anvio_contigs_db/{GROUP}_contigs_copy.db`
- MetaWRAP refined bins :  
  `~/Stage_Copenhague/binning/{GROUP}/bin_refinement/metawrap_1_1000_bins.contigs/`

---

## Outputs

### Profile databases
- Single assemblies :  
  `~/Stage_Copenhague/anvio_db/anvio_single_profile_db/sample_xx/PROFILE.db`
- Co-assemblies (per-sample) :  
  `~/Stage_Copenhague/anvio_db/anvio_multi_profile_db/sample_xx/PROFILE.db`
- Co-assemblies (merged) :  
  `~/Stage_Copenhague/anvio_db/anvio_multi_profile_db/{GROUP}_merged_profile/PROFILE.db`

### Collections
- Files associating contigs with bins :
  - Single assemblies : `~/Stage_Copenhague/anvio_collections/sample_xx_bins.txt`
  - Co-assemblies : `~/Stage_Copenhague/anvio_collections/{GROUP}/{GROUP}_bins.txt` 
- File assigning the source and a color to each bin in a collection (co-assemblies only) :  
  `~/Stage_Copenhague/anvio_collections/{GROUP}/{GROUP}_bins_info.txt`

### SCG-based taxonomy
- Single assemblies:  
  `~/Stage_Copenhague/anvio_collections/sample_xx_scg_taxonomy.txt`
- Co-assemblies:  
  `~/Stage_Copenhague/anvio_collections/{GROUP}/{GROUP}_scg_taxonomy.txt`

### Summaries
- Single assemblies :  
  `~/Stage_Copenhague/anvio_summary/sample_xx_summary/`
- Co-assemblies :  
  `~/Stage_Copenhague/anvio_summary/{GROUP}_summary/`

### Logs
- Single assemblies:  
  `~/Stage_Copenhague/logs/step_05_to_08/sample_XX_latest_analyses.log`
- Co-assemblies:  
  `~/Stage_Copenhague/logs/step_05_to_08_coassemblies/{GROUP}_latest_analyses_step{STEP_NUMBER}.log`

---

## Execution

### Single assemblies
```bash
latest_analyses_all_samples.sh
```
This will process all 24 samples in parallel (`-j 4`), generating profiles, collections, taxonomy, and summaries.

### Co-assemblies
```bash
step_05_coassemblies.sh
step_05_bis_coassemblies.sh
steps_06_to_08_coassemblies.sh
```
These scripts process each group sequentially :  
1. Create per-sample profiles (`step_05_coassemblies.sh`)  
2. Merge into a group multi-profile DB (`step_05_bis_coassemblies.sh`)  
3. Import bins, assign taxonomy to the bins (based on SCGs), and summarize (`steps_06_to_08_coassemblies.sh`)

---

## Parameters

### anvi-profile *([documentation](https://anvio.org/help/main/programs/anvi-profile/))* 
- `-i` : BAM file  
- `-c` : contigs DB  
- `--min-contig-length` : keep only contigs whose size is greater than the specified value : 2000 (single assemblies) / 1000 (co-assemblies)  
- `--sample-name` : label in profile DB  
- `--output-dir` : profile output directory  
- `--force-overwrite` : allows the command to replace (overwrite) previous results if any   
- `-T` : threads (4 for single assemblies, 8 for co-assemblies)
- `--cluster-contigs` : performs contig binning directly on `Anvi'o`. Useful for viewing each single assembly via `anvi-interactive` without specifying a collection. Enabled for single assemblies only


### anvi-merge *only for co-assemblies* *([documentation](https://anvio.org/help/main/programs/anvi-merge/))* 
- Inputs : per-sample PROFILE.db files (4 per coassembly group)  
- `-c` : contigs database (DB)  
- `-o` : merged output directory  
- `-S` : merged profile name  
- `--skip-hierarchical-clustering` : skip contig clustering

### anvi-import-collection *([documentation](https://anvio.org/help/main/programs/anvi-import-collection/))*
- Input : collection file (`*_bins.txt`)
- `-c` : contigs DB
- `-p` : profile DB
- `-C` : specifies a name for the bin collection 
- `--contigs-mode` : import bins as contig-level (not split-level) collection  
- `--bins-info` : information file (source & RGB colors - *co-assemblies only*)

### anvi-estimate-scg-taxonomy *([documentation](https://anvio.org/help/main/programs/anvi-estimate-scg-taxonomy/))*
This command assigns bin taxonomy based on SCG sets.
- `-c` : contigs DB
- `-p` : profile DB
- `-C` : specifies the name for the bin collection
- `-o` : output directory  

### anvi-summarize *([documentation](https://anvio.org/help/main/programs/anvi-summarize/))*
This command generates HTML & tabular summaries.
- `-c` : contigs DB
- `-p` : profile DB
- `-C` : specifies the name for the bin collection
- `-o` : output directory
- `--report-aa-seqs-for-gene-calls` : display the amino acid sequences for the gene calls. 

---

## Notes
- All bin names are reformatted (dots replaced by underscores) before import into `Anvi'o` so that they are compatible and detected by `Anvi'o`.
- Co-assemblies use an additional color table to improve visualization in the interactive interface.
- Scripts use `GNU Parallel` to process multiple samples/groups at once, with separate log files per sample/group.
- Scripts use relative paths from `~/Stage_Copenhague`.
