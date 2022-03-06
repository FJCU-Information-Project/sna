library(visNetwork)
#library(sqldf)
#library(RODBC)
#library(dbConnect)
#library(DBI)
#library(gWidgets)
library(RMySQL)
#library(xlsx)
#library(sqldf)


args <- commandArgs(trailingOnly = TRUE)
inId <- args[1] # CLI input parameter


connect = dbConnect(MySQL(), dbname = "trans",username = "root",
                    password = "IM39project",host = "localhost",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES BIG5") # 設定資料庫連線編碼
Sys.getlocale("LC_ALL") #解決中文編碼問題

print("after db")
count_1 <- dbGetQuery(connect ,paste("SELECT from_id,COUNT(`to_id`) as total FROM trans.weight WHERE `from_id` = ",inId,"or `to_id` = ",inId,"  group by from_id")) #算出每個from_id有幾種不同的關聯
print("1")
closeness_from_id <- dbGetQuery(connect ,paste("SELECT id,name FROM node WHERE `id` = ",inId, "group by id"))
print("2")
closeness_dataframe <- data.frame(from_id=c(count_1$from_id),from_id_name=c(closeness_from_id$name),count=c(count_1$total)) 

print("after data")
node_id <- dbGetQuery(connect ,paste("SELECT * FROM weight WHERE `from_id` = ",inId,"or `to_id` = ",inId))
from_id_name <- dbGetQuery(connect ,paste("select from_id,`name` from trans.node n,trans.weight w where `from_id` = ",inId,"or `to_id` = ",inId," and  n.id = w.to_id group by from_id"))
to_id_name <- dbGetQuery(connect ,paste("select to_id,`name` from trans.node n,trans.weight w where `from_id` = ",inId,"or `to_id` = ",inId," and  n.id = w.to_id group by to_id"))
node_name <- data.frame(id=c(node_id[1,1],node_id$to_id),name=c(from_id_name$name,to_id_name$name))
node <- data.frame(id=c(node_id[1,1],node_id$to_id),label = paste(node_name$id),title = paste(node_name$id),font.size = 20)
rel_id <- dbGetQuery(connect ,paste("SELECT * FROM weight WHERE `from_id` = ",inId,"or `to_id` = ",inId))
edge <- data.frame(from=c(rel_id$from_id), to=c(rel_id$to_id), value=c(rel_id$total))
edge$width <- rel_id$total

print("after fetch node")
closeness_pic <- visNetwork(node, edge, width = "100%", height = "500px")%>%
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
print("Sucess")
visSave(closeness_pic, file = "../flask/templates/closeness.html",selfcontained = FALSE, background = "white")
print("End")
closeness_table<- data.frame(from_id = c(closeness_dataframe$from_id),from_id_name = c(closeness_dataframe$from_id_name),weight=c(closeness_dataframe$count))
write.csv(closeness_table,"../flask/closeness_table.csv", row.names = FALSE, fileEncoding = "UTF-8")
print("Create CSV")
