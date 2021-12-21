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
abc<- dbGetQuery(connect ,"SELECT from_id as `from`,to_id as `to` FROM `weight` WHERE `total`>=20000")
ccout <- visNetwork(nodes, abc, width = "100%", height = "500px")%>%
  visIgraphLayout() %>% #靜態
  visNodes(size = 30)%>%
  visOptions(highlightNearest = TRUE, selectedBy= "label")%>%
  visPhysics(stabilization = FALSE,#動態效果
             solver = "repulsion",
             repulsion = list(gravitationalConstant = 1500))

visSave(ccout, file = "E:/GitHub/trans/public/path.html",selfcontained = FALSE, background = "white")