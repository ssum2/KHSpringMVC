<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"> 

<jsp:include page="header.jsp" />

<style type="text/css">
   body {padding: 0.5%;}
   .table {width: 55%; margin-bottom: 2%;}
   .title {width: 15%; font-weight: bold; background-color: #ffffcc; vertical-align: middle !important; }  /* 부트스트랩 때문에 vertical-align: middle 이 적용이 안되므로 css가 안될시 !important 를 주어서 최우선으로 하도록 한다. !important 란 최우선으로 우선순위를 주는것 */
   .short {width: 50%; height: 30px;}
   .long  {width: 98%; height: 30px;}
   .btn {margin-right: 1%;}
</style>

<script type="text/javascript">
	$(document).ready(function(){
		$("#writerid").val("${sessionScope.userid}");
	});

	function goWrite() {
		var frm = document.writeFrm;
		frm.action = "addEnd_transaction.action";
		frm.method = "post";
		frm.submit();
	}
</script>

<div>
	<h2 style="margin-bottom: 2%;">트랜잭션처리<span style="color: blue;">함</span> : 글쓰기</h2>
	
	<form name="writeFrm">
		<table class="table table-bordered">
			<tr>
				<td class="title">아이디</td>
				<td><input type="text" name="writerid" id="writerid" class="short" /></td>
			</tr>
			<tr>
				<td class="title">글제목</td>
				<td><input type="text" name="title" class="long" /></td>
			</tr>
			<tr>
            	<td class="title">내용</td>
            	<td><textarea name="content" class="long" style="height: 200px;"></textarea></td>
         	</tr>
		</table>

		<button type="button" class="btn" onClick="goWrite();">완료</button>
		<button type="button" class="btn" onClick="history.back();">취소</button>
		<button type="button" class="btn" onClick="javascript:location.href='list.action'">글목록</button>
	</form>

</div>
<jsp:include page="footer.jsp" />
