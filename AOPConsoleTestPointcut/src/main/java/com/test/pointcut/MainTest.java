package com.test.pointcut;

import org.springframework.context.ApplicationContext;
import org.springframework.context.support.GenericXmlApplicationContext;


public class MainTest {

	public static void main(String[] args) {
		
		// IoC(Inversion of Control)컨테이너(Spring컨테이너)로 사용되는 
		// ApplicationContext 객체 생성하기 
		// 이것은 XML 설정을 로드함으로써 생성할 수 있다. 
		ApplicationContext context = new GenericXmlApplicationContext("classpath:main.xml"); 
	
		// 빈(bean) 객체 생성하기
		ICore core = context.getBean("core", ICore.class); 
		// core.xml 파일에서 id 가 "core"로 되어진 객체를 얻어옴.	
		
		core.m1();
		core.m2();
		
		System.out.println("\r\n#######################\r\n");
		
		core.my1();
		core.my2();
		core.my3();
		
		System.out.println("\r\n---------------------\r\n");
		
		String result = core.me1("홍길동");
		System.out.println(result);
		
		int sum = core.me2(2, 5);
		System.out.println("합계 : " + sum);
		
		System.out.println("\r\n---------------------\r\n");
		core.hello();

	}

}
