rule enhanced_volcano:
    input:
        "tmp/fair_rnaseq_deseq2/deseq2_wald_test/{species}.{build}.{release}/{dge_name}/wald.tsv",
    output:
        protected(
            "results/{species}.{build}.{release}/{dge_name}/Graphs/Volcano_plot.png"
        ),
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: attempt * (1024 * 4),
        runtime=lambda wildcards, attempt: attempt * 35,
        tmpdir="tmp",
    log:
        "logs/fair_rnaseq_deseq2/enhanced_volcano/{dge_name}.{species}.{build}.{release}.log",
    benchmark:
        "benchmark/fair_rnaseq_deseq2/enhanced_volcano/{dge_name}.{species}.{build}.{release}.tsv"
    params:
        extra=lookup(dpath="params/enhanced_volcano", within=config),
        # extra="lab='Gene_id', x='ShrinkedFC', y='adjusted_pvalues'",
        width=1024,
        height=768,
    wrapper:
        "v3.3.6/bio/enhancedvolcano"
