package com.test.model;

public class MemberVO {
	private int no;
	private String name;
	private String email;
	private String tel;
	private String addr;
	private String writeday;
	
	public MemberVO() {}

	public MemberVO(int no, String name, String email, String tel, String addr, String writeday) {
		super();
		this.no = no;
		this.name = name;
		this.email = email;
		this.tel = tel;
		this.addr = addr;
		this.writeday = writeday;
	}

	public int getNo() {
		return no;
	}

	public void setNo(int no) {
		this.no = no;
	}

	public String getName() {
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

	public String getWriteday() {
		return writeday;
	}

	public void setWriteday(String writeday) {
		this.writeday = writeday;
	}
	
	
}
