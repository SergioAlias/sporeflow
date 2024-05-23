rule itsxpress:
    input:
        config["outdir"] + "/" + config["proj_name"] + "/qiime2/reads/demux.qza"
    output:
        fastq_qza = config["outdir"] + "/" + config["proj_name"] + "/qiime2/itsxpress/its_seqs.qza",
        fastq_qzv = config["outdir"] + "/" + config["proj_name"] + "/qiime2/itsxpress/its_seqs.qzv",
    conda:
        "../envs/qiime2-amplicon-2024.2-py38-linux-conda.yml"
    params:
        outdir = config["outdir"] + "/" + config["proj_name"] + "/qiime2/itsxpress",
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