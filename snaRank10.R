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
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
Sys.setlocale("LC_ALL","Chinese") #解決中文編碼問題
node8<- dbSendQuery(connect,"SET NAMES gbk")
node8<- dbGetQuery(connect ,"select * from `node` where `id`=11")
relationship8<- dbGetQuery(connect ,"select * from `relationship` where `from_id`=11")
#選擇from_id
weight10<- dbGetQuery(connect ,"select * from `weight` where `from_id`=11 order by `total` desc")
weightfor10<-weight10[1:10,]
bindnode<-weightfor10
bn<-data.frame(id =bindnode[1,1])
bb<-data.frame(id = c(bindnode$to_id))
bb<-rbind(bn,bb)
t3<- dbGetQuery(connect ,"select * from `node`")
a<- dbGetQuery(connect ,"select * from `attribute`")
names(a)[1] <- "attribute"
names(a)[2] <- "attr_name"
getTitle<- merge(x = t3, y = a, by = "attribute", all.x = TRUE)#left join
allNode<- getTitle
all_node<- merge(x = bb, y = allNode, by = "id", all.x = TRUE)#left join
total_nodes<- data.frame(id = c(all_node$id), group = c(all_node$attr_name), 
                         label = paste(all_node$name), 
                         title = paste("<p>", all_node$attr_name,"<br>",all_node$enname,"</p>"),
                         font.size = 20)
weightRelationship<- data.frame(from = c(bindnode$from_id), to = c(bindnode$to_id)
                                ,value=c(bindnode$total),font.size =10,label = paste("權重", bindnode$total),font.color ="brown")
snaRank10<-visNetwork(total_nodes,weightRelationship, width = "100%", height = "500px")%>%
  visNodes(size = 30)%>%
  visOptions(highlightNearest = TRUE, selectedBy= "label",nodesIdSelection = list(enabled = TRUE,
                                                                                  style = 'width: 200px; height: 26px;
                                 background: #f8f8f8;
                                 color: darkblue;
                                 border:none;
                                 outline:none;'))%>%
  visPhysics(stabilization = FALSE,#動態效果
             solver = "repulsion",
             repulsion = list(gravitationalConstant = 1500))

visSave(snaRank10, file = "E:/GitHub/trans/public/snaRank10.html",selfcontained = FALSE, background = "white")

#顯示排名前十關聯名字case次數(權重)與排名數
bindnode$Rank<-floor(rank(-bindnode$total))
rank<-bindnode[order(floor(rank(bindnode$Rank))),]
# connect = dbConnect(MySQL(), dbname = "trans",username = "root",
#                     password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
# dbListTables(connect)
# Sys.setlocale("LC_ALL","Chinese") #解決中文編碼問題
ranknode<- dbGetQuery(connect ,"select * from `node`")
rankatr<- dbGetQuery(connect ,"select * from `attribute`")
names(ranknode)[1] <- "to_id"
ranknodename<- merge(x = rank, y = ranknode, by = "to_id", all.x = TRUE)#left join
library(dplyr)#使用arrange函數
newrank<-arrange(ranknodename, Rank) # 按 Rank 列進行升序排列
rankTable<- data.frame(肇事因素 = c(newrank$name), 關聯肇事因素排名 = c(newrank$Rank),Case總數=c(newrank$total))
#排名前十關聯table的csv
write.csv(rankTable,"E:/GitHub/trans/public/rankTable.csv", row.names = FALSE)
install.packages("tidyverse")
install.packages("jsonlite")
library(tidyverse)
library(jsonlite)
rankjson <- 
  as_tibble(rankTable, rownames = 'id') %>% 
  slice(1:10) %>% 
  select(肇事因素, 關聯肇事因素排名, Case總數)
rankjson<-toJSON(x = rankjson, dataframe = 'rows', pretty = T)
#顯示排名前十關聯table的json
save(rankjson, file="E:/GitHub/trans/public/rankTable.json")