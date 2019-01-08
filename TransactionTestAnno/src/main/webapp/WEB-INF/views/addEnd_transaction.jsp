<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="header.jsp" />

<script type="text/javascript">
	<c:if test="${not empty result && result == 2}">
		alert("글쓰기 성공!!");
		location.href="<%=request.getContextPath() %>/list.action";
	</c:if>
	
	<c:if test="${not empty result && result != 2}">
		alert("글쓰기 실패!!");
		location.href="<%=request.getContextPath() %>/list.action";
	</c:if>		
</script>

<jsp:include page="footer.jsp" />