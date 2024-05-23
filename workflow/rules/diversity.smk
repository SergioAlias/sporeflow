rule diversity:
    input:
        metadata = config["metadata"],
        table = config["outdir"] + "/" + config["proj_name"] + "/qiime2/dada2/table.qza"
    output:
        rarefaction = config["outdir"] + "/" + config["proj_name"] + "/qiime2/diversity/rarefaction_curves.qzv",
        rarefied_table = config["outdir"] + "/" + config["proj_name"] + "/qiime2/diversity/rarefied_table.qza",
        obs_feat_vector = config["outdir"] + "/" + config["proj_name"] + "/qiime2/diversity/observed_features_vector.qza",
        shannon_vector = config["outdir"] + "/" + config["proj_name"] + "/qiime2/diversity/shannon_vector.qza",
        evenness_vector = config["outdir"] + "/" + config["proj_name"] + "/qiime2/diversity/evenness_vector.qza",
        jaccard_dist_mat = config["outdir"] + "/" + config["proj_name"] + "/qiime2/diversity/jaccard_distance_matrix.qza",
        bray_curtis_dist_mat = config["outdir"] + "/" + config["proj_name"] + "/qiime2/diversity/bray_curtis_distance_matrix.qza",
        jaccard_pcoa = config["outdir"] + "/" + config["proj_name"] + "/qiime2/diversity/jaccard_pcoa_results.qza",
        bray_curtis_pcoa = config["outdir"] + "/" + config["proj_name"] + "/qiime2/diversity/bray_curtis_pcoa_results.qza",
        jaccard_emperor = config["outdir"] + "/" + config["proj_name"] + "/qiime2/diversity/jaccard_emperor.qzv",
        bray_curtis_emperor = config["outdir"] + "/" + config["proj_name"] + "/qiime2/diversity/bray_curtis_emperor.qzv"
    conda:
        "../envs/qiime2-amplicon-2024.2-py38-linux-conda.yml"
    params:
        outdir = config["outdir"] + "/" + config["proj_name"] + "/qiime2/diversity",
        max_depth = config["diveristy_rarefaction_max_depth"],
        steps = config["diversity_rarefaction_steps"],
        iterations = config["diversity_rarefaction_iterations"],
        sampling_depth = config["diversity_sampling_depth"],
        nthreads = config["diversity_beta_n_threads"]
    shell:
        """
        mkdir -p {params.outdir}
        >&2 echo "Alpha rarefaction"
        time qiime diversity alpha-rarefaction \
          --i-table {input.table} \
          --p-max-depth {params.max_depth} \
          --p-steps {params.steps} \
          --p-iterations {params.iterations} \
          --o-visualization {output.rarefaction}
        >&2 echo "Diversity core metrics"
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
          --o-bray-curtis-emperor {output.bray_curtis_emperor}
        """