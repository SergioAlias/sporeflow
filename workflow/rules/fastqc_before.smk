rule fastqc_before:
    input:
        fq_f = config["raw_data"] + "/{sample}_" + config["r1_suf"] + ".fastq.gz",
        fq_r = config["raw_data"] + "/{sample}_" + config["r2_suf"] + ".fastq.gz",
    output:
        html_f = config["outdir"] + "/" + config["proj_name"] + "/fastqc_before/{sample}_" + config["r1_suf"] + "_fastqc.html",
        html_r = config["outdir"] + "/" + config["proj_name"] + "/fastqc_before/{sample}_" + config["r2_suf"] + "_fastqc.html",
        zip_f = config["outdir"] + "/" + config["proj_name"] + "/fastqc_before/{sample}_" + config["r1_suf"] + "_fastqc.zip",
        zip_r = config["outdir"] + "/" + config["proj_name"] + "/fastqc_before/{sample}_" + config["r2_suf"] + "_fastqc.zip"
    conda:
        "../envs/qc.yml"
    params:
        outdir = config["outdir"] + "/" + config["proj_name"] + "/fastqc_before"
    shell:
        """
        mkdir -p {params.outdir}
        time fastqc --noextract \
          --outdir {params.outdir} \
          --threads 2 \
          {input.fq_f} {input.fq_r}
        """