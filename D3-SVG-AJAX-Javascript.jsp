<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
    <head>
        <style>
            .node {
                stroke: #fff;
                stroke-width: 0.1px;
            }
            .link {
                stroke: #999;
                stroke-opacity: .6;
            }
            path {
                cursor: pointer;
            }
            path:hover
            {
                opacity: 0.3;
            }

        </style>
        <title>Entity-relation explorer by Md. Rashadul Hasan Rakib(B00598853)</title>
        <script type="text/javascript" src="d3.v3.min.js"></script>
        <script type="text/javascript">
            var xmlhttp;
            var result;
            var maxRecords=8;
            var color = d3.scale.category20();
            var arcEntityNameYOffest=20;
            var arcTextHeight=20;
            var ind=-1;
            var mulFactorOfOuterRadius=5;
            //use color array to color group by group index

            function getOutput()
            {
                if (xmlhttp.readyState==4)
                {
                    result=xmlhttp.responseText.replace(/^\s+/, '').replace(/\s+$/, '');
                    //document.write(result);
                    //alert(result);
                    if(result.length>0){
                        nodes.push(createjsonnode(document.getElementById("txt_QE").value,result,++ind));
                         
                    }
                    else{
                        alert("Sorry! The entity is not in database...");
                    }
                    
                   start(charsize);
                    
                }
            }

            function getXmlHttpObject()
            {
                if (window.XMLHttpRequest)
                {
                    return new XMLHttpRequest();
                }
                if (window.ActiveXObject)
                {
                    return new ActiveXObject("Microsoft.XMLHTTP");
                }
                return null;
            }
            
            function getResultFromServer(){
                
                var txt_QE=document.getElementById("txt_QE");
                xmlhttp=getXmlHttpObject();
                if(xmlhttp!=null){
                    var url="http://localhost:8080/MCSWeb/processRequest.jsp?qe=" + txt_QE.value+"&maxRecords="+maxRecords;
                    url=url.replace(/ /g,"_");
                    //alert(url); 
                    

                    xmlhttp.onreadystatechange=getOutput;
                    xmlhttp.open("GET",url,true);
                    xmlhttp.send(null);
                    
                }
                
                //alert(txt_QE.value);
            }
        </script>
    </head>
    <body>
    <center>
        <table>
            <!--<form action="visproject-B00598853.jsp" method="GET">-->
            <tr>
                <td>
                    <span>Query Entity:</span>
                </td>
                <td>
                    <input type="text" id="txt_QE" name="txt_QE" />            
                </td>
            </tr>
            <tr>
                <td>
                    <!--<% out.print(request.getParameter("txt_QE"));%>-->
                </td>
                <td>
                    <input type="button" value="Visualize relations" onclick="javascript:getResultFromServer();" />
                </td>

            </tr>
            <!--</form>-->
            <tr>
                <td colspan="2">


                    <script type="text/javascript">
                        window.width
                        //var width = 2400, height = 1200, xoffset=20, yoffset=20;
                        //var width = window.innerWidth, height = window.innerHeight*2, xoffset=20, yoffset=20;
                        var width = document.body.clientWidth, height = window.innerHeight, xoffset=20, yoffset=20;
			
                        var nodes=[];
                        var links=[];
			
                        var force = d3.layout.force()
                        .nodes(nodes)
                        .links(links)
                        .charge(-100)
                        .linkDistance(500)
                        .gravity(.01)
                        .size([width, height])
                        .on("tick",tick);
			
                        var svg = d3.select("body").append("svg")
                        .attr("width", width)
                        .attr("height", height);
			
                        var node = svg.selectAll(".node");
                        var link = svg.selectAll(".link");
			
                        var charsize=8;
                        			
                        function start(charsize) {
							
                            var ls=link.data(force.links())
                            .enter().append("svg").append("svg:g");
				
                            link = ls.append("line").attr("class", "link").attr("id",function(d) {return d.id;})
                            .style("stroke-width", function(d) { return Math.sqrt(d.value); });
				
                            link.append("title")
                            .text(function(d) { return d.label; });
				
                            node = node.data(force.nodes())
                            .enter().append("svg").append("svg:g").attr("id",function(d,i){return i;})
                            .attr("transform", function(d,i){ return "translate("+(d.totalchars*i*5+200*i)+","+(d.totalchars*i*5+200*i)+")";})
                            .call(force.drag);
                            
                            node.each(function(d,i){
                                var nd = d3.select(this);
                                //console.log(nd);
                                var ndId= i;
                                
                                var circleText= nd.append("text")//.attr("transform", "rotate(180)" )
                                .attr("text-anchor", "middle");
                                
                                var qewords= d.queryentity.split(" ");
                                for(var j=0;j<qewords.length;j++){
                                    circleText.append("svg:tspan").attr("x",0).attr("y",j*15).text(qewords[j]);
                                }
                                
                                var circle = nd.append("circle")
                                .attr("class", "node")
                                .style("fill", "white")
                                .append("title")
                                .text(function(d) { return d.queryentity; });
                                
                                var bbox = circleText.node().getBBox();
                                var radius = bbox.width/2+10;
                              
                                circle.attr("r", radius);
                                
                                var noOfOtherEntities=0;
                                
                                var groupsInANode = nd.selectAll("g").data(function (d) { noOfOtherEntities=d.otherentities.length; return d.otherentities; })                       
                                .enter().append("svg:g");
                                 
                                //console.log(noOfOtherEntities);
                                 
                                var startangle=0;
                                var endangle=0;
                                var prevPath=null;
                                var originalPath=null;
                                
                                var hg =  {};
                                var hgMemberCount = {};
                                var hgCommonCW = {};
                                
                                var dAttrs = {};
                                var reversedPathIndexes= {};
                                var totalPaths =0;
                                var startendangles= {};
                                
                                groupsInANode.each(function (d,j){
                                    //console.log(d.color+":"+hg[d.color]); commoncontextwords
                                    //console.log(j);
                                    totalPaths=totalPaths+1;
                                    if(hg[d.color]==undefined && hgMemberCount[d.color]==undefined){
                                        hg[d.color]=startangle;
                                        hgMemberCount[d.color]=1;
                                    }
                                    else{
                                        hgMemberCount[d.color]=hgMemberCount[d.color]+1;
                                    }
                                    
                                    if(hgCommonCW[d.color]==undefined){
                                        hgCommonCW[d.color]=d.commoncontextwords;
                                    }
                                        
                                        
                                        
                                    //if(j<noOfOtherEntities/2){
                                    var aGroup = d3.select(this);
                                    var grID=j;
                                    var path=aGroup.append("svg:path")
                                    .attr("id","node"+ndId+"path"+grID)
                                    .attr("fill", function(d) { return d.color } )
                                    .attr("stroke", "white").attr("stroke-width", 0.5)
                                    .on("click",function(d){
										
                                        svg.remove();
                                        svg = d3.select("body").append("svg")
                                        .attr("width", width)
                                        .attr("height", height);
			
                                        node = svg.selectAll(".node");
                                        link = svg.selectAll(".link");
				
                                        var txt_QE=document.getElementById("txt_QE");
                                        xmlhttp=getXmlHttpObject();
                                        if(xmlhttp!=null){
                                            var url="http://localhost:8080/MCSWeb/processRequest.jsp?qe=" + d.ename+"&maxRecords="+maxRecords;
                                            url=url.replace(/ /g,"_");
                                    
                                            var parentNodeID=parseInt(this.parentNode.parentNode.id);
                                            xmlhttp.onreadystatechange=function ()
                                            {
                                                if (xmlhttp.readyState==4)
                                                {
                                                    result=xmlhttp.responseText.replace(/^\s+/, '').replace(/\s+$/, '');
                                                    console.log("res:"+result);
                                                    //alert(result);
                                                    
                                                    if(result.length>0){
                                                        nodes.push(createjsonnode(d.ename,result,++ind)); 
                                                        links.push(createjsonlink(parentNodeID,ind,d.queryentity,d.ename)); 
                                                        
                                                    }
                                                    else{
                                                        alert("Sorry! The entity is not in database...");
                                                    }
                                                    			
                                                    start(charsize);
                                                }
                                            }
                                            xmlhttp.open("GET",url,true);
                                            xmlhttp.send(null);

                                        }
                                    });
                                    
                                    var coreArc = d3.svg.arc()
                                    .innerRadius(radius)
                                    .outerRadius(function(d){	
                                        return d.arcchars*mulFactorOfOuterRadius;
                                    }
                                )
                                    .startAngle(startangle)
                                    .endAngle(function(d) {
                                        endangle= startangle+ Math.PI*2*d.arcchars/d.totalchars;
                                        
                                        return endangle;
                                    });
                                    
                                    path.attr("d", coreArc);
                                    path.append("title")
                                    .text(function(d) { return d.ename+":"+d.contextwords; });
                                    
                                    originalPath=path.attr("d");
                                    
                                    var reverseFactor=1;
                                    var ondDegree =  0.0174532925; //rad
                                    
                                    if(startangle>=Math.PI/2-ondDegree*5 && startangle<3*Math.PI/2-ondDegree*20){
                                        
                                        reversedPathIndexes[j]="some value";
                                        
                                        //reverseFactor=-1;
                                        var prevPathArr;
                                        if(prevPath!=null){
                                            var tempprevPathArr=((prevPath.split("L")[1]).split("A")[0]);
                                            prevPathArr=tempprevPathArr.replace(/,/g," ").split(" ");
                                            //console.log(prevPath+":"+prevPathArr);
                                        }
                                        
                                        var pathDAttr=path.attr("d").toString().replace(/M/g,"").replace(/Z/g,"").split("L")[0].split("A");
                                        
                                        //console.log(pathDAttr[0]+":"+pathDAttr[1]);
                                        var numbersOFFirstStr= pathDAttr[0].replace(/,/g," ").split(" ");
                                        //console.log(numbersOFFirstStr);
                                        
                                        var numbersOFSecondStr= pathDAttr[1].replace(/,/g," ").split(" ");
                                        //console.log(numbersOFSecondStr);
                                        
                                        var oldPathOfInnerArc = path.attr("d").toString().split("A")[2].replace(/Z/,"").replace(/,/g," ");
                                        //var prevInnerArcArr = prevPath.toString().split("A")[2].replace(/Z/,"").replace(/,/g," ").split(" ");
                                        //console.log(prevInnerArcArr);
                                        
                                        
                                        var dAttr= "M "+numbersOFSecondStr[numbersOFSecondStr.length-2]+" "
                                            +numbersOFSecondStr[numbersOFSecondStr.length-1]+" A "
                                            +numbersOFSecondStr[0]+" "+numbersOFSecondStr[1]+" 0 0 0 "+numbersOFFirstStr[0]+" "+numbersOFFirstStr[1]
                                            +" L " +prevPathArr[0]+" "+ prevPathArr[1] 
                                            +" A "+oldPathOfInnerArc; //add as a garbage
        
                                            
                                        /*var dAttr= "M "+numbersOFSecondStr[numbersOFSecondStr.length-2]+" "
                                            +numbersOFSecondStr[numbersOFSecondStr.length-1]+" A "
                                            +numbersOFSecondStr[0]+" "+numbersOFSecondStr[1]+" 0 0 0 "+numbersOFFirstStr[0]+" "+numbersOFFirstStr[1]
                                            +" L " +prevPathArr[0]+" "+ prevPathArr[1] +" A "
                                            + prevInnerArcArr[0]+ " "+ prevInnerArcArr[1]+ " 0 0 1 "
                                            + prevInnerArcArr[prevInnerArcArr.length-1] +" "
                                            + prevInnerArcArr[prevInnerArcArr.length-2]
                                            + " Z";   */ 
                                        //console.log(dAttr);
                                        
                                        path.attr("d",dAttr);
                                        
                                        
                                        /*var txt = aGroup.append("text");
                                        //.attr("transform", "rotate(180)" );
                                       
                                        //var tpath;    
                                  
                                        var tpathQE=txt.append("textPath")
                                        .attr("xlink:href", "#node"+ndId+"path"+grID);
                                        //.attr("textLength","15%");
                                        //}
                                        var eHeight=0; 
                                        var enws = d.ename.split(" ");
                                        for(var k=enws.length-1;k>=0;k--){
                                            var dy = (k==0)?arcEntityNameYOffest:15;
                                            tpathQE.append("svg:tspan").attr("x",5).attr("font-size",charsize*2.3)
                                            //.attr("text-anchor", "middle")
                                            .attr("dy",reverseFactor*dy)
                                            .text(enws[k])
                                            eHeight=eHeight+dy;
                                        }
                                    
                                        var tpathOE=txt.append("textPath")
                                        .attr("xlink:href", "#node"+ndId+"path"+grID)
                                        .attr("textLength","9.3%");
                                        
                                        var cws = d.contextwords.split(",");
                                        for(var k=0;k<cws.length;k++){
                                            var dy = (k==0)?arcEntityNameYOffest:15;
                                            tpathOE.append("svg:tspan").attr("x",5).attr("font-size",charsize*2.1)
                                            //.attr("text-anchor", "middle")
                                            //.attr("font-family","monospace")
                                            .attr("dy",reverseFactor*dy)
                                            .text(cws[k]);
                                        }*/
                                        
                                        //thin border
                                        /*aGroup.append("svg:path").attr("fill", "white" )
                                        .attr("stroke", "white").attr("stroke-width", 0.1)
                                        .attr("d", d3.svg.arc()
                                        .innerRadius(d.arcchars*mulFactorOfOuterRadius-eHeight-5)
                                        .outerRadius(d.arcchars*mulFactorOfOuterRadius-eHeight+1-5)
                                        .startAngle(startangle)
                                        .endAngle(endangle)
                                    );*/
                                        
                                    }
                                    else{
                                          
                                        var txt = aGroup.append("text");
                                        //.attr("transform", "rotate(180)" );
                                       
                                        //var tpath;    
                                  
                                        var tpathQE=txt.append("textPath")
                                        .attr("xlink:href", "#node"+ndId+"path"+grID);
                                        //.attr("textLength","15%");
                                        //}
                                        var eHeight=0; 
                                        /*var enws = d.ename.split(" ");
                                        for(var k=0;k<enws.length;k++){
                                            var dy = (k==0)?arcEntityNameYOffest:15;
                                            tpathQE.append("svg:tspan").attr("x",5).attr("font-size",charsize*2.3)
                                            //.attr("text-anchor", "middle")
                                            .attr("dy",reverseFactor*dy)
                                            .text(enws[k])
                                            eHeight=eHeight+dy;
                                        }*/
        
                                        var dy = arcEntityNameYOffest;
                                        tpathQE.append("svg:tspan")
                                        .attr("x",5)
                                        .attr("font-size",charsize*2.3)
                                        //.attr("text-anchor", "middle")
                                        .attr("dy",reverseFactor*dy)
                                        .text(d.ename)
                                        
                                        eHeight=eHeight+dy;
                                    
                                    
                                        var textLength=10;
                                        
                                        var angleDiff= Math.abs(startangle-endangle);
                                        if(angleDiff>1){
                                            textLength=18;
                                        }
                                    
                                        var tpathOE=txt.append("textPath")
                                        .attr("xlink:href", "#node"+ndId+"path"+grID)
                                        .attr("textLength",(angleDiff*textLength)+"%");
                                        console.log("diff:"+angleDiff);
                                        
                                        var cws = d.contextwords.split(",");
                                        for(var k=0;k<cws.length;k++){
                                            var dy = (k==0)?arcEntityNameYOffest:15;
                                            tpathOE.append("svg:tspan").attr("x",5).attr("font-size",charsize*2.1)
                                            //.attr("text-anchor", "middle")
                                            //.attr("font-family","monospace")
                                            .attr("dy",reverseFactor*dy)
                                            .text(cws[k]);
                                        }
                                        
                                        //thin border
                                        aGroup.append("svg:path").attr("fill", "white" )
                                        .attr("stroke", "white").attr("stroke-width", 0.1)
                                        .attr("d", d3.svg.arc()
                                        .innerRadius(d.arcchars*mulFactorOfOuterRadius-eHeight-5)
                                        .outerRadius(d.arcchars*mulFactorOfOuterRadius-eHeight+1-5)
                                        .startAngle(startangle)
                                        .endAngle(endangle)
                                    );
                                        
                                    }
                                    
                                    
                                    dAttrs[j]= path.attr("d");
                                    console.log(dAttrs[j]);
                                    
                                    prevPath = originalPath;
                                    startendangles[j]=startangle+";"+endangle;
                                    
                                    startangle=endangle;
                                    //}
                                 
                                });
                                
                                //second time to draw special reverse path
                                groupsInANode.each(function (d,j){
                                   
                                   
                                    if(reversedPathIndexes[j]!=undefined){
                                        var reverseFactor=-1;
                                        var grID=j;
                                        var aGroup = d3.select(this);
                                        var aFirstPath=aGroup.select("path");
                                        
                                        var nextPathIndex = (j+1)%totalPaths;
                                        
                                        var nextPathAttrs = dAttrs[nextPathIndex].split("L")[1].replace(/A/g," ").replace(/Z/g," ").replace(/,/g," ")
                                        .replace(/^\s+/, '').replace(/\s+$/, '').split(" "); //line attrs of large arc 
                                        
                                        var parts=aFirstPath.attr("d").toString().split("A");
                                        var outerArcWithLine=parts[0]+" A "+ parts[1];
                                        var innerPathsAttrs=parts[2].replace(/^\s+/, '').replace(/\s+$/, '').split(" ");
                                        var newpath=outerArcWithLine
                                            +" A "+innerPathsAttrs[0]+" "+innerPathsAttrs[1]+" 0  0 1 "+nextPathAttrs[0]+" "+nextPathAttrs[1]+" Z";
                                        //console.log("newpath:"+newpath);
                                        aFirstPath.attr("d", newpath);
                                        
                                        var txt = aGroup.append("text");
                                        //.attr("transform", "rotate(180)" );
                                       
                                        //var tpath;    
                                  
                                        var tpathQE=txt.append("textPath")
                                        .attr("xlink:href", "#node"+ndId+"path"+grID);
                                        //.attr("textLength","15%");
                                        //}
                                        var eHeight=0; 
                                        /*var enws = d.ename.split(" ");
                                        for(var k=enws.length-1;k>=0;k--){
                                            var dy = (k==0)?arcEntityNameYOffest:15;
                                            tpathQE.append("svg:tspan")
                                            .attr("x",15)
                                            .attr("font-size",charsize*2.3)
                                            //.attr("text-anchor", "middle")
                                            .attr("dy",reverseFactor*dy+12+(enws.length-1-k)*-2)
                                            .text(enws[k])
                                            eHeight=eHeight+dy;
                                        }*/
                                        
                                        var dy = arcEntityNameYOffest;
                                        tpathQE.append("svg:tspan")
                                        .attr("x",15)
                                        .attr("font-size",charsize*2.3)
                                        //.attr("text-anchor", "middle")
                                        .attr("dy",reverseFactor*dy+12)
                                        .text(d.ename)
                                        
                                        eHeight=eHeight+dy;
                                        
                                        var textLength=20;
                                        
                                        var angleDiff= Math.abs(startangle-endangle);
                                       
                                        var tpathOE=txt.append("textPath")
                                        .attr("xlink:href", "#node"+ndId+"path"+grID)
                                        //.attr("textLength","20%");
                                        .attr("textLength",(angleDiff*textLength+10)+"%");
                                    
                                        var cws = d.contextwords.split(",");
                                        for(var k=0;k<cws.length;k++){
                                            var dy = (k==0)?arcEntityNameYOffest:15;
                                            tpathOE.append("svg:tspan")
                                            .attr("x",15)
                                            .attr("font-size",charsize*2.1)
                                            //.attr("text-anchor", "middle")
                                            //.attr("font-family","monospace")
                                            .attr("dy",reverseFactor*dy)
                                            .text(cws[k]);
                                        }
                                        
                                        //thin border
                                        //console.log(startendangles[j].split(";")[0]);
                                        aGroup.append("svg:path").attr("fill", "white" )
                                        .attr("stroke", "white").attr("stroke-width", 0.1)
                                        .attr("d", d3.svg.arc()
                                        .innerRadius(d.arcchars*mulFactorOfOuterRadius-eHeight-1)
                                        .outerRadius(d.arcchars*mulFactorOfOuterRadius-eHeight-2)
                                        .startAngle(parseFloat(startendangles[j].split(";")[0]))
                                        .endAngle(parseFloat(startendangles[j].split(";")[1]))
                                    );
                                        
                                        
                                    }
                                   
                                });
                               
                                
                                //create arc for centroid for a group inside a node    
                                //console.log(hg+":"+hg.length);
                                var hgkeys = []; 
                                //var centroid=
                                for(var key in hg){
                                    //console.log(key);
                                    
                                    hgkeys.push(key);
                                }
                                //console.log(hgkeys.length);
                                
                                //for(var k=0;k<)
                                //create common arc for centroid
                                for(var k=0;k<hgkeys.length;k++){
                                    var sa = hg[hgkeys[k]];
                                    var ea = ((k+1)<hgkeys.length)?hg[hgkeys[k+1]]:2*Math.PI;
                                    //console.log("sa="+sa+" ea="+ea);
                                    console.log(hgCommonCW[hgkeys[k]].length);
                                    if(hgMemberCount[hgkeys[k]]>1 && hgCommonCW[hgkeys[k]].length>0 ){
                                        nd.append("svg:path").attr("fill", "white" )
                                        .attr("stroke", "white").attr("stroke-width", 0.1)
                                        .attr("d", d3.svg.arc()
                                        .innerRadius(radius+22)
                                        .outerRadius(radius+23)
                                        .startAngle(sa)
                                        .endAngle(ea)
                                    );
                                        
                                        nd.append("svg:path").attr("fill", hgkeys[k] )
                                        .attr("id","node"+ndId+"group"+k) //use k as group no
                                        .attr("d", d3.svg.arc()
                                        .innerRadius(radius)
                                        .outerRadius(radius+22)
                                        .startAngle(sa)
                                        .endAngle(ea)
                                    );
                                        
                                        var textLength=5;
                                        switch(hgCommonCW[hgkeys[k]].length)
                                        {
                                            case 1:
                                            case 2:
                                                textLength=2;
                                                break;
                                            case 3:
                                            case 4:
                                                textLength=3;
                                                break;
                                            case 5:
                                            case 6:
                                                textLength=4;
                                                break;
                                            default:
                                                textLength=5;
                                        }
                                        
                                        var centroidAngleDiff = Math.abs(sa-ea);
                                        var startoffset= Math.abs(centroidAngleDiff/2);
                                        
                                        var arcTextOfCentroid = nd.append("text").attr("text-anchor", "middle").attr("font-size",charsize*2.2);
                                        var arcTextPathOfCentroid = arcTextOfCentroid.append("textPath")
                                        .attr("xlink:href", "#node"+ndId+"group"+k)
                                        .attr("startOffset", startoffset*20+"%")
                                        .attr("textLength",textLength+"%");
                                        
                                        //.attr("dy",20)
                                        //.text(hgCommonCW[hgkeys[k]]); //monospace
                                        arcTextPathOfCentroid.append("svg:tspan").attr("dy",15).text(hgCommonCW[hgkeys[k]]);
                                    }
                                }
                                                               
                            });
                            						
                            force.start();
                        }
                        
                        function tick() {
				
                            link.attr("x1", function(d) { return d.source.x; })
                            .attr("y1", function(d) { return d.source.y; })
                            .attr("x2", function(d) { return d.target.x; })
                            .attr("y2", function(d) { return d.target.y; });
				
                            node.attr("transform", function(d){ return "translate("+d.x+","+d.y+")"; });
                        }
			
                        /*function angle(sa,ea) {
                            var a = (sa + ea) * 90 / Math.PI - 90;
                            return a > 90 ? a - 180 : a;
                        }*/
			
                        function createjsonnode(QEntity,result,index){
			    
                            var allRows = result.split(";");
                            //alert(result);
                            
                            var rows = (allRows.length>maxRecords)?maxRecords:allRows.length;
                            
                            //var totalChars=0;
                            var totalMaxWidth = 0;
                            var maxWidthOfWordsInAnArc = [];
                            for(var i=0;i<rows;i++){
                               
                                var columnValues = allRows[i].split("|");
                                
                                var maxWidth=columnValues[5].length+columnValues[1].length;
                                //console.log(maxWidth);
                                maxWidthOfWordsInAnArc.push(maxWidth);
                                totalMaxWidth=totalMaxWidth+maxWidth;
                            }
                            
                            //console.log(totalMaxWidth);
                            
                            var jsonNode ='{"index":'+ index.toString()+', "totalchars": '+totalMaxWidth.toString()+',"queryentity": "'+QEntity+'", "otherentities": [';
                            
                            var nodes='';
                            for(var i=0;i<rows;i++){
                                var singleRow = allRows[i];
                                var allColumns = singleRow.split("|");
                                var columns=allColumns.length;
                               
                                var grNo = allColumns[columns-1].match(/\d/g);
                               
                                var node='{ "ename": "'+allColumns[1]+'", "color": "'+color(grNo)+'",'
                                    +'"commoncontextwords": "'+allColumns[4]+'",' 
                                    +'"contextwords": "'+allColumns[5]+'", "queryentity": "'+QEntity+'","totalchars": '+totalMaxWidth.toString()
                                    +', "arcchars": '+maxWidthOfWordsInAnArc[i]+'}';
                                if(i==0){
                                    nodes=node;
                                } else{
                                    nodes=nodes+","+node;
                                }
                            }
                            jsonNode=jsonNode+nodes+']}';
                            //alert(jsonNode);
                          	   
                            return eval('(' + jsonNode + ')');
                        }
			
                        function createjsonlink(sindex,tindex,sE,tE){
                            var l=
                                {
                                "source": sindex,
                                "target": tindex,
                                "value": 5,
                                "label": "From "+sE+" To "+tE,
                                "id": "line"+sindex.toString()+tindex.toString()
                            };
				
                            return l;
                        }
			
                    </script>
                </td>
            </tr>
        </table> 
    </center>
</body>
</html>
