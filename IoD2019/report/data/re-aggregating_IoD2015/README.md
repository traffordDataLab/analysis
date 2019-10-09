## Re-aggregating IoD2015 to 2019 Local Authority District boundaries

### Method for calculating average scores

1. Multiply each LSOA score by the appropriate population denominator for each domain or sub-domain:    

|Domain |Population Denominator |
|:--- |:---- |
|IMD |total population |
|Income |total population |
|Employment |working age |
|Education, Skills & Training |total population |
|Health |total population |
|Crime |total population |
|Housing |total population |
|Living Environment |total population |
|Income Deprivation Affecting Children Index(IDOACI) |dependent children |
|Income Deprivation Affecting Older People Index (IDOPCI) |older population |

2\. Sum scores by 2019 local authority district    
3\. Sum LSOA population by local authority district     
4\. Divide total score by appropriate local authority district population   
5\. Rank in ascending order

### Data

A CSV file containing the re-aggregated rank of average scores and the proportion of LSOAs within the 1st decile for all local authority districts in England can be found [here](data.csv).

### R script

The R script to re-aggregate the IoD2015 to 2019 local authority district boundaries can be found [here](script.R).

### Sources    

- Appendix A, [IoD2019 Research report](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833947/IoD2019_Research_Report.pdf)     
- Appendix N, [IoD2019 Technical report](https://www.gov.uk/government/publications/english-indices-of-deprivation-2019-technical-report)   
- "15. How can I create my own Indices for different geographies?", [IoD2019 Frequently Asked Questions (FAQs)](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/835119/IoD2019_FAQ.pdf)


