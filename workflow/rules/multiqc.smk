rule multiqc:
    input:
        multiqc_input
    output:
        report = multiqc_dir("multiqc_report.html")
    conda:
        conda_qc
    params:
        outdir = multiqc_dir(),
        fastqc_before_outdir = fastqc_before_dir(),
        trim_logdir = cutadapt_logdir(),
        fastqc_after_outdir = fastqc_after_dir(),
        yaml_config = multiqc_template,
        cutadapted = config["use_cutadapt"]
    shell:
        """
        searchdirs=()
        searchdirs+=({params.fastqc_before_outdir})
        if [[ {params.cutadapted} == "True" ]]; then
          searchdirs+=({params.trim_logdir})
          searchdirs+=({params.fastqc_after_outdir})
        fi
        mkdir -p {params.outdir}
        time multiqc \
          --force \
          "${{searchdirs[@]}}" \
          --config {params.yaml_config} \
          --outdir {params.outdir}
        """