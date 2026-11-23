# Methodology and statistical interpretation

## Population and preparation

The original Rebrickable catalogue snapshot contains **17,313** records dated 2010–2025. Records with missing/non-positive piece counts and the root categories `Gear`, `Books`, `Collectible Minifigures` are excluded. One special entry, `BIGBOX-1`, is removed from the analytical subset, leaving **9,410** records. This is a catalogue-reference analysis, **not a sales-volume analysis**.

The hierarchy in `themes.csv.gz` is traversed to assign top-level families. Rebrands and taxonomy changes can shift family counts without reflecting identical changes in product supply.

## BI analysis

- Main periods: 2010–2019, 2020–2021, and 2022–2025.
- 'Large' means at least 1,000 pieces. The rule is fixed for descriptive comparison, but not an official LEGO segmentation standard.
- Financial series are from official annual reports in **million DKK**. A catalogue-to-revenue relationship must not be interpreted as product-level revenue or causal evidence.

## BA: decision tree

- Target: `grande` (≥1,000 pieces), else `pequeno`.
- Predictors: `ano` and grouped `familia`. **Piece count must not be a predictor**, because that would directly reveal the class (data leakage).
- Train/validation: 2010–2019 versus 2020–2022 for prior selection by F1.
- Final exploratory fit: 2010–2022, evaluated on 2023–2025. Earlier development reviewed the holdout, so it is **not an untouched confirmatory test**.
- Observed test performance: accuracy **69.81%**, precision **24.02%**, recall **71.70%**, F1 **35.98%**, balanced accuracy **70.63%**. The low precision means many sets flagged as large were actually below the threshold.

## BA: correlation

- Yearly percentage-point changes in large-set share vs revenue growth: Spearman **rho = −0.1179**, **p = 0.6757** (n = 15). No statistically significant association was detected.
- Age-label share vs revenue (2020–2025): **rho = 0.9429**, exact **p = 0.01667** (n = 6).
- Changes in age-label share vs yearly revenue growth: **rho = 0.5**, exact **p = 0.45** (n = 5).

The apparent levels relationship could reflect their **shared time trend**. With very small samples, missing age data and no segment-level sales, the analyses **cannot support causal attribution**.

## Adult market / age limitation

Of 9,410 analytic references, 6,862 (72.92%) have age data under `brickset 2026.0.0`; 371 are marked 18+, 6,491 below 18, and 2,548 have no age information. Age coverage varies by year. The historical age label does not capture all products marketed to adults before its introduction. Exploratory keyword matching also finds false positives and is kept separate from the explicit 18+ classification.
