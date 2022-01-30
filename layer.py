import numpy as np 
import pymysql
conn = pymysql.connect(host='140.136.155.121',port=50306,user='root',passwd='IM39project',charset='utf8',db='trans')
if conn:
    print('success')
    cursor=conn.cursor()
    # SQL_truncate = "TRUNCATE `trans`.`layer`"
    # cursor.execute(SQL_truncate)
    factorId = 17 #起始點變數
    times=2
    list=[]
    duplicate = 0
    layerColumnName=('factor_id','near_id', 'weight', 'color', 'level')
    list.append(layerColumnName)
    sql = "SELECT `from_id`, `to_id`,`total` FROM `trans`.`weight` where `from_id`=%d"%(factorId) # 找和起始點相關的第一層節點
    cursor.execute(sql)# 執行 SQL 
    layer1Result = cursor.fetchall()# 取出全部資料
    
    #layer1Result = None
    
    if layer1Result!=():
        from1_id=layer1Result[1][0]
        layerValues=(from1_id,from1_id,0,'#ffcc33','起始點')
        list.append(layerValues)
        for i in range(len(layer1Result)): 
            from1_id=layer1Result[i][0]
            to1_id=layer1Result[i][1]
            weight1=layer1Result[i][2]
            # layerValues=(from1_id,from1_id,'#ffcc33','起始點')
            # list.append(layerValues)
            layer1Values=(from1_id,to1_id,weight1,'#699c4c','第1層')
            list.append(layer1Values)
            sql = "SELECT `from_id`, `to_id`,`total` FROM `trans`.`weight` where `from_id`=%d"%(to1_id)
            cursor.execute(sql)# 執行 SQL 
            layer2Result=(cursor.fetchall()) # 取出全部資料
           # print(layer2Result)
            for j in range(len(layer2Result)):
                from2_id=layer2Result[j][0]
                to2_id=layer2Result[j][1]
                weight2=layer2Result[j][2]
                layer2Values = (from2_id,factorId,weight2,'#699c4c','第1層')
                if layer2Values not in list:
                    layer2Values = (from2_id,to2_id,weight2,'#0066cc','第2層')
                    list.append(layer2Values)
                else:
                    continue
        #print(list)
        # SQL = "INSERT INTO `trans`.`layer` (factor_id, near_id, color, level) VALUES (%s, %s, %s, %s, %s)"
        # cursor.executemany(SQL, list)
        conn.commit()# 提交到 SQL
    np.savetxt("numpy.csv", list, delimiter =",",fmt ='%s', encoding='UTF-8')
cursor.close()
conn.close()# 關閉 SQL 連線



