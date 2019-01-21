<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%-- ======= #26. tiles2 중 sideinfo 페이지 만들기  ======= --%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 차트그리기 --> 
<script src="https://code.highcharts.com/highcharts.js"></script>
<script src="https://code.highcharts.com/modules/data.js"></script>
<script src="https://code.highcharts.com/modules/drilldown.js"></script>

<script type="text/javascript">
	var weatherTimeCycle = 0; // 시간주기를 잡아주는 전역변수; 단위 밀리초
	
	$(document).ready(function() {
		loopshowNowTime();	// 현재 시각 출력하기
		
		// #매 30분 0초가 될 때마다 기상청 날씨 정보를 자동 갱신 
		var now = new Date();
		var minute = now.getMinutes();
		
		if(minute < 30){	// 현재시각 0분~29분 사이일 때
			weatherTimeCycle = (30-minute)*60*1000; // 0분일 때 30분 / 5분일 때 25분
		}
		else if(minute == 30){ // 30분일 때
			weatherTimeCycle = 1000;
		}
		else { // 31분~59분일 떄
			weatherTimeCyle = (((60-minute))+30)*60*1000;
		}
		loopshowWeather();	// 기상청 날씨정보 공공API XML데이터 호출
//		showRank();
	}); // end of ready(); ---------------------------------

	function showNowTime() {
		
		var now = new Date();
		
		var strNow = "";
		var mon = now.getMonth() + 1;
		if(mon < 10){
			strNow = now.getFullYear() + "-0" + mon + "-" + now.getDate();
		}
		else{
			now.getFullYear() + "-" + mon + "-" + now.getDate();
		}
		
		var hour = "";
	    if(now.getHours() >= 12) {
	    	hour = "오후 " + (now.getHours() - 12); 
	    } 
	    else {
	    	hour = "오전 " + now.getHours();
	    }
		
		var minute = "";
		if(now.getMinutes() < 10) {
			minute = "0"+now.getMinutes();
		} else {
			minute = now.getMinutes();
		}
		
		var second = "";
		if(now.getSeconds() < 10) {
			second = "0"+now.getSeconds();
		} else {
			second = now.getSeconds();
		}
		
		strNow += " "+hour + ":" + minute + ":" + second;
		
		$("#clock").html("<span style='color:green; font-weight:bold;'>"+strNow+"</span>");
	
	}// end of function showNowTime() -----------------------------


	function loopshowNowTime() {
		showNowTime();
		
		var timejugi = 1000;   // 시간을 1초 마다 자동 갱신하려고.
		
		setTimeout(function() {
						loopshowNowTime();	
					}, timejugi);
		
	}// end of loopshowNowTime() --------------------------
	
	
// [190121]
// #기상청 날씨정보 공공API XML 데이터 호출하기
	function showWeather(){
		$.ajax({
			url: "<%= request.getContextPath() %>/weatherXML.action",
			type: "GET",
			dataType: "XML",
			success: function(xml){
				var rootElement = $(xml).find(":root");
				// console.log($(rootElement).prop("tagName"));
				// >> 최상위 루트의 태그명: current
				
				var weather = $(rootElement).find("weather");
				// console.log($(weather).attr("year")+"년 "+$(weather).attr("month")+"월 "+$(weather).attr("day")+"일 "+$(weather).attr("hour")+"시");
				// >> 2019년 01월 21일 10시
				
				var updateTime = $(weather).attr("year")+"년 "+$(weather).attr("month")+"월 "+$(weather).attr("day")+"일 "+$(weather).attr("hour")+"시";
				
				var localArr = $(rootElement).find("local");	// local 태그 정보 가져오기
				// console.log("localArr.length: "+localArr.length);
				// >> localArr.length: 95
				
				var html = "업데이트: <span style='font-weight: bold; '>"+updateTime+"</span>&nbsp;&nbsp;&nbsp;";
				html += "<span class='btn btn-info' onClick='javascript:showWeather();'>update</span><br/>";
				html += "<table class='table table-hover' align='center'>";
				html += "<tr>";
				html += "<th>지역</th>";
				html += "<th>날씨</th>";
				html += "<th>기온</th>";
				html += "</tr>";
				

				for(var i=0; i<localArr.length; i++){
					var local = $(localArr).eq(i);
					/* .eq(index) 는 선택된 요소들을 인덱스 번호로 찾을 수 있는 선택자이다. 
	           		 마치 배열의 인덱스(index)로 값(value)를 찾는 것과 같은 효과를 낸다.
	   				*/
	   				/* console.log($(local).text() 
	   							+ " stn_id:" + $(local).attr("stn_id") 
	   							+ " icon:" + $(local).attr("icon") 
	   							+ " desc:" + $(local).attr("desc") 
	   							+ " ta:" + $(local).attr("ta") ); */
					html+="<tr><td>"+$(local).text()+"</td>";
					html+="<td>"+$(local).attr("desc")+"</td>";
					html+="<td>"+$(local).attr("ta")+"</td></tr>";
				}
				html += "</table>";
				
				
				$("#displayWeather").html(html);
				
			},
			error: function(request, status, error){
				if(request.readyState == 0 || request.status == 0) return;
				else alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
			}
			
		});
	}
	// #날씨 함수 반복하기
	function loopshowWeather() {
		showWeather();
		
		setTimeout(function() {
			showWeather();	
			}, weatherTimeCycle);
		
		setTimeout(function() {
			loopshowWeather();	
			}, weatherTimeCycle + (60*60*1000)); // cycle 돌고 난 뒤 1시간 뒤에 다시 호출
		
	}// end of loopshowWeather() --------------------------
	
	
	function getTableRank() {
		
		$.getJSON("rankShowJSON.action", function(json){
	 								           // json => ajax 요청에 의해 서버로 부터 리턴받은 데이터.
			
			// $.each() 함수는 $(selector).each()와는 다르다.
			// $.each(배열, callback(indexInArray, valueOfElement) );
			// 배열을 다루는 경우에는, 콜백 함수는 인덱스와 값을 인자로 갖는다.
						
			var html = "<table class='table table-hover' align='center' width='250px' height='180px'>";
				html += "<tr>";
				html += "<th class='myaligncenter'>등수</th>";
				html += "<th class='myaligncenter'>제품명</th>";
				html += "<th class='myaligncenter'>주문량합</th>";
				html += "</tr>";
			
			$.each(json, function(entryIndex, entry){  
				html += "<tr>";
				html += "<td class='myaligncenter myrank'>"+ entry.RANK +"</td>";
				html += "<td class='myaligncenter'>"+ entry.JEPUMNAME +"</td>";
				html += "<td class='myaligncenter'>"+ entry.TOTALQTY +"</td>";
				html += "</tr>";
			});
		
			html += "</table>";
		
			$("#displayRank").html(html);
			
		}); // end of $.getJSON("rankShowJSON.action", function(data) {} )-----------
	}// end of function getTableRank() { }--------------------------
	
	
	function getChartRank() {
		
		$.getJSON("rankShowJSON.action", function(json){
	 								           // data => ajax 요청에 의해 서버로 부터 리턴받은 데이터.
            var jepumObjArr = [];
            	 		
			$.each(json, function(entryIndex, entry){ 
				jepumObjArr.push({
	                "name": entry.JEPUMNAME,
	                "y": parseFloat(entry.PERCENT),
	                "drilldown": entry.JEPUMNAME
	            });
			});	// end of $.each(json, function(entryIndex, entry)----------------
			
			
    		var jepumObjDetailArr = [];
     // 또는 var jepumObjDetailArr = new Array();
		    			
			$.each(json, function(entryIndex, entry) { 
				$.getJSON("jepumdetailnameRankShowJSON.action?jepumname="+entry.JEPUMNAME, function(json2){
					var subArr = [];
			// 또는   var subArr = new Array();

					$.each(json2, function(entryIndex2, entry2){ 
						subArr.push([
									 entry2.JEPUMDETAILNAME,
									 parseFloat(entry2.PERCENT)
								    ]);
					});	// end of $.each(json2, function(entryIndex2, entry2){  --------------
					
					jepumObjDetailArr.push({
						"name": entry.JEPUMNAME,
						"id": entry.JEPUMNAME,
						"data": subArr
					});	
					
				});
				
			}); // end of $.each(data, function(entryIndex, entry){ ----------------------
			
			
	 								 
		    // Create the chart
		    $('#chart-container').highcharts({
		        chart: {
		            type: 'column'
		        },
		        title: {
		            text: '제품별 판매 점유율'
		        },
		        subtitle: {
		           // text: 'Click the columns to view versions. Source: <a href="http://netmarketshare.com">netmarketshare.com</a>.'
		        },
		        xAxis: {
		            type: 'category'
		        },
		        yAxis: {
		            title: {
		                text: '점유율(%)'
		            }

		        },
		        legend: {
		            enabled: false
		        },
		        plotOptions: {
		            series: {
		                borderWidth: 0,
		                dataLabels: {
		                    enabled: true,
		                    format: '{point.y:.1f}%'
		                }
		            }
		        },

		        tooltip: {
		            headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
		            pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y:.2f}%</b> of total<br/>'
		        },

		        series: [{
		            name: 'Brands',
		            colorByPoint: true,
		            data: jepumObjArr   // **** 위에서 구한값을 대입시킴. ****
		        }],
		        drilldown: { 
		        	series: jepumObjDetailArr  // **** 위에서 구한값을 대입시킴. ****
		         /* series: [{
		                name: jepumObjArr[0].name,  // *** 위에서 한 작업으로 키값이 JEPUMNAME 에서 name 으로 변경됨.
		                id: jepumObjArr[0].name,    // *** 위에서 한 작업으로 키값이 JEPUMNAME 에서 name 으로 변경됨.
		                data: [
		                    [
		                        'v11.0',
		                        24.13
		                    ],
		                    [
		                        'v8.0',
		                        17.2
		                    ],
		                    [
		                        'v9.0',
		                        8.11
		                    ],
		                    [
		                        'v10.0',
		                        5.33
		                    ],
		                    [
		                        'v6.0',
		                        1.06
		                    ],
		                    [
		                        'v7.0',
		                        0.5
		                    ]
		                ]
		            }, {
		                name: jepumObjArr[1].name,
		                id: jepumObjArr[1].name,
		                data: [
		                    [
		                        'v40.0',
		                        5
		                    ],
		                    [
		                        'v41.0',
		                        4.32
		                    ],
		                    [
		                        'v42.0',
		                        3.68
		                    ],
		                    [
		                        'v39.0',
		                        2.96
		                    ],
		                    [
		                        'v36.0',
		                        2.53
		                    ],
		                    [
		                        'v43.0',
		                        1.45
		                    ],
		                    [
		                        'v31.0',
		                        1.24
		                    ],
		                    [
		                        'v35.0',
		                        0.85
		                    ],
		                    [
		                        'v38.0',
		                        0.6
		                    ],
		                    [
		                        'v32.0',
		                        0.55
		                    ],
		                    [
		                        'v37.0',
		                        0.38
		                    ],
		                    [
		                        'v33.0',
		                        0.19
		                    ],
		                    [
		                        'v34.0',
		                        0.14
		                    ],
		                    [
		                        'v30.0',
		                        0.14
		                    ]
		                ]
		            }, {
		                name: jepumObjArr[2].name,
		                id: jepumObjArr[2].name,
		                data: [
		                    [
		                        'v35',
		                        2.76
		                    ],
		                    [
		                        'v36',
		                        2.32
		                    ],
		                    [
		                        'v37',
		                        2.31
		                    ],
		                    [
		                        'v34',
		                        1.27
		                    ],
		                    [
		                        'v38',
		                        1.02
		                    ],
		                    [
		                        'v31',
		                        0.33
		                    ],
		                    [
		                        'v33',
		                        0.22
		                    ],
		                    [
		                        'v32',
		                        0.15
		                    ]
		                ]
		            }, {
		                name: jepumObjArr[3].name,
		                id: jepumObjArr[3].name,
		                data: [
		                    [
		                        'v8.0',
		                        2.56
		                    ],
		                    [
		                        'v7.1',
		                        0.77
		                    ],
		                    [
		                        'v5.1',
		                        0.42
		                    ],
		                    [
		                        'v5.0',
		                        0.3
		                    ],
		                    [
		                        'v6.1',
		                        0.29
		                    ],
		                    [
		                        'v7.0',
		                        0.26
		                    ],
		                    [
		                        'v6.2',
		                        0.17
		                    ]
		                ]
		            }, {
		                name: jepumObjArr[4].name,
		                id: jepumObjArr[4].name,
		                data: [
		                    [
		                        'v12.x',
		                        0.34
		                    ],
		                    [
		                        'v28',
		                        0.24
		                    ],
		                    [
		                        'v27',
		                        0.17
		                    ],
		                    [
		                        'v29',
		                        0.16
		                    ]
		                ]
		            }] 
		        */
		        }  
		    });	 								 
		
		}); // end of $.getJSON("rankShowJSON.action", function(data) {} )-----------
	}// end of function getChartRank() { }--------------------------

	
	function showRank(){
		getTableRank();
		getChartRank();
		
	//	var timejugi = 10000;   // 시간을 10초 마다 자동 갱신하려고.
		
	//	setTimeout(function() {
	//			showRank();	
	//		}, timejugi);
	}// end of showRank()-------------------------
	
</script>


<div style="margin: 0 auto;" align="center">
	현재시각 :&nbsp; 
	<div id="clock" style="display:inline;"></div>
</div>
<div id="displayWeather" style="min-width: 90%; max-height: 500px; overflow-y: scroll; margin-top: 20px; margin-bottom: 70px; padding-left: 10px; padding-right: 10px;"></div>
<div id="displayRank" style="min-width: 90%; margin-top: 50px; margin-bottom: 50px; padding-left: 20px; padding-right: 20px;"></div>
<div id="chart-container" style="min-width: 90%; min-height: 400px; margin: 0 auto; border: solid #F0FFFF 5px;"></div>
	
	
	
	
	
	