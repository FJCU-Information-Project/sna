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
#inId <- 1

connect = dbConnect(MySQL(), dbname = "trans",username = "root",
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES BIG5") # 設定資料庫連線編碼
Sys.getlocale("LC_ALL") #解決中文編碼問題

weight_total <- dbGetQuery(connect ,paste("SELECT sum(total) FROM weight WHERE `from_id` = ",inId, "or `to_id` = ",inId)) #找出符合inId的權重數合計
inId_data <- dbGetQuery(connect, paste("select * from trans.node where id = ",inId))
node_id <- dbGetQuery(connect ,paste("select `from_id`,`to_id`,`name`,total from trans.node n,trans.weight w where (`from_id` = ",inId,"and n.`id` = w.`to_id`) or (`to_id`=",inId,"and n.`id`= w.`from_id`)")) #找出所有符合條件的資料
inId_is_from_id <- dbGetQuery(connect ,paste("select `from_id`,`to_id`,`name`,total from trans.node n,trans.weight w where (`from_id` = ",inId,"and n.`id` = w.`to_id`)")) #找出from_id等於起始點的資料
inId_is_to_id <- dbGetQuery(connect ,paste("select `from_id`,`to_id`,`name`,total from trans.node n,trans.weight w where (`to_id`=",inId,"and n.`id`= w.`from_id`)")) #找出to_id等於起始點的資料
#all_node <- dbGetQuery(connect,paste("select `id` from trans.node"))
count_node <- as.numeric(dbGetQuery(connect,paste("select max(`id`) from trans.node")))
count_edge <- dbGetQuery(connect ,paste("select count(`name`) from trans.node n,trans.weight w where (`from_id` = ",inId,"and n.`id` = w.`to_id`) or (`to_id`=",inId,"and n.`id`= w.`from_id`)")) #計算符合inId的edge數量
count_total_edge <- dbGetQuery(connect ,paste("SELECT count(`total`) FROM trans.default_relationship where total != 0")) #找出該資料集中的總edge數量
print(31)
#計算degree_centrality
i <- 1
degree_centrality_table <- data.frame(id=c(1:count_node),name=c(1:count_node),degree=c(1:count_node))
while (i <= count_node) {
  count_every_edge <- dbGetQuery(connect ,paste("select count(`name`) from trans.node n,trans.weight w where (`from_id` = ",i,"and n.`id` = w.`to_id`) or (`to_id`=",i,"and n.`id`= w.`from_id`)")) #計算符合i的edge數量
  take_node_d_name <- dbGetQuery(connect,paste("select `name` from trans.node where id = ",i))
  every_degree_centrality <- round(count_every_edge/((count_total_edge-1)*(count_total_edge-2)),7)
  degree_centrality_table[i,2] <- data.frame(name=c(take_node_d_name[1,1]))
  degree_centrality_table[i,3] <- data.frame(degree=c(every_degree_centrality))
  i <- i + 1
}
print(43)
#degree_centrality_table <- subset(degree_centrality_table,degree != 0)

#計算closeness_centrality
j <- 1
closeness_centrality_table <- data.frame(id=c(1:count_node),name=c(1:count_node),closeness=(1:count_node))
while (j <= count_node) {
  node_weight <- dbGetQuery(connect ,paste("select sum(`total`) from trans.node n,trans.weight w where (`from_id` = ",j,"and n.`id` = w.`to_id`) or (`to_id`=",j,"and n.`id`= w.`from_id`)")) 
  take_node_c_name <- dbGetQuery(connect,paste("select `name` from trans.node where id = ",j))
  every_closeness_centrality <- round(1/node_weight,5)
  closeness_centrality_table[j,2] <- data.frame(name=c(take_node_c_name[1,1]))
  closeness_centrality_table[j,3] <- data.frame(closeness=c(every_closeness_centrality))
  j <- j + 1
}
#closeness_centrality_table <- subset(closeness_centrality_table,closeness != "NA" & closeness != 0)
print(58)
basic_table <- data.frame(name=c(degree_centrality_table$name),degree_centrality=c(degree_centrality_table$degree),closeness_centrality=c(closeness_centrality_table$closeness))
basic_table <- subset(basic_table,degree_centrality != "NA" & degree_centrality != 0 & closeness_centrality != "NA" & closeness_centrality != 0) #剔除NA和0的值
print(61)
node <- data.frame(id=c(inId,inId_is_from_id$to_id,inId_is_to_id$from_id),label = c(inId_data$name,inId_is_from_id$name,inId_is_to_id$name),title = c(inId_data$name,inId_is_from_id$name,inId_is_to_id$name),font.size = 20)
edge <- data.frame(from=c(inId), to=c(inId_is_from_id$to_id,inId_is_to_id$from_id),title=paste("Weight:",inId_is_from_id$total,inId_is_to_id$total), value=c(inId_is_from_id$total,inId_is_to_id$total),width=c(inId_is_from_id$total,inId_is_to_id$total))
#edge$width <- c(inId_is_from_id$total,inId_is_to_id$total)
print(65)
basic_pic <- visNetwork(node, edge, width = "100%", height = "500px")%>%
  visNodes(size = 30)%>%
  visOptions(highlightNearest = TRUE, selectedBy= "label",nodesIdSelection = list(
              enabled = TRUE,
              style = 'width: 200px; height: 26px;
                    background: #f8f8f8;
                    color: darkblue;
                    border:none;
                    outline:none;'))%>%
  visPhysics(stabilization = FALSE,#動態效果
              solver = "repulsion",
              repulsion = list(gravitationalConstant = 1500))

visSave(basic_pic, file = "../flask/templates/basic.html",selfcontained = FALSE, background = "white")
print("before csv")
write.csv(basic_table,"../flask/basic_table.csv", row.names = FALSE, fileEncoding = "UTF-8")
print("create csv")