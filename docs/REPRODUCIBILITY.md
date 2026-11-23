# Reproducing the project

## Prerequisites

R and RStudio, plus the packages installed by `source("INSTALAR_DEPENDENCIAS.R")`:

- `rpart`
- `rpart.plot`
- `brickset` (the published output used **2026.0.0**)

## Files that must be downloaded separately

The public repository does **not** bundle third-party raw catalogues. Download `sets.csv.gz` and `themes.csv.gz` from [Rebrickable](https://rebrickable.com/downloads/) and place them in `dados/originais/`. Alternatively, run `source("scripts/00_obter_dados_rebrickable.R")` to download the latest versions if missing.

The exact published snapshot had:

| File | MD5 |
|---|---|
| `sets.csv.gz` | `f28b85fb54583272aabb0ca56cf81162` |
| `themes.csv.gz` | `1d7f14a5ae1568f6ea2360ea141e343d` |
| `lego_financas_2010_2025_conferencia.csv` | `183ab042abc9f4ef0c5848b361e2c60e` |

The published metrics were produced using that snapshot, so downloading today's catalogue **can change record counts and results**. The `brickset` package also contains version-dependent age data. The small derived results and figures included here are a stable reference for what was reported.

## Run

1. Open `Projeto_LEGO_2010_2025.Rproj` in RStudio.
2. Run `source("INSTALAR_DEPENDENCIAS.R")` if necessary.
3. Provide the raw catalogue files as described above.
4. Run `source("00_EXECUTAR_TUDO.R")`.
5. Inspect generated CSVs and PNGs, then the final data integrity check.

Avoid using `setwd()` to arbitrary absolute paths; all project scripts assume the RStudio project root. The main routine runs all nine analytical scripts and the integrity check last.

## Common failures

- **Missing `sets.csv.gz` or `themes.csv.gz`:** place the Rebrickable files in `dados/originais/`.
- **Missing `brickset` package:** run the dependencies installer.
- **Unexpected totals:** verify the catalogue snapshot checksum and package version.
- **Missing plots:** verify the current working directory and whether image devices can be opened.
