install.packages("visNetwork")
install.packages("dbConnect")
install.packages("RMySQL")
library("visNetwork")
library("sqldf")
library(RODBC)
library(dbConnect)
library(DBI)
library(gWidgets)
library(RMySQL)
library(xlsx)
connect = dbConnect(MySQL(), dbname = "trans",username = "root",
                    password = "IM39project",host = "localhost",DBMSencoding="UTF8")
dbListTables(connect)
t1<- dbSendQuery(connect,"SET NAMES gbk")
t1<- dbGetQuery(connect ,"select * from `node`")
Encoding(t1)<-"utf8"
names(t1)[3] <- "group"
t2<- dbGetQuery(connect ,"select * from `relationship`")
t2 = t2[3:4]
edges<-t2
visNetwork(nodes,edges,  
           main = "台中交通事故sna", 
           submain = list(text = "個別肇事因素與區域關聯圖",
                          style = "font-family:Comic Sans MS;color:#ff0000;font-size:15px;text-align:center;"), 
           footer = "Fig.1 依區域分為不同的case",
           height = "700px", width = "100%") %>%
  visOptions(selectedBy = "group", 
             manipulation = TRUE, #edit network
             highlightNearest = TRUE, 
             nodesIdSelection = TRUE) %>%
  visGroups(groupname = "A", color = "red") %>%
  visGroups(groupname = "B", color = "lightblue") %>%
  visLegend()%>%
  visPhysics(stabilization = FALSE,#動態效果
             solver = "repulsion", 
             repulsion = list(gravitationalConstant = -500))
###
# Sys.setlocale("LC_ALL","Chinese") 解決中文編碼問題
install.packages("igraph")
library(igraph)
#my_matrix<-as.matrix(t1[,2:3])
my_matrix<-t1[,2:3]
my_second_network<-graph.adjacency(my_matrix,mode="undirected",
                                   diag=FALSE)
my_second_network
betweenness(my_second_network,directed=FALSE)
degree(my_second_network,mode="all")
plot(my_second_network)