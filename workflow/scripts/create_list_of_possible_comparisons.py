# codinf: utf-8

__author__ = "Thibault Dayris"
__copyright__ = "Copyright 2024, Thibault Dayris"
__email__ = "thibault.dayris@gustaveroussy.fr"
__license__ = "MIT"

import itertools
import logging
import pandas

samples: pandas.DataFrame = snakemake.params.samples
non_factor_columns: list[str] = [
    "sample_id",
    "upstream_file",
    "downstream_file",
    "file",
]
min_level_number: int = 2

possible_comparisons: list[dict[str, str]] = []

for factor in samples.columns:
    logging.info(f"Considering {factor} in the DGE analysis...")
    if factor in non_factor_columns:
        logging.info(
            f"Ignoring columns {factor} in sample description, "
            "since this is not a factor."
        )
        continue

    levels_counts = samples[factor].value_counts()
    levels: list[str] = []
    for level, level_count in levels_counts.items():
        if level_count < min_level_number:
            logging.warning(
                f"The level {level} in factor {factor} only has "
                f"{level_count} sample. At least {min_level_number} "
                "are required to conduct a DGE analysis with DESeq2."
            )
        else:
            levels.append(level)

    if len(levels) < 2:
        logging.warning(
            f"The factor {factor} only has {len(levels)} usable level. "
            "At least 2 levels are required to conduct a "
            "DGE analysis with DESeq2."
        )
        continue

    for level1, level2 in itertools.permutations(levels, 2):
        possible_comparisons.append(
            {
                "name": f"DGE_factor_{factor}_comparing_test_{level1}_vs_reference_{level2}",
                "formula": f"~{factor}",
                "test": level1,
                "reference": level2,
            }
        )

coldata: pandas.DataFrame = pandas.DataFrame.from_records(
    possible_comparisons, orient="index"
)
coldata.to_csv(snakemake.output["coldata"], sep=",", header=True, index=False)
