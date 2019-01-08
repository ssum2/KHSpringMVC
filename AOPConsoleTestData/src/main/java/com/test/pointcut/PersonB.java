package com.test.pointcut;

public class PersonB implements IQuiz {
	String grade;
	@Override
	public String getGrade() {
		return grade;
	}
	@Override
	public void setGrade(String grade) {
		this.grade = grade;
	}
	
	@Override
	public void showPerson(int age, String name) {
		System.out.println("▶ 클래스명; PersonB ----------");
		System.out.println("1. age: "+ age);
		System.out.println("2. name: "+ name);
		System.out.println("---------------------------");

	}
	@Override
	public int calc(int kor, int eng, int math) {
		int total = (int)(kor*0.2) + (int)(eng*0.3) + (int)(math*0.5);
		System.out.println("----------------------- \nPersonB의 total: "+total);
		return total;
	}
	
	private String passwd;
	@Override
	public String getPasswd() {
		return passwd;
	}
	@Override
	public void setPasswd(String passwd) throws MyException{
		if(passwd == null || (passwd != null && passwd.length() < 10)) {
			this.passwd = passwd;
			throw new MyException(">> 암호의 길이는 10글자 이상이어야합니다.");
		}
		this.passwd = passwd;
	}

}
