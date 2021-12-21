install.packages("visNetwork")
install.packages("dbConnect")
install.packages("RMySQL")
install.packages("gWidgets")
install.packages("xlsx")

library(visNetwork)
library(sqldf)
library(RODBC)
library(dbConnect)
library(DBI)
library(gWidgets)
library(RMySQL)
library(xlsx)
library(sqldf)

connect = dbConnect(MySQL(), dbname = "trans",username = "root",
                    password = "IM39project",host = "localhost",DBMSencoding="UTF8")
dbListTables(connect)
Sys.setlocale("LC_ALL","Chinese") #解決中文編碼問題

t1<- dbSendQuery(connect,"SET NAMES gbk")
t1<- dbGetQuery(connect ,"select * from `node`") #導入資料庫中的node
a<- dbGetQuery(connect ,"select * from `attribute`") #導入資料庫中的attribute
r1<- dbGetQuery(connect ,"select * from `relationship`")
w<- dbGetQuery(connect ,"select * from `weight`")

t3<-t1
names(a)[1] <- "attribute"
names(a)[2] <- "attr_name"
getTitle<- merge(x = t3, y = a, by = "attribute", all.x = TRUE)#left join
s_name <- t1[1,1]
nodes <- data.frame(id=c(getTitle$id), group=c(getTitle$attr_name))
                     label = c(getTitle$name)
                     title = paste("<p>", getTitle$attr_name,"<br>",getTitle$enname,"</p>")
                     font.size = 20

t2<- dbGetQuery(connect ,"select * from `relationship`")
#from<-dbGetQuery(connect ,"select `from_id` from `relationship`")
#edges <- data.frame(from = c(from_id$name), to = c(to_id$name),value = c(round(rnorm(7162675,10))))
edges <- data.frame(from = c(t2$from_id), to = c(t2$to_id),value = c(round(rnorm(5392226,10))))
# 觀察第一個與第二個 cols有沒有重複關聯值 true表示重複
edgesrows2 <- duplicated(edges[, c(1, 2)])  
# 將from to 重覆的關聯刪除
edgestable <- edges[!edgesrows2,]
edges<-edgestable[1:2]
#edges<- t2[3:4]
#edges <- data.frame(from = c(edges$from_id), to = c(edges$to_id),value = c(round(rnorm(7162675,10))))
max<- dbGetQuery(connect ,"SELECT max(`total`) FROM `weight`")
min<- dbGetQuery(connect ,"SELECT min(`total`) FROM `weight`")
space <- ((max-min)/10)
edges$width<- round(((w[,3]-min)+space)/space)

ccout <- visNetwork(nodes, edges, width = "100%", height = "500px")%>%
  visInteraction(navigationButtons = TRUE)%>%
  visLayout(
    layout = "layout_nicely",
    physics = TRUE,
    smooth = FALSE,
    type = "square",
    randomSeed = NULL,
    layoutMatrix = NULL,
  ) %>% #靜態
#  visHierarchicalLayout()%>%
  visOptions(highlightNearest = TRUE, selectedBy= "label",
             nodesIdSelection = list(enabled = TRUE,  selected = s_name))%>%
#  visPhysics(solver = "forceAtlas2Based",
#            forceAtlas2Based = list(gravitationalConstant= -500))
  visPhysics(solver = "barnesHut")

  visSave(ccout, file = "E:/GitHub/path.html",selfcontained = FALSE, background = "white")