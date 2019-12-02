## load the tidiverse package
library(tidyverse)

## set the working directory to the directory where the spreadsheet is so it is easy to open is
## use "skip" because it has one line with text at the top (I have previously opened the file)

ice_ext_raw <- read_csv("ice_extention/data/DATAX.csv", skip = 1)

## check out the data
str(ice_ext_raw)
head(ice_ext_raw)

# WRANGLING

## DONE
### remove the numbering of the regions in the header
### new tibble with yearly average ice extent
### new tibble with yearly average ice extent by region

## TO DO:
### dataframe with the highest winter and the lowest summer ice extent
### dataframe with the highest and the lowest yearly ice extent check if the highest extent is during the winter and the lowest during the summer
### dataframe with the yearly percentage change in ice extent
### dataframe with the yearly percentage change in ice extent in the summer
### dataframe with the yearly percentage change in ice extent in the winter


## remove the numbering of the regions in the header
### make a character vector with only the names of the headers and print it to be then able to copy only the name
### using colnames, copy only the names of the regions (without the numbering) to a new character vector and use it co change the header
headers <- colnames(ice_ext_raw)
print(headers)
ice_ext_cont <- ice_ext_raw
colnames(ice_ext_cont) <- c("yyyyddd", "Northern_Hemisphere", "Beaufort_Sea", "Chukchi_Sea", "East_Siberian_Sea", "Laptev_Sea", "Kara_Sea", "Barents_Sea", "Greenland_Sea", "Baffin_Bay_Gulf_of_St", "Canadian_Archipelago", "Hudson_Bay", "Central_Arctic", "Bering_Sea", "Baltic_Sea", "Sea_of_Okhotsk", "Yellow_Sea", "Cook_Inlet")

## new tibble with yearly average ice extent
### create a new tibble where the first column is only the year (remove the day) using "separate()"
### use "convert = TRUE" so the variable for year is converted to integer and not character
### pipe it to make a new data frame where the "region" is a variable with "gather()"
### group_by() the new data frame by year to then summarise() the average ice_ext by this variable
ice_ext_year_avg <- separate(ice_ext_cont, yyyyddd, sep = 4, into = "year", convert = TRUE) %>%
  gather(region, ice_extent, Northern_Hemisphere:Cook_Inlet) %>%
  group_by(year) %>%
  summarise(avg_ice_ext = mean(ice_extent))

## new tibble with yearly average ice extent by region
### same as ice_ext_year_avg but =>
### group_by() by region and year to then summarise() the average ice_ext by those two variables
ice_ext_year_avg_reg <- separate(ice_ext_cont, yyyyddd, sep = 4, into = "year", convert = TRUE) %>%
  gather(region, ice_extent, Northern_Hemisphere:Cook_Inlet) %>%
  group_by(region, year) %>%
  summarise(avg_ice_ext = mean(ice_extent))

# PLOTS

## DONE
### line graph of the yearly average ice extent
### line graph of the yearly average ice extent by region
### line graph of the yearly average ice extent by region in a log10 scale

## line graph of the yearly average ice extent
ice_ext_year_avg %>% ggplot(aes(year, avg_ice_ext)) +
  geom_line()

## line graph of the yearly average ice extent by region
ice_ext_year_avg_reg %>%  ggplot(aes(year, avg_ice_ext, color = region)) +
  geom_line()

## line graph of the yearly average ice extent by region in a log10 scale
ice_ext_year_avg_reg %>%  ggplot(aes(year, avg_ice_ext, color = region)) +
  geom_line() +
  scale_y_log10()
