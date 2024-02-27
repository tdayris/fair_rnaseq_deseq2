rule create_coldata:
    output:
        temp(
            "tmp/fair_rnaseq_deseq2/create_coldata/{species}.{build}.{release}/{dge_name}/coldata.csv"
        ),
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 1024,
        runtime=lambda wildcards, attempt: attempt * 10,
        tmpdir="tmp",
    log:
        "logs/fair_rnaseq_deseq2/create_coldata/{dge_name}.{species}.{build}.{release}.log",
    benchmark:
        "benchmark/fair_rnaseq_deseq2/create_coldata/{dge_name}.{species}.{build}.{release}.tsv"
    params:
        samples=samples.copy(),
    conda:
        "../envs/python.yaml"
    script:
        "../scripts/create_coldata.py"
