rule taxonomy:
    input:
        dada2_seqs = qiime2_dir("dada2", "rep-seqs.qza"),
        dada2_table = qiime2_dir("dada2", "table.qza"),
        metadata = config["metadata"],
        classifier = os.path.join(config["db_dir"], config["db_file"])
    output:
        taxonomy_qza = qiime2_dir("taxonomy", "taxonomy.qza"),
        taxonomy_qzv = qiime2_dir("taxonomy", "taxonomy.qzv"),
        taxonomy_barplot = qiime2_dir("taxonomy", "barplot.qzv"),
        collapsed_table_qza = qiime2_dir("dada2", "collapsed_table.qza"),
        collapsed_table_qzv = qiime2_dir("dada2", "collapsed_table.qzv")
    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir("taxonomy"),
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