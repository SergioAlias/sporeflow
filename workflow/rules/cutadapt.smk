rule cutadapt:
    input:
        fq_f = config["raw_data"] + "/{sample}_" + config["r1_suf"] + ".fastq.gz",
        fq_r = config["raw_data"] + "/{sample}_" + config["r2_suf"] + ".fastq.gz",
    output:
        fq_trim_f = config["outdir"] + "/" + config["proj_name"] + "/reads_trimmed" + "/{sample}_" + config["r1_suf"] + "_cutadapt.fastq.gz",
        fq_trim_r = config["outdir"] + "/" + config["proj_name"] + "/reads_trimmed" + "/{sample}_" + config["r2_suf"] + "_cutadapt.fastq.gz",
        trim_log = config["outdir"] + "/" + config["proj_name"] + "/cutadapt_logs" + "/{sample}_cutadapt.log"
    conda:
        "../envs/qiime2-amplicon-2024.2-py38-linux-conda.yml"
    params:
        outdir = config["outdir"] + "/" + config["proj_name"] + "/reads_trimmed",
        log_outdir = config["outdir"] + "/" + config["proj_name"] + "/cutadapt_logs",
        primer_f = config["cutadapt_primer_f"],
        primer_r = config["cutadapt_primer_r"],
        revcom_f = complementary(config["cutadapt_primer_f"]),
        revcom_r = complementary(config["cutadapt_primer_r"]),
        nthreads = config["cutadapt_n_threads"]
    shell:
        """
        mkdir -p {params.outdir} {params.log_outdir}
        time cutadapt \
          {input.fq_f} \
          {input.fq_r} \
          --front Primer_F=^{params.primer_f} \
          -G Primer_R=^{params.primer_r} \
          --adapter Rev_com_primer_R={params.revcom_r} \
          -A Rev_com_primer_F={params.revcom_f} \
          --discard-untrimmed \
          --cores {params.nthreads} \
          --output {output.fq_trim_f} \
          --paired-output {output.fq_trim_r} \
          | tee {output.trim_log}
        """