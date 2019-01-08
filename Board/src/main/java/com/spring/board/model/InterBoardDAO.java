package com.spring.board.model;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Repository;

import com.spring.member.model.MemberVO;

//===== #32. Respository 선언
@Repository
public interface InterBoardDAO {

//	#이미지 파일 이름 리스트 가져오기
	List<String> getImgfilenameList();

//	#로그인 체크
	MemberVO getLoginMember(HashMap<String, String> map);

	void setLastLoginDate(HashMap<String, String> map);

//	#글 작성하기(파일첨부X)
	int add(BoardVO boardvo);

//	#글 목록 불러오기1(페이징X, 검색어X)	
	List<BoardVO> getBoardListNoSearch();

//	#글 목록 불러오기2(페이징X, 검색어O)	
	List<BoardVO> getBoardListWithSearch(HashMap<String, String> paraMap);
	
//	#글 상세 조회하기
	BoardVO getView(String seq);

//	#글 상세정보를 조회할 때 조회수를 1씩 증가시키는 메소드
	void setAddReadCount(String seq);

//	#글 암호를 체크하는 메소드
	boolean checkPW(HashMap<String, String> paraMap);

//	#글 내용 수정하는 메소드(글 암호체크 후)
	int updateContent(HashMap<String, String> paraMap);

//	#글 삭제하기(트랜잭션  처리)
	int deleteContent(HashMap<String, String> paraMap);

//	#댓글 작성하기
	int addComment(CommentVO cvo);
	
//	#댓글 작성 메소드가 성공시에 댓글 갯수 컬럼 1증가
	int updateCommentCount(String parentSeq);

//	#댓글 목록 가져오기
	List<CommentVO> getComment(String seq);

//	#댓글 목록 가져오기; 페이징처리
	List<CommentVO> listComment(HashMap<String, String> paraMap);
//	#댓글 목록 가져오기; 댓글 목록의 페이지바를 구하기 위해 부모글의 총 댓글 개수 가져오기
	int getCommentTotalCount(HashMap<String, String> paraMap);
	
//	#원글에 댓글이 있는지 유무를 알아오는 메소드
	int isExistsComment(HashMap<String, String> paraMap);

//	#댓글 삭제하기
	int deleteComment(HashMap<String, String> paraMap);
	
//	#검색타입/검색어에 만족하는 총 게시물 개수 가져오기
	int getTotalCountWithSearch(HashMap<String, String> paraMap);

//	#검색조건이 없는 경우의 총 게시물 개수 가져오기
	int getTotalCountNoSearch();
	
//	#글 목록 불러오기3(페이징O, 검색어O or 검색어X)
	List<BoardVO> boardListPaging(HashMap<String, String> paraMap);

//	#tblBoard테이블의 groupno 컬럼의 최대값 알아오기
	int getGroupNoMax();

//	#첨부파일이 있는 글 작성하기
	int add_withFile(BoardVO boardvo);

}
