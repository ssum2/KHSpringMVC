<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<% String ctxPath = request.getContextPath(); %>

<script type="text/javascript">
	var loginuser = "${sessionScope.loginuser.userid}";
	var goBackURL = "${requestScope.goBackURL}";
	
	if(loginuser != null && loginuser != "" && (goBackURL == null || goBackURL == "") ) {
		alert("로그인 성공 !!");
		location.href="<%=ctxPath%>/index.action";
	}
	
	if(loginuser != null && loginuser != "" && (goBackURL != null && goBackURL != "")) {
		alert("로그인 성공 !!");
		location.href=goBackURL;
	}
</script>
    