rule fastqc:
    input:
        expand(config["raw_data"] + "/{sample}.fastq.gz", sample = SAMPLES)
    output:
        html = config["outdir"] + "/" + config["proj_name"] + "/fastqc/{sample}.html",
        zip = config["outdir"] + "/" + config["proj_name"] + "/fastqc/{sample}_fastqc.zip"
    conda:
        "../envs/qc.yml"
    params:
        outdir = config["outdir"] + "/" + config["proj_name"] + "/fastqc"
    shell:
        """
        mkdir -p {params.outdir}
        sleep 10
        touch {output.html}
        """