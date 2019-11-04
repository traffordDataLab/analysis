# Indices of Deprivation 2019 - ward reports

This folder contains reports for Trafford's 21 electoral wards based on the [Indices of Deprivation 2019](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2019) data published by the [Ministry of Housing, Communities & Local Government](https://www.gov.uk/government/organisations/ministry-of-housing-communities-and-local-government). The reports are published in HTML format.

### Relationship between LSOAs and electoral wards
The data for the Indices of Deprivation is provided at Lower-layer Super Output Area (LSOA). Ward boundaries and LSOA boundaries do not always perfectly align and so it is impossible to aggregate from LSOA to ward exactly. Instead a 'best-fit' methodology is used by the [Office for National Statistics (ONS)](http://geoportal.statistics.gov.uk/datasets/500d4283cbe54e3fa7f358399ba3783e_0) to assign LSOAs to the most appropriate ward.

### Building the reports
The template used in the reports is the [R Markdown](https://rmarkdown.rstudio.com/) file **iod_ward_report_template.Rmd**. The individual reports are created by running the build script **build_reports.R**. Once they have been created, the 'Key findings' content is then manually pasted into each report from **key_findings.txt**.
