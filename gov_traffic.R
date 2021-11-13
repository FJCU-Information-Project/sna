# data used in next examples
install.packages("visNetwork")
library("visNetwork")
#example node and edge
nodes <- jsonlite::fromJSON("https://raw.githubusercontent.com/datastorm-open/datastorm-open.github.io/master/visNetwork/data/nodes_miserables.json")
edges <- jsonlite::fromJSON("https://raw.githubusercontent.com/datastorm-open/datastorm-open.github.io/master/visNetwork/data/edges_miserables.json")
#traffic project node and edge link
nodes <- jsonlite::fromJSON("https://raw.githubusercontent.com/FJCU-Information-Project/sna/main/gov_nodes.json")
edges <- jsonlite::fromJSON("https://raw.githubusercontent.com/FJCU-Information-Project/sna/main/gov_edges.json")
id->c(0:19)
ID->data.frame(id)
nodes<-nodes[0:20,c("區","肇事因素個別")]
traffic_nodes<-cbind(ID,nodes)
colnames(traffic_nodes)<-c("id","label","group")
traffic_edges<-edges[0:20,]
visNetwork(traffic_nodes, traffic_edges, height = "700px", width = "100%") %>%
  visOptions(selectedBy = "group", 
             manipulation = TRUE,
             highlightNearest = TRUE, 
             nodesIdSelection = TRUE) %>%
  visPhysics(stabilization = FALSE)