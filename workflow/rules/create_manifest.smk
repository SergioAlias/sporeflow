rule create_manifest:
    input:
        qiime2_input_seqs
    output:
        qiime2_dir("manifest.tsv")
    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir(),
        reads_dir = qiime2_input_dir,
        end = config["end"],
        frw = config["r1_suf"],
        rev = config["r2_suf"],
        cutadapted = config["use_cutadapt"]
    shell:
        """
        time Rscript workflow/scripts/manifest.R {params.reads_dir} {params.outdir} {params.end} {params.frw} {params.rev} {params.cutadapted}
        """