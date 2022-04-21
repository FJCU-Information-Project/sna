#ctrl shift + c 多行註解

print("Hello Before library")

library(visNetwork)
#library(sqldf)
#library(RODBC)
#library(dbConnect)
#library(DBI)
#library(gWidgets)
library(RMySQL)
#library(xlsx)
library(igraph)
library(utf8)

args <- commandArgs(trailingOnly = TRUE)
id <- args[1] # CLI input parameter
rankUserId <- args[2] #(資料庫名稱，使用者名稱user_id)
rankDatasetId <- args[3] #(資料表代號，dataset)
print(rankUserId)
print(rankDatasetId)
connect = dbConnect(MySQL(), dbname = rankUserId,username = "root",
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES BIG5") # 設定資料庫連線編碼
Sys.getlocale(category = "LC_ALL") # 查詢系統編碼環境
#Sys.setlocale("LC_ALL","Chinese") # 設定系統編碼為簡體中文
print(11)
# node8<- dbGetQuery(connect ,paste("select * from `node` where `id`=", id))
node8<- dbGetQuery(connect ,paste("select * from node where id=",id," and dataset=",rankDatasetId))
print(node8)
# relationship8<- dbGetQuery(connect ,paste("select * from `weight` where `from_id`= ",id))
relationship8<- dbGetQuery(connect ,paste("select * from weight where from_id= ",id,"and dataset=",rankDatasetId))
# relationship_toid<- dbGetQuery(connect ,paste("select * from `weight` where `to_id`=",id))
relationship_toid<- dbGetQuery(connect ,paste("select * from weight where `to_id`=",id,"and dataset=",rankDatasetId))
names(relationship_toid)[3] <- "to_id"
names(relationship_toid)[4] <- "from_id"

#選擇from_id
#weight10<- dbGetQuery(connect ,paste("select * from `weight` where `from_id`= ", id, " order by `total` desc"))
weight10<- dbGetQuery(connect ,paste("select * from weight where `from_id`= ", id,"and dataset=",rankDatasetId,"order by `total` desc"))
# weight_toid<- dbGetQuery(connect ,paste("select * from `weight` where `to_id`=",id,"order by `total` desc"))
weight_toid<- dbGetQuery(connect ,paste("select * from weight where `to_id`=",id,"and dataset=",rankDatasetId,"order by `total` desc"))
names(weight_toid)[2] <- "to_id"
names(weight_toid)[3] <- "from_id"
weight10<-rbind(weight10,weight_toid)
weight10<-weight10[order(weight10$total,decreasing = T),]
count_toid<-(length(weight10$to_id))
count_toid<-ceiling(count_toid*0.1)

weightfor10<-weight10[1:count_toid,]
bindnode<-weightfor10
rankbindnode<-bindnode
rankbindnode$rank <- 1:count_toid
c
c <- 2
while (c <= count_toid){
  if (rankbindnode$total[c]==rankbindnode$total[c-1]){
    rankbindnode$rank[c] <- rankbindnode$rank[c-1]
  }
  c <- c+1
}
bn<-data.frame(id =bindnode[1,2])
bb<-data.frame(id = (bindnode$to_id))
bb<-rbind(bn,bb)
t3<- dbGetQuery(connect ,paste0("select * from `node`where dataset=",rankDatasetId))
a<- dbGetQuery(connect ,paste0("select * from `attribute` where dataset=",rankDatasetId))
names(a)[2] <- "attribute"
names(a)[3] <- "attr_name"
getTitle<- merge(x = t3, y = a, by = "attribute", all.x = TRUE)#left join
allNode<- getTitle
all_node<- merge(x = bb, y = allNode, by = "id", all.x = TRUE)#left join
all_node <- all_node[!duplicated(all_node),]
#r<- dbGetQuery(connect ,paste("select * from `relationship` where `to_id`=",id))
#r[!duplicated(r[,c(3,4)]),]

centernode=data.frame(total =3000)
orderothernode<-bindnode[order(bindnode$to_id),]
othernode=data.frame(total=orderothernode$total)
nodevalue<-rbind(centernode,othernode)

getnodetable<-t3
names(getnodetable)[1] <- "to_id"
getweightgroup<- merge(x = getnodetable, y = orderothernode, by = "to_id", all.y = TRUE)#left join
print(111111)
total_nodes<- data.frame(id = c(all_node$id), group = c(all_node$attr_name), 
                         label = paste(all_node$name), 
                         title = paste("<p>", all_node$attr_name,all_node$enname,"</p>"),
                         font.size = 15,value = c(nodevalue$total))
weightRelationship<- data.frame(from = c(bindnode$from_id)
                                ,to = c(bindnode$to_id)
                                ,value = c(bindnode$total)
                                ,font.size = 10
                                #,label = paste("權重", bindnode$total)
                                # Why Error?
                                ,title=paste("Weight :",bindnode$total,"Rank : ",rankbindnode$rank)
                                ,group=c(getweightgroup$name)
                                ,font.color ="brown")
snaRank10<-visNetwork(total_nodes,weightRelationship, width = "100%", height = "500px")%>%
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

visSave(snaRank10, file = "../flask/templates/snaRank10.html",selfcontained = FALSE, background = "white")

#顯示排名前十關聯名字case次數(權重)與排名數
bindnode$Rank<-floor(rank(-bindnode$total))
rank<-bindnode[order(floor(rank(bindnode$Rank))),]
# connect = dbConnect(MySQL(), dbname = "trans",username = "root",
#                     password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
# dbListTables(connect)
# Sys.setlocale("LC_ALL","Chinese") #解決中文編碼問題
ranknode<- dbGetQuery(connect ,paste0("select * from `node` where dataset=",rankDatasetId))
rankatr<- dbGetQuery(connect ,paste0("select * from `attribute`where dataset=",rankDatasetId))
names(ranknode)[3] <- "to_id"
ranknodename<- merge(x = rank, y = ranknode, by = "to_id", all.x = TRUE)#left join
library(dplyr)#使用arrange函數
newrank<-arrange(ranknodename, Rank) # 按 Rank 列進行升序排列
# rankTable<- data.frame(肇事因素 = c(newrank$name)
#           , 關聯肇事因素排名 = c(newrank$Rank)
#           ,Case總數=c(newrank$total))
rankTable<- data.frame(factor = c(newrank$name)
          ,factorRank = c(newrank$Rank)
          ,caseWeight=c(newrank$total))
#排名前十關聯table的csv
write.csv(rankTable,"../flask/rank_table.csv", row.names = FALSE, fileEncoding = "UTF-8")
print(55)

# install.packages("tidyverse")
# install.packages("jsonlite")
# library(tidyverse)
# library(jsonlite)
# print(3)
# rankjson <- 
#   as_tibble(rankTable, rownames = 'id') %>% 
#   slice(1:count_toid) %>% 
#   select(factor, factorRank, caseNumber)
# print(2)
# rankjson<-toJSON(x = rankjson, dataframe = 'rows', pretty = T)
# #顯示排名前十關聯table的json
# print(1)
# save(rankjson, file="E:/GitHub/trans/public/rankTable.json")
# print(0)