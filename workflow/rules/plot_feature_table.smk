rule plot_feature_table:
    input:
        table = qiime2_dir("feature_tables", "{feat_table}_table.qza"),
        taxonomy = qiime2_dir("taxonomy", "taxonomy.qza"),
        metadata = lambda w: os.path.join(code_dir, META_FILES[w.feat_table])
    output:
        barplot = qiime2_dir("feature_table_plots", "{feat_table}_barplot.qzv")
    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir("feature_table_plots"),
    shell:
        """
        mkdir -p {params.outdir}
        >&2 printf "\nTaxa barplot:\n"
        time qiime taxa barplot \
          --i-table {input.table}  \
          --i-taxonomy {input.taxonomy} \
          --m-metadata-file {input.metadata} \
          --o-visualization {output.barplot}
        """ 

