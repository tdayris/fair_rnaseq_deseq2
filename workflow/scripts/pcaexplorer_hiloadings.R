# __author__ = "Thibault Dayris"
# __copyright__ = "Copyright 2024, Thibault Dayris"
# __email__ = "thibault.dayris@gustaveroussy.fr"
# __license__ = "MIT"

# Perform PCAExplorer hi-loadings analysis from DESeq2 results

# Sink the stderr and stdout to the snakemake log file
# https://stackoverflow.com/a/48173272
log.file <- file(snakemake@log[[1]], open = "wt")
base::sink(log.file)
base::sink(log.file, type = "message")

base::library(package = "DESeq2")        # Differential analysis
base::library(package = "pcaExplorer")   # Handles PCAs
base::library(package = "Cairo")         # Graphic library

# Overload output defaults in order to avoid
# X11 foreward errors on cluster nodes
options(bitmapType = "cairo")

# Load specified input files
# Load DESeq2 table
dds_path <- base::as.character(
  x = snakemake@input[["dds"]]
)
dds <- base::readRDS(file = dds_path)
print(head(dds))


# Load annotation table
annotation_path <- base::as.character(
  x = snakemake@input[["id_to_name"]]
)
annotation <- utils::read.table(
  file = annotation_path,
  header = False,
  sep = ",",
  stringsAsFactors = FALSE
)
base::colnames(annotation) <- c("gene_id", "gene_name")
base::row.names(annotation) <- annotation$gene_id
print(head(annotation))


# Load extra parameters
extra <- "x = dds, annotation = annotation"
if ("extra" %in% names(snakemake@params)) {
  extra <- base::paste(
    extra,
    snakemake@params[["extra"]],
    sep = ", "
  )
}

# Build command line
command <- base::paste0(
  "hi_loadings(",
  extra,
  ")"
)

base::message(command)

# Build plot
w <- 1024
if ("w" %in% base::names(snakemake@params)) {
  w <- base::as.numeric(snakemake@params[["w"]])
}
h <- 768
if ("h" %in% base::names(snakemake@params)) {
  h <- base::as.numeric(snakemake@params[["h"]])
}

png(
  filename = snakemake@output[["png"]],
  width = w,
  height = h,
  units = "px",
  type = "cairo"
)

# Exec pcaexplorer command line
base::eval(
  base::parse(
    text = command
  )
)

dev.off()


# Proper syntax to close the connection for the log file
# but could be optional for Snakemake wrapper
base::sink(type = "message")
base::sink()