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
		frm.action = "<%=ctxPath %>/mybatistest/mybatisTest7End.action"; 
		frm.submit();
	}

</script>	

</head>
<body>

	<div align="center">
		<h2>번호를 입력받아 한사람의 모든 정보를 찾아주는 페이지(/mybatistest/mybatisTest7.action)</h2>
		
		<form name="searchFrm">
			번호 : <input type="text" name="no" />
			<br/><br/>
			<button type="button" onClick="goSearch();">찾기</button>
		</form>
	</div>

</body>
</html>
