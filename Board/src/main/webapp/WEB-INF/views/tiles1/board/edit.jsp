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
		//전역변수
	    var obj = [];
	    
	    //스마트에디터 프레임생성
	    nhn.husky.EZCreator.createInIFrame({
	        oAppRef: obj,
	        elPlaceHolder: "content",
	        sSkinURI: "<%= request.getContextPath() %>/resources/smarteditor/SmartEditor2Skin.html",
	        htParams : {
	            // 툴바 사용 여부 (true:사용/ false:사용하지 않음)
	            bUseToolbar : true,            
	            // 입력창 크기 조절바 사용 여부 (true:사용/ false:사용하지 않음)
	            bUseVerticalResizer : true,    
	            // 모드 탭(Editor | HTML | TEXT) 사용 여부 (true:사용/ false:사용하지 않음)
	            bUseModeChanger : true,
	        }
	    });
		
	 	// 수정버튼
	    $("#btnUpdate").click(function(){
			//id가 content인 textarea에 에디터에서 대입
		    obj.getById["content"].exec("UPDATE_CONTENTS_FIELD", []);
		    
			// 유효성검사
			var subject = $("#subject").val().trim();
			if(subject == ""){
				alert("제목을 입력해주세요.");
				$("#subject").focus();
				return false;
			}
			
			var pw = $("#pw").val().trim();
			if(pw == ""){
	 			alert("암호를 입력해주세요.");
	 			$("#pw").focus();
	 			return false;
	 		}
		 	
	 		//폼 submit
		    var editFrm = document.editFrm;
		    editFrm.subject.value=$("#subject").val();
		    editFrm.content.value=$("#content").val();
		    editFrm.pw.value=$("#pw").val();
		    editFrm.action = "<%=ctxPath%>/editEnd.action";
		    editFrm.method = "POST";
		    editFrm.submit();
		 	
	    });
	
	});// end of $(document).ready()----------------------
    
</script>

<div style="padding-left: 10%; border: solid 0px red;">
	<h1>글 수정</h1>
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
			<td><input type="text" id="subject" class="long" value="${boardvo.subject}" /></td>
        </tr>
		<tr>
			<th>내용</th>
           	<td>
           	<%-- **textarea 태그에서 required="required" 속성을 사용하면  스마트 에디터는 오류가 발생하므로 사용하지 않는다. ** --%>
           	<textarea id="content" rows="10" cols="100" style="width:95%; height:412px;">${boardvo.content}</textarea>
           	</td>
		</tr>
		<tr>
			<th>암호</th>
			<td><input type="password" id="pw" class="short" /></td>
		</tr>

	</table>
	<br/>

	<button type="button" id="btnUpdate">수정완료</button>
	<button type="button" id="btn" onClick="javascript:history.back();">취소</button>
	
	<%-- hidden타입의 input태그가 있는 form --%>
	<form name="editFrm">
		<input type="hidden" name="seq" value="${boardvo.seq}"/>
		<input type="hidden" name="subject"/>
		<input type="hidden" name="content"/>
		<input type="hidden" name="pw"/>
	</form>
	<br/>
	<br/>
		
	
	<div>&nbsp;</div>
</div>
