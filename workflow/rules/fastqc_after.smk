rule fastqc_after:
    input:
        fq_f = cutadapt_dir("{sample}_" + config["r1_suf"] + "_cutadapt.fastq.gz"),
        fq_r = cutadapt_dir("{sample}_" + config["r2_suf"] + "_cutadapt.fastq.gz")
    output:
        html_f = fastqc_after_dir("{sample}_" + config["r1_suf"] + "_cutadapt_fastqc.html"),
        html_r = fastqc_after_dir("{sample}_" + config["r2_suf"] + "_cutadapt_fastqc.html"),
        zip_f = fastqc_after_dir("{sample}_" + config["r1_suf"] + "_cutadapt_fastqc.zip"),
        zip_r = fastqc_after_dir("{sample}_" + config["r2_suf"] + "_cutadapt_fastqc.zip")
    conda:
        conda_qc
    params:
        outdir = fastqc_after_dir()
    shell:
        """
        mkdir -p {params.outdir}
        time fastqc --noextract \
          --outdir {params.outdir} \
          --threads 2 \
          {input.fq_f} {input.fq_r}
        """