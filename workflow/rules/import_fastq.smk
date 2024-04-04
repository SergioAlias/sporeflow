rule import_fastq:
    input:
        config["outdir"] + "/" + config["proj_name"] + "/manifest.tsv"
    output:
        fastq_qza = config["outdir"] + "/" + config["proj_name"] + "/reads/paired-end-demux.qza",
        fastq_qzv = config["outdir"] + "/" + config["proj_name"] + "/reads/paired-end-demux.qzv"
    conda:
        "../envs/qiime2-amplicon-2024.2-py38-linux-conda.yml"
    shell:
        """
        time qiime tools import \
          --type 'SampleData[PairedEndSequencesWithQuality]' \
          --input-path {input} \
          --output-path {output.fastq_qza} \
          --input-format PairedEndFastqManifestPhred33V2
        time qiime demux summarize \
          --i-data {output.fastq_qza} \
          --o-visualization {output.fastq_qzv}
        """