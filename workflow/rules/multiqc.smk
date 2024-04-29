rule multiqc:
    input:
        html_f = expand(config["outdir"] + "/" + config["proj_name"] + "/fastqc_before/{sample}_" + config["r1_suf"] + "_fastqc.html", sample = SAMPLES),
        html_r = expand(config["outdir"] + "/" + config["proj_name"] + "/fastqc_before/{sample}_" + config["r2_suf"] + "_fastqc.html", sample = SAMPLES),
        trim_log = expand(config["outdir"] + "/" + config["proj_name"] + "/cutadapt_logs" + "/{sample}_cutadapt.log", sample = SAMPLES),
        html_trim_f = expand(config["outdir"] + "/" + config["proj_name"] + "/fastqc_after/{sample}_" + config["r1_suf"] + "_cutadapt_fastqc.html", sample = SAMPLES),
        html_trim_r = expand(config["outdir"] + "/" + config["proj_name"] + "/fastqc_after/{sample}_" + config["r2_suf"] + "_cutadapt_fastqc.html", sample = SAMPLES)
    output:
        report = config["outdir"] + "/" + config["proj_name"] + "/multiqc/multiqc_report.html"
    conda:
        "../envs/qc.yml"
    params:
        outdir = config["outdir"] + "/" + config["proj_name"] + "/multiqc",
        fastqc_before_dir = config["outdir"] + "/" + config["proj_name"] + "/fastqc_before",
        cutadapt_dir = config["outdir"] + "/" + config["proj_name"] + "/cutadapt_logs",
        fastqc_after_dir = config["outdir"] + "/" + config["proj_name"] + "/fastqc_after"
    shell:
        """
        mkdir -p {params.outdir}
        time multiqc \
          {params.fastqc_before_dir} \
          {params.cutadapt_dir} \
          {params.fastqc_after_dir} \
          --outdir {params.outdir}
        """