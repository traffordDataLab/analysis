
library(tidyverse) ; library(httr) ; library(jsonlite) ; library(zoo)

#House of Commons Library MSOA Names
# URL: https://visual.parliament.uk/msoanames
# Licence: Open Government Licence

lookup <- read_csv("https://visual.parliament.uk/msoanames/static/MSOA-Names-Latest.csv") %>%
  filter(Laname=="Trafford")

#QS203EW - Country of birth (detailed), Census 2011, ONS
# URL: https://www.nomisweb.co.uk
# Licence: Open Government Licence

#Country of Birth Msoa

df <- read_csv("https://www.nomisweb.co.uk/api/v01/dataset/NM_524_1.data.csv?date=latest&geography=1245709510...1245709537&rural_urban=0&cell=2,9...13,17...22,24...27,29,30,34...36,38...43,46,47,49...51,53...57,59...61,64...67,69,70,72,74...77&measures=20100")

cob2011 <- df %>%
  left_join(lookup %>% select(msoa11cd,msoa11nm,msoa11hclnm), by = c("GEOGRAPHY_CODE" = "msoa11cd")) %>%
  filter(OBS_VALUE != 0) %>%
  select(area_name = msoa11hclnm,
         country_of_birth = CELL_NAME,
         value = OBS_VALUE,
         order = CELL_SORTORDER) 

write_csv(cob2011,"data/cob2011_msoa.csv")

cobstats <- cob2011 %>%
  group_by(country_of_birth) %>%
  #group_by(area_name) %>%
  summarise(value = sum(value))

#Country of Birth Trafford

df <- read_csv("https://www.nomisweb.co.uk/api/v01/dataset/NM_524_1.data.csv?date=latest&geography=1946157089&rural_urban=0&cell=0,2,9...14,32,33,37,43,45,48,52,58,61,63,66...68,72,73,76&measures=20100") %>%
  select(area_name = GEOGRAPHY_NAME, country_of_birth = CELL_NAME, value = OBS_VALUE)

cob_nonUK <- df %>%
  filter(!country_of_birth %in% c("All categories: Country of birth", "Europe: United Kingdom: Total")) %>%
  summarise(total=sum(value))

percent <- df %>%
  filter(country_of_birth == "All categories: Country of birth") %>%
  mutate(percent=(cob_nonUK$total/value)*100)
  
#NINO 

# Source: DWP, Stat-Explore
# URL: https://stat-xplore.dwp.gov.uk/webapi/metadata/NINO/NINO.html
# Licence: Open Government Licence

# add your API key
api_key <- ""

# API endpoint
path <- "https://stat-xplore.dwp.gov.uk/webapi/rest/v1/table"


#NINO Msoa countries year

query <- list(database = unbox("str:database:NINO"),
              measures = "str:count:NINO:f_NINO",
              dimensions = c("str:field:NINO:f_NINO:MSOA_CODE",
                             "str:field:NINO:f_NINO:QTR",
                             "str:field:NINO:f_NINO:NEWNAT"
              ) %>% matrix(),
              recodes = list(
                `str:field:NINO:f_NINO:MSOA_CODE` = list(
                  map = as.list(paste0("str:value:NINO:f_NINO:MSOA_CODE:V_C_MASTERGEOG11_MSOA_TO_LA_NI:E0", seq(2001259, 2001286, 1))), total = unbox(TRUE)),
                `str:field:NINO:f_NINO:QTR` = list(
                  map = as.list(paste0("str:value:NINO:f_NINO:QTR:c_CALYR:",seq(10,20,1)))),
                `str:field:NINO:f_NINO:NEWNAT` = list(
                  map = as.list(paste0("str:value:NINO:f_NINO:NEWNAT:C_NINO_COUNTRY:",c(101,102,103,104,105,106,107,108,109,110,111,112,113,114,201,202,203,204,205,206,207,208,211,212,209,210,213,301,302,303,304,305,306,307,308,309,310,311,312,314,315,316,317,318,319,320,321,324,325,326,327,603,708,501,502,504,515,516,517,519,522,524,531,534,535,536,537,538,539,540,543,547,509,510,511,518,520,521,528,544,505,506,513,530,532,542,548,551,507,508,512,514,523,525,529,533,541,545,546,402,403,404,405,406,407,408,409,410,411,412,413,414,415,416,418,419,420,421,422,423,424,425,426,427,429,430,431,433,434,436,437,438,439,440,441,442,443,444,445,446,447,449,450,451,453,455,456,457,401,417,428,432,435,448,452,454,601,602,639,652,604,605,606,607,608,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,628,629,630,631,632,633,634,635,636,637,638,640,641,642,643,644,645,646,647,648,650,651,653,654,655,549,550,649,701,702,703,704,705,706,707,709,710,711,712,713,714,715,716,717,718,719,720,721,722,723,999))), total = unbox(TRUE))
              )) %>% toJSON()

request <- POST(
  url = path,
  body = query,
  config = add_headers(APIKey = api_key),
  encode = "json")

response <- fromJSON(content(request, as = "text"), flatten = TRUE)

# extract list items and convert to a dataframe
tabnames <- response$fields$items %>% map(~.$labels %>% unlist)
values <- response$cubes[[1]]$values
dimnames(values) <- tabnames

df <- as.data.frame.table(values, stringsAsFactors = FALSE) %>%
  as_tibble() %>% 
  set_names(c(response$fields$label,"value")) %>%
  left_join(lookup%>%select(msoa11cd,msoa11nm,msoa11hclnm), by = c("National - Regional - Admin LA - MSOA (Northern Ireland excluded)" = "msoa11nm")) %>%
  select(area_code=msoa11cd, area_name=msoa11hclnm, registration_period=`Quarter and Year of Registration`, nationality=Nationality, value) %>%
mutate(area_code = ifelse(is.na(area_code),"E08000009",area_code),
       area_name = ifelse(is.na(area_name),"Trafford",area_name),
       nationality = ifelse(nationality == "Total","All nationalities",nationality))
  
noNI <- df %>%
  group_by(nationality) %>%
  summarise(value = sum(value)) %>%
  filter(!value==0)

dfFilter <- df %>%
  filter(nationality %in% noNI$nationality)

nino_msoa <- dfFilter


write_csv(dfFilter,"data/nino_msoa.csv")


#NINO Trafford Countries quarterly

query <- list(database = unbox("str:database:NINO"),
              measures = "str:count:NINO:f_NINO",
              dimensions = c("str:field:NINO:f_NINO:MSOA_CODE",
                             "str:field:NINO:f_NINO:QTR",
                             "str:field:NINO:f_NINO:NEWNAT"
              ) %>% matrix(),
              recodes = list(
                `str:field:NINO:f_NINO:MSOA_CODE` = list(
                  map = as.list(paste0("str:value:NINO:f_NINO:MSOA_CODE:V_C_MASTERGEOG11_LA_TO_REGION_NI:E0", c(8000009)))),
                `str:field:NINO:f_NINO:QTR` = list(
                  map = as.list(paste0("str:value:NINO:f_NINO:QTR:c_QTR:",seq(37,78,1)))),
                `str:field:NINO:f_NINO:NEWNAT` = list(
                  map = as.list(paste0("str:value:NINO:f_NINO:NEWNAT:C_NINO_COUNTRY:",c(101,102,103,104,105,106,107,108,109,110,111,112,113,114,201,202,203,204,205,206,207,208,211,212,209,210,213,301,302,303,304,305,306,307,308,309,310,311,312,314,315,316,317,318,319,320,321,324,325,326,327,603,708,501,502,504,515,516,517,519,522,524,531,534,535,536,537,538,539,540,543,547,509,510,511,518,520,521,528,544,505,506,513,530,532,542,548,551,507,508,512,514,523,525,529,533,541,545,546,402,403,404,405,406,407,408,409,410,411,412,413,414,415,416,418,419,420,421,422,423,424,425,426,427,429,430,431,433,434,436,437,438,439,440,441,442,443,444,445,446,447,449,450,451,453,455,456,457,401,417,428,432,435,448,452,454,601,602,639,652,604,605,606,607,608,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,628,629,630,631,632,633,634,635,636,637,638,640,641,642,643,644,645,646,647,648,650,651,653,654,655,549,550,649,701,702,703,704,705,706,707,709,710,711,712,713,714,715,716,717,718,719,720,721,722,723,999))), total = unbox(TRUE))
              )) %>% toJSON()

request <- POST(
  url = path,
  body = query,
  config = add_headers(APIKey = api_key),
  encode = "json")

response <- fromJSON(content(request, as = "text"), flatten = TRUE)

# extract list items and convert to a dataframe
tabnames <- response$fields$items %>% map(~.$labels %>% unlist)
values <- response$cubes[[1]]$values
dimnames(values) <- tabnames

df <- as.data.frame.table(values, stringsAsFactors = FALSE) %>%
  as_tibble() %>% 
  set_names(c(response$fields$label,"value")) %>%
  mutate(area_code="E08000009") %>%
select(area_code, area_name=`National - Regional - Admin LA - MSOA (Northern Ireland excluded)`, registration_period=`Quarter and Year of Registration`, nationality=Nationality, value) %>%
  mutate(nationality = ifelse(nationality == "Total","All nationalities",nationality))

noNI <- df %>%
  group_by(nationality) %>%
  summarise(value = sum(value)) %>%
  filter(!value==0)

dfFilter <- df %>%
  filter(nationality %in% noNI$nationality) 

nino_trafford_countries <- dfFilter

write_csv(dfFilter,"data/nino_trafford_countries.csv")

#Trafford world area

query <- list(database = unbox("str:database:NINO"),
              measures = "str:count:NINO:f_NINO",
              dimensions = c("str:field:NINO:f_NINO:MSOA_CODE",
                             "str:field:NINO:f_NINO:QTR",
                             "str:field:NINO:f_NINO:NEWNAT"
              ) %>% matrix(),
              recodes = list(
                `str:field:NINO:f_NINO:MSOA_CODE` = list(
                  map = as.list(paste0("str:value:NINO:f_NINO:MSOA_CODE:V_C_MASTERGEOG11_LA_TO_REGION_NI:E0", c(8000009)))),
                `str:field:NINO:f_NINO:QTR` = list(
                  map = as.list(paste0("str:value:NINO:f_NINO:QTR:c_CALYR:",seq(1,20,1)))),
                `str:field:NINO:f_NINO:NEWNAT` = list(
                  map = as.list(paste0("str:value:NINO:f_NINO:NEWNAT:C_NINO_WORLDAREA:",c(1,2,3,4,9))))
              )) %>% toJSON()

request <- POST(
  url = path,
  body = query,
  config = add_headers(APIKey = api_key),
  encode = "json")

response <- fromJSON(content(request, as = "text"), flatten = TRUE)

# extract list items and convert to a dataframe
tabnames <- response$fields$items %>% map(~.$labels %>% unlist)
values <- response$cubes[[1]]$values
dimnames(values) <- tabnames

df <- as.data.frame.table(values, stringsAsFactors = FALSE) %>%
  as_tibble() %>% 
  set_names(c(response$fields$label,"value")) %>%
  filter(!Nationality=="Other / unknown") %>%
  select(area_name='National - Regional - Admin LA - MSOA (Northern Ireland excluded)', registration_period=`Quarter and Year of Registration`, nationality=Nationality, value) 

worldAreaYear <- df

write_csv(df,"data/worldAreaYear.csv")


