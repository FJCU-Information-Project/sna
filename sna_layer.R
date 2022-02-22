#ctrl shift + c 多行註解


library(visNetwork)
library(RMySQL)
#library(igraph)
library(utf8)
#install.packages("thepackage",lib="H:/Documents/R/win-library/4.1")
#library(thepackage,lib="H:/Documents/R/win-library/4.1")
layer_csv<- read.csv(file = paste0("..",.Platform$file.sep,"Flask",.Platform$file.sep,"layer.csv"), encoding = "UTF-8")
names(layer_csv)[1] <- "factor_id"#將第一個欄名變更

connect = dbConnect(MySQL(), dbname = "trans",username = "root",
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES BIG5") # 設定資料庫連線編碼
Sys.getlocale(category = "LC_ALL") # 查詢系統編碼環境
layer_to_id<-data.frame(from_id = c(layer_csv$factor_id),id = c(layer_csv$near_id),group=c(layer_csv$level),color=c(layer_csv$color),total=c(layer_csv$weight))

node_layer<- dbGetQuery(connect ,"select * from `node`")
attr_layer<- dbGetQuery(connect ,"select * from `attribute`")
names(attr_layer)[1] <- "attribute"
names(attr_layer)[2] <- "attr_name"
get_layer_attr<- merge(x = node_layer, y = attr_layer, by = "attribute", all.x = TRUE)#將屬性和節點表格合併
all_layer_node<- merge(x = layer_to_id, y = get_layer_attr, by = "id", all.x = TRUE)#用id合併得到節點的屬性資訊

all_layer_node<-unique(all_layer_node)#刪除重複的第二層節點
all_layer_node<-all_layer_node[order(all_layer_node$id,all_layer_node$group),]#將層級做降冪排列
all_layer_node <-all_layer_node[(!duplicated(all_layer_node$id)),]#刪除和第一層重複的第二層節點

#用於畫sna圖的節點
layer_nodes<- data.frame(id = c(all_layer_node$id), 
                         group = c(all_layer_node$group), 
                         label = paste(all_layer_node$name), 
                         title = paste("<p>", all_layer_node$name,"<br>", all_layer_node$attr_name,"<br>",all_layer_node$enname,"</p>"),
                         font.size = 20,
                         color=c(all_layer_node$color)
                         )
#用於畫sna圖的關聯
layer_relationship<- data.frame(from = c(layer_csv$factor_id)
                                ,to = c(layer_csv$near_id)
                                ,value = c(layer_csv$weight)
                                ,font.size = 10
                                ,label = paste("weight", layer_csv$weight)
                                ,font.color ="brown")
print(layer_nodes)
draw_sna_layer<-visNetwork(layer_nodes,layer_relationship, width = "100%", height = "500px")%>%
  visNodes(size = 30)%>%
  visOptions(highlightNearest = TRUE
             , selectedBy= "group"
             ,nodesIdSelection = list(enabled = TRUE
                                      ,style = 'width: 200px; height: 26px;
                                  background: #f8f8f8;
                                  color: darkblue;
                                  border:none;
                                  outline:none;'))%>%
  visPhysics(stabilization = FALSE,#動態效果
             solver = "repulsion",
             repulsion = list(gravitationalConstant = 1500))

visSave(draw_sna_layer, file = paste0("..",.Platform$file.sep,"Flask",.Platform$file.sep,"templates",.Platform$file.sep,"layer.html"), selfcontained = FALSE)

from_layer_id<-all_layer_node
names(from_layer_id)[2] <- "from_id"
get_layer_from_attr<-get_layer_attr
names(get_layer_from_attr)[2] <- "from_id"
all_from_layer_node<- merge(x = from_layer_id, y = get_layer_from_attr, by = "from_id", all.x = TRUE)#用id合併得到節點的屬性資訊

#層級分析csv表(欄位:第一層id、名稱、權重 和 第二層id、名稱、權重)
layerTable<- data.frame(first_id = c(all_from_layer_node $from_id)
                        ,first_name = c(all_from_layer_node $name.y)
                        #,first_attr_name = c(all_from_layer_node $attr_name.x)
                        #,first_eng_name = c(all_from_layer_node $enname.x)
                        ,second_id = c(all_from_layer_node $id)
                        ,second_name = c(all_from_layer_node $name.x)
                        ,total=c(all_from_layer_node $total)
                        ,group=c(all_from_layer_node $group)
                        #,second_attr_name = c(all_layer_node $attr_name)
                        #,second_eng_name = c(all_layer_node $enname)
                        #,node_layer=c(all_layer_node $group)
                       )
write.csv(layerTable,paste0("..",.Platform$file.sep,"Flask",.Platform$file.sep,"layer_table.csv"), row.names = FALSE, fileEncoding = "UTF-8")
