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

count_1 <- dbGetQuery(connect ,"SELECT COUNT(`to_id`) FROM weight group by from_id") #算出每個from_id有幾種不同的關聯
closeness_from_id <- dbGetQuery(connect ,"SELECT from_id FROM weight group by from_id") 
closeness_dataframe <- data.frame(from_id=c(closeness_from_id),count=c(count_1)) 


node_id <- dbGetQuery(connect ,paste("SELECT * FROM weight WHERE `from_id` = ", inId))
node <- data.frame(id=c(node_id[1,1],node_id$to_id))
rel_id <- dbGetQuery(connect ,paste("SELECT * FROM weight WHERE `from_id` = ", inId))
edge <- data.frame(from=c(rel_id$from_id), to=c(rel_id$to_id), value=c(rel_id$total))
edge$width <- rel_id$total

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