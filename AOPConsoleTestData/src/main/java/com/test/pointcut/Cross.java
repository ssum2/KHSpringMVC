package com.test.pointcut;

import java.util.HashMap;
import java.util.Set;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.After;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

// Cross class; 보조업무 클래스 --> Aspect(관점, 목적) 애노테이션 필요
@Aspect
public class Cross {
	@Pointcut("execution(public void com.test.pointcut.Core.m1())")	
	// 식별자메소드인 pc1을 기준으로 execution(~~m1())메소드로 잘라온다
	// 접근제한자 public 생략가능
	// 동일한 패키지인 경우  com.test.pointcut 패키지 생략 가능
	public void pc1() {}
	
	@Before("pc1()") 	// m1이라는 주업무메소드를 실행하기 앞서서 Before에 등록된 메소드를 먼저 실행
	public void before(JoinPoint joinPoint) {
		System.out.println("보조업무");
		
//		#JoinPoint타입 파라미터를 받아오면 주업무객체를 사용할 수 있음	
		System.out.println("주업무객체: "+joinPoint.getTarget());
//		주업무객체: com.test.pointcut.Core@2aa5fe93
		
/*		JoinPoint.getTarget() = 주업무 Object
		getTarget()은 주업무객체를 반환하기 때문에 이것을 사용하면 주업무의 여러가지 정보를 얻어올 수 있다.
	 	이를 통해 보조업무에서 다양한 적용이 가능하다.
 */
//		cf) Pointcut AspectJ 형식을 반환함
		System.out.println("Pointcut AspectJ Long: "+joinPoint.toLongString());
		System.out.println("Pointcut AspectJ Short: "+joinPoint.toShortString());
		System.out.println("Pointcut AspectJ normal: "+joinPoint.toString());
/*		Pointcut AspectJ Long: execution(public abstract void com.test.pointcut.ICore.m1())
		Pointcut AspectJ Short: execution(ICore.m1())
		Pointcut AspectJ normal: execution(void com.test.pointcut.ICore.m1())	*/
		
//		#Pointcut 메소드 형식을 반환
		System.out.println("Pointcut Signature: " + joinPoint.getSignature());
//		>> Pointcut Signature: void com.test.pointcut.ICore.m1()
		
//		#인자값 리스트 반환; Pointcut의 파라미터값을 반환
//		=> 주업무 객체가 실행되기 위해 필요한 인자값 정보에 보조업무 객체가 접근가능
		System.out.println(joinPoint.getArgs());
//		>> [Ljava.lang.Object;@2b6856dd
		
	}
	
	@Pointcut("execution(public * Core.m2())")	
	public void pc2() {}
	
	
	@Before("pc2()")
	public void before2(JoinPoint joinPoint) {
//		#주업무객체 가져오기; Object타입을 Core클래스 타입으로 캐스팅
		Core core = (Core)joinPoint.getTarget();
		System.out.println(core.num);
		System.out.println(core.getName());
		
	}
	
	@Pointcut("execution(public * Core.m3(String, String))")	
	public void pc3() {}
	
	HashMap<String, String> mapColor = new HashMap<String, String>();
	HashMap<String, String> mapSubject = new HashMap<String, String>();
	
	@After("pc3()")
	public void after(JoinPoint joinPoint) {
		System.out.println("▶ After 메소드");
		System.out.println("------------ color -------------");
//		#주업무가 실행되고 난 후, 주업무의 값을 분석하기
		String color = (String)joinPoint.getArgs()[0];	// 배열에서 String타입 캐스팅해서 값을 가져옴
//		MainTest에서 Core.m3(String color, Stirng subject) 메소드를 호출할 때  
//		첫번째 파라미터인 String color 값을 반환받아옴
		
		if(color != null && !color.trim().isEmpty()) {
			if(color.equalsIgnoreCase("red")) {
				mapColor.put(color, "빨강");
			} else if(color.equalsIgnoreCase("blue")) {
				mapColor.put(color, "파랑");
			} else if(color.equalsIgnoreCase("yellow")) {
				mapColor.put(color, "노랑");
			} else if(color.equalsIgnoreCase("green")) {
				mapColor.put(color, "초록");
			} else {
				mapColor.put(color, "기타색상");
			}
		}
		else {
			color = "none";
			mapColor.put(color, "없음");
		}
		Set<String> keyset =  mapColor.keySet();
		
		for(String key : keyset) {
			System.out.println(key+"="+mapColor.get(key));
		}
		
		System.out.println("------------ subject -----------");
		String subject = (String)joinPoint.getArgs()[1];
		if(subject != null && !subject.trim().isEmpty()) {
			if(subject.equalsIgnoreCase("kor")) {
				mapSubject.put(subject, "국어");
			} else if(color.equalsIgnoreCase("eng")) {
				mapSubject.put(subject, "영어");
			} else if(color.equalsIgnoreCase("math")) {
				mapSubject.put(subject, "수학");
			} else if(color.equalsIgnoreCase("science")) {
				mapSubject.put(subject, "과학");
			} else if(color.equalsIgnoreCase("society")) {
				mapSubject.put(subject, "사회");
			} else {
				mapSubject.put(subject, "기타과목");
			}
		}
		else {
			subject = "none";
			mapSubject.put(subject, "없음");
		}
		Set<String> keyset2 =  mapSubject.keySet();
		
		for(String key : keyset2) {
			System.out.println(key+"="+mapSubject.get(key));
		}
		
	}
	
	
//////===== !!!!! 정리 !!!!! ===== //////
	/*
	      주업무 객체에서 보조업무 객체로 무언가를 전달하려면......
	   1. 주업무 객체의 멤버값  (public 으로 전달)
	     --> JoinPoint 의   getTarget() 사용
	     
	   2. 주업무 객체의 Pointcut의 인자값
	     --> JoinPoint 의  getArgs() 사용
	     
	   3. 주업무 객체의 Pointcut의 결과값 
	     --> After returning Advice 사용    
	*/
	
	/*
 === Pointcut 명시자 대신에 within 명시자를 사용해서 선언하기 ===
		- within 명시자는 특정 타입에 속하는 메소드를 Pointcut으로 설정한다.
		- 타입 패턴만을 이용해서 Pointcut을 설정한다.
		- within 명시자는 execution 명시자에 비해 세밀도가 떨어진다.
		
		ex) @Pointcut("within(com.test.pointcut.Core)")
			- com.test.pointcut.Core 클래스의 모든 메소드를 Pointcut으로 선언한다.
		ex) @Pointcut("within(Core)")
			- 위의 예의 패키지 생략 표현
		ex) @Pointcut("within(com.test.pointcut.*)")
			- com.test.pointcut 패키지내의 모든 클래스의 모든 메소드를 Pointcut으로 선언한다.
		ex) @Pointcut("within(com.test...*)")
			- com.test와 그 하위 패키지내의 모든 클래스의 모든 메소드를 Pointcut으로 선언한다.
 */

	@Pointcut("within(com.test.pointcut.Core)")
	public void pc4() { }

	@Before("pc4()")
	public void before4() {
		System.out.println(">>>>보조업무4<<<<");	// Core클래스의 메소드를 실행할 때마다 무조건
	}


/*	
	=== Pointcut 명시자 대신에 bean 명시자를 사용해서 선언하기 ===
		- baen 명시자는 빈 이름의 패턴을 사용해서 Pointcut을 설정한다.
		- Spring에서만 사용 가능한 명시자이다. (AspectJ에는 없다.)
		
		ex) @Pointcut("bean(core)")
			- 빈 이름이 "core"인 클래스의 모든 메소드를 Pointcut으로 선언한다.
		ex) @Pointcut("bean(c*)")
			- 빈 이름이 "c"로 시작하는 모든 클래스의 모든 메소드를 Pointcut으로 선언한다.
		ex) @Pointcut("bean(*c)")
			- 빈 이름이 "c"로 끝나는 모든 클래스의 모든 메소드를 Pointcut으로 선언한다.

*/

	@Pointcut("bean(core)")	// xml에 정의된 bean의 id가 core인 것
	public void pc5() { }

	@Before("pc5()")
	public void before5() {
		System.out.println("====보조업무5====");
	}
	
	
	
}
