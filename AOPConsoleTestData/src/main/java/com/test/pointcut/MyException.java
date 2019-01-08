package com.test.pointcut;

public class MyException extends Exception {

	private static final long serialVersionUID = 1L;
	
//	#기본생성자
	public MyException() {
		super("암호의 길이는 8글자 이상이어야 합니다.");
	}
	
	
//	#파라미터가 있는 생성자
	public MyException(String errMsg) {
		super(errMsg);
	}
}

