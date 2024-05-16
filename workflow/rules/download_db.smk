rule download_db:
    output:
        seq = config["db_dir"] + "/" + config["db_name"] + "/" + db_subdir + "/sequences.qza",
        tax = config["db_dir"] + "/" + config["db_name"] + "/" + db_subdir + "/taxonomy.qza"
    conda:
        "../envs/qiime2-amplicon-2024.2-py38-linux-conda.yml"
    params:
        outdir = config["db_dir"] + "/" + config["db_name"] + "/" + db_subdir,
        unite_version = config["db_unite_version"],
        unite_taxon = config["db_unite_taxon"],
        unite_cluster = config["db_unite_cluster"],
        unite_singletons = "--p-singletons" if config["db_unite_singletons"] else "--p-no-singletons"
    shell:
        """
        mkdir -p {params.outdir}
        time source workflow/scripts/download_db.sh \
          {output.seq} \
          {output.tax} \
          {params.unite_version} \
          {params.unite_taxon} \
          {params.unite_cluster} \
          {params.unite_singletons}
        """