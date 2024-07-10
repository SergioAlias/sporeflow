rule alpha_group_sign:
    input:
        metadata = config["metadata"],
        obs_feat_vector = qiime2_dir("diversity", "observed_features_vector.qza"),
        shannon_vector = qiime2_dir("diversity", "shannon_vector.qza"),
        evenness_vector = qiime2_dir("diversity", "evenness_vector.qza"),
        simpson_vector = qiime2_dir("diversity", "simpson_vector.qza"),
        chao1_vector = qiime2_dir("diversity", "chao1_vector.qza")
    output:
        obs_feat_sign = qiime2_dir("group_significances", "observed_features_group_significance.qzv"),
        shannon_sign = qiime2_dir("group_significances", "shannon_group_significance.qzv"),
        evenness_sign = qiime2_dir("group_significances", "evenness_group_significance.qzv"),
        simpson_sign = qiime2_dir("group_significances", "simpson_group_significance.qzv"),
        chao1_sign = qiime2_dir("group_significances", "chao1_group_significance.qzv")
    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir("group_significances")
    shell:
        """
        mkdir -p {params.outdir}
        >&2 printf "\nAlpha group significance: Observed features\n"
        time qiime diversity alpha-group-significance \
          --i-alpha-diversity {input.obs_feat_vector} \
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
        >&2 printf "\nAlpha group significance: Chao1\n"
        time qiime diversity alpha-group-significance \
          --i-alpha-diversity {input.chao1_vector} \
          --m-metadata-file {input.metadata} \
          --o-visualization {output.chao1_sign}
        """