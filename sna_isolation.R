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
inId1 <- args[1] # CLI input parameter
inId2 <- args[2] #(資料庫名稱，使用者代號user_id)
inId3 <- args[3] #(資料表名稱，dataset_id)

print("15")
connect = dbConnect(MySQL(), dbname = inId2,username = "root",
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES utf8") # 設定資料庫連線編碼
#Sys.getlocale("LC_ALL") #解決中文編碼問題
print("21")
print(inId1)
select_isolation <- data.frame(c(dbGetQuery(connect ,paste0("SELECT * FROM `",inId2,"`.weight where (from_id = ",inId1," or to_id = ",inId1,") and total = 0 and dataset = ",inId3))))
print("26")
select_node <- data.frame(c(dbGetQuery(connect ,paste0("SELECT * FROM `",inId2,"`.weight where dataset = ",inId3," and (from_id = ",inId1," or to_id = ",inId1,")"))))
print("28")
select_draw_edge <- data.frame(c(dbGetQuery(connect ,paste0("SELECT * FROM `",inId2,"`.weight where (from_id = ",inId1," or to_id = ",inId1,") and total != 0 and dataset = ",inId3))))
#print(select_isolation)
#print(select_node)
print("32")
from_id_name <- data.frame(c(dbGetQuery(connect ,paste0("select `from_id`,`name` from `",inId2,"`.node n, `",inId2,"`.weight w where (from_id = ",inId1," or to_id = ",inId1,") and n.id = w.from_id and w.dataset = ",inId3))))
#print(from_id_name)
print("33")
to_id_name <- data.frame(c(dbGetQuery(connect ,paste0("select to_id,`name` from `",inId2,"`.node n,`",inId2,"`.weight w where (from_id = ",inId1," or to_id = ",inId1,") and n.id = w.to_id and w.dataset = ",inId3))))
table_from_id_name <- data.frame(c(dbGetQuery(connect ,paste0("select from_id,`name` from `",inId2,"`.node n,`",inId2,"`.weight w where (from_id = ",inId1," or to_id = ",inId1,") and total = 0 and n.id = w.from_id and w.dataset = ",inId3))))
table_to_id_name <- data.frame(c(dbGetQuery(connect ,paste0("select to_id,`name` from `",inId2,"`.node n,`",inId2,"`.weight w where (from_id = ",inId1," or to_id = ",inId1,") and total = 0 and n.id = w.to_id and w.dataset = ",inId3))))
print(to_id_name)
print("25")
#print(select_node)
#print(from_id_name)
count_id_is_to_id <- as.numeric(dbGetQuery(connect, paste0("SELECT count(`from_id`) FROM `",inId2,"`.weight where dataset = ",inId3," and to_id = ",inId1)))
#print(count_id_is_to_id)
count_id <- as.numeric(dbGetQuery(connect, paste0("SELECT count(`from_id`) FROM `",inId2,"`.weight where dataset = ",inId3," and (from_id = ",inId1," or to_id = ",inId1,")")))
print(count_id)
node <- data.frame(id=c(inId1,select_node$from_id[select_node$to_id==inId1],select_node$to_id[select_node$from_id==inId1]),name = c(to_id_name[1,2],from_id_name$name[from_id_name$from_id!=inId1],to_id_name$name[to_id_name$to_id!=inId1]),label = c(to_id_name[1,2],from_id_name$name[from_id_name$from_id!=inId1],to_id_name$name[to_id_name$to_id!=inId1]),title = c(to_id_name[1,2],from_id_name$name[from_id_name$from_id!=inId1],to_id_name$name[to_id_name$to_id!=inId1]),font.size = 20)
print("47")
#print(node)
edge_from_id <- data.frame(from_id=c(inId1))
edge <- data.frame(from=(edge_from_id$from_id), to=c(select_draw_edge$from_id[select_draw_edge$to_id==inId1],select_draw_edge$to_id[select_draw_edge$from_id==inId1]), title=paste("Weight:",select_draw_edge[,4]), value=c(select_draw_edge[,4]), width=c(select_draw_edge[,4]))
#edge$width <- select_draw_edge[,4]
print("29")
print(edge)
isolation_pic <- visNetwork(node, edge, width = "100%", height = "500px")%>%
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

visSave(isolation_pic, file = "../flask/templates/isolation.html",selfcontained = FALSE, background = "white")
print("43")
isolation_table <- data.frame(from_id=c(select_isolation$from_id),from_id_name=c(table_from_id_name$name),to_id=c(select_isolation$to_id),to_id_name=c(table_to_id_name$name),total=c(select_isolation$total))
print(isolation_table)
write.csv(isolation_table,"../flask/isolation_table.csv", row.names = FALSE, fileEncoding = "UTF-8")
print("success")