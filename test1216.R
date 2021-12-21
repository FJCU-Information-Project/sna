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

test<-t1
names(test)[1] <- "from_id"
r_id<-data.frame(from_id=c(test$from_id),name=c(test$name))
#names(r_id)[1] <- "id"
#r2<-data.frame(id=c(r1$id),from_id=c(r1$from_id))
r2<-r1[1:3]
from_id<- merge(x = r2, y = r_id, by = "from_id", all.x = TRUE)

tt_id<-t1
names(tt_id)[1] <- "to_id"
to_id<- merge(x = r1, y = tt_id, by = "to_id", all.x = TRUE)
#names(t1)[3] <- "group"
s_name <- t1[1,1]
#nodes <- data.frame(id = c(t1$id), group = c(t1$attribute), 
#                   #color = c(n$color), 
#                    label = c(t1$name), 
#                    title = paste("<p>", getTitle$attr_name,"<br>",getTitle$enname,"</p>"),
#                    font.size = 30)
nodes <- data.frame(id=c(getTitle$id), group=c(getTitle$attr_name))
                     label = c(getTitle$name)
                     title = paste("<p>", getTitle$attr_name,"<br>",getTitle$enname,"</p>")
                     font.size = 20

t2<- dbGetQuery(connect ,"select * from `relationship`")
#from<-dbGetQuery(connect ,"select `from_id` from `relationship`")
#edges <- data.frame(from = c(from_id$name), to = c(to_id$name),value = c(round(rnorm(7162675,10))))
edges <- data.frame(from = c(t2$from_id), to = c(t2$to_id),value = c(round(rnorm(5392226,10))))

#edges<- t2[3:4]
#edges <- data.frame(from = c(edges$from_id), to = c(edges$to_id),value = c(round(rnorm(7162675,10))))
max<- dbGetQuery(connect ,"SELECT max(`total`) FROM `weight`")
min<- dbGetQuery(connect ,"SELECT min(`total`) FROM `weight`")
space <- ((max-min)/10)
edges$width<- round(((w[,3]-min)+space)/space)

ccout <- visNetwork(nodes, edges, width = "100%", height = "500px")%>%
  visInteraction(navigationButtons = TRUE)
  visIgraphLayout(
    layout = "layout_nicely",
    physics = FALSE,
    smooth = FALSE,
    type = "square",
    randomSeed = NULL,
    layoutMatrix = NULL,
  ) %>% #靜態
  visOptions(highlightNearest = TRUE, selectedBy= "label",
             nodesIdSelection = list(enabled = TRUE,  selected = s_name))
  visPhysics(solver = "forceAtlas2Based",
             forceAtlas2Based = list(gravitationalConstant= -500))
  

  visSave(ccout, file = "E:/GitHub/path.html",selfcontained = FALSE, background = "white")