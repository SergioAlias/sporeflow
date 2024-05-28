rule collapse_feature_table:
    input:
        expand(qiime2_dir("feature_tables", "{collapse}table.qza"), collapse = TO_COLLAPSE),
        metadata = config["metadata"],
        taxonomy = qiime2_dir("taxonomy", "taxonomy.qza")
    output:
        expand(qiime2_dir("feature_tables", "{collapse}sp_collapsed_table.qza"), collapse = TO_COLLAPSE),
        expand(qiime2_dir("feature_tables", "{collapse}sp_collapsed_table.qzv"), collapse = TO_COLLAPSE),
        expand(qiime2_dir("feature_tables", "{collapse}barplot.qzv"), collapse = TO_COLLAPSE)
    conda:
        conda_qiime2
    params:
        qiime2_dir("feature_tables")
    shell:
        """
          headers=$(head -n 1 {input.metadata})
          IFS=$'\\t' read -r -a header_array <<< "$headers"
          header_array[0]="ungrouped"
          for ((i = 0; i < ${{#header_array[@]}}; i++)); do
            header_array[$i]="${{header_array[$i]}}_"
          done
          >&2 printf "\nFeature table collapses:\n"
          for ((i = 0; i < ${{#header_array[@]}}; i++)); do
            >&2 printf "\nBarplot before collapse:\n"
            time qiime taxa barplot \
              --i-table {params}/${{header_array[$i]}}table.qza  \
              --i-taxonomy {input.taxonomy} \
              --o-visualization {params}/${{header_array[$i]}}barplot.qzv
            >&2 printf "\nCollapse feature table to species level:\n"
            time qiime taxa collapse \
              --i-table {params}/${{header_array[$i]}}table.qza \
              --i-taxonomy {input.taxonomy} \
              --p-level 7 \
              --o-collapsed-table {params}/${{header_array[$i]}}sp_collapsed_table.qza
            time qiime feature-table summarize \
              --i-table {params}/${{header_array[$i]}}sp_collapsed_table.qza \
              --o-visualization {params}/${{header_array[$i]}}sp_collapsed_table.qzv
          done
        """