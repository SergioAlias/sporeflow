rule adonis:
    input:
        metadata = config["metadata"],
        jaccard_dist_mat = qiime2_dir("diversity", "jaccard_distance_matrix.qza"),
        bray_curtis_dist_mat = qiime2_dir("diversity", "bray_curtis_distance_matrix.qza"),
        aitchison_dist_mat = qiime2_dir("diversity", "aitchison_distance_matrix.qza"),
        gemelli_dist_mat = qiime2_dir("diversity", "gemelli_distance_matrix.qza")
    output:
        jaccard_adonis = qiime2_dir("group_significances", "adonis", "Formula:" + config["adonis_formula"], "jaccard_adonis.qzv"),
        bray_curtis_adonis = qiime2_dir("group_significances", "adonis", "Formula:" + config["adonis_formula"], "bray_curtis_adonis.qzv"),
        aitchison_adonis = qiime2_dir("group_significances", "adonis", "Formula:" + config["adonis_formula"], "aitchison_adonis.qzv"),
        gemelli_adonis = qiime2_dir("group_significances", "adonis", "Formula:" + config["adonis_formula"], "gemelli_adonis.qzv")
    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir("group_significances", "adonis", "Formula:" + config["adonis_formula"]),
        adonis_formula = config["adonis_formula"]
    shell:
        """
        mkdir -p {params.outdir}
        >&2 printf "\nAdonis in vegan-R: Jaccard\n"
        time qiime diversity adonis \
          --i-distance-matrix {input.jaccard_dist_mat} \
          --m-metadata-file {input.metadata} \
          --p-formula "{params.adonis_formula}" \
          --p-permutations 999 \
          --p-n-jobs 1 \
          --o-visualization {output.jaccard_adonis}
        >&2 printf "\nAdonis in vegan-R: Bray-Curtis\n"
        time qiime diversity adonis \
          --i-distance-matrix {input.bray_curtis_dist_mat} \
          --m-metadata-file {input.metadata} \
          --p-formula "{params.adonis_formula}" \
          --p-permutations 999 \
          --p-n-jobs 1 \
          --o-visualization {output.bray_curtis_adonis}
        >&2 printf "\nAdonis in vegan-R: Aitchison\n"
        time qiime diversity adonis \
          --i-distance-matrix {input.aitchison_dist_mat} \
          --m-metadata-file {input.metadata} \
          --p-formula "{params.adonis_formula}" \
          --p-permutations 999 \
          --p-n-jobs 1 \
          --o-visualization {output.aitchison_adonis}
        >&2 printf "\nAdonis in vegan-R: Gemelli\n"
        time qiime diversity adonis \
          --i-distance-matrix {input.gemelli_dist_mat} \
          --m-metadata-file {input.metadata} \
          --p-formula "{params.adonis_formula}" \
          --p-permutations 999 \
          --p-n-jobs 1 \
          --o-visualization {output.gemelli_adonis}
        """