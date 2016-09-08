<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<!-- <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
 --><meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet"
	href="http://neo4j-contrib.github.io/developer-resources/language-guides/assets/css/main.css">
<title>Screen To Service Mapping</title>

</head>
<body>
	<div role="navigation" class="navbar navbar-default navbar-static-top">
		<div class="container">
			<div class="row">
					<div class="navbar-header col-sm-6 col-md-6"  >
					<div class="logo-well">
						 <img
							src="http://neo4j-contrib.github.io/developer-resources/language-guides/assets/img/logo-white.svg"
							alt="Neo4j World's Leading Graph Database" id="logo">
					</div>
					<div class="navbar-brand">
						<div class="brand">Screen To Service Mapping</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	
	<div class="row">
	<div class="col-sm-4 col-md-7">
					<ul class="nav navbar-nav">
						<li>
							<form class="navbar-form" id="search">
								<div class="form-group">
									<input type="text" id="idSearch" value="service" placeholder="Search for Result" class="form-control" name="search">
								</div>
								<button id="btnSearch" type="button">Search</button>
							</form>
						</li>
					</ul>
					
				<div id="divSearchReasult" class="col-md-5" style="display:none" >
			     <div class="panel panel-default">
				<div id="searchfade"class="panel-heading">Search Results</div>
				<table id="results" class="table table-striped table-hover">
					<tbody>
					</tbody>
				</table>
			</div>
		</div>
	</div>
<div class="panel-heading" style="font-weight: bold" id="title" >
</div>
<select id="insightList" multiple="multiple"></select>
<input type="button" id="btnSelected" value="Submit" />
<div id="graph" class="col-md-9" ></div>
</div>
 <div class="col-sm-6 col-md-7">
 <div id="alerts" style="display:none">No matching data found for your search result. Please try again.</div>
 </div>
<style type="text/css">
div#graph   {
     margin-top:300px !important;
      margin-left:300px !important;
  			}
.node {
            cursor: pointer;
       }

 .node circle {
                fill: #fff;
                stroke: steelblue;
                stroke-width: 3px;
            }
            
.link {
            fill: none;
            stroke: #ccc;
        }

        .tree {
            margin-left: 10px;
            overflow: auto;
        }
</style>

<script type="text/javascript" src="//code.jquery.com/jquery-1.11.0.min.js"></script>
<script src="http://d3js.org/d3.v3.min.js" type="text/javascript"></script>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
<script src="http://code.jquery.com/jquery.min.js"></script>
<script src="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/js/bootstrap.min.js"></script>
<script type="text/javascript" src="http://davidstutz.github.io/bootstrap-multiselect/dist/js/bootstrap-multiselect.js"></script>
<link rel="stylesheet" href="http://davidstutz.github.io/bootstrap-multiselect/dist/css/bootstrap-multiselect.css" type="text/css"/>
<script id="example">
$('#insightList').multiselect({
  enableClickableOptGroups: true
});
</script>
<script type="text/javascript">

$('#btnSelected').click(function () {
    var selected = $("#insightList option:selected");
    var message = "";
    selected.each(function () {
        message += $(this).html() + ",";
    });
    $("#graph").empty();
    eachItemChecklist(message);

});
	
$('#insightList').multiselect({

    includeSelectAllOption: true

});
	$.ajax({
        type: "POST",
        url: "test",
		 dataType : 'json',
    	 data : {
    		    "action":"4",
   			    },
        success: function(relations) 
        {
       	relations.forEach(function(row) 
       			{
					var name = row.n;	
				    var htm = '';
					    htm += '<option>' + name + '</option>';
					    $('#insightList').append(htm);
					    $('#insightList').multiselect('rebuild');
					
       		 });
       	 
       	 } 
 		 });
	
	$("#btnSearch").click(function(){
		$("#graph").empty();
		 var searchValue = $('#idSearch').val(); 
		 if(!searchValue || searchValue.length==0){
			alert('Enter some text'); 
		 }
		 else{
			 $("option:selected").removeAttr("selected");
			  $("#title").empty();
			 $('#insightList').multiselect('refresh');
			 loadSearchList();
			 }
	});
	function loadSearchList(){
		 var searchValue = $('#idSearch').val(); 
		 $.ajax({
             type: "POST",
             url: "test",
     		 dataType : 'json',
	     	 data : {
	     		    "action":"1",
	    			"searchValue":searchValue
	    	 },
             success: function(result) {
				   // alert('---Node Json-'+ JSON.stringify(result, null, 4));
               var t = $("table#results tbody").empty();
          	   if(!result || result.length==0){
          		 $("#divSearchReasult").hide(); 
          		 $("#alerts").show(); 
          		 $("#graph").empty();
          		 } else {
          		      $("#divSearchReasult").show(); 
             		  $("#alerts").hide(); 
					   result.forEach(function(row) {
						var bp = row.bp;
						$("<tr><td class='bp'>" + bp + "</td></tr>").appendTo(t).click(
								function() { 
										var input = $(this).find("td.bp").text();
										 $("option:selected").removeAttr("selected");
										 $('#insightList').multiselect('refresh');
										 $("#graph").empty();
										 $("#title").text(input);
										eachItemClick(input);
									 })
							});
          		   }
            } 
     });
	 }
	 
 function eachItemClick(searchItem){
	 $.ajax({
         type: "POST",
         url: "test",
 		 dataType : 'json',
     	 data : {
     		    "action":"2",
    			"searchValue":searchItem
    	 },
         success: function(result) {
        	 treeGraph(result, "#graph");
        } 
   });
 }
 function eachItemChecklist(searchItem){
	 
	 var inp= $("#title").html();
	 alert(inp);
	 $.ajax({
         type: "POST",
         url: "test",
 		 dataType : 'json',
     	 data : {
     		    "action":"5",
    			"searchValue":inp,
    			"searchItem":searchItem.toString()
    	 },
         success: function(result) {
        	 treeGraph(result, "#graph");
        	 //forceGraph(result, "#graph");
        }
    	 });
 }
 function eachGraphNodeClick(previous,searchItem){
	 $.ajax({
         type: "POST",
         url: "test",
 		 dataType : 'json',
     	 data : {
     		    "action":"2",
    			"searchValue":searchItem
    	 },
         success: function(result) {
        	 addNewNode(previous, result.children);
        } 
   });
 }
 function forceGraph(treeData, treeContainerDom){
	 
	var width = 1200, height = 1200,root;
	var force = d3.layout.force().charge(-220).size([width, height]).on("tick", tick);
	var svg = d3.select("body").append("svg").attr("width", width).attr("height", height);
	var link = svg.selectAll(".link");
	var svg = d3.select(treeContainerDom).append("svg:svg").attr("width", width).attr("height", height);
    root = treeData;
	update();
	function update() {
	var nodes = flatten(root);
	var links = d3.layout.tree().links(nodes);
	    // Restart the force layout.
	force.nodes(nodes).links(links).linkDistance(200).start();
    var link = svg.selectAll(".link").data(links, function(d) { return d.target.id; });
	    link.enter().append("line").attr("class", "link");
	    link.exit().remove();
	var node = svg.selectAll("g.node").data(nodes)
	var groups = node.enter().append("g").attr("class", "node") .attr("id", function (d) {
	        return d.id
	    })
	        .on('click', click)
	        .call(force.drag);
	 groups.append("circle")  .attr("class","node")
	        .attr("x", -8)
	      .attr("y",-8)
	      .attr("r", function(d) { return d.children ? 10: 15 })
	      .style("fill", color)
	      .on("click", click)
	      .call(force.drag);


	    groups.append("text")
	        .attr("dx", 12)
	        .attr("dy", "0.35em")
	        .style("font-size", "15px")
	        .style("color", "#000000")
	        .style("font-family", "Arial")
	        .text(function (d) {
	        console.log(d);
	        return d.name
	    });


	    node.exit().remove();


	    force.on("tick", function () {
	        link.attr("x1", function (d) {
	            return d.source.x;
	        })
	            .attr("y1", function (d) {
	            return d.source.y;
	        })
	            .attr("x2", function (d) {
	            return d.target.x;
	        })
	            .attr("y2", function (d) {
	            return d.target.y;
	        });

	        node.attr("transform", function (d) {
	            return "translate(" + d.x + "," + d.y + ")";
	        });
	    });
	}

	function tick() {
	  link.attr("x1", function(d) { return d.source.x; })
	      .attr("y1", function(d) { return d.source.y; })
	      .attr("x2", function(d) { return d.target.x; })
	      .attr("y2", function(d) { return d.target.y; });

	  node.attr("transform", function (d) {
	            return "translate(" + d.x + "," + d.y + ")";
	        });
	}

	// Color leaf nodes orange, and packages white or blue.
	function color(d) {
	   return d._children ? "#3182bd" // collapsed package
	      : d.children ? "#c6dbef" // expanded package
	      : "#fd8d3c"; // leaf node
	}

	// Toggle children on click.
	function click(d) {
	  if (!d3.event.defaultPrevented) {
	    if (d.children) {
	      d._children = d.children;
	      d.children = null;
	    } else {
	      d.children = d._children;
	      d._children = null;
	    }
	    update();
	  }
	}

	// Returns a list of all nodes under the root.
	function flatten(root) {
	  var nodes = [], i = 0;

	  function recurse(node) {
	    if (node.children) node.children.forEach(recurse);
	    if (!node.id) node.id = ++i;
	    nodes.push(node);
	  }

	  recurse(root);
	  return nodes;
	}

	 
 }	
 
 function treeGraph(treeData, treeContainerDom){
	 var width = 700;
	 var height = 650;
	 var maxLabel = 150;
	 var duration = 500;
	 var radius = 10;
	 var i = 0;
	 var root;
	 var margin = {top: 20, right: 10, bottom: 20, left: 250};
	 var tree = d3.layout.tree()
	     .size([height, width]);

	 var diagonal = d3.svg.diagonal()
	     .projection(function(d) { return [d.y, d.x]; });
	 
	
	 d3.selectAll("svg > *").remove();
	 var svg = d3.select(treeContainerDom).append("svg")
	     .attr("width", 1200 + margin.left + margin.right)
	     .attr("height", height+ margin.top + margin.bottom)
	         .append("g")
	         .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

	
	 root = treeData;
	 root.x0 = height / 2;
	 root.y0 = 0;
	 root.children.forEach(collapse);
	 update(root);
	 function addNewNode(d, item) 
	 {
		d._children = d._children || [];
	    d._children = d._children.concat(item);
	 }

	 function update(source) 
	 {
	     // Compute the new tree layout.
	     var nodes = tree.nodes(root).reverse();
	     var links = tree.links(nodes);

	     // Normalize for fixed-depth.
	     nodes.forEach(function(d) { d.y = d.depth * maxLabel; });

	     // Update the nodes…
	     var node = svg.selectAll("g.node")
	         .data(nodes, function(d){ 
	             return d.id || (d.id = ++i); 
	                                 });

	     // Enter any new nodes at the parent's previous position.
	     var nodeEnter = node.enter()
	         .append("g")
	         .attr("class", "node")
	         .attr("transform", function(d){ return "translate(" + source.y0 + "," + source.x0 + ")"; })
	         .on("click", function(d) {
		       		click(d);
	       		if (!d._children || d._children.length === 0) {
	       		 var input = d3.select(this).text();
				 
	       		$.ajax({
	                type: "POST",
	                url: "test",
	        		 dataType : 'json',
	            	 data : {
	            		"action":"2",
	           			"searchValue":input
	           	 },
	              success: function(result) {
	            	// alert(result);
	               	 addNewNode(d, result.children);
	               	 //click(d);
	               } 
	            });
				  
	           }
	       });
	     nodeEnter.append("circle")
	         .attr("r", 5)
	          .attr("stroke", function (d) { return  d._children ? "steelblue" : "#00c13f"; 
	         });

	     nodeEnter.append("text")
	         .attr("x", function(d){ 
	             var spacing = computeRadius(d) + 5;
	             return d.children || d._children ? -15 : 15; 
	         })
	         .attr("dy", "-3")
	         .attr("text-anchor", function(d){ return d.children || d._children ? "end" : "start"; })
	         .text(function(d){ return d.name; })
	         .style("fill-opacity", 1e-6);
	     
	     /* .attr("transform", function(d) {
             return "rotate(-65)" 
             }) */

	     // Transition nodes to their new position.
	     var nodeUpdate = node.transition()
	         .duration(duration)
	         .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

	     nodeUpdate.select("circle")
	         .attr("r", function(d){ return computeRadius(d); })
	       //  .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });
	     .attr("stroke", function (d) { return  d._children ? "steelblue" : "#00c13f"; });
	     nodeUpdate.select("text").style("fill-opacity", 1);
	     
	    
	     // Transition exiting nodes to the parent's new position.
	     var nodeExit = node.exit().transition()
	         .duration(duration)
	         .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
	         .remove();

	     nodeExit.select("circle").attr("r", 5);
	     nodeExit.select("text").style("fill-opacity", 1e-6);

	     // Update the links…
	     var link = svg.selectAll("path.link")
	         .data(links, function(d){ return d.target.id; });

	     // Enter any new links at the parent's previous position.
	     link.enter().insert("path", "g")
	         .attr("class", "link")
	         .attr("d", function(d){
	             var o = {x: source.x0, y: source.y0};
	             return diagonal({source: o, target: o});
	         });
  
	     
	     // Transition links to their new position.
	     link.transition()
	         .duration(duration)
	         .attr("d", diagonal);

	     // Transition exiting nodes to the parent's new position.
	     link.exit().transition()
	         .duration(duration)
	         .attr("d", function(d){
	             var o = {x: source.x, y: source.y};
	             return diagonal({source: o, target: o});
	         })
	         .remove();
	     
	     // Update the link text
	        var linktext = svg.selectAll("g.link")
	            .data(links, function (d) {
	            return d.target.id;
	        });  
	        
	        linktext.enter()
	        .insert("g")
	        .attr("class", "link")
	        .append("text")
	        .attr("dy", ".35em")
	        .attr("stroke",  "#6C6968") 
	         .attr("style", "font-size: 12; font-family: Times New Roman")
	        .attr("text-anchor", "middle")
	        .text(function (d) {
	        //console.log(d.target.name);
	        return d.target.rel;
	    });

	    // Transition link text to their new positions

	    linktext.transition()
	        .duration(duration)
	        .attr("transform", function (d) {
	        return "translate(" + ((d.source.y + d.target.y) / 2) + "," + ((d.source.x + d.target.x) / 2) + ")";
	    })
	    
	     linktext.exit().transition()
        .remove();

	     // Stash the old positions for transition.
	     nodes.forEach(function(d){
	         d.x0 = d.x;
	         d.y0 = d.y;
	     });
	 }

	 function computeRadius(d)
	 {
	     if(d.children || d._children) return radius + (radius * nbEndNodes(d) / 10);
	     else return radius;
	 }

	 function nbEndNodes(n)
	 {
	     nb = 0;    
	     if(n.children){
	         n.children.forEach(function(c){ 
	             nb += nbEndNodes(c); 
	         });
	     }
	     else if(n._children){
	         n._children.forEach(function(c){ 
	             nb += nbEndNodes(c); 
	         });
	     }
	     else nb++;
	     
	     return nb;
	 }

	 function click(d)
	 {
		 
		 if (d.children){
	         d._children = d.children;
	         d.children = null;
	     } 
	     else{
	         d.children = d._children;
	         d._children = null;
	     }
	 
		 		     
	     update(d);
	 }

	 function collapse(d){
	     if (d.children){
	         d._children = d.children;
	         d._children.forEach(collapse);
	         d.children = null;
	     }
	 }

 }
  
	</script>
	
</body>

</html>