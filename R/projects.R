# Function to fetch projects based on a list of plan IDs
fetch_projects <- function(plan_ids) {
  # Initialize an empty list to store all projects
  all_projects <- list()
  
  # Loop through plan IDs in batches of 50 to avoid API limits
  for (i in seq(1, length(plan_ids), 50)) {
    # Extract the current batch of plan IDs
    batch_ids <- plan_ids[i:min(i+49, length(plan_ids))]
    
    # Construct the API URL for the project search endpoint
    project_url <- paste0(api_root, "/v2/public/project/search?planIds=", paste(batch_ids, collapse = ","))
    
    # Initialize the page number for pagination
    page <- 1
    
    # Repeat until all pages of results are fetched
    repeat {
      # Make a request to the API to fetch project data for the current page
      project_data <- make_request(paste0(project_url, "&page=", page))
      
      # Append the fetched project data to the list of all projects
      all_projects <- c(all_projects, project_data$data)
      
      # Check if we've reached the last page of results
      if (page >= project_data$data$pagination$pages) break
      
      # Increment the page number for the next iteration
      page <- page + 1
    }
  }
  
  # Return the combined list of all projects as a single data frame
  return(bind_rows(all_projects))
}