rule create_manifest:
    input:
        expand(config["outdir"] + "/" + config["proj_name"] + "/reads_trimmed/{sample}_" + config["r1_suf"] + "_cutadapt.fastq.gz", sample = SAMPLES)
    output:
        config["outdir"] + "/" + config["proj_name"] + "/qiime2/manifest.tsv"
    conda:
        "../envs/qiime2-amplicon-2024.2-py38-linux-conda.yml"
    params:
        outdir = config["outdir"] + "/" + config["proj_name"] + "/qiime2",
        reads_dir = config["outdir"] + "/" + config["proj_name"] + "/reads_trimmed",
        end = config["end"],
        frw = config["r1_suf"],
        rev = config["r2_suf"]
    shell:
        """
        time Rscript workflow/scripts/manifest.R {params.reads_dir} {params.outdir} {params.end} {params.frw} {params.rev}
        """