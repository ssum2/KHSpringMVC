package com.spring.trantestanno.model;

import java.util.HashMap;
import java.util.List;

public interface InterNoticeDAO {
	
	int getLoginUserPoint(String userid); // 나의포인트 요청
	
	int insert_tx_notices(NoticeVO vo);     // 글쓰기(tx_notices 테이블에 insert)
	
	int update_tx_notices(String writerid); // 포인트점수 증가(tx_member 테이블의 point 컬럼 1증가 업데이트)
	
	List<HashMap<String, String>> list(); // 글목록보기
	
	HashMap<String, String> contentView(int seq); // 글 상세내용 보기
}
