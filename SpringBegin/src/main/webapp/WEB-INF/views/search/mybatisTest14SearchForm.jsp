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
<title>회사 명단(부서별 보기)</title>

<style type="text/css">
	table {border: 1px solid gray;
	       border-collapse: collapse;
	      }
	
	th, td {border: 1px solid gray;}
    
	select.my_select {height: 25px;}  	
</style>

<script type="text/javascript" src="<%=ctxPath %>/resources/js/jquery-3.3.1.min.js"></script>

<script type="text/javascript">

    $(document).ready(function(){
    	callAjax("", $("#gender").val(), $("#ageline").val());
    	
    	$("#btnSearch").click(function(){
    		var deptnoArr = new Array();	// 체크박스 여러개의 값을 가져올 것이기 때문에 배열로 선언
    		$(".department_id").each(function(){
    			var bool = $(this).is(":checked");		// 체크박스의 체크여부를 검사
    			if(bool){
    				deptnoArr.push($(this).val());		// 체크된 경우 해당 input 태그의 value를 배열에 넣어줌
    			}
    		});
    		
    		var str_deptnoes = deptnoArr.join();	// 배열에 있는 것을 문자열 하나로 합침 --> join의 파라미터에 구분자를 주지 않으면 기본값 ","
    		// console.log(str_deptnoes);
    		
    		callAjax(str_deptnoes, $("#gender").val(), $("#ageline").val());
    	});
    	
    }); // end of $(document).ready()--------------------------------------------

    
	function callAjax(str_deptnoes, gender, ageline) {
    	var data_form = {"str_deptnoes":str_deptnoes, "gender":gender, "ageline":ageline}
    	$.ajax({
    		url:"mybatisTest14JSON.action",
    		type:"GET",
    		data: data_form,
    		dataType:"JSON",
    		success: function(json){
    			var html = "";
    			if(json.length>0){
    				$.each(json, function(entryIndex, entry){
        					html +=	"<tr>"+
    				    			"<td>"+(entryIndex+1)+"</td>";
    				    			if(entry.DEPARTMENT_ID == "-1"){
    				    				html += "<td>부서없음</td>";
    				    			}
    				    			else{
    				    				html += "<td>"+entry.DEPARTMENT_ID+"</td>";
    				    			}
    				    	html += "<td>"+entry.DEPARTMENT_NAME+"</td>"+
    					    		"<td>"+entry.EMPLOYEE_ID+"</td>"+
    					    		"<td>"+entry.NAME+"</td>"+
    					    		"<td>"+entry.JUBUN+"</td>"+
    					    		"<td>"+entry.GENDER+"</td>"+
    					    		"<td>"+entry.AGE+"</td>"+
    					    		"<td>\$"+Number(entry.YEARPAY).toLocaleString('en')+"</td>"+
    					    		"</tr>";
    					
        			});
    				 $("#result").empty().html(html);
    			}
    			else{
    				$("#result").empty().html("<tr><td colspan='9' style='text-align: center;'>조건에 일치하는 사원이 없습니다.</td></tr>");
    				
    			}
    		},
    		error: function(request, status, error){
				if(request.readyState == 0 || request.status == 0) return;
				else alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
			}
    	});
    	
    }// end of function callAjax(addrSearch)------------
    
</script>	

</head>
<body>

	<div align="center">
		<h2>우리회사 사원명단</h2>
		<br/>
		
		<form name="searchFrm">
			<c:forEach var="deptno" items="${deptnoList}">
				<c:if test="${deptno == -1}">
				<input type="checkbox" class="department_id" name="department_id" id="department_id${deptno}" value="${deptno}"/>
				<label for="department_id${deptno}">부서 없음</label>&nbsp;
				</c:if>
				<c:if test="${deptno != -1}">
				<input type="checkbox" class="department_id" name="department_id" id="department_id${deptno}" value="${deptno}"/>
				<label for="department_id${deptno}">${deptno}번 부서</label>&nbsp;
				</c:if>
			</c:forEach>
			<br/><br/>
			
			<select name="gender" id="gender" class="my_select">
				<option value="">성별</option>
				<option value="남">남</option>
				<option value="여">여</option>
			</select>
						
			<select name="ageline" id="ageline" class="my_select">
				<option value="">연령대</option>
				<option value="0">10대미만</option>
				<option value="10">10대</option>
				<option value="20">20대</option>
				<option value="30">30대</option>
				<option value="40">40대</option>
				<option value="50">50대</option>
				<option value="60">60대</option>
			</select>
			
			<button type="button" id="btnSearch">검색</button>&nbsp;&nbsp;
		</form>
	</div>
	
	<div id="display" align="center" style="margin-top: 50px;">
		<table style="width: 900px;">
			<thead>
				<tr>
					<th>일련번호</th>
					<th>부서번호</th>
					<th>부서명</th>
					<th>사원번호</th>
					<th>사원명</th>
					<th>주민번호</th>
					<th>성별</th>
					<th>나이</th>
					<th>연봉</th>
				</tr>
			</thead>
			
			<tbody id="result"></tbody>
		</table>
	</div>
	
</body>
</html>
