#install.packages("shiny")
#install.packages("visNetwork")

# devtools::install_github("datastorm-open/visNetwork") for development version

require(visNetwork)
#?visNetwork

# minimal example
nodes <- data.frame(id = 1:3)
edges <- data.frame(from = c(1,2), to = c(1,3))
visNetwork(nodes, edges)

# vignette
#vignette("Introduction-to-visNetwork")

# full javascript documentation
#visDocumentation()

# shiny example
shiny::runApp(system.file("shiny", package = "visNetwork"))
