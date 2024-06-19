rule dada2:
    input:
        seqs = dada2_input_seqs_qza,
        metadata = config["metadata"]
    output:
        table_qza = qiime2_dir("feature_tables", "unfiltered_table.qza"),
        seqs_qza = qiime2_dir("dada2", "rep-seqs.qza"),
        stats_qza = qiime2_dir("dada2", "denoising-stats.qza"),
        table_qzv = qiime2_dir("feature_tables", "unfiltered_table.qzv"),
        seqs_qzv = qiime2_dir("dada2", "rep-seqs.qzv"),
        stats_qzv = qiime2_dir("dada2", "denoising-stats.qzv"),
        freqs_qza = qiime2_dir("sample_frequencies", "unfiltered_frequencies.qza")
    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir("dada2"),
        feature_tables_outdir = qiime2_dir("feature_tables"),
        freqs_outdir = qiime2_dir("sample_frequencies"),
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
        mkdir -p {params.outdir} \
          {params.feature_tables_outdir} \
          {params.freqs_outdir}
        >&2 printf "\nDADA2:\n"
        time qiime dada2 denoise-paired \
          --i-demultiplexed-seqs {input.seqs} \
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
        >&2 printf "\nQZV generation:\n"
        time qiime feature-table summarize \
          --i-table {output.table_qza} \
          --m-sample-metadata-file {input.metadata} \
          --o-visualization {output.table_qzv}
        time qiime feature-table tabulate-sample-frequencies \
          --i-table {output.table_qza} \
          --o-sample-frequencies {output.freqs_qza}
        time qiime feature-table tabulate-seqs \
          --i-data {output.seqs_qza} \
          --o-visualization {output.seqs_qzv}
        time qiime metadata tabulate \
          --m-input-file {output.stats_qza} \
          --o-visualization {output.stats_qzv}
        """