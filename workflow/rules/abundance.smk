rule abundance:
    input:
        table = qiime2_dir("feature_tables", "{levels}_table.qza"),
        metadata = config["metadata"]
    output:
        expand(qiime2_dir("abundance", "{meta_col}", "{{levels}}_ancombc.qza"), meta_col = META_COLS),
        expand(qiime2_dir("abundance", "{meta_col}", "{{levels}}_da_barplot.qzv"), meta_col = META_COLS),
        expand(qiime2_dir("abundance", "{meta_col}", "{{levels}}_tabular.qzv"), meta_col = META_COLS)
    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir("abundance"),
        level_name = lambda w: w.levels,
        p_alpha = config["abundance_p_alpha"],
        barplot_thr = config["abundance_barplot_threshold"]
    shell:
        """
        mkdir -p {params.outdir}
        metadata_file={input.metadata}
        header=$(head -n 1 "$metadata_file")
        IFS=$'\t' read -r -a columns <<< "$header"
        for (( i=1; i<${{#columns[@]}}; i++ )); do
          column=${{columns[i]}}
          column=${{column//$'\r'/}}
          >&2 printf "\nANCOM-BC:\n"
          time qiime composition ancombc \
            --i-table {input.table} \
            --m-metadata-file {input.metadata} \
            --p-formula $column \
            --p-p-adj-method 'fdr' \
            --p-prv-cut 0.1 \
            --p-lib-cut 0 \
            --p-alpha {params.p_alpha} \
            --o-differentials "{params.outdir}/"$column"/{params.level_name}_ancombc.qza"
          >&2 printf "\nQZV generation:\n"
          time qiime composition da-barplot \
            --i-data "{params.outdir}/"$column"/{params.level_name}_ancombc.qza" \
            --p-significance-threshold {params.barplot_thr} \
            --p-level-delimiter ';' \
            --o-visualization "{params.outdir}/"$column"/{params.level_name}_da_barplot.qzv"
          time qiime composition tabulate \
            --i-data "{params.outdir}/"$column"/{params.level_name}_ancombc.qza" \
            --o-visualization "{params.outdir}/"$column"/{params.level_name}_tabular.qzv"
        done
        """