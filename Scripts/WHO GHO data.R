library(tidyverse)
library(jsonlite) #needed to read content from WHO
library(httr)# needed for API
library(glue)

## Global Variables ----

URL_BASE <-  "https://ghoapi.azureedge.net/api/"

## Global Variables ----
SADC <- c("AGO", "NAM", "ZAF", "LSO", "SWZ", 
          "BWA", "ZWE", "ZMB", "MOZ", "MWI", 
          "MDG", "COM", "SYC", "MUS")

EAC <- c("BDI", "KEN", "RWA", "SSD", "TZA", "UGA", "COD")

ECOWAS  <- c("BEN", "BFA", "CPV", "CIV", "GMB", "GHA", "GIN", 
             "GNB", "LBR", "MLI", "NER", "NGA", "SEN", "SLE", "TGO")


COUNTRY <- c(SADC, EAC, ECOWAS)


#INDICATOR <- c("MDG_0000000025")
INDICATOR_TEXT <- "tuberculosis"
INDICATOR_TEXT_TB <- "tb"
INDICATOR <- "TB_"

TITLE <- "All TB Indicators "

# Functions --------------------------

convert_JSON_to_tbl <- function(url){
    data <- GET(url)
    data_df <- fromJSON(content(data, as = "text", encoding = "utf-8"))
    data_tbl <-  map_if(data_df, is.data.frame, list) %>% 
        as_tibble %>% 
        unnest(cols = c(value)) %>% 
        select(-'@odata.context')
}

# Find what you need
all_dimension <-  convert_JSON_to_tbl("https://ghoapi.azureedge.net/api/Dimension") 
all_countries <-  convert_JSON_to_tbl(glue(URL_BASE,"Dimension/COUNTRY/DimensionValues")) %>% 
    select(Code, Title)
all_indicators <-  convert_JSON_to_tbl(glue(URL_BASE,"Indicator")) %>% 
    select(-Language)


#Select a few based on globals
indicators_from_code <- all_indicators %>% 
    filter(grepl(INDICATOR, IndicatorCode, ignore.case = TRUE)) 



indicators_from_text <- all_indicators %>% 
    filter(grepl(INDICATOR_TEXT, IndicatorName, ignore.case = TRUE))

indicators_from_text_tb <- all_indicators %>% 
    filter(grepl(INDICATOR_TEXT_TB, IndicatorName, ignore.case = TRUE))

indicators <- indicators_from_code %>% 
    union(indicators_from_text) %>% 
    union(indicators_from_text_tb)

indicator_codes <- indicators %>% 
    pull(IndicatorCode)


# Pull data
# how to limit by country? write a query so it only includes the correct country

indicator_data <- map(indicator_codes, function(id) {
    response <- GET(
        glue(URL_BASE, id))
    content(response, "text")
})

class(indicator_data)

# Convert the data to a tibble and combine into a single table


indicator_data_tbl <- map_dfr(indicator_data, ~ fromJSON(.x, simplifyVector = TRUE) 
                                      %>% as_tibble() 
                                      %>% unnest(cols = everything())) 


#Clean up columns
# Need to join in countries and indicator details

all_data <- indicator_data_tbl %>% 
    filter(SpatialDim %in% COUNTRY) %>% 
    select(IndicatorCode, TimeDim, SpatialDim, NumericValue, High, Low) %>%
    mutate(region = case_when(SpatialDim %in% SADC ~ "SADC",
                              SpatialDim %in% EAC ~ "EAC",
                              SpatialDim %in% ECOWAS ~ "ECOWAS")) %>% 
    rename(Code = SpatialDim,) %>% 
    left_join(indicators, by = "IndicatorCode") %>% 
    left_join(all_countries, by = "Code") %>% 
    rename(year = TimeDim,
           value = NumericValue,
           high_value = High,
           low_value = Low,
           country_code = Code,
           indicator_name = IndicatorName,
           country = Title,
           indicator_code = IndicatorCode) %>% 
    select(indicator_code, indicator_name, year, country_code, country, everything()) %>% 
    write_excel_csv(glue("Data/",TITLE," WHO Data.csv"))
 



