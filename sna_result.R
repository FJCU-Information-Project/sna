library(visNetwork)
#library(sqldf)
#library(RODBC)
#library(dbConnect)
#library(DBI)
#library(gWidgets)
library(RMySQL)
#library(xlsx)
#library(sqldf)


# args <- commandArgs(trailingOnly = TRUE)
# inId <- args[1] # CLI input parameter


connect = dbConnect(MySQL(), dbname = "trans",username = "root",
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES BIG5") # 設定資料庫連線編碼
Sys.getlocale("LC_ALL") #解決中文編碼問題

select_reault <- dbGetQuery(connect ,("select * from trans.result_weight where result_name = '受傷'")) #拿到某結果為條件下的所有資料
rank_weight <- dbGetQuery(connect, ("select * from trans.result_weight where result_name = '受傷' order by `total` desc")) #將權重由高到低排序
count <- dbGetQuery(connect ,("select count(result_name) from trans.result_weight where result_name = '受傷'")) #計算資料筆數
count_rank <- round(count[1,1]*0.01) #計算要顯示幾筆資料(目前設定前1%)
list <- data.frame(rank=c(1:count_rank), c(rank_weight[1:count_rank,]))
draw_data <- data.frame(c(list[1,])) #找到想印的名次的資料(目前是印權重第一名)

from_id_name <- dbGetQuery(connect ,("select from_id,`name` from trans.node n,trans.result_weight r where result_name = '受傷' and n.id = r.from_id order by `total` desc"))
table_from_id_name <- from_id_name[1:count_rank,2] #列出前1%的from_id_name
to_id_name <- dbGetQuery(connect ,("select to_id,`name` from trans.node n,trans.result_weight r where result_name = '受傷' and n.id = r.to_id order by `total` desc"))
table_to_id_name <- to_id_name[1:count_rank,2] #列出前1%的to_id_name

draw_from_id <- draw_data[1,3] #找到from_id
draw_to_id <- draw_data[1,4] #找到to_id
weight <- draw_data[1,5] #找到weight
draw_from_id_name <- dbGetQuery(connect ,("select from_id,`name` from trans.node n,trans.result_weight r where result_name = '受傷' and n.id = r.from_id and n.id = 139 group by from_id"))
draw_to_id_name <- dbGetQuery(connect ,("select to_id,`name` from trans.node n,trans.result_weight r where result_name = '受傷' and n.id = r.to_id and n.id = 184 group by to_id"))
node <- data.frame(id=c(draw_from_id,draw_to_id),label = c(draw_from_id_name[1,2],draw_to_id_name[1,2]),title = c(draw_from_id_name[1,1],draw_to_id_name[1,1]),font.size = 20)
edge <- data.frame(from=c(draw_from_id), to=c(draw_to_id), value=c(weight))
edge$width <- weight

result_pic <- visNetwork(node, edge, width = "100%", height = "500px")%>%
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

visSave(result_pic, file = "../flask/templates/result.html",selfcontained = FALSE, background = "white")

result_table<- data.frame(rank=c(list$rank),from_id=c(list$from_id),from_id_name=c(table_from_id_name),to_id=c(list$to_id),to_id_name=c(table_to_id_name),total=c(list$total))
write.csv(result_table,"../flask/result_table.csv", row.names = FALSE, fileEncoding = "UTF-8")
