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
<title>프로시저를 사용하여 테이블에 insert 하는 예제</title>

<script type="text/javascript">

	function goRegister() {
		// 유효성 검사는 생략함.
		
		var frm = document.myFrm;
		frm.method = "POST";
		frm.action = "<%=ctxPath %>/mybatistest/mybatisTest17End.action";   
		            //  /startspring/mybatistest/mybatisTest17End.action
		            
		frm.submit();            
	}
</script>

</head>
<body>
	<div align="center">
		<h2>프로시저를 사용하여 테이블에 insert 하는 예제(/mybatistest/mybatisTest17.action)</h2>
		
		<form name="myFrm">
	  	성명 : <input type="text" name="name"/> <br/>
	  	메일 : <input type="text" name="email"/> <br/>
	  	전화 : <input type="text" name="tel"/> <br/>
	  	주소 : <input type="text" name="addr"/> <br/>
	  	<br/><br/>
	  	<button type="button" onClick="goRegister();">등록</button>
	  </form>
	</div>
</body>
</html>




