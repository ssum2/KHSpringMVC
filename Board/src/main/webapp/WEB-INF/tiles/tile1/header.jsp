<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
	
<%@ page import="java.net.InetAddress" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<%-- ======= #25. tiles1 중 header 페이지 만들기  ======= --%>
<%
	String cxtPath = request.getContextPath();

	//=== 서버 IP 주소 알아오기 === //
	InetAddress inet = InetAddress.getLocalHost();
	String serverIP = inet.getHostAddress(); 
	int portnumber = request.getServerPort();
	
	String serverName = "http://"+serverIP+":"+portnumber;
%>

<div align="center">
	<ul class="nav nav-tabs mynav">
		<li class="dropdown"><a class="dropdown-toggle"
			data-toggle="dropdown" href="#">Home <span class="caret"></span></a>
			<ul class="dropdown-menu">
				<li><a href="<%=cxtPath%>/index.action">Home</a></li>
				<%-- <li><a href="<%=serverName%><%=cxtPath%>/chatting/multichat.action">웹채팅</a></li> --%>
				<li><a href="#">Submenu 1-3</a></li>
			</ul></li>
	<li class="dropdown"><a class="dropdown-toggle"
			data-toggle="dropdown" href="#">게시판 <span class="caret"></span></a>
			<ul class="dropdown-menu">
				<li><a href="<%=cxtPath%>/list.action">목록보기</a></li>
				<li><a href="<%=cxtPath%>/add.action">글쓰기</a></li>
				<li><a href="#">Submenu 2-3</a></li>
			</ul></li>
		<li class="dropdown"><a class="dropdown-toggle"
			data-toggle="dropdown" href="#">주문(통계차트) <span class="caret"></span></a>
			<ul class="dropdown-menu">
				<li><a href="<%=cxtPath%>/chart/order.action">주문하기</a></li>
				<li><a href="<%=cxtPath%>/chart/myorderchart.action">나의주문내역차트</a></li>
				<li><a href="#">Submenu 3-3</a></li>
			</ul></li>	
		
		<li class="dropdown"><a class="dropdown-toggle"
			data-toggle="dropdown" href="#">제품정보 <span class="caret"></span></a>
			<ul class="dropdown-menu">
				<li><a href="<%=cxtPath%>/product/listProduct.action">제품목록</a></li>
			</ul></li>
		
		<c:if test="${sessionScope.loginuser.gradelevel >= 10 }">
		<li class="dropdown"><a class="dropdown-toggle"
			data-toggle="dropdown" href="#">제품등록(다중파일첨부) <span class="caret"></span></a>
			<ul class="dropdown-menu">
			    <li><a href="<%=cxtPath%>/product/addProduct.action">제품등록</a></li>
				<li><a href="<%=cxtPath%>/product/productStore.action">제품입고</a></li>
			</ul></li>
		</c:if>	
		
		<li class="dropdown"><a class="dropdown-toggle"
			data-toggle="dropdown" href="#">로그인 <span class="caret"></span></a>
			<ul class="dropdown-menu">
				<c:if test="${sessionScope.loginuser == null}">
				<li><a href="#">회원가입</a></li>
				<li><a href="<%=cxtPath%>/login.action">로그인</a></li>
				</c:if>
				
				<c:if test="${sessionScope.loginuser != null}">
				<li><a href="<%=cxtPath%>/myinfo.action">나의정보</a></li>
				<li><a href="<%=cxtPath%>/logout.action">로그아웃</a></li>
				</c:if>
			</ul></li>		
		
		<!-- ===== #49. 로그인 성공한 사용자 이메일 출력하기. ===== -->
		<c:if test="${sessionScope.loginuser.gradelevel < 10 }">
		<li style="margin-left: 35%; margin-top: 1%;">
		  <span style="color: navy; font-weight: bold;">${sessionScope.loginuser.email}</span>&nbsp;[<span style="font-size: 10pt;">${sessionScope.loginuser.name}님</span>]
		</li>
		</c:if>
		
		<c:if test="${sessionScope.loginuser.gradelevel >= 10 }">
		<li style="margin-left: 15%; margin-top: 1%;">
		  <span style="color: red; font-weight: bold;">${sessionScope.loginuser.email}</span>&nbsp;[<span style="font-size: 10pt;">${sessionScope.loginuser.name}님</span>]
		</li>
		</c:if>		
	</ul>
</div>
