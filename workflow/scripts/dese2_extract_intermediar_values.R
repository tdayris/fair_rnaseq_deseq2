# __author__ = "Thibault Dayris"
# __copyright__ = "Copyright 2024, Thibault Dayris"
# __email__ = "thibault.dayris@gustaveroussy.fr"
# __license__ = "MIT"

# This script extract intermediar values from DESeq2
# in order to perform later quality controls

# Sink the stderr and stdout to the snakemake log file
# https://stackoverflow.com/a/48173272
log.file <- file(snakemake@log[[1]], open = "wt")
base::sink(log.file)
base::sink(log.file, type = "message")


# Differential analysis
base::library(package = "DESeq2")

# Setting up multithreading if required
parallel <- FALSE
if (snakemake@threads > 1) {
  BiocParallel::register(
    BPPARAM = BiocParallel::MulticoreParam(
      base::as.numeric(snakemake@threads)
    )
  )
  parallel <- TRUE
}

# Load DESeq2 results
wald <- base::readRDS(file = snakemake@input[["wald"]])


contrast <- NULL
if (contrast_length == 1) {
  # Case user provided a result name in the `contrast` parameter
  contrast <- base::as.character(x = snakemake@params[["contrast"]])
  contrast <- base::paste0("name='", contrast[1], "'")

} else if (contrast_length == 2) {
  # Case user provided both tested and reference level
  # In that order! Order matters.
  contrast <- sapply(
    snakemake@params[["contrast"]],
    function(extra) base::as.character(x = extra)
  )
  contrast <- base::paste0(
    "contrast=list('", contrast[1], "', '", contrast[2], "')"
  )

} else if (contrast_length == 3) {
  # Case user provided both tested and reference level,
  # and studied factor.
  contrast <- sapply(
    snakemake@params[["contrast"]],
    function(extra) base::as.character(x = extra)
  )
  contrast <- base::paste0(
    "contrast=c('",
    contrast[1],
    "', '",
    contrast[2],
    "', '",
    contrast[3],
    "')"
  )
}


results_extra <- "object=wald, parallel = parallel"
if ("results_extra" %in% base::names(snakemake@params)) {
  results_extra <- base::paste(
    results_extra,
    contrast,
    snakemake@params[["extra"]],
    sep = ", "
  )
}

results_cmd <- base::paste0("DESeq2::results(", results_extra, ")")
base::message("Result extraction command: ", results_cmd)

results_frame <- base::eval(base::parse(text = results_cmd))

shrink_extra <- base::paste(
  "dds = wald",
  "res = results_frame",
  "contrast = contrast[1]",
  "parallel = parallel",
  "type = 'ashr'",
  sep = ", "
)
if ("shrink_extra" %in% base::names(snakemake@params)) {
  shrink_extra <- base::paste(
    shrink_extra,
    snakemake@params[["shrink_extra"]],
    sep = ", "
  )
}
shrink_cmd <- base::paste0("DESeq2::lfcShrink(", shrink_extra, ")")
base::message("Command line used for log(FC) shrinkage:", shrink_cmd)

results_frame <- base::eval(base::parse(text = results_cmd))
shrink_frame <- base::eval(base::parse(text = shrink_cmd))
results_frame$log2FoldChange <- shrink_frame$log2FoldChange


base::message("Saving Metadata information")
metadata_table <- data.frame(metadata(results_frame)$filterThreshold)
metadata_table$filterTheta <- metadata(results_frame)$filterTheta
metadata_table$alpha <- metadata(results_frame)$alpha
metadata_table$lfcThreshold <- metadata(results_frame)$lfcThreshold

# Saving metadata table
utils::write.table(
  x = metadata_table,
  file = base::as.character(x = snakemake@output[["metadata"]]),
  quote = FALSE,
  sep = ",",
  row.names = TRUE
)

base::message("Saving ThetaFilter information: ")
theta <- metadata(results_frame)$filterNumRej

# Saving theta filter table
utils::write.table(
  x = theta,
  file = base::as.character(x = snakemake@output[["filter_theta"]]),
  quote = FALSE,
  sep = "\t",
  row.names = TRUE
)

base::message("Saving enriched results information")
results_frame$filterThreshold <- results_frame$baseMean > metadata(results_frame)$filterThreshold

utils::write.table(
  x = results_frame,
  file = base::as.character(x = snakemake@output[["results"]]),
  quote = FALSE,
  sep = ",",
  row.names = TRUE
)

