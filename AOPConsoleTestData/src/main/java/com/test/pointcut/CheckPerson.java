package com.test.pointcut;

import java.util.Scanner;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;

@Aspect	// 관심사 클래스로 지정
public class CheckPerson {

	@Pointcut("execution(public void com.test.pointcut.Person*.showPerson(int, String))")	
	public void pc1() {}
	
	@Before("pc1()")
	public void before(JoinPoint joinPoint) {
		int age = (Integer)joinPoint.getArgs()[0];
		/*PersonA personA = (PersonA)joinPoint.getTarget();
		PersonB personB = (PersonB)joinPoint.getTarget();*/
		if(age <= 0) {
			System.out.println("나이는 0보다 커야 합니다.입력하신 나이"+age+"는 사용할 수 없습니다.");
		
			/*Scanner sc = new Scanner(System.in);
			System.out.print(">> 새로운 나이를 입력하세요: ");
			int v_age = sc.nextInt();
			personA.setAge(v_age);*/
		}
		
		String name = (String)joinPoint.getArgs()[1];
		if(name.length() >= 10) {
			System.out.println("이름은 10글자 이상 입력할 수 없습니다.");
		}
		else if(name.trim().isEmpty()) {
			System.out.println("이름에 공백은 사용할 수 없습니다.");
		}
		
	}
	@Pointcut("execution(public int com.test.pointcut.Person*.calc(int, int, int))")	
	public void pc2() {}
	
	@AfterReturning(pointcut="pc2()", returning="total")
	public void afterReturningA(JoinPoint joinPoint, Object total) {
		System.out.println(">> afterReturningA 메소드 시작");
		int v_total = (Integer)total;
		IQuiz person = (IQuiz)joinPoint.getTarget();
		switch(v_total/10){
			case 10:
			case 9:
				person.setGrade("A");
				break;
			case 8:
				person.setGrade("B");
				break;
			case 7:
				person.setGrade("C");
				break;
			case 6:
				person.setGrade("D");
				break;
			default:
				person.setGrade("F");
				break;
		}
		System.out.println("grade: "+person.getGrade());
	}
	
	@Pointcut("execution(public void com.test.pointcut.Person*.setPasswd(String))")	
	public void pc3() {}
	
	@AfterThrowing(pointcut="pc3()", throwing="e")
	public void afterthrowing(JoinPoint joinPoint, Exception e) {
		IQuiz person =(IQuiz)joinPoint.getTarget();
		System.out.println("입력하신 암호 "+ person.getPasswd()+"는 사용할 수 없습니다.");
		System.out.println(">> 예외기록: "+e.getMessage());
	}


}
