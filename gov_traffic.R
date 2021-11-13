# data used in next examples
install.packages("visNetwork")
library("visNetwork")
#example node and edge
nodes <- jsonlite::fromJSON("https://raw.githubusercontent.com/datastorm-open/datastorm-open.github.io/master/visNetwork/data/nodes_miserables.json")
edges <- jsonlite::fromJSON("https://raw.githubusercontent.com/datastorm-open/datastorm-open.github.io/master/visNetwork/data/edges_miserables.json")
#traffic project node and edge link
nodes <- jsonlite::fromJSON("https://raw.githubusercontent.com/FJCU-Information-Project/sna/main/gov_nodes.json")
edges <- jsonlite::fromJSON("https://raw.githubusercontent.com/FJCU-Information-Project/sna/main/gov_edges.json")
id->c(0:19) #20列id
ID->data.frame(id)
nodes<-nodes[0:20,c("區","肇事因素個別")]
traffic_nodes<-cbind(ID,nodes) #將id欄和node欄合併
# setnames(資料,舊變數名稱,新變數名稱)
#setnames(mydata, c("dest","origin"), c("Destination", "origin.of.flight"))
colnames(traffic_nodes)<-c("id","label","group") #欄位重新命名
traffic_edges<-edges[0:20,]
#每個區域代表不同的case 連結在一起的node代表是相同的肇事因素
visNetwork(traffic_nodes, traffic_edges,  
           main = "台中交通事故sna", 
           submain = list(text = "個別肇事因素與區域關聯圖",
                          style = "font-family:Comic Sans MS;color:#ff0000;font-size:15px;text-align:center;"), 
           footer = "Fig.1 依區域分為不同的case",
           height = "700px", width = "100%") %>%
  visOptions(selectedBy = "group", 
             manipulation = TRUE, #edit network
             highlightNearest = TRUE, 
             nodesIdSelection = TRUE) %>%
  visGroups(groupname = "A", color = "red") %>%
  visGroups(groupname = "B", color = "lightblue") %>%
  visLegend()%>%
  visPhysics(stabilization = FALSE,#動態效果
             solver = "repulsion", 
             repulsion = list(gravitationalConstant = -500))