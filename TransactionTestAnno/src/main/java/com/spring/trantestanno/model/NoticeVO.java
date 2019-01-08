package com.spring.trantestanno.model;

public class NoticeVO {

	private String seq; 
	private String writerid;
	private String title;
	private String content;
	
	public NoticeVO() { }
	
	public NoticeVO(String seq, String writerid, String title, String content) {
		this.seq = seq;
		this.writerid = writerid;
		this.title = title;
		this.content = content;
	}

	public String getSeq() {
		return seq;
	}
	
	public void setSeq(String seq) {
		this.seq = seq;
	}
	
	public String getWriterid() {
		return writerid;
	}
	
	public void setWriterid(String writerid) {
		this.writerid = writerid;
	}
	
	public String getTitle() {
		return title;
	}
	
	public void setTitle(String title) {
		this.title = title;
	}
	
	public String getContent() {
		return content;
	}
	
	public void setContent(String content) {
		this.content = content;
	}
			
}
