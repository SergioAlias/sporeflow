rule create_manifest:
    input:
        fastq_dir = config["raw_data"]
    output:
        manifest = config["outdir"] + "/" + config["proj_name"] + "/my_fastq.txt" # TODO AÑADIR CONDA ENV
    params:
        suffix = config["suffix"]
    shell:
        """
        time find {input.fastq_dir} -type f -name "*{params.suffix}" > {output.manifest}
        """