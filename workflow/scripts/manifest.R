#!/usr/bin/env Rscript

# Sergio Alías, 20240227
# Last modified 20240304

# Create manifest file required for QIIME2 to work with the FASTQ files

#--- Libs ---#


#--- Args ---#

args <- commandArgs(trailingOnly = TRUE)

fastq_dir <- args[1]
outdir <- args[2]
end <- args[3]
if (end == "paired"){
  forward <- args[4]
  reverse <- args[5]
  cols <- c("sample-id", "forward-absolute-filepath", "reverse-absolute-filepath")
} else if (end == "single"){
  cols <- c("sample-id", "absolute-filepath")
}

#--- Main ---#

## Manifest dataframe
manifest <- data.frame(matrix(ncol = length(cols), nrow = 0))
colnames(manifest) <- cols

## We get FASTQ filenames and sample names
fastq <- list.files(fastq_dir)
samples <- unique(gsub("_R\\d+_cutadapt.fastq.gz", "", fastq))

## Iterate and get sample names and absolute paths, add them to manifest
for (i in seq_along(samples)){
  sample <- samples[i]
  row_to_add <- data.frame(matrix(ncol = length(cols), nrow = 1))
  colnames(row_to_add) <- cols
  row_to_add$`sample-id` <- sample # TODO ADD SINGLE END HANDLING
  row_to_add$`forward-absolute-filepath` <- paste0(fastq_dir, "/", grep(paste0("^", sample, "_", forward, ".*$"), fastq, value = TRUE))
  row_to_add$`reverse-absolute-filepath` <- paste0(fastq_dir, "/", grep(paste0("^", sample, "_", reverse, ".*$"), fastq, value = TRUE))
  manifest <- rbind(manifest, row_to_add)
}

## Export manifest file

write.table(manifest,
            file = file.path(outdir, "manifest.tsv"),
            sep = "\t",
            row.names = FALSE)
