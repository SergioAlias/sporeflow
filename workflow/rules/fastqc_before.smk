rule fastqc_before:
    input:
        fq_f = os.path.join(config["raw_data"], "{sample}_" + config["r1_suf"] + ".fastq.gz"),
        fq_r = os.path.join(config["raw_data"], "{sample}_" + config["r2_suf"] + ".fastq.gz")
    output:
        html_f = fastqc_before_dir("{sample}_" + config["r1_suf"] + "_fastqc.html"),
        html_r = fastqc_before_dir("{sample}_" + config["r2_suf"] + "_fastqc.html"),
        zip_f = fastqc_before_dir("{sample}_" + config["r1_suf"] + "_fastqc.zip"),
        zip_r = fastqc_before_dir("{sample}_" + config["r2_suf"] + "_fastqc.zip")
    conda:
        conda_qc
    params:
        outdir = fastqc_before_dir()
    shell:
        """
        mkdir -p {params.outdir}
        time fastqc --noextract \
          --outdir {params.outdir} \
          --threads 2 \
          {input.fq_f} {input.fq_r}
        """