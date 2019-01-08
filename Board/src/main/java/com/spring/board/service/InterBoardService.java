package com.spring.board.service;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;

import com.spring.board.model.BoardVO;
import com.spring.board.model.CommentVO;
import com.spring.member.model.MemberVO;

@Service
public interface InterBoardService {

//	#이미지 파일 이름 리스트 가져오기
	List<String> getImgfilenameList();

//	#로그인 체크
	MemberVO getLoginMember(HashMap<String, String> map);

//	#글작성하기(파일첨부X)
	int add(BoardVO boardvo);

//	#글 목록 불러오기1(페이징X, 검색어X)
	List<BoardVO> getBoardListNoSearch();

//	#글 목록 불러오기2(페이징X, 검색어O)
	List<BoardVO> getBoardListWithSearch(HashMap<String, String> paraMap);
	
//	#글 상세 조회
	BoardVO getView(String seq, String userid);
	BoardVO getViewWithNoAddCount(String seq);

//	#글 수정하기
	int edit(HashMap<String, String> paraMap);

//	#글 삭제하기
	int del(HashMap<String, String> paraMap) throws Throwable;

//	#댓글 작성하기
	int addComment(CommentVO cvo) throws Throwable;

//	#댓글목록 가져오기
	List<CommentVO> getComment(String seq);

//	#댓글 목록 가져오기(페이징처리)
	List<CommentVO> listComment(HashMap<String, String> paraMap);

//	#부모글의 총 댓글 개수 가져오기
	int getCommentTotalCount(HashMap<String, String> paraMap);

//	#검색타입/검색어에 만족하는 총 게시물 개수 가져오기
	int getTotalCountWithSearch(HashMap<String, String> paraMap);

//	#검색조건이 없는 경우의 총 게시물 개수 가져오기
	int getTotalCountNoSearch();
	
//	#글 목록 불러오기3(페이징O, 검색어O or 검색어X)
	List<BoardVO> boardListPaging(HashMap<String, String> paraMap);

//	#첨부파일이 있는 글 작성 하기
	int add_withFile(BoardVO boardvo);



}
