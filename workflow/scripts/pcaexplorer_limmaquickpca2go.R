# __author__ = "Thibault Dayris"
# __copyright__ = "Copyright 2024, Thibault Dayris"
# __email__ = "thibault.dayris@gustaveroussy.fr"
# __license__ = "MIT"

# Perform PCAExplorer GO analysis from DESeq2 PCA axes

# Sink the stderr and stdout to the snakemake log file
# https://stackoverflow.com/a/48173272
log.file <- file(snakemake@log[[1]], open = "wt")
base::sink(log.file)
base::sink(log.file, type = "message")

base::library(package = "DESeq2")        # Differential analysis
base::library(package = "pcaExplorer")   # Handles PCAs

# Load specified input files
# Load DESeq2 results
dds_path <- base::as.character(
  x = snakemake@input[["dds"]]
)
dds <- base::readRDS(file = dds_path)
print(head(dds))

dst <- base::as.character(
  x = snakemake@input[["dst"]]
)
dst <- base::readRDS(file = dst_path)
print(head(dst))

# Build command line
extra <- "se = dst"
if ("extra" %in% base::names(snakemake@params)) {
  extra <- base::paste(
    extra,
    snakemake@params[["extra"]],
    sep = ", "
  )
}

command <- base::paste0(
  "pcaExplorer::limmaquickpca2go(",
  extra,
  ")"
)

base::message(command)

# Exec PCAExplorer command
limmaquick <- base::eval(
  base::parse(
    text = command
  )
)

# Save results
utils::write.table(
  x = limmaquick$PC1$posLoad,
  file = snakemake@output[["pc1"]],
  sep = ","
)

utils::write.table(
  x = limmaquick$PC2$posLoad,
  file = snakemake@output[["pc2"]],
  sep = ","
)

base::saveRDS(
  object = limmaquick,
  file = snakemake@output[["rds"]]
)

# Proper syntax to close the connection for the log file
# but could be optional for Snakemake wrapper
base::sink(type = "message")
base::sink()