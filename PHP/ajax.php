<?php
require_once('mysql_connection.php');

header('Content-type: text/json');
$res = $_POST['aoData'];
$chr = $_GET['Chr'];
$effect = $_GET['Effect'];
$disorder = $_GET['Disorder'];

$sEcho = 0;
$iDisplayStart = 0; // 起始索引
$iDisplayLength = 0;//分页长度
$iSortCol_0 = 0;
$sSortDir_0 = "DESC";
$sSearch = '';

$jsonarray= json_decode(stripslashes($res)) ;
foreach($jsonarray as $value){ 
	if($value->name=="sEcho"){
	   $sEcho=$value->value;
	}
	if($value->name=="iDisplayStart"){
	   $iDisplayStart=$value->value;
	}
	if($value->name=="iDisplayLength"){
	   $iDisplayLength=$value->value;
	}
	if ($value -> name  == "iSortCol_0") {
		$iSortCol_0 = $value -> value;
	}
	if ($value -> name  == "sSortDir_0") {
		$sSortDir_0 = $value -> value;
	}
	if ($value -> name  == "sSearch") {
		$sSearch = $value -> value;
	}
}

if((int)$iSortCol_0==0){$sortCol="Chr";}elseif((int)$iSortCol_0==1){$sortCol="Start";}elseif((int)$iSortCol_0==2){$sortCol="End";}elseif((int)$iSortCol_0==3){$sortCol="Ref";}elseif((int)$iSortCol_0==4){$sortCol="Alt";}elseif((int)$iSortCol_0==5){$sortCol="Cytoband";}elseif((int)$iSortCol_0==6){$sortCol="Gene_region";}elseif((int)$iSortCol_0==7){$sortCol="disorder";}elseif((int)$iSortCol_0==8){$sortCol="Gene_symbol";}elseif((int)$iSortCol_0==9){$sortCol="Effect";}elseif((int)$iSortCol_0==10){$sortCol="Mutation_type";}elseif((int)$iSortCol_0==11){$sortCol="Total_damaging_score";}elseif((int)$iSortCol_0==12){$sortCol="Extreme";}

$Array = Array(); 

//$sSearch = strtolower($sSearch);

if($sSearch==''){
	if($chr=="All" && $effect=="All" && $disorder=="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder ORDER BY $sortCol $sSortDir_0";
	}elseif($chr!="All" && $effect=="All" && $disorder=="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder where Chr='".$chr."' ORDER BY $sortCol $sSortDir_0";
	}elseif($chr=="All" && $effect!="All" && $disorder=="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder where Effect='".$effect."' ORDER BY $sortCol $sSortDir_0";
	}elseif($chr=="All" && $effect=="All" && $disorder!="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder where disorder='".$disorder."' ORDER BY $sortCol $sSortDir_0";
	}elseif($chr!="All" && $effect!="All" && $disorder=="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder where Chr='".$chr."' AND Effect='".$effect."' ORDER BY $sortCol $sSortDir_0";
	}elseif($chr!="All" && $effect=="All" && $disorder!="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder where Chr='".$chr."' AND disorder='".$disorder."' ORDER BY $sortCol $sSortDir_0";
	}elseif($chr=="All" && $effect!="All" && $disorder!="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder where Effect='".$effect."'  AND disorder='".$disorder."' ORDER BY $sortCol $sSortDir_0";
	}elseif($chr!="All" && $effect!="All" && $disorder!="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder where Chr='".$chr."' AND Effect='".$effect."' AND disorder='".$disorder."' ORDER BY $sortCol $sSortDir_0";
	}
}else{
	if($chr=="All" && $effect=="All" && $disorder=="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder where concat(Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme) LIKE '%".$sSearch."%' ORDER BY $sortCol $sSortDir_0";
	}elseif($chr!="All" && $effect=="All" && $disorder=="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder where Chr='".$chr."' AND concat(Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme) LIKE '%".$sSearch."%' ORDER BY $sortCol $sSortDir_0";
	}elseif($chr=="All" && $effect!="All" && $disorder=="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder where Effect='".$effect."' AND concat(Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme) LIKE '%".$sSearch."%' ORDER BY $sortCol $sSortDir_0";
	}elseif($chr=="All" && $effect=="All" && $disorder!="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder where disorder='".$disorder."' AND concat(Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme) LIKE '%".$sSearch."%' ORDER BY $sortCol $sSortDir_0";
	}elseif($chr!="All" && $effect!="All" && $disorder=="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder where Chr='".$chr."' AND Effect='".$effect."' AND concat(Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme) LIKE '%".$sSearch."%' ORDER BY $sortCol $sSortDir_0";
	}elseif($chr!="All" && $effect=="All" && $disorder!="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder where Chr='".$chr."' AND disorder='".$disorder."' AND concat(Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme) LIKE '%".$sSearch."%' ORDER BY $sortCol $sSortDir_0";
	}elseif($chr=="All" && $effect!="All" && $disorder!="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder where Effect='".$effect."'  AND disorder='".$disorder."' AND concat(Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme) LIKE '%".$sSearch."%' ORDER BY $sortCol $sSortDir_0";
	}elseif($chr!="All" && $effect!="All" && $disorder!="All"){$each_query="select Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme from All_disorder where Chr='".$chr."' AND Effect='".$effect."' AND disorder='".$disorder."' AND concat(Chr,Start,End,Ref,Alt,Cytoband,Gene_region,disorder,Gene_symbol,Effect,Mutation_type,Total_damaging_score,Extreme) LIKE '%".$sSearch."%' ORDER BY $sortCol $sSortDir_0";
	}
}

$array_list=array();
$recordsTotal=0;
$each_search_row=mysql_query($each_query);
while($each_info=mysql_fetch_array($each_search_row)){

	if(strlen($each_info[Ref])<=2 && strlen($each_info[Alt]) <= 2){
	$d =  array($each_info[Chr],$each_info[Start],$each_info[End],$each_info[Ref],$each_info[Alt],$each_info[Cytoband],$each_info[Gene_region],$each_info[disorder],$each_info[Gene_symbol],$each_info[Effect],$each_info[Mutation_type],$each_info[Total_damaging_score],$each_info[Extreme],$each_info[Ref],$each_info[Alt]);
	}elseif(strlen($each_info[Ref])>2 && strlen($each_info[Alt]) <= 2){
		$str1 = substr($each_info[Ref],0,3)."&hellip;";
		$d =  array($each_info[Chr],$each_info[Start],$each_info[End],$str1,$each_info[Alt],$each_info[Cytoband],$each_info[Gene_region],$each_info[disorder],$each_info[Gene_symbol],$each_info[Effect],$each_info[Mutation_type],$each_info[Total_damaging_score],$each_info[Extreme],$each_info[Ref],$each_info[Alt]);
	}elseif(strlen($each_info[Ref])<=2 && strlen($each_info[Alt]) > 2){
		$str1 = substr($each_info[Alt],0,3)."&hellip;";
		$d =  array($each_info[Chr],$each_info[Start],$each_info[End],$each_info[Ref],$str1,$each_info[Cytoband],$each_info[Gene_region],$each_info[disorder],$each_info[Gene_symbol],$each_info[Effect],$each_info[Mutation_type],$each_info[Total_damaging_score],$each_info[Extreme],$each_info[Ref],$each_info[Alt]);
	}elseif(strlen($each_info[Ref])<=2 && strlen($each_info[Alt]) > 2){
		$str1 = substr($each_info[Ref],0,3)."&hellip;";
		$str2 = substr($each_info[Alt],0,3)."&hellip;";
		$d =  array($each_info[Chr],$each_info[Start],$each_info[End],$str1,$str2,$each_info[Cytoband],$each_info[Gene_region],$each_info[disorder],$each_info[Gene_symbol],$each_info[Effect],$each_info[Mutation_type],$each_info[Total_damaging_score],$each_info[Extreme],$each_info[Ref],$each_info[Alt]);
	}

	Array_push($Array, $d);
	$recordsTotal++;
}

$json_data = array ('sEcho'=>$sEcho,'iTotalRecords'=>$recordsTotal,'iTotalDisplayRecords'=>$recordsTotal,'aaData'=>array_slice($Array,$iDisplayStart,$iDisplayLength));  //按照datatable的当前页和每页长度返回json数据
$obj=json_encode($json_data);
echo $obj;

?>

