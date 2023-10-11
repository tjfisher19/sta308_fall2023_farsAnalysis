#####################################
## 
## sta308_week07_github_code03.R
##
## We will now continue with some
##   analysis of the FARS data
##
## We will compute the fatality rate
##   in each county in Ohio for each
##   year. 

## Getting started

library(tidyverse)

## Load data from Monday
load("countyYearFatalities.RData")
load("countyYearPopulations.RData")

glimpse(county_year_data)
glimpse(OhioCountyPops)

######################################
## We want to merge by county and year
## So first we must get the county names
##   in the same format
## i.e., turn "ADAMS (1)" into "Adams"
##    and so forth
##
## Streamlined solution
##   (similar to last week but nested functions)

county_year_data2 <- county_year_data %>%
  mutate(County = str_to_title(
    str_trim(
      str_remove_all(County, "[(0123456789)]")
      )
    )
  )

glimpse(county_year_data2)

#########################
## Note, a single observation from 2022 gets picked up
county_year_data2 %>%
  slice_max(Date_time)
## We will remove it below as it technically takes place 
##   after the time window we are studying

#############################
## Now we will aggregate
##   by year and county.
## First we need to compute
##   the year from the 
##   provided date & time
## The functionality is provided in lubridate
##   the year() function

library(lubridate)

county_year_aggregates <- county_year_data2 %>%
  mutate(Year = year(Date_time)) %>%
  filter(Year < 2022) %>%
  group_by(Year, County) %>%
  summarize(Fatalities = sum(Fatalities))

glimpse(county_year_aggregates)

## 8 years, 88 counties, so 8*88 = 704 observations
##    why are we missing 4?
##
## Some counties in some years reported no fatalities!
##   A good thing contextually
## Let's add them back into the record with 0 fatalities
##   We will use some advanced functionality!
##       crossing() and complete()
##   both in tidyr (in tidyverse)
## 
help(complete)
help(crossing)

complete_county_year_aggregates <- county_year_aggregates %>%
  ungroup() %>%     # data must not include groups
  complete(crossing(Year, County), fill=list(Fatalities=0))

##############################
## Now we can merge by Year & County
glimpse(complete_county_year_aggregates)
glimpse(OhioCountyPops)

help(merge)
## Merge when "County" == "County" and "Year"=="Year"
ohioCountyFatalPop <- merge(complete_county_year_aggregates,
                            OhioCountyPops,
                            by=c("County", "Year")
)
glimpse(ohioCountyFatalPop)

##############################
## Yay! Now we have Counties,
##    Years, Populations and
##    Fatalities by automobile
##    crashes!  We can find a 
##    rate fairly easily.


ohioCountyFatalPop <- ohioCountyFatalPop %>%
  mutate(Fatality_rate = Fatalities/Population*10000)

## Highest 2 counties (by rate) in each year
ohioCountyFatalPop %>%
  group_by(Year) %>%
  slice_max(Fatality_rate, n=8) %>%
  print(n=65)

## Lowest 2 counties (by rate) per year
ohioCountyFatalPop %>%
  group_by(Year) %>%
  slice_min(Fatality_rate, n=8)

## Let's save our processed data!
##  All counties in each year
##  summarized with the populations
##  in there.
save(ohioCountyFatalPop,
     file="countyYearlyFatalityRates.RData")

