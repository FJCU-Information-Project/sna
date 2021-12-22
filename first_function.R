#ctrl shift + c 多行註解

library(visNetwork)
library(sqldf)
library(RODBC)
library(dbConnect)
library(DBI)
library(gWidgets)
library(RMySQL)
library(xlsx)
library(sqldf)
library(igraph)
connect = dbConnect(MySQL(), dbname = "trans",username = "root",
                    password = "IM39project",host = "localhost",DBMSencoding="UTF8")
dbListTables(connect)
Sys.setlocale("LC_ALL","Chinese") #解決中文編碼問題
#node8<- dbSendQuery(connect,"SET NAMES gbk")
# node8<- dbGetQuery(connect ,"select * from `node` where `id`=8")
nodeforloop<-dbSendQuery(connect,"SET NAMES gbk")
nodeforloop<- dbGetQuery(connect ,"select * from `node`")
# relationship8<- dbGetQuery(connect ,"select * from `relationship` where `from_id`=8")
relationshipforloop<- dbGetQuery(connect ,"select * from `relationship`")
# node_list<<-list()
# relationship_list<<-list()
node_data_frame<<-data.frame(node=numeric(),first=numeric(),second=numeric(),third=numeric(),forth=numeric(),fifth=numeric())
relationship_data_frame<<-data.frame(first=numeric(),second=numeric(),third=numeric(),forth=numeric(),fifth=numeric())
# count <<- 1
for (i in c(nodeforloop$id)){
  weightloop <- dbGetQuery(connect, paste("select * from `weight` where `from_id`=",i," order by `total` desc"))
  cat("select * from `weight` where `from_id`=",i," order by `total` desc")
  weightforloop5<-weightloop[1:5,]
  bindnode<-weightforloop5
  bn<-bindnode[1,1]
  bn8<-data.frame(id = c(bindnode$to_id))
  bb<-data.frame()
  bb<-data.frame(id = c(weightloop$from_id[1]))
  bb<-rbind(bb,bn8)
  allNode<- getTitle
  all_node<- merge(x = bb, y = allNode, by = "id", all.x = TRUE)#left join
  total_nodes<- data.frame(id = c(all_node$id), group = c(all_node$attr_name), 
                           label = paste(all_node$name), 
                           title = paste("<p>", all_node$attr_name,"<br>",all_node$enname,"</p>"),
                           font.size = 20)
  weightRelationship<- data.frame(from = c(weightfor5$from_id), to = c(weightfor5$to_id),value=c(weightfor5$total))
  # node_list[i] <- total_nodes
  # relationship_list[i] <- weightRelationship
  node_data_frame[nrow(node_data_frame) + 1,] = c(bb$id[1],bb$id[2],bb$id[3],bb$id[4],bb$id[5],bb$id[6])
  # node_data_frame$first[count]<-bb$id[2]
  # node_data_frame$second[count]<-bb$id[3]
  # node_data_frame$third[count]<-bb$id[4]
  # node_data_frame$forth[count]<-bb$id[5]
  # node_data_frame$fifth[count]<-bb$id[6]
  # node_list[]
  
  relationship_data_frame[nrow(relationship_data_frame) + 1,] = c(weightRelationship$value[1],weightRelationship$value[2],weightRelationship$value[3],weightRelationship$value[4],weightRelationship$value[5],weightRelationship$value[6])
  # relationship_data_frame$first[count]<-weightRelationship$value[1]
  # relationship_data_frame$second[count]<-weightRelationship$value[2]
  # relationship_data_frame$third[count]<-weightRelationship$value[3]
  # relationship_data_frame$forth[count]<-weightRelationship$value[4]
  # relationship_data_frame$fifth[count]<-weightRelationship$value[5]
  # count+1
  
  #   data.frame(node=]),first=c(),second=c(total_nodes$id[3]),third=c(total_nodes$id[4]),
  #                           forth=c(total_nodes$id[5]),fifth=c(total_nodes$id[6]))
  # relationship_data_frame<-data.frame(fw=c(weightRelationship$value[1]),sw=c(weightRelationship$value[2]),
  #                                     tw=c(weightRelationship$value[3]),fow=c(weightRelationship$value[4]),fiw=c(weightRelationship$value[5]))
}
# for(i in nchar(node_list))
# {
sna_a<-visNetwork(node_data_frame,relationship_data_frame, width = "100%", height = "500px")%>%
  visNodes(size = 30)%>%
  visOptions(highlightNearest = TRUE, selectedBy= "label")%>%
  visPhysics(stabilization = FALSE,#動態效果
             solver = "repulsion",
             repulsion = list(gravitationalConstant = 1500))
# 
# sna_a<-visNetwork(total_nodes,weightRelationship, width = "100%", height = "500px")%>%
#   visNodes(size = 30)%>%
#   visOptions(highlightNearest = TRUE, selectedBy= "label")%>%
#   visPhysics(stabilization = FALSE,#動態效果
#              solver = "repulsion",
#              repulsion = list(gravitationalConstant = 1500))
#選擇from_id
# weight8<- dbGetQuery(connect ,"select * from `weight` where `from_id`=8 order by `total` desc")
# weightfor5<-weight8[1:5,]
# bindnode<-weightfor5
# bn<-bindnode[1,1]
# bn8<-data.frame(id =bindnode[1,1])
# bb<-data.frame(id = c(bindnode$to_id))
# bb<-rbind(bn8,bb)
# allNode<- getTitle
# all_node<- merge(x = bb, y = allNode, by = "id", all.x = TRUE)#left join
# total_nodes<- data.frame(id = c(all_node$id), group = c(all_node$attr_name), 
#                     label = paste(all_node$name), 
#                     title = paste("<p>", all_node$attr_name,"<br>",all_node$enname,"</p>"),
#                     font.size = 20)
# weightRelationship<- data.frame(from = c(weightfor5$from_id), to = c(weightfor5$to_id),value=c(weightfor5$total))
# sna_a<-visNetwork(total_nodes,weightRelationship, width = "100%", height = "500px")%>%
#   visNodes(size = 30)%>%
#   visOptions(highlightNearest = TRUE, selectedBy= "label")%>%
#   visPhysics(stabilization = FALSE,#動態效果
#              solver = "repulsion",
#              repulsion = list(gravitationalConstant = 1500))
# 
visSave(sna_a, file = "../trans/public/sna_a.html",selfcontained = FALSE, background = "white")