


# load packages -----------------------------------------------------------

library(tidyverse)
library(stringr)
library(lubridate)


# read in data ------------------------------------------------------------

bcr <- read_csv("data-processed/BCR_cells_processed.csv")
id_key <- read_csv("data-raw/BCR_ID_Key.csv") %>% 
	mutate(replicate = as.character(jar))


bcr_id <- left_join(bcr, id_key, by = "replicate")

bcr_id$tmt[is.na(bcr_id$tmt)] <- "just algae"

bcr_id <- bcr_id %>% 
	mutate(temp.y = ifelse(is.na(temp.y), temp.x, temp.y)) %>% 
	rename(temperature = temp.y)

bcr_id %>% 
	filter(cell_density < 150000) %>%
	mutate(biovolume = cell_density * cell_volume) %>% 
	mutate(start_time = ymd_hm(start_time)) %>% 
	# filter(!grepl("C", replicate)) %>% 
	group_by(replicate) %>% 
	ggplot(aes(x = start_time, y = biovolume, color = tmt, group = replicate)) + geom_point(size = 5, alpha = 0.5) +
	geom_line() + 
	theme_bw() + facet_wrap( ~ temperature + tmt) + ylab("algal biovolume concentration (um3/ml)") +
	xlab("sample date")
