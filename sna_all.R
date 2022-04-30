library(visNetwork)
#library(sqldf)
#library(RODBC)
#library(dbConnect)
#library(DBI)
#library(gWidgets)
library(RMySQL)
#library(xlsx)
#library(sqldf)

args <- commandArgs(trailingOnly = TRUE)

inId1 <- args[1] #(資料庫名稱，使用者代號user_id)
inId2 <- args[2] #(資料表名稱，dataset_id)
inId1 <- as.character(inId1)
inId2 <- as.character(inId2)
print(inId1)
print(inId2)
print(class(inId1))
print(class(inId2))
#inId3 <- args[3] #選取想看的權重程度(前10%、前20%、前30%.....全部(100%))，以小數位回傳(0.1、0.2、0.3、....、1)
#inId3 <- as.numeric(inId3)
connect = dbConnect(MySQL(), dbname = inId1,username = "root",
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES utf8") # 設定資料庫連線編碼
Sys.getlocale("LC_ALL") #解決中文編碼問題
print("21")

max_weight <- as.numeric(dbGetQuery(connect, paste0("select max(`total`) from `",inId1,"`.weight where dataset = ",inId2)))
#max_weight <- max_weight*(1-inId3)
max_weight <- max_weight*(1-0.2) #目前直接設定顯示關聯程度前20%
node_all <- dbGetQuery(connect, paste0("select * from `",inId1,"`.node where dataset = ",inId2))
print(34)
node_id <- dbGetQuery(connect, paste0("select * from `",inId1,"`.weight where (total > ",max_weight,") and dataset = ",inId2))
print(90)
node_id <- data.frame(from_id=c(node_id[,2]), to_id=c(node_id[,3]), weight=c(node_id[,4]))

node_id <- node_id[order(-node_id$weight),]

from_id_name <- dbGetQuery(connect, paste0("select `name` from `",inId1,"`.weight w, `",inId1,"`.node n where w.from_id = n.id and w.dataset = ",inId2))
to_id_name <- dbGetQuery(connect, paste0("select `name` from `",inId1,"`.weight w, `",inId1,"`.node n where w.to_id = n.id and w.dataset = ",inId2))
node <- data.frame(id=c(node_all[,3]), name=c(node_all[,5]), title=c(node_all[,5]), label=c(node_all[,5]), group=c(node_all[,5]), font.size=20)
#print(node)
edge <- data.frame(from=c(node_id$from_id),to=c(node_id$to_id),value=c(node_id$weight),width=c(node_id$weight),title=paste("Weight:",node_id$weight))
#print(edge)

all_pic <- visNetwork(node, edge, width = "100%", height = "500px")%>%
  visNodes(size = 10)%>%
  visOptions(highlightNearest = TRUE
              ,selectedBy= "group"
              ,nodesIdSelection = list(enabled = TRUE
                                        ,style = 'width: 200px; height: 26px;
                                 background: #f8f8f8;
                                 color: darkblue;
                                 border:none;
                                 outline:none;'))%>%
  visPhysics(stabilization = FALSE,#動態效果
             solver = "repulsion",
             repulsion = list(gravitationalConstant = 1500))
print("59")
visSave(all_pic, file = paste0("..",.Platform$file.sep,"Flask",.Platform$file.sep,"templates",.Platform$file.sep,"all.html"),selfcontained = FALSE, background = "white")
print("61")
print("64")
print("success")