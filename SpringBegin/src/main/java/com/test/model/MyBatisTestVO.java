package com.test.model;

public class MyBatisTestVO {
	String name;
	String email;
	String tel;
	String addr;
	
	public MyBatisTestVO() {}
	
	public MyBatisTestVO(String name, String email, String tel, String addr) {
		this.name = name;
		this.email = email;
		this.tel = tel;
		this.addr = addr;
	}
	
	public String getIrum() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getTel() {
		return tel;
	}
	public void setTel(String tel) {
		this.tel = tel;
	}
	public String getAddr() {
		return addr;
	}
	public void setAddr(String addr) {
		this.addr = addr;
	}
	
	
}
