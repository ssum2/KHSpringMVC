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
