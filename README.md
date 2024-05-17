# <img src="./.img/sf_negative.png" width="500">

🦠 **SporeFlow: Fungal ITS metataxonomics made easy**

> ⚠️ ***Disclaimer*** ⚠️
> 
> *This workflow is still under development, thus it can not be used for a complete metataxonomic experiment yet.*

SporeFlow (**S**nakemake **P**ipeline F**or** M**e**tataxonomics Work**flow**s) is a pipeline for metataxonomic analysis of fungal ITS using [QIIME2](https://qiime2.org/) and [Snakemake](https://snakemake.readthedocs.io/en/v7.32.2/). It takes into consideration all the particularities of the indel-rich ITS region and modifies the typical QIIME2 workflow (which with default settings usually works well in 16S) according to these particularities.

Steps working for now:

- Download database for taxonomic assignation in QIIME2 format with [RESCRIPt plugin](https://docs.qiime2.org/2024.2/plugins/available/rescript/) (rule `download_db`)
- Run [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on the raw FASTQ files (rule `fastqc_before`)
- Run [Cutadapt](https://cutadapt.readthedocs.io/en/v4.6/) on the raw FASTQ files (rule `cutadapt`)
- Run [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on the trimmed FASTQ files (rule `fastqc_after`)
- Aggregate QC results (FastQC before trimming, Cutadapt, FastQC after trimming) with [MultiQC](https://multiqc.info/) (rule `multiqc`)
- Create manifest file for QIIME2 (rule `create_manifest`)
- Import FASTQ files to QIIME2 (rule `import_fastq`)
- **(ITS analysis only)** Trim ITS sequences in QIIME2 with [ITSxpress plugin](https://forum.qiime2.org/t/q2-itsxpress-a-tutorial-on-a-qiime-2-plugin-to-trim-its-sequences/5780) (rule `itsxpress`)
- Denoise, dereplicate and cluster sequences in QIIME2 with [DADA2 plugin](https://docs.qiime2.org/2024.2/plugins/available/dada2/) (rule `dada2`)

## Requisites

The only prerequisite is having Conda installed. In this regard, we **highly recommend** installing [Miniconda](https://docs.anaconda.com/free/miniconda/index.html) and then installing [Mamba](https://anaconda.org/conda-forge/mamba) (used by default by Snakemake) for a lightweight and fast experience.

## Usage

1. Clone the repository
2. Run `source init_sporeflow.sh`
3. Edit `config/config.yml` with your experiment details. Variables annotated with #cluster# must also be updated in `config/cluster_config.yml`.
4. If needed, modify `time`, `ncpus` and `memory` variables in `config/cluster_config.yml`.
5. Run `sf_download_db` to download the database for taxonomic assignation.
6. Run `sf_run` to run the workflow.
   
## Immediate submit and Screen

Sporeflow inlcudes a command, `sf_immediate`, that automatically sends all jobs to Slurm, correctly queued according to their dependencies. This is desirable e.g. when the runtime in the cluster login machine is very short, because it may kill Snakemake in the middle of the workflow. If your HPC queue system only allows a limited number of jobs submitted at once, change that number in `init_sporeflow.sh` and source it again (that also applies for `sf_run`).

Please note that if the number of simultaneous jobs accepted by the queue system is less than the total number of jobs you need to submit, the workflow will fail. For such cases, we highly recommend not using `sf_immediate`. Instead, use `sf_run` inside a Screen. Screen is a multiplexer that lets you create multiple virtual terminal sessions. It is installed by default in most Linux HPC systems.

To create a screen, use `screen -S sporeflow`. Then, follow usage section there. You can dettach the screen with `Ctrl+a` and then `d`. You can attach the screen again with `screen -r sporeflow`. For more details about Screen usage, please check [this Gist](https://gist.github.com/jctosta/af918e1618682638aa82).

## Drawing DAGs and rule graphs

Since Sporeflow is built over Snakemake, you can generate DAGs, rule graphs and file graphs of the workflow. We provide three commands for this: `sf_draw_dag`, `sf_draw_rulegraph` and `sf_draw_filegraph`.