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
library(sna)
print("12")
args <- commandArgs(trailingOnly = TRUE)
inId1 <- args[3] # CLI input parameter(起使節點id)
inId2 <- args[1] #(資料庫名稱，使用者代號user_id)
inId3 <- args[2] #(資料表名稱，dataset_id)
#inId <- 17
print(inId1)
connect = dbConnect(MySQL(), dbname = inId2 ,username = "root",
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES utf8") # 設定資料庫連線編碼
Sys.getlocale("LC_ALL") #解決中文編碼問題
print("22")
#建立權重表矩陣
the_max_node <- as.numeric(dbGetQuery(connect,paste0("select max(`id`) from `",inId2,"`.node where dataset = ",inId3)))#取出節點最大值
#print(the_max_node)
print("27")
data <- dbGetQuery(connect,paste0("select * from `",inId2,"`.weight where dataset =",inId3))
print("29")
#node_name <- dbGetQuery(connect,"select * from trans.node")
data_count <- dbGetQuery(connect,paste0("select count(`dataset`) from `",inId2,"`.weight where dataset =",inId3))#取出有可能的關聯組數
print("32")
data_matrix <- matrix(c("Null"),nrow = the_max_node,ncol = the_max_node)#建立一張全部為Null的矩陣表
i <- 1
while (i<=data_count) {
  from_id <- data[i,2]
  to_id <- data[i,3]
  total <- data[i,4]
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
#print(data_matrix)
basic_table <- data.frame(node_id=c(1:the_max_node),
                          node_name=c(1:the_max_node),
                          degree_centrality=c(degree(data_matrix,gmode = "graph",rescale = "TRUE")),
                          closeness_centrality=c(closeness(data_matrix,gmode = "TRUE",cmode="suminvundir")))
#在表格上加上節點名稱
print("58")

j <- 1
while(j<=the_max_node){
  node_name <- data.frame(c(dbGetQuery(connect,paste0("select * from `",inId2,"`.node where id = ",j))))
  node_name <- node_name[node_name$dataset==inId3,]
  basic_table[j,2] <- node_name[1,5]
  j <- j + 1
}
print("55")
basic_table <- subset(basic_table,degree_centrality != "NA" & degree_centrality != 0 & closeness_centrality != "NA" & closeness_centrality != 0) #剔除NA和0的值
print("57")
#print(basic_table)
#write.csv(basic_table,"C:/Users/User/Desktop/basic_table.csv", row.names = FALSE, fileEncoding = "UTF-8")
#write.csv(data_matrix,"C:/Users/User/Desktop/data_table.csv", row.names = FALSE, fileEncoding = "UTF-8")

if(!is.na(inId1)){
  #有參數再畫圖
  inId_is_from_id <- dbGetQuery(connect,paste0("select * from `",inId2,"`.weight w,`",inId2,"`.node n where w.`from_id` = ",inId1," and w.to_id = n.id and w.dataset =",inId3))
  print("77")
  #print(inId_is_from_id)
  inId_is_to_id <- dbGetQuery(connect,paste0("select * from `",inId2,"`.weight w,`",inId2,"`.node n where w.`to_id` = ",inId1," and w.from_id = n.id and w.dataset =",inId3))
  print("79")
  #print(inId_is_to_id)
  inId_name <- dbGetQuery(connect,paste0("select `name` from `",inId2,"`.node where id = ",inId1," and dataset =",inId3))
  print("65")
  #print(inId_name)
  node <- data.frame(id=c(inId1,inId_is_to_id[,2],inId_is_from_id[,3]),name=c(inId_name[1,1],inId_is_to_id[,9],inId_is_from_id[,9]),label=c(inId_name[1,1],inId_is_to_id[,9],inId_is_from_id[,9]),title=c(inId_name[1,1],inId_is_to_id[,9],inId_is_from_id[,9]),font.size = 20)
  node <- subset(node[!duplicated(node$id),])
  print("67")
  edge_list <- data.frame(from_id=c(inId1),to_id=c(inId_is_to_id[,2],inId_is_from_id[,3]),weight=c(inId_is_to_id[,4],inId_is_from_id[,4]))
  print("69")
  #print(node)
  edge <- data.frame(from=c(edge_list$from_id),to=c(inId_is_to_id[,2],inId_is_from_id[,3]),title=paste("Weight:",edge_list$weight), value=c(inId_is_to_id[,4],inId_is_from_id[,4]),width=c(inId_is_to_id[,4],inId_is_from_id[,4]))
  edge <- subset(edge,value != 0) #權重為0的不要建立起關聯
  print("71")
  #print(edge)
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
}
print("before csv")
write.csv(basic_table,"../flask/basic_table.csv", row.names = FALSE, fileEncoding = "UTF-8")
print("create csv")
print("success")