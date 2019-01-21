package com.spring.weather.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
public class WeatherController {
	
//	#기상청 오픈API 공공데이터(XML) 호출하기
//	http://www.kma.go.kr/XML/weather/sfc_web_map.xml
	@RequestMapping(value="/weatherXML.action", method={RequestMethod.GET})
	public String weatherXML() {
		
		return "xml/weatherXML";
	}
}
