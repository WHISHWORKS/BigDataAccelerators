<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet"
	href="http://neo4j-contrib.github.io/developer-resources/language-guides/assets/css/main.css">
<title>Neo4j BP - TS Mapping</title>
</head>

<body>
  <form method="post" action="login">
	<div role="navigation" class="navbar navbar-default navbar-static-top">
		<div class="container">
			<div class="row">
				
				<div class="navbar-header col-sm-6 col-md-6">
					<div class="logo-well">
						<a href="http://neo4j.com/developer-resources"> <img
							src="http://neo4j-contrib.github.io/developer-resources/language-guides/assets/img/logo-white.svg"
							alt="Neo4j World's Leading Graph Database" id="logo">
						</a>
					</div>
					<div class="navbar-brand">
						<div class="brand">Screen To Service Mapping</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div  id="graph"></div>
	<div class="row">
	<div class="col-sm-6 col-md-7">
					<ul class="nav navbar-nav">
						<li>
							<form role="search" class="navbar-form" id="search">
								<div class="form-group">
									<input type="text" value="service"
										placeholder="Search for Result" class="form-control" name="search">
								</div>
								<button id="btn_search" onclick="" type="submit">Search</button>
							</form>
						</li>
					</ul>
				</div>
		<div class="col-md-4">
			<div class="panel panel-default">
				<div class="panel-heading">Search Results</div>
				<table id="results" class="table table-striped table-hover">
					<thead>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div>
		</div>
  </div>
	</form>	
<style type="text/css">

div#graph {
     margin-top:150px !important;
      margin-left:50px !important;
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
            stroke-width: 2px;
        }

        .tree {
            margin-left: 10px;
            overflow: auto;
        }
</style>

 <script type="text/javascript" src="//code.jquery.com/jquery-1.11.0.min.js"></script>
	<script src="http://d3js.org/d3.v3.min.js" type="text/javascript"></script>
	<script type="text/javascript">
	 $(function() {
			function showOrg(name) {
				$.get("/bp/" + encodeURIComponent(name), function(data) {
					if (!data)
						return;
					$("#name").text(data.name);
					var list = $("table#details tbody").empty();
					data.cast1.forEach(function(cast1) {
  					   $("<tr><td class='chilnodes'>" + data.name + "</td><td>" + cast1.name + "</td></tr>").appendTo(list)
					});
				}, "json");
				return false;
			}
       
	     $("#search").submit(search);
         search();
	   function search() {
     		var query = $("#search").find("input[name=search]").val();
			$.get("/search?q=" + encodeURIComponent(query),	
					function(data) {
			      			var t = $("table#results tbody").empty();
							if (!data || data.length == 0)
								{
								
								$("#graph").empty();

								return $("<tr><td class='bp'>" +'No data found' + "</td></tr>").appendTo(t);
			}else{
							data.forEach(function(row) {
									var bp = row.bp;
									$("<tr><td class='bp'>" + bp.name + "</td></tr>").appendTo(t).click(
											function() { 
													//d3.selectAll("svg > *").remove();
													var input = $(this).find("td.bp").text();
													//alert(input);
													$("#graph").empty();
													d3.json("/bp/"+ encodeURIComponent(input),
															function(error,graph) {
														          if (error)
																	 return;
													//alert('Enter');
													
													treeGraph(graph, "#graph");														          
														
																});

												 })
										});}
					}, "json");
				return false;
			}
		})
		
		
		
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
		     .attr("width", width)
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
					 
					// alert(input);

					  d3.json("/bp/"+ encodeURIComponent(input),
		       			     function(error,graph) {
		       		 if (error)
						  return;
		       		 
		       		
		             addNewNode(d, graph.children);
			       		
		       		  
		       	  });
					  
					  
		           }
		       		

		                   
		       });
		     nodeEnter.append("circle")
		         .attr("r", 5)
		         .style("fill", function(d){ 
		             return d._children ? "lightsteelblue" : "white"; 
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

		     // Transition nodes to their new position.
		     var nodeUpdate = node.transition()
		         .duration(duration)
		         .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

		     nodeUpdate.select("circle")
		         .attr("r", function(d){ return computeRadius(d); })
		         .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });

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

		
		function addEndSystem(input,graph){
		  
		 // alert('input'+ input);
		  totalNodes = force.nodes();
		  totalLinks = force.links();
		  for ( x = 0; x < graph.nodes.length; x++ ) {
		    	var found = false;
			    for ( y = 0; y < totalNodes.length; y++ ) {
			    	if (totalNodes[y].name.localeCompare(graph.nodes[x].name) == 0) {
			    		found = true;
			    		alert(found);
			    	}
			    }
			    if (found == false)
			    {
			    	alert('found false');
			     	totalNodes.push(graph.nodes[x]);
			    	nodeHash['graph.nodes[x].name'] = totalNodes.length - 1;
				    alert('---Node Json-'+ JSON.stringify(totalNodes, null, 4));
		    	  	    	   
			    }
			    
			    
		 }
		  
		  for ( x = 0; x < graph.links.length; x++ ) {
		    	var found = false;
			    for ( y = 0; y < totalLinks.length; y++ )
			    {
			    	alert('In Links   '+totalLinks[y].targetName+'---compare with-'+graph.links[x].targetName);
			    	if (totalLinks[y].targetName.localeCompare(graph.links[x].targetName) == 0) {
			    		found = true;
			    		break;
			    	}
			    }
			    if (found == false)
			    {
			      totalLinks.push({source: findNodeIndex(input) ,target: findNodeIndex(graph.links[x].targetName),sourceName: graph.links[x].sourceName,targetName: graph.links[x].targetName});
				  alert('---LINk Json-'+ JSON.stringify(totalLinks, null, 4));
			    }
		    } 
		  
		  restart();
	}
	  
	  
	  function  findNodeIndex(value) {
          for (var i = 0; i < totalNodes.length; i++) {
              if (totalNodes[i].name.localeCompare(value) == 0) {
                  return i;
              }
          };
      };

	  function restart(){
		  	 alert('restart called'+ totalLinks.length + '-------'+ totalNodes.length);
		  //	d3.selectAll("svg > *").remove(); 
		  	var alertText = ' ';
		  	for(property in totalLinks){
		  		alertText = 'alertText' + property + '---- ';
		  		var data = ' ';
		  		for(property1 in totalLinks[property]){
		  			data = data + totalLinks[property][property1];
		  		}
		  		alert(alertText + '--' + data);
		  	}
			  var colors = d3.scale.category10();

			 var link = svg.selectAll(".link").data(totalLinks);
			 link.enter().insert("line", ".node").append("line").attr("class","link").style("stroke", "#ccc").style("stroke-width", 1);
			 link.exit().remove();
			 var node = svg.selectAll(".node").data(totalNodes);
			 node.enter().append("g").attr("class",	
					                   function(d) {
											 return "node "+ d.label
										}).call(force.drag);
			  node.append("circle").attr("r",20).style("fill", function (d, i) { return colors(i); });
			  node.append("text").attr("x",12).attr("dy",".35em").text(
													function(d) {
														return d.name;
													});
			 node.exit().remove();

	   		  force.nodes(totalNodes).links(totalLinks).start();

                force.on("tick",function() {
           	        link.attr("x1",function(d) {
           	    	              return d.source.x;
			           }).attr(	"y1",function(d) {
								      return d.source.y;
					   }).attr("x2",function(d) {
									  return d.target.x;
					   }).attr("y2",function(d) {
									  return d.target.y;
					  }); 
			          node.attr("transform",function(d) {
									  return "translate("+ d.x + "," + d.y + ")";
					  });
			  });  
                
                

				  }
	  
	  
	</script>
	
</body>
</html>
