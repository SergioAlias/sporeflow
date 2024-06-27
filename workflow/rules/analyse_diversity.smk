rule analyse_diversity:
    input:
        metadata = config["metadata"],
        obs_feat_vector = qiime2_dir("diversity", "observed_features_vector.qza"),
        shannon_vector = qiime2_dir("diversity", "shannon_vector.qza"),
        evenness_vector = qiime2_dir("diversity", "evenness_vector.qza"),
        simpson_vector = qiime2_dir("diversity", "simpson_vector.qza"),
        jaccard_dist_mat = qiime2_dir("diversity", "jaccard_distance_matrix.qza"),
        bray_curtis_dist_mat = qiime2_dir("diversity", "bray_curtis_distance_matrix.qza"),
        aitchison_dist_mat = qiime2_dir("diversity", "aitchison_distance_matrix.qza")
    output:
        obs_feat_sign = qiime2_dir("group_significances", "observed_features_group_significance.qzv"),
        shannon_sign = qiime2_dir("group_significances", "shannon_group_significance.qzv"),
        evenness_sign = qiime2_dir("group_significances", "evenness_group_significance.qzv"),
        simpson_sign = qiime2_dir("group_significances", "simpson_group_significance.qzv"),
        jaccard_sign = qiime2_dir("group_significances", "jaccard_group_significance.qzv"),
        bray_curtis_sign = qiime2_dir("group_significances", "bray_curtis_group_significance.qzv"),
        aitchison_sign = qiime2_dir("group_significances", "aitchison_group_significance.qzv")
    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir("group_significances"),
        meta_col = config["abundance_meta_col"],
        beta_method = config["diversity_beta_group_significance_method"]
    shell:
        """
        mkdir -p {params.outdir}
        >&2 printf "\nAlpha group significance: Observed features\n"
        time qiime diversity alpha-group-significance \
          --i-alpha-diversity {input.obs_vector} \
          --m-metadata-file {input.metadata} \
          --o-visualization {output.obs_feat_sign}
        >&2 printf "\nAlpha group significance: Shannon\n"
        time qiime diversity alpha-group-significance \
          --i-alpha-diversity {input.shannon_vector} \
          --m-metadata-file {input.metadata} \
          --o-visualization {output.shannon_sign}
        >&2 printf "\nAlpha group significance: Evenness\n"
        time qiime diversity alpha-group-significance \
          --i-alpha-diversity {input.evenness_vector} \
          --m-metadata-file {input.metadata} \
          --o-visualization {output.evenness_sign}
        >&2 printf "\nAlpha group significance: Simpson\n"
        time qiime diversity alpha-group-significance \
          --i-alpha-diversity {input.simpson_vector} \
          --m-metadata-file {input.metadata} \
          --o-visualization {output.simpson_sign}
        >&2 printf "\nBeta group significance: Jaccard\n"
        time qiime diversity beta-group-significance \
          --i-distance-matrix {input.jaccard_dist_mat} \
          --m-metadata-file {input.metadata} \
          --m-metadata-column {params.meta_col} \
          --p-method {params.beta_method} \
          --p-pairwise \
          --o-visualization {output.jaccard_sign}
        >&2 printf "\nBeta group significance: Bray-Curtis\n"
        time qiime diversity beta-group-significance \
          --i-distance-matrix {input.bray_curtis_dist_mat} \
          --m-metadata-file {input.metadata} \
          --m-metadata-column {params.meta_col} \
          --p-method {params.beta_method} \
          --p-pairwise \
          --o-visualization {output.bray_curtis_sign}
        >&2 printf "\nBeta group significance: Aitchison\n"
        time qiime diversity beta-group-significance \
          --i-distance-matrix {input.aitchison_dist_mat} \
          --m-metadata-file {input.metadata} \
          --m-metadata-column {params.meta_col} \
          --p-method {params.beta_method} \
          --p-pairwise \
          --o-visualization {output.aitchison_sign}
        """