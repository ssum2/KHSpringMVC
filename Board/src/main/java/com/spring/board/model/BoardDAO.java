package com.spring.board.model;

import java.util.HashMap;
import java.util.List;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.spring.member.model.MemberVO;

//	===== #32. Respository 선언
@Repository
public class BoardDAO implements InterBoardDAO {

//	===== #33. DI(의존객체) 주입하기
	@Autowired
	private SqlSessionTemplate sqlsession;

//	===== #38. 이미지 파일 이름 리스트 가져오기
	@Override
	public List<String> getImgfilenameList() {
		List<String> imgfilenameList = sqlsession.selectList("board.imgfilenamelist");
		return imgfilenameList;
	}

//	===== #46. 로그인 여부/마지막 로그인 일시 알아오기; DAO에서는 해당 유저가 있는지 없는지 여부만 판별
	@Override
	public MemberVO getLoginMember(HashMap<String, String> map) {

		MemberVO loginuser = sqlsession.selectOne("board.getLoginMember", map);
		return loginuser;
	}

//	#46. 마지막 로그인 일시 기록하기
	@Override
	public void setLastLoginDate(HashMap<String, String> map) {
		sqlsession.update("board.setLastLoginDate", map);
	}

//	[181231]
//	===== #55. 글 작성하기(파일첨부X)
	@Override
	public int add(BoardVO boardvo) {
		int result = sqlsession.insert("board.add", boardvo);
		return result;
	}
	
//	===== #59. 전체 글 목록 가져오기(페이징X, 검색어X)
	@Override
	public List<BoardVO> getBoardListNoSearch() {
		List<BoardVO> boardList = sqlsession.selectList("board.boardListNoSearch");
		return boardList;
	}
	
//	===== #108. 글 목록 가져오기(페이징X, 검색어O)
	@Override
	public List<BoardVO> getBoardListWithSearch(HashMap<String, String> paraMap) {
		List<BoardVO> boardList = sqlsession.selectList("board.boardListWithSearch", paraMap);
		return boardList;
	}
	
//	===== #63. 글 상세 조회	
	@Override
	public BoardVO getView(String seq) {
		BoardVO boardvo = sqlsession.selectOne("board.getView", seq);
		return boardvo;
	}

//	===== #64. 글 상세 조회; 조회수 증가하기	
	@Override
	public void setAddReadCount(String seq) {
		sqlsession.update("board.setAddReadCount", seq);
	}

//	===== #73. 글 암호 검사(글 수정 및 삭제)
	@Override
	public boolean checkPW(HashMap<String, String> paraMap) {
		
		boolean checkpw = false;
		int n = sqlsession.selectOne("board.checkPW", paraMap);
		if(n==1) {
			checkpw = true;
		}
		return checkpw;
	}

//	===== #75. 글 수정하기
	@Override
	public int updateContent(HashMap<String, String> paraMap) {
		int result = sqlsession.update("board.updateContent", paraMap);
		return result;
	}

//	===== #80. 글 삭제하기(트랜잭션 처리)
	@Override
	public int deleteContent(HashMap<String, String> paraMap) {
		int result = sqlsession.update("board.deleteContent", paraMap);
//		>> 본래 delete 이지만 답변형 게시판으로 만들 예정이기 때문에 update로 status만 변경하도록 함
		return result;
	}

//	===== #87. 댓글 작성(추가)하기; insert; 트랜잭션 처리(1)
	@Override
	public int addComment(CommentVO cvo) {
		int result = sqlsession.insert("board.addComment", cvo);
		return result;
	}

//	===== #88. 댓글 작성 후 원글의 댓글카운트 증가시키기; update; 트랜잭션 처리(2)
	@Override
	public int updateCommentCount(String parentSeq) {
		int result = sqlsession.update("board.updateCommentCount", parentSeq);
		return result;
	}

//	#댓글 목록 가져오기
	@Override
	public List<CommentVO> getComment(String seq) {
		List<CommentVO> commentList = sqlsession.selectList("board.getComment", seq);
		return commentList;
	}

//	===== #94-1. 댓글 목록 가져오기(페이징처리)
	@Override
	public List<CommentVO> listComment(HashMap<String, String> paraMap) {
		List<CommentVO> commentList = sqlsession.selectList("board.listComment", paraMap);
		return commentList;
	}

//	===== #94-2. 댓글 목록 가져오기(페이징처리); 총 댓글 개수 가져오기
	@Override
	public int getCommentTotalCount(HashMap<String, String> paraMap) {
		int commentTotalCount = sqlsession.selectOne("board.getCommentTotalCount", paraMap);
		return commentTotalCount;
	}

//	===== #101. 원글의 댓글 유무 확인하기
	@Override
	public int isExistsComment(HashMap<String, String> paraMap) {
		int count = sqlsession.selectOne("board.isExistsComment", paraMap);

		return count;
	}
//	===== #102. 댓글 삭제하기(status변경)	
	@Override
	public int deleteComment(HashMap<String, String> paraMap) {
		int result = sqlsession.update("board.deleteComment", paraMap);
//		>> 본래 delete 이지만 답변형 게시판으로 만들 예정이기 때문에 update로 status만 변경하도록 함
		return result;
	}

//	[190104]
// ===== #113. 검색타입/검색어에 만족하는 총 게시글 개수 가져오기 =====
	@Override
	public int getTotalCountWithSearch(HashMap<String, String> paraMap) {
		int totalCount = sqlsession.selectOne("board.getTotalCountWithSearch", paraMap);
		return totalCount;
	}
	
// ===== #114. 검색조건이 없는 총 게시글 개수 가져오기 =====
	@Override
	public int getTotalCountNoSearch() {
		int totalCount = sqlsession.selectOne("board.getTotalCountNoSearch");
		return totalCount;
	}

// ===== #118. 검색조건에 맞는 총 게시글 가져오기 =====
	@Override
	public List<BoardVO> boardListPaging(HashMap<String, String> paraMap) {
		List<BoardVO> boardList = sqlsession.selectList("board.boardListPaging", paraMap);

		return boardList;
	}
	
// ===== #128. tblBoard테이블의 그룹번호 max값 가져오기 =====
	@Override
	public int getGroupNoMax() {
		int maxgroupno = sqlsession.selectOne("board.getGroupNoMax");
		return maxgroupno;
	}

//	===== #142. 첨부파일이 있는 글 작성하기
	@Override
	public int add_withFile(BoardVO boardvo) {
		int result = sqlsession.insert("board.add_withFile", boardvo);
		return result;
	}
}
