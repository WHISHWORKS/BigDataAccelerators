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
				
				
				<div id="graph" class="col-md-8"></div>
		
		
  </div><div class="col-sm-6 col-md-7">
  					<div id="alerts" style="display:none">No matching data found for your search result. Please try again.</div>
  </div>
<style type="text/css">

div#graph {
     margin-top:150px !important;
      margin-left:300px !important;
}
/* thead, tbody { display: block; }

tbody {
    height: 100px;       /* Just for the demo          */
    overflow-y: auto;    /* Trigger vertical scroll    */
    overflow-x: hidden;  /* Hide the horizontal scroll */
} */


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
            stroke-width: 2px;
        }

        .tree {
            margin-left: 10px;
            overflow: auto;
        }
</style>
 <script type="text/javascript" src="//code.jquery.com/jquery-1.11.0.min.js"></script>
	<script src="http://d3js.org/d3.v3.min.js" type="text/javascript"></script>
	<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
	<script type="text/javascript">
	$("#btnSearch").click(function(){
		$("#graph").empty();
		 var searchValue = $('#idSearch').val(); 
		
		 if(!searchValue || searchValue.length==0){
			alert('Enter some text'); 
		 }
		 else{
			 loadSearchList();
				
		 
		 }
	});
	
   /*  $("#searchfade").click(function(){  
        $("#results").slideToggle("slow");  
    });   */
   /*  $("#searchfade").click(function(){  
        $("#results").slideToggle("slow");  
    });   */
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
          		 /* to show no data */
          		// $("<tr><td class='bp'>" +'No data found' + "</td></tr>").appendTo(t);
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
										$("#graph").empty();
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
		
 
 function treeGraph(treeData, treeContainerDom){
	 var width = 700;
	 var height = 650;
	 var maxLabel = 150;
	 var duration = 500;
	 var radius = 10;
	 var i = 0;
	 var root;

	 var tree = d3.layout.tree()
	     .size([height, width]);

	 var diagonal = d3.svg.diagonal()
	     .projection(function(d) { return [d.y, d.x]; });
	 
	 var orientations = {
			  "top-to-bottom": {
			    size: [width, height],
			    x: function(d) { return d.x; },
			    y: function(d) { return d.y; }
			  },
			  "right-to-left": {
			    size: [height, width],
			    x: function(d) { return width - d.y; },
			    y: function(d) { return d.x; }
			  },
			  "bottom-to-top": {
			    size: [width, height],
			    x: function(d) { return d.x; },
			    y: function(d) { return height - d.y; }
			  },
			  "left-to-right": {
			    size: [height, width],
			    x: function(d) { return d.y; },
			    y: function(d) { return d.x; }
			  }
			};

	d3.selectAll("svg > *").remove();
	 var svg = d3.select(treeContainerDom).append("svg")
	     .attr("width", 1200)
	     .attr("height", height)
	         .append("g")
	         .attr("transform", "translate(" + maxLabel + ",0)");

	 root = treeData;
	 root.x0 = height / 2;
	 root.y0 = 0;

	 root.children.forEach(collapse);
	 update(root);

	 function addNewNode(d, item) {
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
		function BuildVerticaLTree(treeData, treeContainerDom) {
                var margin = { top: 40, right: 120, bottom: 20, left: 120 };
                var width = 960 - margin.right - margin.left;
                var height = 500 - margin.top - margin.bottom;

                var i = 0, duration = 750;
                var tree = d3.layout.tree()
                    .size([height, width]);
                var diagonal = d3.svg.diagonal()
                    .projection(function (d) { return [d.x, d.y]; });
                var svg = d3.select(treeContainerDom).append("svg")
                    .attr("width", width + margin.right + margin.left)
                    .attr("height", height + margin.top + margin.bottom)
                  .append("g")
                    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
                root = treeData;

                update(root);
                function update(source) {
                    // Compute the new tree layout.
                    var nodes = tree.nodes(root).reverse(),
                        links = tree.links(nodes);
                    // Normalize for fixed-depth.
                    nodes.forEach(function (d) { d.y = d.depth * 100; });
                    // Declare the nodes…
                    var node = svg.selectAll("g.node")
                        .data(nodes, function (d) { return d.id || (d.id = ++i); });
                    // Enter the nodes.
                    var nodeEnter = node.enter().append("g")
                        .attr("class", "node")
                        .attr("transform", function (d) {
                            return "translate(" + source.x0 + "," + source.y0 + ")";
                        }).on("click", nodeclick);
                    nodeEnter.append("circle")
                     .attr("r", 10)
                        .attr("stroke", function (d) { return d.children || d._children ? "steelblue" : "#00c13f"; })
                        .style("fill", function (d) { return d.children || d._children ? "lightsteelblue" : "#fff"; });
                    //.attr("r", 10)
                    //.style("fill", "#fff");
                    nodeEnter.append("text")
                        .attr("y", function (d) {
                            return d.children || d._children ? -18 : 18;
                        })
                        .attr("dy", ".35em")
                        .attr("text-anchor", "middle")
                        .text(function (d) { return d.name; })
                        .style("fill-opacity", 1e-6);
                    // Transition nodes to their new position.
                    //horizontal tree
                    var nodeUpdate = node.transition()
                        .duration(duration)
                        .attr("transform", function (d) { return "translate(" + d.x + "," + d.y + ")"; });
                    nodeUpdate.select("circle")
                        .attr("r", 10)
                        .style("fill", function (d) { return d._children ? "lightsteelblue" : "#fff"; });
                    nodeUpdate.select("text")
                        .style("fill-opacity", 1);


                    // Transition exiting nodes to the parent's new position.
                    var nodeExit = node.exit().transition()
                        .duration(duration)
                        .attr("transform", function (d) { return "translate(" + source.x + "," + source.y + ")"; })
                        .remove();
                    nodeExit.select("circle")
                        .attr("r", 1e-6);
                    nodeExit.select("text")
                        .style("fill-opacity", 1e-6);
                    // Update the links…
                    // Declare the links…
                    var link = svg.selectAll("path.link")
                        .data(links, function (d) { return d.target.id; });
                    // Enter the links.
                    link.enter().insert("path", "g")
                        .attr("class", "link")

                        .attr("d", function (d) {
                            var o = { x: source.x0, y: source.y0 };
                            return diagonal({ source: o, target: o });
                        });
                    // Transition links to their new position.
                    link.transition()
                        .duration(duration)
                    .attr("d", diagonal);


                    // Transition exiting nodes to the parent's new position.
                    link.exit().transition()
                        .duration(duration)
                        .attr("d", function (d) {
                            var o = { x: source.x, y: source.y };
                            return diagonal({ source: o, target: o });
                        })
                        .remove();

                    // Stash the old positions for transition.
                    nodes.forEach(function (d) {
                        d.x0 = d.x;
                        d.y0 = d.y;
                    });
                }

                // Toggle children on click.
                function nodeclick(d) {
                    if (d.children) {
                        d._children = d.children;
                        d.children = null;
                    } else {
                        d.children = d._children;
                        d._children = null;
                    }
                    update(d);
                }
            }

	  
	</script>
	
</body>

</html>