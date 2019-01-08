package com.spring.trantestanno.model;

import java.util.HashMap;
import java.util.List;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;


//#14. DAO 선언
@Repository
public class NoticeDAO implements InterNoticeDAO {

	@Autowired //의존객체주입(DI : Dependency Injection) 
	private SqlSessionTemplate sqlsession;

	// 나의포인트 요청
	@Override
	public int getLoginUserPoint(String userid) {
		int point = sqlsession.selectOne("trantestanno.getLoginUserPoint", userid);
	    return point;
	}
	
	
	@Override
	public int insert_tx_notices(NoticeVO ntvo) {
		int n = sqlsession.insert("trantestanno.insert_tx_notices", ntvo);
	    return n;
	}

	
	@Override
	public int update_tx_notices(String writerid) {
		int n = sqlsession.update("trantestanno.update_tx_notices", writerid);
	    return n;
	}


	@Override
	public List<HashMap<String, String>> list() {
		List<HashMap<String, String>> list = sqlsession.selectList("trantestanno.list");
		return list;
	}


	@Override
	public HashMap<String, String> contentView(int seq) {
		HashMap<String, String> contentViewMap = sqlsession.selectOne("trantestanno.contentView", seq);
		return contentViewMap;
	}
	
	
}
