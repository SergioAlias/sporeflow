rule cutadapt: # TODO: change everything, add shell QZV generation
    input:
        config["outdir"] + "/" + config["proj_name"] + "/reads_raw/demux.qza"
    output:
        table_qza = config["outdir"] + "/" + config["proj_name"] + "/dada2/table.qza",
        seqs_qza = config["outdir"] + "/" + config["proj_name"] + "/dada2/rep-seqs.qza",
        stats_qza = config["outdir"] + "/" + config["proj_name"] + "/dada2/denoising-stats.qza",
        table_qzv = config["outdir"] + "/" + config["proj_name"] + "/dada2/table.qzv",
        seqs_qzv = config["outdir"] + "/" + config["proj_name"] + "/dada2/rep-seqs.qzv",
        stats_qzv = config["outdir"] + "/" + config["proj_name"] + "/dada2/denoising-stats.qzv"
    conda:
        "../envs/qiime2-amplicon-2024.2-py38-linux-conda.yml"
    params:
        primer_f = config["dada2_trim_left_f"],
        primer_r = config["dada2_trim_left_r"],
        trunclen_f = config["dada2_trunc_len_f"],
        trunclen_r = config["dada2_trunc_len_r"],
        nthreads = config["dada2_n_threads"]
    shell:
        """
        time qiime cutadapt trim-paired
          --demultiplexed-sequences demux.qza \
          --p-front-f CCTACGGGNGGCWGCAG \
          --p-front-r GACTACHVGGGTATCTAATCC \
          --p-match-adapter-wildcards \
          --p-match-read-wildcards \
          --p-discard-untrimmed \
          --o-trimmed-sequences trimmed.qza
        time 
        """