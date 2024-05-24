rule group_feature_table:
    input:
        table = qiime2_dir("dada2", "table.qza"),
        metadata = config["metadata"]
    output:
        grouped_table_qza = qiime2_dir("dada2", "{column}table.qza"),
        grouped_table_qzv = qiime2_dir("dada2", "{column}table.qzv")
    conda:
        conda_qiime2
    params:
        metadata_col = "{column}"[:-1] if "{column}" not in ["", "sp_collapsed_"] else SKIP_RULE
    shell:
        """
        if [ "{params.metadata_col}" == "SKIP_RULE" ]; then
          >&2 printf "\nAlready existing feature table provided as input; skipping rule...\n"
        else
          >&2 printf "\nFeature table grouping:\n"
          time qiime feature-table group \
            --i-table {input.table} \
            --p-axis sample \
            --p-mode sum \
            --m-metadata-file {input.metadata} \
            --m-metadata-column {params.metadata_col} \
            --o-grouped-table {output.grouped_table_qza}
          >&2 printf "\nQZV generation:\n"
          time qiime feature-table summarize \
            --i-table {output.grouped_table_qza} \
            --o-visualization {output.grouped_table_qzv}
        fi
        """