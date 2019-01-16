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
<title>Insert title here</title>

<style type="text/css">
	table {border: 1px solid gray;
	       border-collapse: collapse;
	       width: 800px;
	      }
	
	th, td {border: 1px solid gray;
	        text-align: center;}

</style>

<script type="text/javascript" src="<%=ctxPath %>/resources/js/jquery-3.3.1.min.js"></script>

<script type="text/javascript">

    $(document).ready(function(){
    	
    	if(${department_id != null }) {
    		searchKeep();
    	}
    	
    });// end of $(document).ready()---------------------

    
    function searchKeep() {
    	$("#department_id").val("${department_id}");
     }// end of function searchKeep()---------------------
    
    
	function goSearch() {
		
		var frm = document.searchFrm;
		frm.method = "GET";
		frm.action = "<%=ctxPath %>/mybatistest/mybatisTest19.action"; 
		frm.submit();
		
	}// end of function goSearch()------------------

</script>	

</head>
<body>

	<div align="center">
		<h2>프로시저를 사용하여 우리회사 특정부서에 근무하는 사원정보 조회(select)하기</h2>
		<br/>
		
		<form name="searchFrm">
			부서번호 : <input type="text" id="department_id" name="department_id" />
			<button type="button" onClick="goSearch();">검색</button>&nbsp;&nbsp;
			<button type="button" onClick="javascript:location.href='mybatisTest19.action'">초기화</button>
		</form>
	</div>
	
	
	<c:if test="${department_id != null}">
		<div align="center" style="margin-top: 50px;">
		  <table>
			<thead>
				<tr>
					<th>사원번호</th>
					<th>사원명</th>
					<th>성별</th>
					<th>나이</th>
					<th>부서명</th>
					<th>직종</th>
					<th>연봉</th>
				</tr>
			</thead>
				
			<tbody>
			    <c:if test="${not empty employeeInfoList}">
				    <c:forEach var="empvo" items="${employeeInfoList}">
				     	<tr>
				     		<td>${empvo.employee_id}</td>
				     		<td>${empvo.ename}</td>
				     		<td>${empvo.gender}</td>
				     		<td>${empvo.age}</td>
				     		<td>${empvo.department_name}</td>
				     		<td>${empvo.job_id}</td>
				     		<td>${empvo.yearsal}</td>
				     	</tr>
			     	</c:forEach>
				</c:if>
					
				 <c:if test="${empty employeeInfoList}">
					<tr>
					   <td colspan="7">해당부서번호를 가진 사원은 존재하지 않습니다.</td>
					</tr>
				 </c:if>
			</tbody>
		  </table>
		</div>
	</c:if>	
		
</body>
</html>
