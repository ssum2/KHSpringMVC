<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%--
	이 파일은 xml데이터를 출력하지만 jsp 파일이기 때문에 <%@ ~ %> 설정도 함께 해줘야하는데, 이 과정에서 윗 부분에 여러줄의 공백이 생김
	>> trimDirectiveWhitespaces="true" ; 해당 파일의 상단, 하단 공백을 없애줌
	>> xml파일은 첫줄에 <?xml version="1.0" encoding="UTF-8" standalone="no" ?>가 와야하기 때문에 반드시 공백을 trim 해야함
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:import url="http://www.kma.go.kr/XML/weather/sfc_web_map.xml" charEncoding="UTF-8"/>