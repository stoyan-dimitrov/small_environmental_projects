## load the tidiverse package
library(tidyverse)

options(digits=12, nsmall=2)

## set the working directory to the directory where the spreadsheet is so it is easy to open it

setwd("/home/stoyan/r_projects/small_environmental_projects")

## use "skip" because it has one line with text at the top (I have previously opened the file)

ice_ext_raw <- read_csv("ice_extention/data/DATAX.csv", skip = 1)

## open the .csv with the raw world temperature data. It shows the yearly change of the world temperature taking as a base the average temperature of the 1961 - 1990 period. The dataset contains data the temperature from 1850 to 2018 and for four regions (1) Global, (2) Northern Hemisphere, (3) Southern Hemisphere, and (4) Tropics. Also the data for each observation contains the median average temperature change, and the upper and lower 95% confidence intervals. The source of the dataset is blob:https://ourworldindata.org/82977cf0-14e7-45a2-9502-018125a72aaa.

t_dat_raw <- read_csv("ice_extention/data/temperature-anomaly.csv")

## check out the data
str(ice_ext_raw)
head(ice_ext_raw)

str(t_dat_raw)
head(t_dat_raw)

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

## make a df of median global and northern hemisphere temperature from 2006 on.

t_regions <- t_dat_raw %>%
  filter(Year > 2005) %>%
  rename(entity = Entity, year = Year, median = `Median (℃)`, lower = `Lower (℃)`, upper = `Upper (℃)`) %>%
  select(-one_of(c("Code", "lower", "upper")))

## make a time-series object from for the global temperature from 2006 to 2018

t_glob_ts <- t_regions %>%
  filter(entity == "Global") %>%
  select(-one_of(c("entity", "year"))) %>%
  pull(median) %>%
  ts(start = 2006, end = 2018, frequency = 1, deltat = 1)

## make a time-series object from for the northern hemisphere temperature from 2006 to 2018

t_nh_ts <- t_regions %>%
  filter(entity == "Northern Hemisphere") %>%
  select(-one_of(c("entity", "year"))) %>%
  pull(median) %>%
  ts(start = 2006, end = 2018, frequency = 1, deltat = 1)

## remove the numbering of the regions in the header
### make a character vector with only the names of the headers and print it to be then able to copy only the name
### using colnames, copy only the names of the regions (without the numbering) to a new character vector and use it co change the header
headers <- colnames(ice_ext_raw)
print(headers)
ice_ext_cont <- ice_ext_raw
colnames(ice_ext_cont) <- c("yyyyddd", "Northern_Hemisphere", "Beaufort_Sea", "Chukchi_Sea", "East_Siberian_Sea", "Laptev_Sea", "Kara_Sea", "Barents_Sea", "Greenland_Sea", "Baffin_Bay_Gulf_of_St", "Canadian_Archipelago", "Hudson_Bay", "Central_Arctic", "Bering_Sea", "Baltic_Sea", "Sea_of_Okhotsk", "Yellow_Sea", "Cook_Inlet")

## new df with yearly average ice extent for the Northern Hemisphere
### create a new df where the first column is only the year (remove the day) using "separate()"
### use "convert = TRUE" so the variable for year is converted to integer and not character

ice_ext_year_avg_nh <- ice_ext_cont %>%
  separate(yyyyddd, sep = 4, into = "year", convert = TRUE) %>%
  select(year, Northern_Hemisphere) %>%
  group_by(year) %>%
  summarise(avg_ice_ext = mean(Northern_Hemisphere)) %>%
  filter(year < 2019)

## make a time-series objectfrom for the northern hemisphere ice extention from 2006 to 2018

ice_ext_year_avg_nh_ts <- ts(data = ice_ext_year_avg_nh$avg_ice_ext, start = 2006, end = 2018, frequency = 1, deltat = 1)

## new df with yearly average ice extent for all seas

ice_ext_year_avg_sea <- ice_ext_cont %>%
  mutate(total=rowSums(ice_ext_cont[,3:18])) %>%
  separate(yyyyddd, sep = 4, into = "year", convert = TRUE) %>%
  group_by(year) %>%
  summarise(avg_ice_ext = mean(total))

## difference between the yearly avg of Northern Hemisphere and all seas

ice_ext_cont %>%
  mutate(total=rowSums(ice_ext_cont[,3:18])) %>%
  mutate(dif=total-Northern_Hemisphere) %>%
  separate(yyyyddd, sep = 4, into = "year", convert = TRUE) %>%
  group_by(year) %>%
  summarise(avg_dif = mean(dif))

## new df with yearly average ice extent by region
### gather() excluding Northern Hemisphere
### group_by() by region and year to then summarise() the average ice_ext by those two variables
ice_ext_year_avg_per_sea <- ice_ext_cont %>%
  separate(yyyyddd, sep = 4, into = "year", convert = TRUE) %>%
  gather(region, ice_extent, Beaufort_Sea:Cook_Inlet) %>%
  group_by(region, year) %>%
  summarise(avg_ice_ext = mean(ice_extent))

# FORMULAS

Find_Max_CCF<- function(a,b)
{
  d <- ccf(a, b, plot = FALSE)
  cor = d$acf[,,1]
  lag = d$lag[,,1]
  res = data.frame(cor,lag)
  res_max = res[which.max(res$cor),]
  return(res_max)
}

Find_Min_CCF<- function(a,b)
{
  d <- ccf(a, b, plot = FALSE)
  cor = d$acf[,,1]
  lag = d$lag[,,1]
  res = data.frame(cor,lag)
  res_min = res[which.min(res$cor),]
  return(res_min)
}

# PLOTS

## DONE
### line graph of the yearly average ice extent
### line graph of the yearly average ice extent by region
### line graph of the yearly average ice extent by region in a log10 scale

## line graph of the yearly average temperature anomaly from 2006 to 2018 by region
t_regions %>% ggplot(aes(year, median, color = entity)) +
  geom_line()

## line graph of the yearly average ice extent of the North Hemisphere
ice_ext_year_avg_nh %>% ggplot(aes(year, avg_ice_ext)) +
  geom_line()

## line graph of the yearly average ice extent by region
ice_ext_year_avg_per_sea %>%  ggplot(aes(year, avg_ice_ext, color = region)) +
  geom_line()

## line graph of the yearly average ice extent by region in a log10 scale
ice_ext_year_avg_per_sea %>%  ggplot(aes(year, avg_ice_ext, color = region)) +
  geom_line() +
  scale_y_log10()

## cross-correlation of global temperature and northern hemisphere ice extention for the period from 2006 to 2018

ccf(t_glob_ts, ice_ext_year_avg_nh_ts)

Find_Max_CCF(t_glob_ts, ice_ext_year_avg_nh_ts)

Find_Min_CCF(t_glob_ts, ice_ext_year_avg_nh_ts)

## cross-correlation of northern hemisphere temperature and northern hemisphere ice extention for the period from 2006 to 2018

ccf(t_nh_ts, ice_ext_year_avg_nh_ts)

Find_Max_CCF(t_nh_ts, ice_ext_year_avg_nh_ts)

Find_Min_CCF(t_nh_ts, ice_ext_year_avg_nh_ts)
