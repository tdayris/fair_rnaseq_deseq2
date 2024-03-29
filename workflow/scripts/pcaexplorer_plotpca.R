# __author__ = "Thibault Dayris"
# __copyright__ = "Copyright 2020, Thibault Dayris"
# __email__ = "thibault.dayris@gustaveroussy.fr"
# __license__ = "MIT"

# This script takes a deseq2 transform object and performs
# a pca on it before plotting requested axes

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
dst_path <- base::as.character(
  x = snakemake@input[["dst"]]
)
dst <- base::readRDS(file = dst_path)
print(head(dst))

# Load extra parameters
extra <- "x = dst"
if ("extra" %in% names(snakemake@params)) {
  extra <- base::paste(
    extra,
    snakemake@params[["extra"]],
    sep = ", "
  )
}

command <- base::paste0(
  "pcaExplorer::pcaplot(",
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