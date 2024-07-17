rule abundance:
    input:
        table = qiime2_dir("feature_tables", "{levels}_table.qza"),
        metadata = config["metadata"]
    output:
        ancombc = qiime2_dir("abundance", "{da_ref}", "{levels}_ancombc.qza"),
        da_barplot = qiime2_dir("abundance", "{da_ref}", "{levels}_da_barplot.qzv"),
        tabular = qiime2_dir("abundance", "{da_ref}", "{levels}_tabular.qzv")
    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir("abundance"),
        level_name = lambda w: w.levels,
        formula = lambda w: "{}".format(w.da_ref).split("_")[0],
        ref_level = lambda w: "{}".format(w.da_ref).split("_")[1],
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
          --p-reference-levels {params.formula}::{params.ref_level} \
          --p-p-adj-method 'fdr' \
          --p-prv-cut 0.1 \
          --p-lib-cut 0 \
          --p-alpha {params.p_alpha} \
          --o-differentials {output.ancombc}
        >&2 printf "\nQZV generation:\n"
        time qiime composition da-barplot \
          --i-data {output.ancombc} \
          --p-significance-threshold {params.barplot_thr} \
          --p-level-delimiter ';' \
          --o-visualization {output.da_barplot}
        time qiime composition tabulate \
          --i-data {output.ancombc} \
          --o-visualization {output.tabular}
        """