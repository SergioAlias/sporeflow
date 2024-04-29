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