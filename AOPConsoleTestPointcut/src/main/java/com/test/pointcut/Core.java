package com.test.pointcut;

public class Core implements ICore {

	@Override // 주업무
	public void m1() {
		System.out.println("주업무1");
	}

	@Override // 주업무
	public void m2() {
		System.out.println("주업무2");
	}

	@Override
	public void my1() {
		System.out.println("주업무 my1");
	}

	@Override
	public void my2() {
		System.out.println("주업무 my2");
	}

	@Override
	public void my3() {
		System.out.println("주업무 my3");
	}

	@Override
	public String me1(String name) {
		String result = "나의 이름은 " + name + " 입니다.";
		return result;
	}

	@Override
	public int me2(int a, int b) {
		int sum = a + b;
		return sum;
	}

	@Override
	public void hello() {
		System.out.println("안녕하세요~~^^");
	}

}
