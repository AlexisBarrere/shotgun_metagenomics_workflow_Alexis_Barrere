# Step 8 - Anvi'o preparation and manual curation of Archaeal bins
In this step, I prepared Archaeal (and Verrucomicrobiota) **bin collections**, regenerated **Anvi'o summaries**, **transferred** the reports to my local WSL environment, then **launched manual curation** in Anvi'o's interactive tools.

> ⚠️ This step assumes that (i) **mapping** (Step 4), (ii) **contigs database creation & annotations** (Step 6), and (iii) **profiling / bin import / taxonomy & summaries** (Step 7) were already completed.  
> Paths and file names below follow the project structure defined in previous steps.

---

## Environment & Software Versions
All commands were executed on the **Thoth** server (Ubuntu 22.04.5 LTS, GNU/Linux 5.15.0-126-generic x86_64) and on my **local WSL Ubuntu session** (on my local computer).

The tools used during this step are managed via 2 Conda environments :
- [`envs/anvio8_env.yml`](../envs/anvio8_env.yml) _conda environment with `Anvi'o` on the Thoth server_
- [`envs/anvio-8.yml`](../envs/anvio-8.yml) _conda environment with `Anvi'o` on my local WSL Ubuntu session_

| Tool         | Version | Installation method |
|--------------|---------|---------------------|
| Anvi'o       | 8.0     | Conda (`bioconda`)  |

### Environment creation
From the repository root :
```bash
# When the script were executed on the Thoth server : 
conda env create -f envs/anvio8_env.yml
conda activate anvio8_env

# When the script where executed on my local WSL Ubuntu session :
conda env create -f envs/anvio-8.yml
conda activate anvio-8.yml
```

## Scripts

### Create Archaea/Verrucomicrobiota collections (samples & co-assemblies)
- [`Archaea_and_directories_all_samples.sh`](Archaea_and_directories_all_samples.sh)  
- [`Archaea_and_directories_all_coassemblies.sh`](Archaea_and_directories_all_coassemblies.sh)  
  ⭢ Scripts that create collections with only **Archean** bins, then create a summary via `anvi-summarize`.

- [`Verrucomicrobiota_collections_all_samples.sh`](Verrucomicrobiota_collections_all_samples.sh)  
- [`Verrucomicrobiota_collections_all_coassemblies.sh`](Verrucomicrobiota_collections_all_coassemblies.sh)  
  ⭢ These scripts do the same as those described before but to create a collection with the phylum **Verrucomicrobiota** (when present).

### Create MAG collections
- [`create_MAGs_collections_all_samples.sh`](create_MAGs_collections_all_samples.sh)  
- [`create_MAGs_collections_all_co-assemblies.sh`](create_MAGs_collections_all_co-assemblies.sh)  
  ⭢ Create collections of MAGs (bins with a completion > 50%) for each single-assembly and co-assembly, only for **Archean** bins. Scripts executed on **Thoth** server.

### Regenerate summaries
- [`anvi_summarize_V2_and_MAGs_all_samples.sh`](anvi_summarize_V2_and_MAGs_all_samples.sh)  
- [`anvi_summarize_V2_and_MAGs_all_coassemblies.sh`](anvi_summarize_V2_and_MAGs_all_coassemblies.sh)  
  ⭢ I re-ran **`anvi-summarize`** for Archaeal (V2) collections and for MAGs (samples & co-assemblies). Scripts executed on **Thoth** server.

### Transfer summaries to WSL
- [`transfer_summaries_all_samples.sh`](transfer_summaries_all_samples.sh)  
- [`transfer_summaries_all_coassemblies.sh`](transfer_summaries_all_coassemblies.sh)  
  ⭢ I transferred the generated summaries from **Thoth ⭢ WSL** for local inspection.

---

## Inputs (from Thoth server)

### Databases from Step 7
- **Single assemblies**  
  - Profile DB : `~/Stage_Copenhague/anvio_db/anvio_single_profile_db/sample_xx/PROFILE.db`
  - Auxiliary data : `~/Stage_Copenhague/anvio_db/anvio_single_profile_db/sample_xx/AUXILIARY-DATA.db`  
  - Contigs DB : `~/Stage_Copenhague/anvio_db/anvio_contigs_db/sample_xx_contigs_copy.db`
  - Initial bins summary : `~/Stage_Copenhague/anvio_summary/sample_xx_summary/bins_summary.txt`

- **Co-assemblies**  
  - Merged profile DB : `~/Stage_Copenhague/anvio_db/anvio_multi_profile_db/{GROUP}_merged_profile/PROFILE.db`
  - Auxiliary data : `~/Stage_Copenhague/anvio_db/anvio_multi_profile_db/{GROUP}_merged_profile/AUXILIARY-DATA.db`  
  - Contigs DB: `~/Stage_Copenhague/anvio_db/anvio_contigs_db/{GROUP}_contigs_copy.db`
  - Initial bins summary : `~/Stage_Copenhague/anvio_summary/{GROUP}_summary/bins_summary.txt`

  --- 

## Outputs

### Collections (server)
- Initial collections (single & co-assemblies) :
  - `~/Stage_Copenhague/visualisation_anvio/sample_xx/sample_xx_collections/metawrap_bins_sample_xx_single_assembly.txt`
  - `~/Stage_Copenhague/visualisation_anvio/{GROUP}/{GROUP}_collections/metawrap_bins_{GROUP}_coassembly.txt`
- Archaeal collections (single & co-assemblies):  
  - `~/Stage_Copenhague/visualisation_anvio/sample_xx/sample_xx_collections/metawrap_bins_sample_xx_single_assembly_Archaea_V1.txt`
  - `~/Stage_Copenhague/visualisation_anvio/{GROUP}/{GROUP}_collections/metawrap_bins_{GROUP}_coassembly_Archaea_V1.txt`
- Verrucomicrobiota collections (when present) :  
  - `~/Stage_Copenhague/visualisation_anvio/sample_xx/sample_xx_collections/metawrap_bins_sample_xx_single_assembly_Verrucomicrobiota.txt`
  - `~/Stage_Copenhague/visualisation_anvio/{GROUP}/{GROUP}_collections/metawrap_bins_{GROUP}_coassembly_Verrucomicrobiota.txt`
- The other collections (the V2 version of the Archaea collection which contains the bins after curation, and the MAGs collection) are present in the folder generated by `anvi-summarize` (see below), you can still view them from each `PROFILE.db` by running the following command : `anvi-show-collections-and-bins -p PROFILE.db`

### Summaries (server)
- Archeal (V1) summaries & tables : 
  - `~/Stage_Copenhague/visualisation_anvio/sample_xx/anvi_summarize/sample_xx_Archaea_V1_summarize/`
  - `~/Stage_Copenhague/visualisation_anvio/{GROUP}/anvi_summarize/{GROUP}_Archaea_V1_summarize/`
- Archaeal (V2) summaries & tables :  
  - `~/Stage_Copenhague/visualisation_anvio/sample_xx/anvi_summarize/sample_xx_Archaea_V2_summarize/`
  - `~/Stage_Copenhague/visualisation_anvio/{GROUP}/anvi_summarize/{GROUP}_Archaea_V2_summarize/`
- MAG summaries & tables:  
  - `~/Stage_Copenhague/visualisation_anvio/sample_xx/anvi_summarize/sample_xx_MAGs_summarize/`
  - `~/Stage_Copenhague/visualisation_anvio/{GROUP}/anvi_summarize/{GROUP}_MAGs_summarize/`
- Verrucomicrobiota summaries & tables (when present) :
  - `~/Stage_Copenhague/visualisation_anvio/sample_xx/anvi_summarize/sample_xx_Verrucomicrobiota_summarize/`
  - `~/Stage_Copenhague/visualisation_anvio/{GROUP}/anvi_summarize/{GROUP}_Verrucomicrobiota_summarize/`  

### Transferred summaries (local WSL)
- The summaries were transferred to my local WSL session for review (same paths)  

---

## Execution

I ran the scripts in the following order :

### Archaeal / Verrucomicrobiota collections
The following scripts were run on the **local WSL Ubuntu** session. They copy the necessary data (`PROFILE.db`, `AUXILIARY-DATA.db`, `*_contigs_copy.db` and `bins_summary.txt`) from the `C:\Users\alexi\Documents\Cours\Stage Copenhague 2025\Stage 2025\Anvi_summarize` folder located in my Windows session, to the dedicated folder on my local WSL Ubuntu session (`~/Stage_Copenhage/visualisation_anvio/sample_$i/input_files/` for single assemblies, `~/Stage_Copenhage/visualisation_anvio/$GROUP/input_files/` for co-assemblies). Then they export the **initial collection** containing all bins, extract the **Archaean** or **Verrucomicrobiota** (when present) bins, create a collection with the **Archaean** or **Verrucomicrobiota** bins of each single assembly or co-assembly, import this collection into the associated `PROFILE.db` (in two versions for Archean bins : V1 to keep an original version of the collection, V2 which was modified during the manual curation of the bins on `Anvi'o`), and then produce a summary.
```bash
# Archaea
bash Archaea_and_directories_all_samples.sh
bash Archaea_and_directories_all_coassemblies.sh

# Verrucomicrobiota
bash Verrucomicrobiota_collections_all_samples.sh
bash Verrucomicrobiota_collections_all_coassemblies.sh
```

### Manual curation of bins
Looking at the initial bin collection summary produced by the `anvi-summarize` command, I could see which bins deserved manual correction, the goal being to achieve greater than **50% completion**, and less than **10% redundancy**

**Example of the steps for curating a bin (bin_13) on Anvi'o for the T7_N1K1 group :**
#### **bin_13 :** 
- Initial completion : 93.42%
- Initial redundancy : 15.79%

I performed the manual curation of **bin_13** via the interactive interface provided by `Anvi'o`, allowing to visualize the contigs of a bin according to different parameters (sequence composition = tetranucleotide frequency & differential coverage for instance) and to exclude contigs that do not seem to belong to the bin :

```bash
# Set the working directory
cd ~/Stage_Copenhague/visualisation_anvio/T3_N1P2K2

# Start the anvi-refine command
anvi-refine -c input_files/T3_N1P2K2_contigs_copy.db -p input_files/PROFILE.db -C metawrap_bins_T3_N1P2K2_coassembly_Archaea_V2 -b bin_30
```

After the curation step :
- Completion : 92.1%
- Redundancy : 3.9%

Details of all other curated bins can be found in the benching document titled `Curation of bins`.

_**N.B :** After each command to view my data via the Anvi'o interface (`anvi-interactive` or `anvi-refine` for example), I had to type `http://localhost:8080` in my browser (preferably **Chrome**) to be able to open the `Anvi'o` graphical interface_

### MAG collections
 After performing manual bin curation on `Anvi'o` via `anvi-refine`, the `visualisation_anvio/` folder of my WSL session has been transferred to the **Thoth** server. 
The following scripts allowed me to create collections of MAGs by keeping, among all the archaeal bins of each single & co-assembly, only those with a completion > 50% and redundancy < 10% :
```bash
create_MAGs_collections_all_samples.sh
create_MAGs_collections_all_co-assemblies.sh
```

### Regenerate Anvi'o summaries (V2 + MAGs)
After creating the MAGs collection, I generated a summary for each Archaeal V2 collection (including manually curated bins as well as lower-quality ones) and for each MAGs collection (restricted to bins of at least medium quality) :
```bash
anvi_summarize_V2_and_MAGs_all_samples.sh
anvi_summarize_V2_and_MAGs_all_coassemblies.sh
```

### Transfer to WSL (passwordless SSH required, see section V - of the [installation.md](../installation.md) file)
At the end of this step, I transferred the generated summary files so that I could keep them locally on my Ubuntu WSL session :
```bash
transfer_summaries_all_samples.sh
transfer_summaries_all_coassemblies.sh
```

---

## Parameters
### anvi-show-collections-and-bins *([documentation](https://anvio.org/help/main/programs/anvi-show-collections-and-bins/))*
- `-p` : To specify the path to the PROFILE.db containing the collections to show

### anvi-export-collection *([documentation](https://anvio.org/help/7/programs/anvi-export-collection/))* 
- `-C` : To specify the name of the collection to export
- `-p` : To specify the path to the PROFILE.db containing the collection
- `-O` : To specify an output folder and a name for the file that will contain the exported collection

### anvi-import-collection *([documentation](https://anvio.org/help/main/programs/anvi-import-collection/))*
- Input : path of the file containing the collection to be imported
- `-c` : To specify the path to the contigs database  
- `-p` : To specify the path to the PROFILE.db containing the collection  
- `-C` : To specify the name of the collection to import  
- `--bins-info` (optional) : specifies the path of the file that assigns source & RGB colors to each bin

### anvi-summarize *([documentation](https://anvio.org/help/main/programs/anvi-summarize/))*
- `-c` : To specify the path to the contigs database  
- `-p` : To specify the path to the PROFILE.db containing the collection to be summarized   
- `-C` : To specify the name of the collection to be summarized    
- `-o` : To specify the name of the folder that will contain the collection summary  
- `--report-aa-seqs-for-gene-calls` : To display the amino acid sequences for the gene calls. 

### anvi-rename-bins *([documentation](https://anvio.org/help/main/programs/anvi-rename-bins/))*
- `-c` : To specify the path to the contig database containing the collection from which to extract MAGs
- `-p` : To specify the path to the PROFILE.db containing the collection from which to extract MAGs
- `--prefix` : Prefix to put in front of the name of the MAGs (I put the name of the sample from which the MAG comes for single assemblies, and the name of the coassembly group from which the MAG comes for co-assemblies)
- `--collection-to-read` : Name of the collection from which the MAGs are extracted
- `--collection-to-write` : Name of the new collection containing the MAGs
- `--report-file` : Specifies the path and name of the report file containing the old and new names of each MAG, the collection of single-copy core genes (SCGs) used to generate the completion/redundancy estimates, the percentage of completion and redundancy, and the size in Mbp of the MAG
- `--min-completion-for-MAG` : Specifies the minimum completion percentage that a bin must have to be considered a MAG and added to the MAG collection (here I chose **50** to have bins of at least average quality)
- `--call-MAGs` : This parameter allows to qualify bins with more than 50% completion and less than 10% redundancy of MAGs (after the prefix defined via `--prefix`)
- `--exclude-bins` : This parameter allows to exclude bins with less than 50% completion and more than 10% redundacy from the new MAG collection 

### Interactive curation
- `anvi-interactive -p PROFILE.db -c CONTIGS.db -C <collection_name>`  
  ⭢ To explore coverage, composition, and taxonomy layers in a specified collection of bins.

- `anvi-merge-bins -p PROFILE.db -C <collection_name> -b bin1,bin2 -B new_bin`  
  ⭢ To merge bins if we think it is necessary after inspection via anvi-interactive

- `anvi-refine -c CONTIGS.db -p PROFILE.db -C <collection_name> -b <bin>`  
  ⭢ To curate bins (moved/removal of contigs when necessary).

> I kept curation changes as **new collection(s)** rather than overwriting existing ones to preserve provenance.

### Transferring files or folders between the Thoth server and my local WSL Ubuntu session
After following section V of the [installation.md](../installation.md) file, I was able to use the following command to transfer data :
```bash
scp -r <path_of_the_folder_to_copy> <path_to_copy_the_folder_to>
```
- `-r` : allows you to copy an entire directory and its contents (files + subfolders) recursively

---

## Notes
- I **followed the WSL + Anvi'o** setup documented in [installation.md](../installation.md) - section IV to review summaries locally and run `anvi-interactive` from WSL (browser at `http://localhost:8080`).  
- I configured **passwordless SSH** (see [installation.md](../installation.md) - section V) to simplify transfers and remote launching of Anvi'o commands.  
- Scripts use relative paths from `~/Stage_Copenhague`.

