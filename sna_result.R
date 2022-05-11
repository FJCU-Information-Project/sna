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
inId2 <- args[2] #(資料庫名稱，使用者代號user_id)
inId3 <- args[3] #(資料表名稱，dataset_id)

connect = dbConnect(MySQL(), dbname = inId2,username = "root",
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES utf8") # 設定資料庫連線編碼
Sys.getlocale("LC_ALL") #解決中文編碼問題
print("21")
print(inId1)
print(inId2)
print(inId3)
toIdName<-(dbGetQuery(connect ,paste0("select * from `",inId2,"`.node n,`",inId2,"`.result_weight r where n.id = r.to_id and n.dataset = ",inId3," and r.total != 0")))
#print(toIdName)
select_result <- data.frame(c(dbGetQuery(connect ,paste0("select * from `",inId2,"`.node n,`",inId2,"`.result_weight r where n.id = r.from_id and n.dataset = ",inId3," and r.total != 0"))),to_id_name=c(toIdName[,5])) 
#print(select_result)
select_result_chosen <- select_result[select_result$result==inId1,] #拿到某結果為條件下的所有資料
#print(select_result_chosen)
#rank_weight <- dbGetQuery(connect, paste("select * from trans.result_weight where result_name = '",inId1,"' order by `total` desc")) 
rank_weight <- data.frame(c(select_result_chosen[order(-select_result_chosen$total),])) #將權重由高到低排序
#print(head(rank_weight))
print("25")
#count <- dbGetQuery(connect ,paste("select count(result_name) from trans.result_weight where result_name = '",inId1,"'")) 
count <- data.frame(c(dim(rank_weight)))
count <- count[1,1] #計算資料筆數
#print(count)
print("27")
count_rank <- round(count*0.01) #計算要顯示幾筆資料(目前設定前1%)
print("29")
list <- data.frame(rank=c(1:count_rank), c(rank_weight[1:count_rank,]))
rank_weight <- rank_weight[1:count_rank,]
i <- 2
while (i <= count_rank){  
  if (list$total[i]==list$total[i-1]){
    list$rank[i] <- list$rank[i-1]
  }
  i <- i + 1
}
print("31")
#print(list)
#draw_data <- data.frame(c(list[inId2,])) #找到想印的名次的資料(目前是印權重第一名)
draw_data <- data.frame(list)
#print(head(draw_data))
print("33")
#from_id_name <- dbGetQuery(connect ,paste("select * from trans.node n,trans.result_weight r where n.id = r.from_id"))
#table_from_id_name <- from_id_name[1:count_rank,2] #列出前1%的from_id_name
#to_id_name <- dbGetQuery(connect ,paste("select to_id,`name` from trans.node n,trans.result_weight r where result_name = '",inId1,"' and n.id = r.to_id order by `total` desc"))
#table_to_id_name <- to_id_name[1:count_rank,2] #列出前1%的to_id_name
print("38")
#print(inId2)
#print(draw_data)
#簡寫的#draw_from_id <- draw_data[inId2,6] #找到from_id
draw_from_id <- draw_data[,8] #找到from_id
#print(draw_from_id)
#簡寫的#draw_to_id <- draw_data[inId2,7] #找到to_id
draw_to_id <- draw_data[,9] #找到to_id
#簡寫的#weight <- draw_data[inId2,8] #找到weight
weight <- draw_data[,11] #找到weight
#draw_from_id_name <- dbGetQuery(connect ,paste("select from_id,`name` from trans.node n,trans.result_weight r where result_name = '",inId1,"' and n.id = r.from_id and n.id = ",inId2," group by from_id"))
#draw_to_id_name <- dbGetQuery(connect ,paste("select to_id,`name` from trans.node n,trans.result_weight r where result_name = '",inId1,"' and n.id = r.to_id and n.id = ",inId2," group by to_id"))
draw_id <- data.frame(id=c(draw_from_id,draw_to_id))
#print(draw_id)
draw_name <- data.frame(name=c(draw_data[,6],draw_data[,12]))
#print(draw_name)
draw_node <- data.frame(id=c(draw_id),name=c(draw_name))
draw_node <- draw_node[!duplicated(draw_node$id),]
#draw_node <- data.frame(id=c(draw_id[!duplicated(draw_id$id),]),name=c(draw_name[!duplicated(draw_name$name),]))
#print(draw_node)
print("65")
#print(draw_node)
#print(length(draw_node$id))
node <- data.frame(id=c(draw_node[,1]),label = c(draw_node[,2]),title = c(draw_node[,2]),group = c(draw_node[,2]),font.size = 20)
#print(weight)
print("68")
edge <- data.frame(from=c(draw_from_id), to=c(draw_to_id), value=c(weight), title=paste("Weight:",weight,"Rank:",list$rank),label=c(weight), font.size=10)
print(node)
#print(edge)
edge$width <- weight
print("47")
#print(inId1)
#print(inId2)
#print(node)
#print(edge)
result_table<- data.frame(rank=c(list$rank),from_id=c(rank_weight$from_id),from_id_name=c(rank_weight$name),to_id=c(rank_weight$to_id),to_id_name=c(rank_weight$to_id_name),total=c(rank_weight$total))
write.csv(result_table,paste0("..",.Platform$file.sep,"Flask",.Platform$file.sep,"result_table.csv"), row.names = FALSE, fileEncoding = "UTF-8")
print(result_table)
print(52)
result_pic <- visNetwork(node, edge, width = "100%", height = "500px")%>%
  visNodes(size = 10)%>%
  visOptions(highlightNearest = TRUE
              ,selectedBy= "group"
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
visSave(result_pic, file = paste0("..",.Platform$file.sep,"Flask",.Platform$file.sep,"templates",.Platform$file.sep,"result.html"),selfcontained = FALSE, background = "white")
print("61")
print("64")
print("success")