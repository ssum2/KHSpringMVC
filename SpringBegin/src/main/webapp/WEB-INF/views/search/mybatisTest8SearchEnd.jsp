<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>    
    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Search End(List 사용)</title>

<style type="text/css">
	table {border: 1px solid gray;
	       border-collapse: collapse;
	      }
	
	th, td {border: 1px solid gray;}
</style>

</head>
<body>

	<div align="center">
		<table>
			<thead>
				<tr>
					<th>번호</th>
					<th>성명</th>
					<th>이메일</th>
					<th>전화번호</th>
					<th>주소</th>
					<th>가입일자</th>
				</tr>
			</thead>
			
			<tbody>
			<c:if test="${not empty memberList}">
			<c:forEach var="mvo" items="${memberList}">
				<tr>
					<td>${mvo.no}</td>
					<td>${mvo.name}</td>
					<td>${mvo.email}</td>
					<td>${mvo.tel}</td>
					<td>${mvo.addr}</td>
					<td>${mvo.writeday}</td>
				</tr>
			</c:forEach>
			</c:if>
			<c:if test="${empty memberList}">
				<td colspan="7">조회하려는 주소 ${addr}와 일치하는 회원은 존재하지 않습니다.</td> 
			</c:if>
			</tbody>
		</table>
	</div>

</body>
</html>