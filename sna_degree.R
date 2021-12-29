library(visNetwork)
library(sqldf)
library(RODBC)
library(dbConnect)
library(DBI)
library(gWidgets)
library(RMySQL)
library(xlsx)
library(sqldf)

connect = dbConnect(MySQL(), dbname = "trans",username = "root",
                    password = "IM39project",host = "localhost",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
Sys.setlocale("LC_ALL","Chinese") #解決中文編碼問題



count_1 <- dbGetQuery(connect ,"SELECT SUM(`total`) FROM weight group by from_id") #算出每個from_id有幾組關聯
count_total <- dbGetQuery(connect ,"SELECT SUM(`total`) FROM weight") #算出總共有幾組關聯
degree_from_id <- dbGetQuery(connect ,"SELECT from_id FROM weight group by from_id")
data <- data.frame(from_id=c(degree_from_id),count=c(count_1),count_total=c(count_total))
degree_ans <- round(data[2]/data[3]*100, digits = 2)
degree_dataframe <- data.frame(from_id=c(degree_from_id),degree=c(degree_ans)) 

node_id <- dbGetQuery(connect ,"SELECT * FROM weight WHERE from_id=1")
from_id_name <- dbGetQuery(connect ,"select from_id,`name` from trans.node n,trans.weight w where from_id=1 and  n.id = w.to_id group by from_id")
to_id_name <- dbGetQuery(connect ,"select to_id,`name` from trans.node n,trans.weight w where from_id=1 and  n.id = w.to_id group by to_id")
node_name <- data.frame(id=c(node[1,1],node_id$to_id),name=c(from_id_name$name,to_id_name$name))
node <- data.frame(id=c(node[1,1],node_id$to_id),label = paste(node_name$name),title = paste(node_name$name),font.size = 20)
rel_id <- dbGetQuery(connect ,"SELECT from_id, to_id, total, name FROM weight, node WHERE from_id=1")
edge <- data.frame(from=c(rel_id$from_id), to=c(rel_id$to_id), value=c(rel_id$total))
edge$width <- rel_id$total
# 
degree_pic <- visNetwork(node, edge, width = "100%", height = "500px")%>%
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

visSave(degree_pic, file = "E:/GitHub/degree.html",selfcontained = FALSE, background = "white")
