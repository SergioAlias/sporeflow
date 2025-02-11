rule relative_filter:
    input:
        table = qiime2_dir("feature_tables", "filtered_table.qza"),
        metadata = config["metadata"]
    output:
        filtered_table_qza = qiime2_dir("feature_tables", "relative_filtered_table.qza"),
        filtered_table_qzv = qiime2_dir("feature_tables", "relative_filtered_table.qzv"),
        filtered_freqs_qza = qiime2_dir("sample_frequencies", "relative_filtered_frequencies.qza")
    conda:
        conda_qiime2
    params:
        filtering_abundance = config["filtering_abundance"],
        filtering_prevalence = config["filtering_prevalence"]
    shell:
        """
        >&2 printf "\nFilter based on relative abundance and prevalence\n"
        time qiime feature-table filter-features-conditionally \
          --i-table {input.table} \
          --p-abundance {params.filtering_abundance} \
          --p-prevalence {params.filtering_prevalence} \
          --o-filtered-table {output.filtered_table_qza}
        >&2 printf "\nGet table QZV and frequencies QZA:\n"
        time qiime feature-table summarize \
          --i-table {output.filtered_table_qza} \
          --m-sample-metadata-file {input.metadata} \
          --o-visualization {output.filtered_table_qzv}
        time qiime feature-table tabulate-sample-frequencies \
          --i-table {output.filtered_table_qza} \
          --o-sample-frequencies {output.filtered_freqs_qza}
        """