# sta308_fall2022_farsAnalysis

This repository contains code that accesses data from the National Highway Traffic Safety Administration (NHTSA) Fatality Analysis Reporting System (FARS) program API.

The FARS data contains information on motor vehicle crashes in the United States that result in a death.

In this short program we query the API to collect all crashes involving a death in every county in Ohio for 2014-2020.

Ultimately we will merge the data from the API with Ohio county-level population data from the US Census and perform a short analysis.

We will also look at what impact COVID-19 had on fatalities in automobile crashes.

## API Details

The FARS API is publicly available and instructions for accessing the API can be found here: https://crashviewer.nhtsa.dot.gov/CrashAPI

We will be obtaining crash-level information for crashes in Ohio from 2014-2020. 

Note: in some years, a county in Ohio reported zero crashes resulting in a death. Contextually this is a great thing but it changes the response from the API and makes the processing a bit more complicated, so we will introduce some new functionality in the `tidyverse`.



