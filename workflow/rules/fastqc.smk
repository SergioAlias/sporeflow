rule fastqc:
    input:
        fq_f = config["raw_data"] + "/{sample}_" + config["r1_suf"] + "_001.fastq.gz",
        fq_r = config["raw_data"] + "/{sample}_" + config["r2_suf"] + "_001.fastq.gz",
    output:
        html_f = config["outdir"] + "/" + config["proj_name"] + "/fastqc/{sample}_" + config["r1_suf"] + "_001_fastqc.html",
        html_r = config["outdir"] + "/" + config["proj_name"] + "/fastqc/{sample}_" + config["r2_suf"] + "_001_fastqc.html",
        zip_f = config["outdir"] + "/" + config["proj_name"] + "/fastqc/{sample}_" + config["r1_suf"] + "_001_fastqc.zip",
        zip_r = config["outdir"] + "/" + config["proj_name"] + "/fastqc/{sample}_" + config["r2_suf"] + "_001_fastqc.zip"
    conda:
        "../envs/qc.yml"
    params:
        outdir = config["outdir"] + "/" + config["proj_name"] + "/fastqc"
    shell:
        """
        mkdir -p {params.outdir}
        time fastqc --noextract \
          --outdir {params.outdir} \
          --threads 2 \
          {input.fq_f} {input.fq_r}
        """