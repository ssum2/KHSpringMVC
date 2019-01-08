package com.test.pointcut;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.After;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class Cross {

    ///////////////  1 : 1  관계    /////////////////////	
	@Pointcut("execution(public void com.test.pointcut.Core.m1())")  
	public void pc1() {}
 // public void target() {} ==> Pointcut 메소드는 "target()" 이라는 이름은 사용 불가능!!! 예약어이다.           
	
	
	@Around("pc1()")
	public void around1(ProceedingJoinPoint joinPoint) 
		throws Throwable {
		
		// 보조업무 시작
		System.out.println("===> 시간 기록 시작 <===");
		long start = System.currentTimeMillis();
		
		
		try {
			// 주업무 시작
			 
			joinPoint.proceed();
			
			// 주업무 끝
			
		} finally {
			long finish = System.currentTimeMillis();
			System.out.println("===> 시간 기록 끝 <===");
			
			System.out.println("== 주업무1 실행시간 : " + (finish-start) + "ms"); 
			// 보조업무 끝	
		}
		
	}
	
	
    ///////////////  1 : N  관계    /////////////////////
	@Pointcut("execution(public void com.test.pointcut.Core.m2())")  
	public void pc2() {}
	
	
	@Around("pc2()")
	public void around2(ProceedingJoinPoint joinPoint) 
		throws Throwable {
		
		// 보조업무 시작
		System.out.println("===> 시간 기록 시작 <===");
		long start = System.currentTimeMillis();
		
		
		try {
			// 주업무 시작
			 
			joinPoint.proceed();
			
			// 주업무 끝
			
		} finally {
			long finish = System.currentTimeMillis();
			System.out.println("===> 시간 기록 끝 <===");
			
			System.out.println("== 주업무2 실행시간 : " + (finish-start) + "ms"); 
			// 보조업무 끝	
		}
		
	}
	
	
	@Before("pc2()")
	public void before() {
		System.out.println("== Cross 클래스의 before()메소드 호출 ==");
	}
	
	
	@After("pc2()")
	public void after() {
		System.out.println("== Cross 클래스의 after()메소드 호출 ==");
	}
	
	
    ///////////////  N : 1  관계    /////////////////////
	@Pointcut("execution(public void com.test.pointcut.Core.my*())")  
	public void pc3() {}
	
	
	@Before("pc3()")
	public void mybefore() {
		System.out.println("== Cross 클래스의 mybefore()메소드 호출 ==");
	}
	
	
    ///////////////  N : N  관계    /////////////////////
	@Pointcut("execution(public * com.test.pointcut.Core.m*(..))")  
	public void pc4() {}
	
	@Before("pc4()")
	public void mybefore2() {
		System.out.println(">>> Cross 클래스의 mybefore2()메소드 호출 <<<");
	}

	@After("pc4()")
	public void myafter2() {
		System.out.println(">>> Cross 클래스의 myafter2()메소드 호출 <<<");
	}
	
 /*
	====== Pointcut 선언시 메소드 표현방법(AspectJ 표현식) 살펴보기 ======
	
	- 스프링에서는 joinPoint 를 지정하기 위해서 Pointcut 을 정의할때 AspectJ 표현식을 확장해서 사용한다.   
	- Pointcut 선언은 execution, within, bean 명시자가 있다.
	    아래의 설명은 execution 명시자를 사용하는 것이다.
	
	  execution([접근자지정패턴] 리턴타입패턴 [패키지패턴]메소드이름패턴(파라미터패턴)) 
	  
	  - 와일드카드(*) 사용이 가능하다.
	  - .. 은 0 또는 그 이상이란 표현이다.
	  - 나머지는 자바표현과 동일하다.
	  
	  ex) @Pointcut("execution(public void com.test.pointcut.Core.m1())")
	      - 해당 패키지의 Core클래스의 m1() 이라는 메소드를 Pointcut 으로 지정한다.
	  
	  ex) @Pointcut("execution(void com.test.pointcut.Core.m1())")
	      - public 은 생략이 가능하다.(public 이 아니면 Pointcut이 될수 없기 때문에..)
	      
      ex) @Pointcut("execution(void Core.m1())")
	      - 주업무 객체와 보조업무 객체가 같은 패키지면 패키지도 생략이 가능하다. 
	      
	  ex) @Pointcut("execution(void Core.*())")
	      - Core클래스의 인자값이 없는 모든 메소드를 Pointcut으로 지정한다.
	      
	  ex) @Pointcut("execution(void Core.a*())")
	      - Core클래스의 인자값이 없고, 이름이 a로 시작하는 모든 메소드를 Pointcut으로 지정한다.
	      
      ex) @Pointcut("execution(void Core.*ing())")
	      - Core클래스의 인자값이 없고, 이름이 ing로 끝나는 모든 메소드를 Pointcut으로 지정한다.
	      
	  ex) @Pointcut("execution(void Core.*(int))")
	      - Core클래스의 인자값이 int 1개를 가지는 모든 메소드를 Pointcut으로 지정한다.
	      
	  ex) @Pointcut("execution(void Core.*(int,String))")
          - Core클래스의 인자값이 2개를(int,String) 가지는 모든 메소드를 Pointcut으로 지정한다.	      
	      	      
	  ex) @Pointcut("execution(void Core.m1(..))")
	      - Core클래스의 인자값이 0개 이상이며, 이름이 m1인 모든 메소드를 Pointcut으로 지정한다. 
	        (즉, 오버로딩된 모든 m1들이 Pointcut으로 설정된다.)
	        	           
	  ex) @Pointcut("execution(void Core.*(..))")            
	      - Core클래스의 리턴타입이 void 이고, 인자값이 0개 이상인 모든 메소드를 Pointcut으로 지정한다. 
	      
	  ex) @Pointcut("execution(int Core.*(..))")      
	      - Core클래스의 리턴타입이 int 이고, 인자값이 0개 이상인 모든 메소드를 Pointcut으로 지정한다.
	      
	  ex) @Pointcut("execution(* Core.*(..))")   
	      - Core클래스의 리턴타입은 어느것이든 상관없고, 인자값이 0개 이상인 모든 메소드를 Pointcut으로 지정한다.        
	  
	  ex) @Pointcut("execution(* com.test.aop..*(..))")
	      - com.test.aop 패키지 이하의 모든 클래스가 가지는 메소드를 Pointcut으로 지정한다.       
	
 */
	
	
	 // === Pointcut 선언을 따로 하지 않고 Advice 선언과 동시에 할 수도 있다. ===
	 @Before("execution(void hello())")	
	 public void pBefore() {
		 System.out.println("Pointcut 선언없이 직접 연결한 Before보조업무");
	 }
	 
	 @After("execution(void hello())")	
	 public void pAfter() {
		 System.out.println("Pointcut 선언없이 직접 연결한 After보조업무");
	 }
	
	
	
}
