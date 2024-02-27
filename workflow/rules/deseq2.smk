rule dds_from_tximport:
    input:
        txi="tmp/fair_rnaseq_salmon_quant/tximport/{species}.{build}.{release}/SummarizedExperimentObject.RDS",
        colData="",
    output:
        temp(
            "tmp/fair_rnaseq_deseq2/dds_from_tximport/{species}.{build}.{release}/{dge_name}/txi.RDS"
        ),
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: attempt * (1024 * 4),
        runtime=lambda wildcards, attempt: attempt * 35,
        tmpdir="tmp",
    log:
        "logs/fair_rnaseq_deseq2/dds_from_tximport/{dge_name}.{species}.{build}.{release}.log",
    benchmark:
        "benchmark/fair_rnaseq_deseq2/dds_from_tximport/{dge_name}.{species}.{build}.{release}.tsv"
    params:
        formula=lambda wildcards: get_formula(wildcards),
        factor=lambda wildcards: get_factor(wildcards),
        reference_level=lambda wildcards: get_reference_level(wildcards),
        tested_level=lambda wildcards: get_tested_level(wildcards),
        min_counts=lookup(dpath="params/deseq2/min_counts", within=config),
        extra=lookup(dpath="params/deseq2/deseqdataset", within=config),
    wrapper:
        "v3.3.6/bio/deseq2/deseqdataset"


rule deseq2_wald_test:
    input:
        dds="tmp/fair_rnaseq_deseq2/dds_from_tximport/{species}.{build}.{release}/{dge_name}/txi.RDS",
    output:
        wald_rds=temp(
            "tmp/fair_rnaseq_deseq2/deseq2_wald_test/{species}.{build}.{release}/{dge_name}/wald.RDS"
        ),
        wald_tsv=temp(
            "tmp/fair_rnaseq_deseq2/deseq2_wald_test/{species}.{build}.{release}/{dge_name}/wald.tsv"
        ),
        normalized_counts_table=temp(
            "tmp/fair_rnaseq_deseq2/deseq2_wald_test/{species}.{build}.{release}/{dge_name}/counts.tsv"
        ),
        normalized_counts_rds=temp(
            "tmp/fair_rnaseq_deseq2/deseq2_wald_test/{species}.{build}.{release}/{dge_name}/counts.RDS"
        ),
    threads: 20
    resources:
        mem_mb=lambda wildcards, attempt: attempt * (1024 * 4),
        runtime=lambda wildcards, attempt: attempt * 35,
        tmpdir="tmp",
    log:
        "logs/fair_rnaseq_deseq2/deseq2_wald_test/{dge_name}.{species}.{build}.{release}.log",
    benchmark:
        "benchmark/fair_rnaseq_deseq2/deseq2_wald_test/{dge_name}.{species}.{build}.{release}.tsv"
    params:
        deseq_extra=lookup(dpath="params/deseq2/wald", within=config),
        shrink_extra=lookup(dpath="params/deseq2/shrink", within=config),
        results_extra=lookup(dpath="params/deseq2/results", within=config),
        contrast=lambda wildcards: get_contrast(wildcards),
    wrapper:
        "v3.3.6/bio/deseq2/wald"


rule deseq2_extract_intermediar_values:
    input:
        wald="tmp/fair_rnaseq_deseq2/deseq2_wald_test/{species}.{build}.{release}/{dge_name}/wald.RDS",
    output:
        metadata=temp(
            "tmp/fair_rnaseq_deseq2/deseq2_extract_intermediar_values/{species}.{build}.{release}/{dge_name}/metadata.csv"
        ),
        results=temp(
            "tmp/fair_rnaseq_deseq2/deseq2_extract_intermediar_values/{species}.{build}.{release}/{dge_name}/results.csv"
        ),
        filter_theta=temp(
            "tmp/fair_rnaseq_deseq2/deseq2_extract_intermediar_values/{species}.{build}.{release}/{dge_name}/theta.csv"
        ),
    threads: 20
    resources:
        mem_mb=lambda wildcards, attempt: attempt * (1024 * 4),
        runtime=lambda wildcards, attempt: attempt * 35,
        tmpdir="tmp",
    log:
        "logs/fair_rnaseq_deseq2/deseq2_extract_intermediar_values/{dge_name}.{species}.{build}.{release}.log",
    benchmark:
        "benchmark/fair_rnaseq_deseq2/deseq2_extract_intermediar_values/{dge_name}.{species}.{build}.{release}.tsv"
    params:
        shrink_extra=lookup(dpath="params/deseq2/shrink", within=config),
        results_extra=lookup(dpath="params/params/results", within=config),
        contrast=lambda wildcards: get_contrast(wildcards),
    conda:
        "../envs/deseq2.yaml"
    script:
        "../scripts/deseq2_extract_intermediar_values.R"
