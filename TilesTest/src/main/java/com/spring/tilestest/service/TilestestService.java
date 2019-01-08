package com.spring.tilestest.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.spring.tilestest.model.InterTilestestDAO;

//====== #31. Service 선언
@Service
public class TilestestService implements InterTilestestService{

	//====== #34. 의존객체 주입하기(DI; Dependency Injection)
	@Autowired
	private InterTilestestDAO dao;
}
