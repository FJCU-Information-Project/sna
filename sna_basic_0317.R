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

args <- commandArgs(trailingOnly = TRUE)
#inId <- args[1] # CLI input parameter
inId <- 17

connect = dbConnect(MySQL(), dbname = "trans",username = "root",
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES BIG5") # 設定資料庫連線編碼
Sys.getlocale("LC_ALL") #解決中文編碼問題

#建立權重表矩陣
the_max_node <- as.numeric(dbGetQuery(connect,"select max(`id`) from trans.node"))#取出節點最大值
data <- dbGetQuery(connect,"select * from trans.default_relationship")
data_count <- dbGetQuery(connect,"select count(total) from trans.default_relationship")#取出有可能的關聯組數
data_matrix <- matrix(c(0),nrow = the_max_node,ncol = the_max_node)#建立一張全部為0的矩陣表
i <- 1
while (i<=data_count) {
  from_id <- data[i,1]
  to_id <- data[i,2]
  total <- data[i,3]
  data_matrix[from_id,to_id] <- total
  data_matrix[to_id,from_id] <- total
  i <- i + 1
}

basic_table <- data.frame(node_id=c(1:the_max_node),degree_centrality=c(degree(data_matrix,gmode = "graph",rescale = "TRUE")))
basic_table <- subset(basic_table,degree_centrality != "NA" & degree_centrality != 0 ) #剔除NA和0的值

write.csv(basic_table,"../flask/basic_table.csv", row.names = FALSE, fileEncoding = "UTF-8")
write.csv(data_matrix,"../flask/data.csv", row.names = FALSE, fileEncoding = "UTF-8")
