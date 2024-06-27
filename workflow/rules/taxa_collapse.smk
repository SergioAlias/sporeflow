rule taxa_collapse:
    input:
        table = qiime2_dir("feature_tables", "filtered_table.qza"),
        taxonomy = qiime2_dir("taxonomy", "taxonomy.qza")
    output:
        expand(qiime2_dir("feature_tables", "{levels}_table.qza"), levels = COLLAPSED_TABLES[1:]),
        expand(qiime2_dir("feature_tables", "{levels}_table.qzv"), levels = COLLAPSED_TABLES[1:])
    conda:
        conda_qiime2
    params:
        feature_tables_outdir = qiime2_dir("feature_tables"),
        levels = config["abundance_collapse_levels"]
    shell:
        """
          IFS=";" read -ra LVL_ARRAY <<< "{params.levels}"
          >&2 printf "\nFeature table taxa collapsing and QZV generation:\n"
          for TAXA_LEVEL in "${{LVL_ARRAY[@]}}"; do
            time qiime taxa collapse \
              --i-table {input.table} \
              --i-taxonomy {input.taxonomy} \
              --p-level $TAXA_LEVEL \
              --o-collapsed-table "{params.feature_tables_outdir}/level_"$TAXA_LEVEL"_table.qza"
            time qiime feature-table summarize \
              --i-table "{params.feature_tables_outdir}/level_"$TAXA_LEVEL"_table.qza" \
              --o-visualization "{params.feature_tables_outdir}/level_"$TAXA_LEVEL"_table.qzv"
          done
        """