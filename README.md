# 🦠 SporeFlow: Snakemake Pipeline For Metataxonomics Workflows

> ⚠️ ***Disclaimer*** ⚠️
> 
> *This workflow is still under development, thus it can not be used for a complete metataxonomic experiment yet.*

Workflow for metataxonomic analysis of cereal soil using [QIIME2](https://qiime2.org/) and [Snakemake](https://snakemake.readthedocs.io/en/v7.32.2/).

Steps working for now:

- Run [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on the raw FASTQ files (rule `fastqc_before`)
- Run [Cutadapt](https://cutadapt.readthedocs.io/en/v4.6/) on the raw FASTQ files (rule `cutadapt`)
- Run [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on the trimmed FASTQ files (rule `fastqc_after`)

Steps working but not integrated yet:

- Create manifest file for QIIME2 (rule `create_manifest`)
- Import FASTQ files to QIIME2 (rule `import_fastq`)

## Requisites

The only prerequisite is having Conda installed. In this regard, we recommend using Miniconda and Mamba for a lightweight and fast experience, although Sporeflow works on any Conda installation.

## Usage

1. Clone the repository
2. Run `source init_sporeflow.sh`
3. Edit `config/config.yml` with your experiment details. Variables annotated with #cluster# must also be updated in `config/cluster_config.yml`.
4. If needed, modify `time`, `ncpus` and `memory` variables in `config/cluster_config.yml`.
5. Run `sf_run` to run the workflow.
   
## Immediate submit: Screen

Sporeflow inlcudes a command, `sf_immediate`, that automatically sends all jobs to Slurm, correctly queued according to their dependencies. This is desirable e.g. when the runtime in the cluster login machine is very short, because it may kill Snakemake in the middle of the workflow. If your HPC queue system only allows a limited number of jobs submitted at once, change that number in `init_sporeflow.sh` and source it again (that also applies for `sf_run`).

Please note that if the number of simultaneous jobs accepted by the queue system is less than the total number of jobs you need to submit, the workflow will fail. For such cases, we highly recommend not using `sf_immediate`. Instead, use `sf_run` inside a Screen. Screen is installed by default in most recent Linux systems.

To create a screen, use `screen -S sporeflow`. Then, follow usage section there. You can dettach the screen with `Ctrl+a` and then `d`. You can attach the screen again with `screen -r sporeflow`. For more details about Screen usage, please check [this Gist](https://gist.github.com/jctosta/af918e1618682638aa82).

## Drawing DAGs and rule graphs

Since Sporeflow is built over Snakemake, you can generate DAGs and rule graphs of the workflow. We provide two commands for this: `sf_draw_dag` and `sf_draw_rulegraph`.