#ctrl shift + c 多行註解
#install.packages("visNetwork")
#install.packages("dbConnect")
#install.packages("RMySQL")
library(visNetwork)
#library(sqldf)
#library(RODBC)
#library(dbConnect)
#library(DBI)
#library(gWidgets)
library(RMySQL)
#library(xlsx)
#library(sqldf)
library(igraph)

args <- commandArgs(trailingOnly = TRUE)

inId1 <- args[1] #(資料庫名稱，使用者代號user_id)
inId2 <- args[2] #(資料表名稱，dataset_id)

connect = dbConnect(MySQL(), dbname = inId1,username = "root",
                    password = "IM39project",host = "localhost",port=50306,DBMSencoding="UTF8")
dbListTables(connect)

dbSendQuery(connect,"SET NAMES BIG5") # 設定資料庫連線編碼
Sys.getlocale("LC_ALL") #解決中文編碼問題

t1<- dbGetQuery(connect , paste0("select * from `",inId1,"`.node where dataset = ",inId2))
a<- dbGetQuery(connect , paste0("select * from `",inId1,"`.attribute where dataset = ",inId2))
t2<- dbGetQuery(connect , paste0("select * from `",inId1,"`.relationship where dataset = ",inId2))
t3<- dbGetQuery(connect , paste0("select * from `",inId1,"`.relationship where `case_id` = 1"))
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

visSave(ccout, file = "../flask/templates/overall.html",selfcontained = FALSE, background = "white")
print("Overall sucess")