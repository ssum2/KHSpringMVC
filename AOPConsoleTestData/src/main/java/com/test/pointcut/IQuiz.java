package com.test.pointcut;

public interface IQuiz {
	
	void showPerson(int age, String name);
	
	int calc(int kor, int eng, int math);
	
	String getGrade();
	void setGrade(String grade);
	
	public String getPasswd();
	public void setPasswd(String passwd) throws MyException;
	 
}
