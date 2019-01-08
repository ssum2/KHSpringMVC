<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<% 
   String ctxPath = request.getContextPath(); 
   //  /startspring 임.
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>search form</title>
<script src="<%= ctxPath %>/resources/js/jquery-3.3.1.min.js"></script>
<style type="text/css">
	table { border: 1px solid gray; 
			border-collapse: collapse;}
	th, td { border: 1px solid gray; 
			 border-collapse: collpase;}
</style>
<script type="text/javascript">
	$(document).ready(function(){
		$("#display").hide();
		
		$("#addrSearch").keydown(function(event){
			if(event.keyCode == 13){
				var addrSearch = $(this).val();
				callAjax(addrSearch);
				
				return false;
				/*
	  		     JSP 페이지에서 Enter 이벤트 발생시
	  		     JSP 페이지에 input type의 text 박스가 오로지 하나인 경우에는
	  		           엔터를 치면 입력한 글자가 사라진다.
	  		           그래서 입력한 글자가 사라지지 않게 하려면
	  		           맨끝에 return false; 를 적어주면 사라지지 않는다.
	  		   */
			}
		});

		
		$("#btnSearch").click(function(){
			var addrSearch=$("#addrSearch").val();
			callAjax(addrSearch);
		});
		
		$("#btnClear").click(function(){
			$("#addrSearch").val("");
			$("#addrSearch").focus();
			$("#result").empty();
			$("#display").hide();
		});
	
		
	});
	
	function callAjax(addrSearch){
		var data_form = {"addrSearch":addrSearch};
		$.ajax({
			url:"mybatisTest13JSON.action",
//			url:"mybatisTest13JSON.action?addrSearch="+addrSearch << 이런식으로도 데이터를 보낼 수 있음(GET방식)
			type:"GET",
			data:data_form,
			dataType:"JSON",
			success:function(json){
				
				$("#result").empty();
				if(json.length > 0){
					$.each(json, function(entryIndex, entry){
						var html = "<tr>"+
									"<td>"+(entryIndex+1)+"</td>"+
									"<td>"+entry.NO+"</td>"+
									"<td>"+entry.NAME+"</td>"+
									"<td>"+entry.EMAIL+"</td>"+
									"<td>"+entry.TEL+"</td>"+
									"<td>"+entry.ADDR+"</td>"+
									"<td>"+entry.WRITEDAY+"</td>"+
									"<td>"+entry.BIRTHDAY+"</td>"+
									"</tr>";

						$("#result").append(html);	
					});
				}
				else{
					$("#result").html("<tr><td colspan='8' style='font-weight: bold; color: red;'>검색된 데이터가 없습니다.</td></tr>");
				}
				$("#display").show();
			},
			error: function(request, status, error){
				if(request.readyState == 0 || request.status == 0) return;
				else alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
			}
		});
	}

</script>	

</head>
<body>

	<div align="center">
		<h2>주소를 입력받아 해당 주소에 거주하는 회원들을 찾아주는 페이지(Ajax; JSONArray사용)</h2>
		<h3>(/mybatistest/mybatisTest13.action)</h3>
		
		<form name="searchFrm">
			주소 : <input type="text" id="addrSearch"/>
			<br/><br/>
			<button type="button" id="btnSearch">찾기</button>&nbsp;&nbsp;
			<button type="button" id="btnClear">초기화</button>
		</form>
	</div>
	<div id="display" align="center" style="margin-top: 50px;">
		<table>
			<thead>
				<tr>
					<th>일련번호</th>
					<th>회원번호</th>
					<th>성명</th>
					<th>이메일</th>
					<th>전화</th>
					<th>주소</th>
					<th>가입일자</th>
					<th>생일</th>
				</tr>
			</thead>
			<tbody id="result">
			</tbody>
		</table>
	</div>

</body>
</html>
