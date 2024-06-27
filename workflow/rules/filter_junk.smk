rule filter_junk:
    input:
        table = qiime2_dir("feature_tables", "unfiltered_table.qza"),
        taxonomy = qiime2_dir("taxonomy", "taxonomy.qza"),
        metadata = config["metadata"]
    output:
        filtered_table_qza = qiime2_dir("feature_tables", "ungrouped_table.qza"),
        filtered_table_qzv = qiime2_dir("feature_tables", "ungrouped_table.qzv"),
        filtered_freqs_qza = qiime2_dir("sample_frequencies", "ungrouped_frequencies.qza")
    conda:
        conda_qiime2
    params:
        intermediate_table = qiime2_dir("feature_tables", "intermediate.qza"),
        kgd_to_keep = config["kingdom_to_keep"],
        min_taxa_level = config["min_taxa_level"],
    shell:
        """
        >&2 printf "\nFilter junk sequences: keep one Kindgom\n"
        time qiime taxa filter-table \
          --i-table {input.table} \
          --i-taxonomy {input.taxonomy} \
          --p-include {params.kgd_to_keep} \
          --p-mode contains \
          --o-filtered-table {params.intermediate_table}
        >&2 printf "\nFilter junk sequences: discard too general taxonomic assignations\n"
        time qiime taxa filter-table \
          --i-table {params.intermediate_table} \
          --i-taxonomy {input.taxonomy} \
          --p-include {params.min_taxa_level} \
          --p-mode contains \
          --o-filtered-table {output.filtered_table_qza}
        rm {params.intermediate_table}
        >&2 printf "\nGet table QZV and frequencies QZA:\n"
        time qiime feature-table summarize \
          --i-table {output.filtered_table_qza} \
          --m-sample-metadata-file {input.metadata} \
          --o-visualization {output.filtered_table_qzv}
        time qiime feature-table tabulate-sample-frequencies \
          --i-table {output.filtered_table_qza} \
          --o-sample-frequencies {output.filtered_freqs_qza}
        """