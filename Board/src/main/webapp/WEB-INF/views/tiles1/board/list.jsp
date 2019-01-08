<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% String ctxPath = request.getContextPath(); %>  
<style type="text/css">
	table, th, td {border: solid gray 1px;}
	#table {border-collapse: collapse; width: 750px;} 
	
	.subjectstyle {font-weight: bold;
    	           color: navy;
    	           cursor: pointer; }
	
	
	#table {border-collapse: collapse; width: 920px;}
	#table th, #table td {padding: 5px;}
	#table th {background-color: #DDDDDD;}
	
	a{text-decoration: none;} 
	
	    
</style>

 
<script type="text/javascript">
	$(document).ready(function(){
		
		$(".subject").bind("mouseover", function(event){
			 var $target = $(event.target);
			 $target.addClass("subjectstyle");
		});
		  
		$(".subject").bind("mouseout", function(event){
			 var $target = $(event.target);
			 $target.removeClass("subjectstyle");
		});
		
		if(${search !=null && colname != null }){
			searchKeep();
		}
		
	});// end of $(document).ready()----------------------
	
	function goView(seq, currentURL){
		var frm = document.goViewFrm;
		frm.seq.value=seq;
		frm.currentURL.value=currentURL;
		frm.method="GET";
		frm.action="view.action";
		frm.submit();
	}

	function goSearch() {
		var frm = document.searchFrm;
		frm.method="GET";
		frm.action="<%= request.getContextPath() %>/list.action";
		frm.submit();
	}
	
	
	function searchKeep(){
		$("#search").val("${search}");
		$("#colname").val("${colname}");
	}
	
		
</script>
<div class="container">
<div class="col-md-12" style="padding-left: 10%; border: solid 0px red;">
	<h1 style="margin-bottom: 30px;">글목록</h1>
	
	<!--  =====#105. 글검색 폼 추가하기; 제목, 내용, 글쓴이 검색 ===== -->
	<div style="margin-bottom: 5%;">
	<form name="searchFrm">
		<select name="colname" id="colname" style="height: 27px; font-size: 10pt;">
			<option value="subject">제목</option>
			<option value="content">내용</option>
			<option value="name">성명</option>
		</select>
		
		<input type="text" name="search" id="search" size="40"/>
		<button type="button" onClick="goSearch();">검색</button>
	</form>
	</div>
	
	<table id="table">
		<tr>
			<th style="width: 70px;  text-align: center;" >글번호</th>
			<th style="width: 360px; text-align: center;" >제목</th>
			<th style="width: 70px;  text-align: center;" >성명</th>
			<th style="width: 180px; text-align: center;" >날짜</th>
			<th style="width: 70px;  text-align: center;" >조회수</th>
			
		<%-- ===== #145. 게시글에 첨부파일이 있는 경우 파일과 크기를 보여주기 --%>
			<th style="width: 70px;  text-align: center;" >파일</th>
			<th style="width: 100px;  text-align: center;" >크기(bytes)</th>
		</tr>
		<c:forEach var="boardvo" items="${boardList}">
			<tr>
				<td align="center">${boardvo.seq}</td>
				<td>
				<%-- #132. 답변형게시판; 답변글인 경우 제목 첫머리에 공백과 함께 Re: 라는 글자를 붙여줌 --%>
				<c:if test="${boardvo.depthno==0}">
					<span class="subject" onClick="goView('${boardvo.seq}', '${currentURL}');">${boardvo.subject}</span>
				</c:if>
				<c:if test="${boardvo.depthno>0}">
					<span class="subject" onClick="goView('${boardvo.seq}', '${currentURL}');" style="color: blue; font-style: italic; padding-left: ${boardvo.depthno * 20}px;">└Re: ${boardvo.subject}</span> 
				</c:if>
				
				
				<%-- #97. 글제목에 댓글개수 달기 --%>
				<c:if test="${boardvo.commentCount==0}">
					</td>
				</c:if>
				<c:if test="${boardvo.commentCount>0}">
					<span style="vertical-align: super; font-style: italic; color: maroon;">[${boardvo.commentCount}]</span></td>
				</c:if>
				
				<td align="center">${boardvo.name}</td>
				<td align="center">${boardvo.regDate}</td>
				<td align="center">${boardvo.readCount}</td>
				<%-- ===== #146. 게시글에 첨부파일이 있는 경우 파일과 크기를 보여주기 --%>
				
				<c:if test="${not empty boardvo.fileName}">
					<td align="center"><img src="<%= ctxPath %>/resources/images/disk.gif" border="0"></td>
					<td align="center">${boardvo.fileSize}</td>
				</c:if>
				<c:if test="${empty boardvo.fileName}">
					<td align="center">파일없음</td>
					<td align="center">0</td>
				</c:if>
				
			</tr>
		</c:forEach>
		
	</table>
	<br/>
	
	<form name="goViewFrm">
		<input type="hidden" name="seq" id="seq" >
		<input type="hidden" name="currentURL" id="currentURL" >
	</form>
	<!--  =====#121. 페이지바 보여주기 ===== -->
	<div style="padding-left: 27%;">
		${pageBar}
	</div>
</div>
</div>