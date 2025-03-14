# _targets.R file
library(targets)
library(tarchetypes)
tar_source()
tar_option_set(packages = c("httr2", "dplyr", "ggplot2", "jsonlite"))

# Parameters
#api_root <- "https://demo.api-hpc-tools.ahconu.org"
api_root <- "https://api.hpc.tools"
plan_url <- paste0(api_root, "/v2/public/plan/overview/2025?disaggregation=false")

list(
  tar_plan(
    plan_data = make_request(plan_url)
    , plan_ids = plan_data$data$plans$id
    , all_projects = fetch_projects(plan_ids)
    , all_flow_data = fetch_and_process_flow_data(plan_ids)
    #, linked_data <- dplyr::left_join(all_flow_data, all_projects, by = "id")
  )
)