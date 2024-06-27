rule extract_freq_values:
    input:
        qiime2_dir("sample_frequencies", "filtered_frequencies.qza"),
    output:
        freqs_json = qiime2_dir("sample_frequencies", "freqs.json"),
    conda:
        conda_qiime2
    params:
        freqs_dir = qiime2_dir("sample_frequencies")
    shell:
        """
        json_output="{{"
        for freq_qza in {params.freqs_dir}/*.qza; do
            time qiime tools export \
              --input-path $freq_qza \
              --output-path {params.freqs_dir}/tmp
            values=$(awk 'NR >= 3 {{print $2}}' "{params.freqs_dir}/tmp/metadata.tsv")
            highest=$(echo "$values" | sort -n | tail -n 1)
            lowest=$(echo "$values" | sort -n | head -n 1)
            base_name=$(basename "$freq_qza")
            name=$(echo "$base_name" | sed 's/_.*//')
            json_output+='"'$name'": {{"highest": "'$highest'", "lowest": "'$lowest'"}},'
            rm -rf {params.freqs_dir}/tmp
        done
        json_output="${{json_output%,}}}}"
        echo "$json_output" >> {output.freqs_json}
        """ 

