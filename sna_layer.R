#ctrl shift + c 多行註解


library(visNetwork)
library(RMySQL)
library(utf8)
layerUserId <- "5678" #(資料庫名稱，使用者名稱user_id)
print(1)
layerDatasetId <- 1 #(資料表代號，dataset)
#layer_csv<- read.csv(file = paste0("..",.Platform$file.sep,"Flask",.Platform$file.sep,"layer.csv"), encoding = "UTF-8")
layer_csv<- read.csv(file = "E://GitHub/Flask/layer.csv", encoding = "UTF-8")
layertable_csv<- read.csv(file = "E://GitHub/Flask/layertable.csv", encoding = "UTF-8")
names(layer_csv)[1] <- "factor_id"#將第一個欄名變更
#print(layertable_csv)

connect = dbConnect(MySQL(), dbname = layerUserId,username = "root",
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES utf8") # 設定資料庫連線編碼
Sys.getlocale(category = "LC_ALL") # 查詢系統編碼環境
layer_to_id<-data.frame(from_id = c(layer_csv$factor_id),id = c(layer_csv$near_id),group=c(layer_csv$level),color=c(layer_csv$color),total=c(layer_csv$weight))
# node_layer<- dbGetQuery(connect ,"select * from `node`")
node_layer<-dbGetQuery(connect ,paste0("select * from `node` where dataset=",layerDatasetId))
# attr_layer<- dbGetQuery(connect ,"select * from `attribute`")
attr_layer<- dbGetQuery(connect ,paste0("select * from `attribute` where dataset=",layerDatasetId))

names(attr_layer)[2] <- "attribute"
names(attr_layer)[3] <- "attr_name"
get_layer_attr<- merge(x = node_layer, y = attr_layer, by = "attribute", all.x = TRUE)#將屬性和節點表格合併
all_layer_node<- merge(x = layer_to_id, y = get_layer_attr, by = "id", all.x = TRUE)#用id合併得到節點的屬性資訊
#all_layer_node<-unique(all_layer_node)#刪除重複的第二層節點
#all_layer_node<-all_layer_node[order(all_layer_node$id,all_layer_node$group),]#將層級做降冪排列
#print(all_layer_node)
all_layer_node <-all_layer_node[(!duplicated(all_layer_node$id)),]#刪除和第一層重複的第二層節點
##first_layer_weight<-all_layer_node[all_layer_node$group == "第1層", ]

count_rel<-(length(layer_csv$near_id))
layer_csv$rank <- 1:count_rel
i <- 2
while (i <= count_rel){
  if (layer_csv$weight[i]==layer_csv$weight[i-1]){
    layer_csv$rank[i] <- layer_csv$rank[i-1]
  }
  i <- i+1
}
#用於畫sna圖的節點
layer_nodes<- data.frame(id = c(all_layer_node$id), 
                         group = c(all_layer_node$group), 
                         label = paste(all_layer_node$name), 
                         #title = paste("<p>", all_layer_node$name,"<br>", all_layer_node$attr_name,"<br>",all_layer_node$enname,"</p>"),
                         font.size = 10,
                         color=c(all_layer_node$color)
                         #value=c(first_layer_weight$total)
                         )
#用於畫sna圖的關聯
layer_relationship<- data.frame(from = c(layer_csv$factor_id)
                                ,to = c(layer_csv$near_id)
                                ,value = c(layer_csv$weight)
                                ,font.size = 10
                                ,title = paste("weight", layer_csv$weight,"Rank : ",layer_csv$rank)
                                ,font.color ="brown")
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
             repulsion = list(gravitationalConstant = 150)
             )

visSave(draw_sna_layer, file = paste0("..",.Platform$file.sep,"Flask",.Platform$file.sep,"templates",.Platform$file.sep,"layer.html"), selfcontained = FALSE)

from_layer_id<-all_layer_node
names(from_layer_id)[2] <- "from_id"
#print(from_layer_id)

#藉由from_id找尋節點關聯資料庫的名稱start
get_layer_from_attr<-get_layer_attr
names(get_layer_from_attr)[3] <- "from_id"
nodename<- data.frame(from_id = c(get_layer_from_attr $from_id),
                      node_name=c(get_layer_from_attr $name),
                      attr_name=c(get_layer_from_attr $attr_name)
                     )
#藉由from_id找尋節點關聯資料庫的名稱end

all_from_layer_node<- merge(x = from_layer_id, y = get_layer_from_attr, by = "from_id", all.x = TRUE)#用id合併得到節點的屬性資訊
##新表merge by from_id
names(layertable_csv)[1]<-"from_id"
# print(layertable_csv)
layer1_node_name<- merge(x = layertable_csv, y = nodename, by = "from_id", all.x = TRUE)#用id合併得到節點的屬性資訊
names(layer1_node_name)[1]<-"first_id"
names(layer1_node_name)[10]<-"first_node_name"
names(layer1_node_name)[11]<-"first_attr_name"
names(layer1_node_name)[2]<-"from_id"
layer2_node_name<- merge(x = layer1_node_name, y = nodename, by = "from_id", all.x = TRUE)#用id合併得到節點的屬性資訊
names(layer2_node_name)[1]<-"second_id"
names(layer2_node_name)[12]<-"second_node_name"
names(layer2_node_name)[13]<-"second_attr_name"
names(layer2_node_name)[6]<-"from_id"
layer3_node_name<- merge(x = layer2_node_name, y = nodename, by = "from_id", all.x = TRUE)#用id合併得到節點的屬性資訊
names(layer3_node_name)[1]<-"third_id"
names(layer3_node_name)[14]<-"third_node_name"
names(layer3_node_name)[15]<-"third_attr_name"
print(11)
layer3_node_name$sum_weight <- layer3_node_name$weight1 + layer3_node_name$weight2
#print(layer3_node_name)
layerTableWeb<-layer3_node_name[order(layer3_node_name$sum_weight, decreasing = TRUE), ]
#print(layerTableWeb)
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
#print(layerTable)
#write.csv(layerTable,"../flask/layerHtmlTable.csv", row.names = FALSE, fileEncoding = "UTF-8")
write.csv(layerTableWeb,"../flask/layerHtmlTable.csv", row.names = FALSE, fileEncoding = "UTF-8")

# write.csv(layerTable,paste0("..",.Platform$file.sep,"Flask",.Platform$file.sep,"layer_table.csv"), row.names = FALSE, fileEncoding = "UTF-8")
#write.csv(layertable,"../flask/Rlayertable.csv", row.names = FALSE, fileEncoding = "UTF-8")
print("success")
