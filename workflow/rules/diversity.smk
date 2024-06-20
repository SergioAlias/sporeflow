rule diversity:
    input:
        table = qiime2_dir("feature_tables", "{feat_table}_table.qza"),
        metadata = lambda w: os.path.join(code_dir, META_FILES[w.feat_table]),
        freqs_json = qiime2_dir("sample_frequencies", "freqs.json")
    output:
        rarefaction = qiime2_dir("diversity", "{feat_table}", "{feat_table}_rarefaction_curves.qzv"),
        rarefied_table = qiime2_dir("diversity", "{feat_table}", "{feat_table}_rarefied_table.qza"),
        obs_feat_vector = qiime2_dir("diversity", "{feat_table}", "{feat_table}_observed_features_vector.qza"),
        shannon_vector = qiime2_dir("diversity", "{feat_table}", "{feat_table}_shannon_vector.qza"),
        evenness_vector = qiime2_dir("diversity", "{feat_table}", "{feat_table}_evenness_vector.qza"),
        jaccard_dist_mat = qiime2_dir("diversity", "{feat_table}", "{feat_table}_jaccard_distance_matrix.qza"),
        bray_curtis_dist_mat = qiime2_dir("diversity", "{feat_table}", "{feat_table}_bray_curtis_distance_matrix.qza"),
        jaccard_pcoa = qiime2_dir("diversity", "{feat_table}", "{feat_table}_jaccard_pcoa_results.qza"),
        bray_curtis_pcoa = qiime2_dir("diversity", "{feat_table}", "{feat_table}_bray_curtis_pcoa_results.qza"),
        jaccard_emperor = qiime2_dir("diversity", "{feat_table}", "{feat_table}_jaccard_emperor.qzv"),
        bray_curtis_emperor = qiime2_dir("diversity", "{feat_table}", "{feat_table}_bray_curtis_emperor.qzv"),
        simpson_vector = qiime2_dir("diversity", "{feat_table}", "{feat_table}_simpson_vector.qza"),
        aitchison_dist_mat = qiime2_dir("diversity", "{feat_table}", "{feat_table}_aitchison_distance_matrix.qza"),
        aitchison_pcoa = qiime2_dir("diversity", "{feat_table}", "{feat_table}_aitchison_pcoa_results.qza"),
        aitchison_emperor = qiime2_dir("diversity", "{feat_table}", "{feat_table}_aitchison_emperor.qzv")
    conda:
        conda_qiime2
    params:
        outdir = lambda w: qiime2_dir("diversity", "{}".format(w.feat_table)),
        max_depth = lambda w: diversityGetDepth(w.feat_table, "highest"),
        steps = config["diversity_rarefaction_steps"],
        iterations = config["diversity_rarefaction_iterations"],
        sampling_depth = lambda w: diversityGetDepth(w.feat_table, "lowest"),
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
          --o-alpha-diversity {output.simpson_vector}
        >&2 printf "\nBeta: Aitchison distance (not included in core metrics):\n"
        time qiime diversity beta \
          --i-table {input.table} \
          --p-metric aitchison \
          --p-pseudocount 1 \
          --o-distance-matrix {output.aitchison_dist_mat}
        >&2 printf "\nBeta: Aitchison distance PCoA and Emperor plot:\n"
        time qiime diversity pcoa \
          --i-distance-matrix {output.aitchison_dist_mat} \
          --o-pcoa {output.aitchison_pcoa}
        time qiime emperor plot \
          --i-pcoa {output.aitchison_pcoa} \
          --m-metadata-file {input.metadata} \
          --o-visualization {output.aitchison_emperor}
        """