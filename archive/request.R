# Install packages

# if httr2 is not installed, install
if (!requireNamespace("httr2", quietly = TRUE)) {
  pak::pak("httr2")
}
# if jsonlite is not installed, install
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  pak::pak("jsonlite")
}
# if data.table is not installed, install
if (!requireNamespace("data.table", quietly = TRUE)) {
  pak::pak("data.table")
}
# if tidyr is not installed, install
if (!requireNamespace("tidyr", quietly = TRUE)) {
  pak::pak("tidyr")
}

# Load libraries
library(httr2)
library(jsonlite)
library(data.table)
library(tidyr)


# Base URL for the API
base_url <- "https://api.hpc.tools/v2/public"

###-----------------------------###
### Retrieve list of locations  ###
###-----------------------------###

url <- paste0(base_url, "/location")
response <- request(url) 
response <- request("https://api.hpc.tools/v2/public/location") |> 
  req_perform() 
locations <- if (resp_is_error(response)) {
  warning(paste("Failed to fetch data from", endpoint))
  NULL
} else {
  resp_body_json(response)
} 
locations$data |> data.table::rbindlist() |> 
  data.table::fwrite("locations.csv")

###---------------------------------------###
### Retrieve list of emergencies by year  ###
###---------------------------------------###

# years 1983 to 2025
years <- 1983:2024
# create a list of URLs for each year
urls <- paste0(base_url, "/emergency/year/", years)
# make a request for each URL
responses <- lapply(urls, function(url) {
  request(url) |>
    req_perform()
})
# check if any of the requests failed
failed <- vapply(responses, function(response) {
  resp_is_error(response)
}, logical(1))
if (any(failed)) {
  warning(paste("Failed to fetch data from", urls[failed]))
}
# extract the data from each response
emergencies <- lapply(responses, function(response) {
  if (resp_is_error(response)) {
    NULL
  } else {  
    resp_body_json(response)
  }
}) |> setNames(years) 

# remove anything before 1999
emergencies <- emergencies[names(emergencies) %in% c(1999:2025)]
# combine the data into a single data frame (get $data from each item)
emergencies_dt <- lapply(
  emergencies,
   \(x) 
    dt <- x$data |> 
     data.table::rbindlist() |> 
     tidyr::unnest_longer(locations) |>
     dplyr::mutate(locations = as.character(locations)) |>
     tidyr::unnest_longer(categories) |> 
     dplyr::mutate(categories = as.character(categories))
 ) |>
  data.table::rbindlist(fill = TRUE)

# select only rows with locations_id = "id" and categories_id = "id", using data.table
emergencies_dt <- emergencies_dt[locations_id == "id" & categories_id == "id", ]

# write the data to a CSV file
data.table::fwrite(emergencies_dt, "emergencies.csv")



###---------------------------------------###
### Retrieve list of plans                ###
###---------------------------------------###

# url
url <- paste0(base_url, "/plan")
# make a request
response <- request(url) |>
  req_perform()
# check if the request failed
plans <- if (resp_is_error(response)) {
  warning(paste("Failed to fetch data from", endpoint))
  NULL
} else {
  resp_body_json(response)
} 

# write to json
jsonlite::write_json(plans, "plans.json")

# plans_dt
plans_dt <- plans$data |> lapply(
  \(x) {

    origRequirements <- x$origRequirements
    revisedRequirements <- x$revisedRequirements
    year <- x$years[[1]]$year
    # if x
    # if x$locations[[1]]$id exist then access it
    if (length(x$locations) > 0) {
      location_id <- x$locations[[1]]$id
    } else {
      location_id <- NA
    }
    # if x$categories[[1]]$id exist then access it
    # iterate over categories and retrieve grouop = planType
    if (length(x$categories) > 0) {
      category_id <- x$categories
    } else {
      category_id <- NA
    }
    data.table::data.table(
      year = year,
      location_id = location_id,
      category_id = category_id,
      origRequirements = origRequirements,
      revisedRequirements = revisedRequirements
    )
    
  }) |>
  data.table::rbindlist()

### plot of plans by year sum revisedRequirements
# library(ggplot2)
# library(dplyr)
# plans_dt |> 
#   summarize(req = sum(revisedRequirements, na.rm = T), .by = year) |>
#   ggplot(aes(x = year, y = req)) + 
#   geom_col()




###---------------------------------------###
### Retrieve list of projects             ###
###---------------------------------------###

# url
url <- paste0(base_url, "/project")
# make a request
response <- request(url) |>
  req_perform()
# check if the request failed
projects <- if (resp_is_error(response)) {
  warning(paste("Failed to fetch data from", endpoint))
  NULL
} else {
  resp_body_json(response)
} 

# write to json
jsonlite::write_json(plans, "projects.json")


id <- 1
projects <- list()

while (TRUE) {
  url <- paste0(base_url, "/project/", id)
  
  tryCatch({
    # Make a request
    response <- request(url) |>
      req_perform()
    
    # Check if the request was successful
    if (!resp_is_error(response)) {
      project <- resp_body_json(response)
      projects[[length(projects) + 1]] <- project
      cat("Successfully fetched project ID:", id, "\n")
      id <- id + 1
    } else {
      stop(paste("HTTP error:", resp_status(response)))
    }
  }, error = function(e) {
    cat("Error occurred at ID:", id, "\n")
    cat("Error message:", e$message, "\n")
    # Stop the loop
    stop("Stopping due to error")
  })
}


# write to json
jsonlite::write_json(plans, "projects_by_id.json")





###---------------------------------------###
### Retrieve locations by id              ###
###---------------------------------------###

url <- paste0(base_url, "/location/1")
# make a request
response <- request(url) |>
  req_perform()
# check if the request failed
location <- if (resp_is_error(response)) {
  warning(paste("Failed to fetch data from", endpoint))
  NULL
} else {
  resp_body_json(response)
} 
