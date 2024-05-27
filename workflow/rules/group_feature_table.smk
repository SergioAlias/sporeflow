rule group_feature_table:
    input:
        table = qiime2_dir("feature_tables", "table.qza"),
        metadata = config["metadata"]
    output:
        expand(qiime2_dir("feature_tables", "{column}_table.qza"), column = META_COLS),
        expand(qiime2_dir("feature_tables", "{column}_table.qzv"), column = META_COLS)
    conda:
        conda_qiime2
    params:
        qiime2_dir("feature_tables")
    shell:
        """
          headers=$(head -n 1 {input.metadata})
          IFS=$'\\t' read -r -a header_array <<< "$headers"
          >&2 printf "\nFeature table grouping and QZV generation:\n"
          for ((i = 1; i < ${{#header_array[@]}}; i++)); do
            time qiime feature-table group \
              --i-table {input.table} \
              --p-axis sample \
              --p-mode sum \
              --m-metadata-file {input.metadata} \
              --m-metadata-column ${{header_array[$i]}} \
              --o-grouped-table {params}/${{header_array[$i]}}_table.qza
            time qiime feature-table summarize \
              --i-table {params}/${{header_array[$i]}}_table.qza \
              --o-visualization {params}/${{header_array[$i]}}_table.qzv
          done
        """