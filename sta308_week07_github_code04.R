#####################################
## 
## sta308_week07_github_code04.R
##
## We will now continue with some
##   analysis of the FARS data
##
## We will do a bit different of an 
##   analysis today looking at how
##   fatalities have varied in time


## Getting started
library(tidyverse)
library(lubridate)

load("countyYearFatalities.RData")
glimpse(county_year_data)

## Let's aggregate the data by Year & Month
##   First we need to extract the Year & Month
##     from the Date_time variable
##   Then group_by() Year and Month
##   Then summarize
ohio_year_mon_fatalities <- county_year_data %>%
  mutate(Year = year(Date_time),
         Month = month(Date_time) ) %>%
  group_by(Year, Month) %>%
  summarise(Fatalities = sum(Fatalities))

View(ohio_year_mon_fatalities)

###########################
## From this data we 
##   can learn from the
##   historic record.
##
## Which months appears most dangerous?

ohio_year_mon_fatalities %>%
  group_by(Month) %>%
  summarize(Avg_Fatalities = mean(Fatalities),
            Median_Fatalities = median(Fatalities),
            SD_Fatalities = sd(Fatalities))

################################
## Note that the summer months
##   roughly May to the end
##   of the year seem to have
##   the most fatalities
## Also note that the variability (SD)
##   tends to be higher with higher
##   averages; except for March
##   (we'll see why in a minute).

############################################
## How did the COVID-19 pandemic influence
##   automobile deaths in 2020?
## We will explore this visually and provide
##   a sneak peak to STA 309 material

####################
## First, strictly for plotting purposes
##    we will create a date variable 
##    in ohio_year_mon_fatalities
## 2014, 1 (January) will be 2014-01-01
## 2014, 2 (February) will be 2014-02-01
##    and so on...
##
## We are doing this strictly for plotting
##   purposes

ohio_year_mon_fatalities <- ohio_year_mon_fatalities %>%
  mutate(Date = ymd(paste0(Year, "-", Month, "-01")))

glimpse(ohio_year_mon_fatalities)

#######################################
## Now a line plot outlining each year
##   and highlighting 2020
ggplot(ohio_year_mon_fatalities) + 
  geom_line(aes(x=Date, y=Fatalities))


#######################
## Let's highlight 2020 by overlaying
##  it on top of the other years
## We do even more tricks here...
ohio_year_mon_fatalities_forPlot <- ohio_year_mon_fatalities %>%
  filter(Year < 2022) %>%
  mutate(Fake_Date = ymd(paste0("2000-", Month, "-01")))

ggplot(ohio_year_mon_fatalities_forPlot,
       aes(x=Fake_Date, y=Fatalities, group=Year)) + 
  geom_line(color="gray65") +
  geom_line(data=filter(ohio_year_mon_fatalities_forPlot, Year==2020),
            color="red", size=2, group=1) +
  theme_minimal() + 
  theme(axis.title = element_blank(),
        plot.caption = element_text(family="mono")) + 
  scale_x_date(breaks="month", date_labels="%B") +
  annotate("segment", x=as.Date("2000-05-15"), xend=as.Date("2000-04-10"),
           y=60, yend=54, arrow=arrow(), color="red", size=1.6) + 
  annotate("text", x=as.Date("2000-05-17"), y=60, color="red", hjust=0,
           label="COVID-19\nShutdowns\nof 2020") + 
  annotate("segment", x=as.Date("2000-05-30"), xend=as.Date("2000-06-20"),
           y=140, yend=148, arrow=arrow(), color="red", size=1.6) + 
  annotate("text", x=as.Date("2000-05-28"), y=140, color="red", hjust=1,
           label="Summer 2020\nreported higher\nthan normal\nfatalities") + 
  labs(title="COVID-19 impact on Ohio Automobile Fatalities",
       subtitle="Reporting to the number of Fatalities per month from 2014-2020\n(2020 highlight in red)",
       caption="Source: NHTSA FARS")

################
## Let's save that image
ggsave(filename="covidImpactPlot.png",
       width=8, height=6, dpi=300, bg="white")
