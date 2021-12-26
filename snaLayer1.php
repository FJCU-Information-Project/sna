<!doctype html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>snalayer1</title>
</head>

<body>
    <p>
        <?php
        parse_str(implode('&', array_slice($argv, 1)), $_GET);
        if(empty($argv[1])){
            print "尚未傳入參數：請輸入正確指令：";
            exit;
        }else{
            print "運算中。。。";
        }
            
        set_time_limit(0);
        $DBNAME = "trans";
        $DBUSER = "root";
        $DBPASSWD = "IM39project";
        $DBHOST = "140.136.155.121";
    
        $link = mysqli_connect($DBHOST, $DBUSER, $DBPASSWD);
        if (empty($link)) {
            echo mysqli_error($link);
            die("無法連接資料庫");
            exit;
        }

        if (!mysqli_select_db($link, $DBNAME)) {
            die("無法選擇資料庫");
        }
        mysqli_query($link, "SET NAMES 'utf8'");

        # 輸入條件
        # $attr_name = "天候";
        # $node_name = "晴";
            
        $attr_name = $_GET['attr'];
        $node_name = $_GET['node'];
            
        # 幾層
        $times = 2;

        $list = array();
        $tlist = array();
        $edge = array();
        array_push($edge, ["from_id", "to_id", "d_edge"]);

        $aid = array();
        $aedge = array();
        $alevel = array();
        $nlist = array();
        $no = array();
        $node = array();
        array_push($node, ["id", "near_node", "attr_name", "level", "color"]); #mac
        # array_push($node, ["id", "level", "color"]); #windows


        # 找node_name的id 設想接收過來的會是node_name 的id
        $s_sql = "SELECT DISTINCT id FROM relationship WHERE from_id = '$node_name'";
        if ($s = $link->query($s_sql)) {
            while ($fieldinfo = $s->fetch_object()) {
                $id = $fieldinfo->id;

                array_push($list, $id);
                array_push($aid, $id);
                array_push($aedge, 100);
                array_push($alevel, "起始點");
                array_push($no, [$id, "起始點"]);

                # 找下一層
                for ($i = 0; $i < $times; $i++) {
                    foreach ($list as $value) {
                        $rela_sql = "SELECT * FROM relationship WHERE from_id = '$value'";
                        $rela = mysqli_query($link, $rela_sql);

                        while ($row = mysqli_fetch_array($rela, MYSQLI_ASSOC)) {
                            $from_id = $row["from_id"];
                            $to_id = $row["to_id"];
                            $d_edge = $row["d_edge"] * 10;


                            # 製成edge表
                            $count = ($i + 1);
                            $group = "第 " . ($count) . " 層";
                            # echo $group. "<br>";

                            array_push($tlist, $to_id);
                            if (!in_array([$from_id, $to_id, $d_edge], $edge)) {
                                array_push($edge, [$from_id, $to_id, $d_edge]);
                            }

                            # node
                            if (!in_array([$to_id, $group], $no)) {
                                array_push($aid, $to_id);
                                array_push($aedge, $d_edge);
                                array_push($alevel, $group);
                            }

                            if (!in_array($to_id, $nlist)) {
                                array_push($nlist, $to_id);
                            }
                        }
                    }
                    $list = $tlist;
                    $tlist = array();
                }

                # 製成node表

                $bid = array();
                $ed = array();
                $lev = array();
                foreach ($nlist as $ta) {
                    $max = 1;
                    $key = array_keys($aid, $ta, true);
                    # print_r($key);

                    foreach ($key as $test) {
                        if (sizeof($key) == 1) {
                            # echo sizeof($key). "<br>";
                            array_push($no, [$aid[$test], $alevel[$test]]);
                        } else {
                            if ($aedge[$test] > $max) {
                                $max = $aedge[$test];

                                if (!in_array([$aid[$test], $alevel[$test]], $no)) {
                                    array_push($bid, $aid[$test]);
                                    array_push($ed, $aedge[$test]);
                                    array_push($lev, $alevel[$test]);
                                }
                            }
                        }
                    }

                    if (sizeof($ed) > 0) {

                        $maxedge = max($ed);
                        $find = array_search($maxedge, $ed);
                        $newid = $bid[$find];
                        $newlevel = $lev[$find];

                        if (!in_array([$newid, $newlevel], $no) and $newid != $id) {
                            array_push($no, [$newid, $newlevel]);
                        }
                    }
                    $bid = array();
                    $ed = array();
                    $lev = array();
                }

                foreach ($no as $test) {
                    $level = $test[1];
                    $node_sql = "SELECT DISTINCT id, `name`, attribute FROM node WHERE id = '$test[0]'";
                    $node = mysqli_query($link, $node_sql);

                    while ($row2 = mysqli_fetch_array($node, MYSQLI_ASSOC)) {
                        $nid = $row2["id"];
                        $near_node = $row2["name"];
                        $attr_name = $row2["attribute"];

                        if (strcmp($level, '起始點') == 0) {
                            $color = "#ffcc33";
                            array_push($node, [$nid, $near_node, $attr_name, $level, $color]); #mac
                            # array_push($node, [$nid, $level, $color]); #windows
                        } elseif (strcmp($level, '第 1 層') == 0) {
                            $color = "#699c4c";
                            array_push($node, [$nid, $near_node, $attr_name, $level, $color]); #mac
                            # array_push($node, [$nid, $level, $color]); #windows
                        } elseif (strcmp($level, '第 2 層') == 0) {
                            $color = "#0066cc";
                            array_push($node, [$nid, $near_node, $attr_name, $level, $color]); #mac
                            # array_push($node, [$nid, $level, $color]); #windows
                        }
                    }
                }
                #輸出
                $nfp = fopen('snaLayer1_node.csv', 'w');
                foreach ($node as $nofield) {
                    fputcsv($nfp, $nofield);
                }

                fclose($nfp);

                $fp = fopen('snaLayer1_edge.csv', 'w');
                foreach ($edge as $fields) {
                    fputcsv($fp, $fields);
                }

                fclose($fp);

                echo "完成" . "<br>";

                mysqli_close($link);
            }
        }
        ?>
    </p>

</body>

</html>
