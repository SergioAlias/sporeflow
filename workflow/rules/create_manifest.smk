rule create_manifest:
    input:
        expand(cutadapt_dir("{sample}_" + config["r1_suf"] + "_cutadapt.fastq.gz"), sample = SAMPLES)
    output:
        qiime2_dir("manifest.tsv")
    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir(),
        reads_dir = cutadapt_dir(),
        end = config["end"],
        frw = config["r1_suf"],
        rev = config["r2_suf"]
    shell:
        """
        time Rscript workflow/scripts/manifest.R {params.reads_dir} {params.outdir} {params.end} {params.frw} {params.rev}
        """