This file describes the installation steps for several software tools used during the internship,  
notably the installation of **Conda**, a popular environment manager, as well as multiple bioinformatics tools and dependencies.

It includes detailed procedures for setting up key components (such as **MetaWRAP** and the **CheckM database** for instance), ensuring full reproducibility of the computational environment on the Thoth server.

# I - Conda installation procedure performed on the server
## 1. Download the Miniconda installer (Linux version, for 64-bit)

```bash
cd ~ 
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh 
```

## 2. Start installation
```bash
Miniconda3-latest-Linux-x86_64.sh
```

**During the installation step :** 
- Accept the default options (`Enter`)
- `"Do you wish the installer to initialize Miniconda3 by running conda init? [yes]"` ⭢ Answer `yes` to this question

## 3. Activate Conda in the current session

Run this command :

```bash
eval "$(/home/alexis/miniconda3/bin/conda shell.bash hook)"
```

## 4. Activate Conda in future sessions 

Run this command :

```bash
conda init
```

⭢ This modified the `~/.bashrc` file so that Conda is automatically activated in all the future sessions.

## 5. Create the environment for a stage of the project

To create the environment from the appropriate YAML file in the `envs` folder of the GitHub repository (refer to the README for each step) :

```bash
conda env create -f envs/your_environment.yml 
```
To activate the created environment :
```bash
conda activate your_environement
```  

---

# II - Installation of MetaWRAP and CheckM database (Step 5)
## 1. Install Mamba in the Conda base environment (recommended for speed)
```bash
conda install -y mamba -n base -c conda-forge
```

## 2. Clone the MetaWRAP GitHub repository
```bash 
cd ~
git clone https://github.com/bxlab/metaWRAP.git
```

## 3. Add MetaWRAP to the PATH
To make the MetaWRAP executables available from anywhere in the terminal, edit the `~/.bashrc` file and add the following line at the end :
```bash
export PATH=$HOME/metaWRAP/bin:$PATH
```
Then save and exit (`Ctrl + O`, then `Ctrl + X`), and apply the changes with :
```bash
source ~/.bashrc
```

## 4. Create the conda environment for MetaWRAP
```bash
mamba create -y -n metawrap_env python=2.7
conda activate metawrap_env
```

## 5. Install all MetaWRAP dependencies
```bash
conda config --add channels defaults
conda config --add channels conda-forge
conda config --add channels bioconda
conda config --add channels ursky

mamba install --only-deps -c ursky metawrap-mg
```
This will install the following tools (among others) into the `metawrap_env` conda environment :

- MetaBAT2

- MaxBin2

- CONCOCT

- CheckM (without the database)

- BWA, Bowtie2, Samtools...

## 6. Install the CheckM database (required for the `bin_refinement` module)
Follow the [official MetaWRAP instructions](https://github.com/bxlab/metaWRAP/blob/master/installation/database_installation.md) to install the 2015 version (2015_01_16) of the CheckM database :
```bash
mkdir -p ~/Stage_Copenhague/databases/checkm_db
cd ~/Stage_Copenhague/databases/checkm_db

wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz
tar -xvf checkm_data_2015_01_16.tar.gz
rm checkm_data_2015_01_16.tar.gz
```
Finally, register this path as the default CheckM data directory :
```bash
checkm data setRoot
```
When prompted, enter :
```bash
~/Stage_Copenhague/databases/checkm_db/
```

--- 

# III - Additional databases for Anvi’o annotation (Step 6)

The following steps are required only once before running the Step 6 scripts.

## 1. Install COG 2020 database
```bash
# Create the folder containing the COG20 database
mkdir -p ~/anvio_cogs/COG20/RAW_DATA_FROM_NCBI

cd ~/anvio_cogs/COG20/RAW_DATA_FROM_NCBI

# Download the necessary data
curl -O https://ftp.ncbi.nih.gov/pub/COG/COG2020/data/checksums.md5.txt
curl -O https://ftp.ncbi.nih.gov/pub/COG/COG2020/data/cog-20.def.tab
curl -O https://ftp.ncbi.nih.gov/pub/COG/COG2020/data/fun-20.tab
curl -O https://ftp.ncbi.nih.gov/pub/COG/COG2020/data/cog-20.cog.csv
curl -O https://ftp.ncbi.nih.gov/pub/COG/COG2020/data/cog-20.fa.gz

# Rename the following file to be compatible with Anvi'o 
mv checksums.md5.txt checksum.md5.txt

cd

conda activate anvio8_env

# Download and setup NCBI's Clusters of Orthologous Groups database
anvi-setup-ncbi-cogs --cog-data-dir ~/anvio_cogs --just-do-it -T 4
# This creates the necessary files in ~/anvio_cogs/COG20/ : 
# - COG.txt, CATEGORIES.txt, PID-TO-CID.cPickle
# - DIAMOND and BLAST database
```
⭢ Downloads and configures the COG 2020 database for use with `anvi-run-ncbi-cogs`.

## 2. Install Centrifuge and its database
First, install Centrifuge in its dedicated environment :
```bash
# Installing Centrifuge via conda (for taxonomic annotation)
conda create -n centrifuge_env centrifuge -c bioconda -c conda-forge

conda activate centrifuge_env
```
Download the prebuilt **p_compressed+h+v** centrifuge database :
```bash
mkdir -p ~/Stage_Copenhague/databases/centrifuge_db
cd ~/Stage_Copenhague/databases/centrifuge_db

# Download the following index on the centrifuge homepage : Bacteria, Archaea, Viruses, Human (compressed) 5.4 GB
wget https://genome-idx.s3.amazonaws.com/centrifuge/p_compressed%2Bh%2Bv.tar.gz

tar -xzvf p_compressed+h+v.tar.gz

rm p_compressed+h+v.tar.gz
```

## 3. Configure SCG taxonomy database
```bash
anvi-setup-scg-taxonomy
```
⭢ Acording to the `Anvi'o` documentation, the purpose of the [anvi-setup-scg-taxonomy](https://anvio.org/help/main/programs/anvi-setup-scg-taxonomy/) program is to download necessary information from [GTDB](https://gtdb.ecogenomic.org/), and set it up in such a way that your `Anvi'o` installation is able to assign taxonomy to **single-copy core genes** (SCGs) using `anvi-run-scg-taxonomy` and estimate taxonomy for genomes or metagenomes using `anvi-estimate-scg-taxonomy`.

---
      
# IV - Installing Anvi'o on Windows via WSL Ubuntu
This section explains how I installed and ran `Anvi'o` on a Windows system using the **Windows Subsystem for Linux (WSL)** with Ubuntu, following the [official Anvi'o Windows installation tutorial](https://anvio.org/install/windows/stable/).  
This method allowed full compatibility with the Linux-based bioinformatics workflows while working directly on a Windows computer.

## 1. Install WSL and Ubuntu

1. Open **Windows PowerShell** as Administrator and run :
   ```powershell
   wsl --install
   ```
   This will :
   - Install the latest version of WSL (e.g., 2.5.9)
   - Download and install the default Linux distribution (**Ubuntu**)

2. When prompted :
   - Create your default Unix user account (example: `alexis`)
   - Set your password

3. To start Ubuntu from PowerShell (Admin mode), run :
   ```powershell
   wsl.exe -d Ubuntu
   ```
   or more simply :
   ```powershell
   wsl
   ```

4. **Path conventions in WSL** :
   - Windows files are accessible under `/mnt/c/Users/<windows_username>/`
        - Example : `"/mnt/c/Users/alexi/Documents/..."`
   - Your Linux home directory is `/home/alexis`, or `/home/<your_chosen_username>`

---

## 2. Install Conda inside WSL Ubuntu
Follow the **same procedure** as described in **Section I** of this document ("Conda installation procedure performed on the server"), but execute the commands **inside the Ubuntu terminal launched via WSL**.

---

## 3. Install Anvi'o in WSL
*I followed the [Anvi'o installation tutorial on Windows](https://anvio.org/install/windows/stable/)*  
Once Conda is installed in WSL Ubuntu :

1. To create the `Anvi'o` environment :
   ```bash
   conda create -y --name anvio-8 python=3.10
   ```

2. Activate the environment :
   ```bash
   conda activate anvio-8
   ```

3. Install all conda packages that `Anvi'o` will need to work properly :
   ```bash
   conda install -y -c conda-forge -c bioconda python=3.10 \
        sqlite=3.46 prodigal idba mcl muscle=3.8.1551 famsa hmmer diamond \
        blast megahit spades bowtie2 bwa graphviz "samtools>=1.9" \
        trimal iqtree trnascan-se fasttree vmatch r-base r-tidyverse \
        r-optparse r-stringi r-magrittr bioconductor-qvalue meme ghostscript \
        nodejs=20.12.2
        
   # try this, if it doesn't install :
   conda install -y -c bioconda fastani
    ```    

4. Install `Anvi'o` :
```bash
# First, download the python source package for the official Anvi'o release : 
curl -L https://github.com/merenlab/anvio/releases/download/v8/anvio-8.tar.gz \
        --output anvio-8.tar.gz

# And install it using pip : 
pip install anvio-8.tar.gz
```

--- 

# V - Configure an SSH connection between the local WSL session and the Thoth server

## 1. Add the Thoth server to the list of IPs (name resolution)  
1. View the server's IP adress by running this command on your server session :
```bash
hostname -I
```
2. Open `/etc/hosts` in your WSL (**Ubuntu**) session with the command :
```bash
sudo nano /etc/hosts
```

3. Add this line after the other IP addresses in the file :
```bash
<server_IP_address> thoth
```
⭢ This means : "when I type **thoth**, understand that it is the IP address <server_IP_address>"  

_**N.B. :** For obvious security reasons, the server's IP address is not listed in this GitHub repository._

After this step, I was able to connect to my session on the server (connected by Ethernet of course) by running :
```bash
ssh alexis@thoth
```

## 2. Configure passwordless access to the server by generating an SSH key
Some scripts in Step 8 will require **passwordless access** to the **Thoth** server. This avoids manually entering the password for each `ssh` or `scp` command.

### 2.1 Generate an SSH key in the WSL session
Run in your **WSL Ubuntu** terminal :
```bash
ssh-keygen -t ed25519 -C "<ssh_key_comment>"
```
Replace `<ssh_key_comment>` with a short description of the machine generating the key, for example:  
`laptop_WSL`, `workstation_lab`, or `server_backup`.

Example output (anonymized) :
```
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/<user>/.ssh/id_ed25519):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/<user>/.ssh/id_ed25519
Your public key has been saved in /home/<user>/.ssh/id_ed25519.pub
The key fingerprint is:
SHA256:************************************ <ssh_key_comment>
The key's randomart image is:
+--[ED25519 256]--+
|   . o + X *     |
|  . = * O B .    |
|   . * O o .     |
|    o = o        |
|     . o         |
|                 |
|                 |
|                 |
|                 |
+----[SHA256]-----+
```
> **Tip :** Just press **Enter** at the "Enter passphrase" prompts to make the connection fully passwordless.

---

### 2.2 Send the public key to the Thoth server
Copy the public key to the server :
```bash
ssh-copy-id <username>@thoth
```
You will be prompted for your password **one last time**. This command appends your public key to the server’s `~/.ssh/authorized_keys` file.

---

### 2.3 Test the connection
```bash
ssh <username>@thoth
```
If you are connected without entering a password, the setup is complete.

---

You can now use `ssh`, `scp`, or automated scripts to transfer data between your **WSL Ubuntu** session and the **Thoth** server without entering your password each time.

