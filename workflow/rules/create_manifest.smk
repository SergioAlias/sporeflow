rule create_manifest:
    input:
        fastq_dir = "AÑADIR VAR CON EL PATH"
    output:
        "MANIFEST-FILE"
    params: # TODO AÑADIR CONDA ENV
        tagline = "tagline"
    shell:
        "time workflow/scripts/tagliner.sh {input.file} {output} {params.tagline}"