rule fastqc_after:
    input:
        fq_f = config["outdir"] + "/" + config["proj_name"] + "/reads_trimmed" + "/{sample}_" + config["r1_suf"] + "_cutadapt.fastq.gz",
        fq_r = config["outdir"] + "/" + config["proj_name"] + "/reads_trimmed" + "/{sample}_" + config["r2_suf"] + "_cutadapt.fastq.gz"
    output:
        html_f = config["outdir"] + "/" + config["proj_name"] + "/fastqc_after/{sample}_" + config["r1_suf"] + "_cutadapt_fastqc.html",
        html_r = config["outdir"] + "/" + config["proj_name"] + "/fastqc_after/{sample}_" + config["r2_suf"] + "_cutadapt_fastqc.html",
        zip_f = config["outdir"] + "/" + config["proj_name"] + "/fastqc_after/{sample}_" + config["r1_suf"] + "_cutadapt_fastqc.zip",
        zip_r = config["outdir"] + "/" + config["proj_name"] + "/fastqc_after/{sample}_" + config["r2_suf"] + "_cutadapt_fastqc.zip"
    conda:
        "../envs/qc.yml"
    params:
        outdir = config["outdir"] + "/" + config["proj_name"] + "/fastqc_after"
    shell:
        """
        mkdir -p {params.outdir}
        time fastqc --noextract \
          --outdir {params.outdir} \
          --threads 2 \
          {input.fq_f} {input.fq_r}
        """