rule diversity:
    input:
        expand(os.path.join(code_dir, "metadata_{col}.tsv"), col = META_COLS),
        metadata = config["metadata"],
        table = qiime2_dir("feature_tables", "{feat_table}table.qza")
    output:
        rarefaction = qiime2_dir("diversity", "{feat_table}rarefaction_curves.qzv"),
        rarefied_table = qiime2_dir("diversity", "{feat_table}rarefied_table.qza"),
        obs_feat_vector = qiime2_dir("diversity", "{feat_table}observed_features_vector.qza"),
        shannon_vector = qiime2_dir("diversity", "{feat_table}shannon_vector.qza"),
        evenness_vector = qiime2_dir("diversity", "{feat_table}evenness_vector.qza"),
        jaccard_dist_mat = qiime2_dir("diversity", "{feat_table}jaccard_distance_matrix.qza"),
        bray_curtis_dist_mat = qiime2_dir("diversity", "{feat_table}bray_curtis_distance_matrix.qza"),
        jaccard_pcoa = qiime2_dir("diversity", "{feat_table}jaccard_pcoa_results.qza"),
        bray_curtis_pcoa = qiime2_dir("diversity", "{feat_table}bray_curtis_pcoa_results.qza"),
        jaccard_emperor = qiime2_dir("diversity", "{feat_table}jaccard_emperor.qzv"),
        bray_curtis_emperor = qiime2_dir("diversity", "{feat_table}bray_curtis_emperor.qzv")
    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir("diversity"),
        metadir = code_dir,
        metacol = lambda w: "{}".replace('sp_collapsed_', '').replace('_', '').format(w.feat_table),
        max_depth = config["diveristy_rarefaction_max_depth"],
        steps = config["diversity_rarefaction_steps"],
        iterations = config["diversity_rarefaction_iterations"],
        sampling_depth = config["diversity_sampling_depth"],
        nthreads = config["diversity_beta_n_threads"]
    wildcard_constraints:
        feat_table = ".*"
    shell:
        """
        mkdir -p {params.outdir}
        if [ -z "{params.metacol}" ]; then
          metafile="{input.metadata}"
        else
          metafile="{params.metadir}/metadata_{params.metacol}.tsv"
        fi
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
          --m-metadata-file $metafile \
          --o-rarefied-table {output.rarefied_table} \
          --o-observed-features-vector {output.obs_feat_vector} \
          --o-shannon-vector {output.shannon_vector} \
          --o-evenness-vector {output.evenness_vector} \
          --o-jaccard-distance-matrix {output.jaccard_dist_mat} \
          --o-bray-curtis-distance-matrix {output.bray_curtis_dist_mat} \
          --o-jaccard-pcoa-results {output.jaccard_pcoa} \
          --o-bray-curtis-pcoa-results {output.bray_curtis_pcoa} \
          --o-jaccard-emperor {output.jaccard_emperor} \
          --o-bray-curtis-emperor {output.bray_curtis_emperor}
        """