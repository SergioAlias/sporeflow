rule beta_group_sign:
    input:
        metadata = config["metadata"],
        jaccard_dist_mat = qiime2_dir("diversity", "jaccard_distance_matrix.qza"),
        bray_curtis_dist_mat = qiime2_dir("diversity", "bray_curtis_distance_matrix.qza"),
        aitchison_dist_mat = qiime2_dir("diversity", "aitchison_distance_matrix.qza")
    output:
        expand(qiime2_dir("group_significances", "{{bgs_method}}", "{meta_col}", "jaccard_group_significance.qzv"), meta_col = BGS_INCLUDE),
        expand(qiime2_dir("group_significances", "{{bgs_method}}", "{meta_col}", "bray_curtis_group_significance.qzv"), meta_col = BGS_INCLUDE),
        expand(qiime2_dir("group_significances", "{{bgs_method}}", "{meta_col}", "aitchison_group_significance.qzv"), meta_col = BGS_INCLUDE)
    conda:
        conda_qiime2
    params:
        outdir = lambda w: qiime2_dir("group_significances", "{}".format(w.bgs_method)),
        beta_method = lambda w: w.bgs_method,
        beta_exclude = config["diversity_beta_cols_to_exclude"]
    shell:
        """
        mkdir -p {params.outdir}
        metadata_file={input.metadata}
        header=$(head -n 1 "$metadata_file")
        IFS=$'\t' read -r -a columns <<< "$header"
        for (( i=1; i<${{#columns[@]}}; i++ )); do
          column=${{columns[i]}}
          column=${{column//$'\r'/}}
          if [[ ";{params.beta_exclude};" != *";$column;"* ]]; then
            >&2 printf "\nBeta group significance: Jaccard\n"
            time qiime diversity beta-group-significance \
              --i-distance-matrix {input.jaccard_dist_mat} \
              --m-metadata-file {input.metadata} \
              --m-metadata-column $column \
              --p-method {params.beta_method} \
              --p-pairwise \
              --o-visualization "{params.outdir}/"$column"/jaccard_group_significance.qzv"
            >&2 printf "\nBeta group significance: Bray-Curtis\n"
            time qiime diversity beta-group-significance \
              --i-distance-matrix {input.bray_curtis_dist_mat} \
              --m-metadata-file {input.metadata} \
              --m-metadata-column $column \
              --p-method {params.beta_method} \
              --p-pairwise \
              --o-visualization "{params.outdir}/"$column"/bray_curtis_group_significance.qzv"
            >&2 printf "\nBeta group significance: Aitchison\n"
            time qiime diversity beta-group-significance \
              --i-distance-matrix {input.aitchison_dist_mat} \
              --m-metadata-file {input.metadata} \
              --m-metadata-column $column \
              --p-method {params.beta_method} \
              --p-pairwise \
              --o-visualization "{params.outdir}/"$column"/aitchison_group_significance.qzv"
          fi
        done
        """