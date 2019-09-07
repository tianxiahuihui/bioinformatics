<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
<?php

$max_nodes=40;
$gene_symbol_1="SCN2A";
//$gene_symbols=$_POST['gene_symbols']?$_POST['gene_symbols']:$_GET['gene_symbols']; //$_GET: get parameters from other page links.
//$gene_symbols=preg_split("/[\s]+/",strtoupper($gene_symbols));
//$symbols_output=join("  ",$gene_symbols);
$edges=array();
//foreach($gene_symbols as $gene_symbol_1){
	$gene2pearson_splits=array();
	$i=0;
	$res_coexpr = `grep -i "^$gene_symbol_1\>" /var/www/html/NPdenovo/database/pearson.result2/all.gt0.7 | cut -f2`;
	
//	if($networkof == "HBT"){
//		$res_coexpr = `grep -i "^$gene_symbol_1\>" /var/www/html/NPdenovo/database/pearson.result2/all.gt0.7 | cut -f2`;
//	}elseif($networkof == "LMD"){
//		$res_coexpr = `grep -i "^$gene_symbol_1\>" /var/www/html/NPdenovo/database/pearson.LMD/all.gt0.7 | cut -f2`;
//	}elseif($networkof == "BrainSpan"){
//		$res_coexpr = `grep -i "^$gene_symbol_1\>" /var/www/html/NPdenovo/database/pearson.BrainSpan/all.gt0.7 | cut -f2`;
//	}

	$gene2pearsons=preg_split('/;/',$res_coexpr);
	foreach($gene2pearsons as $gene2pearson){
		$gene2pearson_temp=preg_split('/:/',$gene2pearson);
		if(abs($gene2pearson_temp[1])>=$min_pearson){
			$gene2pearson_splits[$i]["gene"]=$gene2pearson_temp[0];
			$gene2pearson_splits[$i]["pearson"]=$gene2pearson_temp[1];
			$i++;
		}
	}
	
	#sort
	$gene_symbol=array();
	$pearson=array();
	foreach($gene2pearson_splits as $key => $value) {
		$gene_symbol[$key]  = $value['gene'];
		$pearson[$key] = abs($value['pearson']);
	}
	array_multisort($pearson, SORT_DESC, $gene_symbol, SORT_ASC, $gene2pearson_splits);
	
	$all_symbols2pearon[$gene_symbol_1] = $gene2pearson_splits; //$all_symbols2pearon: [genesymbol => array(1 => array("gene"=>gene;"pearson"=>pearson))]  3 dimention
	
	$nodes_count=0;
	foreach($gene2pearson_splits as $key => $value){
		if($nodes_count<=$max_nodes){
			$edges[$gene_symbol_1][$value['gene']]=$value['pearson']; //$edges: [genesymbol => array(gene=>pearson)]  2 dimention
			$nodes_count+=1;//echo $value['gene']," ";
		}else{
			break;
		}
	}
	
//}

$all_symbol2mutnum=array();
$all_symbol_list_query=mysql_query("select * from All_disorder_pvalue");
while($all_symbol_list_res=mysql_fetch_array($all_symbol_list_query)){
	$all_symbol2mutnum[$all_symbol_list_res[Gene]]=$all_symbol2mutnum[$all_symbol_list_res[Gene]]?($all_symbol2mutnum[$all_symbol_list_res[Gene]]+$all_symbol_list_res[dn_LoF]+$all_symbol_list_res[dn_mis3]):($all_symbol_list_res[dn_LoF]+$all_symbol_list_res[dn_mis3]);
}

?>


    
    <head>
        <title>Cytoscape Web example</title>
        
		<!-- JSON support for IE (needed to use JS API) -->
		<script type="text/javascript" src="cytoscape_v1.0.4/js/min/json2.min.js"></script>
		
		<!-- Flash embedding utility (needed to embed Cytoscape Web) -->
		<script type="text/javascript" src="cytoscape_v1.0.4/js/min/AC_OETags.min.js"></script>
		
		<!-- Cytoscape Web JS API (needed to reference org.cytoscapeweb.Visualization) -->
		<script type="text/javascript" src="cytoscape_v1.0.4/js/min/cytoscapeweb.min.js"></script>
        
        <script type="text/javascript">
			window.onload = function() {
				// id of Cytoscape Web container div
				var div_id = "network";
				
				// NOTE: - the attributes on nodes and edges
				//       - it also has directed edges, which will automatically display edge arrows
				var xml = '\
				<graphml>\
				  <key id="label" for="all" attr.name="label" attr.type="string"/>\
				  <key id="weight" for="node" attr.name="weight" attr.type="double"/>\
				  <graph edgedefault="directed">\
					<?php
					$gene_lists=array();
					$array_redundancy=array();
					$node_list=array();
					foreach($edges as $symbol_once => $key_value){foreach($key_value as $key => $value){
						if(!in_array($key,$gene_lists)){
							array_push($gene_lists,$key);
							$weight_pearson=abs($value*2);
							$weight_pearson=sqrt($all_symbol2mutnum[$key]?($all_symbol2mutnum[$key]+3):0.1);
							echo "<node id=\"$key\"><data key=\"label\">$key</data><data key=\"weight\">$weight_pearson</data></node>";array_push($node_list,$key);}
						if($symbol_once != $key and !in_array($key,$gene_symbols)){echo "<edge source=\"$symbol_once\" target=\"$key\"></edge>";}
						if(!in_array("$symbol_once.$key",$array_redundancy) and !in_array("$key.$symbol_once",$array_redundancy) and in_array($key,$gene_symbols) and $symbol_once != $key){echo "<edge source=\"$symbol_once\" target=\"$key\"></edge>";array_push($array_redundancy,"$symbol_once.$key");}
					}}
					$array_redundancy=array();
					foreach($gene_symbols as $symbol_center){
						if(!in_array($symbol_center,$node_list)){
							$weight_ppi=sqrt($all_symbol2mutnum[$symbol_center]?($all_symbol2mutnum[$symbol_center]+3):0.1);
							echo "<node id=\"$symbol_center\"><data key=\"label\">$symbol_center</data><data key=\"weight\">$weight_ppi</data></node>";}}
					?>
					</graph>\
					</graphml>\
					';
                    
                    function rand_color() {
                        function rand_channel() {
                            return Math.round( Math.random() * 255 );
                        }
                        
                        function hex_string(num) {
                            var ret = num.toString(16);
                            
                            if (ret.length < 2) {
                                return "0" + ret;
                            } else {
                                return ret;
                            }
                        }
                        
                        var r = rand_channel();
                        var g = rand_channel();
                        var b = rand_channel();
                        
                        return "#" + hex_string(r) + hex_string(g) + hex_string(b); 
                    }
                    
                    // visual style we will use
                    var visual_style = {
                        global: {
                            backgroundColor: "#efefef"
                        },
                        nodes: {
                            //shape: "OCTAGON",
                            borderWidth: 1,
                            borderColor: "#ffffff",
                            size: {
                                defaultValue: 25,
                                continuousMapper: { attrName: "weight", minValue: 20, maxValue: 40 }
                            },
                            color: {
                                discreteMapper: {
                                    attrName: "id",
                                    entries: [
                                        <?
                                        $span_coexpr=1-$min_pearson;
                                        foreach($edges as $symbol_once => $key_value){
                                            echo "{ attrValue: \"$symbol_once\", value: \"#BAE3F9\" },"; //color of central genes
                                            foreach($key_value as $key => $value){
                                                if(! in_array($key,$gene_symbols)){
                                                    if($value<($span_coexpr/8+$min_pearson)){
                                                        echo "{ attrValue: \"$key\", value: \"#FFCCCC\" },"; //minimum pearson, light color
                                                    }elseif($value<($span_coexpr*2/8+$min_pearson)){
                                                        echo "{ attrValue: \"$key\", value: \"#FF9999\" },";
                                                    }elseif($value<($span_coexpr*3/8+$min_pearson)){
                                                        echo "{ attrValue: \"$key\", value: \"#FF6666\" },";
                                                    }elseif($value<($span_coexpr*4/8+$min_pearson)){
                                                        echo "{ attrValue: \"$key\", value: \"#FF3333\" },";
                                                    }elseif($value<($span_coexpr*5/8+$min_pearson)){
                                                        echo "{ attrValue: \"$key\", value: \"#FF0000\" },";
                                                    }elseif($value<($span_coexpr*6/8+$min_pearson)){
                                                        echo "{ attrValue: \"$key\", value: \"#CC0000\" },";
                                                    }elseif($value<($span_coexpr*7/8+$min_pearson)){
                                                        echo "{ attrValue: \"$key\", value: \"#990000\" },";
                                                    }else{
                                                        echo "{ attrValue: \"$key\", value: \"#660000\" },";
                                                    }
                                                }
                                            }
                                        }
                                        ?> 
                                    ]
                                }
                            },
                            labelHorizontalAnchor: "center"
                        },
                        edges: {
                            width: 1,
                            color: "#0B94B1",
                            targetArrowShape: "NONE"
                        }
                    };
                    // initialization options
                    var options = {
                        swfPath: "cytoscape_v1.0.4/swf/CytoscapeWeb",
                        flashInstallerPath: "cytoscape_v1.0.4/swf/playerProductInstall"
                    };
                    
                    var vis = new org.cytoscapeweb.Visualization(div_id, options);
                    
                    vis.ready(function() {
                        // set the style programmatically
                        document.getElementById("color").onclick = function(){
                            visual_style.global.backgroundColor = rand_color();
                            vis.visualStyle(visual_style);
                        };
                    });
     
                    var draw_options = {
                        // your data goes here
                        network: xml,
                        
                        // show edge labels too
                        edgeLabelsVisible: true,
                        
                        // let's try another layout
                        layout: "ForceDirected",
                        
                        // set the style at initialisation
                        visualStyle: visual_style,
                        
                        // hide pan zoom
                        panZoomControlVisible: false 
                    };
                    
                    vis.draw(draw_options);
                    vis.exportNetwork('draw_options', 'download_network.php?type=xml');
                };


        </script>
        
        <style>
            * { margin: 0; padding: 0; font-family: Helvetica, Arial, Verdana, sans-serif; }
            html, body { height: 100%; width: 100%; padding: 0; margin: 0; background-color: #f0f0f0; }
            body { line-height: 1.5; color: #000000; font-size: 14px; }
            /* The Cytoscape Web container must have its dimensions set. */
            #network { width: 100%; height: 80%; }
            #note { width: 100%; text-align: center; padding-top: 1em; }
            .link { text-decoration: underline; color: #0b94b1; cursor: pointer; }
        </style>
    </head>
    
    <body>
        <div id="network">
            Cytoscape Web will replace the contents of this div with your graph.
        </div>
    </body>
    
</html>
