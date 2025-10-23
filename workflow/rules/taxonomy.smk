rule taxonomy:
    input:
        dada2_seqs = qiime2_dir("dada2", "rep-seqs.qza"),
        metadata = config["metadata"],
        classifier = os.path.join(config["db_dir"], config["db_file"])
    output:
        taxonomy_qza = qiime2_dir("taxonomy", "taxonomy.qza"),
        taxonomy_qzv = qiime2_dir("taxonomy", "taxonomy.qzv")
    conda:
        conda_qiime2
    params:
        outdir = qiime2_dir("taxonomy"),
        nthreads = config["taxonomy_n_threads"],
        confidence = config["taxonomy_confidence"]
    shell:
        """
        mkdir -p {params.outdir}
        >&2 printf "\nTaxonomic classification:\n"
        time qiime feature-classifier classify-sklearn \
          --i-classifier {input.classifier} \
          --i-reads {input.dada2_seqs} \
          --p-n-jobs {params.nthreads} \
          --p-confidence {params.confidence} \
          --o-classification {output.taxonomy_qza}
        >&2 printf "\nQZV generation:\n"
        time qiime metadata tabulate \
          --m-input-file {output.taxonomy_qza} \
          --o-visualization {output.taxonomy_qzv}
        """