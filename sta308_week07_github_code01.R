###################################### 
## 
##  sta308_week07_github_code01.R
##
##  This code is a streamlined version of code that is
##    similar to the results from last week
##  We will start off class by running this code and discussing
##    all that it does.
##
## 1. uses functionality from the jsonlite package,
##    specifically using the fromJSON() function
##    to fetch data from the NHTSA FARS API
## 2. Provides a function that will fetches all fatal
##    crashes in the state of Ohio from 2014 to 2021
##

## Load necessary libraries

library(jsonlite)
library(tidyverse)

#################################
## get_fatal_crashes_json(year=2014)
##
## This function takes the provided 'year' 
##   parameter and appends it to the website/API
##   call. The result of the API call is then output.
## We are getting a list of crashes, with some details,
##   for all fatal crashes in the state of Ohio
## We use this function so we can lapply() over
##   all years from 2014 to 2021.
##

get_fatal_crashes_json <- function(year=2014) {
  site <- paste0("https://crashviewer.nhtsa.dot.gov/CrashAPI/crashes/GetCaseList?states=39&fromYear=", 
                 year, 
                 "&toYear=",
                 year, 
                 "&minNumOfVehicles=1&maxNumOfVehicles=6&format=json")
  fromJSON(site)
}

all_crashes_list <- lapply(2014:2021, get_fatal_crashes_json)

##########
## Let's explore everything in all_crashes_list

class(all_crashes_list)    # List
length(all_crashes_list)   # with 7 years

## The first element
class(all_crashes_list[[1]])  # another list!
length(all_crashes_list[[1]]) # 4 items in it
names(all_crashes_list[[1]])  # we want Results

class(all_crashes_list[[1]]$Results)  # Another list
length(all_crashes_list[[1]]$Results) # but a single element

class(all_crashes_list[[1]]$Results[[1]])  # data.frame we want!

## Let's look at it
glimpse(all_crashes_list[[1]]$Results[[1]])

###########################
## This is the data from the first API call
##   so the 2014 data
## It has information we want. 
##   Number of Fatalities -- FATALS
##   Counties -- CountyName
##   Date -- in a wonky format?
## Other potentially interesting information
##   Number of persons involved, number of vehicles
##   and number of pedestrians
## We could do lots of interesting things.

#############################
## For our analysis, we just
##   want the county names and
##   dates of the crashes, along
##   with the fatalities
## What do to with those dates?
##   see https://en.wikipedia.org/wiki/Unix_time
## It is convoluted but the first
##   10 digits is what we want, the number
##   of seconds since January 1, 1970 12:00:00am
## We can do a little string parsing and convert
##   it to a proper date and time

#################################
## Last week, we first solved the mini problem of Adams
##   county, then we generalized. Today we will do something
##   similar. Let's consider the first crash in the record
##   and solve this mini problem

first_rec <- all_crashes_list[[1]]$Results[[1]] %>%
  slice(1)
first_rec

str_sub(first_rec$CrashDate, start=7, end=16)
as.numeric(str_sub(first_rec$CrashDate, start=7, end=16))

today()
as.numeric(today())
as.numeric(ymd("0450-08-12"))

as_datetime(as.numeric(str_sub(first_rec$CrashDate, start=7, end=16)))

#################################################
## Now we automate the process
##  The function below does the above in an
##  automated fashion. It also removes
##  a few erroneous dates that get fetched
##

get_county_date_fatalities <- function(x) {
  x$Results[[1]] %>%
    mutate(Date_string = str_sub(CrashDate, start=7, end=16),
           Date_time = as_datetime(as.numeric(Date_string)) ) %>%
    filter(as.numeric(Date_string) > 0)  %>% # remove 2 erroneous dates
    select(County = CountyName,
           Date_time,
           Fatalities = Fatals)
}

library(lubridate)
county_year_data_list <- lapply(all_crashes_list, get_county_date_fatalities)

county_year_data <- bind_rows(county_year_data_list)
glimpse(county_year_data)
View(county_year_data)

## We now all the fatalities for Ohio from 2014 to 2021
##   recording both the county and date of the crash
##

#################
## Save our data.frame
save(county_year_data,
     file="countyYearFatalities.RData")

