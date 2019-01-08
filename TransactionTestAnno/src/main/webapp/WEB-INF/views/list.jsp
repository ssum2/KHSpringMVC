<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>    

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"> 

<jsp:include page="header.jsp" />

<style type="text/css">
  body {padding: 0.5%;}
  .table {width: 80%;}
  .title {font-weight: bold; background-color: #ffffcc; text-align: center;}  
  .btn   {margin-right: 1%;}
  
  .titleColor {color: #660029; font-weight: bold;}
</style>

<script type="text/javascript">
	$(document).ready(function(){
		$(".writeTitle").hover(function(){
			                      $(this).addClass("titleColor");
		                       }, 
				               function(){
		                	      $(this).removeClass("titleColor");   
		                       });
	});// end of $(document).ready()----------------------
	
	function goContentView(seq) {
		location.href="contentView.action?seq="+seq;
	}
	
</script>

<div style="margin-bottom: 10%;">
	<h2 style="margin-bottom: 2%;">공지게시판 : 글목록</h2>
	
	<table class="table table-bordered">
		<thead>
			<tr>
				<th width="10%" class="title">글번호</th>
				<th width="20%" class="title">작성자</th>
				<th width="70%" class="title">글제목</th>
			</tr>
		</thead>
		<tbody>
			<c:if test="${empty list}">
				<tr>
					<td colspan="3">데이터가 없습니다.</td>
				</tr>
			</c:if>
			<c:if test="${not empty list}">
				<c:forEach var="map" items="${list}" varStatus="status">
					<tr>
						<td>${map.RNO}</td>
						<td>${map.NAME}</td>
						<td><span class="writeTitle" style="cursor: pointer;" onClick="goContentView('${map.SEQ}')">${map.TITLE}</span></td>
					</tr>
				</c:forEach>
			</c:if>
		</tbody>
	</table>
	
	<div style="border: 0px solid gray; width: 50%; margin-top: 3%; margin-left: 20%;">
		<button type="button" class="btn" onClick="javascript:location.href='add_notransaction.action'">글쓰기(트랜잭션처리안함)</button>
		<button type="button" class="btn" onClick="javascript:location.href='add_transaction.action'">글쓰기(트랜잭션처리함)</button>
	</div>
	
</div>
	
<jsp:include page="footer.jsp" />