<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
	String ctxPath = request.getContextPath();
%>    
    
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Spring 에서 Transaction(트랜잭션)처리 테스트</title>

<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

<style type="text/css">

body {font-family: Arial, Helvetica, sans-serif, 돋움;}

.header {
  background-color: #f1f1f1;
  padding: 2%;
  text-align: center;
}

.navbar {
  overflow: hidden;
  background-color: #333;
  font-family: Arial, Helvetica, sans-serif;
}

.navbar a {
  float: left;
  font-size: 16px;
  color: white;
  text-align: center;
  padding: 14px 16px;
  text-decoration: none;
}

.dropdown {
  float: left;
  overflow: hidden;
}

.dropdown .dropbtn {
  font-size: 16px;  
  border: none;
  outline: none;
  color: white;
  padding: 14px 16px;
  background-color: inherit;
  font-family: inherit;
  margin: 0;
}

.navbar a:hover, .dropdown:hover .dropbtn {
  background-color: red;
}

.dropdown-content {
  display: none;
 /* position: absolute; */
  position: fixed;
  background-color: #f9f9f9;
  min-width: 160px;
  box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
  z-index: 1;
}

.dropdown-content a {
  float: none;
  color: black;
  padding: 12px 16px;
  text-decoration: none;
  display: block;
  text-align: left;
}

.dropdown-content a:hover {
  background-color: #ddd;
}

.dropdown:hover .dropdown-content {
  display: block;
}

.sticky {
  position: fixed;
  top: 0;
  width: 99%; 
}

.footer {
   position: relative;
   left: 0.5%;
   bottom: 0;
   width: 99%;
   min-height: 60px;
   background-color: red;
   color: white;
   text-align: center;
   padding: 10px;
}
</style>

<script type="text/javascript" src="<%=ctxPath%>/resources/js/jquery-3.3.1.min.js"></script>

<script type="text/javascript">
	
	$(document).ready(function(){
		
	//	#부트스트랩으로 상단 메뉴 스크롤업 해도 상단에 고정시키기
		var navbarTop = $("#navbar").offset().top;
	//	var navbarLeft = $("#navbar").offset().left;
		
		var scrollTop = 0;
		$(window).scroll(function(event){
			scrollTop = $(this).scrollTop();
		 // alert("scrollTop : "+scrollTop);
		 // alert("navbarTop : "+navbarTop);
			
		    if(scrollTop >= navbarTop) {
				$("#navbar").addClass("sticky"); // sticky; 위치를 고정시키는 클래스
			}
			else {
				$("#navbar").removeClass("sticky");
			}
		});
	});
	
</script>

</head>

<body>

<div class="header">
  <h2>Spring 에서 Transaction(트랜잭션)처리 테스트</h2>
</div>

<div class="navbar" id="navbar">
  <a href="<%=ctxPath%>/">메인</a>
  <a href="<%=ctxPath%>/mypoint.action">나의포인트</a>
  <div class="dropdown">
    <button class="dropbtn">글쓰기및목록 
      <i class="fa fa-caret-down"></i>
    </button>
    <div class="dropdown-content">
      <a href="<%=ctxPath%>/add_notransaction.action">글쓰기(트랜잭션처리안함)</a>
      <a href="<%=ctxPath%>/add_transaction.action">글쓰기(트랜잭션처리함)</a>
      <a href="<%=ctxPath%>/list.action">글목록</a>
    </div>
  </div> 
</div>

<div style="margin-top: 2%; margin-right: 5%; margin-bottom: 2%; margin-left: 5%;">
