package com.spring.board.controller;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.spring.board.model.BoardVO;
import com.spring.board.model.CommentVO;
import com.spring.board.model.PhotoVO;
import com.spring.board.service.InterBoardService;
import com.spring.common.AES256;
import com.spring.common.FileManager;
import com.spring.common.MyUtil;
import com.spring.common.SHA256;
import com.spring.member.model.MemberVO;
import com.spring.common.LargeThumbnailManager;

//===== #30. 컨트롤러 선언  =====
/* XML에서 빈을 만드는 대신에 클래스명 앞에 @Component 어노테이션을 적어주면 해당 클래스는 bean으로 자동 등록된다. 
그리고 bean의 이름(첫글자는 소문자)은 해당 클래스명이 된다. */
@Controller
public class BoardController {
//	===== #35. Service DI(의존객체) 주입하기
	@Autowired
	private InterBoardService service;
	
//	===== #45. 암호화를 위한 DI 주입하기
	@Autowired
	private AES256 aes;

//	===== #139. 파일업로드 및 파일 다운로드를 위한 FileManager 의존객체 주입
	@Autowired
	private FileManager fileManager;
	
//	===== #스마트에디터3. 파일썸네일 생성을 위해 의존객체 주입;
//	원본 사진 크기가 600 이상일경우 width 사이즈를 적절하게 조절
	@Autowired
	private LargeThumbnailManager largeThumbnailManager;
	
//	===== #36. 메인 페이지 요청
	@RequestMapping(value="/index.action", method= {RequestMethod.GET})
	public String index(HttpServletRequest req) {
		List<String> imgfilenameList = service.getImgfilenameList();
		req.setAttribute("imgfilenameList", imgfilenameList);
		return "main/index.tiles1";
//		>> /Board/src/main/webapp/WEB-INF/views/tiles1/main/index.jsp 파일 생성

	}
	
//	===== #40. 로그인 페이지 요청
	@RequestMapping(value="/login.action", method= {RequestMethod.GET})
	public String login(HttpServletRequest req) {

		return "login/loginform.tiles1";
	}
	
//	===== #41. 로그인 여부/마지막 로그인 일시 알아오기
	@RequestMapping(value="/loginEnd.action", method= {RequestMethod.POST})
	public String loginEnd(HttpServletRequest req) {
		
		String userid = req.getParameter("userid");
		String pwd = req.getParameter("pwd");
		
		HashMap<String ,String> map  = new HashMap<String, String>();
		map.put("userid", userid);
		map.put("pwd", SHA256.encrypt(pwd));
		
		MemberVO loginuser = service.getLoginMember(map);
		
		HttpSession session = req.getSession();
		String msg = "";
		String loc = "";
		if(loginuser == null) {
			msg = "아이디 또는 비밀번호가 일치하지 않습니다.";
			loc = "javascript:history.back()";
			
			req.setAttribute("msg", msg);
			req.setAttribute("loc", loc);
			
			return "msg";
		}
		else if(loginuser!=null && loginuser.isRequireCertify()) {
			msg = "마지막 로그인 일시가 1년이 경과하여 휴면상태로 전환되었습니다. 관리자에게 문의하세요.";
			loc = "javascript:history.back()";
			
			req.setAttribute("msg", msg);
			req.setAttribute("loc", loc);
			
			return "msg";
		}
		else if(loginuser!=null && loginuser.isRequirePwdChange()){
			msg = "비밀번호 변경 일시가 6개월이 경과하였습니다. 비밀번호를 변경한 후 이용 바랍니다.";
			loc = req.getContextPath()+"/myinfo.action";
			
			req.setAttribute("msg", msg);
			req.setAttribute("loc", loc);
			session.setAttribute("loginuser", loginuser);
			return "msg";
		}
		else {
			session.setAttribute("loginuser", loginuser);
			
//			#세션에 저장되어있는 돌아갈 페이지가 있는 경우 그쪽으로 돌려보냄
			if(session.getAttribute("goBackURL") != null) {				
				String goBackURL = (String)session.getAttribute("goBackURL");
				req.setAttribute("goBackURL", goBackURL);
				session.removeAttribute("goBackURL");
				
			}
			return "login/loginEnd.tiles1";
//			>> /Board/src/main/webapp/WEB-INF/views/tiles1/login/loginEnd.jsp 파일 생성하기
		}
	}
	
	
//	#비밀번호 변경을 위해 나의 정보로 이동
	@RequestMapping(value="/myinfo.action", method={RequestMethod.GET})
	public String myinfo(HttpServletRequest req) {
		return "login/myinfo.tiles1";
	    //  /Board/src/main/webapp/WEB-INF/views/tiles1/login/myinfo.jsp 파일을 생성한다.
	}
	
// ===== #50. 로그아웃 완료 요청. =====
	@RequestMapping(value="/logout.action", method={RequestMethod.GET})
	public String logout(HttpServletRequest req, HttpSession session) {
		
		 session.invalidate();
	  	
		 String msg = "로그아웃 되었습니다."; 
		 String ctxPath = req.getContextPath();
		 String loc = ctxPath+"/index.action";
			
		 req.setAttribute("msg", msg);
		 req.setAttribute("loc", loc);
			
		 return "msg";
	}
	
//	[181231]
//	===== #51. 글쓰기 폼페이지 요청하기 =====
//	>> 포인트컷으로 잘라와서 글쓰기 폼 페이지에 가기 전에 로그인 요청부터 해줌(LoginCheck 클래스)
	@RequestMapping(value="/add.action", method={RequestMethod.GET})
	public String requireLogin_add(HttpServletRequest req, HttpServletResponse res) {
//		===== #125. 답글쓰기 요청이 들어왔을 때 답글 작성하기 =====
		String fk_seq = req.getParameter("fk_seq");
		String groupno = req.getParameter("groupno");
		String depthno = req.getParameter("depthno");
		
		if((fk_seq != null || fk_seq != "") 
				&& (groupno != null || groupno != "") 
				&& (depthno != null || depthno != "")) {
			req.setAttribute("fk_seq", fk_seq);
			req.setAttribute("groupno", groupno);
			req.setAttribute("depthno", depthno);
		}
		
		
		return "board/add.tiles1";
	}
	
//	===== #53. 글 작성 폼에서 입력한 값을 받아와서 DB에 insert하기 =====
	@RequestMapping(value="/addEnd.action", method={RequestMethod.POST})
//	public String addEnd(BoardVO boardvo, HttpServletRequest req) {
//		>> view단에서 보낸 form의 name이 VO의 변수명과 같을 때 VO 타입으로 받아오면 req에서 파라미터값 안받아와도 됨
//	[190107]
/*	===== #136. 파일첨부가 된 글쓰기 HttpServletRequest 대신 MultipartHttpServletRequest 객체를 파라미터로 받아옴
	MultipartHttpServletRequest를 사용하려면 servlet-context.xml에서 multipartResolver를 bean으로 등록해줘야 함	*/
	public String addEnd(BoardVO boardvo, MultipartHttpServletRequest req) {
/*
	웹페이지에 요청form이 enctype="multipart/form-data" 으로 되어있어서 Multipart 요청(파일처리 요청)이 들어올때 
	컨트롤러에서는 HttpServletRequest 대신 MultipartHttpServletRequest 인터페이스를 사용해야 한다.
	MultipartHttpServletRequest 인터페이스는 HttpServletRequest 인터페이스와 MultipartRequest 인터페이스를 상속받고있다.
	즉, 웹 요청 정보를 얻기 위한 getParameter()와 같은 메소드와 Multipart(파일처리) 관련 메소드를 모두 사용가능하다.
	 
	===== 사용자가 쓴 글에 파일이 첨부되어 있는 것인지 아니면 파일첨부가 안된것인지 구분을 지어주어야 한다. =====
		========= !!첨부파일이 있는지 없는지 알아오기 시작!! ========= */
		MultipartFile attach = boardvo.getAttach();
		
		if(!attach.isEmpty()) {
//			#attach가 비어있지 않을 때(첨부파일이 있는 경우)
//			1) WAS의 특정 폴더에 사용자가 업로드한 파일을 저장; webapp/resources/files
			HttpSession session = req.getSession();
			String root = session.getServletContext().getRealPath("/");	// >> / == webapp(like webcontent)
			// >> root는 .metadata
			
			String path =root+"resources" +File.separator+"files"; // 첨부파일들을 저장할 WAS내의 폴더  경로
			
//			System.out.println("[Controller] path: "+path);
//			[Controller] path: C:\SpringWorkspace\.metadata\.plugins\org.eclipse.wst.server.core\tmp0\wtpwebapps\Board\resources\files
			
//			2) 파일첨부를 위한 변수의 설정 및 값을 초기화한 후 파일 업로드
			String newFileName = "";	// WAS 디스크에 저장할 파일명
			byte[] bytes = null;	// 첨부파일을 WAS디스크에 저장할 때 사용하는 용도
			long fileSize = 0;		// 파일 크기를 읽어오는 용도
		
			try {
				// 바이트 타입의 배열로 직렬화한 값을 읽어오기
				bytes = attach.getBytes();
				
				newFileName = fileManager.doFileUpload(bytes, attach.getOriginalFilename(), path);
				// 201901070912354846876..png
			} catch (Exception e) {
				e.printStackTrace();
			}
//			System.out.println("[Controller] newFileName: "+newFileName);
//			[Controller] newFileName: 201901071125391474462150770003.jpg
			
//			3) BoardVO의 fileName, orgFilename, fileSize 값을 넣어주기
			boardvo.setFileName(newFileName);
			boardvo.setOrgFilename(attach.getOriginalFilename());
			boardvo.setFileSize(String.valueOf(attach.getSize()));
		}
//		========= !!첨부파일이 있는지 없는지 알아오기 종료!! =========
//		int result = service.add(boardvo);
		
//		#140. 파일첨부 유무에 따라 service로 객체 전송하기
		int result = 0;
		if(attach.isEmpty()) {
			// 파일첨부가 없을 때
			result = service.add(boardvo);	// 기존에 쓰던 메소드 그대로 사용
		}
		else {
			// 파일첨부가 있을 때
			result = service.add_withFile(boardvo);
		}
		String loc="";
		
//		#insert 성공시 글 목록으로 보내줌
		if(result ==1) {
			loc = req.getContextPath()+"/list.action";
		}
		else {
			loc=req.getContextPath()+"/index.action";
		}
		req.setAttribute("result", result);
		req.setAttribute("loc", loc);
		
		return "board/addEnd.tiles1";
	}
	
//	===== #57. 글 목록 불러오기; 페이징X/검색어X =====
//	===== #106. 글 목록 불러오기; 페이징X/검색어O =====
//	[190104]
//	===== #110. 글 목록 불러오기; 페이징O/검색어O =====
	@RequestMapping(value="/list.action", method={RequestMethod.GET})
	public String list(HttpServletRequest req) {
		List<BoardVO> boardList = null;
		
//		#57. 페이징X/검색어X
//		boardList = service.getBoardListNoSearch();

//		#106. 페이징X/검색어O
/*		#검색타입(컬럼네임), 검색어 받아오기
		String colname = req.getParameter("colname");
		String search = req.getParameter("search");
		
		if(colname==null) {
			colname="subject";
		}
		if(search==null) {
			search="";
		}
		HashMap<String, String> paraMap = new HashMap<String ,String>();
		paraMap.put("colname", colname);
		paraMap.put("search",search);
		
		if(search != null && !search.trim().equals("") && !search.trim().equals("null")) {
			// 검색어가 있는 경우
			boardList = service.getBoardListWithSearch(paraMap);
			
//			#검색타입, 검색어 keep을 위해 다시 어트리뷰트에 셋팅
			req.setAttribute("colname", colname);	 
			req.setAttribute("search",search);
		}
		else {
			// 검색어가 없는 경우
			boardList = service.getBoardListWithSearch(paraMap);
		}*/
//---------------------------------------------------------------------------------------------		
//		#110. 페이징O/검색어O
/*		ex) 3페이지를 볼 때
		-> http://localhost:9090/board/list.action?colname=name&search=&currentShowPageNo=3 */
		
//		1) 사용자가 보려는 페이지의 번호, 검색타입(컬럼네임), 검색어 받아오기
		String str_currentShowPageNo = req.getParameter("currentShowPageNo");
		String colname = req.getParameter("colname");
		String search = req.getParameter("search");
		
		if(colname==null) {
			colname="subject";
		}
		if(search==null) {
			search="";
		}
		HashMap<String, String> paraMap = new HashMap<String ,String>();
		paraMap.put("colname", colname);
		paraMap.put("search",search);
		
//		2) 페이지 구분을 위한 변수 선언하기
		int totalCount = 0;			// 조건에 맞는 총게시물의 개수
		int sizePerPage = 10;		// 한 페이지당 보여줄 게시물 개수
		int currentShowPageNo = 0;	// 현재 보여줄 페이지번호(초기치 1)
		int totalPage = 0;			// 총 페이지 수(웹브라우저 상에서 보여줄 총 페이지의 개수)
		
		int startRno = 0;			// 시작행 번호
		int endRno = 0;				// 마지막행 번호
		
		int blockSize = 10;			// 페이지바의 블럭(토막) 개수
		
//		3) 총 페이지수 구하기
		if(search != null && !search.trim().equals("") && !search.trim().equals("null")) {
//			a. 검색어가 있을 때(search!=null || search!="") 총 게시물 개수 구하기
			totalCount = service.getTotalCountWithSearch(paraMap);
		}
		else {
//			b. 검색어가 없을 때(search==null || search=="") 총 게시물 개수 구하기
			totalCount = service.getTotalCountNoSearch();
		}
		totalPage=(int)Math.ceil((double)totalCount/sizePerPage);
		
//		4) 현재 페이지 번호 셋팅하기
		if(str_currentShowPageNo == null) {
//			게시판 초기 화면의 경우
			currentShowPageNo=1;
		}
		else {
//			특정 페이지를 조회한 경우
			try {
			currentShowPageNo = Integer.parseInt(str_currentShowPageNo);
			if(currentShowPageNo<1 || currentShowPageNo>totalPage) {
				currentShowPageNo = 1;
			}
			} catch(NumberFormatException e) {
				currentShowPageNo = 1;
			}
		}
		
//		5) 가져올 게시글의 범위 구하기(기존 공식과 다른 버전)
		startRno = ((currentShowPageNo-1) * sizePerPage)+1;
		endRno = startRno+sizePerPage -1; 
		
//		6) DB에서 조회할 조건들을 paraMap에 넣기
		paraMap.put("startRno", String.valueOf(startRno));
		paraMap.put("endRno", String.valueOf(endRno));
		
//		7) 게시글 목록 가져오기
		boardList = service.boardListPaging(paraMap);
//		System.out.println("boardList.size(): "+boardList.size());
		
		
//		#120. 페이지바 만들기(MyUtil에 있는 static메소드 사용)
		String pageBar = "<ul>";
		pageBar += MyUtil.getPageBarWithSearch(sizePerPage, blockSize, totalPage, currentShowPageNo, colname, search, null, "list.action");
		pageBar += "</ul>";
		
/* ===== #69. 글조회수(readCount)증가 (DML문 update)는	반드시 해당 글제목을 클릭했을 경우에만 글조회수가 증가되고 
		 이전보기, 다음보기를 했을 경우나 웹브라우저에서 새로고침(F5)을 했을 경우에는 증가가 안되도록 한다.(session을 이용하여 처리) ===== */
		HttpSession session = req.getSession();
		session.setAttribute("readCountPermission", "yes");
		
		req.setAttribute("boardList", boardList);
//		#검색타입, 검색어 keep을 위해 다시 어트리뷰트에 셋팅
		req.setAttribute("colname", colname);	 
		req.setAttribute("search",search);
		
//		#페이지바 넘겨주기
		req.setAttribute("pageBar", pageBar);
		
//		#currentURL 뷰로 보내기
		String currentURL = MyUtil.getCurrentURL(req);
//		System.out.println(currentURL);
		if(currentURL.substring(currentURL.length()-5).equals("?null")) {
			currentURL = currentURL.substring(0 , currentURL.length()-5);
//			System.out.println("잘라낸 링크: "+currentURL);
		}
		req.setAttribute("currentURL", currentURL);
		return "board/list.tiles1";
	}
	
//	===== #61. 글 상세 보기 =====
	@RequestMapping(value="/view.action", method={RequestMethod.GET})
	public String view(HttpServletRequest req) {
		String seq = req.getParameter("seq"); // 글번호 받아오기
		String goBackURL = req.getParameter("currentURL");
		
		BoardVO boardvo = null;	// 조회한 글의 정보를 담아줄 BoardVO객체변수
//		List<CommentVO> commentList = null;
		HttpSession session = req.getSession();
/* ===== #67. 글조회수(readCount)증가 (DML문 update)는	반드시 해당 글제목을 클릭했을 경우에만 글조회수가 증가되고 
		이전보기, 다음보기를 했을 경우나 웹브라우저에서 새로고침(F5)을 했을 경우에는 증가가 안되도록 한다.(session을 이용하여 처리	) ===== */

		String readCountPermission = (String)session.getAttribute("readCountPermission");
		MemberVO loginuser = (MemberVO)session.getAttribute("loginuser");
/*		#타인이 쓴 글의 상세를 읽어오면 readCount가 올라감
		로그인 하지 않은 상태에서도 글은 읽을 수 있지만 readCount는 올라가지 않음	
		userid가 null일 때 - readCount의 증가 없이 글 조회
				null이 아닐 때 - 로그인유저와 글쓴이가 동일인물일 때 - readCount증가 없이 글 조회
				 		   - 불일치 할 때 - readCount 증가 및 글 조회	*/
		String userid = null;
		if(readCountPermission != null && "yes".equals(readCountPermission)) {
			if(loginuser != null) {
				userid = loginuser.getUserid();
			}

			boardvo = service.getView(seq, userid);
//			#글 1개를 보기 위해 글목록을 거쳐온 경우, 확인 후 세션에서 값을 지움
			session.removeAttribute("readCountPermission");
		}
		else {
//			#세션에서 값을 지운 경우(글을 조회하고난 다음) --> 새로고침 또는 이전글 다음글로 접근 --> 조회수 카운트 XX
			boardvo = service.getViewWithNoAddCount(seq);
			/*if(boardvo.getCommentCount()!="0") {
				commentList = service.getComment(seq);
			}*/
		}
		req.setAttribute("boardvo", boardvo);
		req.setAttribute("goBackURL", goBackURL);
//		req.setAttribute("commentList", commentList);
		
		return "board/view.tiles1";
	}

	
//	[190102]	
//	===== #70. 글 수정하기; 글 수정 페이지로 보내기 =====
//	-> 1. 로그인 했을 때  접근 가능 / 2. 작성자만 수정 가능 / 3. 글 암호 확인
	@RequestMapping(value="/edit.action", method={RequestMethod.GET})
	public String requireLogin_edit(HttpServletRequest req, HttpServletResponse res) {
//		1) 수정할 글의 seq 가져오기
		String seq = req.getParameter("seq");
		
//		2) 수정할 글의 전체 내용 가져오기; 위에서 글 상세 읽을 때 썼던 메소드 재활용
		BoardVO boardvo = service.getViewWithNoAddCount(seq);
		
//		3) 로그인한 유저가 수정할 글의 작성자인지 확인
		HttpSession session = req.getSession();
		MemberVO loginuser = (MemberVO)session.getAttribute("loginuser");
		
		if(!loginuser.getUserid().equals(boardvo.getFk_userid())) {
			String msg="다른 사용자의 글은 수정이 불가합니다.";
			String loc="javascript:history.back();";
			req.setAttribute("msg", msg);
			req.setAttribute("loc", loc);
			
			return "msg";
		}
		else {
			req.setAttribute("boardvo", boardvo);
			return "board/edit.tiles1";
		}
		
	}

	
//	===== #71. 글 수정하기; 글 수정 완료 페이지  =====
	@RequestMapping(value="/editEnd.action", method={RequestMethod.POST})
	public String editEnd(BoardVO boardvo, HttpServletRequest req) {
//		1) form에서 보낸 암호와 기존 글 정보의 암호가 일치하는 지 확인
		HashMap<String, String> paraMap = new HashMap<String, String>();
		paraMap.put("SEQ", boardvo.getSeq());
		paraMap.put("PW", boardvo.getPw());
		paraMap.put("SUBJECT", boardvo.getSubject());
		paraMap.put("CONTENT", boardvo.getContent());
		
		int result = service.edit(paraMap);
//		넘겨받은 값이 1이면 update성공, 0이면 실패(암호 불일치)
		
		String msg = "";
		String loc = "";
		
		if(result == 0) {
			msg="글 수정 실패";
			loc="javascript:history.back();";
		}
		else {
			msg="글 수정 완료";
			loc=req.getContextPath()+"/view.action?seq="+boardvo.getSeq();
//			>> 수정완료 후 수정된 글의 상세페이지로 이동
		}
		req.setAttribute("msg", msg);
		req.setAttribute("loc", loc);
		return "msg";
	}

	
//	===== #77. 글 삭제하기; 페이지 요청 =====
	@RequestMapping(value="/del.action", method={RequestMethod.GET})	
	public String requireLogin_del(HttpServletRequest req, HttpServletResponse res) {
//		1) 삭제할 글의 seq 가져오기
		String seq = req.getParameter("seq");
		
//		2) 삭제할 글의 전체 내용 가져오기; 위에서 글 상세 읽을 때 썼던 메소드 재활용
		BoardVO boardvo = service.getViewWithNoAddCount(seq); 
		
//		3) 로그인한 유저가 삭제할 글의 작성자인지 확인
		HttpSession session = req.getSession();
		MemberVO loginuser = (MemberVO)session.getAttribute("loginuser");
		
		if(!loginuser.getUserid().equals(boardvo.getFk_userid())) {
			String msg="다른 사용자의 글은 삭제가 불가합니다.";
			String loc="javascript:history.back();";
			req.setAttribute("msg", msg);
			req.setAttribute("loc", loc);
			
			return "msg";
		}
		else {
			req.setAttribute("seq", seq);
			
//			4) 글 암호 검사
			return "board/del.tiles1";
		}
	}
	
//	===== #78. 글 삭제하기; 글 삭제 완료 페이지  =====
	@RequestMapping(value="/delEnd.action", method={RequestMethod.POST})
	public String delEnd(BoardVO boardvo, HttpServletRequest req) throws Throwable{
//		1) form에서 보낸 암호와 기존 글 정보의 암호가 일치하는 지 확인
		HashMap<String, String> paraMap = new HashMap<String, String>();
		paraMap.put("SEQ", boardvo.getSeq());
		paraMap.put("PW", boardvo.getPw());
		
		int result = service.del(paraMap);
//		넘겨받은 값이 1이면 update성공, 0이면 실패(암호 불일치)
		
		String msg = "";
		String loc = "";
		
		if(result == 0) {
			msg="글 삭제 실패";
			loc="javascript:history.back();";
		}
		else {
			msg="글 삭제 완료";
			loc=req.getContextPath()+"/list.action";
//			>> 삭제완료 후 글 목록으로 이동
		}
		req.setAttribute("msg", msg);
		req.setAttribute("loc", loc);
		return "msg";
	}
	
//	===== #85. 댓글 쓰기  ===== 
	@RequestMapping(value="/addComment.action", method={RequestMethod.POST})
	@ResponseBody
	public HashMap<String, String> addComment(CommentVO cvo, HttpServletRequest req) throws Throwable {
		HashMap<String, String> returnMap = new HashMap<String, String>();
		
		int n = service.addComment(cvo);
		
		if(n==1) {
//			댓글 쓰기 및 원 게시글 데이터에 댓글갯수가 1만큼 update 성공했을 때 
			returnMap.put("fk_userid", cvo.getFk_userid());
			returnMap.put("name", cvo.getName());
			returnMap.put("content", cvo.getContent());
			returnMap.put("regdate", MyUtil.getNowTime());
		}

		return returnMap;
	}
	
//	[190103]
//	===== #92-1. Ajax로 댓글 목록 출력하기; 특정페이지(1, 2, 3페이지...)의 댓글목록만 가져오기 =====
	@RequestMapping(value="/commentList.action", method= {RequestMethod.GET})
	@ResponseBody
	public List<HashMap<String, Object>> commentList(HttpServletRequest req) {
//		***JSONArray타입을 대체할 HashMap타입의 List 객체 생성
		List<HashMap<String, Object>> mapList = new ArrayList<HashMap<String, Object>>();
		
//		1) 뷰에서 보낸 파라미터값 가져오기
		String parentSeq = req.getParameter("parentSeq");
		String currentShowPageNo = req.getParameter("currentShowPageNo");
		
		if(currentShowPageNo == null || "".equals(currentShowPageNo)) {
			currentShowPageNo = "1";
		}
		
//		2) 페이징 처리 공식에 따라서 페이징처리할 값 계산하기
/*		#페이징 처리 공식
		rno1 = 특정페이지번호*한페이지당 보여줄 댓글개수-(댓글개수-1)
		rno2 = 특정페이지번호*한페이지당 보여줄 댓글개수
		
 		currentShowPageNo
 		(페이지번호)			rno1		rno2
		-------------------------------------
			1페이지			1			5
			2페이지			6			10
			3페이지			11			15
			....							*/
		int sizePerPage = 5;	// 한 페이지 당 보여줄 댓글의 갯수
		int rno1 = Integer.parseInt(currentShowPageNo) * sizePerPage - (sizePerPage-1);
		int rno2 = Integer.parseInt(currentShowPageNo) * sizePerPage;

//		3) service단에 보내줄 파라미터맵 만들기; 부모글번호, 한 페이지에 보여줄 댓글의 rownum 시작번호, 끝번호
		HashMap<String, String> paraMap = new HashMap<String, String>();
		paraMap.put("parentSeq", parentSeq);
		paraMap.put("rno1", String.valueOf(rno1));
		paraMap.put("rno2", String.valueOf(rno2));
		
//		4) 페이지번호에 따른 CommentVO타입의 List 가져오기
		List<CommentVO> commentList = service.listComment(paraMap);
		
//		5) JSON객체를 대신할 HashMap객체에 가져온 값을 담아서 JSONArray에 넣어줌
		for(CommentVO cmtvo : commentList) {
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("fk_userid", cmtvo.getFk_userid());
			map.put("name", cmtvo.getName());
			map.put("content", cmtvo.getContent());
			map.put("regdate", cmtvo.getRegDate());
			
			mapList.add(map);
		}
		
		return mapList;
	}
//	===== #92-2. Ajax로 댓글 목록의 페이지바 출력하기 =====
	@RequestMapping(value="/getCommentTotalPage.action", method= {RequestMethod.GET})
	@ResponseBody
	public HashMap<String, Integer> getCommentTotalPage(HttpServletRequest req) {
//		***JSONObject를 대체할 HashMap객체 생성
		HashMap<String, Integer> returnMap = new HashMap<String, Integer>();
		
//		1) 뷰에서 보낸 파라미터값 가져오기
		String parentSeq = req.getParameter("parentSeq");
		String sizePerPage = req.getParameter("sizePerPage");
		
		if(sizePerPage == null || "".equals(sizePerPage)) {
			sizePerPage = "5";
		}

//		2) service단에 보내줄 파라미터맵 만들기; 부모글번호, 페이지바 사이즈
		HashMap<String, String> paraMap = new HashMap<String, String>();
		paraMap.put("parentSeq", parentSeq);
		paraMap.put("sizePerPage", sizePerPage);
		
//		3) 부모글번호에 해당하는 댓글 갯수 가져오기 
		int totalCount = service.getCommentTotalCount(paraMap);
		
//		4) 총 페이지 수 구하기
//		ex) 57.0(행 개수)/10(sizePerPage) => 5.7 => 6.0 => 6
//		ex2) 57.0(행 개수)/5(sizePerPage) => 11.4 => 12.0 => 12
		int totalPage = (int)Math.ceil((double)totalCount/Integer.parseInt(sizePerPage));
		
		returnMap.put("totalPage", totalPage);
		return returnMap;
	}
	
//	===== #149. 글 상세페이지에서 첨부파일 다운로드 하기
	@RequestMapping(value="/download.action", method= {RequestMethod.GET})
	public void requireLogin_download(HttpServletRequest req, HttpServletResponse res) {
		String seq = req.getParameter("seq");	// 다운받으려는 첨부파일이 있는 글 번호
		
//		#첨부파일이 있는 글 번호에서 메타데이터에 저장되어있는 파일명, 원본파일명을 가져오기
		BoardVO boardvo = service.getViewWithNoAddCount(seq);
		
		String saveFilename = boardvo.getFileName();	// 디스크에 올라가있는 파일명
		String orgFilename = boardvo.getOrgFilename();	// 실제 파일명
		
//		#다운받을 파일이 있는 메타데이터 경로 구하기
		HttpSession session = req.getSession();
		String root = session.getServletContext().getRealPath("/");	// >> / == webapp(like webcontent)
		// >> root는 .metadata
		
		String path =root+"resources" +File.separator+"files"; // 첨부파일들을 저장할 WAS내의 폴더  경로
		
//		#다운로드하기; boolean flag
		boolean flag = false;
		flag = fileManager.doFileDownload(saveFilename, orgFilename, path, res);
		// >> 다운로드 성공시 true, 실패시 false return
		if(!flag) {
			// 실패시 메시지 띄우기
			res.setContentType("text/html; charset=UTF-8");
			try {
				PrintWriter out = res.getWriter();	// 웹브라우저상에 내용물을 기재하는 객체
				
				out.println("<script type='text/javascript'>alert('파일 다운로드 실패');</script>");
				
			} catch (IOException e) {
				e.printStackTrace();
			}
			
		}
	}
	
	
//	[190114]
//	===== #스마트에디터1. 단일사진 파일 업로드
//	파일첨부는 무조건 POST 방식으로 전송
	@RequestMapping(value="/image/photoUpload.action", method= {RequestMethod.POST})
	public String photoUpload(PhotoVO photovo, HttpServletRequest req) {
		String callback = photovo.getCallback();
	    String callback_func = photovo.getCallback_func();
	    String file_result = "";
	    
		if(!photovo.getFiledata().isEmpty()) {
			// 파일이 존재한다라면
			
			/*
			   1. 사용자가 보낸 파일을 WAS(톰캣)의 특정 폴더에 저장해주어야 한다.
			   >>>> 파일이 업로드 되어질 특정 경로(폴더)지정해주기
			        우리는 WAS 의 webapp/resources/photo_upload 라는 폴더로 지정해준다.
			 */
			
			// WAS 의 webapp 의 절대경로를 알아와야 한다. 
			HttpSession session = req.getSession();
			String root = session.getServletContext().getRealPath("/"); 
			String path = root + "resources"+File.separator+"photo_upload";
			// path 가 첨부파일들을 저장할 WAS(톰캣)의 폴더가 된다. 
			
		//	System.out.println(">>>> 확인용 path ==> " + path); 
			// >>>> 확인용 path ==> C:\SpringWorkspace\.metadata\.plugins\org.eclipse.wst.server.core\tmp0\wtpwebapps\Board\resources\photo_upload\
			
			// 2. 파일첨부를 위한 변수의 설정 및 값을 초기화한 후 파일올리기
			String newFilename = "";
			// WAS(톰캣) 디스크에 저장할 파일명 
			
			byte[] bytes = null;
			// 첨부파일을 WAS(톰캣) 디스크에 저장할때 사용되는 용도 
						
			try {
				bytes = photovo.getFiledata().getBytes(); 
				// getBytes()는 첨부된 파일을 바이트단위로 파일을 다 읽어오는 것이다. 
				/* 2-1. 첨부된 파일을 읽어오는 것
					    첨부한 파일이 강아지.png 이라면
					    이파일을 WAS(톰캣) 디스크에 저장시키기 위해
					    byte[] 타입으로 변경해서 받아들인다.
				*/
				// 2-2. 이제 파일올리기를 한다.
				String original_name = photovo.getFiledata().getOriginalFilename();
				//  photovo.getFiledata().getOriginalFilename() 은 첨부된 파일의 실제 파일명(문자열)을 얻어오는 것이다. 
				newFilename = fileManager.doFileUpload(bytes, original_name, path);
				
		//      System.out.println(">>>> 확인용 newFileName ==> " + newFileName); 
				
				int width = fileManager.getImageWidth(path+File.separator+newFilename);
		//		System.out.println("확인용 >>>>>>>> width : " + width);
				
				if(width > 600) {
					width = 600;
					newFilename = largeThumbnailManager.doCreateThumbnail(newFilename, path);
				}
		//		System.out.println("확인용 >>>>>>>> width : " + width);
				
				String CP = req.getContextPath();  // board
				file_result += "&bNewLine=true&sFileName="+newFilename+"&sWidth="+width+"&sFileURL="+CP+"/resources/photo_upload/"+newFilename; 
				
			} catch (Exception e) {
				e.printStackTrace();
			}
			
		} else {
			// 파일이 존재하지 않는다라면
			file_result += "&errstr=error";
		}
		return "redirect:" + callback + "?callback_func="+callback_func+file_result;
	}
	
// ==== #스마트에디터4. 드래그앤드롭을 사용한 다중사진 파일업로드 ====
	@RequestMapping(value="/image/multiplePhotoUpload.action", method={RequestMethod.POST})
	public void multiplePhotoUpload(HttpServletRequest req, HttpServletResponse res) {
	    
		/*
		   1. 사용자가 보낸 파일을 WAS(톰캣)의 특정 폴더에 저장해주어야 한다.
		   >>>> 파일이 업로드 되어질 특정 경로(폴더)지정해주기
		        우리는 WAS 의 webapp/resources/photo_upload 라는 폴더로 지정해준다.
		*/
		
		// WAS 의 webapp 의 절대경로를 알아와야 한다. 
		HttpSession session = req.getSession();
		String root = session.getServletContext().getRealPath("/"); 
		String path = root + "resources"+File.separator+"photo_upload";
		// path 가 첨부파일들을 저장할 WAS(톰캣)의 폴더가 된다. 
		
	//	System.out.println(">>>> 확인용 path ==> " + path); 
		// >>>> 확인용 path ==> C:\SpringWorkspace\.metadata\.plugins\org.eclipse.wst.server.core\tmp0\wtpwebapps\Board\resources\photo_upload\  
		
		File dir = new File(path);
		if(!dir.exists())
			dir.mkdirs();
		
		String strURL = "";
		
		try {
			if(!"OPTIONS".equals(req.getMethod().toUpperCase())) {
	    		String filename = req.getHeader("file-name"); //파일명을 받는다 - 일반 원본파일명
	    		
	    //		System.out.println(">>>> 확인용 filename ==> " + filename); 
	    		// >>>> 확인용 filename ==> berkelekle%ED%8A%B8%EB%9E%9C%EB%94%9405.jpg
	    		
	    		InputStream is = req.getInputStream();
	    	/*
	          	요청 헤더의 content-type이 application/json 이거나 multipart/form-data 형식일 때,
	          	혹은 이름 없이 값만 전달될 때 이 값은 요청 헤더가 아닌 바디를 통해 전달된다. 
	          	이러한 형태의 값을 'payload body'라고 하는데 요청 바디에 직접 쓰여진다 하여 'request body post data'라고도 한다.

               	서블릿에서 payload body는 Request.getParameter()가 아니라 
            	Request.getInputStream() 혹은 Request.getReader()를 통해 body를 직접 읽는 방식으로 가져온다. 	
	    	 */
	    		String newFilename = fileManager.doFileUpload(is, filename, path);
	    	
				int width = fileManager.getImageWidth(path+File.separator+newFilename);
       //		System.out.println(">>>> 확인용 width ==> " + width);
				
				if(width > 600) {
					width = 600;
					newFilename = largeThumbnailManager.doCreateThumbnail(newFilename, path);
				}
		//		System.out.println(">>>> 확인용 width ==> " + width);
				// >>>> 확인용 width ==> 600
				// >>>> 확인용 width ==> 121
	    	
				String CP = req.getContextPath(); // board
			
				strURL += "&bNewLine=true&sFileName="; 
            	strURL += newFilename;
            	strURL += "&sWidth="+width;
            	strURL += "&sFileURL="+CP+"/resources/photo_upload/"+newFilename;
	    	}
		
	    	/// 웹브라우저상에 사진 이미지를 쓰기 ///
			PrintWriter out = res.getWriter();
			out.print(strURL);
		} catch(Exception e){
			e.printStackTrace();
		}
		
	}// end of void multiplePhotoUpload(HttpServletRequest req, HttpServletResponse res)---------------- 
	
//	[190121]
//	#전국맛집찾기 페이지로 이동하기
	@RequestMapping(value="/deliciousStore.action", method={RequestMethod.GET})
	public String deliciousStore() {
		
		return "store/deliciousStore.tiles2";
	}
}
