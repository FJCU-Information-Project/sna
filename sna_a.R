#ctrl shift + c 多行註解
install.packages("visNetwork")
install.packages("dbConnect")
install.packages("RMySQL")
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
node8<- dbSendQuery(connect,"SET NAMES gbk")
node8<- dbGetQuery(connect ,"select * from `node` where `id`=8")
relationship8<- dbGetQuery(connect ,"select * from `relationship` where `from_id`=8")
#選擇from_id
weight8<- dbGetQuery(connect ,"select * from `weight` where `from_id`=8 order by `total` desc")
weightfor5<-weight8[1:5,]
bindnode<-weightfor5
bn<-bindnode[1,1]
bn8<-data.frame(id =bindnode[1,1])
bb<-data.frame(id = c(bindnode$to_id))
bb<-rbind(bn8,bb)
allNode<- getTitle
all_node<- merge(x = bb, y = allNode, by = "id", all.x = TRUE)#left join
total_nodes<- data.frame(id = c(all_node$id), group = c(all_node$attr_name), 
                    label = paste(all_node$name), 
                    title = paste("<p>", all_node$attr_name,"<br>",all_node$enname,"</p>"),
                    font.size = 20)
weightRelationship<- data.frame(from = c(weightfor5$from_id), to = c(weightfor5$to_id),value=c(weightfor5$total))
sna_a<-visNetwork(total_nodes,weightRelationship, width = "100%", height = "500px")%>%
  visNodes(size = 30)%>%
  visOptions(highlightNearest = TRUE, selectedBy= "label")%>%
  visPhysics(stabilization = FALSE,#動態效果
             solver = "repulsion",
             repulsion = list(gravitationalConstant = 1500))

visSave(sna_a, file = "E:/GitHub/trans/public/sna_a.html",selfcontained = FALSE, background = "white")