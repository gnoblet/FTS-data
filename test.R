library(targets)
library(httr2)
tar_source("R/")
plan_ids <- tar_read(plan_ids)
#api_root <- "https://demo.api-hpc-tools.ahconu.org"
api_root <- "https://api.hpc.tools"
plan_url <- paste0(api_root, "/v2/public/plan/overview/2025?disaggregation=false")

all_flow_data <- list()
  
  for (plan_id in plan_ids) {
    flow_data <- fetch_flow_data(plan_id)
    if (!is.null(flow_data)) {
      flow_data$plan_id <- plan_id
      all_flow_data <- c(all_flow_data, list(flow_data))
    }
  }


  
  all_flow_data <- bind_rows(all_flow_data) 
  all_flow_data$id <- as.character(all_flow_data$id)


  flow_data <- fetch_flow_data(plan_id)


  flow_url <- paste0(api_root, "/v1/public/fts/flow?planid=", plan_id)#, "&groupBy=project&report=3")
  flow_data <- make_request(flow_url)
