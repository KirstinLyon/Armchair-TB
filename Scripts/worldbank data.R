library(tidyverse)
library(wbstats)


#Pull down worldbank data

all_indicators <- wbstats::wb_indicators()


all_sources <- all_indicators %>% 
    distinct(source) #%>% 
    #filter("Health Nutrition and Population Statistics")
  
Nutrition <- all_sources %>% 
    filter(source == "Health Nutrition and Population Statistics")


all_nutrition_indicators <- all_indicators %>% 
    filter(source =="Health Nutrition and Population Statistics")


write_csv(all_nutrition_indicators,"All WorldBank Nutrition Indicators.csv")
write_csv(all_sources, "All WorldBank Sources.csv")
write_csv(all_indicators, "All WorldBank Indicators.csv")


#gives an idea of what is in the dataset
fresh_cache <- wb_cache()
fresh_indicators <- fresh_cache$indicators
fresh_countries <- fresh_cache$countries
