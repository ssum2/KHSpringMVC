package com.test.memo;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.aspectj.lang.ProceedingJoinPoint;

public class Logger {
	//보조업무
	// - 메모를 작성하는데 걸리는 시간을 로그에 남기는 보조업무
	public void arround(ProceedingJoinPoint  joinPoint) throws Throwable {
		
		//보조업무 시작
		long start = System.currentTimeMillis();
		System.out.println("시간 기록 시작");
		
		try {
			// 주업무 시작
			// - joinPoint.proceed(); 메소드를 실행함으로 
			//   Pointcut 에 설정된 주업무를 처리해주는 메소드가 호출되어 실행된다.
			//   지금은 public * com.test.memo.Memo.*(..) 이다. 
			
			joinPoint.proceed();  
			
			//   그리로 joinPoint.proceed() 메소드의 리턴값은 Object 이다.;
			//   이를통해 Aspect 로 연결된 Original Method(지금은 Memo 클래스의 모든 메소드임) 의 
			//   리턴값을 형변환을 통하여 받을수 있다.
			//   지금은 Original Method 의 리턴값이 void 임.
			// 주업무 끝
			
		} finally {
			long finish = System.currentTimeMillis();
			System.out.println("시간 기록 끝");
			System.out.println("주업무 실행시간 : " + (finish - start) + "ms");
			//보조업무 끝
		}
	}
	
	// 보조업무 추가
	// - 메모를 작성하기 전 현재 시간을 로그에 남기는 보조업무
	public void before() {
		
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"); 
		String now = sdf.format(new Date());
		
		System.out.println("   메모 작성 날짜시간 : " + now);
		//System.out.printf("메모 작성 시간 : %tT\n", Calendar.getInstance());
	}
	
	// 보조업무 추가
	// - 메모 작성, 수정시 메모작성횟수와 메모수정 횟수를 누적해서 로그에 남기는 보조업무
	int cnt = 0;
	public void after() {
		cnt++;
		System.out.printf("메모 편집 횟수 : %d회\n", cnt);
	}
	
	// 보조업무 추가; afterreturning
	// - 메모를 삭제한 뒤 삭제한 메모의 번호를 로그에 남기는 보조업무
	// - 보조객체의 인자명(파라미터명)과 XML의 returning의 인자명은 ★동일★해야함
	public void afterreturning(Object seq) {
		System.out.println("삭제된 메모 번호: "+seq);
	}
	
	// 보조업무 추가; afterthrowing
	// - 메모를 읽다가 예외가 발생하면 로그에 남기는 보조업무
	// - 보조객체의 인자명(파라미터명)과 XML의 throwing의 인자명은 ★동일★해야함
	// 	<aop:after-throwing method="afterthrowing" pointcut-ref="m1" throwing="e"/>
	public void afterthrowing(Exception e) {
		System.out.println("예외기록: "+e.getMessage());
	}
	
}
