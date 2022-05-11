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
inId3 <- args[3] #選取想看的權重程度(前10%、前20%、前30%.....全部(100%))，以小數位回傳(0.1、0.2、0.3、....、1)
inId3 <- as.numeric(inId3)
connect = dbConnect(MySQL(), dbname = inId1,username = "root",
                    password = "IM39project",host = "140.136.155.121",port=50306,DBMSencoding="UTF8")
dbListTables(connect)
dbSendQuery(connect,"SET NAMES utf8") # 設定資料庫連線編碼
Sys.getlocale("LC_ALL") #解決中文編碼問題
print("21")

max_weight <- as.numeric(dbGetQuery(connect, paste0("select max(`total`) from `",inId1,"`.weight where dataset = ",inId2)))
max_weight <- max_weight*(1-inId3)
#max_weight <- max_weight*(1-0.2) #目前直接設定顯示關聯程度前20%
#node_all <- dbGetQuery(connect, paste0("select * from `",inId1,"`.node where dataset = ",inId2))
print(34)
node_id <- dbGetQuery(connect, paste0("select * from `",inId1,"`.weight where (total > ",max_weight,") and dataset = ",inId2))
from_id_name <- dbGetQuery(connect, paste0("select `name` from `",inId1,"`.weight w, `",inId1,"`.node n where (total > ",max_weight,") and w.from_id = n.id and n.dataset = ",inId2))
to_id_name <- dbGetQuery(connect, paste0("select `name` from `",inId1,"`.weight w, `",inId1,"`.node n where (total > ",max_weight,") and w.to_id = n.id and n.dataset = ",inId2))

print(head(from_id_name))
print(head(to_id_name))
count_rank <- as.numeric(dbGetQuery(connect, paste0("select count(`from_id`) from `",inId1,"`.weight where (total > ",max_weight,") and dataset = ",inId2)))
print(90)
print(count_rank)
node_id <- data.frame(from_id=c(node_id[,2]), from_id_name=c(from_id_name[,1]), to_id=c(node_id[,3]), to_id_name=c(to_id_name[,1]), weight=c(node_id[,4]))
print(head(node_id))

node_id <- node_id[order(-node_id$weight),]

list <- data.frame(rank=c(1:count_rank), c(node_id[1:count_rank,]))
#print(list)
node_id <- node_id[1:count_rank,]
print("52")
print(node_id)
i <- 2
while (i <= count_rank){  
  if (list$weight[i]==list$weight[i-1]){
    list$rank[i] <- list$rank[i-1]
  }
  i <- i + 1
}
print(head(list))
#print(head(node_id))
#node_all是給node用的
node_all <- data.frame(id=c(node_id[,1],node_id[,3]),name=c(node_id[,2],node_id[,4]))
print(node_all)
node_all <- node_all[!duplicated(node_all$id),]
print("67")
print(node_all)
#print(head(from_id_name))
#print(head(to_id_name))
node <- data.frame(id=c(node_all[,1]), name=c(node_all[,2]), title=c(node_all[,2]), label=c(node_all[,2]), group=c(node_all[,2]), font.size=20)
#print(node)
edge <- data.frame(from=c(list$from_id),to=c(list$to_id),value=c(list$weight),width=c(list$weight),title=paste("Weight:",list$weight," ,Rank:",list$rank))
#print(edge)

all_table<- data.frame(rank=c(list$rank),from_id=c(list$from_id),from_id_name=c(list$from_id_name),to_id=c(list$to_id),to_id_name=c(list$to_id_name),total=c(list$weight))
write.csv(all_table,paste0("..",.Platform$file.sep,"Flask",.Platform$file.sep,"all_table.csv"), row.names = FALSE, fileEncoding = "UTF-8")
print(all_table)
print("79")

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