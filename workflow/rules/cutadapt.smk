rule cutadapt:
    input:
        fq_f = config["raw_data"] + "/{sample}_" + config["r1_suf"] + ".fastq.gz",
        fq_r = config["raw_data"] + "/{sample}_" + config["r2_suf"] + ".fastq.gz",
    output:
        fq_trim_f = config["outdir"] + "/" + config["proj_name"] + "/reads_trimmed" + "/{sample}_" + config["r1_suf"] + "_cutadapt.fastq.gz",
        fq_trim_r = config["outdir"] + "/" + config["proj_name"] + "/reads_trimmed" + "/{sample}_" + config["r2_suf"] + "_cutadapt.fastq.gz"
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
          # --p-front-f {params.primer_f} \
          # --p-front-r {params.primer_r} \
          # --p-adapter-f {params.revcom_r} \
          # --p-adapter-r {params.revcom_f} \
          # --p-match-adapter-wildcards \
          # --p-match-read-wildcards \
          # --p-discard-untrimmed \
          # --p-cores {params.nthreads} \
          # --o-trimmed-sequences {output.trimmed_qza} \
          # --verbose
        time cutadapt \
          {input.fq_f} \
          {input.fq_r} \
          --front ^{params.primer_f} \
          -G ^{params.primer_r} \
          --adapter {params.revcom_r} \
          -A {params.revcom_f} \
          --discard-untrimmed \
          --cores {params.nthreads} \
          --output {output.fq_trim_f} \
          --paired-output {output.fq_trim_r}
        """