library("tidyverse")
library("directlabels")

load("fisheries/fisheries.RData")

## A single column graph of fish production (in log10 scale) including all countries
ia %>% ggplot(aes(year, fish_production, color = country)) +
  geom_col() +
  facet_grid(. ~ country) +
  scale_x_discrete(breaks = c("2008", "2017")) +
  theme(legend.position = "bottom", axis.text.x = element_text(angle=90))

## A single column graph of fish production (in log10 scale) including all countries

ia %>% ggplot(aes(year, fish_production, color = country)) +
  geom_col() +
  scale_y_continuous(trans = "log10") +
  facet_grid(. ~ country) +
  scale_x_discrete(breaks = c("2008", "2017")) +
  theme(legend.position = "bottom", axis.text.x = element_text(angle=90))

## A set of column graphs of fish production by country

ia %>% ggplot(aes(year, fish_production, color = country)) +
  geom_col() +
  facet_wrap(~country) +
  theme(legend.position="none", axis.text.x = element_text(angle=45))

## A set of column graphs of fish production (in log10 scale) by country

ia %>% ggplot(aes(year, fish_production, color = country)) +
  geom_col() +
  scale_y_continuous(trans = "log10") +
  facet_wrap(~country) +
  theme(legend.position="none", axis.text.x = element_text(angle=45))

avg_prod <- ia2 %>% group_by(year) %>%
  summarise(avg_year_prod = mean(fish_production))


## A single line graph of fish production (in log10 scale) including all countries

ia2 %>% ggplot(aes(year, fish_production, color = country)) +
  geom_line() +
  scale_x_continuous(breaks = c(2008, 2017)) +
  scale_y_continuous(trans = "log10") +
  geom_dl(aes(label = country), method = list(dl.combine("first.qp", "last.qp"), cex = 0.7)) +
  theme(legend.position="none") +
  geom_smooth(avg_prod, aes(year, avg_year_prod))

## A set of line graphs of fish production (in log10 scale) by country

ia2 %>% ggplot(aes(year, fish_production, color = country)) +
  geom_line() +
  scale_x_continuous(breaks = c(2008, 2017)) +
  scale_y_continuous(trans = "log10") +
  theme(legend.position="none") +
  facet_wrap(~country)
