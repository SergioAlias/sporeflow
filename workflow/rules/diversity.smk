rule diversity:
    input:
        table = qiime2_dir("feature_tables", "filtered_table.qza"),
        metadata = config["metadata"],
        taxonomy = qiime2_dir("taxonomy", "taxonomy.qza"),
        freqs_json = qiime2_dir("sample_frequencies", "freqs.json")
    output:
        rarefaction = qiime2_dir("diversity", "rarefaction_curves.qzv"),
        rarefied_table = qiime2_dir("diversity", "rarefied_table.qza"),
        obs_feat_vector = qiime2_dir("diversity", "observed_features_vector.qza"),
        shannon_vector = qiime2_dir("diversity", "shannon_vector.qza"),
        evenness_vector = qiime2_dir("diversity", "evenness_vector.qza"),
        jaccard_dist_mat = qiime2_dir("diversity", "jaccard_distance_matrix.qza"),
        bray_curtis_dist_mat = qiime2_dir("diversity", "bray_curtis_distance_matrix.qza"),
        jaccard_pcoa = qiime2_dir("diversity", "jaccard_pcoa_results.qza"),
        bray_curtis_pcoa = qiime2_dir("diversity", "bray_curtis_pcoa_results.qza"),
        jaccard_emperor = qiime2_dir("diversity", "jaccard_emperor.qzv"),
        bray_curtis_emperor = qiime2_dir("diversity", "bray_curtis_emperor.qzv"),
        simpson_vector = qiime2_dir("diversity", "simpson_vector.qza"),
        chao1_vector = qiime2_dir("diversity", "chao1_vector.qza"),
        aitchison_dist_mat = qiime2_dir("diversity", "aitchison_distance_matrix.qza"),
        aitchison_pcoa = qiime2_dir("diversity", "aitchison_pcoa_results.qza"),
        aitchison_emperor = qiime2_dir("diversity", "aitchison_emperor.qzv"),
        gemelli_dist_mat = qiime2_dir("diversity", "gemelli_distance_matrix.qza"),
        gemelli_rpca = qiime2_dir("diversity", "gemelli_rpca_results.qza"),
        gemelli_emperor = qiime2_dir("diversity", "gemelli_emperor.qzv")

    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir("diversity"),
        max_depth = diversityGetDepth("filtered", "highest", False),
        steps = config["diversity_rarefaction_steps"],
        iterations = config["diversity_rarefaction_iterations"],
        sampling_depth = diversityGetDepth("filtered", "lowest", True),
        gemelli_nfeat = config["diversity_beta_gemelli_nfeatures"],
        nthreads = config["diversity_beta_n_threads"]
    shell:
        """
        mkdir -p {params.outdir}
        >&2 printf "\nUsing table: {input.table}\n"
        >&2 printf "\nMax depth: {params.max_depth}\n"
        >&2 printf "\nSampling depth: {params.sampling_depth}\n"
        >&2 printf "\nAlpha rarefaction:\n"
        time qiime diversity alpha-rarefaction \
          --i-table {input.table} \
          --p-max-depth {params.max_depth} \
          --p-steps {params.steps} \
          --p-iterations {params.iterations} \
          --o-visualization {output.rarefaction}
        >&2 printf "\nDiversity core metrics:\n"
        time qiime diversity core-metrics \
          --i-table {input.table} \
          --p-sampling-depth {params.sampling_depth} \
          --p-n-jobs {params.nthreads} \
          --m-metadata-file {input.metadata} \
          --o-rarefied-table {output.rarefied_table} \
          --o-observed-features-vector {output.obs_feat_vector} \
          --o-shannon-vector {output.shannon_vector} \
          --o-evenness-vector {output.evenness_vector} \
          --o-jaccard-distance-matrix {output.jaccard_dist_mat} \
          --o-bray-curtis-distance-matrix {output.bray_curtis_dist_mat} \
          --o-jaccard-pcoa-results {output.jaccard_pcoa} \
          --o-bray-curtis-pcoa-results {output.bray_curtis_pcoa} \
          --o-jaccard-emperor {output.jaccard_emperor} \
          --o-bray-curtis-emperor {output.bray_curtis_emperor} \
          --no-recycle
        >&2 printf "\nAlpha: Simpson index (not included in core metrics):\n"
        time qiime diversity alpha \
          --i-table {output.rarefied_table} \
          --p-metric simpson \
          --o-alpha-diversity {output.simpson_vector} \
          --no-recycle
        >&2 printf "\nAlpha: Chao1 index (not included in core metrics):\n"
        time qiime diversity alpha \
          --i-table {output.rarefied_table} \
          --p-metric chao1 \
          --o-alpha-diversity {output.chao1_vector} \
          --no-recycle
        >&2 printf "\nBeta: Aitchison distance (not included in core metrics):\n"
        time qiime diversity beta \
          --i-table {input.table} \
          --p-metric aitchison \
          --p-pseudocount 1 \
          --o-distance-matrix {output.aitchison_dist_mat} \
          --no-recycle
        >&2 printf "\nBeta: Aitchison distance PCoA and Emperor plot:\n"
        time qiime diversity pcoa \
          --i-distance-matrix {output.aitchison_dist_mat} \
          --o-pcoa {output.aitchison_pcoa}
        time qiime emperor plot \
          --i-pcoa {output.aitchison_pcoa} \
          --m-metadata-file {input.metadata} \
          --o-visualization {output.aitchison_emperor}
        >&2 printf "\nBeta: Aitchison without pesudocount with Gemelli (not included in core metrics):\n"
        time qiime gemelli rpca \
          --i-table {input.table} \
          --p-min-sample-count 0 \
          --p-min-feature-count 0 \
          --p-min-feature-frequency 0 \
          --p-n-components 3 \
          --p-max-iterations 5 \
          --o-distance-matrix {output.gemelli_dist_mat} \
          --o-biplot {output.gemelli_rpca}
        >&2 printf "\nBeta: Aitchison (Gemelli) Emperor biplot:\n"
        time qiime emperor biplot \
          --i-biplot {output.gemelli_rpca} \
          --m-sample-metadata-file {input.metadata} \
          --m-feature-metadata-file {input.taxonomy} \
          --p-number-of-features {params.gemelli_nfeat} \
          --o-visualization {output.gemelli_emperor}
        """