<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 

<% String ctxPath = request.getContextPath(); %>
   
<style type="text/css">
	table, th, td, input, textarea {border: solid gray 1px;}
	
	#table{border-collapse: collapse;
	 		         width: 1000px;
	 		        }
	#table th, #table td{padding: 5px;}
	#table th{width: 120px; background-color: #DDDDDD;}
	#table td{width: 860px;}
	.long {width: 470px;}
	.short {width: 120px;} 	

	a{text-decoration: none;}	
	
	

</style>

<script type="text/javascript">
    
	$(document).ready(function(){
	
	});// end of $(document).ready()----------------------
    
	function goDelete(){
 		// 폼 submit
	    var frm = document.delFrm;
 		
 		// 유효성검사
		var pw = frm.pw.value.trim();
		if(pw == ""){
 			alert("암호를 입력해주세요.");
 			$("#pw").focus();
 			return false;
 		}

		frm.action = "<%=ctxPath%>/delEnd.action";
		frm.method = "POST";
		frm.submit();
	}
</script>

<div style="padding-left: 10%; border: solid 0px red;">
	<h1 style="margin-bottom: 50px;">글 삭제</h1>

	<form name="delFrm">
		<table>
			<tr>
				<th>암호</th>
				<td>
					<input type="password" id="pw" name="pw" class="short"/>
					<input type="hidden" id="seq" name="seq" value="${seq}"/>
					<%-- 삭제해야할 글 번호와 함께 사용자가 입력한 암호를 전송하도록 함 --%>
				</td>
				
			</tr>
		</table>
	</form>
	<br/>

	<button type="button" onClick="goDelete();">확인</button>
	<button type="button" onClick="javascript:history.back();">취소</button>
	
	
	<br/>
	<br/>
		
	
	<div>&nbsp;</div>
</div>
