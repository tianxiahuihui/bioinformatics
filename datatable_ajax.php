<?php include("header.php");?>
<?php require_once('mysql_connection.php'); ?>

<style type="text/css" title="currentStyle">  
    @import "css/jquery.dataTables.min.css";  
    @import "css/jquery.dataTables_themeroller.css";  
</style> 

<script type="text/javascript" src="js/jquery.dataTables.min.js"></script>

<script type="text/javascript">
	$(document).ready(function() {
		refreshDataTable();
	});

 var refreshDataTable=function() {
	 var table = $('#bro_mu').DataTable({
		 //"ajax":"data/tabledata.json",
		// "iDisplayLength": 3,
		// "sPaginationType": "full_numbers",//分页风格，full_number会把所有页码显示出来
		"deferRender": true,//当处理大数据时，延迟渲染数据，有效提高Datatables处理能力
		 "bPaginite": true,
		 "bInfo": true,
		 "bSort": true,
		 "processing": false,
		 "bLengthChange" : true,
		 "bAutoWidth": false,
		 "aLengthMenu": [[20, 50, 100], ["20", "50", "100"]],
		 "iDisplayLength" : 20,
		 "aaSorting": [[11, "desc"]],
		 "aoColumnDefs":[{"aTargets":[8],"mRender":function(data,type,full){return "<a href=\"detail.php?Gene_symbol='"+data+"'\">"+data+"</a>"}
		 }],

		 "serverSide": true,//是否从服务器加载数据
		 "sAjaxSource": "ajax.php",//这个是请求的地址
		 "fnServerData": retrieveData //获取数据的处理函数

	 });
	 function retrieveData(url, aoData, fnCallback) {
		 var data={"data":{"id":"123123","name":"2s",}};
		 $.ajax({
			 url: url,//这个就是请求地址对应sAjaxSource
			 data : {
				 "aoData" : JSON.stringify(aoData)
			 },
			 type: 'POST',//使用post方式传递数据
			 dataType: 'json',
			 async: false,
			 success: function (result) {

			 //var obj=JSON.parse(result);
			 console.log(result);
			 fnCallback(result);//把返回的数据传给这个方法就可以了,datatable会自动绑定数据的
			 },
			 error:function(XMLHttpRequest, textStatus, errorThrown) {

			 alert("status:"+XMLHttpRequest.status+",readyState:"+XMLHttpRequest.readyState+",textStatus:"+textStatus);

			 }
		 });
	 }
 };
</script>


<div class="container">

	<table class="table table-bordered table-hover" id="bro_mu">
	<thead>
		<tr class='info'>								
			<th>chr</th>
			<th>Start</th>
			<th>End</th>
			<th>Ref</th>
			<th>Alt</th>
			<th>Cytoband</th>
			<th>Gene region</th>
			<th>Disorder</th>
			<th>Gene symbol</th>
			<th>Effect</th>
			<th>Mutation type</th>
			<th>Total damaging score</th>
			<th style="text-align:center;">Extreme</th>
		</tr>
	</thead><tbody>

	</tbody>
	</table>

</div>

<br/>
<?php include("footer.php");?>
