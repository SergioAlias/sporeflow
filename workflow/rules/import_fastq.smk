rule import_fastq:
    input:
        qiime2_dir("manifest.tsv")
    output:
        fastq_qza = qiime2_dir("reads", "demux.qza"),
        fastq_qzv = qiime2_dir("reads", "demux.qzv")
    conda:
        conda_qiime2
    shell:
        """
        >&2 printf "\nImport sequences:\n"
        time qiime tools import \
          --type 'SampleData[PairedEndSequencesWithQuality]' \
          --input-path {input} \
          --output-path {output.fastq_qza} \
          --input-format PairedEndFastqManifestPhred33V2
        >&2 printf "\nQZV generation:\n"
        time qiime demux summarize \
          --i-data {output.fastq_qza} \
          --o-visualization {output.fastq_qzv}
        """