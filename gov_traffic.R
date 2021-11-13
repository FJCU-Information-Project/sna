# data used in next examples
install.packages("visNetwork")
library("visNetwork")
nb <- 10
nodes <- data.frame(id = 1:nb, label = paste("Label", 1:nb),
                    group = sample(LETTERS[1:3], nb, replace = TRUE), value = 1:nb,
                    title = paste0("<p>", 1:nb,"<br>Tooltip !</p>"), stringsAsFactors = FALSE)

edges <- data.frame(from = c(8,2,7,6,1,8,9,4,6,2),
                    to = c(3,7,2,7,9,1,5,3,2,9),
                    value = rnorm(nb, 10), label = paste("Edge", 1:nb),
                    title = paste0("<p>", 1:nb,"<br>Edge Tooltip !</p>"))

visNetwork(nodes, edges, height = "500px", width = "100%") %>% 
  visOptions(highlightNearest = TRUE) %>%
  visLayout(randomSeed = 123)

visNetwork(nodes, edges, height = "500px", width = "100%") %>% 
  visOptions(highlightNearest = list(enabled = T, degree = 2, hover = T)) %>%
  visLayout(randomSeed = 123)

visNetwork(nodes, edges, height = "500px", width = "100%") %>% 
  visGroups(groupname = "A", shape = "icon", 
            icon = list(code = "f0c0", size = 75)) %>%
  visGroups(groupname = "B", shape = "icon", 
            icon = list(code = "f007", color = "red")) %>%
  visGroups(groupname = "C", shape = "icon", 
            icon = list(code = "f1b9", color = "black")) %>%
  visOptions(highlightNearest = list(enabled =TRUE, degree = 2, hover = T)) %>%
  addFontAwesome() %>%
  visLayout(randomSeed = 123)

visNetwork(nodes, edges, height = "500px", width = "100%") %>% 
  visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
  visLayout(randomSeed = 123)

# on "authorised" column
visNetwork(nodes, edges, height = "500px", width = "100%") %>%
  visOptions(selectedBy = "group") %>%
  visLayout(randomSeed = 123)

visNetwork, an R package for interactive network visualization
Introduction
Nodes
Edges
Groups
Legend & Title
Use image & Icon
Options
Layout
Igraph
Performance
CART
Shiny
Interactions
Physics
Configure tools
More...
Some custom options are available using visOptions().
# data used in next examples
nb <- 10
nodes <- data.frame(id = 1:nb, label = paste("Label", 1:nb),
                    group = sample(LETTERS[1:3], nb, replace = TRUE), value = 1:nb,
                    title = paste0("<p>", 1:nb,"<br>Tooltip !</p>"), stringsAsFactors = FALSE)

edges <- data.frame(from = c(8,2,7,6,1,8,9,4,6,2),
                    to = c(3,7,2,7,9,1,5,3,2,9),
                    value = rnorm(nb, 10), label = paste("Edge", 1:nb),
                    title = paste0("<p>", 1:nb,"<br>Edge Tooltip !</p>"))
Highlight nearest
You can highlight nearest nodes and edges by clicking on a node with highlightNearest. Just click everywhere except on nodes to reset the network :
  
  visNetwork(nodes, edges, height = "500px", width = "100%") %>% 
  visOptions(highlightNearest = TRUE) %>%
  visLayout(randomSeed = 123)


It’s now possible to control the degree of depth, and to enable this option also hovering nodes (hover). Using hover, you can still use click to set a view :
  
  visNetwork(nodes, edges, height = "500px", width = "100%") %>% 
  visOptions(highlightNearest = list(enabled = T, degree = 2, hover = T)) %>%
  visLayout(randomSeed = 123)
This feature is available also with images and icons :
  
  visNetwork(nodes, edges, height = "500px", width = "100%") %>% 
  visGroups(groupname = "A", shape = "icon", 
            icon = list(code = "f0c0", size = 75)) %>%
  visGroups(groupname = "B", shape = "icon", 
            icon = list(code = "f007", color = "red")) %>%
  visGroups(groupname = "C", shape = "icon", 
            icon = list(code = "f1b9", color = "black")) %>%
  visOptions(highlightNearest = list(enabled =TRUE, degree = 2, hover = T)) %>%
  addFontAwesome() %>%
  visLayout(randomSeed = 123)
Select by node id
You can also select a node by id/label with a list using nodesIdSelection :
  
  visNetwork(nodes, edges, height = "500px", width = "100%") %>% 
  visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
  visLayout(randomSeed = 123)

Select by id


Select by a column
Select subset of nodes by the values of a column using selectedBy. Nodes can have multiple groups using comma-separated values :
  
  # on "authorised" column
  visNetwork(nodes, edges, height = "500px", width = "100%") %>%
  visOptions(selectedBy = "group") %>%
  visLayout(randomSeed = 123)

Select by group
# or new column, with multiple groups
nodes$sample <- paste(sample(LETTERS[1:3], nrow(nodes), replace = TRUE),
                      sample(LETTERS[1:3], nrow(nodes), replace = TRUE), 
                      sep = ",")
nodes$label <- nodes$sample # for see groups

visNetwork(nodes, edges, height = "500px", width = "100%") %>%
  visOptions(selectedBy = list(variable = "sample", multiple = T)) %>%
  visLayout(randomSeed = 123)

visNetwork(nodes, edges, height = "500px", width = "100%") %>% 
  visOptions(highlightNearest = TRUE, 
             nodesIdSelection = list(enabled = TRUE,
                                     selected = "8",
                                     values = c(5:10),
                                     style = 'width: 200px; height: 26px;
                                 background: #f8f8f8;
                                 color: darkblue;
                                 border:none;
                                 outline:none;')) %>%
  visLayout(randomSeed = 123)

nodes <- data.frame(id = 1:15, label = paste("Label", 1:15),
                    group = sample(LETTERS[1:3], 15, replace = TRUE))

edges <- data.frame(from = trunc(runif(15)*(15-1))+1,
                    to = trunc(runif(15)*(15-1))+1)

# keeping all parent node attributes  
visNetwork(nodes, edges) %>% visEdges(arrows = "to") %>%
  visOptions(collapse = TRUE)

visNetwork(nodes, edges, height = "500px", width = "100%") %>% 
  visOptions(manipulation = TRUE) %>%
  visLayout(randomSeed = 123)

nodes <- jsonlite::fromJSON("https://raw.githubusercontent.com/datastorm-open/datastorm-open.github.io/master/visNetwork/data/nodes_miserables.json")
nodes <- jsonlite::fromJSON("https://raw.githubusercontent.com/FJCU-Information-Project/sna/main/gov.json?token=ATFUORTAMNUA6HSJD5FDABDBRO5I6")
edges <- jsonlite::fromJSON("https://raw.githubusercontent.com/datastorm-open/datastorm-open.github.io/master/visNetwork/data/edges_miserables.json")

 # subset(nodes,label=="Myriel")

visNetwork(nodes, edges, height = "700px", width = "100%") %>%
  visOptions(selectedBy = "group", 
             highlightNearest = TRUE, 
             nodesIdSelection = TRUE) %>%
  visPhysics(stabilization = FALSE)