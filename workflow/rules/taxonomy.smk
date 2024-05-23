rule taxonomy:
    input:
        dada2_seqs = config["outdir"] + "/" + config["proj_name"] + "/qiime2/dada2/rep-seqs.qza",
        dada2_table = config["outdir"] + "/" + config["proj_name"] + "/qiime2/dada2/table.qza",
        metadata = config["metadata"],
        classifier = config["db_dir"] + "/" + config["db_file"]
    output:
        taxonomy_qza = config["outdir"] + "/" + config["proj_name"] + "/qiime2/taxonomy/taxonomy.qza",
        taxonomy_qzv = config["outdir"] + "/" + config["proj_name"] + "/qiime2/taxonomy/taxonomy.qzv",
        taxonomy_barplot = config["outdir"] + "/" + config["proj_name"] + "/qiime2/taxonomy/barplot.qzv",
        collapsed_table_qza = config["outdir"] + "/" + config["proj_name"] + "/qiime2/dada2/collapsed_table.qza",
        collapsed_table_qzv = config["outdir"] + "/" + config["proj_name"] + "/qiime2/dada2/collapsed_table.qzv"

    conda:
        "../envs/qiime2-amplicon-2024.2-py38-linux-conda.yml"
    params:
        outdir = config["outdir"] + "/" + config["proj_name"] + "/qiime2/taxonomy",
        nthreads = config["taxonomy_n_threads"]
    shell:
        """
        mkdir -p {params.outdir}
        >&2 echo "Taxonomic classification"
        time qiime feature-classifier classify-sklearn \
          --i-classifier {input.classifier} \
          --i-reads {input.dada2_seqs} \
          --p-n-jobs {params.nthreads} \
          --o-classification {output.taxonomy_qza}
        >&2 echo "QZV generation"
        time qiime metadata tabulate \
          --m-input-file {output.taxonomy_qza} \
          --o-visualization {output.taxonomy_qzv}
        time qiime taxa barplot \
          --i-table {input.dada2_table}  \
          --i-taxonomy {output.taxonomy_qza} \
          --m-metadata-file {input.metadata} \
          --o-visualization {output.taxonomy_barplot}
        >&2 echo "Collapse table to species level"
        time qiime taxa collapse \
          --i-table {input.dada2_table} \
          --i-taxonomy {output.taxonomy_qza} \
          --p-level 7 \
          --o-collapsed-table {output.collapsed_table_qza}
        time qiime feature-table summarize \
          --i-table {output.collapsed_table_qza} \
          --m-sample-metadata-file {input.metadata} \
          --o-visualization {output.collapsed_table_qzv}
        """