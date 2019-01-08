<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
   
<style type="text/css">
	table, th, td, input, textarea {border: solid gray 1px;}
	
	#table, #table2 {border-collapse: collapse;
	 		         width: 1000px;
	 		        }
	#table th, #table td{padding: 5px;}
	#table th{width: 120px; background-color: #DDDDDD;}
	#table td{width: 860px;}
	.long {width: 470px;}
	.short {width: 120px;} 	
	
	.move  {cursor: pointer;}
	.moveColor {color: #660029; font-weight: bold;}
	
	a{text-decoration: none;}	
	
	

</style>

<script type="text/javascript">
    
	$(document).ready(function(){
	
		$(".move").hover(function(){
	       $(this).addClass("moveColor");
	     }, 
	     function(){
	  	   $(this).removeClass("moveColor");   
	     });
	
// [190103] 
//		#댓글 목록 ajax로 나타내기
		if(${boardvo.commentCount > 0} ){
			// 초기치 설정(최신댓글순으로 한 페이지에 최대 5개까지 노출)
			goViewComment("1"); // 파라미터로 초기페이지(처음 노출될 페이지번호)값을 설정
			
		}
	});// end of $(document).ready()----------------------
    
//	#댓글 작성하기
	function goAddWrite() {
		var frm = document.addWriteFrm;
		var nameval = frm.name.value.trim();
		if(nameval==""){
			alert("로그인 후 이용 가능합니다.");
			location.href= "<%= request.getContextPath() %>/login.action";
			return;
		}
		
		var contentval = frm.content.value.trim();
		
		if(contentval==""){
			alert("댓글 내용을 입력하세요.");
			frm.content.value="";
			frm.content.focus();
			return;
		}
		
		var queryString = $("form[name=addWriteFrm]").serialize();
		// >> &로 form의 값들이 엮여서 나옴
		// console.log(queryString);	// fk_userid=ssum&name=%EB%B0%B0%EC%88%98%EB%AF%B8&content=hello&parentSeq=8
		
		$.ajax({
			url:"<%= request.getContextPath() %>/addComment.action",
			data: queryString,
			type: "POST",
			dataType: "JSON",
			success: function(json){
				var html = "<tr>"+
							"<td style='text-align: center;'>";
							if("${boardvo.fk_userid}"== json.fk_userid){
								html += json.name+"(글작성자)</td>";
							}
							else {
								html += json.name+"</td>";
							}
							html +="<td>"+json.content+"</td>"+
							"<td style='text-align: center;'>"+json.regdate+"</td>"+
							"</tr>";
				
				$("#commentDisplay").prepend(html);
				frm.content.value="";
			},
			error: function(request, status, error){
				if(request.readyState == 0 || request.status == 0) return;
				else alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
			}
		});
	} // end of goWrite
	
//	#Ajax로 댓글 목록을 페이징처리하여 보여주는 함수	
	function goViewComment(currentShowPageNo){
		var form_data = {"parentSeq":"${boardvo.seq}",
						"currentShowPageNo":currentShowPageNo,
						}
		$.ajax({
			url: "<%= request.getContextPath() %>/commentList.action",
			data: form_data,
			type: "GET",
			dataType: "JSON",
			success: function(json){
				// 1) 페이징 처리된 댓글 목록 가져오기
				var resultHTML = "";
				$.each(json, function(entryIndex, entry){
					resultHTML += "<tr>"+
								"<td style='text-align: center;'>";
					if("${boardvo.fk_userid}" == entry.fk_userid){
						resultHTML += entry.name+"(글쓴이)</td>";
					}
					else {
						resultHTML += entry.name+"</td>";
					}
					resultHTML +="<td>"+entry.content+"</td>"+
								"<td style='text-align: center;'>"+entry.regdate+"</td>"+
								"</tr>";
				});
				
				$("#commentDisplay").empty().html(resultHTML);
				
				// 2) 페이지바 함수 호출
				makeCommentPageBar(currentShowPageNo);
			},
			error: function(request, status, error){
				if(request.readyState == 0 || request.status == 0) return;
				else alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
			}
			
		});
	} // end of goViewComment
	
//	#Ajax로 댓글목록의 페이지바 만들기
	function makeCommentPageBar(currentShowPageNo){
		var form_data = {parentSeq:"${boardvo.seq}",
						sizePerPage:"5"};
		$.ajax({
			url: "<%= request.getContextPath()%>/getCommentTotalPage.action",
			data: form_data,
			type:"GET",
			dataType:"JSON",
			success: function(json){
				
				if(json.totalPage > 0){
					// 댓글이 있는 경우 
					var totalPage = json.totalPage;
					var pageBarHTML = "";
					
					// 블럭사이즈; 1개의 페이지바블럭 당 페이지번호 개수
					var blockSize = 10;
					
					// 루프; 1부터 증가하여 1개 블럭을 이루는 페이지번호의 갯수(블럭사이즈가 10일때 loop는 1~10)
					var loop = 1; 
					
					// 페이지바 한 블럭에 해당하는 번호
					var pageNo = Math.floor((currentShowPageNo-1)/blockSize)*blockSize+1;
					/*
							현재 페이지		pageNo
						--------------------------
							1			1	Math.floor((1-1)/10)*10+1 = 1
							2			1	Math.floor((2-1)/10)*10+1 
											= 1/10을 javascript에서 0.1로 출력 
											--> Math.floor로 0.1보다 작은 최소의 정수값 0으로 만듦 ==> 1
							3			1	그 아래 항도 0.n 형태여서 Math.floor로 0으로 만듦
							...
							10			1
							11			2
							...
							21			3
							...
					*/
					if( pageNo!= 1){
						pageBarHTML += "&nbsp;<a href='javascript:goViewComment(\""+(pageNo-1)+"\");'>[이전]</a>&nbsp;";
					}
					while(!(loop>blockSize || pageNo > totalPage)){
						if(pageNo == currentShowPageNo){
							pageBarHTML += "&nbsp;<span style='font-weight: bold; text-decoration:underline; color: maroon;'>"+pageNo+"</span>&nbsp;";
						}
						else{
							pageBarHTML += "&nbsp;<a href='javascript:goViewComment(\""+pageNo+"\");'>"+pageNo+"</a>&nbsp;";
						}
						
						loop++;
						pageNo++;
					}
					
					if( !(pageNo>totalPage)){
						pageBarHTML += "&nbsp;<a href='javascript:goViewComment(\""+pageNo+"\");'>[다음]</a>&nbsp;";
					}
					
					$("#pageBar").empty().html(pageBarHTML);
				}
				else{
					// 댓글이 없는 경우
					$("#pageBar").empty();
					pageBarHTML = "";
				}
			},
			error: function(request, status, error){
				if(request.readyState == 0 || request.status == 0) return;
				else alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
			}
			
		});
		
	} // end of makeCommentPageBar
    
</script>

<div style="padding-left: 10%; border: solid 0px red;">
	<h1>글내용보기</h1>
	
	<table id="table">
		<tr>
			<th>글번호</th>
			<td>${boardvo.seq}</td>
		</tr>
		<tr>
			<th>성명</th>
			<td>${boardvo.name}</td>
		</tr>
		<tr>
           	<th>제목</th>
           	<td>${boardvo.subject}</td>
        	</tr>
		<tr>
			<th>내용</th>
			<td><div>${boardvo.content}</div></td>
		</tr>
		<tr>
			<th>조회수</th>
			<td>${boardvo.readCount}</td>
		</tr>
		<tr>
			<th>날짜</th>
			<td>${boardvo.regDate}</td>
		</tr>
	<%-- ===== #148. 첨부파일 이름 및 파일크기를 보여주고 다운로드하게 만들기 --%>
		<tr>
			<th>첨부파일</th>
			<td>
				<c:if test="${sessionScope.loginuser != null}">
					<a href="<%= request.getContextPath() %>/download.action?seq=${boardvo.seq}">${boardvo.orgFilename}</a>
				</c:if>
				<c:if test="${sessionScope.loginuser == null}">
					${boardvo.orgFilename}
				</c:if>
			</td>
		
		</tr>
		<tr>
			<th>파일크기</th>
			<td>${boardvo.fileSize}</td>
		</tr>

	</table>
	
	<br/>
	
	<div style="margin-bottom: 1%;">이전글 : <span class="move" onClick="javascript:location.href='view.action?seq=${boardvo.previousseq}'">${boardvo.previoussubject}</span></div>
	<div style="margin-bottom: 1%;">다음글 : <span class="move" onClick="javascript:location.href='view.action?seq=${boardvo.nextseq}'">${boardvo.nextsubject}</span></div>
	
	<br/>
	
	<button type="button" onClick="javascript:location.href='<%= request.getContextPath() %>/${goBackURL}'">목록보기</button>
	<c:if test="${sessionScope.loginuser.userid eq boardvo.fk_userid}">
	<button type="button" onClick="javascript:location.href='<%= request.getContextPath() %>/edit.action?seq=${boardvo.seq}'">수정</button>
	<button type="button" onClick="javascript:location.href='<%= request.getContextPath() %>/del.action?seq=${boardvo.seq}'">삭제</button>
	</c:if>
	<%-- ===== #123. 답글쓰기 버튼 추가 ===== --%>
	<button type="button" onClick="javascript:location.href='<%= request.getContextPath() %>/add.action?fk_seq=${boardvo.seq}&groupno=${boardvo.groupno}&depthno=${boardvo.depthno}'">답글쓰기</button>	
	<br/>
	<br/>
		
	<%-- [190102] 댓글작성하기 --%>
	<p style="margin-top: 3%; font-size: 16pt;">댓글쓰기</p>
	<%-- ===== #84. 댓글쓰기 폼 추가 ===== --%>
	<form name="addWriteFrm">
		<input type="hidden" name="fk_userid" value="${sessionScope.loginuser.userid}" readonly /> 
		성명 : <input type="text" name="name" value="${sessionScope.loginuser.name}" class="short" readonly /> 
		댓글내용 : <input type="text" name="content" class="long" />

		<!-- 댓글에 달리는 원게시물 글번호(즉, 댓글의 부모글 글번호) -->
		<input type="hidden" name="parentSeq" value="${boardvo.seq}" />

		<button type="button" onClick="goAddWrite();">쓰기</button>
	</form>
	<%-- #91. 댓글 내용 보여주기 --%>
	<table id="table2" style="margin-top: 2%; margin-bottom: 3%;">
		<thead>
			<tr>
				<th style="text-align: center;">댓글 사용자</th>
				<th style="text-align: center;">내용</th>
				<th style="text-align: center;">작성일</th>
			</tr>
		</thead>
		<tbody id="commentDisplay">
			<%-- <c:if test="${commentList !=null}">
			<c:forEach var="cvo" items="${commentList}">
				<tr>
					<c:if test="${boardvo.fk_userid == cvo.fk_userid}">
						<td style="text-align: center;">${cvo.name}(작성자)</td>
					</c:if>
					<c:if test="${boardvo.fk_userid != cvo.fk_userid}">
						<td style="text-align: center;">${cvo.name}</td>
					</c:if>
					<td>${cvo.content}</td>
					<td style="text-align: center;">${cvo.regDate}</td>
				</tr>
			</c:forEach>
			</c:if> --%>
		</tbody>
	</table>
	
	<div id="pageBar" style="height: 50px; margin-left: 30%;"></div>
</div>
