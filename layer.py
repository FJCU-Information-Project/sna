from xml.dom.minidom import Element
import numpy as np
import pymysql
import sys
import os
import pandas as pd
from pandas.core.frame import DataFrame
import math
conn = pymysql.connect(host='140.136.155.121', port=50306,
                       user='root', passwd='IM39project', charset='utf8', db='trans')
if conn:
    print('success by layer.py')
    cursor = conn.cursor()
    # SQL_truncate = "TRUNCATE `trans`.`layer`"
    # cursor.execute(SQL_truncate)
    # factorId = 2 #起始點變數
    factorId = int(sys.argv[1])#起使節點id
    userId = str(sys.argv[2])#user_id
    datasetId = int(sys.argv[3])#dataset_id
    # userId = 5678
    # datasetId = 1
    times = 2
    list = []
    list1=[]
    list2=[]
    list3=[]
    list4=[]
    list5=[]
    duplicate = 0
    layerColumnName = ('factor_id', 'near_id', 'weight', 'color', 'level')
    list.append(layerColumnName)
    #sql = "SELECT `from_id`, `to_id`,`total` FROM `trans`.`weight` where `from_id`=%d" % (
        #factorId)  # 找和起始點相關的第一層節點
    # sql = "SELECT `from_id`, `to_id`,`total` FROM `trans0528`.`weight` where `from_id`=%d or `to_id`=%d"%(factorId,factorId)
    sql = "SELECT `from_id`, `to_id`,`total` FROM `%s`.`weight` where (`from_id`=%d or `to_id`=%d) and `dataset`=%d"%(userId,factorId,factorId,datasetId)
    cursor.execute(sql)  # 執行 SQL
    layer1Result = cursor.fetchall()  # 取出全部資料
    #layer1Result = None
    if layer1Result != ():
        from1_id = layer1Result[1][0]
        #layerValues = (from1_id, from1_id, 0, '#ffcc33', '起始點')
        layerValues = (factorId, factorId, 0, '#ffcc33', '起始點')
        list.append(layerValues)
        firstdata = DataFrame(list)
        firstdata.columns=['from_id','to_id','weight','color','layer']
        for i in range(len(layer1Result)):
            from1_id = layer1Result[i][0]
            to1_id = layer1Result[i][1]
            weight1 = layer1Result[i][2]
            if(to1_id==factorId):
                from1_id = layer1Result[i][1]
                to1_id = layer1Result[i][0]
                weight1 = layer1Result[i][2]
            # layerValues=(from1_id,from1_id,'#ffcc33','起始點')
            # list.append(layerValues)
            layer1Values = (from1_id, to1_id, weight1, '#699c4c', '第1層')
            list1.append(layer1Values)
            data = DataFrame(list1) #將list轉換成dataframe
            print(11)
            #print(data)
            # print(data[(data.weight1 != 0) ]& (data.to1_id!= factorId) )
            data = data[data[2] != 0]
        
            print(99)
            data.columns=['from_id','to_id','weight','color','layer']#加入dataframe欄名
        #print(data)
        if not data.empty:
        #data=(data[(data.weight != 0) ]& (data.to_id!= factorId) )
            data=data.sort_values(by=['weight'], ascending=False)#依照權重大小排序(高到低)
            layer1nodelen=round(len(list1)*0.1)#取權重前10%作為第一層節點
            data=data[0:layer1nodelen]#列出權重為前10%的所有肇事因素節點
            datatoid=data['to_id']#取得第一層節點
            datalist =data.values.tolist()
            from1_id=datatoid.values.tolist()#將第一層節點轉換為list型式作為尋找第二層節點的起始點
            for i in range(len(from1_id)):
                layer1_id = from1_id[i]
                #print(from1_id)
                #sql = "SELECT `from_id`, `to_id`,`total` FROM `%s`.`weight` where (`from_id`=%d) and `dataset`=%d"%(userId,factorId,datasetId)
                sql = "SELECT `from_id`, `to_id`,`total` FROM `%s`.`weight` where (`from_id`=%d or `to_id`=%d) and `dataset`=%d" % (userId,layer1_id,layer1_id,datasetId)
                cursor.execute(sql)  # 執行 SQL
                layer2Result = (cursor.fetchall())  # 取出全部資料
                #if layer2Result != ():
                for j in range(len(layer2Result)):
                    from2_id = layer2Result[j][0]
                    to2_id = layer2Result[j][1]
                    weight2 = layer2Result[j][2]
                    layer2Values = (from2_id, layer1_id, weight2, '#699c4c', '第1層')
                    #print(layer2Values)
                #for k in range(len(from1_id)):
                    #if layer2Values not in datalist:
                    if (to2_id not in from1_id):
                        layer2Values = (from2_id, to2_id,
                                        weight2, '#0066cc', '第2層')
                        list2.append(layer2Values)
                    else:
                        continue
                    data2 = DataFrame(list2) #將list2(第二層)轉換成dataframe
                    data2.columns=['from_id','to_id','weight','color','layer']#加入dataframe欄名
                    #print(data2)
            data2=data2.sort_values(by=['weight'], ascending=False)#依照權重大小排序(高到低)
            layer2nodelen=round(len(list2)*0.03)#取權重前3%作為第一層節點
            data2=data2[0:layer2nodelen]#列出權重為前3%的所有肇事因素節點
            frames = [firstdata, data, data2]
            # print(frames)
            result = pd.concat(frames)
            
            #以下將第一層和第二層的節點作合併 產出table
            data3=data2
            data3.columns=['to_id','to2_id','weight','color','layer']#加入dataframe欄名
            data4=data
            layertable = pd.merge(data4,data3,on='to_id')
            # layertable = columns=['from_id','to1_id','weight1','color1','layer1','to2_id','weight2','color2','layer2']#加入dataframe欄名
            ### 以下為測試
            #print(layertable)
            layerTableColumnName = ('from_id','to1_id','weight1','color1','layer1','to2_id','weight2','color2','layer2')
            list3.append(layerTableColumnName)
            #list3.append(layertable)
            layertabledf = DataFrame(list3)
            layertable.columns=['from_id','to1_id','weight1','color1','layer1','to2_id','weight2','color2','layer2']#加入dataframe欄名
            layertabledf.columns=['from_id','to1_id','weight1','color1','layer1','to2_id','weight2','color2','layer2']#加入dataframe欄名
            #print(layertabledf)
            # result2 = [layertabledf,layertable]
            #print(layertabledf)
            layertable=layertabledf.append(layertable)
            layertable=(layertable[(layertable.weight1 != 0) ] )
            layertable=(layertable[(layertable.from_id != layertable.to2_id) ] )
            print(layertable)
            print(result)
            conn.commit()  # 提交到 SQL
            #np.savetxt(".."+os.sep+"Flask"+os.sep+"layer.csv", list,
                    #delimiter=",", fmt='%s', encoding='utf-8-sig')
            np.savetxt(".."+os.sep+"Flask"+os.sep+"layer.csv", result,
                    delimiter=",", fmt='%s', encoding='utf-8-sig')#用於R的表
            #print(1)
            np.savetxt(".."+os.sep+"Flask"+os.sep+"layertable.csv", layertable,
                    delimiter=",", fmt='%s', encoding='utf-8-sig')#顯示於網頁的層級表
        else:
            layerColumnName = ('factor_id', 'near_id', 'weight', 'color', 'level')
            list4.append(layerColumnName)
            result = DataFrame(list4)
            layerTableColumnName = ('from_id','to1_id','weight1','color1','layer1','to2_id','weight2','color2','layer2')
            list5.append(layerTableColumnName)
            #list3.append(layertable)
            layertable = DataFrame(list5)
            np.savetxt(".."+os.sep+"Flask"+os.sep+"layer.csv", result,
                    delimiter=",", fmt='%s', encoding='utf-8-sig')#用於R的表
            #print(1)
            np.savetxt(".."+os.sep+"Flask"+os.sep+"layertable.csv", layertable,
                    delimiter=",", fmt='%s', encoding='utf-8-sig')#顯示於網頁的層級表
        cursor.close()

conn.close()  # 關閉 SQL 連線
