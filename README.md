# <img src="./.img/sf_negative.png" width="500">

[![Issues](https://img.shields.io/github/issues/SergioAlias/sporeflow?label=Issues)](https://github.com/SergioAlias/sporeflow/issues)
[![Snakemake](https://img.shields.io/badge/Snakemake-7.32.4-5442a6.svg)](https://snakemake.github.io)
[![QIIME 2](https://img.shields.io/badge/QIIME2-2024.2-e5b611.svg)](https://qiime2.org/)

> 🎉 **Exciting news!** 🎉 This workflow now supports the use of **Translation Elongation Factor 1 alpha (TEF1)** as a marker gene for the filamentous fungal genus ***Fusarium***.

🦠 **SporeFlow: 16S, ITS and TEF1 metataxonomics pipeline**

SporeFlow (**S**nakemake **P**ipeline F**or** M**e**tataxonomics Work**flow**s) is a pipeline for metataxonomic analysis of fungal ITS, *Fusarium* TEF1 and bacterial 16S using [QIIME 2](https://qiime2.org/) and [Snakemake](https://snakemake.readthedocs.io/en/v7.32.2/).

More information on the use of TEF1 for *Fusarium* can be found in [https://github.com/SergioAlias/fusariumid-train](https://github.com/SergioAlias/fusariumid-train).

>🐍 *This workflow uses Snakemake 7.32.4. Newer versions (8+) contain [backwards incompatible changes](https://snakemake.readthedocs.io/en/stable/getting_started/migration.html) that may result in this pipeline not working in a Slurm HPC queue system.*

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

1. Clone the repository.

2. Create a Screen (see section [**Immediate submit and Screen**](#immediate-submit-and-screen)).

3. Run the following command to download (if needed) and activate the SporeFlow environment, and to set aliases for the main functions:
```bash
source init_sporeflow.sh
```

4. Create links to your original FASTQ files (with `ln -s`) that match the format `[sample_name]_R1.fastq.gz` / `[sample_name]_R2.fastq.gz` (the workflow only accepts paired-end sequencing for now).

5. Edit `metadata.tsv` with your samples metadata.

6.  For differential abundance, edit `abundance.tsv` with the comparisons you want to perform, based on fields and values included in `metadata.tsv`.

7. Edit `config/config.yml` with your experiment details. Variables annotated with #cluster# must also be updated in `config/cluster_config.yml`.

8. If needed, modify `time`, `ncpus` and `memory` variables in `config/cluster_config.yml`.

9. Classifier setup:
   - **Fungi (ITS):** download a UNITE classfier in QIIME 2 format from [https://github.com/colinbrislawn/unite-train/releases](https://github.com/colinbrislawn/unite-train/releases). We recommend using one of the following (remember to change the name accordingly in `config/config.yml`):
     - `unite_ver10_dynamic_all_04.04.2024-Q2-2024.2.qza`
     - `unite_ver10_99_all_04.04.2024-Q2-2024.2.qza`

   - **Fungi, *Fusarium* (TEF1):** you can train your own classifier or download a pre-made one from [https://github.com/SergioAlias/fusariumid-train](https://github.com/SergioAlias/fusariumid-train).

   - **Bacteria:** download a SILVA classifier in QIIME 2 format from [https://resources.qiime2.org/](https://resources.qiime2.org/). We recommend using the SILVA 138 99% OTUs full-length sequences database (remember to change the name accordingly in `config/config.yml`).

10. Run `sf_run` to start the workflow. You can also run it until some key steps (using `--until rule_name`) to check the results before continuing and to change parameters if necessary (recommended). For example, a possible workflow split could be:
```bash
sf_run --until multiqc     # quality control and possible primer trimming
sf_run --until dada2       # feature table construction
sf_run --until taxonomy    # taxonomic classification
sf_run                     # rest of workflow


# Tip: add the flag -n to perform a dry-run. You will see how many jobs 
# will be executed without actually running the workflow.

# Example:

# sf_run --until multiqc -n
```

## Immediate submit and Screen

Sporeflow inlcudes a command, `sf_immediate`, that automatically sends all jobs to Slurm, correctly queued according to their dependencies. This is desirable e.g. when the runtime in the cluster login machine is very short, because it may kill Snakemake in the middle of the workflow. If your HPC queue system only allows a limited number of jobs submitted at once, change that number in `init_sporeflow.sh` and source it again (that also applies for `sf_run`).

Please note that if the number of simultaneous jobs accepted by the queue system is less than the total number of jobs you need to submit, the workflow will fail. For such cases, we highly recommend not using `sf_immediate`. Instead, use `sf_run` inside a Screen. Screen is a multiplexer that lets you create multiple virtual terminal sessions. It is installed by default in most Linux HPC systems.

To create a screen, use `screen -S sporeflow`. Then, follow usage section there. You can dettach the screen with `Ctrl+a` and then `d`. You can attach the screen again with `screen -r sporeflow`. For more details about Screen usage, please check [this Gist](https://gist.github.com/jctosta/af918e1618682638aa82).

## Drawing DAGs and rule graphs

Since Sporeflow is built over Snakemake, you can generate DAGs, rule graphs and file graphs of the workflow. We provide three commands for this: `sf_draw_dag`, `sf_draw_rulegraph` and `sf_draw_filegraph`.