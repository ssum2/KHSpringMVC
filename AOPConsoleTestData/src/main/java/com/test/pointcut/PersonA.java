package com.test.pointcut;

public class PersonA implements IQuiz {
	
	private int age;
	private String name;
	
	private String grade;
	
	public int getAge() {
		return age;
	}


	public void setAge(int age) {
		this.age = age;
	}


	public String getName() {
		return name;
	}


	public void setName(String name) {
		this.name = name;
	}
	
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
		System.out.println("▶ 클래스명; PersonA ----------");
		System.out.println("1. 나이: "+ age);
		System.out.println("2. 성명: "+ name);
		System.out.println("---------------------------");
	}


	@Override
	public int calc(int kor, int eng, int math) {
		int total = (int)(kor*0.5) + (int)(eng*0.3) + (int)(math*0.2);
		System.out.println("----------------------- \nPersonA의 total: "+total);
		return total;
	}

	
	private String passwd;
	@Override
	public String getPasswd() {
		return passwd;
	}
	@Override
	public void setPasswd(String passwd) throws MyException{
		if(passwd == null || passwd.length() < 8) {
			this.passwd = passwd;
			throw new MyException("== 암호의 길이는 8글자 이상이어야합니다.");
		}
		this.passwd = passwd;
	}

}
