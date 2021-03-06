#ctrl shift + c 多行註解
install.packages("visNetwork")
install.packages("dbConnect")
install.packages("RMySQL")
library(visNetwork)
library(sqldf)
library(RODBC)
library(dbConnect)
library(DBI)
library(gWidgets)
library(RMySQL)
library(xlsx)
library(sqldf)
library(igraph)
connect = dbConnect(MySQL(), dbname = "trans",username = "root",
                    password = "IM39project",host = "localhost",DBMSencoding="UTF8")
dbListTables(connect)
Sys.setlocale("LC_ALL","Chinese") #解決中文編碼問題
t1<- dbSendQuery(connect,"SET NAMES gbk")
t1<- dbGetQuery(connect ,"select * from `node`")
a<- dbGetQuery(connect ,"select * from `attribute`")
t2<- dbGetQuery(connect ,"select * from `relationship`")
t3<- dbGetQuery(connect ,"select * from `relationship` where `case_id`=1")
w<- dbGetQuery(connect ,"select * from `weight`")
#t3代表node表 將節點與屬性left join得到attr_name 
t3<-t1
names(a)[1] <- "attribute"
names(a)[2] <- "attr_name"
getTitle<- merge(x = t3, y = a, by = "attribute", all.x = TRUE)#left join
s_name <- t1[1,1]
nodes <- data.frame(id = c(getTitle$id), group = c(getTitle$attr_name), 
                    #color = c(n$color), 
                    label = paste(getTitle$name), 
                    title = paste("<p>", getTitle$attr_name,"<br>",getTitle$enname,"</p>"),
                    font.size = 20)
edges <- data.frame(from = c(t2$from_id), to = c(t2$to_id))
# 觀察第一個與第二個 cols有沒有重複關聯值 true表示重複
edgesrows2 <- duplicated(edges[, c(1, 2)])  
# 將from to 重覆的關聯刪除
edgestable <- edges[!edgesrows2,]
edge<-edgestable[1:2]
ccout <- visNetwork(nodes, edge, width = "100%", height = "500px")%>%
  visNodes(size = 30)%>%
  visOptions(highlightNearest = TRUE, selectedBy= "label")%>%
  visPhysics(stabilization = FALSE,#動態效果
             solver = "repulsion",
             repulsion = list(gravitationalConstant = 1500))

visSave(ccout, file = "E:/GitHub/trans/path.html",selfcontained = FALSE, background = "white")
# 計算第一欄與第二欄位次數
# edgescount<-edges[,c(1,2)]
# edgescount<-[,(.N),by=edges[,c(1, 2)]]
# a<-NBA1516DT[,.(.N,AssistsMean=mean(Assists)),
#           by=Team]
# ccout <- visNetwork(nodes, edges, width = "100%", height = "500px")%>%
#   visInteraction(navigationButtons = TRUE)
# visIgraphLayout(
#   layout = "layout_nicely",
#   physics = FALSE,
#   smooth = FALSE,
#   type = "square",
#   randomSeed = NULL,
#   layoutMatrix = NULL,
# ) %>% #靜態
#   visOptions(highlightNearest = TRUE, selectedBy= "label",
#              nodesIdSelection = list(enabled = TRUE,  selected = s_name))
# visPhysics(solver = "forceAtlas2Based",
#            forceAtlas2Based = list(gravitationalConstant= -500))
# 
# 
# visSave(ccout, file = "E:/GitHub/path.html",selfcontained = FALSE, background = "white")
# ccout <- visNetwork(nodes, edge, width = "100%", height = "500px")%>%
#   # visInteraction(navigationButtons = TRUE) %>%
#   visIgraphLayout(
#                   layout = "layout_with_sugiyama",
#                   physics = TRUE,
#                   smooth = TRUE,
#                   type = "full",
#                   randomSeed = 123,
#                   layoutMatrix = NULL,) %>% #靜態
#   
#   visOptions(highlightNearest = TRUE, selectedBy= "label",
#                nodesIdSelection = list(enabled = TRUE,  selected = s_name)) %>%
# visPhysics(solver = "forceAtlas2Based", 
#            forceAtlas2Based = list(gravitationalConstant = -500))
# 
# visSave(ccout, file = "E:/GitHub/path.html",selfcontained = FALSE, background = "white")
#  ###
#edges<- t2[3:4]

###

install.packages("igraph")
library(igraph)
#my_matrix<-as.matrix(t1[,2:3])
my_matrix<-t1[,2:3]
#convert list to numeric
name <- as.numeric(unlist(my_matrix[,1]))
group <- as.numeric(unlist(my_matrix[,2]))
my_second_network<-graph.adjacency(my_matrix,mode="undirected",
                                   diag=FALSE)
my_second_network
betweenness(my_second_network,directed=FALSE)
degree(my_second_network,mode="all")
plot(my_second_network)

library(dplyr)

df1 <- data.frame(id = c(1, 2, 2, 3, 3, 4, 5, 5),
                  gender = c("F", "F", "M", "F", "B", "B", "F", "M"),
                  variant = c("a", "b", "c", "d", "e", "f", "g", "h"))

a1 <- df1 %>% group_by(id) %>% filter (! duplicated(id))
a2 <- df1 %>% group_by(gender) %>% filter (! duplicated(gender))
a3 <- df1 %>% group_by(variant) %>% filter (! duplicated(variant))

df2 <- mtcars

tmp3 <- df2 %>% group_by(cyl) %>% filter (! duplicated(cyl))
tmp4 <- df2 %>% group_by(mpg) %>% filter (! duplicated(mpg))