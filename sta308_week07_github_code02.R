#######################################
## 
## sta308_week07_github_code02.R
##
## Important!!!!
##    - Save this .R file into the folder with your 
##      Day 18 Project, likely called 
##      sta308_day18_assignment-userID  or something similar!
##    - Make sure you have run the code in the 
##      data processing file sta308_week07_github_code01.R.
##      It creates a file we need in the future.
##
## This R code is provided to streamline
##   the discussion for day 18 of STA 308.
##
## The code provided below should be familiar...
##   We read in county-level census data
##   and extract the population of each county of Ohio
##   but unlike in our previous examples, we now do it by year
##
## At the end of this file, write code that merges
##   the county-level vehicle fatality data with the
##   population data included here. Explore the
##   relationship between population and fatalities, adjust
##   as appropriate and explore which counties seem most
##   dangerous.


#### Fetch the US Census data for 2014-2019 from the 2010 estimates
OhioPop1019 <- 
  read_csv("https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/asrh/cc-est2019-agesex-39.csv") 
#### and from the 2020 census
OhioPop2021 <- 
  read_csv("https://www2.census.gov/programs-surveys/popest/datasets/2020-2021/counties/asrh/cc-est2021-agesex-39.csv")

##################################
## Extract the years (12==2019, 11==2018, ..., 7==2014)
##   from the 2010 census estimates
## Convert 7 to 2014, 8 to 2015, and so on...
## Get the county names and drop the word " County"
## Select the county names, year and corresponding populations
##
OhioCountyPop_part1 <- OhioPop1019 %>% 
  filter(YEAR %in% 7:12) %>% 
  mutate(County = str_remove(CTYNAME, " County"),
         Year = YEAR+2007) %>%  
  select(County, Year, Population=POPESTIMATE) 
glimpse(OhioCountyPop_part1)

## Do the same from the 2020 census, but we only have 1 year

OhioCountyPop_part2 <- OhioPop2021 %>% 
  filter(YEAR > 1 ) %>% 
  mutate(County = str_remove(CTYNAME, " County"),
         Year = YEAR + 2018) %>%  
  select(County, Year, Population=POPESTIMATE) 
glimpse(OhioCountyPop_part2)

##########
## so....
##
## OhioCountyPop_part1 has each counties estimated population
##    for the years 2014 through 2019, ....and....
## OhioCountyPop_part2 has each counties estimated population
##    for the year 2020 & 2021
##
## I want to put them together (stack them together much
##    like the penguin example)

OhioCountyPops <- bind_rows(OhioCountyPop_part1,
                            OhioCountyPop_part2)

View(OhioCountyPops)

## Save the population data
save(OhioCountyPops,
     file="countyYearPopulations.RData")


