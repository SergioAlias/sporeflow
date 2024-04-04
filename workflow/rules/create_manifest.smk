rule create_manifest:
    input:
        config["raw_data"]
    output:
        config["outdir"] + "/" + config["proj_name"] + "/manifest.tsv" # TODO AÑADIR CONDA ENV
    conda:
        "qiime2-amplicon-2024.2" # TODO: CAMBIAR POR EL YAML DE QIIME2
    params:
        outdir = config["outdir"] + "/" + config["proj_name"],
        end = config["end"],
        frw = config["r1_suf"],
        rev = config["r2_suf"]
    shell:
        """
        time Rscript workflow/scripts/manifest.R {input} {params.outdir} {params.end} {params.frw} {params.rev}
        """