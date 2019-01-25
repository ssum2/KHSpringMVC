-- [ board 게시판 ] 

-- #게시판 이미지 테이블 만들기
create table tilestest_img_advertise
(imgno          number not null
,imgfilename    varchar2(100) not null
,constraint PK_tilestest_img_advertise primary key(imgno)
);

create sequence seq_img_advertise
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

insert into tilestest_img_advertise values(seq_img_advertise.nextval, '미샤.png');
insert into tilestest_img_advertise values(seq_img_advertise.nextval, '원더플레이스.png');
insert into tilestest_img_advertise values(seq_img_advertise.nextval, '레노보.png');
insert into tilestest_img_advertise values(seq_img_advertise.nextval, '동원.png');
commit;

select imgfilename
from tilestest_img_advertise
order by imgno desc;

select IDX ,USERID ,NAME ,PWD ,EMAIL ,HP1 ,HP2 ,HP3 ,POST1 ,POST2 ,ADDR1 ,ADDR2 ,GENDER ,
BIRTHDAY ,COIN ,POINT ,REGISTERDAY ,STATUS ,LASTLOGINDATE ,LASTPWDCHANGEDATE, gradelevel 
from jsp_member
order by idx desc;

-- 로그인한 회원에게 등급레벨에 따라 접근권한 차등 부여하기
alter table jsp_member add gradelevel number(2) default 1;
commit;

update jsp_member set gradelevel=10 where userid in ('admin', 'ssum');

commit;

select *
from jsp_member
order by gradelevel desc, idx asc;


select idx, userid, name, email, gradelevel
        ,trunc(MONTHS_BETWEEN(sysdate, lastlogindate)) as lastlogindategap
        ,trunc(MONTHS_BETWEEN(sysdate, lastpwdchangedate)) as pwdchangegap
from jsp_member
where status=1 and userid='leess' and pwd='9695b88a59a1610320897fa84cb7e144cc51f2984520efb77111d94b402a8382';

update jsp_member set lastpwdchangedate=add_months(sysdate, -7), lastlogindate=add_months(sysdate, -7) where userid='leess';
commit;

select *
from jsp_member
order by gradelevel desc, idx asc;

-- [181231]

create table tblBoard
(seq            number                not null   -- 글번호
,fk_userid      varchar2(20)          not null   -- 사용자ID
,name           Nvarchar2(20)         not null   -- 글쓴이
,subject        Nvarchar2(200)        not null   -- 글제목
,content        Nvarchar2(2000)       not null   -- 글내용    -- clob
,pw             varchar2(20)          not null   -- 글암호
,readCount      number default 0      not null   -- 글조회수
,regDate        date default sysdate  not null   -- 글쓴시간
,status         number(1) default 1   not null   -- 글삭제여부  1:사용가능한글,  0:삭제된글 
,constraint  PK_tblBoard_seq primary key(seq)
,constraint  FK_tblBoard_userid foreign key(fk_userid) references jsp_member(userid)
,constraint  CK_tblBoard_status check( status in(0,1) )
);

create sequence boardSeq
start with 1
increment by 1
nomaxvalue 
nominvalue
nocycle
nocache;

-- insert 쿼리문
insert into tblBoard(seq, fk_userid, name, subject, content, pw, readCount, regDate, status) 
values(boardSeq.nextval, #{fk_userid}, #{name}, #{subject}, #{content}, #{pw},  default, default, default);

select seq, fk_userid, name, subject, content, pw, readCount, regDate, status
from tblBoard
order by seq desc;

select seq, fk_userid, name, subject, content, pw, readCount, to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regdate
from tblBoard
where status = 1
order by seq desc;

-- 글 상세 조회; 이전글 다음글 정보까지 가져오기
select previousSeq, priviousSubject, seq, fk_userid, name, subject, readCount, regdate, nextSeq, nextSubject
from
(
select lag(seq, 1) over(order by seq desc) as previousSeq
        , lag(subject, 1) over(order by seq desc) as priviousSubject
        , seq, fk_userid, name, subject, readCount, to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regdate
        , lead(seq, 1) over(order by seq desc) as nextSeq
        , lead(subject, 1) over(order by seq desc) as nextSubject
from tblBoard
where status = 1
) V
where V.seq = #{seq}


-- [190102]
------------------------------------------------------------------------
----- **** 댓글 테이블 생성 **** -----  
create table tblComment
(seq           number               not null   -- 댓글번호
,fk_userid     varchar2(20)         not null   -- 사용자ID
,name          varchar2(20)         not null   -- 성명
,content       varchar2(1000)       not null   -- 댓글내용
,regDate       date default sysdate not null   -- 작성일자
,parentSeq     number               not null   -- 원게시물 글번호
,status        number(1) default 1  not null   -- 글삭제여부
                                               -- 1 : 사용가능한 글,  0 : 삭제된 글
                                               -- 댓글은 원글이 삭제되면 자동적으로 삭제되어야 한다.
,constraint PK_tblComment_seq primary key(seq)
,constraint FK_tblComment_userid foreign key(fk_userid)
                                    references jsp_member(userid)
,constraint FK_tblComment_parentSeq foreign key(parentSeq) 
                                      references tblBoard(seq) on delete cascade
,constraint CK_tblComment_status check( status in(1,0) ) 
);

create sequence commentSeq
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

/*
 댓글쓰기(tblComment 테이블)를 성공하면 원게시물(tblBoard 테이블)에
 댓글의 갯수(1씩 증가)를 알려주는 컬럼 commentCount 을 추가하겠다.
*/
alter table tblBoard
add commentCount number default 0 not null;

select *
from tblBoard
order by seq desc;


select seq, fk_userid, name, content, regDate, parentSeq, status
from tblComment
order by seq desc;

update tblBoard set commentCount = 8 where seq = 8;
update tblBoard set commentCount = 1 where seq = 7;
update tblBoard set commentCount = 1 where seq = 2;

commit;
-- insert 구문           
insert into tblComment(seq, fk_userid, name, content, regDate, parentSeq, status) 
values(commentSeq.nextval, #{fk_userid}, #{name}, #{content}, default, #{parentSeq}, default);


-- [190103]
-- #페이징처리를 위한 댓글 데이터 인서트하기
begin
    for i in 1..100 loop
        insert into tblComment(seq, fk_userid, name, content, regDate, parentSeq, status)
        values(commentSeq.nextval, 'ssum', '배수미', i||'번 댓글', sysdate, 7, default);
    end loop;
end;

commit;


update tblBoard set commentCount = commentCount+100 where seq=7;
commit;


-- #페이징처리한 댓글목록 쿼리
select rno, seq, parentseq, fk_userid, name, content, regdate
from 
(
    select  rownum as rno, seq, parentseq, fk_userid,  name, content, regdate
    from 
    (
        select seq, parentseq, fk_userid, name, content, to_char(regdate, 'yyyy-mm-dd hh24:mi:ss') as regdate
        from tblComment
        where parentseq = 7
        order by seq desc
    ) V
)T
where rno between 11 and 15;


select count(*)
from tblComment
where parentSeq=7;

delete from tblBoard where seq =7;

select *
from tblBoard;

select *
from tblComment;

rollback;


select seq, name, subject, readCount, to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate, commentCount
from tblBoard
where status = 1 and subject like '%'||'입니다'||'%'
order by seq desc;


-- [190104]
-- #페이징처리를 위한 tblBoard 테이블에 데이터 인서트
begin
    for i in 1..100 loop
        insert into tblBoard(seq, fk_userid, name, subject, content, pw, readCount, regDate, status) 
        values(boardSeq.nextval, 'ssum', '배수미', '나의'||i||'번째 글', i||'번글 내용입니다', '1234',  default, default, default);
    end loop;
end;

begin
    for i in 1..100 loop
        insert into tblBoard(seq, fk_userid, name, subject, content, pw, readCount, regDate, status) 
        values(boardSeq.nextval, 'chaew1', '차은우1', '은우의'||i||'번째 글', i||'번글 내용입니다', '1234',  default, default, default);
    end loop;
end;

commit;

select *
from jsp_member
order by idx desc;

select seq, name, subject, readCount,  regDate, commentCount
from
(
select rownum as rno, seq, name, subject, readCount,  regDate, commentCount
from
    (
    select seq, name, subject, readCount, to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate, commentCount
    from tblBoard
    where status = 1 and name like '%'||'차'||'%'
    order by seq desc
    ) V
)T
where rno between 1 and 10
order by rno asc;


-----------------------------------------------------------
         ---- *** 답변형 게시판 *** ----
-----------------------------------------------------------
-- #답변형 게시판을 위한 백업 및 기존 테이블 삭제
create table tblComment_backup
as
select *
from tblComment
order by seq asc;

create table tblBoard_backup
as
select *
from tblBoard
order by seq asc;

drop table tblComment purge;
drop table tblBoard purge;

-- #재생성
create table tblBoard
(seq           number                not null   -- 글번호
,fk_userid     varchar2(20)          not null   -- 사용자ID
,name          Nvarchar2(20)         not null   -- 글쓴이
,subject       Nvarchar2(200)        not null   -- 글제목
,content       Nvarchar2(2000)       not null   -- 글내용    -- clob
,pw            varchar2(20)          not null   -- 글암호
,readCount     number default 0      not null   -- 글조회수
,regDate       date default sysdate  not null   -- 글쓴시간
,status        number(1) default 1   not null   -- 글삭제여부  1:사용가능한글,  0:삭제된글 
,commentCount  number default 0      not null   -- 댓글수
,groupno       number                not null   -- 답변글쓰기에 있어서 그룹번호
                                                -- 원글(부모글)과 답변글은 동일한 groupno 를 가진다. 
                                                -- 답변글이 아닌 원글(부모글)인 경우 groupno 의 값은 groupno 컬럼의 최대값(max)+1 로 한다.  
                                                
,fk_seq        number default 0      not null   -- fk_seq 컬럼은 절대로 foreign key가 아니다.
                                                -- fk_seq 컬럼은 자신의 글(답변글)에 있어서 
                                                -- 원글(부모글)이 누구인지에 대한 정보값이다.
                                                -- 답변글쓰기에 있어서 답변글이라면 fk_seq 컬럼의 값은 
                                                -- 원글(부모글)의 seq 컬럼의 값을 가지게 되며,
                                                -- 답변글이 아닌 원글일 경우 0 을 가지도록 한다.
                                                
,depthno       number default 0       not null  -- 답변글쓰기에 있어서 답변글 이라면                                                
                                                -- 원글(부모글)의 depthno + 1 을 가지게 되며,
                                                -- 답변글이 아닌 원글일 경우 0 을 가지도록 한다.
,constraint  PK_tblBoard_seq primary key(seq)
,constraint  FK_tblBoard_userid foreign key(fk_userid) references jsp_member(userid)
,constraint  CK_tblBoard_status check( status in(0,1) )
);

drop sequence boardSeq;

create sequence boardSeq
start with 1
increment by 1
nomaxvalue 
nominvalue
nocycle
nocache;


create table tblComment
(seq         number                not null   -- 댓글번호
,fk_userid   varchar2(20)          not null   -- 사용자ID
,name        varchar2(20)          not null   -- 성명
,content     varchar2(1000)        not null   -- 댓글내용
,regDate     date default sysdate  not null   -- 작성일자
,parentSeq   number                not null   -- 원게시물 글번호
,status      number(1) default 1   not null   -- 글삭제여부
                                              -- 1 : 사용가능한 글,  0 : 삭제된 글
                                              -- 댓글은 원글이 삭제되면 자동적으로 삭제되어야 한다.
,constraint PK_tblComment_seq primary key(seq)
,constraint FK_tblComment_userid foreign key(fk_userid)
                                    references jsp_member(userid)
,constraint FK_tblComment_parentSeq foreign key(parentSeq) 
                                      references tblBoard(seq) on delete cascade
,constraint CK_tblComment_status check( status in(1,0) ) 
);

drop sequence commentSeq;

create sequence commentSeq
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

select *
from tblBoard;

insert into tblBoard
select seq, fk_userid, name, subject, content, pw, readcount, regdate, status, commentcount, rownum as groupno, 0, 0
from
(
 select seq, fk_userid, name, subject, content, pw, readcount, regdate, status, commentcount 
 from tblBoard_backup
 order by seq asc
)V;

commit;

select *
from tblBoard
order by seq desc;

insert into tblComment
select *
from tblComment_backup
order by seq asc;

-- #시퀀스 번호 맞춰주기
select max(seq)
from tblBoard; -- 208

select max(seq)
from tblComment;    -- 113


create sequence boardSeq
start with 209
increment by 1
nomaxvalue 
nominvalue
nocycle
nocache;

create sequence commentSeq
start with 114
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

drop table tblComment_backup purge;
drop table tblBoard_backup purge;


select seq, name, subject, readCount, regDate, commentCount, groupno, depthno, fk_seq
		from
		(
		select rownum as rno, seq, name, subject, readCount,  regDate, commentCount, groupno, depthno, fk_seq
		from 
		    (
		    select seq, name, subject, readCount, to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate, commentCount
		    		,groupno, depthno, fk_seq
		    from tblBoard
		    where status = 1
		    <if test="search != '' and search != null and search !='null' ">
			and ${colname} like '%'||#{search}||'%'
			</if>
			start with fk_seq = 0   -- fk_seq를 0부터 시작해서 탐색
           	connect by prior seq = fk_seq   -- 시퀀스 시작값 = 다른행에 있는 fk_seq 연결
           	order siblings by groupno desc, seq asc -- 원글은 groupno를 1씩 증가하여 insert, 답변글은 원글과 동일하게 insert
		    ) V
		)T
		where rno between #{startRno} and #{endRno}
		order by rno asc;


-- [190107]
-- #파일첨부를 위해 tblBoard 테이블에 컬럼 추가
-- 1) WAS에 저장될 파일명(201901070912354846876..png); 현재시간에 나노타임까지 붙음
alter table tblBoard
add filename varchar2(255);

-- 2) 실제 유저가 보는 파일명(실제 파일명); 사용자가 파일을 업로드/다운로드 할 때 사용되는 파일명
alter table tblBoard
add orgFilename varchar2(255);

-- 3) 파일크기; 파일1개당 크기 10MB로 제한
alter table tblBoard
add filesize number;


-- #최종 게시판 테이블
/*
create table tblBoard
(seq           number                not null   -- 글번호
,fk_userid     varchar2(20)          not null   -- 사용자ID
,name          Nvarchar2(20)         not null   -- 글쓴이
,subject       Nvarchar2(200)        not null   -- 글제목
,content       Nvarchar2(2000)       not null   -- 글내용    -- clob
,pw            varchar2(20)          not null   -- 글암호
,readCount     number default 0      not null   -- 글조회수
,regDate       date default sysdate  not null   -- 글쓴시간
,status        number(1) default 1   not null   -- 글삭제여부  1:사용가능한글,  0:삭제된글 
,commentCount  number default 0      not null   -- 댓글수
,groupno       number                not null   -- 답변글쓰기에 있어서 그룹번호
                                                -- 원글(부모글)과 답변글은 동일한 groupno 를 가진다. 
                                                -- 답변글이 아닌 원글(부모글)인 경우 groupno 의 값은 groupno 컬럼의 최대값(max)+1 로 한다.  
                                                
,fk_seq        number default 0      not null   -- fk_seq 컬럼은 절대로 foreign key가 아니다.
                                                -- fk_seq 컬럼은 자신의 글(답변글)에 있어서 
                                                -- 원글(부모글)이 누구인지에 대한 정보값이다.
                                                -- 답변글쓰기에 있어서 답변글이라면 fk_seq 컬럼의 값은 
                                                -- 원글(부모글)의 seq 컬럼의 값을 가지게 되며,
                                                -- 답변글이 아닌 원글일 경우 0 을 가지도록 한다.
                                                
,depthno       number default 0       not null  -- 답변글쓰기에 있어서 답변글 이라면                                                
                                                -- 원글(부모글)의 depthno + 1 을 가지게 되며,
                                                -- 답변글이 아닌 원글일 경우 0 을 가지도록 한다.
,filename         varchar2(255)        -- WAS에 저장될 파일명(201901070912354846876..png); 현재시간에 나노타임까지 붙음
,orgFilename    varchar2(255)        -- 실제 유저가 보는 파일명(실제 파일명); 사용자가 파일을 업로드/다운로드 할 때 사용되는 파일명
,filesize           number               -- 파일크기; 파일1개당 크기 10MB로 제한
,constraint  PK_tblBoard_seq primary key(seq)
,constraint  FK_tblBoard_userid foreign key(fk_userid) references jsp_member(userid)
,constraint  CK_tblBoard_status check( status in(0,1) )
);
*/

select *
from tblBoard
order by seq desc;



-- [190124]
------------------------------------------------------------------------------------------
   ---- **** === 스낵제품 구입에 따른 차트그리기 === **** ----

create table chart_snack
(snackno       number not null          -- 스낵번호(대분류, 시퀀스)
,snackname     varchar2(100) not null   -- 제품명
,constraint PK_chart_snack primary key(snackno)
);

create sequence seq_chart_snack
start with 1000
increment by 1000
nomaxvalue
nominvalue
nocycle
nocache;

insert into chart_snack values(seq_chart_snack.nextval, '감자깡');
insert into chart_snack values(seq_chart_snack.nextval, '새우깡');
insert into chart_snack values(seq_chart_snack.nextval, '양파링');
insert into chart_snack values(seq_chart_snack.nextval, '고구마깡');
insert into chart_snack values(seq_chart_snack.nextval, '빼빼로');
commit;

select *
from chart_snack;


create table chart_snackType         -- 동일한 스낵제품중에서 세분류 되어진 스낵타입 테이블
(typecode    varchar2(50)            -- 타입코드
,typename    varchar2(100)           -- 타입명
,constraint PK_chart_snackType primary key(typecode)
);

insert into chart_snackType values('taste_1', '매운맛');
insert into chart_snackType values('taste_2', '순한맛');
insert into chart_snackType values('taste_3', '달콤맛');
insert into chart_snackType values('taste_4', '고소한맛');
insert into chart_snackType values('taste_5', '순한맛');
insert into chart_snackType values('size_1', '소량');
insert into chart_snackType values('size_2', '중량');
insert into chart_snackType values('size_3', '대량');
insert into chart_snackType values('madein_1', '국산');
insert into chart_snackType values('madein_2', '중국산');
insert into chart_snackType values('makecompany_1', '롯데');
insert into chart_snackType values('makecompany_2', '오리온');
insert into chart_snackType values('makecompany_3', '해태');

commit;

create table chart_snackDetail
(snackDetailno        number        not null          -- 스낵제품 상세번호(소분류, 시퀀스)
,fk_snackno           number        not null          -- 스낵번호(대분류)
,fk_typecode          varchar2(50)  not null          -- 타입코드(중분류)
,constraint PK_chart_snackDetail  primary key(snackDetailno)
,constraint FK_chart_snackDetail_1  foreign key(fk_snackno)
                                       references chart_snack(snackno)
,constraint FK_chart_snackDetail_2  foreign key(fk_typecode)
                                       references chart_snackType(typecode)                                  
);


create sequence seq_chart_snackDetail 
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

insert into chart_snackDetail values(seq_chart_snackDetail.nextval, 1000, 'taste_1');
insert into chart_snackDetail values(seq_chart_snackDetail.nextval, 1000, 'taste_2');
insert into chart_snackDetail values(seq_chart_snackDetail.nextval, 1000, 'taste_3');
insert into chart_snackDetail values(seq_chart_snackDetail.nextval, 2000, 'size_1');
insert into chart_snackDetail values(seq_chart_snackDetail.nextval, 2000, 'size_2');
insert into chart_snackDetail values(seq_chart_snackDetail.nextval, 2000, 'size_3');
insert into chart_snackDetail values(seq_chart_snackDetail.nextval, 3000, 'taste_4');
insert into chart_snackDetail values(seq_chart_snackDetail.nextval, 3000, 'taste_5');
insert into chart_snackDetail values(seq_chart_snackDetail.nextval, 4000, 'madein_1');
insert into chart_snackDetail values(seq_chart_snackDetail.nextval, 4000, 'madein_2');
insert into chart_snackDetail values(seq_chart_snackDetail.nextval, 5000, 'makecompany_1');
insert into chart_snackDetail values(seq_chart_snackDetail.nextval, 5000, 'makecompany_2');
insert into chart_snackDetail values(seq_chart_snackDetail.nextval, 5000, 'makecompany_3');

commit;

select *
from chart_snackDetail;

select snackno, snackname
from chart_snack
where snackno in (select distinct fk_snackno from chart_snackDetail)
order by snackno asc;


select typecode, typename
from chart_snackType
where typecode in(select fk_typecode
                  from chart_snackDetail
                  where fk_snackno = 1000);


create table chart_snackOrder
(orderno     number not null          -- 주문번호(전표, 시퀀스)
,userid      varchar2(20) not null    -- 사용자ID
,orderday    date default sysdate     -- 주문일자
,constraint  PK_chart_snackOrder_orderno primary key(orderno)
,constraint  FK_chart_snackOrder_userid foreign key(userid) 
                                           references jsp_member(userid)
);


create sequence seq_chart_snackOrder
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

/*
insert into chart_snackOrder(orderno, userid, orderday)
values(seq_chart_snackOrder.nextval, 'seoyh', default);
*/

select *
from chart_snackOrder
order by orderno desc;


create table chart_snackOrderDetail 
(orderDetailno      number not null   -- 주문상세번호(시퀀스)
,fk_orderno         number not null   -- 주문번호(전표)
,fk_snackDetailno   number not null   -- 제품상세번호
,oqty               number not null   -- 주문량
,constraint  PK_chart_snackOrderDetail  primary key(orderDetailno)
,constraint  FK_orderDetail_orderno foreign key(fk_orderno)
                                               references chart_snackOrder(orderno)
,constraint  FK_orderDetail_jepumDetailno foreign key(fk_snackDetailno)     
                                               references chart_snackDetail(snackDetailno)
);

create sequence seq_chart_snackOrderDetail
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

/*
insert into chart_snackOrderDetail(orderDetailno, fk_orderno, fk_snackDetailno, oqty)
values(seq_chart_snackOrderDetail.nextval
    , (select max(orderno) from chart_snackOrder where userid = 'seoyh')
    , (select snackDetailno
       from chart_snackDetail
       where fk_snackno = 1000 and fk_typecode = 'taste_1')
    , 3);
*/

select *
from chart_snackOrderDetail 
order by orderDetailno desc;


select rank() over(order by sum(A.oqty) desc) as ranking
     , C.snackname 
     , sum(A.oqty) as totalqty
     , trunc( sum(A.oqty)/(select sum(oqty) from chart_snackOrderDetail) * 100, 1) as percentage
from chart_snackOrderDetail A left join chart_snackDetail B
on A.fk_snackDetailno = B.snackDetailno
left join chart_snack C
on B.fk_snackno = C.snackno
group by C.snackname;


select C.typename as TYPENAME
     , trunc( sum(A.oqty)/( select sum(oqty) 
                            from chart_snackOrderDetail) * 100, 1) as PERCENT
from chart_snackOrderDetail A left join chart_snackDetail B
on A.fk_snackDetailno = B.snackDetailno
left join chart_snackType C
on B.fk_typecode = C.typecode
left join chart_snack D
on B.fk_snackno = D.snackno
where D.snackname = '감자깡'
group by C.typename
order by TYPENAME;

-----------------------------------------------------------------------------------------------
select C.typename as TYPENAME
     , trunc( sum(A.oqty)/( select sum(oqty) 
                            from chart_snackOrderDetail
                            where fk_snackdetailno in (select SD.snackdetailno
                                                       from chart_snack S join chart_snackDetail SD
                                                       on S.snackno = SD.fk_snackno
                                                       where S.snackname = '감자깡') ) * 100, 1) as PERCENT
from chart_snackOrderDetail A left join chart_snackDetail B
on A.fk_snackDetailno = B.snackDetailno
left join chart_snackType C
on B.fk_typecode = C.typecode
left join chart_snack D
on B.fk_snackno = D.snackno
where D.snackname = '감자깡'
group by C.typename
order by TYPENAME;
--------------------------------------------------------------------------------------------


select D.snackname 
     , sum(B.oqty) as totalqty
     , trunc( sum(B.oqty)/(select sum(oqty) from chart_snackOrderDetail) * 100, 1) as percentage
from chart_snackOrder A join chart_snackOrderDetail B 
on A.orderno = B.fk_orderno
join chart_snackDetail C
on B.fk_snackDetailno = C.snackDetailno
left join chart_snack D
on C.fk_snackno = D.snackno
where A.userid = 'seoyh'
group by D.snackname
order by totalqty desc;



select ranking, snackname, typename, totalqty, percentage
from
(
select rank() over(order by sum(A.oqty) desc) as RANKING
     , D.snackname, C.typename, sum(A.oqty) as TOTALQTY
     , trunc( sum(A.oqty)/(select sum(oqty) from chart_snackOrderDetail) * 100, 1) as PERCENTAGE
from chart_snackOrderDetail A left join chart_snackDetail B
on A.fk_snackDetailno = B.snackDetailno
left join chart_snackType C
on B.fk_typecode = C.typecode
left join chart_snack D
on B.fk_snackno = D.snackno
group by D.snackname, C.typename
) V
where V.snackname = '감자깡';





---------------------------------------------------------------------------------------
-- [190125]
-------------------------------------------------------------------
   ----- *** 다중파일 첨부(업로드) 제품등록/제품입고 하기 *** -----
-------------------------------------------------------------------
create table spring_product_category
(catecodeseq    number(8)     not null  -- 카테고리 코드 일련번호
,catecode       varchar2(20)  not null  -- 카테고리 코드
,catename       varchar2(100) not null  -- 카테고리명
,constraint PK_spring_product_category primary key(catecodeseq)
,constraint UQ_spring_product_category unique(catecode)
);

create sequence seq_spring_product_category
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

insert into spring_product_category values(seq_spring_product_category.nextval, '10000000', '전자제품');
insert into spring_product_category values(seq_spring_product_category.nextval, '20000000', '의류');
insert into spring_product_category values(seq_spring_product_category.nextval, '30000000', '도서');
insert into spring_product_category values(seq_spring_product_category.nextval, '40000000', '자동차');

commit;

select *
from spring_product_category;


create table spring_product_spec
(specseq    number(8)     not null  -- 제품스펙 일련번호
,speccode   varchar2(20)  not null  -- 카테고리 코드
,specname   varchar2(100) not null  -- 카테고리명
,constraint PK_spring_product_spec primary key(specseq)
,constraint UQ_spring_product_spec unique(speccode)
);

create sequence seq_spring_product_spec
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

insert into spring_product_spec values(seq_spring_product_spec.nextval, 'HIT','히트상품');
insert into spring_product_spec values(seq_spring_product_spec.nextval, 'BEST','베스트상품');
insert into spring_product_spec values(seq_spring_product_spec.nextval, 'NEW','신상품');

commit;

select specseq, speccode, specname
from spring_product_spec;


------- ====== 제품 테이블 : spring_product ====== -------
create table spring_product
(prodseq        number        not null   -- 제품일련번호(Primary Key)
,prodname       varchar2(100) not null   -- 제품명
,fk_catecode    varchar2(20)             -- 카테고리 코드(Foreign Key)
,prodcompany    varchar2(50)             -- 제조회사명
,prodqty        number        default 0  -- 제품 재고량(주의!!! insert 되어지는 대상이 아니라 제품입고 테이블의 insert 시 update 되어지는 컬럼이며, 동시에 제품판매 테이블의 insert 시 update 되어지는 컬럼이다)
,price          number(10)    default 0  -- 제품 정가
,saleprice      number(10)    default 0  -- 제품 판매가(할인해서 팔 것이므로)
,fk_speccode    varchar2(20)             -- 'HIT', 'BEST', 'NEW' 등의 값을 가짐.
,prodcontent    clob                     -- 제품설명  varchar2는 varchar2(4000) 최대값이므로
                                         --          4000 byte 를 초과하는 경우 clob 를 사용한다.
                                         --          clob 는 최대 4GB 까지 지원한다.
,prodpoint      number(8) default 0      -- 포인트 점수                                         
,constraint  PK_spring_product_prodseq primary key(prodseq)
,constraint  FK_spring_product_fk_catecode foreign key(fk_catecode)
                                           references spring_product_category(catecode)
,constraint FK_spring_product_fk_prodspec foreign key(fk_speccode)
                                           references spring_product_spec(speccode)
);

create sequence seq_spring_product
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

select *
from spring_product;

create table spring_productimage
(prodimageseq         number    not null       -- 제품이미지 일련번호(Primary Key)
,fk_prodseq           number    not null       -- 제품번호(Foreign Key)
,imagefilename        varchar2(255) not null   -- 이미지파일명. WAS에 저장될 파일명(2019012545435345464367524654634.png)
,imageorgFilename     varchar2(255) not null   -- 진짜 이미지파일명(쉐보레우측.png) // 사용자가 파일을 업로드 하거나 파일을 다운로드 할때 사용되어지는 파일명 
,imagefileSize        number                   -- 파일크기
,thumbnailFileName    varchar2(255)            -- WAS에 저장될 썸네일 파일명(2019012513165790354388015717.png). 
                                               -- 썸네일 파일명을 받는 컬럼임. 
,constraint PK_spring_productimage primary key(prodimageseq)
,constraint FK_spring_productimage foreign key(fk_prodseq)
                                   references spring_product(prodseq) on delete cascade 
);

create sequence seq_spring_productimage
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

select *
from spring_productimage;

create table spring_productibgo
(productibgoseq    number  not null       -- 입고일련번호
,prodseq           number  not null       -- 제품일련번호(Foreign Key)
,ibgoqty           number  not null       -- 입고량
,prodinputdate     date default sysdate   -- 제품입고일자
,constraint PK_spring_productibgo primary key(productibgoseq)
,constraint FK_spring_productibgo foreign key(prodseq)
                                  references spring_product(prodseq) 
); 

create sequence seq_spring_productibgo
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

select productibgoseq, prodseq, ibgoqty, prodinputdate
from spring_productibgo
order by productibgoseq desc;


---- 제품목록 조회 ----
select A.catename, B.prodseq, B.prodname, B.prodcompany, B.prodqty, B.price, B.saleprice, B.prodcontent, B.prodpoint, C.specname
from spring_product_category A join spring_product B
on A.catecode = B.fk_catecode
join spring_product_spec C
on B.fk_speccode = C.speccode;


---- *** 뷰 생성하기 *** ----
create or replace view view_spring_productinfo
as
select A.catename, B.prodseq, B.prodname, B.prodcompany, B.prodqty, B.price, B.saleprice, B.prodcontent, B.prodpoint, C.specname
from spring_product_category A join spring_product B
on A.catecode = B.fk_catecode
join spring_product_spec C
on B.fk_speccode = C.speccode;

select *
from view_spring_productinfo;

select catename, prodseq, prodname, prodcompany, prodqty, price, saleprice, prodcontent, prodpoint, specname
from view_spring_productinfo
where prodseq = 2;

select *
from spring_productimage;

select *
from spring_productimage
where prodimageseq in (select min(prodimageseq)
                       from spring_productimage
                       group by fk_prodseq);


select A.prodseq, A.catename, A.prodname, A.prodcompany, A.specname, B.thumbnailfilename
from view_spring_productinfo A left join (select *
                                          from spring_productimage
                                          where prodimageseq in (select min(prodimageseq)
                                                                 from spring_productimage
                                                                 group by fk_prodseq)) B
on A.prodseq = B.fk_prodseq;


select imagefilename, imageorgfilename, imagefilesize, thumbnailfilename
from spring_productimage
where fk_prodseq = 2
order by prodimageseq asc;

