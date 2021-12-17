#ctrl shift + c 多行註解
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
library(sqldf)
connect = dbConnect(MySQL(), dbname = "trans",username = "root",
                    password = "IM39project",host = "localhost",DBMSencoding="UTF8")
dbListTables(connect)
Sys.setlocale("LC_ALL","Chinese") #解決中文編碼問題
t1<- dbSendQuery(connect,"SET NAMES gbk")
t1<- dbGetQuery(connect ,"select * from `node`")
a<- dbGetQuery(connect ,"select * from `attribute`")
attribute<- dbGetQuery(connect ,"select * from `attribute`")
r1<- dbGetQuery(connect ,"select * from `relationship`")
#t3代表node表 將節點與屬性left join得到attr_name 
t3<-t1
names(a)[1] <- "attribute"
names(a)[2] <- "attr_name"
getTitle<- merge(x = t3, y = a, by = "attribute", all.x = TRUE)#left join

#將node表與relationship表合併做left join 欲取得from_id的中文
test<-t1
names(test)[1] <- "from_id"
r_id<-data.frame(from_id=c(test$from_id),name=c(test$name))
#names(r_id)[1] <- "id"
#r2<-data.frame(id=c(r1$id),from_id=c(r1$from_id))
r2<-r1[1:3]
from_id<- merge(x = r2, y = r_id, by = "from_id", all.x = TRUE)

#欲取得to_id的中文
tt_id<-t1
names(tt_id)[1] <- "to_id"
to_id<- merge(x = r1, y = tt_id, by = "to_id", all.x = TRUE)
#names(t1)[3] <- "group"
s_name <- t1[1,1]
#t1$attribute
# nodes <- data.frame(id = c(t1$id), group = c(attribute$name), 
#                     #color = c(n$color), 
#                     label = c(t1$name), 
#                     title = paste("<p>", getTitle$attr_name,"<br>",getTitle$enname,"</p>"),
#                     font.size = 30)
nodes <- data.frame(id = c(getTitle$id), group = c(getTitle$attr_name), 
                    #color = c(n$color), 
                    label = c(getTitle$name), 
                    title = paste("<p>", getTitle$attr_name,"<br>",getTitle$enname,"</p>"),
                    font.size = 20)
t2<- dbGetQuery(connect ,"select * from `relationship`")
#from<-dbGetQuery(connect ,"select `from_id` from `relationship`")
#edges <- data.frame(from = c(from_id$name), to = c(to_id$name),value = c(round(rnorm(7162675,10))))
#edges<- t2[3:4]

edges <- data.frame(from = c(t2$from_id), to = c(t2$to_id),value = c(round(rnorm(7162675,10))))
# 觀察第一個與第二個 cols有沒有重複關聯值 true表示重複
edgesrows2 <- duplicated(edges[, c(1, 2)])  
# 將from to 重覆的關聯刪除
edgestable <- edges[!edgesrows2,]
edge<-edgestable[1:2]

ccout <- visNetwork(nodes, edge, width = "100%", height = "500px")%>%
  visInteraction(navigationButtons = TRUE) %>%
  visIgraphLayout() %>% #靜態
  visOptions(highlightNearest = TRUE, selectedBy= "label",
            ) %>%
visPhysics(solver = "forceAtlas2Based", 
           forceAtlas2Based = list(gravitationalConstant = -500))

visSave(ccout, file = "E:/GitHub/path.html",selfcontained = FALSE, background = "white")
 ###
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