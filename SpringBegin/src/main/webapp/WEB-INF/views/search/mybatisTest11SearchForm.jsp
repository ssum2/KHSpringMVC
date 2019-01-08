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
	      }
	
	th, td {border: 1px solid gray;}
	
	.total {background-color: #ffff99; 
	        font-weight: bold;
	        text-align: center;}
</style>

<script type="text/javascript" src="<%=ctxPath %>/resources/js/jquery-3.3.1.min.js"></script>

<script type="text/javascript">

    $(document).ready(function(){
    	if(${ searchWord!=null }){
    		searchKeep();	
    	}
    	
    });// end of $(document).ready()---------------------

    
    function searchKeep() {
    	$("#colName").val("${colName}");
    	$("#searchWord").val("${searchWord}");
    	$("#startday").val("${startday}");
    	$("#endday").val("${endday}");
    	
    }// end of function searchKeep()---------------------
    
    
	function goSearch() {
		var searchWord = $("#searchWord").val();
		
		if(searchWord.trim() == ""){
			alert("검색어를 입력하세요.");
			return;
		}
		else {
			var frm = document.searchFrm;
			frm.method="GET";
			frm.action="<%= ctxPath %>/mybatistest/mybatisTest11.action";
			frm.submit();
		}
		
	}// end of function goSearch()------------------

</script>	

</head>
<body>

	<div align="center">
		<h2>회원명단</h2>
		<br/>
		
		<form name="searchFrm">
			<select name="colName" id="colName">
				<option value="name">성명</option>
				<option value="email">이메일</option>
				<option value="tel">전화</option>
				<option value="addr">주소</option>
			</select>
			<input type="text" name="searchWord" id="searchWord" size="20"/>
			<br/><br/>
			시작일 : <input type="date" name="startday" id="startday" size="12" /> ~ 종료일 : <input type="date" name="endday" id="endday" size="12"/> 
			<br/><br/>
			<button type="button" onClick="goSearch();">검색</button>&nbsp;&nbsp;
			<button type="button" onClick="javascript:location.href='mybatisTest11.action'">초기화</button>
		</form>
	</div>
	
	<c:if test="${memberList != null}">
		<div align="center" style="margin-top: 50px;">
		  <table>
			<thead>
				<tr>
				    <th>일련번호</th>
					<th>회원번호</th>
					<th>성명</th>
					<th>이메일</th>
					<th>전화번호</th>
					<th>주소</th>
					<th>가입일자</th>
					<th>생일</th>
				</tr>
			</thead>
			
			<tbody>
			<c:set var="cnt" value="0" />
			<c:if test="${empty memberList}"> <%-- empty memberList 또는 memberList.size() <= 0  null값은 올 수 없음; 텅 빈 리스트를 넘겨주는 것 --%>
				<tr>
					<td colspan="8">검색하신 '${searchWord}' 검색어와 일치하는 회원이 없습니다.</td>
				</tr>
			</c:if>
			<c:if test="${not empty memberList}">
			    <c:forEach var="map" items="${memberList}" varStatus="status">
			    	<tr>
			    		<td>${status.count}</td>
			    		<td>${map.NO}</td>
			    		<td>${map.NAME}</td>
			    		<td>${map.EMAIL}</td>
			    		<td>${map.TEL}</td>
			    		<td>${map.ADDR}</td>
			    		<td>${map.WRITEDAY}</td>
			    		<td>${map.BIRTHDAY}</td>
			    	</tr>
			    	<c:set var="cnt" value="${status.count}"/>
			    </c:forEach>
			 </c:if>
				    <tr>
				    	<td colspan="4">검색된 회원수</td>
				    	<td colspan="4" style="text-align: center;">${cnt}명</td>
				    </tr>
			</tbody>
		  </table>
		</div>
	</c:if>
	
	
	
</body>
</html>
