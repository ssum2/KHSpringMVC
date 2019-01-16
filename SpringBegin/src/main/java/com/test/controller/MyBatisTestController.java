package com.test.controller;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;

import javax.servlet.http.HttpServletRequest;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.test.model.EmployeeVO;
import com.test.model.MemberVO;
import com.test.model.MemberVO2;
import com.test.model.MyBatisTestVO;
import com.test.service.MyBatisTestService;

/*
사용자 웹브라우저 요청(View)  ==> DispatcherServlet ==> @Controller 클래스 <==>> Service단(핵심업무로직단, business logic단) <==>> Model단[Repository](DAO, DTO) <==>> myBatis <==>> DB(오라클)           
(http://...  *.action)                                  |
       ↑                                              |
       |                                              ↓
       |                                           View단(.jsp)
       -----------------------------------------------| 
                                                       
Service(서비스)단 객체를 업무 로직단(비지니스 로직단)이라고 부른다.
Service(서비스)단 객체가 하는 일은 Model단에서 작성된 데이터베이스 관련 여러 메소드들 중 관련있는것들만을 모아 모아서
하나의 트랜잭션 처리 작업이 이루어지도록 만들어주는 객체이다.
여기서 업무라는 것은 데이터베이스와 관련된 처리 업무를 말하는 것으로 Model 단에서 작성된 메소드를 말하는 것이다.
이 서비스 객체는 @Controller 단에서 넘겨받은 어떤 값을 가지고 Model 단에서 작성된 여러 메소드를 호출하여 실행되어지도록 해주는 것이다.
실행되어진 결과값을 @Controller 단으로 넘겨준다.
*/


@Component
/* XML에서 빈을 만드는 대신에 클래스명 앞에 @Component 어노테이션을 적어주면 해당 클래스는 bean으로 자동 등록된다. 
     그리고 bean의 이름(첫글자는 소문자)은 해당 클래스명이 된다.
     여기서는 @Controller 를 사용하므로 @Component 기능이 이미 있으므로 @Component를 명기하지 않아도 MyBatisTestController 는 bean 으로 등록되어 스프링컨테이너가 자동적으로 관리해준다.  */
@Controller
public class MyBatisTestController {
	// ※ 의존객체주입(DI : Dependency Injection) 
	//  ==> 스프링 프레임워크는 객체를 관리해주는 컨테이너를 제공해주고 있다.
	//      스프링 컨테이너는 bean으로 등록된 MyBatisTestDAO 클래스 객체가 사용될 때(서비스에서 호출할 때),
	//      MyBatisTestDAO 클래스의 인스턴스 객체변수(의존객체)인 SqlSessionTemplate sqlsession 에 
	//      자동적으로 bean 으로 등록되어 생성되어진 SqlSessionTemplate sqlsession 객체를  
	//      MyBatisTestDAO 클래스의 인스턴스 변수 객체로 사용되어지게끔 넣어주는 것을 의존객체주입(DI : Dependency Injection)이라고 부른다. 
	//      이것이 바로 IoC(Inversion of Control == 제어의 역전) 인 것이다.
	
	//      즉, 개발자가 인스턴스 변수 객체를 필요에 의해 생성해주던 것에서 탈피하여 스프링은 컨테이너에 객체를 담아 두고, 
	//      필요할 때에 컨테이너로부터 객체를 가져와 사용할 수 있도록 하고 있다. 
	//      스프링은 객체의 생성 및 생명주기를 관리할 수 있는 기능을 제공하고 있으므로, 더이상 개발자에 의해 객체를 생성 및 소멸하도록 하지 않고
	//      객체 생성 및 관리를 스프링 프레임워크가 가지고 있는 객체 관리기능을 사용하므로 Inversion of Control == 제어의 역전 이라고 부른다.  
	//      그래서 스프링 컨테이너를 IoC 컨테이너라고도 부른다. (더이상 개발자가 객체 생성 삭제를 관리하지 않고 프레임워크 컨테이너가 관리하기 때문에 제어의 역전)
	
	//  === 느슨한 결합 ===
	//      스프링 컨테이너가 MyBatisTestDAO 클래스 객체에서 SqlSessionTemplate sqlsession 클래스 객체를 사용할 수 있도록 
	//      만들어주는 것을 "느슨한 결합" 이라고 부른다.
	//      느스한 결합은 MyBatisTestDAO 객체가 메모리에서 삭제되더라도 SqlSessionTemplate sqlsession 객체는 메모리에서 동시에 삭제되는 것이 아니라 남아 있다.
	//	cf) 단단한 결합: 일반적인 java클래스에서 클래스 내에 선언된 변수는 해당 클래스를 삭제하면 자동으로 함께 삭제됨	

	
//	#서비스 결합
	@Autowired
	private MyBatisTestService service;
	// private MyBatisTestService service = new MyBatisTestService();
	// === 단단한 결합(개발자가 인스턴스 변수 객체를 필요에 의해 생성해주던 것) ===
	//    ==> MyBatisTestController 객체가 메모리에서 삭제 되어지면 MyBatisTestService service 객체는 멤버변수이므로 메모리에서 자동적으로 삭제되어진다.
	
	@RequestMapping(value="/mybatistest/mybatisTest1.action", method={RequestMethod.GET})	// url 매핑
	public String mybatisTest1(HttpServletRequest req) {
		int n = service.mbtest1();	// insert용
		
		String msg = "";
		if(n==1) {
			msg = "데이터 입력 성공";
		}
		else {
			msg = "데이터 입력 실패";
		}
		req.setAttribute("msg", msg);
		return "mybatisTest1";
	}
	/* DAO로 바로 접근하지 않고 MyBatis를 통해 DB에 접근 => 미들웨어
	 * MyBatis에서는 select, update, delete, insert의 기능이 각각 다른 메소드로 나뉘어져 있음
	 * Service에서 트랜잭션 처리를 해서 DAO로 보내고 MyBatis를 거쳐 DB에 접근
	 * 
	 */
	
//	[181213]
//	update 처리하기
	@RequestMapping(value="/mybatistest/mybatisTest2.action", method={RequestMethod.GET})	// url 매핑
	public String mybatisTest2(HttpServletRequest req) {
		String name = "차은우";
		
		int n = service.mbtest2(name);	// update용
		
		String msg = "";
		if(n==1) {
			msg = n+"개의 데이터 수정 성공";
		}
		else {
			msg = "데이터 입력 실패";
		}
		req.setAttribute("msg", msg);
		return "mybatisTest2";
	}
	
//	form을 띄워주는 페이지는 대부분 GET방식
//	BUT 파일을 추가하는 form은 POST방식!
//	글쓰기 form 띄우기 처리
	@RequestMapping(value="/mybatistest/mybatisTest3.action", method={RequestMethod.GET})
	public String mybatisTest3(HttpServletRequest req) {
		
		return "register/mybatisTest3AddForm";	
	}
	
	
	@RequestMapping(value="/mybatistest/mybatisTest3End.action", method={RequestMethod.POST})
	public String mybatisTest3End(HttpServletRequest req) {
//		1) form에서 들어온 값 받아오기
		String name = req.getParameter("name");
		String email = req.getParameter("email");
		String tel = req.getParameter("tel");
		String addr = req.getParameter("addr");
		
//		2) DTO(VO; 도메인)에 넣기
		MyBatisTestVO vo = new MyBatisTestVO();
		vo.setName(name);
		vo.setEmail(email);
		vo.setTel(tel);
		vo.setAddr(addr);
		
//		3) service로 DTO 전송
		int n = service.mbtest3(vo); // insert
		
		String msg = "";
		if(n==1) {
			msg = n+"개의 데이터 입력 성공";
		}
		else {
			msg = "데이터 입력 실패";
		}
		req.setAttribute("msg", msg);
		return "register/mybatisTest3AddEnd";		
	}
	
	
//	form name == set 메소드 일치하는 객체 사용
	@RequestMapping(value="/mybatistest/mybatisTest4.action", method={RequestMethod.GET})
	public String mybatisTest4(HttpServletRequest req) {
		
		return "register/mybatisTest4AddForm";	
	}
	
	
	@RequestMapping(value="/mybatistest/mybatisTest4End.action", method={RequestMethod.POST})
	public String mybatisTest4End(MemberVO mvo, HttpServletRequest req) {
// **** form 에서 넘어오는 name 의 값과 
//      DB 의 컬럼명과 DTO(VO)의 get과 set다음에 나오는 메소드명(첫글자는 대문자)이 
//		(다른건 달라도 되지만 반드시form name과 dto의 set다음 메소드명이 일치)
//      동일할 경우 위처럼 파라미터명에 MemberVO mvo 와 같이 넣어주기만 하면
//      form에 입력된 값들이 자동적으로  MemberVO mvo 에 입력되어지므로  		

// 		1) form 에서 넘어온 값 받기위하여 
//    	사용하였던 req.getParameter("name"); 이러한 작업이 필요없다.
		
// 		2) DTO(VO)에 넣어주는 작업도 필요없다.

//		3) service로 DTO 전송
		int n = service.mbtest4(mvo); // insert
		
		String msg = "";
		if(n==1) {
			msg = n+"개의 데이터 입력 성공";
		}
		else {
			msg = "데이터 입력 실패";
		}
		req.setAttribute("msg", msg);
		return "register/mybatisTest4AddEnd";		
	}
	
	
//	#HashMap 사용
	@RequestMapping(value="/mybatistest/mybatisTest5.action", method={RequestMethod.GET})
	public String mybatisTest5(HttpServletRequest req) {
		
		return "register/mybatisTest5AddForm";	
	}
	
	@RequestMapping(value="/mybatistest/mybatisTest5End.action", method={RequestMethod.POST})
	public String mybatisTest5End(HttpServletRequest req) {
		String name = req.getParameter("name");
		String email = req.getParameter("email");
		String tel = req.getParameter("tel");
		String addr = req.getParameter("addr");

		HashMap<String, String> map = new HashMap<String ,String>();
		map.put("NAME", name);
		map.put("EMAIL", email);
		map.put("TEL", tel);
		map.put("ADDR", addr);
		
		int n = service.mbtest5(map); // insert
		
		String msg = "";
		if(n==1) {
			msg = "회원가입 성공!";
		}
		else {
			msg = "회원가입 실패";
		}
		req.setAttribute("msg", msg);
		return "register/mybatisTest5AddEnd";		
	}
	
	
//	#검색 조건에 맞는 데이터를 찾아 보여주기(1)
//	ModelAndView를 쓰지 않고 HttpServletRequest를 사용
	@RequestMapping(value="/mybatistest/mybatisTest6.action", method={RequestMethod.GET})
	public String mybatisTest6(HttpServletRequest req) {

//		search form으로 이동
		return "search/mybatisTest6SearchForm";	
	}
	
	@RequestMapping(value="/mybatistest/mybatisTest6End.action", method={RequestMethod.GET})
	public String mybatisTest6End(HttpServletRequest req) {
		String str_no = "";
		
		try {
//			1) 검색어 받아오기
			str_no = req.getParameter("no");
		
			int no = Integer.parseInt(str_no);
//			3) 숫자가 제대로 들어온 경우	service로 검색어를 전송
			String name = service.mbtest6(no); // select
			
			String result = null;
			
			if(name != null) {
				result = name;
			}
			else {
				result = "검색하신 "+no+"번에 일치하는 회원이 없습니다.";
			}
		
			req.setAttribute("result", result);
			return "search/mybatisTest6SearchEnd";
			
		} catch (NumberFormatException e) {
//			2) 숫자가 아닌 문자열이 들어온 경우 예외처리
			String msg = "는 숫자가 아닙니다. 숫자만 입력 가능 합니다.";
			req.setAttribute("str_no", str_no);
			req.setAttribute("msg", msg);
			return "search/mybatisTest6SearchError";	
		}
	}
	
	
//	#검색 조건에 맞는 데이터를 찾아 보여주기(2)
//	Model 사용
	@RequestMapping(value="/mybatistest/mybatisTest6_2.action", method={RequestMethod.GET})
	public String mybatisTest6_2() {

//		search form으로 이동
		return "search/mybatisTest6_2SearchForm";	
	}
	
	@RequestMapping(value="/mybatistest/mybatisTest6_2End.action", method={RequestMethod.GET})
	public String mybatisTest6_2End(HttpServletRequest req, Model model) {
		String str_no = "";
		
		try {
//			1) 검색어 받아오기
			str_no = req.getParameter("no");
		
			int no = Integer.parseInt(str_no);
//			3) 숫자가 제대로 들어온 경우	service로 검색어를 전송
			String name = service.mbtest6(no); // select
			
			String result = null;
			
			if(name != null) {
				result = name;
			}
			else {
				result = "검색하신 "+no+"번에 일치하는 회원이 없습니다.";
			}
		
//			4) Model 객체를 이용하여 view로 데이터 전송하기
//			Model; db에서 얻어온 결과물을 담는 객체 (저장소)
			model.addAttribute("result", result);
			return "search/mybatisTest6_2SearchEnd";
			
		} catch (NumberFormatException e) {
//			2) 숫자가 아닌 문자열이 들어온 경우 예외처리
			String msg = "는 숫자가 아닙니다. 숫자만 입력 가능 합니다.";
			model.addAttribute("str_no", str_no);
			model.addAttribute("msg", msg);
			return "search/mybatisTest6_2SearchError";	
		}
	}
	
	
	
//	[181214]	
//	#검색 조건에 맞는 데이터를 찾아 보여주기(3)
//	ModelAndView 사용; 
//	String타입으로 쓰는것이 캐시를 사용하기 때문에(캐싱) 성능 면에서 좋음 ---> ModelAndView 보다 String타입을 더 많이 씀
	@RequestMapping(value="/mybatistest/mybatisTest6_3.action", method={RequestMethod.GET})
	public String mybatisTest6_3() {

//		search form으로 이동
		return "search/mybatisTest6_3SearchForm";	
	}
	
	@RequestMapping(value="/mybatistest/mybatisTest6_3End.action", method={RequestMethod.GET})
	public ModelAndView mybatisTest6_3End(HttpServletRequest req, ModelAndView mv) {
		String str_no = "";
		
		try {
//			1) 검색어 받아오기
			str_no = req.getParameter("no");
		
			int no = Integer.parseInt(str_no);
//			3) 숫자가 제대로 들어온 경우	service로 검색어를 전송
			String name = service.mbtest6(no); // select
			
			String result = null;
			
			if(name != null) {
				result = name;
			}
			else {
				result = "검색하신 "+no+"번에 일치하는 회원이 없습니다.";
			}
//			#ModelAndView 객체를 사용하여 데이터와 뷰를 동시에 사용 가능
//			- mv.addObject("key값", value); ---> 모든 객체를 저장 가능
			mv.addObject("result", result);
			
//			- view 지정; setViewName
			mv.setViewName("search/mybatisTest6_3SearchEnd");		
			
		} catch (NumberFormatException e) {
//			2) 숫자가 아닌 문자열이 들어온 경우 예외처리
			String msg = "는 숫자가 아닙니다. 숫자만 입력 가능 합니다.";
			mv.addObject("str_no", str_no);
			mv.addObject("msg", msg);
			mv.setViewName("search/mybatisTest6_3SearchError");	
		}
		return mv;
	}
	
	
	
//	#검색 조건에 맞는 데이터를 찾아 보여주기(4)
//	MyBatis에서 VO로 받아온 결과물을 리턴 
	@RequestMapping(value="/mybatistest/mybatisTest7.action", method={RequestMethod.GET})
	public String mybatisTest7() {

//		search form으로 이동
		return "search/mybatisTest7SearchForm";	
	}
	
	@RequestMapping(value="/mybatistest/mybatisTest7End.action", method={RequestMethod.GET})
	public String mybatisTest7End(HttpServletRequest req) {
		String str_no = "";
		
		try {
//			1) 검색어 받아오기
			str_no = req.getParameter("no");
		
			int no = Integer.parseInt(str_no);
//			3) 숫자가 제대로 들어온 경우	service로 검색어를 전송
			MemberVO mvo = service.mbtest7(no);

			req.setAttribute("mvo", mvo);
			req.setAttribute("no", no);
			return "search/mybatisTest7SearchEnd";

		} catch (NumberFormatException e) {
			String msg = "는 숫자가 아닙니다. 숫자만 입력 가능 합니다.";
			req.setAttribute("str_no", str_no);
			req.setAttribute("msg", msg);
			return "search/mybatisTest7SearchError";
		}
	}
	
//	#검색 조건에 맞는 데이터를 찾아 보여주기(5)
//	MyBatis에서 VO로 받아온 결과물을 리턴, ModelAndView 사용
	@RequestMapping(value="/mybatistest/mybatisTest7_2.action", method={RequestMethod.GET})
	public String mybatisTest7_2() {

//		search form으로 이동
		return "search/mybatisTest7_2SearchForm";	
	}
	
	@RequestMapping(value="/mybatistest/mybatisTest7_2End.action", method={RequestMethod.GET})
	public ModelAndView mybatisTest7_2End(HttpServletRequest req, ModelAndView mv) {
		String str_no = "";
		
		try {
//			1) 검색어 받아오기
			str_no = req.getParameter("no");
		
			int no = Integer.parseInt(str_no);
//			3) 숫자가 제대로 들어온 경우	service로 검색어를 전송
			MemberVO mvo = service.mbtest7(no);

			mv.addObject("mvo", mvo);
			mv.addObject("no", no);
			mv.setViewName("search/mybatisTest7_2SearchEnd");

		} catch (NumberFormatException e) {
			String msg = "는 숫자가 아닙니다. 숫자만 입력 가능 합니다.";
			mv.addObject("str_no", str_no);
			mv.addObject("msg", msg);
			mv.setViewName("search/mybatisTest7_2SearchError");	
		}
		return mv;
	}
	
//	#검색 조건에 맞는 데이터를 찾아 보여주기(6)
//	MyBatis에서 List<VO> 타입으로 받아온 것을 view에 리턴
	@RequestMapping(value="/mybatistest/mybatisTest8.action", method={RequestMethod.GET})
	public String mybatisTest8() {

//		search form으로 이동
		return "search/mybatisTest8SearchForm";	
	}
	
	@RequestMapping(value="/mybatistest/mybatisTest8End.action", method={RequestMethod.GET})
	public String mybatisTest8End(HttpServletRequest req) {

//		1) 검색어 받아오기
		String addr = req.getParameter("addr");
	
		List<MemberVO> memberList = service.mbtest8(addr);

		req.setAttribute("memberList", memberList);
		req.setAttribute("addr", addr);
		
		return "search/mybatisTest8SearchEnd";
	}
	
	
//	#검색 조건에 맞는 데이터를 찾아 보여주기(7)
//	MyBatis에서 List<VO> 타입으로 받아온 것을 view에 리턴(2) --> VO와 컬럼명이 일치하지 않는 경우
	@RequestMapping(value="/mybatistest/mybatisTest9.action", method={RequestMethod.GET})
	public String mybatisTest9() {

//		search form으로 이동
		return "search/mybatisTest9SearchForm";	
	}
	
	@RequestMapping(value="/mybatistest/mybatisTest9End.action", method={RequestMethod.GET})
	public String mybatisTest9End(HttpServletRequest req) {

//		1) 검색어 받아오기
		String addr = req.getParameter("addr");
	
		List<MemberVO2> memberList = service.mbtest9(addr);

		req.setAttribute("memberList", memberList);
		req.setAttribute("addr", addr);
		
		return "search/mybatisTest9SearchEnd";
	}
	
//	#검색 조건에 맞는 데이터를 찾아 보여주기(8)
//	MyBatis에서 List<VO> 타입으로 받아온 것을 view에 리턴(3) --> VO와 컬럼명이 일치하지 않는 경우(2); 더 간략한 방법
	@RequestMapping(value="/mybatistest/mybatisTest9_2.action", method={RequestMethod.GET})
	public String mybatisTest9_2() {

//		search form으로 이동
		return "search/mybatisTest9_2SearchForm";	
	}
	
	@RequestMapping(value="/mybatistest/mybatisTest9_2End.action", method={RequestMethod.GET})
	public String mybatisTest9_2End(HttpServletRequest req) {

//		1) 검색어 받아오기
		String addr = req.getParameter("addr");
	
		List<MemberVO2> memberList = service.mbtest9_2(addr);

		req.setAttribute("memberList", memberList);
		req.setAttribute("addr", addr);
		
		return "search/mybatisTest9_2SearchEnd";
	}
	
	
//	#검색 조건에 맞는 데이터를 찾아 보여주기(9)
//	MyBatis에서 List<VO> 타입으로 받아온 것을 view에 리턴(3) --> VO와 컬럼명이 일치하지 않는 경우(3); HashMap사용
	@RequestMapping(value="/mybatistest/mybatisTest10.action", method={RequestMethod.GET})
	public String mybatisTest10() {

//		search form으로 이동
		return "search/mybatisTest10SearchForm";	
	}
	
	@RequestMapping(value="/mybatistest/mybatisTest10End.action", method={RequestMethod.GET})
	public String mybatisTest10End(HttpServletRequest req) {

//		1) 검색어 받아오기
		String addr = req.getParameter("addr");
	
		List<HashMap<String, String>> memberMapList = service.mbtest10(addr);

		req.setAttribute("memberMapList", memberMapList);
		req.setAttribute("addr", addr);
		
		return "search/mybatisTest10SearchEnd";
	}
	
	
//	#검색 조건에 맞는 데이터를 찾아 보여주기(10)
//	페이지를 띄운 다음 다시 값을 받아와서 똑같은 페이지로 보내기; HashMap 객체를 파라미터로 보내 List형태로 select 
	@RequestMapping(value="/mybatistest/mybatisTest11.action", method={RequestMethod.GET})
	public String mybatisTest11(HttpServletRequest req) {
		String colName = req.getParameter("colName"); // select태그에 있는 name
		String searchWord = req.getParameter("searchWord");
		String startday = req.getParameter("startday");
		String endday = req.getParameter("endday");
		
//		4개의 값을 HashMap으로 묶음
		if(colName != null && searchWord != null) {
			HashMap<String ,String> paraMap = new HashMap<String, String>();
			paraMap.put("COLNAME", colName);
			paraMap.put("SEARCHWORD", searchWord);
			paraMap.put("STARTDAY", startday);
			paraMap.put("ENDDAY", endday);
			
			List<HashMap<String, String>> memberList = service.mbtest11(paraMap);
			int cnt = service.mbtest11_2(paraMap);
			
			req.setAttribute("memberList", memberList);
	//		req.setAttribute("cnt", cnt);
			
			req.setAttribute("colName", colName);
			req.setAttribute("searchWord", searchWord);
			req.setAttribute("startday", startday);
			req.setAttribute("endday", endday);
//			search form으로 이동
			return "search/mybatisTest11SearchForm";	
		}
		else {
//			search form으로 이동
			return "search/mybatisTest11SearchForm";
		}
	
	}
	
	
//	[181219]	
//	#employees, departments 테이블에서 조회해오기
//	페이지를 띄운 다음 다시 값을 받아와서 똑같은 페이지로 보내기; HashMap 객체를 파라미터로 보내 List형태로 select 
	@RequestMapping(value="/mybatistest/mybatisTest12.action", method={RequestMethod.GET})
	public String mybatisTest12(HttpServletRequest req) {
//		#부서번호 리스트 받아오기	
		List<Integer> deptnoList=service.mbtest12_deptnoList();
		
		String department_id = req.getParameter("department_id");
		String gender = req.getParameter("gender");
		
		if(department_id!=null && gender !=null) {
			HashMap<String, String> paraMap = new HashMap<String, String>();
			paraMap.put("DEPARTMENT_ID", department_id);
			paraMap.put("GENDER",gender);
			List<HashMap<String, String>> empList=service.mbtest12_empList(paraMap);
			
			req.setAttribute("department_id", department_id);
			req.setAttribute("gender", gender);
			req.setAttribute("empList", empList);
			req.setAttribute("deptnoList", deptnoList);
			return "search/mybatisTest12SearchForm";

		}
		
		req.setAttribute("deptnoList", deptnoList);
		return "search/mybatisTest12SearchForm";
	}
	

//	#employees, departments 테이블에서 조회해오기
//	페이지를 띄운 다음 다시 값을 받아와서 똑같은 페이지로 보내기; HashMap 객체를 파라미터로 보내 List형태로 select 하여 ModelAndView로 보내기
	@RequestMapping(value="/mybatistest/mybatisTest12_2.action", method={RequestMethod.GET})
	public ModelAndView mybatisTest12_2(HttpServletRequest req, ModelAndView mv) {
//		#부서번호 리스트 받아오기	
		List<Integer> deptnoList=service.mbtest12_deptnoList();
		
		String department_id = req.getParameter("department_id");
		String gender = req.getParameter("gender");
		
		if(department_id!=null && gender !=null) {
			HashMap<String, String> paraMap = new HashMap<String, String>();
			paraMap.put("DEPARTMENT_ID", department_id);
			paraMap.put("GENDER",gender);
			List<HashMap<String, String>> empList=service.mbtest12_empList(paraMap);
			
			mv.addObject("department_id", department_id);
			mv.addObject("gender", gender);
			mv.addObject("empList", empList);
			mv.addObject("deptnoList", deptnoList);
			
			mv.setViewName("search/mybatisTest12_2SearchForm");
		}
		else {
		
			mv.addObject("deptnoList", deptnoList);
			mv.setViewName("search/mybatisTest12_2SearchForm");
		}
		return mv;
	}
	

//	#Ajax 사용하기
//	1) form 화면 띄우기
	@RequestMapping(value="/mybatistest/mybatisTest13.action", method={RequestMethod.GET})
	public String mybatisTest13() {
		
		return "search/mybatisTest13SearchForm";
	}
	
//	2) form에서 받아온 값을 받아와서 DB 데이터를 가져와 view로 전송하기 (JSON 사용)
	@RequestMapping(value="/mybatistest/mybatisTest13JSON.action", method={RequestMethod.GET})
	public String mybatisTest13JSON(HttpServletRequest req) {
		String addrSearch = req.getParameter("addrSearch");
		JSONArray jsonArr = new JSONArray();
		if(addrSearch != null && !addrSearch.trim().isEmpty()) {
			List<HashMap<String, String>> memberList = service.mbtest13(addrSearch);
			
			if(memberList != null && memberList.size() >0) {
				for(HashMap<String, String> map :memberList) {
					JSONObject jsonObj = new JSONObject();
					jsonObj.put("NO", map.get("NO"));
					jsonObj.put("NAME", map.get("NAME"));
					jsonObj.put("EMAIL", map.get("EMAIL"));
					jsonObj.put("TEL", map.get("TEL"));
					jsonObj.put("ADDR", map.get("ADDR"));
					jsonObj.put("WRITEDAY", map.get("WRITEDAY"));
					jsonObj.put("BIRTHDAY", map.get("BIRTHDAY"));
					
					jsonArr.put(jsonObj);
				}
			}
		}
		
		String str_jsonArr = jsonArr.toString();
		req.setAttribute("str_jsonArr", str_jsonArr);
		return "search/mybatisTest13SearchJSON";
	}
	
//	#Ajax 사용하기(2); JSON.jsp 없이 출력하기
//	1) form 화면 띄우기
	@RequestMapping(value="/mybatistest/mybatisTest13_2.action", method={RequestMethod.GET})
	public String mybatisTest13_2() {
		
		return "search/mybatisTest13_2SearchForm";
	}
	
//	2) form에서 받아온 값을 받아와서 DB 데이터를 가져와 view로 전송하기 (JSON Jackson, @ResponseBody)
	// ==> jackson JSON 라이브러리와 @ResponseBody 사용하여 JSON 을 파싱하기 === //
/* 
	@ResponseBody 란?
	메소드에 @ResponseBody Annotation이 되어 있으면 return 되는 값은 View 단을 통해서 출력되는 것이 아니라 
	HTTP Response Body에 들어간다
			
	!!! 그리고 jackson JSON 라이브러리를 사용할때 주의해야할 점은!!!!! 
		메소드의 리턴타입은 
		행이 1개 일경우                          HashMap<K,V>       이거나            Map<K,V>   이고 
		행이 2개 이상일 경우           List<HashMap<K,V>>      이거나   List<Map<K,V>>  이어야 한다.
		그런데 행이 2개 이상일 경우  ArrayList<HashMap<K,V>> 이거나   ArrayList<Map<K,V>> 이면 안된다.!!!
			     
	이와같이 jackson JSON 라이브러리를 사용할때의 장점은 View 단이 필요없게 되므로 간단하게 작성하는 장점이 있다. 
*/	
	@RequestMapping(value="/mybatistest/mybatisTest13_2JSON.action", method={RequestMethod.GET})
	@ResponseBody
	public List<HashMap<String, Object>> mybatisTest13_2JSON(HttpServletRequest req) {
		String addrSearch = req.getParameter("addrSearch");
		
		List<HashMap<String, Object>> mapList = new ArrayList<HashMap<String,Object>>();
		// JSONArray, JSONObject를 대신함
		
		if(addrSearch != null && !addrSearch.trim().isEmpty()) {
			List<HashMap<String, String>> memberList = service.mbtest13(addrSearch);
			
			if(memberList != null && memberList.size() >0) {
				for(HashMap<String, String> memberMap :memberList) {
					HashMap<String, Object> map = new HashMap<String, Object>();                          
					map.put("NO", memberMap.get("NO"));
					map.put("NAME", memberMap.get("NAME"));
					map.put("EMAIL", memberMap.get("EMAIL"));
					map.put("TEL", memberMap.get("TEL"));
					map.put("ADDR", memberMap.get("ADDR"));
					map.put("WRITEDAY", memberMap.get("WRITEDAY"));
					map.put("BIRTHDAY", memberMap.get("BIRTHDAY"));
					
					mapList.add(map);
				}
			}
		}
		
		return mapList;
	}
	
	
//	[181220]
//	# testdb.xml 파일에 foreach를 사용하기
	@RequestMapping(value="/mybatistest/mybatisTest14.action", method={RequestMethod.GET})
	public String mybatisTest14(HttpServletRequest req) {
		List<Integer> deptnoList = service.mbtest12_deptnoList();
		
		req.setAttribute("deptnoList", deptnoList);
		return "search/mybatisTest14SearchForm";
	}
	@RequestMapping(value="/mybatistest/mybatisTest14JSON.action", method={RequestMethod.GET})
	@ResponseBody
	public List<HashMap<String, Object>> mybatisTest14JSON(HttpServletRequest req) {
		List<HashMap<String, Object>> resultMapList = new ArrayList<HashMap<String,Object>>();
		// JSONArray, JSONObject를 대신함
		
//		str_deptnoes, gender, ageline
		String str_deptnoes = req.getParameter("str_deptnoes");
		String[] deptnoArr = str_deptnoes.split(",");
		/*for(int i=0; i<deptnoArr.length; i++) {
			System.out.println("확인용: "+deptnoArr[i]);
		}*/
		
		String gender = req.getParameter("gender");
		String ageline = req.getParameter("ageline");
		
		HashMap<String, Object> paraMap = new HashMap<String, Object>();
		paraMap.put("DEPTNOARR", deptnoArr);
		paraMap.put("GENDER", gender);
		paraMap.put("AGELINE", ageline);

		List<HashMap<String, String>> empList = service.mbtest14(paraMap);
		
		for(HashMap<String, String> empMap :empList) {
			HashMap<String, Object> resultMap = new HashMap<String, Object>();
			resultMap.put("DEPARTMENT_ID", empMap.get("DEPARTMENT_ID"));
			resultMap.put("DEPARTMENT_NAME", empMap.get("DEPARTMENT_NAME"));
			resultMap.put("EMPLOYEE_ID", empMap.get("EMPLOYEE_ID"));
			resultMap.put("NAME", empMap.get("NAME"));
			resultMap.put("JUBUN", empMap.get("JUBUN"));
			resultMap.put("GENDER", empMap.get("GENDER"));
			resultMap.put("AGE", empMap.get("AGE"));
			resultMap.put("YEARPAY", empMap.get("YEARPAY"));
			
			resultMapList.add(resultMap);
		}
		return resultMapList;
	}
	
	
//	#차트 그리기
	@RequestMapping(value="/mybatistest/mybatisTest15.action", method={RequestMethod.GET})
	public String mybatisTest15() {
		
		return "chart/mybatisTest15";
	}
	
//	1) 성별 분포도
	@RequestMapping(value="/mybatistest/mybatisTest15JSON_gender.action", method={RequestMethod.GET})
	@ResponseBody
	public List<HashMap<String, Object>> mybatisTest15JSON_gender() {
		List<HashMap<String, Object>> resultMapList = new ArrayList<HashMap<String, Object>>();
		
		List<HashMap<String, String>> genderList = service.mbtest15_gender();
		for(HashMap<String, String> map : genderList) {
			HashMap<String, Object> resultMap = new HashMap<String, Object>();
			resultMap.put("GENDER", map.get("GENDER"));
			resultMap.put("CNT", map.get("CNT"));
			resultMap.put("AVG", map.get("AVG"));
			
			resultMapList.add(resultMap);
		}
		return resultMapList;
	}
//	2) 성별 분포도
	@RequestMapping(value="/mybatistest/mybatisTest15JSON_ageline.action", method={RequestMethod.GET})
	@ResponseBody
	public List<HashMap<String, Object>> mybatisTest15JSON_ageline() {
		List<HashMap<String, Object>> resultMapList = new ArrayList<HashMap<String, Object>>();
		
		List<HashMap<String, String>> agelineList = service.mbtest15_ageline();
		for(HashMap<String, String> map : agelineList) {
			HashMap<String, Object> resultMap = new HashMap<String, Object>();
			resultMap.put("AGELINE", map.get("AGELINE"));
			resultMap.put("CNT", map.get("CNT"));
			resultMap.put("AVG", map.get("AVG"));
			
			resultMapList.add(resultMap);
		}
		return resultMapList;
	}
	
//	3) 성별 분포도
	@RequestMapping(value="/mybatistest/mybatisTest15JSON_deptno.action", method={RequestMethod.GET})
	@ResponseBody
	public List<HashMap<String, Object>> mybatisTest15JSON_deptno() {
		List<HashMap<String, Object>> resultMapList = new ArrayList<HashMap<String, Object>>();
		
		List<HashMap<String, String>> deptnoList = service.mbtest15_deptno();
		for(HashMap<String, String> map : deptnoList) {
			HashMap<String, Object> resultMap = new HashMap<String, Object>();
			resultMap.put("DEPTNO", map.get("DEPTNO"));
			resultMap.put("DEPTNAME", map.get("DEPTNAME"));
			resultMap.put("CNT", map.get("CNT"));
			resultMap.put("AVG", map.get("AVG"));
			resultMap.put("AVGDEPT", map.get("AVGDEPT"));
			
			resultMapList.add(resultMap);
		}
		return resultMapList;
	}

	
	
// [190116]
// **** Mybatis 에서 Procedure 사용하기 **** //
// ***** Mybatis 에서 Procedure 를 사용하여 insert 하기 ***** //
// VO를 사용하지 않고 HashMap 을 사용하여  DB에 insert 하도록 하겠다. ***
	@RequestMapping(value = "/mybatistest/mybatisTest17.action", method = { RequestMethod.GET })
	public String mybatisTest17() {

// 글쓰기 form 페이지를 띄우려고 한다.
		return "register/mybatisTest17AddForm";
//   /WEB-INF/views/register/mybatisTest17AddForm.jsp 를 파일을 생성한다.
	}

	@RequestMapping(value = "/mybatistest/mybatisTest17End.action", method = { RequestMethod.POST })
	public String mybatisTest17End(HttpServletRequest req) {

// 1. form 에서 넘어온 값 받기
		String name = req.getParameter("name");
		String email = req.getParameter("email");
		String tel = req.getParameter("tel");
		String addr = req.getParameter("addr");

// 2. HashMap으로 저장시킨다. 
		HashMap<String, String> paraMap = new HashMap<String, String>();

		paraMap.put("NAME", name);
		paraMap.put("EMAIL", email);
		paraMap.put("TEL", tel);
		paraMap.put("ADDR", addr);

// 3. Service 단으로 HashMap 을 넘긴다.
//		프로시저는 반환값이 없기 때문에 성공 실패 여부를 가리려면 예외처리를 해줘야함
		String msg = "";
		try {
			service.mbtest17(paraMap);
			msg = "회원가입 성공!!";
			req.setAttribute("msg", msg);
			return "register/mybatisTest17AddEnd";
		} catch (Exception e) {
			msg = "회원가입 실패!!";
			req.setAttribute("msg", msg);
			return "register/mybatisTest17AddEnd";
		}

//   /WEB-INF/views/register/mybatisTest17AddEnd.jsp 를 파일을 생성한다.
	}
	
// ***** 사원번호를 입력받아서 Mybatis 에서 Procedure 를 사용하여 한명의 사원정보 select 하기 ***** //
	@RequestMapping(value="/mybatistest/mybatisTest18.action", method={RequestMethod.GET})       
	public String mybatisTest18(HttpServletRequest req) {
	
		// 1. form 에서 넘어온 값 받기
		String employee_id = req.getParameter("employee_id");
		
		// 2. HashMap으로 저장시킨다. (반드시 서비스단으로 보내야할 변수의 갯수가 1개 이더라도 HashMap 으로 만들어서 넘겨야 한다.!!!!)
		// >> 오라클에서 호출하는 프로시저에서는 파라미터에 in모드, out모드 둘 다 받기 때문에 out모드의 결과물 때문에 HashMap형태로 보내야함
		// out모드 결과물을 map에 다시 넘겨주기 때문에 모든 타입을 받을 수 있는 Object로 해야함
		HashMap<String, Object> paraMap = new HashMap<String, Object>(); // !!!! Object 로 해야 한다. !!!!
		paraMap.put("EMPLOYEE_ID", employee_id);
				
		// 3. Service 단으로 HashMap 을 넘기는데 그 결과값은 반드시 VO의 List 로 받아와야 한다.!!!!!
		// 오라클 프로시저에서 실행한 커서는 행이 한개가 나올지 복수가 나올 지 모름 -> List형태로 받아야 호환 가능 
		ArrayList<EmployeeVO> employeeInfoList = service.mbtest18(paraMap);
			
	    req.setAttribute("employeeInfoList", employeeInfoList);
	    req.setAttribute("employee_id", employee_id);
	
	    return "search/mybatisTest18Search";
	}
	
// ***** 부서번호를 입력받아서 Mybatis 에서 Procedure 를 사용하여 여러명의 사원정보 select 하기 ***** //
	@RequestMapping(value="/mybatistest/mybatisTest19.action", method={RequestMethod.GET})       
	public String mybatisTest19(HttpServletRequest req) {
	
		// 1. form 에서 넘어온 값 받기
		String department_id = req.getParameter("department_id");

		// 2. HashMap으로 저장시킨다. (반드시 서비스단으로 보내야할 변수의 갯수가 1개 이더라도 HashMap 으로 만들어서 넘겨야 한다.!!!!)
		HashMap<String, Object> paraMap = new HashMap<String, Object>(); // !!!! Object 로 해야 한다. !!!!
		paraMap.put("DEPARTMENT_ID", department_id);
				
		// 3. Service 단으로 HashMap 을 넘기는데 그 결과값은 반드시 VO의 List 로 받아와야 한다.!!!!!
		ArrayList<EmployeeVO> employeeInfoList = service.mbtest19(paraMap);
			
	    req.setAttribute("employeeInfoList", employeeInfoList);
	    req.setAttribute("department_id", department_id);
	
	    return "search/mybatisTest19Search";
	}

}
