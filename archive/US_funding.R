
# Import libraries and packages ------------------------------------------

# Load 
box::use(
  data.table[...],
  rio[import])

# Read FTS data
dat <- data.table::fread("data_export/FTS_data_search_results_63db21cfe202aaa37782b850e432e231_as_on_2025-01-28.xlsx")

