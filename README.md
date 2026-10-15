# Replication Package

**The Economic Impact of Firms' Political Connections**
Klea Ibrahimi (Central European University), Mihály Fazekas (Central European University), Marc Schiffbauer (World Bank), Todor Galev (Center for the Study of Democracy)

This repository contains the replication materials (scripts and documentation) for the paper. The dataset is shared separately (see [Datasets](#datasets)).

## Contents

```
replication_package/
├── README.md
├── code/
│   └── Political_connections_WBPR_replication.do   # produces all tables
├── data/
│   └── Orbis_pcfirms_elections_merged.dta          # starting dataset (not on GitHub, see below)
└── output/
    └── tables/                                     # created by the do-file
```

## Data Availability Statement

The datasets combine licensed, non-public and public sources (see below). The election data are publicly available. The Orbis firm data are proprietary and subject to the Bureau van Dijk license terms; the political connections dataset is not publicly available. The combined analysis dataset is shared with reviewers on request for replication purposes only.

### Datasets

The replication package uses the Stata dataset **`Orbis_pcfirms_elections_merged.dta`** (≈5.2 GB, firm-year panel, Bulgaria 2010–2018). Download link: **[TO ADD: Google Drive link]**. Place the file in `data/`.

The dataset already contains the political connection variables and TFP (Levinsohn–Petrin and Cobb–Douglas, computed beforehand). The election-based treatment variables and all remaining variables used in the analysis are defined in the do-file. The dataset combines three sources:

**1. Orbis firm-level data**
Orbis firm-level data can be accessed through a subscription to the Orbis database, provided by Bureau van Dijk, a Moody's Analytics company. Access typically requires institutional or individual licensing, and users can retrieve detailed firm-level information such as financials, ownership structures and industry classifications. Academic institutions often provide access to Orbis for faculty and students, subject to the terms of their institutional agreements.

The data cover 2010–2018 and are used to measure firm performance: profits, sales, employment, wages and productivity. Nominal values are deflated with 2-digit NACE sector producer price indices. Productivity is estimated with capital measured as real fixed tangible assets, labour as total number of employees, and intermediate inputs as total material costs. The Orbis ownership data, including the "Global Ultimate Owner" variable, are used to identify indirect ownership links between politically exposed persons and firms.

**2. Political connections dataset**
The political connections dataset was assembled for Bulgaria and is described in detail in Fazekas et al. (2025). A firm is classified as politically connected if its owner or manager held an influential political position at the national or local level between 2010 and 2018 and gained political influence by winning elections. Politically exposed persons (PEPs) and their firm connections are identified by combining:

- *Asset declarations.* Senior public office holders must disclose whether they or a family member co-own or manage a private firm, published by the Commission for Counter Corruption and Forfeiture of Unlawfully Acquired Assets (2021).
- *Global Magnitsky sanctions list.* Maintained by the Office of Foreign Assets Control (OFAC), U.S. Department of the Treasury (2021).
- *Orbis ownership data.* Direct and indirect ownership links via the "Global Ultimate Owner" variable (Bureau van Dijk, 2024).
- *Bulgarian Business Register.* Additional firms co-owned or managed by PEPs and their relatives (Bulgarian Registry Agency, 2024).
- *Offshore leaks and investigative sources.* Foreign business registries, the Panama Papers, Paradise Papers and Luxembourg Leaks, and reports by the International Consortium of Investigative Journalists (2024).

Availability: not publicly available.

**3. Bulgarian election data**
- Original source: Central Electoral Commission of Bulgaria (Централна избирателна комисия), election results publicly available at <https://results.cik.bg> (main site: <https://www.cik.bg>).
- Description: election results scraped for 2007–2019. For each election, the data provide by municipality the candidates, their political parties and vote shares, which identify winning candidates (mayors, municipal councillors and members of parliament). National elections in the sample period: 2009, 2013, 2014 and 2017. Local elections: 2007, 2011 and 2015.
- Accessed: 2022.
- Availability: publicly available online.

## Computational Requirements

- **Software:** Stata 18 (SE or MP). Earlier versions (≥16) should work.
- **User-written packages** (install once from SSC):
  ```stata
  ssc install ftools,    replace
  ssc install reghdfe,   replace
  ssc install estout,    replace
  ssc install coefplot,  replace
  ssc install ietoolkit, replace
  ```
- **Memory:** the starting dataset is ≈5.2 GB; at least 16 GB RAM recommended.

## Instructions

1. Download `Orbis_pcfirms_elections_merged.dta` and place it in `data/`.
2. Open `code/Political_connections_WBPR_replication.do` and set `global root` (Section 0) to the path of this folder. No other paths need to be changed.
3. Run the do-file. Tables are written to `output/tables/`. Tables 2–3 are printed in the Stata log.

## Scripts

The replication package contains one Stata do-file, **`Political_connections_WBPR_replication.do`**, which produces all tables in the paper. It is organised by table, with a clear heading for each followed by the code that produces it. Part A runs the firm-level analysis and Part B the sector-level analysis. Each part starts from the same dataset and first defines the sample and the election-based treatment variables.

| Output | Description | Section in do-file | Output file |
|---|---|---|---|
| Table 1 | Descriptive statistics: outcomes by connection type (all firm-years, no imputation) | Part A, Table 1 | `Table1_descriptives.tex` |
| Table 2 | Descriptive statistics: size, age, sector (firms observed in 2010) | Part A, Tables 2–3 | Stata log |
| Table 3 | Descriptive statistics: NUTS-3 regions (firms observed in 2010) | Part A, Tables 2–3 | Stata log |
| Table 4 | Number of sectors across years | Part B, Table 4 | `Table4_sectors_by_year.csv` |
| Table 5 | Connecting to power and firm performance | Part A, Table 5 | `Table5_firms_connected.csv/.tex` |
| Table 6 | Local vs national elections, firm level | Part A, Table 6 | `Table6_firms_local_national.csv/.tex` |
| Table 7 | Losing connections and firm performance | Part A, Table 7 | `Table7_firms_lost.csv/.tex` |
| Table 8 | Political connections and sector aggregate growth | Part B, Table 8 | `Table8_sectors_connected.csv/.tex` |
| Table 9 | Local vs national elections, sector level | Part B, Table 9 | `Table9_sectors_local_national.csv/.tex` |
| Table 10 (Annex) | Firm performance by election margins | Part A, Table 10 | `Table10_firms_margins.csv/.tex` |
| Figures 1–2 | National and local election timelines | n/a | Illustrations based on the election calendar; not produced by code |

## License

The code is released under the MIT License. The data are subject to the licenses of the original providers (see Data Availability Statement).

## Contact

Klea Ibrahimi: Ibrahimi_Klea@phd.ceu.edu
