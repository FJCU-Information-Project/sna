#ctrl shift + c 多行註解

print("Hello Before library")

library(visNetwork)
library(RMySQL)
library(igraph)
library(utf8)
layer_csv<- read.csv(file = 'E:/GitHub/sna/layer.csv', encoding = "UTF-8")
names(layer_csv)[1] <- "factor_id"

connect = dbConnect(MySQL(), dbname = "trans",username = "root",
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES BIG5") # 設定資料庫連線編碼
Sys.getlocale(category = "LC_ALL") # 查詢系統編碼環境
#layer_from_id<-data.frame(id = (layer_csv$factor_id))
#duplicated_from_id<-data.frame(id=(layer_from_id[!duplicated(layer_from_id),]),color=c(layer_from_id$color))
layer_to_id<-data.frame(id = c(layer_csv$near_id),group=c(layer_csv$level),color=c(layer_csv$color),total=c(layer_csv$weight))
#bind_from_to_id<-rbind(duplicated_from_id,layer_to_id)
#duplicated_bind_from_to_id<-data.frame(id=(bind_from_to_id[!duplicated(bind_from_to_id),]))

attr_layer<- dbGetQuery(connect ,"select * from `attribute`")
names(attr_layer)[1] <- "attribute"
names(attr_layer)[2] <- "attr_name"
get_layer_attr<- merge(x = node_layer, y = attr_layer, by = "attribute", all.x = TRUE)#left join

all_layer_node<- merge(x = layer_to_id, y = get_layer_attr, by = "id", all.x = TRUE)#left join
#duplicated(all_layer_node$(id,group))
all_layer_node<-unique(all_layer_node)
all_layer_node<-all_layer_node[order(all_layer_node$id,all_layer_node$group),]

all_layer_node <-all_layer_node[(!duplicated(all_layer_node$id)),]


layer_nodes<- data.frame(id = c(all_layer_node$id), group = c(all_layer_node$group), 
                         label = paste(all_layer_node$group), 
                         title = paste("<p>", all_layer_node$attr_name,"<br>",all_layer_node$enname,"</p>"),
                         font.size = 20,
                         color=c(all_layer_node$color)
                         )

layer_relationship<- data.frame(from = c(layer_csv$factor_id)
                                ,to = c(layer_csv$near_id)
                                ,value = c(layer_csv$weight)
                                ,font.size = 10
                                ,label = paste("權重", layer_csv$weight)
                                ,font.color ="brown")
#print(total_nodes)
draw_sna_layer<-visNetwork(layer_nodes,layer_relationship, width = "100%", height = "500px")%>%
  visNodes(size = 30)%>%
  visOptions(highlightNearest = TRUE
             , selectedBy= "label"
             ,nodesIdSelection = list(enabled = TRUE
                                      ,style = 'width: 200px; height: 26px;
                                  background: #f8f8f8;
                                  color: darkblue;
                                  border:none;
                                  outline:none;'))%>%
  visPhysics(stabilization = FALSE,#動態效果
             solver = "repulsion",
             repulsion = list(gravitationalConstant = 1500))

visSave(draw_sna_layer, file = "../flask/templates/layer.html")


layerTable<- data.frame(node_id = c(all_layer_node $id)
                       ,node_name = c(all_layer_node $name)
                       ,node_attr_name = c(all_layer_node $attr_name)
                       ,node_eng_name = c(all_layer_node $enname)
                       ,node_weight=c(all_layer_node $total)
                       ,node_layer=c(all_layer_node $group)
                       )

write.csv(rankTable,"../flask/layerTable.csv", row.names = FALSE, fileEncoding = "UTF-8")
