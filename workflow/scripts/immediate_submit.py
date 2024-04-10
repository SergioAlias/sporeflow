#!/usr/bin/env python3

# Sergio Alías, 2024-02-06
# Last modified 2024-02-06

# Adapted from -> https://ulhpc-tutorials.readthedocs.io/en/latest/bio/snakemake/#immediate_submit

# Script for  to immediately submit all jobs to the cluster and
# tell the scheduler about the dependencies so they run in the
# right order. It helps parsing the job submission message from
# Slurm cleanly

# This script now also takes care of all the other Slurm options,
# so you don't need to define SLURM_ARGS anymore in the shell.

import os
import sys

from snakemake.utils import read_job_properties

# last command-line argument is the job script
jobscript = sys.argv[-1]

# all other command-line arguments are the dependencies
dependencies = set(sys.argv[1:-1])

# parse the job script for the job properties that are encoded by snakemake within
job_properties = read_job_properties(jobscript)

# collect all command-line options in an array
cmdline = ["sbatch"]

# set all the slurm submit options as before (MODIFIED BY SERGIO)
slurm_args = " --mem {memory} -c {ncpus} -t {time} -J {jobname} -o {output} -e {error} ".format(**job_properties["cluster"])

cmdline.append(slurm_args)

if dependencies:
    cmdline.append("--dependency")
    # only keep numbers in dependencies list
    dependencies = [ x for x in dependencies if x.isdigit() ]
    cmdline.append("afterok:" + ",".join(dependencies))

cmdline.append(jobscript)

os.system(" ".join(cmdline))