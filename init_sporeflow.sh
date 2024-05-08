#!/bin/bash

echo "🦠 Running init_sporeflow.sh"

while [[ $CONDA_DEFAULT_ENV ]]; do
    echo "🦠 Deactivating current Conda environment: $CONDA_DEFAULT_ENV"
    conda deactivate
done

if { conda env list | grep 'sporeflow-main'; } >/dev/null 2>&1; then
  echo "🦠 Environment sporeflow-main is already installed."
else
  conda env create --file config/smk_conda.yml
  echo "🦠 Environment sporeflow-main installed successfully."
fi

echo "🦠 Activating environment..."
conda activate sporeflow-main

echo "🦠 Setting aliases..."

## Default njobs is 30. Feel free to change it in run_sporeflow and run_inmediate

alias sf_run='snakemake --use-conda --cluster "sbatch -J {cluster.jobname} -t {cluster.time} --mem {cluster.memory} -c {cluster.ncpus} -o {cluster.output} -e {cluster.error}" --cluster-config config/cluster_config.yml --jobs 30'
alias sf_immediate='snakemake --use-conda --cluster-config config/cluster_config.yml --jobs 30 -pr --immediate-submit --notemp --cluster "python3 workflow/scripts/immediate_submit.py {dependencies}"'
alias sf_draw_dag='snakemake -f --dag | dot -Tpdf > dag.pdf'
alias sf_draw_rulegraph='snakemake -f --rulegraph | dot -Tpdf > rulegraph.pdf'

echo "🦠 Sporeflow loaded successfully!"
echo "    - Use sf_run to run Sporeflow in a Slurm HPC queue system"
echo "    - Use sf_immediate to run Sporeflow and send all jobs to the queue system at once (not recommended)"
echo "    - Use sf_draw_dag to draw a DAG of the workflow in dag.pdf"
echo "    - Use sf_draw_rulegraph to draw a rule graph of the workflow in ruelgraph.pdf"


