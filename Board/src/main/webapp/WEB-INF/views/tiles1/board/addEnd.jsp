<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<script type="text/javascript">
	if(${result==1}){
		alert("글 작성 완료");
	}
	else{
		alert("글 작성 실패");
	}
	
	location.href="${loc}";

</script>