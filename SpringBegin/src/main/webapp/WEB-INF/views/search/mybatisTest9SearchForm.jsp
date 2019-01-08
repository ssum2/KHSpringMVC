<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<% 
   String ctxPath = request.getContextPath(); 
   //  /startspring 임.
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>search form</title>

<script type="text/javascript">

	function goSearch() {
		var frm = document.searchFrm;
		frm.method = "GET";
		frm.action = "<%=ctxPath %>/mybatistest/mybatisTest9End.action"; 
		frm.submit();
	}

</script>	

</head>
<body>

	<div align="center">
		<h2>주소를 입력받아 해당 주소에 거주하는 회원들을 찾아주는 페이지(/mybatistest/mybatisTest9.action)</h2>
		
		<form name="searchFrm">
			주소 : <input type="text" name="addr" />
			<br/><br/>
			<button type="button" onClick="goSearch();">찾기</button>
		</form>
	</div>

</body>
</html>
