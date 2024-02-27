module fair_rnaseq_salmon_quant:
    snakefile:
        github("tdayris/fair_fastqc_multiqc", path="workflow/Snakefile", tag="1.0.2")
    config:
        {**config, "load_fastqc_multiqc": False, "load_genome_indexer": False}


use rule * from fair_rnaseq_salmon_quant
