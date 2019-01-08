package com.spring.board.service;
import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.spring.board.model.BoardVO;
import com.spring.board.model.CommentVO;
import com.spring.board.model.InterBoardDAO;
import com.spring.common.AES256;
import com.spring.member.model.MemberVO;

// ===== #31. Service 선언
@Service
public class BoardService implements InterBoardService {
//	===== #34. MyBatisDAO DI(의존객체) 주입하기
	@Autowired
	private InterBoardDAO dao;
	
//	===== #45. 암호화를 위한 DI 주입하기
	@Autowired
	private AES256 aes;
	
//	===== #37. 이미지 파일 이름 리스트 가져오기
	@Override
	public List<String> getImgfilenameList() {
		List<String> imgfilenameList = dao.getImgfilenameList();
		return imgfilenameList;
	}
	
//	===== #42. 로그인 여부/마지막 로그인 일시 알아오기
	@Override
	public MemberVO getLoginMember(HashMap<String, String> map) {
		MemberVO loginuser = dao.getLoginMember(map);
		
//	===== #48. aes DI로 이메일 복호화
		if(loginuser==null) {

			return loginuser;
		}
		else if(loginuser != null && loginuser.getLastlogindategap()>=12) {
//			#마지막  로그인 일시가 12개월 이상인 경우  requireCertify 변수 값을 true, 아니면 false
			loginuser.setRequireCertify(true);
			return loginuser;
		}
		
		else {
			if(loginuser.getPwdchangegap()>=6) {
//				#마지막  암호 변경 일시가 6개월 이상이면 requirePwdChange 변수 값을 true, 아니면 false
				loginuser.setRequirePwdChange(true);
			}
			
			try {
				dao.setLastLoginDate(map);	// 마지막 로그인 일시를 현재시각으로 변경하기
				loginuser.setEmail(aes.decrypt(loginuser.getEmail()));
			} catch (UnsupportedEncodingException | GeneralSecurityException e) {
				e.printStackTrace();
			} 

			return loginuser;
			
		}
		
	}

//	[181231]
//	===== #54. 글 작성하기(파일첨부X)
	@Override
	public int add(BoardVO boardvo) {
//		===== #127. 원글인지 답글쓰기인지 구분하여 tblBoard 테이블에 insert
//		원글쓰기일 때; groupno 컬럼의 값을 최대값(max)+1해서 insert
//		답글쓰기일 때; groupno의 값을 넘겨받은 값으로 insert
		
		if(boardvo.getFk_seq() == null || boardvo.getFk_seq().trim().isEmpty()) {
			// 원글쓰기인 경우
			int groupno = dao.getGroupNoMax()+1;
			boardvo.setGroupno(String.valueOf(groupno));
		}
		int result = dao.add(boardvo);
		return result;
	}

//	[190107]
//	===== #141. 첨부파일이 있는 글 작성하기
	@Override
	public int add_withFile(BoardVO boardvo) {
		if(boardvo.getFk_seq() == null || boardvo.getFk_seq().trim().isEmpty()) {
			// 원글쓰기인 경우
			int groupno = dao.getGroupNoMax()+1;
			boardvo.setGroupno(String.valueOf(groupno));
		}
		
		int result = dao.add_withFile(boardvo);
		return result;
	}

//	===== #58. 검색 조건, 페이징 처리 없는 전체글목록 가져오기
	@Override
	public List<BoardVO> getBoardListNoSearch() {
		List<BoardVO> boardList = dao.getBoardListNoSearch();
		return boardList;
	}

// ===== #107. 글 목록 가져오기(페이징X, 검색어O) =====	
	@Override
	public List<BoardVO> getBoardListWithSearch(HashMap<String, String> paraMap) {
		List<BoardVO> boardList = dao.getBoardListWithSearch(paraMap);
		return boardList;
	}	
	
	
//	===== #62. 글 상세 조회
	@Override
	public BoardVO getView(String seq, String userid) {
//		1) 글 정보 읽어오기
		BoardVO boardvo = dao.getView(seq);
		
//		2) 글 조회수 증가 여부를 판단하기		
		if(userid!=null && !boardvo.getFk_userid().equals(userid)) {
			dao.setAddReadCount(seq);
			boardvo = dao.getView(seq);
		}
		return boardvo;
	}

//	===== #68. 글 상세 조회; 글 조회수 증가XX
	@Override
	public BoardVO getViewWithNoAddCount(String seq) {
//		#글 정보 읽어오기
		BoardVO boardvo = dao.getView(seq);
		return boardvo;
	}

//	===== #72. 글 수정하기; 글암호가 일치할 때만 update(트랜잭션 처리)
	@Override
	public int edit(HashMap<String, String> paraMap) {
		boolean checkpw = dao.checkPW(paraMap);
		
		int result = 0;
		if(checkpw) {
			result = dao.updateContent(paraMap);
		}
		
		return result;
	}

//	===== #79. 글 삭제하기; 글암호가 일치할 때만 delete
	@Override
//	public int del(HashMap<String, String> paraMap) {
//	===== #98. 글 삭제하기; 글암호가 일치할 때만 status update(트랜잭션 처리)
	@Transactional(propagation=Propagation.REQUIRED, isolation= Isolation.READ_COMMITTED, rollbackFor={Throwable.class})
	public int del(HashMap<String, String> paraMap) throws Throwable {
		boolean checkpw = dao.checkPW(paraMap);
		
		int count = 0; 	// 원글에 달려있는 댓글 유무 확인
		
		int n1 = 0;
		int n2 = 0;
		int result = 0;
		if(checkpw) {
			count = dao.isExistsComment(paraMap); // #99. 댓글 유무 알아오기
			n1 = dao.deleteContent(paraMap);	// 원글 1개 삭제하기
			
			if(count>0) {
				// #100. 원글에 달려있는 댓글 삭제하기
				n2 = dao.deleteComment(paraMap);
			}
		}
		
		if((n1 >0 && (count>0 && n2>0)) || (n1 >0 && count==0)) {
			result=1;
		}
		
		return result;
	}

// ===== #86. 댓글쓰기 =====
// tblComment 테이블에 insert 된 다음에 tblBoard 테이블에 commentCount 컬럼이 1증가(update) 하도록 요청한다.
// 즉, 2개이상의 DML 처리를 해야하므로 Transaction 처리를 해야 한다.
// >>>>> 트랜잭션처리를 해야할 메소드에 @Transactional 어노테이션을 설정하면 된다. 
// rollbackFor={Throwable.class} 은 롤백을 해야할 범위를 말하는데 Throwable.class 은 error 및 exception 을 포함한 최상위 루트이다. 
// 즉, 해당 메소드 실행시 발생하는 모든 error 및 exception 에 대해서 롤백을 하겠다는 말이다.
	@Override
	@Transactional(propagation=Propagation.REQUIRED, isolation= Isolation.READ_COMMITTED, rollbackFor={Throwable.class})
	public int addComment(CommentVO cvo) throws Throwable {
		int result=0;
		
		int n=0;
		n=dao.addComment(cvo);
		
		if(n==1) {
			result = dao.updateCommentCount(cvo.getParentSeq());
		}
		return result;
	}

//	#댓글 목록 가져오기
	@Override
	public List<CommentVO> getComment(String seq) {
		List<CommentVO> commentList = dao.getComment(seq);
		return commentList;
	}

// ===== #93-1. 댓글 목록 가져오기; 페이징처리 완료 =====
	@Override
	public List<CommentVO> listComment(HashMap<String, String> paraMap) {
		List<CommentVO> commentList = dao.listComment(paraMap);
		return commentList;
	}

// ===== #93-2. 부모글의 총 댓글 개수 가져오기 =====	
	@Override
	public int getCommentTotalCount(HashMap<String, String> paraMap) {
		int commentTotalCount = dao.getCommentTotalCount(paraMap);
		return commentTotalCount;
	}

//	[190104]	
// ===== #111. 검색타입/검색어에 만족하는 총 게시글 개수 가져오기 =====
	@Override
	public int getTotalCountWithSearch(HashMap<String, String> paraMap) {
		int totalCount = dao.getTotalCountWithSearch(paraMap);
		return totalCount;
	}
// ===== #112. 검색조건이 없는 총 게시글 개수 가져오기 =====
	@Override
	public int getTotalCountNoSearch() {
		int totalCount = dao.getTotalCountNoSearch();
		return totalCount;
	}

// ===== #117. 검색조건이 있는 총 게시글 개수 가져오기 =====
	@Override
	public List<BoardVO> boardListPaging(HashMap<String, String> paraMap) {
		List<BoardVO> boardList = dao.boardListPaging(paraMap);
		return boardList;
	}



}
