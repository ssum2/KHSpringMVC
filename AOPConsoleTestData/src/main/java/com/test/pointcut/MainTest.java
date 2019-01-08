package com.test.pointcut;

import org.springframework.context.ApplicationContext;
import org.springframework.context.support.GenericXmlApplicationContext;

public class MainTest {

	public static void main(String[] args){
		// IoC(Inversion of Control)컨테이너(Spring컨테이너)로 사용되는 
		// ApplicationContext 객체 생성하기 
		// 이것은 XML 설정을 로드함으로써 생성할 수 있다. 
		ApplicationContext context = new GenericXmlApplicationContext("classpath:main.xml"); 
	
		// 빈(bean) 객체 생성하기
		ICore core = context.getBean("core", ICore.class); 
		// core.xml 파일에서 id 가 "core"로 되어진 객체를 얻어옴.	
		
		core.m1();
		
		System.out.println("--------------------------------");
		core.m2();
		/*	결과화면
			--------------------------------
			100
			홍길동
			주업무 2*/
		
		
		System.out.println("\n------------- m3 시작 ------------");
		core.m3("red", "kor");
		System.out.println("\n------------- m3(2) ------------");
		core.m3("blue", "eng");
		System.out.println("\n------------- m3(3) ------------");
		core.m3("red", "math");
		System.out.println("\n------------- m3(4) ------------");
		core.m3(" ", "science");
		System.out.println("\n------------- m3(5) ------------");
		core.m3("yellow", "society");
		
/*		결과화면
		------------- m3 시작 ------------
		주업무 3
		색상: red
		과목: kor
		------------- m3 끝 -------------
		▶ After 메소드
		------------ color -------------
		red=빨강
		------------ subject -----------
		kor=국어
		
		------------- m3(2) ------------
		주업무 3
		색상: blue
		과목: eng
		------------- m3 끝 -------------
		▶ After 메소드
		------------ color -------------
		red=빨강
		blue=파랑
		------------ subject -----------
		kor=국어
		eng=기타과목
		
		------------- m3(3) ------------
		주업무 3
		색상: red
		과목: math
		------------- m3 끝 -------------
		▶ After 메소드
		------------ color -------------
		red=빨강
		blue=파랑
		------------ subject -----------
		math=기타과목
		kor=국어
		eng=기타과목
		
		------------- m3(4) ------------
		주업무 3
		색상:  
		과목: science
		------------- m3 끝 -------------
		▶ After 메소드
		------------ color -------------
		red=빨강
		blue=파랑
		none=없음
		------------ subject -----------
		science=기타과목
		math=기타과목
		kor=국어
		eng=기타과목
		
		------------- m3(5) ------------
		주업무 3
		색상: yellow
		과목: society
		------------- m3 끝 -------------
		▶ After 메소드
		------------ color -------------
		red=빨강
		blue=파랑
		yellow=노랑
		none=없음
		------------ subject -----------
		society=기타과목
		science=기타과목
		math=기타과목
		kor=국어
		eng=기타과목
*/

		System.out.println("\n================== quiz ====================");
//		================== quiz ====================	
		// 빈(bean) 객체 생성하기
		IQuiz personA = context.getBean("personA", IQuiz.class); 
		IQuiz personB = context.getBean("personB", IQuiz.class); 
		
//		#showPerson을 실행하기 전에 파라미터로 들어가는 age값을 먼저 검사하기
		personA.showPerson(0, "이순신");
		System.out.println("");
		
//		#파라미터 name의 길이, 공백 제한
		personB.showPerson(30, "       ");
		personA.showPerson(25, "이순신ㅇㄹㅇㄹㅇㄹㄴㄹㄴㅇㄹㅈㄷㄱㄹㄴㅇㄹㄴㅇㄹㄴㅇㄹㅇ");
	
//		#점수를 계산하여 등급 나타내기
		System.out.println("========= 점수 계산하기 ==========");
		personA.calc(100, 100, 70);
		System.out.println("personA의 grade: "+personA.getGrade());
		personB.calc(100, 100, 70);
		System.out.println("personB의 grade: "+personB.getGrade());
		
		
		
		
//		#패스워드 사용자정의 예외처리
		System.out.println("\n==============사용자 정의 예외처리==============");
		try {
			personA.setPasswd("a12345");
		} catch (MyException e) {
		}
		
		try {
			personB.setPasswd("a1234567");
		} catch (MyException e) {
		}
		
		

		
	}

}
