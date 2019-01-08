package com.spring.tilestest.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import com.spring.tilestest.service.InterTilestestService;

// ====== #30. Controller 선언
@Controller
public class TilestestController {

	//====== #35. 의존객체 주입하기(DI; Dependency Injection)
	@Autowired
	private InterTilestestService service;
	
//	#tiles resolver; tiles1(header-contents-footer)
	@RequestMapping(value="/test1.action", method={RequestMethod.GET})
	public String test1() {
	
		return "test/test1.tiles1";
	}
	
//	#tiles resolver; tiles2(header-contents-sideinfo-footer)
	@RequestMapping(value="/test2.action", method={RequestMethod.GET})
	public String test2() {
	
		return "test/test2.tiles2";
	}
	
//	#tiles resolver; notiles
	@RequestMapping(value="/test3.action", method={RequestMethod.GET})
	public String test3() {
	
		return "test3.notiles";
	}
	
//	#기본 resolver
	@RequestMapping(value="/test4.action", method={RequestMethod.GET})
	public String test4() {
	
		return "test4";
	}
	
	
//	[181228]
//	#ModelAndView 타입 리턴하기
	
//	1)tiles resolver; tiles1(header-contents-footer)
	@RequestMapping(value="/test5.action", method={RequestMethod.GET})
	public ModelAndView test5(ModelAndView mv) {
		
		mv.addObject("name", "오지명");
		mv.setViewName("test/test5.tiles1");
		
		return mv;
	}
	
//	2)tiles resolver; tiles2(header-contents-sideinfo-footer)
	@RequestMapping(value="/test6.action", method={RequestMethod.GET})
	public ModelAndView test6(ModelAndView mv) {
	
		mv.addObject("name", "육지명");
		mv.setViewName("test/test6.tiles2");
		
		return mv;
	}
	
//	3)tiles resolver; notiles
	@RequestMapping(value="/test7.action", method={RequestMethod.GET})
	public ModelAndView test7(ModelAndView mv) {
		
		mv.addObject("name", "칠지명");
		mv.setViewName("test7.notiles");
		
		return mv;
	}
	
//	4)기본 resolver
	@RequestMapping(value="/test8.action", method={RequestMethod.GET})
	public ModelAndView test8(ModelAndView mv) {
		mv.addObject("name", "칠지명");
		mv.setViewName("test4");
		
		return mv;
	}
}
