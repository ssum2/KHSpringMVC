package com.test.aop;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.stereotype.Component;

@Aspect
@Component
/*
XML에서 빈을 만드는 대신에 클래스명 앞에 @Component 어노테이션을 적어주면
  해당 클래스(지금은 Cross)는 bean으로 자동 등록된다.
  그리고 bean의 이름(첫글자는 소문자)은 해당 클래스명(지금은 Cross)이 된다.
  지금은 bean의 이름은 cross 이 된다.
*/
public class Cross {
//	#로그인된 회원만 접근이 가능하도록 하는 메소드를 Pointcut으로 선언하기
//	- AOPController.memberinfo(); 회원 전용 정보 페이지
//	- AOPController.membermy(); 회원 전용 개인정보 페이지
	@Pointcut("execution(public * com.test.aop.AOPController.member*(..))")
	public void pcmember() {}
	
//	#인증받지 못한(로그인하지 않은)사용자는 회원 전용 페이지에 접근할 수 없게 하기
	@Before("pcmember()")
	public void memberBefore(JoinPoint joinPoint) {
//		#로그인 유무 확인을 위해 첫번째 파라미터 request를 통해 세션값을 얻어오기
		HttpServletRequest request = (HttpServletRequest)joinPoint.getArgs()[0];
		HttpServletResponse response = (HttpServletResponse)joinPoint.getArgs()[1];
		HttpSession session = request.getSession();
		
		if(session.getAttribute("loginuser") == null) {
			try {
				String msg = "먼저 로그인하세요.";
				String loc = "/aop/index.action";
				request.setAttribute("msg", msg);
				request.setAttribute("loc", loc);
				
				RequestDispatcher dispatcher =  request.getRequestDispatcher("/WEB-INF/views/msg.jsp");
			
				dispatcher.forward(request, response);
			} catch (ServletException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
}
