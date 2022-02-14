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
inId1 <- args[1] # CLI input parameter
inId2 <- args[2]
#inId1 <- "未受傷"
#inId2 <- 2

connect = dbConnect(MySQL(), dbname = "trans",username = "root",
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES BIG5") # 設定資料庫連線編碼
Sys.getlocale("LC_ALL") #解決中文編碼問題
print("21")
print(inId1)
toIdName<-(dbGetQuery(connect ,paste("select * from trans.node n,trans.result_weight r where n.id = r.to_id")))
select_result <- data.frame(c(dbGetQuery(connect ,paste("select * from trans.node n,trans.result_weight r where n.id = r.from_id"))),to_id_name=c(toIdName[,2])) 

select_result_chosen <- select_result[select_result$result_name==inId1,] #拿到某結果為條件下的所有資料
#print(select_result_chosen)
#rank_weight <- dbGetQuery(connect, paste("select * from trans.result_weight where result_name = '",inId1,"' order by `total` desc")) 
rank_weight <- data.frame(c(select_result_chosen[order(-select_result_chosen$total),])) #將權重由高到低排序
#print(rank_weight)
print("25")
#count <- dbGetQuery(connect ,paste("select count(result_name) from trans.result_weight where result_name = '",inId1,"'")) 
count <- data.frame(c(dim(rank_weight)))
count <- count[1,1] #計算資料筆數
print(count)
print("27")
count_rank <- round(count*0.01) #計算要顯示幾筆資料(目前設定前1%)
print("29")
list <- data.frame(rank=c(1:count_rank), c(rank_weight[1:count_rank,]))
rank_weight <- rank_weight[1:count_rank,]
print("31")
draw_data <- data.frame(c(list[inId2,])) #找到想印的名次的資料(目前是印權重第一名)
print("33")
#from_id_name <- dbGetQuery(connect ,paste("select * from trans.node n,trans.result_weight r where n.id = r.from_id"))
#table_from_id_name <- from_id_name[1:count_rank,2] #列出前1%的from_id_name
#to_id_name <- dbGetQuery(connect ,paste("select to_id,`name` from trans.node n,trans.result_weight r where result_name = '",inId1,"' and n.id = r.to_id order by `total` desc"))
#table_to_id_name <- to_id_name[1:count_rank,2] #列出前1%的to_id_name
print("38")
print(inId2)
print(draw_data)
#簡寫的#draw_from_id <- draw_data[inId2,6] #找到from_id
draw_from_id <- draw_data[,6] #找到from_id
print(draw_from_id)
#簡寫的#draw_to_id <- draw_data[inId2,7] #找到to_id
draw_to_id <- draw_data[,7] #找到to_id
#簡寫的#weight <- draw_data[inId2,8] #找到weight
weight <- draw_data[,8] #找到weight
#draw_from_id_name <- dbGetQuery(connect ,paste("select from_id,`name` from trans.node n,trans.result_weight r where result_name = '",inId1,"' and n.id = r.from_id and n.id = ",inId2," group by from_id"))
#draw_to_id_name <- dbGetQuery(connect ,paste("select to_id,`name` from trans.node n,trans.result_weight r where result_name = '",inId1,"' and n.id = r.to_id and n.id = ",inId2," group by to_id"))
node <- data.frame(id=c(draw_from_id,draw_to_id),label = c(draw_data[1,3],draw_data[1,9]),title = c(draw_data[inId2,6],draw_data[inId2,7]),font.size = 20)
edge <- data.frame(from=c(draw_from_id), to=c(draw_to_id), value=c(weight))
print(node)
print(edge)
edge$width <- weight
print("47")
print(inId1)
print(inId2)
print(node)
print(edge)
result_table<- data.frame(rank=c(list$rank),from_id=c(rank_weight$from_id),from_id_name=c(rank_weight$name),to_id=c(rank_weight$to_id),to_id_name=c(rank_weight$to_id_name),total=c(rank_weight$total))
write.csv(result_table,"E:\\GitHub\\flask\\result_table.csv", row.names = FALSE, fileEncoding = "UTF-8")
print(52)
result_pic <- visNetwork(node, edge, width = "100%", height = "500px")%>%
  visNodes(size = 30)%>%
  visOptions(highlightNearest = TRUE
              ,selectedBy= "label"
              ,nodesIdSelection = list(enabled = TRUE
                                        ,style = 'width: 200px; height: 26px;
                                 background: #f8f8f8;
                                 color: darkblue;
                                 border:none;
                                 outline:none;'))%>%
  visPhysics(stabilization = FALSE,#動態效果
             solver = "repulsion",
             repulsion = list(gravitationalConstant = 1500))
print("59")
visSave(result_pic, file = "E:\\GitHub\\flask\\templates\\result.html",selfcontained = FALSE, background = "white")
print("61")
print("64")