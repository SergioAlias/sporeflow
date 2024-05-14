rule dada2:
    input:
        config["outdir"] + "/" + config["proj_name"] + "/qiime2/itsxpress/its_seqs.qza"
    output:
        table_qza = config["outdir"] + "/" + config["proj_name"] + "/qiime2/dada2/table.qza",
        seqs_qza = config["outdir"] + "/" + config["proj_name"] + "/qiime2/dada2/rep-seqs.qza",
        stats_qza = config["outdir"] + "/" + config["proj_name"] + "/qiime2/dada2/denoising-stats.qza",
        table_qzv = config["outdir"] + "/" + config["proj_name"] + "/qiime2/dada2/table.qzv",
        seqs_qzv = config["outdir"] + "/" + config["proj_name"] + "/qiime2/dada2/rep-seqs.qzv",
        stats_qzv = config["outdir"] + "/" + config["proj_name"] + "/qiime2/dada2/denoising-stats.qzv"
    conda:
        "../envs/qiime2-amplicon-2024.2-py38-linux-conda.yml"
    params:
        outdir = config["outdir"] + "/" + config["proj_name"] + "/qiime2/dada2",
        trimleft_f = config["dada2_trim_left_f"],
        trimleft_r = config["dada2_trim_left_r"],
        trunclen_f = config["dada2_trunc_len_f"],
        trunclen_r = config["dada2_trunc_len_r"],
        max_ee_f = config["dada2_max_ee_f"],
        max_ee_r = config["dada2_max_ee_r"],
        trunc_q = config["dada2_trunc_q"],
        min_overlap = config["dada2_min_overlap"],
        nthreads = config["dada2_n_threads"]
    shell:
        """
        mkdir -p {params.outdir}
        time qiime dada2 denoise-paired \
          --i-demultiplexed-seqs {input} \
          --p-trim-left-f {params.trimleft_f} \
          --p-trim-left-r {params.trimleft_r} \
          --p-trunc-len-f {params.trunclen_f} \
          --p-trunc-len-r {params.trunclen_r} \
          --p-max-ee-f {params.max_ee_f} \
          --p-max-ee-r {params.max_ee_r} \
          --p-trunc-q {params.trunc_q} \
          --p-min-overlap {params.min_overlap} \
          --p-n-threads {params.nthreads} \
          --o-table {output.table_qza} \
          --o-representative-sequences {output.seqs_qza} \
          --o-denoising-stats {output.stats_qza}
        time qiime feature-table summarize \
          --i-table {output.table_qza} \
          --o-visualization {output.table_qzv}
        time qiime feature-table tabulate-seqs \
          --i-data {output.seqs_qza} \
          --o-visualization {output.seqs_qzv}
        time qiime metadata tabulate \
          --m-input-file {output.stats_qza} \
          --o-visualization {output.stats_qzv}
        """