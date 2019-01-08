package com.spring.tilestest.model;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

//====== #32. DAO 선언(@Repository)
@Repository
public class TilestestDAO implements InterTilestestDAO {

	//====== #33. 의존객체 주입하기(DI; Dependency Injection)
	@Autowired
	private SqlSessionTemplate sqlsession;
	
	
}
