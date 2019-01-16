package com.test.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public interface InterMyBatisTestDAO {
	int mbtest1();

	int mbtest2(String name);

	int mbtest3(MyBatisTestVO vo);

	int mbtest4(MemberVO mvo);

	int mbtest5(HashMap<String, String> map);

	String mbtest6(int no);

	MemberVO mbtest7(int no);

	List<MemberVO> mbtest8(String addr);
	
	List<MemberVO2> mbtest9(String addr);
	
	List<MemberVO2> mbtest9_2(String addr);

	List<HashMap<String, String>> mbtest10(String addr);

	List<HashMap<String, String>> mbtest11(HashMap<String, String> paraMap);

	int mbtest11_2(HashMap<String, String> paraMap);

	List<Integer> mbtest12_deptnoList();

	List<HashMap<String, String>> mbtest12_empList(HashMap<String, String> paraMap);

	List<HashMap<String, String>> mbtest13(String addrSearch);

	List<HashMap<String, String>> mbtest14(HashMap<String, Object> paraMap);

	List<HashMap<String, String>> mbtest15_gender();

	List<HashMap<String, String>> mbtest15_ageline();

	List<HashMap<String, String>> mbtest15_deptno();

	void mbtest17(HashMap<String, String> paraMap);

	ArrayList<EmployeeVO> mbtest18(HashMap<String, Object> paraMap);

	ArrayList<EmployeeVO> mbtest19(HashMap<String, Object> paraMap);
	
}
