<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
  

<% 
   String ctxPath = request.getContextPath(); 
   //  /startspring 임.
%> 
    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>chart(1) 성별, 연령대, 부서번호별 현황</title>
<script src="https://code.highcharts.com/highcharts.js"></script>
<script src="https://code.highcharts.com/modules/exporting.js"></script>
<script src="https://code.highcharts.com/modules/export-data.js"></script>
<script type="text/javascript" src="<%=ctxPath %>/resources/js/jquery-3.3.1.min.js"></script>
<style type="text/css">
	table#tblGender, table#tblAgeline,table#tblYearpay {width: 100%;
					                   margin-top: 10%;
					                   border: 1px solid gray;
					       			   border-collapse: collapse;
					                  }
	
	table#tblGender th, table#tblGender td
	, table#tblAgeline th, table#tblAgeline td
	, table#tblYearpay th, table#tblYearpay td {border: 1px solid gray; 
												text-align: center;}
	                                        
	table#tblGender th {background-color: #ffffe6;} 
	
	table#tblAgeline th {background-color: #ffffe6;} 
	
	table#tblYearpay th {background-color: #ffe6e6;}                                        
</style>



<script type="text/javascript">

    $(document).ready(function(){
    	$("#btnOK").click(function(){
    		var chartType = $("#chartType").val();
    		callAjax(chartType);
    	});
    	
    	    	
    });// end of $(document).ready()
    
    
    function callAjax(chartType) {
		switch(chartType){
			case "gender": 
				$.ajax({
					url: "mybatisTest15JSON_gender.action",
					type: "GET",
					dataType: "JSON",
					success: function(json){
					var resultArr = [];
					for(var i=0; i<json.length; i++){
						var obj = {name: json[i].GENDER
									, y: Number(json[i].AVG)};	// 퍼센트 계산을 위해 반드시 Number로 변환
						resultArr.push(obj);
					}
					///////////////////////////////////////////////////////////////
					Highcharts.chart('chart', {
			    	    chart: {
			    	        plotBackgroundColor: null,
			    	        plotBorderWidth: null,
			    	        plotShadow: false,
			    	        type: 'pie'
			    	    },
			    	    title: {
			    	        text: '사내 직원 성별 통계'
			    	    },
			    	    tooltip: {
			    	        pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
			    	    },
			    	    plotOptions: {
			    	        pie: {
			    	            allowPointSelect: true,
			    	            cursor: 'pointer',
			    	            dataLabels: {
			    	                enabled: true,
			    	                format: '<b>{point.name}</b>: {point.percentage:.1f} %',
			    	                style: {
			    	                    color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
			    	                }
			    	            }
			    	        }
			    	    },
			    	    series: [{
			    	        name: '구성비율',
			    	        colorByPoint: true,
			    	        data: resultArr 
			    	    }]
			    	});
					//////////////////////////////////////////////////////////////
						var v_data = "";
						$.each(json, function(entryIndex, entry){
							if(json.length > 0){
								v_data += "<tr>"+
											"<td>"+entry.GENDER+"</td>"+
											"<td>"+entry.CNT+"</td>"+
											"<td>"+entry.AVG+"</td>"+
											"</tr>";
							}
							else{
								v_data += "<tr><td colspan='3'>데이터가 없습니다.</td></tr>";
							}
							
						});
					
						var html = "<table id='tblAgeline'>"+
									"<thead>"+"<tr>"+
									"<th>성별</th>"+"<th>인원수</th>"+"<th>비율(%)</th>"+
									"</tr>"+"</thead>"+
									"<tbody>"+v_data+"</tbody>"+
									"</table>";
						$("#tbl").html(html);
					},
					error: function(request, status, error){
						if(request.readyState == 0 || request.status == 0) return;
						else alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
					}
				});
				break;
				
			case "ageline":
				$.ajax({
					url: "mybatisTest15JSON_ageline.action",
					type: "GET",
					dataType: "JSON",
					success: function(json){
					var resultArr = [];
					for(var i=0; i<json.length; i++){
						var obj = [ json[i].AGELINE, Number(json[i].CNT) ];
						resultArr.push(obj);
					}
					///////////////////////////////////////////////////////////////
					
					Highcharts.chart('chart', {
					    chart: {
					        type: 'column'
					    },
					    title: {
					        text: '사내 연령대별 직원 분포도'
					    },
					    subtitle: {
					        text: 'khCompany 2018'
					    },
					    xAxis: {
					        type: 'category',
					        labels: {
					            rotation: -45,
					            style: {
					                fontSize: '13px',
					                fontFamily: 'Verdana, sans-serif'
					            }
					        }
					    },
					    yAxis: {
					        min: 0,
					        title: {
					            text: 'Population (millions)'
					        }
					    },
					    legend: {
					        enabled: false
					    },
					    tooltip: {
					        pointFormat: 'Population in 2017: <b>{point.y:.1f} millions</b>'
					    },
					    series: [{
					        name: 'Population',
					        data: resultArr,
					        dataLabels: {
					            enabled: true,
					            rotation: -90,
					            color: '#FFFFFF',
					            align: 'right',
					            format: '{point.y:.1f}', // one decimal
					            y: 10, // 10 pixels down from the top
					            style: {
					                fontSize: '13px',
					                fontFamily: 'Verdana, sans-serif'
					            }
					        }
					    }]
					});
					//////////////////////////////////////////////////////////////
						var v_data = "";
						$.each(json, function(entryIndex, entry){
							if(json.length > 0){
								v_data += "<tr>"+
											"<td>"+entry.AGELINE+"</td>"+
											"<td>"+entry.CNT+"</td>"+
											"<td>"+entry.AVG+"</td>"+
											"</tr>";
							}
							else{
								v_data += "<tr><td colspan='3'>데이터가 없습니다.</td></tr>";
							}
							
						});
					
						var html = "<table id='tblGender'>"+
									"<thead>"+"<tr>"+
									"<th>연령대</th>"+"<th>인원수</th>"+"<th>비율(%)</th>"+
									"</tr>"+"</thead>"+
									"<tbody>"+v_data+"</tbody>"+
									"</table>";
						$("#tbl").html(html);
					},
					error: function(request, status, error){
						if(request.readyState == 0 || request.status == 0) return;
						else alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
					}
				});
				break;
				
			case "deptno": 
				$.ajax({
					url: "mybatisTest15JSON_deptno.action",
					type: "GET",
					dataType: "JSON",
					success: function(json){
					var resultArr1 = [];
					var resultArr2 = [];
					var resultDept = [];
					for(var i=0; i<json.length; i++){
						var obj = json[i].DEPTNO+"("+json[i].DEPTNAME+")";	// 퍼센트 계산을 위해 반드시 Number로 변환
						var obj2 = Number(json[i].CNT);
						var obj3 = Number(json[i].AVGDEPT);
						resultArr1.push(obj2);
						resultArr2.push(obj3);
						resultDept.push(obj);
					}
					///////////////////////////////////////////////////////////////
					
					Highcharts.chart('chart', {
					    chart: {
					        zoomType: 'xy'
					    },
					    title: {
					        text: '부서별 사원 분포 및 연봉 통계'
					    },
					    subtitle: {
					        text: 'Source: 인사혁신처'
					    },
					    xAxis: [{
					        categories: resultDept,
					        crosshair: true
					    }],
					    yAxis: [{ // Primary yAxis
					        labels: {
					            format: '{value}명',
					            style: {
					                color: Highcharts.getOptions().colors[2]
					            }
					        },
					        title: {
					            text: '사원수',
					            style: {
					                color: Highcharts.getOptions().colors[2]
					            }
					        },
					        opposite: true
					
					    }, { // Secondary yAxis
					        gridLineWidth: 0,
					        title: {
					            text: '평균연봉',
					            style: {
					                color: Highcharts.getOptions().colors[0]
					            }
					        },
					        labels: {
					            format: '\${value}',
					            style: {
					                color: Highcharts.getOptions().colors[0]
					            }
					        }
					
					    }],
					    tooltip: {
					        shared: true
					    },
					    legend: {
					        layout: 'vertical',
					        align: 'left',
					        x: 80,
					        verticalAlign: 'top',
					        y: 55,
					        floating: true,
					        backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor) || 'rgba(255,255,255,0.25)'
					    },
					    series: [{
					        name: '연봉평균',
					        type: 'column',
					        yAxis: 1,
					        data: resultArr2,
					        tooltip: {
					            valueSuffix: '\$ '
					        }
					
					    }, {
					        name: '사원수',
					        type: 'spline',
					        data: resultArr1,
					        tooltip: {
					            valueSuffix: ' 명'
					        }
					    }]
					});


					//////////////////////////////////////////////////////////////
						var v_data = "";
						$.each(json, function(entryIndex, entry){
							if(json.length > 0){
								v_data += "<tr>"+
											"<td>"+entry.DEPTNO+"</td>"+
											"<td>"+entry.DEPTNAME+"</td>"+
											"<td>"+entry.CNT+"</td>"+
											"<td>"+entry.AVG+"</td>"+
											"<td>"+entry.AVGDEPT+"</td>"+
											"</tr>";
							}
							else{
								v_data += "<tr><td colspan='3'>데이터가 없습니다.</td></tr>";
							}
							
						});
					
						var html = "<table id='tblYearpay'>"+
									"<thead>"+"<tr>"+
									"<th>부서번호</th>"+"<th>부서명</th>"+"<th>인원수</th>"+"<th>비율(%)</th>"+"<th>연봉평균</th>"+
									"</tr>"+"</thead>"+
									"<tbody>"+v_data+"</tbody>"+
									"</table>";
						$("#tbl").html(html);
					},
					error: function(request, status, error){
						if(request.readyState == 0 || request.status == 0) return;
						else alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
					}
				});
				break;
		}
    	
    	
    	
    }// end of function callAjax(addrSearch)
    

</script>	

</head>
<body>

	<div align="center" style="margin-bottom: 100px;">
		<h2>차트그리기</h2>
		<br/><br/>
		
		<form name="searchFrm">
			
			<select name="chartType" id="chartType" style="height: 25px;">
				<option value="gender">성별</option>
				<option value="ageline">연령대</option>
				<option value="deptno">부서번호</option>
			</select>
			
			<button type="button" id="btnOK">확인</button>&nbsp;&nbsp;
			<button type="button" id="btnClear">초기화</button>
		</form>
	</div>
	
	<div id="chart" style="min-width: 310px; height: 400px; max-width: 600px; margin: 0 auto"></div>
	<%-- chart 크기를 변경하려면 min-width, height, max-width 사이즈를 조절해주면 됨 --%>
	
	<div id="tbl" style="margin: 0 auto; width: 20%; border: 0px solid red;"></div>
	
</body>
</html>
