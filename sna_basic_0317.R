library(visNetwork)
#library(sqldf)
#library(RODBC)
#library(dbConnect)
#library(DBI)
#library(gWidgets)
library(RMySQL)
#library(xlsx)
#library(sqldf)
#install.packages("sna")
print("11")
library(sna)
print("12")
args <- commandArgs(trailingOnly = TRUE)
inId <- args[1] # CLI input parameter
#inId <- 17
print("16")
connect = dbConnect(MySQL(), dbname = "trans",username = "root",
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES BIG5") # 設定資料庫連線編碼
Sys.getlocale("LC_ALL") #解決中文編碼問題
print("22")
#建立權重表矩陣
the_max_node <- as.numeric(dbGetQuery(connect,"select max(`id`) from trans.node"))#取出節點最大值
data <- dbGetQuery(connect,"select * from trans.default_relationship")
#node_name <- dbGetQuery(connect,"select * from trans.node")
data_count <- dbGetQuery(connect,"select count(total) from trans.default_relationship")#取出有可能的關聯組數
data_matrix <- matrix(c("Null"),nrow = the_max_node,ncol = the_max_node)#建立一張全部為Null的矩陣表
i <- 1
while (i<=data_count) {
  from_id <- data[i,1]
  to_id <- data[i,2]
  total <- data[i,3]
  #有關聯的將其權重加入矩陣
  if (total != 0){
    data_matrix[from_id,to_id] <- total
    data_matrix[to_id,from_id] <- total
  }
  #沒有關聯的一樣顯示null
  else{
    data_matrix[from_id,to_id] <- "Null"
    data_matrix[to_id,from_id] <- "Null"
  }
  i <- i + 1
}
print("46")
basic_table <- data.frame(node_id=c(1:the_max_node),node_name=c(1:the_max_node),degree_centrality=c(degree(data_matrix,gmode = "graph",rescale = "TRUE")),closeness_centrality=c(closeness(data_matrix,gmode = "TRUE",cmode="suminvundir")))
#在表格上加上節點名稱
j <- 1
while(j<=the_max_node){
  node_name <- data.frame(c(dbGetQuery(connect,paste("select `name` from trans.node where id = ",j))))
  basic_table[j,2] <- node_name[1,1]
  j <- j + 1
}
print("55")
basic_table <- subset(basic_table,degree_centrality != "NA" & degree_centrality != 0 & closeness_centrality != "NA" & closeness_centrality != 0) #剔除NA和0的值

#write.csv(basic_table,"C:/Users/User/Desktop/basic_table.csv", row.names = FALSE, fileEncoding = "UTF-8")
#write.csv(data_matrix,"C:/Users/User/Desktop/data_table.csv", row.names = FALSE, fileEncoding = "UTF-8")

#畫圖
inId_is_from_id <- dbGetQuery(connect,paste("select * from trans.default_relationship d,trans.node n where d.`from_id` = ",inId," and d.to_id = n.id"))
inId_is_to_id <- dbGetQuery(connect,paste("select * from trans.default_relationship d,trans.node n where d.`to_id` = ",inId," and d.from_id = n.id"))
inId_name <- dbGetQuery(connect,paste("select `name` from trans.node where id =",inId))
node <- data.frame(id=c(inId,inId_is_to_id[,1],inId_is_from_id[,2]),name=c(inId_name[1,1],inId_is_to_id[,5],inId_is_from_id[,5]),label=c(inId_name[1,1],inId_is_to_id[,5],inId_is_from_id[,5]),title=c(inId_name[1,1],inId_is_to_id[,5],inId_is_from_id[,5]),font.size = 20)
edge_list <- data.frame(from_id=c(inId),to_id=c(inId_is_to_id[,1],inId_is_from_id[,2]),weight=c(inId_is_to_id[,3],inId_is_from_id[,3]))
edge <- data.frame(from=c(edge_list$from_id),to=c(inId_is_to_id[,1],inId_is_from_id[,2]),title=paste("Weight:",edge_list$weight), value=c(inId_is_to_id[,3],inId_is_from_id[,3]),width=c(inId_is_to_id[,3],inId_is_from_id[,3]))
print("68")
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
print("81")
visSave(basic_pic, file = "../flask/templates/basic.html",selfcontained = FALSE, background = "white")
print("before csv")
write.csv(basic_table,"../flask/basic_table.csv", row.names = FALSE, fileEncoding = "UTF-8")
print("create csv")
print("success")