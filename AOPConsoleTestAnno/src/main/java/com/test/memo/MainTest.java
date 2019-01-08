package com.test.memo;

import org.springframework.context.ApplicationContext;
import org.springframework.context.support.GenericXmlApplicationContext;

public class MainTest {

	public static void main(String[] args) {

		// IoC(Inversion of Control; 제어의 역전)컨테이너(Spring컨테이너)로 사용되는 
		// ApplicationContext 객체 생성하기 
		// 이것은 XML 설정을 로드함으로써 생성할 수 있다. 
		ApplicationContext context = new GenericXmlApplicationContext("classpath:memo.xml");

		// 빈(bean) 객체 생성하기
		IMemo memo = context.getBean("memo", IMemo.class); 
		// memo.xml 파일에서 id 가 "memo"로 되어진 객체를 얻어옴.
		
		//메모 쓰기 (프록시 객체를 통한 주업무 호출) around, before
//		memo.write("스프링 공부하기");
		
		//메모 수정(주업무 추가); after
//		memo.edit("AOP 공부하기");
		
		//메모 삭제(주업무 추가2); afterreturning
//		memo.del(5);
		
		//메모 읽기(주업무 추가3); afterthrowing
		try {
			memo.read(10);
			memo.read(-2);
		} catch (Exception e) {
		}
	}

}
