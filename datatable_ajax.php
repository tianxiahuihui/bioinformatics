<?php include("header.php");?>
<?php require_once('mysql_connection.php'); ?>

<style type="text/css" title="currentStyle">  
    @import "css/jquery.dataTables.min.css";  
    @import "css/jquery.dataTables_themeroller.css";  
</style> 

<style type="text/css" title="currentStyle">  
td.details-control {
    background: url('img/details_open.png') no-repeat center center;
    cursor: pointer;
}
tr.shown td.details-control {
    background: url('img/details_close.png') no-repeat center center;
}
</style> 

<script type="text/javascript" src="js/jquery.dataTables.min.js"></script>

<script type="text/javascript">
function format ( d ) {
    // `d` is the original data object for the row
    return '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
        '<tr>'+
            '<td>Ref:</td>'+
            '<td>'+d[13]+'</td>'+
            '<td>Alt:</td>'+
            '<td>'+d[14]+'</td>'+
        '</tr>'+
        '<tr>'+
            '<td>Gene Symbol:</td>'+
            '<td>'+d[8]+'</td>'+
        '</tr>'+
    '</table>';
}

$(document).ready(function() {
	refreshDataTable();


	
});

 var refreshDataTable=function() {

//	var chr = "chr1";
//	var eff = "nonsynonymous";
//	var dis = "ASD";

	var chr=$("#chr").val();
	var eff=$("#eff").val();
	var dis=$("#dis").val();

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
		destroy: true,
        "columns": [
            { "aoData": "Chr" },
            { "aoData": "Start" },
            { "aoData": "End" },
            { "aoData": "Ref" },
            { "aoData": "Alt" },
            { "aoData": "Cytoband" },
            { "aoData": "Gene region" },
            { "aoData": "Disorder" },
            { "aoData": "Gene symbol" },
            { "aoData": "Effect" },
            { "aoData": "Mutation type" },
            { "aoData": "Total damaging score" },
            { "aoData": "Extreme" },
            { "aoData": "Ref" },
            { "aoData": "Alt" },
            {
                "className":      'details-control',
                "orderable":      false,
                "aoData":           null,
                "defaultContent": ''
            }
        ],
		
		"aoColumnDefs": [{ //隐藏列
		"bVisible": false,"aTargets": [13],"bSearchable": false},{
		"bVisible": false,"aTargets": [14],"bSearchable": false},{
		"aTargets":[8],"mRender":function(data,type,full){return "<a href=\"detail.php?Gene_symbol='"+data+"'\">"+data+"</a>"}}
		],
		 "serverSide": true,//是否从服务器加载数据
		 "sAjaxSource": "ajax.php?Chr="+chr+"&Effect="+eff+"&Disorder="+dis+"",//这个是请求的地址
		// "sAjaxSource": "ajax.php?Chr=chr1&Effect=nonsynonymous&Disorder=ASD",//这个是请求的地址
		 "fnServerData": retrieveData //获取数据的处理函数

	 });

	// Add event listener for opening and closing details
    $('#bro_mu tbody').on('click', 'td.details-control', function () {
        var tr = $(this).closest('tr');
        var row = table.row( tr );
 
        if ( row.child.isShown() ) {
            // This row is already open - close it
            row.child.hide();
            tr.removeClass('shown');
        }
        else {
            // Open this row
            row.child( format(row.data()) ).show();
            tr.addClass('shown');
        }
    } );

	 function retrieveData(url, aoData, fnCallback) {
		// var data={"data":{"id":"123123","name":"2s",}};
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

<div class="form-group">
	<label class="col-sm-3 control-label">Three parameters to filter:</label>
	<div class="col-sm-3">
		<select class="form-control" name="chr" id="chr" onchange="refreshDataTable()">
		<option value="All" name="All" selected="selected">All chromosome</option>
		<option value="chr1" name="chr1">chr1</option><option value="chr2" name="chr2">chr2</option><option value="chr3" name="chr3">chr3</option>
		<option value="chr4" name="chr4">chr4</option><option value="chr5" name="chr5">chr5</option><option value="chr6" name="chr6">chr6</option>
		<option value="chr7" name="chr7">chr7</option><option value="chr8" name="chr8">chr8</option><option value="chr9" name="chr9">chr9</option>
		<option value="chr10" name="chr10">chr10</option><option value="chr11" name="chr11">chr11</option><option value="chr12" name="chr12">chr12</option>
		<option value="chr13" name="chr13">chr13</option><option value="chr14" name="chr14">chr14</option><option value="chr15" name="chr15">chr15</option>
		<option value="chr16" name="chr16">chr16</option><option value="chr17" name="chr17">chr17</option><option value="chr18" name="chr18">chr18</option>
		<option value="chr19" name="chr19">chr19</option><option value="chr20" name="chr20">chr20</option><option value="chr21" name="chr21">chr21</option>
		<option value="chr22" name="chr22">chr22</option><option value="chrX" name="chrX">chrX</option><option value="chrY" name="chrY">chrY</option>

		</select>
	</div>
	
	<div class="col-sm-3">
		<select class="form-control" name="eff" id="eff" onchange="refreshDataTable()">
		<option value="All" name="All" selected="selected">All mutation effect</option>
		<option value="nonsynonymous" name="nonsynonymous">nonsynonymous</option>
		<option value="splicing" name="splicing" >splicing</option>
		<option value="frameshift" name="frameshift" >frameshift</option>
		<option value="nonframeshift" name="nonframeshift">nonframeshift</option>
		<option value="synonymous" name="synonymous" >synonymous</option>
		<option value="unknown" name="unknown">unknown</option>

		</select>
	</div>

	<div class="col-sm-3">
		<select class="form-control" name="dis" id="dis" onchange="refreshDataTable()">
		<option value="All" name="All" selected="selected">All disorder</option>
		<option value="ASD" name="ASD">ASD</option>
		<option value="ID" name="ID">ID</option>
		<option value="EE" name="EE">EE</option>
		<option value="SCZ" name="SCZ">SCZ</option>
		<option value="DD" name="DD">DD</option>
		<option value="Control" name="Control">Control</option>
		</select>
	</div>
</div>

<br/>
<br/>

	<table class="table table-bordered table-hover" id="bro_mu">
	<thead>
		<tr class='info'>								
			<th>Chr</th>
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
			<th></th>
			<th></th>
			<th>Detail</th>
		</tr>
	</thead><tbody>

	</tbody>

<!--	<tfoot>
		<tr>								
			<th>Chr</th>
			<th></th>
			<th></th>
			<th></th>
			<th></th>
			<th></th>
			<th></th>
			<th>Disorder</th>
			<th></th>
			<th>Effect</th>
			<th></th>
			<th></th>
			<th></th>
			<th></th>
			<th></th>
			<th></th>
		</tr>
	</tfoot>
-->
</table>

</div>

<br/>
<?php include("footer.php");?>
