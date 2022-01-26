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

from_id_name <- dbGetQuery(connect ,("select from_id,`name` from trans.node n,trans.result_weight r where n.id = r.from_id group by from_id"))
to_id_name <- dbGetQuery(connect ,("select to_id,`name` from trans.node n,trans.result_weight r where n.id = r.to_id group by to_id"))
node <- data.frame(id=c(from_id_name$from_id,to_id_name$to_id),name=c(from_id_name$name,to_id_name$name))
edge <- data.frame(from=c(list$from_id), to=c(list$to_id), value=c(list$total))
edge$width <- list$total

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
print("before csv")
result_table<- data.frame(from_id = c(from_id_name$from_id),from_id_name = c(from_id_name$name),to_id=c(to_id_name$to_id),to_id_name=c(to_id_name$name),weight=c(rel_id$total))
write.csv(degree_table,"../flask/degree_table.csv", row.names = FALSE, fileEncoding = "UTF-8")
