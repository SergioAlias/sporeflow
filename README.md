# <img src="./.img/sf_negative.png" width="500">

[![Snakemake](https://img.shields.io/badge/Snakemake-7.32.4-5442a6.svg)](https://snakemake.github.io)
[![QIIME 2](https://img.shields.io/badge/QIIME2-2024.2-e5b611.svg)](https://qiime2.org/)

🦠 **SporeFlow: Fungal ITS metataxonomics pipeline**

> 🧫 ***New feature incoming: 16S*** 🧫
> 
> *We are currently prioritizing the implementation of a 16S analysis option. This feature is under active development and will be completed soon.*

> ⚠️ ***Disclaimer*** ⚠️
> 
> *This workflow is still under active development. New functions and improvements may be added in the future.*

SporeFlow (**S**nakemake **P**ipeline F**or** M**e**tataxonomics Work**flow**s) is a pipeline for metataxonomic analysis of fungal ITS using [QIIME 2](https://qiime2.org/) and [Snakemake](https://snakemake.readthedocs.io/en/v7.32.2/). It takes into consideration all the particularities of the indel-rich ITS region.

What SporeFlow does:

- Run [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on the raw FASTQ files (rule `fastqc_before`)
- Run [Cutadapt](https://cutadapt.readthedocs.io/en/v4.6/) on the raw FASTQ files (rule `cutadapt`)
- Run [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on the trimmed FASTQ files (rule `fastqc_after`)
- Aggregate QC results (FastQC before trimming, Cutadapt, FastQC after trimming) with [MultiQC](https://multiqc.info/) (rule `multiqc`)
- Create manifest file for QIIME 2 (rule `create_manifest`)
- Import FASTQ files to QIIME 2 (rule `import_fastq`)
- Trim ITS sequences in QIIME 2 with [ITSxpress plugin](https://forum.qiime2.org/t/q2-itsxpress-a-tutorial-on-a-qiime-2-plugin-to-trim-its-sequences/5780) (rule `itsxpress`)
- Denoise, dereplicate, remove chimeras and merge sequences in QIIME 2 with [DADA2 plugin](https://docs.qiime2.org/2024.2/plugins/available/dada2/) (rule `dada2`)
- Perform taxonomic classification in QIIME 2 with [feature-classifier plugin](https://library.qiime2.org/plugins/q2-feature-classifier/3/) (rule `taxonomy`)
- Perform diversity analysis in QIIME 2 with [diversity plugin](https://docs.qiime2.org/2024.2/plugins/available/diversity/) (rule `diversity`)
- Perform differential abundance in QIIME 2 with [composition plugin](https://docs.qiime2.org/2024.2/plugins/available/composition/) (rule `abundance`)

There are some additional steps used for adapting results between main steps. We don't worry about those for now.

## Requisites

The only prerequisite is having Conda installed. In this regard, we **highly recommend** installing [Miniconda](https://docs.anaconda.com/free/miniconda/index.html) and then installing [Mamba](https://anaconda.org/conda-forge/mamba) (used by default by Snakemake) for a lightweight and fast experience.

## Usage

1. Clone the repository

2. Create a Screen (see section **Immediate submit and Screen**)

3. Run the following command to download (if needed) and activate the SporeFlow environment, and to set aliases for the main functions:
```bash
source init_sporeflow.sh
```

4. Edit `config/config.yml` with your experiment details. Variables annotated with #cluster# must also be updated in `config/cluster_config.yml`.

5. If needed, modify `time`, `ncpus` and `memory` variables in `config/cluster_config.yml`.

6. Download a UNITE classfier in QIIME 2 format from [https://github.com/colinbrislawn/unite-train/releases](https://github.com/colinbrislawn/unite-train/releases). We recommend using one of the following (remember to change the name accordingly in `config/config.yml`):
   - `unite_ver10_dynamic_all_04.04.2024-Q2-2024.2.qza`
   - `unite_ver10_99_all_04.04.2024-Q2-2024.2.qza`  

7. Run the following command to start the workflow:
```bash
sf_run
```

## Immediate submit and Screen

Sporeflow inlcudes a command, `sf_immediate`, that automatically sends all jobs to Slurm, correctly queued according to their dependencies. This is desirable e.g. when the runtime in the cluster login machine is very short, because it may kill Snakemake in the middle of the workflow. If your HPC queue system only allows a limited number of jobs submitted at once, change that number in `init_sporeflow.sh` and source it again (that also applies for `sf_run`).

Please note that if the number of simultaneous jobs accepted by the queue system is less than the total number of jobs you need to submit, the workflow will fail. For such cases, we highly recommend not using `sf_immediate`. Instead, use `sf_run` inside a Screen. Screen is a multiplexer that lets you create multiple virtual terminal sessions. It is installed by default in most Linux HPC systems.

To create a screen, use `screen -S sporeflow`. Then, follow usage section there. You can dettach the screen with `Ctrl+a` and then `d`. You can attach the screen again with `screen -r sporeflow`. For more details about Screen usage, please check [this Gist](https://gist.github.com/jctosta/af918e1618682638aa82).

## Drawing DAGs and rule graphs

Since Sporeflow is built over Snakemake, you can generate DAGs, rule graphs and file graphs of the workflow. We provide three commands for this: `sf_draw_dag`, `sf_draw_rulegraph` and `sf_draw_filegraph`.