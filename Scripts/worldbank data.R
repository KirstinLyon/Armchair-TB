library(tidyverse)
library(wbstats) #World bank database
library(httr)# needed for API
library(jsonlite) #needed to read content from WHO
library(WHO)

# WorldBank Datasets ----

#Pull down worldbank data 

all_indicators <- wbstats::wb_indicators()

wbstats::


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

?wb_cache
?wb_data

df <- get_data("WHOSIS_000001")

country <- wb_countries()

# WHO Datasets ----

# https://www.dataquest.io/blog/r-api-tutorial/
#https://www.who.int/data/gho/info/gho-odata-api
#you want the status to be 200 - that means it has worked
#Status codes: https://www.restapitutorial.com/httpstatuscodes.html
#https://gateway.euro.who.int/en/api/specification/#nav-example-4
#https://apps.who.int/gho/data/node.resources.api
#https://apps.who.int/gho/athena/public_docs/examples.html
#https://apps.who.int/gho/data/node.home
#https://data.who.int/products/datadot
#https://portal.who.int/triplebillions/PowerBIDashboards/ExploreIndicators

res = GET("https://ghoapi.azureedge.net/api/Dimension")
res

rawToChar(res$content)
data = fromJSON(rawToChar(res$content))
data

test = GET("https://ghoapi.azureedge.net/api")
test

test2 = GET("http://apps.who.int/gho/athena/api/GHO/WHOSIS_000001,WHOSIS_000015")
test2
data_test2 = fromJSON(rawToChar(test2$content))


rawToChar(test$content)
data_test = fromJSON(rawToChar(test$content))

data_test

class(data)


list1 <- data


df <- map_if(list1, is.data.frame, list) %>% as_tibble %>% unnest(cols = c(value))
df # this is what we want!
class(df)


# move to a tibble



who_indicators <- WHO::get_codes()


countries <- GET("https://ghoapi.azureedge.net/api/DIMENSION/COUNTRY/DimensionValues")
countries_list <- fromJSON(rawToChar(countries$content))

countries_list


TB <- GET("https://ghoapi.azureedge.net/api/Indicator?$filter=contains(IndicatorName,'Tuberculosis')")
TB_LIST <- fromJSON(rawToChar(TB$content))
TB_LIST



