<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="header.jsp" />

<div>
    <c:forEach var="n" begin="1" end="100">
	    ${n}<br/>
		<h3>Dropdown Menu inside a Navigation Bar</h3>
		<p>Hover over the "Dropdown" link to see the dropdown menu.</p>
	</c:forEach>
</div>

<jsp:include page="footer.jsp" />
    