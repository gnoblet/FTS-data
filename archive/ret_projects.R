library(httr2)
library(jsonlite)
library(dplyr)

# Set the API root
api_root <- "https://demo.api-hpc-tools.ahconu.org"
api_root <- "https://api.hpc.tools"

# Function to make API requests
make_request <- function(url) {
  resp <- request(url) %>%
    req_perform()
  return(fromJSON(resp_body_string(resp)))
}

# Fetch plan IDs
plan_url <- paste0(api_root, "/v2/public/plan/overview/2025?disaggregation=false")
plan_data <- make_request(plan_url)
plan_ids <- plan_data$data$plans$id

#----------------
# Function to fetch project details


# Fetch all project details
all_projects <- fetch_projects(plan_ids)



# Function to fetch flow data
fetch_flow_data <- function(plan_id) {
  flow_url <- paste0(api_root, "/v1/public/fts/flow?planid=", plan_id, "groupBy=project&report=3") #, "&groupBy=project&report=3")
  flow_data <- make_request(flow_url)
  return(flow_data$data$flows)
}

# Fetch flow data for each plan and link to projects
all_flow_data <- list()
for (plan_id in plan_ids[1]) {
  flow_data <- fetch_flow_data(plan_id)
  if (!is.null(flow_data)) {
    flow_data$plan_id <- plan_id
    all_flow_data <- c(all_flow_data, list(flow_data))
  }
}

all_flow_data <- bind_rows(all_flow_data) 
all_flow_data$id <- as.character(all_flow_data$id)
all_projects$id <- as.character(all_projects$id)
# Link flow data to project data
linked_data <- left_join(all_flow_data, all_projects, by = "id")

# Print the first few rows of the linked data
print(head(linked_data))
