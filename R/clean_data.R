library(tidycensus)
library(rvest)
library(janitor)
library(dplyr)
library(devtools)
library(urbnmapr)
library(ggplot2)


## load data ----------------------------------------------------------------------------

##2016 data
content_16 = read_html("https://en.wikipedia.org/wiki/2016_South_Carolina_Democratic_presidential_primary")
table_16 = html_table(content_16, fill = TRUE)
prim_16 = table_16[[12]]
names(prim_16)[3] = "clinton_perc_16" 
names(prim_16)[5] = "sanders_perc_16"
names(prim_16)[8] = "turnout_16"
prim_16[9] = NULL
names(prim_16)[7] = "total_vote_16" 
names(prim_16)[4] = "sanders_raw_16"
names(prim_16)[2] = "clinton_raw_16"
prim_16 <- prim_16[-c(47),]

content_20 = read_html("https://en.wikipedia.org/wiki/2020_South_Carolina_Democratic_presidential_primary")
table_20 = html_table(content_20, fill = TRUE)
prim_20 = table_20[[14]]
names(prim_20)[3] = "biden_perc_20" 
names(prim_20)[5] = "buttigieg_perc_20" 
names(prim_20)[7] = "gabbard_perc_20" 
names(prim_20)[9] = "klobuchar_perc_20" 
names(prim_20)[11] = "sanders_perc_20" 
names(prim_20)[13] = "steyer_perc_20" 
names(prim_20)[15] = "warren_perc_20" 
names(prim_20)[17] = "others_perc_20" 
names(prim_20)[19] = "total_votes_20"
names(prim_20)[2] = "biden_raw_20"
names(prim_20)[4] = "buttigieg_raw_20"
names(prim_20)[6] = "gabbard_raw_20"
names(prim_20)[8] = "klobuchar_raw_20"
names(prim_20)[10] = "sanders_raw_20"
names(prim_20)[12] = "steyer_raw_20"
names(prim_20)[14] = "warren_raw_20"
names(prim_20)[16] = "others_raw_20"
names(prim_20)[20] = "turnout_20"
prim_20[18] = NULL


##merging dataset --------------------------------------------------------------
sc_prim <- merge(prim_16, prim_20)
sc_prim$turnout_16 = gsub("%", "", sc_prim$turnout_16)
sc_prim$total_vote_16 = gsub(",", "", sc_prim$total_vote_16)
sc_prim$total_votes_20 = gsub(",", "", sc_prim$total_votes_20)

sc_prim$turnout_16 = as.numeric(sc_prim$turnout_16)
sc_prim$total_votes_20 = as.numeric(sc_prim$total_votes_20)
sc_prim$total_vote_16 = as.numeric(sc_prim$total_vote_16)


##calculations -------------------------------------------------------------------
sc_prim$turnout_diff = sc_prim$turnout_20 - sc_prim$turnout_16
sc_prim$total_diff = sc_prim$total_votes_20 - sc_prim$total_vote_16
sc_prim$perc_coal = sc_prim$total_diff/sum(sc_prim$total_diff)

##mapping -----------------------------------------------------------------
counties_sf = get_urbn_map("counties", sf = TRUE)

sc_sf = counties_sf %>%
  filter(state_name == "South Carolina") %>%
  mutate(county_name = gsub("County", "", county_name)) %>%
  rename(County = county_name)

sc_sf = as.data.frame(sc_sf)

sc_prim_map = left_join(sc_sf, sc_prim, by = "County")

sc_sf_1 = sc_sf %>%
  left_join(sc_prim, by = "County")

COUN
sc_prim_map %>%
ggplot(mapping = aes(long, lat, group = group, fill = turnout_diff)) +
  geom_polygon(color = NA) +
  scale_fill_gradientn(labels = scales::percent,
                       guide = guide_colorbar(title.position = "top")) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  theme(legend.title = element_text(),
        legend.key.width = unit(.5, "in")) +
  labs(fill = "turnout_diff") +
  theme_urban_map()


