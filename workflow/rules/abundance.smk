rule abundance:
    input:
        table = qiime2_dir("feature_tables", "{levels}_table.qza"),
        metadata = config["metadata"]
    output:
        ancom = qiime2_dir("abundance", abundance_subdir, "{levels}_ancombc.qza"),
        barplot = qiime2_dir("abundance", abundance_subdir, "{levels}_da_barplot.qzv"),
        tabular = qiime2_dir("abundance", abundance_subdir, "{levels}_tabular.qzv")
    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir("abundance", abundance_subdir),
        formula = config["abundance_meta_col"],
        reference = config["abundance_meta_ref"],
        p_alpha = config["abundance_p_alpha"],
        barplot_thr = config["abundance_barplot_threshold"]
    shell:
        """
        mkdir -p {params.outdir}
        >&2 printf "\nANCOM-BC:\n"
        time qiime composition ancombc \
          --i-table {input.table} \
          --m-metadata-file {input.metadata} \
          --p-formula {params.formula} \
          --p-reference-levels {params.formula}::{params.reference} \
          --p-p-adj-method 'fdr' \
          --p-prv-cut 0.1 \
          --p-lib-cut 0 \
          --p-alpha {params.p_alpha} \
          --o-differentials {output.ancom}
        >&2 printf "\nQZV generation:\n"
        time qiime composition da-barplot \
          --i-data {output.ancom} \
          --p-significance-threshold {params.barplot_thr} \
          --o-visualization {output.barplot}
        time qiime composition tabulate \
          --i-data {output.ancom} \
          --o-visualization {output.tabular}
        """