package com.test.memo;

public interface IMemo {
	//주업무 - 메모 작성하기
	void write(String memo);
	
	// 주업무 - 메모 수정하기
	void edit(String memo);
	
	// 주업무 - 메모 삭제하기
	int del(int seq);
	
	// 주업무 - 메모 읽기
	void read(int seq) throws Exception;
}
