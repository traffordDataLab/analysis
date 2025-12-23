# Indices of Deprivation 2025 - ward reports

This folder contains reports for Trafford's 21 electoral wards based on the [Indices of Deprivation 2025](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2025) data published by the [Ministry of Housing, Communities & Local Government](https://www.gov.uk/government/organisations/ministry-of-housing-communities-and-local-government). The reports are published in HTML format.

## Relationship between LSOAs and electoral wards
The data for the Indices of Deprivation are provided at Lower-layer Super Output Area (LSOA). Ward boundaries and LSOA boundaries do not always perfectly align and so it is impossible to aggregate from LSOA to ward exactly. Instead a 'best-fit' methodology is used by the [Office for National Statistics (ONS)](https://www.ons.gov.uk/) to assign LSOAs to the most appropriate ward. The version used for these reports is the [2021 LSOAs to 2025 Wards and 2025 LAs](https://geoportal.statistics.gov.uk/datasets/ons::lsoa-2021-to-electoral-ward-2025-to-lad-2025-best-fit-lookup-in-ew-v2/about).

## Building the reports
The template used in the reports is the [R Markdown](https://rmarkdown.rstudio.com/) file **iod_ward_report_template.Rmd**. The individual reports are created by running the build script **build_reports.R**.
