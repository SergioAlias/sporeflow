# SporeFlow: Snakemake Pipeline For Metataxonomics Workflows

Incomplete workflow for metataxonomic analysis of cereal soil.

Steps working for now:

- Create manifest file for QIIME2 (rule `create_manifest`)
- Import FASTQ files to QIIME2 (rule `import_fastq`)