rule print_tagline:
    input:
        file = "letters.txt"
    output:
        "prints.txt"
    params:
        tagline = "tagline"
    shell:
        "time workflow/scripts/tagliner.sh {input.file} {output} {params.tagline}"