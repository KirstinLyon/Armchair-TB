library(tidyverse)
library(wbstats) #World bank database

## Global Variables ----
SADC <- c("AGO", "NAM", "ZAF", "LSO", "SWZ", 
                                 "BWA", "ZWE", "ZMB", "MOZ", "MWI", 
                                 "MDG", "COM", "SYC", "MUS")

#Burundi, Democratic Republic of the Congo,Kenya,  Rwanda,  South Sudan,  Uganda, Tanzania
EAC <- c("BDI", "KEN", "RWA", "SSD", "TZA", "UGA", "COD")

ECOWAS  <- c("BEN", "BFA", "CPV", "CIV", "GMB", "GHA", "GIN", 
            "GNB", "LBR", "MLI", "NER", "NGA", "SEN", "SLE", "TGO")




ALL_REGIONS <- c(SADC, EAC, ECOWAS)


START_YEAR = 2000
END_YEAR = 2023

INDICATORS <- c("SH.TBS.INCD", "SH.TBS.DTEC.ZS", "SH.TBS.MORT",
                "SH.TBS.CURE.ZS", "SH.XPD.EHEX.CH.ZS", "SH.XPD.GHED.GE.ZS",
                "SH.UHC.SRVS.CV.XD", "SP.DYN.LE00.FE.IN", "SP.DYN.LE00.MA.IN",
                "HD.HCI.OVRL", "SH.IMM.IBCG")


## Meta-data ----
indicators_metadata <- wbstats::wb_indicators() %>% 
    select(indicator_id, indicator, indicator_desc, source_org)

## Extract data ----
WB_data <- wbstats::wb_data(
    indicator = INDICATORS,
    country = ALL_REGIONS,
    start_date = START_YEAR,
    end_date = END_YEAR
) %>% 
    select(-iso2c) %>% 
    rename(year = date) %>% 
    mutate(region = case_when(iso3c %in% SADC ~ "SADC",
                              iso3c %in% EAC ~ "EAC",
                              iso3c %in% ECOWAS ~ "ECOWAS")) %>% 
    select(iso3c, country, region, year, everything()) ##%>% 
    ##write_excel_csv("WB_data.csv")

# Convert to a long format
WB_data_long <- WB_data %>% 
    pivot_longer(!c(country, year, iso3c, region),
                 names_to = "indicator_id",
                 values_to = "value") %>% 
    left_join(indicators_metadata, by = "indicator_id") %>% 
    drop_na() %>% 
    write_excel_csv("WB_data_long.csv")
