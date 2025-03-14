# Function to fetch flow data
fetch_flow_data <- function(plan_id) {
  flow_url <- paste0(api_root, "/v1/public/fts/flow?planid=", plan_id) #, "&groupBy=project&report=3")
  flow_data <- make_request(flow_url)
  flow_data <- flow_data$data$flows
  return(flow_data)
}


fetch_and_process_flow_data <- function(plan_ids) {
  all_flow_data <- list()
  
  for (plan_id in plan_ids) {
    flow_data <- fetch_flow_data(plan_id)
    flow_data <- as.data.frame(flow_data)
    if (!is.null(flow_data)) {
      all_flow_data <- c(all_flow_data, list(flow_data))
    }
  }

  # Bind list
  all_flow_data <- setNames(all_flow_data, plan_ids) |> 
    purrr::list_rbind(names_to = "plan_id")

  all_flow_data <- bind_rows(all_flow_data) 
  all_flow_data$id <- as.character(all_flow_data$id)

  return(all_flow_data)
}
