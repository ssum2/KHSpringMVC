package com.test.pointcut;


//	Core class; 주업무 클래스
public class Core implements ICore {
	
	public int num = 100;
	private String name = "홍길동";
	
	public String getName() {
		return name;
	}
	
	
//	#주업무(1)
	@Override
	public void m1() {
		System.out.println("주업무 1");
	}

//	#주업무(2)
	@Override
	public void m2() {
		System.out.println("주업무 2");
	}

//	#주업무(3)
	@Override
	public void m3(String color, String subject) {
		System.out.println("주업무 3");
		System.out.println("색상: "+color);
		System.out.println("과목: "+subject);
		System.out.println("------------- m3 끝 -------------");
	}

//	#주업무(4)
	@Override
	public void m4() {
		System.out.println("주업무 4");
	}
}
