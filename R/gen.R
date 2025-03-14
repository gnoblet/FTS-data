# Function to make API requests
make_request <- function(url) {
  resp <- request(url) |> 
    req_perform()
  return(fromJSON(resp_body_string(resp)))
}