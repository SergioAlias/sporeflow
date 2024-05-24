rule multiqc:
    input:
        zip_f = expand(fastqc_before_dir("{sample}_" + config["r1_suf"] + "_fastqc.zip"), sample = SAMPLES),
        zip_r = expand(fastqc_before_dir("{sample}_" + config["r2_suf"] + "_fastqc.zip"), sample = SAMPLES),
        trim_log = expand(cutadapt_logdir("{sample}_cutadapt.log"), sample = SAMPLES),
        zip_trim_f = expand(fastqc_after_dir("{sample}_" + config["r1_suf"] + "_cutadapt_fastqc.zip"), sample = SAMPLES),
        zip_trim_r = expand(fastqc_after_dir("{sample}_" + config["r2_suf"] + "_cutadapt_fastqc.zip"), sample = SAMPLES)
    output:
        report = multiqc_dir("multiqc_report.html")
    conda:
        conda_qc
    params:
        outdir = multiqc_dir(),
        fastqc_before_outdir = fastqc_before_dir(),
        trim_logdir = cutadapt_logdir(),
        fastqc_after_outdir = fastqc_after_dir()
    shell:
        """
        mkdir -p {params.outdir}
        time multiqc \
          --force \
          {params.fastqc_before_outdir} \
          {params.trim_logdir} \
          {params.fastqc_after_outdir} \
          --config /home/salias/projects/sporeflow/config/multiqc_template.yml \
          --outdir {params.outdir}
        """