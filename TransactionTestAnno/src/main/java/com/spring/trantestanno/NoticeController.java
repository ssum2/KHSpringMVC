package com.spring.trantestanno;

import java.util.HashMap;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import com.spring.trantestanno.model.NoticeVO;
import com.spring.trantestanno.service.InterNoticeService;

//#13. 컨트롤러 선언
@Component
/* XML에서 빈을 만드는 대신에 클래스명 앞에 @Component 어노테이션을 적어주면 해당 클래스는 bean으로 자동 등록된다. 
     그리고 bean의 이름(첫글자는 소문자)은 해당 클래스명이 된다. */
@Controller
public class NoticeController {
	
	@Autowired // 의존객체주입(DI : Dependency Injection)
	private InterNoticeService service;
	
	
	// 시작페이지 요청
	@RequestMapping(value="/index.action", method={RequestMethod.GET} ) 
	public String index(HttpServletRequest req) {
		
//		#시작페이지에서 세션 삭제
		HttpSession session = req.getSession();
		session.invalidate();
		
		return "index";
	/*	~~views/index.jsp
	 	<beans:bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
			<beans:property name="prefix" value="/WEB-INF/views/" />
			<beans:property name="suffix" value=".jsp" />
		</beans:bean>
	 */
	}
	
	
	// 나의포인트 페이지 요청
	@RequestMapping(value="/mypoint.action", method={RequestMethod.GET} ) 
	public String mypoint(HttpServletRequest req) {
		
		HttpSession session = req.getSession();
		session.setAttribute("userid", "hongkd");
		
		String userid = (String)session.getAttribute("userid");
		
		// Service 단에 요청.
		int point = service.getLoginUserPoint(userid);
		
		req.setAttribute("point", point);

		return "point";
	}
	
	
	// transaction 처리가 없는 글쓰기 요청
	@RequestMapping(value="/add_notransaction.action", method={RequestMethod.GET} ) 
	public String add_notransaction() {
		return "add_notransaction";
	}
	
	
	// transaction 처리가 없는 글쓰기 완료 요청
    @RequestMapping(value="/addEnd_notransaction.action", method={RequestMethod.POST} ) 
    public String addEnd_notransaction(NoticeVO ntvo, HttpServletRequest req, HttpServletResponse res) {  
    	
    	ntvo.setTitle("[트랜잭션처리안함] "+ntvo.getTitle());
    	ntvo.setContent(ntvo.getContent().replaceAll("\r\n", "<br/>")); // enter는 <br>태그로 바꿔서 보여주기
    	
    	// Service 단에 요청.
   		int result = service.add_notransaction(ntvo); 
    	
   		req.setAttribute("result", result); // 키값 result 정의
   		
    	return "addEnd_notransaction";
    }

   /*
    @ExceptionHandler 에 대해서.....
    ==> 어떤 컨트롤러내에서 발생하는 익셉션이 있을시 익셉션 처리를 해주려고 한다면
        @ExceptionHandler 어노테이션을 적용한 메소드를 구현해주면 된다
         
       컨트롤러내에서 @ExceptionHandler 어노테이션을 적용한 메소드가 존재하면, 
       스프링은 익셉션 발생시 @ExceptionHandler 어노테이션을 적용한 메소드가 처리해준다.
       따라서, 컨트롤러에 발생한 익셉션을 직접 처리하고 싶다면 @ExceptionHandler 어노테이션을 적용한 메소드를 구현해주면 된다.
    */
 
   @ExceptionHandler(java.sql.SQLIntegrityConstraintViolationException.class)
   public String handleSQLIntegrityConstraintViolationException(java.sql.SQLIntegrityConstraintViolationException e, HttpServletRequest req) {
	    /*
	           오류 보고 -
          SQL 오류: ORA-02290: check constraint (MYORAUSER.CK_TX_MEMBER_POINT) violated 	
	     */
	   
	   	System.out.println(">>>>>>>>>>>>>>>"+e.getErrorCode());
	   	// >>>>>>>>>>>>>>>2290
		   	
	   	String msg = "";
		   	
	   	switch (e.getErrorCode()) {
				case 2290:
					msg = "포인트가 최대치가 되어서 글쓰기가 취소되었습니다.";
					break;
			
				default:
					msg = "SQL오류발생 >>오류번호: "+e.getErrorCode();
					break;
			}
		   	    	
		String loc = "/trantestanno/index.action";	// req.getContextPath()+/index.action
		req.setAttribute("msg", msg);
		req.setAttribute("loc", loc);
			
		return "msg";
   }
  
   
   /*@ExceptionHandler(org.springframework.dao.DataIntegrityViolationException.class)
   public String handleDataIntegrityViolationException(org.springframework.dao.DataIntegrityViolationException e, HttpServletRequest req, HttpServletResponse res) {
   	
   	System.out.println(">>>>>>>>>>>>>>>"+e.getMessage());
   	//String msg = "포인트가 최대치가 되어서 글쓰기가 취소되었습니다.";
   	String msg = e.getMessage();
		String loc = "/trantestanno/index.action";
		req.setAttribute("msg", msg);
		req.setAttribute("loc", loc);
		
		return "msg";
   }*/    
		
	// transaction 처리가 있는 글쓰기 요청
	@RequestMapping(value="/add_transaction.action", method={RequestMethod.GET} ) 
	public String add_transaction() {
		return "add_transaction";
	}
	
	
	// transaction 처리가 있는 글쓰기 완료 요청
    @RequestMapping(value="/addEnd_transaction.action", method={RequestMethod.POST} ) 
    public String addEnd_transaction(NoticeVO ntvo, HttpServletRequest req, HttpServletResponse res) 
    		throws Throwable {
	   // Throwable; 오류가 발생할 수 있음
    	  ntvo.setTitle("[트랜잭션처리함] "+ntvo.getTitle());
    	  ntvo.setContent(ntvo.getContent().replaceAll("\r\n", "<br/>")); 
	   
    	  // Service 단에 요청.
   		  int result = service.add_transaction(ntvo);
    	  
   		  req.setAttribute("result", result); // 키값 result 정의
    	  return "addEnd_transaction";
    }
    
	
    // 글목록 보기
 	@RequestMapping(value="/list.action", method={RequestMethod.GET} ) 
 	public String list(HttpServletRequest req) {
 		
 		List<HashMap<String, String>> list = service.list();
 		
 		req.setAttribute("list", list);
 		
 		return "list";
 	}
 	
 	
 	// 글 상세내용 보기
  	@RequestMapping(value="/contentView.action", method={RequestMethod.GET} ) 
  	public ModelAndView contentView(HttpServletRequest req, ModelAndView mv) {
  		
  		String str_seq = req.getParameter("seq");
  		  		
  		try {
			  int seq = Integer.parseInt(str_seq);
			  HashMap<String, String> contentViewMap = service.contentView(seq);
			  
			  mv.addObject("contentViewMap", contentViewMap);
			  mv.setViewName("contentView");
			  
		} catch (NumberFormatException e) {
			mv.addObject("str_seq", str_seq);
			mv.setViewName("contentViewError");
		}
  		
  		return mv;
  		
  	}
 	
    
	
}
