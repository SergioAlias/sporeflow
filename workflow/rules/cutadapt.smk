rule cutadapt:
    input:
        config["outdir"] + "/" + config["proj_name"] + "/reads_raw/demux.qza"
    output:
        trimmed_qza = config["outdir"] + "/" + config["proj_name"] + "/reads_trimmed/trimmed.qza",
        trimmed_qzv = config["outdir"] + "/" + config["proj_name"] + "/reads_trimmed/trimmed.qzv"
    conda:
        "../envs/qiime2-amplicon-2024.2-py38-linux-conda.yml"
    params:
        outdir = config["outdir"] + "/" + config["proj_name"] + "/reads_trimmed",
        primer_f = config["cutadapt_primer_f"],
        primer_r = config["cutadapt_primer_r"],
        revcom_f = complementary(config["cutadapt_primer_f"]),
        revcom_r = complementary(config["cutadapt_primer_r"]),
        nthreads = config["cutadapt_n_threads"]
    shell:
        """
        mkdir -p {params.outdir}
        time qiime cutadapt trim-paired \
          --i-demultiplexed-sequences {input} \
          --p-front-f {params.primer_f} \
          --p-front-r {params.primer_r} \
          --p-adapter-f {params.revcom_r} \
          --p-adapter-r {params.revcom_f} \
          --p-match-adapter-wildcards \
          --p-match-read-wildcards \
          --p-discard-untrimmed \
          --p-cores {params.nthreads} \
          --o-trimmed-sequences {output.trimmed_qza} \
          --verbose
        time qiime demux summarize \
          --i-data {output.trimmed_qza} \
          --o-visualization {output.trimmed_qzv}
        """