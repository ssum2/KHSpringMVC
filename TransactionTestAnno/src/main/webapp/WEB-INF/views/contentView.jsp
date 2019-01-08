<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"> 

<jsp:include page="header.jsp" />

<style type="text/css">
	body {padding: 0.5%;}	
   .table {width: 55%; margin-bottom: 1%;}
   .title {width: 15%; font-weight: bold; background-color: #ffffcc; vertical-align: middle !important; }  /* 부트스트랩 때문에 vertical-align: middle 이 적용이 안되므로 css가 안될시 !important 를 주어서 최우선으로 하도록 한다. !important 란 최우선으로 우선순위를 주는것 */
   .move  {cursor: pointer;}
   .moveColor {color: #660029; font-weight: bold;}
</style>

<script type="text/javascript">
	$(document).ready(function(){

		$(".move").hover(function(){
					       $(this).addClass("moveColor");
					     }, 
					     function(){
					  	   $(this).removeClass("moveColor");   
					     });
	
	});// end of $(document).ready()----------------------
	
</script>

<div>
	<h2 style="margin-bottom: 1%;">글상세 내용보기</h2>

		<table class="table table-bordered">
			<tr>
				<td class="title">글제목</td>
				<td>${contentViewMap.TITLE}</td>
			</tr>
			<tr>
				<td class="title">작성자</td>
				<td>${contentViewMap.NAME}</td>
			</tr>
			<tr>
            	<td class="title">내용</td>
            	<td style="height: 200px;">${contentViewMap.CONTENT}</td>
         	</tr>
		</table>
		
		<div style="margin-bottom: 1%;">이전글 : <span class="move" onClick="javascript:location.href='contentView.action?seq=${contentViewMap.PREVIOUSSEQ}'">${contentViewMap.PREVIOUSTITLE}</span></div>
		<div style="margin-bottom: 1%;">다음글 : <span class="move" onClick="javascript:location.href='contentView.action?seq=${contentViewMap.NEXTSEQ}'">${contentViewMap.NEXTTITLE}</span></div>
		<button type="button" class="btn" onClick="javascript:location.href='list.action'">글목록</button>

</div>
<jsp:include page="footer.jsp" />
