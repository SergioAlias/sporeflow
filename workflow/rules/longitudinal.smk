rule longitudinal:
    input:
        metadata = config["metadata"],
        meta_qza = longitudinal_input
    output:
        lme_qzv = qiime2_dir("longitudinal", "linear-mixed-effects.qzv")
    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir("longitudinal"),
        metric = metric_name,
        state_col = config["longitudinal_state_column"],
        ind_id_col = config["longitudinal_individual_id_col"]
    shell:
        """
        mkdir -p {params.outdir}
        >&2 printf "\nLongitudinal: linear mixed effects (LME) model\n"
        time qiime longitudinal linear-mixed-effects \
          --m-metadata-file {input.metadata} \
          --m-metadata-file {input.meta_qza} \
          --p-metric {params.metric} \
          --p-state-column {params.state_col} \
          --p-individual-id-column {params.ind_id_col} \
          --o-visualization {output.lme_qzv}
        """