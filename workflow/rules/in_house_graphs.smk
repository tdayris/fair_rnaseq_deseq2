rule seaborn_clustermap_samples:
    input:
        counts="tmp/fair_rnaseq_deseq2/deseq2_wald_test/{species}.{build}.{release}/{dge_name}/counts.tsv",
    output:
        png="results/{species}.{build}.{release}/{dge_name}/Graphs/Sample_Heatmap.png",
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 1024,
        runtime=lambda wildcards, attempt: attempt * 10,
        tmpdir="tmp",
    log:
        "logs/fair_rnaseq_deseq2/seaborn_clustermap_sample/{dge_name}.{species}.{build}.{release}.log",
    benchmark:
        "benchmark/fair_rnaseq_deseq2/seaborn_clustermap_sample/{dge_name}.{species}.{build}.{release}.tsv"
    params:
        ...,
