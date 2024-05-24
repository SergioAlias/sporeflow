rule itsxpress:
    input:
        qiime2_dir("reads", "demux.qza")
    output:
        fastq_qza = qiime2_dir("itsxpress", "its_seqs.qza"),
        fastq_qzv = qiime2_dir("itsxpress", "its_seqs.qzv")
    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir("itsxpress"),
        region = config["itsxpress_region"],
        cluster_id = config["itsxpress_cluster_id"],
        nthreads = config["itsxpress_n_threads"]
    shell:
        """
        mkdir -p {params.outdir}
        >&2 echo "ITSxpress"
        time qiime itsxpress trim-pair-output-unmerged \
          --i-per-sample-sequences {input} \
          --p-region {params.region} \
          --p-taxa F \
          --p-cluster-id {params.cluster_id} \
          --p-threads {params.nthreads} \
          --o-trimmed {output.fastq_qza}
        >&2 echo "QZV generation"
        time qiime demux summarize \
          --i-data {output.fastq_qza} \
          --o-visualization {output.fastq_qzv}
        """