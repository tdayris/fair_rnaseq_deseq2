SHELL=/usr/bin/bash
.ONESHELL:
.SHELLFLAGS := -euic
.DELETE_ON_ERROR: linter_info.txt format.txt pipeline.txt

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# List of snakefiles to lint
snakefiles := \
	"../workflow/rules/coldata.smk" \
	"../workflow/rules/common.smk" \
	"../workflow/rules/deseq2.smk" \
	"../workflow/rules/enhanced_volcano.smk" \
	"../workflow/rules/fair_fastqc_multiqc.smk" \
	"../workflow/rules/fair_genome_indexer.smk" \
	"../workflow/rules/fair_rnaseq_salmon_quant.smk" \
	"../workflow/rules/in_house_graphs.smk" \
	"../workflow/rules/pca_explorer.smk" \
	"../workflow/Snakefile"


python_scripts := \
	"../workflow/scripts/create_list_of_possible_comparisons.py" \
	"../workflow/scripts/create_coldata.py"

.PHONY: all
all: report.txt


dag.png: linter.txt
	mamba activate test-snakemake-wrappers && \
	snakemake -s ../workflow/Snakefile \
		--rulegraph --forceall | dot -Tpng > dag.png && \
	cp --verbose dag.png ../dag.png


report.txt: pipeline.txt
	mamba activate test-snakemake-wrappers && \
	snakemake -s ../workflow/Snakefile \
		--report report.zip 2>&1 | tee report.txt


pipeline.txt: linter.txt format.txt black.txt
	mamba activate test-snakemake-wrappers && \
	snakemake -s ../workflow/Snakefile \
		--cores 2 \
		--software-deployment-method conda \
		2>&1 | tee pipeline.txt


format.txt:
	mamba activate test-snakemake-wrappers && \
	snakefmt $(snakefiles) 2>&1 | tee format.txt


linter.txt: format.txt black.txt
	mamba activate test-snakemake-wrappers && \
	snakemake -s ../workflow/Snakefile \
		--lint 2>&1 | tee linter.txt


black.txt:
	mamba activate test-snakemake-wrappers && \
	black $(python_scripts) 2>&1 | tee black.txt

.PHONY: clean
clean:
	rm -rvf linter.txt \
		   format.txt \
		   reference \
		   results \
		   tmp \
		   logs \
		   benchmark \
		   report.html \
		   report.txt \
		   pipeline.txt \
		   genomes.csv \
		   dag.png \
		   black.txt \
		   report.zip 
