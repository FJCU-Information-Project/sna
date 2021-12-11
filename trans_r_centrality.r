library("visNetwork")
library("sqldf")
library("dbConnect")
install.packages("dbConnect")
args <- commandArgs(TRUE)
N <- args[1]
H <- strsplit(N,split="/",fixed=T)
category <- H[[1]][1]
memTable <- H[[1]][2]

Sys.setlocale(category = "LC_ALL", locale = "zh_TW.UTF-8")
con <- dbConnect(RMySQL::MySQL(), host = "140.136.155.121", port=3306,dbname="trans",user = "root", password = "im39project")
dbSendQuery(con,"SET NAMES utf8")
member <- dbReadTable(con, memTable)

main <- read.csv.sql("Nfile.csv", sql = "SELECT * FROM trans.node")
rela <- read.csv.sql("Rfile.csv", sql = "SELECT * FROM trans.relationship GROUP by `from`, `to`")