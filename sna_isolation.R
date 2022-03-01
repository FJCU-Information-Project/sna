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

print("15")
connect = dbConnect(MySQL(), dbname = "trans",username = "root",
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES BIG5") # 設定資料庫連線編碼
Sys.getlocale("LC_ALL") #解決中文編碼問題
print("21")
print(inId)
select_isolation <- data.frame(c(dbGetQuery(connect ,paste("SELECT * FROM trans.default_relationship where from_id = ",inId," and total = 0"))))
select_node <- data.frame(c(dbGetQuery(connect ,paste("SELECT * FROM trans.default_relationship where from_id = ",inId))))
select_draw_edge <- data.frame(c(dbGetQuery(connect ,paste("SELECT * FROM trans.default_relationship where from_id = ",inId," and total != 0"))))
print(select_isolation)
print(select_node)
from_id_name <- data.frame(c(dbGetQuery(connect ,paste("select from_id,`name` from trans.node n,trans.default_relationship d where from_id = ",inId," and n.id = d.from_id"))))
to_id_name <- data.frame(c(dbGetQuery(connect ,paste("select to_id,`name` from trans.node n,trans.default_relationship d where from_id = ",inId," and n.id = d.to_id"))))
table_from_id_name <- data.frame(c(dbGetQuery(connect ,paste("select from_id,`name` from trans.node n,trans.default_relationship d where from_id = ",inId," and total = 0 and n.id = d.from_id"))))
table_to_id_name <- data.frame(c(dbGetQuery(connect ,paste("select to_id,`name` from trans.node n,trans.default_relationship d where from_id = ",inId," and total = 0 and n.id = d.to_id"))))
print("25")
node <- data.frame(id=c(select_node[1,1],select_node[,2]),label = c(from_id_name[1,2],to_id_name[,2]),title = c(from_id_name[1,2],to_id_name[,2]),font.size = 20)
edge <- data.frame(from=c(select_draw_edge[,1]), to=c(select_draw_edge[,2]), value=c(select_draw_edge[,3]))
edge$width <- select_draw_edge[,3]
print("29")
isolation_pic <- visNetwork(node,edge, width = "100%", height = "500px")%>%
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

visSave(isolation_pic, file = "../flask/templates/isolation.html",selfcontained = FALSE, background = "white")
print("43")
isolation_table <- data.frame(from_id=c(select_isolation$from_id),from_id_name=c(table_from_id_name$name),to_id=c(select_isolation$to_id),to_id_name=c(table_to_id_name$name),total=c(select_isolation$total))
write.csv(isolation_table,"../flask/isolation_table.csv", row.names = FALSE, fileEncoding = "UTF-8")
print("success")