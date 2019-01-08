<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>    
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<% 
   String ctxPath = request.getContextPath(); 
   //  /startspring 임.
%>
    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회사 사원 조회</title>

<style type="text/css">
	table {border: 1px solid gray;
	       border-collapse: collapse;
	      }
	
	th, td {border: 1px solid gray;}
	
	.total {background-color: #ffff99; 
	        font-weight: bold;
	        text-align: center;}
	thead { background-color: navy;
		 	color: white;}
</style>

<script type="text/javascript" src="<%=ctxPath %>/resources/js/jquery-3.3.1.min.js"></script>

<script type="text/javascript">

    $(document).ready(function() {
    	if( "${department_id != null && gender != null }")	{
    		searchKeep();
    	}
    		
    	
    	
    });// end of $(document).ready()---------------------

    
    function searchKeep() {
    	$("#department_id").val("${department_id}");
    	$("#gender").val("${gender}");
    }// end of function searchKeep()---------------------
    
    
	function goSearch() {
		var frm = document.searchFrm;
		frm.method = "GET";
		frm.action = "<%= ctxPath %>/mybatistest/mybatisTest12_2.action";
		frm.submit();
		
	}// end of function goSearch()------------------

</script>	

</head>
<body>

	<div align="center">
		<h2>우리회사 사원명단</h2>
		<br/>
		
		<form name="searchFrm">
			<select name="department_id" id="department_id">
				<option class="deptid" value="">전체</option>
			    <c:forEach var="deptid" items="${deptnoList}">
			    	<c:if test="${deptid==-1}">
			    		<option class="deptid" value="${deptid}">부서없음</option>
			    	</c:if>
			    	<c:if test="${deptid!=-1}">
			    		<option class="deptid" value="${deptid}">${deptid}</option>
			    	</c:if>
			    </c:forEach>
			</select>
			
			<select name="gender" id="gender">
				<option value="전체">전체</option>
				<option value="남">남</option>
				<option value="여">여</option>
			</select>
			
			<button type="button" onClick="goSearch();">검색</button>&nbsp;&nbsp;
			<button type="button" onClick="javascript:location.href='mybatisTest12_2.action'">초기화</button>
		</form>
	</div>
	
	<c:if test="${empList != null}">
		<div align="center" style="margin-top: 50px;">
		  <table>
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
			<tbody>
				<c:set var="cnt"  value="0"/>
				<c:if test="${not empty empList}">
			    <c:forEach var="empDeptMap" items="${empList}" varStatus="status">
			    	<tr>
			    		<td>${status.count}</td>
			    		<td>${empDeptMap.DEPARTMENT_ID}</td>
			    		<td>${empDeptMap.DEPARTMENT_NAME}</td>
			    		<td>${empDeptMap.EMPLOYEE_ID}</td>
			    		<td>${empDeptMap.NAME}</td>
			    		<td>${empDeptMap.JUBUN}</td>
			    		<td>${empDeptMap.GENDER}</td>
			    		<td>${empDeptMap.AGE}</td>
			    		<td><fmt:formatNumber value="${empDeptMap.YEARPAY}" pattern="$###,###"/></td>
			    	</tr>
			    	<c:set var="cnt" value="${status.count}"/>
			    </c:forEach>
			    </c:if>
			    <c:if test="${empty empList}">
			    	<tr><td colspan="9" style="text-align: center;">검색 조건에 일치하는 사원이 없습니다.</td></tr>
			    </c:if>
			    <tr>
			    	<td colspan="9" style="text-align: right; padding-right: 3%;">검색된 사원수:  ${cnt}명</td>
			    </tr>
			   
			</tbody>
		  </table>
		</div>
	</c:if>
	
</body>
</html>
