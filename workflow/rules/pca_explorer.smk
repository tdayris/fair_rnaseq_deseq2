rule pcaexplorer_plot_pca:
    input:
        dst="tmp/fair_rnaseq_deseq2/deseq2_wald_test/{species}.{build}.{release}/{dge_name}/wald.RDS",
    output:
        png=protected("results/{species}.{build}.{release}/{dge_name}/PCA/PCA.png"),
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 1024,
        time_min=lambda wildcards, attempt: attempt * 15,
        tmpdir="tmp",
    log:
        "logs/fair_rnaseq_deseq2/pcaexplorer_plot_pca/{dge_name}.{species}.{build}.{release}.log",
    benchmark:
        "benchmark/fair_rnaseq_deseq2/pcaexplorer_plot_pca/{dge_name}.{species}.{build}.{release}.tsv"
    params:
        extra=lambda wildcards: get_pcaexplorer_plotpca_params(wildcards),
        w=lookup(dpath="params/png/width", within=config),
        w=lookup(dpath="params/png/height", within=config),
    conda:
        "../envs/pcaexplorer.yaml"
    script:
        "../scripts/pcaexplorer_plotpca.R"


rule pcaexplorer_plot_distribution_expression:
    input:
        dst="tmp/fair_rnaseq_deseq2/deseq2_wald_test/{species}.{build}.{release}/{dge_name}/wald.RDS",
    output:
        png=protected(
            "results/{species}.{build}.{release}/{dge_name}/Graphs/Expression.png"
        ),
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 1024,
        time_min=lambda wildcards, attempt: attempt * 15,
        tmpdir="tmp",
    log:
        "logs/fair_rnaseq_deseq2/pcaexplorer_plot_distribution_expression/{dge_name}.{species}.{build}.{release}.log",
    benchmark:
        "benchmark/fair_rnaseq_deseq2/pcaexplorer_plot_distribution_expression/{dge_name}.{species}.{build}.{release}.tsv"
    params:
        extra=lookup(dpath="params/pcaexplorer/distro_expr", within=config),
        w=lookup(dpath="params/png/width", within=config),
        w=lookup(dpath="params/png/height", within=config),
    conda:
        "../envs/pcaexplorer.yaml"
    script:
        "../scripts/pcaexplorer_distroexpr.R"


rule pcaexplorer_plot_hi_loadings:
    input:
        dds="tmp/fair_rnaseq_deseq2/deseq2_wald_test/{species}.{build}.{release}/{dge_name}/wald.RDS",
        annotation="reference/annotation/{species}.{build}.{release}.id_to_gene.tsv",
    output:
        png=protected(
            "results/{species}.{build}.{release}/{dge_name}/Graphs/Hi_Loadings.png"
        ),
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 1024,
        time_min=lambda wildcards, attempt: attempt * 15,
        tmpdir="tmp",
    log:
        "logs/fair_rnaseq_deseq2/pcaexplorer_plot_hi_loadings/{dge_name}.{species}.{build}.{release}.log",
    benchmark:
        "benchmark/fair_rnaseq_deseq2/pcaexplorer_plot_hi_loadings/{dge_name}.{species}.{build}.{release}.tsv"
    params:
        extra=lookup(dpath="params/pcaexplorer/hi_loadings", within=config),
        w=lookup(dpath="params/png/width", within=config),
        w=lookup(dpath="params/png/height", within=config),
    conda:
        "../envs/pcaexplorer.yaml"
    script:
        "../scripts/pcaexplorer_hiloadings.R"


rule pcaexplorer_limma_quick_pca2go:
    input:
        dds="tmp/fair_rnaseq_deseq2/deseq2_wald_test/{species}.{build}.{release}/{dge_name}/wald.RDS",
    output:
        pc1=protected("results/{species}.{build}.{release}/{dge_name}/PCA/GO_PC1.csv"),
        pc2=protected("results/{species}.{build}.{release}/{dge_name}/PCA/GO_PC2.csv"),
        rds=temp(
            "tmp/fair_rnaseq_deseq2/pcaexplorer_limma_quick_pca2go/{species}.{build}.{release}/{dge_name}.RDS"
        ),
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: attempt * (1024 * 2),
        runtime=lambda wildcards, attempt: attempt * 35,
        tmpdir="tmp",
    log:
        "logs/fair_rnaseq_deseq2/pcaexplorer_limma_quick_pca2go/{dge_name}.{species}.{build}.{release}.log",
    benchmark:
        "benchmark/fair_rnaseq_deseq2/pcaexplorer_limma_quick_pca2go/{dge_name}.{species}.{build}.{release}.tsv"
    params:
        extra=lookup(dpath="params/pcaexplorer/limmaquickpca2go", within=config),
    conda:
        "../envs/pcaexplorer.yaml"
    script:
        "../scripts/pcaexplorer_limmaquickpca2go.R"
