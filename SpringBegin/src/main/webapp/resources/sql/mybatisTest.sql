show user;

---- ==== *** Spring myBatisTest *** ==== ----

create table spring_mybatistest
(no         number
,name       varchar2(20)
,email      varchar2(30)
,tel        varchar2(20)
,addr       varchar2(200)
,writeday   date default sysdate
,constraint PK_spring_mybatistest_no primary key(no)
);

create sequence seq_mybatistest
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;


select *
from spring_mybatistest
order by no desc;

/*
insert into spring_mybatistest(no, name, email, tel, addr, writeday)
values(seq_mybatistest.nextval, '홍길동'||seq_mybatistest.nextval, 'hongkd@gmail.com', '010-234-5678', '서울시 종로구 인사동', default);
*/

select no, name, email, tel, addr, to_char(writeday, 'yyyy-mm-dd hh24:mi:ss') as writeday
from spring_mybatistest
where no = 1;


-- [181214]
-- /mybatistest/mybatisTest10.action
alter table spring_mybatistest add birthday varchar2(20);

commit;

select no, name, email, tel, addr, to_char(writeday, 'yyyy-mm-dd hh24:mi:ss') as writeday, birthday
from spring_mybatistest
where no = 1;

insert into spring_mybatistest(no, name, email, tel, addr, writeday, birthday)
values(seq_mybatistest.nextval, '박보검'||seq_mybatistest.nextval, 'parkbogum@gmail.com', '010-234-5678', '경기도 과천시 부촌동', default, '1992-01-01');

commit;

update spring_mybatistest set birthday = '1993-02-22' where no != 9;


-- [181219] hr 계정의 테이블을 이용하기

select *
from hr.employees;

select *
from hr.departments;

-- 성별을 알려주는 함수
create or replace function func_gender(p_jubun IN varchar2  )
return varchar2
is
    v_gender varchar2(10) ; --자릿수 써도 괜찮음
begin
    if substr(p_jubun, 7, 1) in ('1' , '3') 
        THEN v_gender :='남' ;
    elsif substr(p_jubun, 7, 1) in ('2' , '4')  then v_gender :='여';
    else v_gender:='오류';
    end if;
    return v_gender;
end func_gender;

select func_gender('9012233548214')
from dual;

--주민등록번호 또는 생년월일을 받아서 나이를 구하는 함수
create or replace function func_age(p_jubun IN varchar2  )
return number
is
    v_age number(10); 
begin
    v_age := extract(year from sysdate) - (to_number(substr(p_jubun, 1, 2))+case when substr(p_jubun, 7,1) in ('1','2') then 1900 else 2000 end) + 1;
    return v_age;
end func_age;

select func_age('9302312013014')
from dual;

-- 강사님이 하신 것
create or replace function func_age2(p_jubun IN varchar2  )
return number
is
    v_birthyear number(4);
begin
   if ( substr(p_jubun, 7, 1) in ('1', '2'))
        then  v_birthyear:= to_number(substr(p_jubun, 1, 2))+1900;
   else  v_birthyear:= to_number(substr(p_jubun, 1, 2))+2000;
   end if;
   return extract(year from sysdate) - v_birthyear + 1;
end func_age2;

select func_age2('8702222013044')
from dual;

-- 사원번호를 받아 연봉을 계산하는 함수
create or replace function func_yearpay(p_employee_id in  hr.employees.employee_id%type)
return number
is
    v_yearpay number;
begin
        select nvl(salary+(salary*commission_pct),salary)*12 into v_yearpay
        from hr.employees
        where employee_id = p_employee_id;
    return v_yearpay;
end;

select func_yearpay(162)
from dual;

-- 문자열 타입으로 연봉 리턴
create or replace function func_yearpay_char(p_employee_id in  hr.employees.employee_id%type)
return varchar2
is
    v_yearpay varchar2(300);
begin
        select to_char(nvl(salary+(salary*commission_pct),salary)*12, '$999,999') into v_yearpay
        from hr.employees
        where employee_id = p_employee_id;
    return v_yearpay;
end;

select func_yearpay_char(162)
from dual;

-- 부서번호/부서명/사원번호/사원명/주민번호/성별/나이/연봉
select   nvl(a.department_id, 0) as department_id
            , nvl(b.department_name, '소속없음') as department_name
            , employee_id
            ,  first_name || ' ' || last_name as name
            , jubun
            , func_gender(jubun) as gende
            , func_age(jubun) as age
            , func_yearpay(employee_id) as yearpay
from hr.employees a left join hr.departments b
on a.department_id = b.department_id;

-- 부서번호 리스트 가져오기(중복제거)
select distinct nvl(department_id, -1) as department_id
		from hr.employees
        order by department_id asc;


select department_id, department_name, employee_id, name, jubun, gender, age, yearpay
from
(
select   nvl(a.department_id, -1) as department_id
            , nvl(b.department_name, '소속없음') as department_name
            , employee_id
            ,  first_name || ' ' || last_name as name
            , jubun
            , func_gender(jubun) as gender
            , func_age(jubun) as age
            , func_yearpay(employee_id) as yearpay
from hr.employees a left join hr.departments b
on a.department_id = b.department_id
)
where gender like '%'||'여'||'%'
and department_id = 13;


-- [181220] 
-- #차트 만들기

-- 1) 성별 차트
select func_gender(jubun) as gender 
          , count(*) as cnt
          , round(( count(*) /(select count(*) from hr.employees) )*100, 1) as avg
from HR.employees
group by func_gender(jubun)
order by 1;

-- 2) 연령대 차트
select decode( trunc(func_age(jubun), -1), 0, '10대 미만', trunc(func_age(jubun), -1)||'대') as ageline
          , count(*) as cnt
          , round((count(*) / (select count(*) from hr.employees))*100, 1) as avg
from HR.employees
group by trunc(func_age(jubun), -1)
order by trunc(func_age(jubun), -1);

-- 3) 부서번호별 차트
select nvl(e.department_id,-1) as deptno
        , nvl(department_name, '소속없음') as deptname
        , count(*) as cnt
        , round((count(*) / (select count(*) from hr.employees))*100, 1) as avg
        , round(avg(nvl(salary+salary*commission_pct, salary)*12)) as avgdept
from HR.employees e left join hr.departments d
on e.department_id = d.department_id
group by nvl(e.department_id,-1), nvl(department_name, '소속없음')
order by 1;



-- [190116]
---------------------------------------------------------------------------
    ----- ***** Mybatis 에서 프로시저 호출해서 사용하기 ***** -------
---------------------------------------------------------------------------
-- 1) insert procedure
select no ,name, email ,tel, addr, writeday, birthday
from spring_mybatistest
order by no desc;

desc spring_mybatistest;


create or replace procedure pcd_spring_mybatistest_insert
(p_name     IN  spring_mybatistest.name%type
,p_email    IN  spring_mybatistest.email%type
,p_tel      IN  spring_mybatistest.tel%type
,p_addr     IN  spring_mybatistest.addr%type
)
is
begin
      insert into spring_mybatistest(no, name, email, tel, addr) 
      values(seq_mybatistest.nextval, p_name, p_email, p_tel, p_addr);
end pcd_spring_mybatistest_insert;



-- 2) select procedure
-- 사원 번호를 받아서 사원정보 출력하기
select E.employee_id , E.first_name || ' ' || E.last_name as ENAME,
        case when substr(E.jubun, 7, 1) in ('1','3') then '남' else '여' end as GENDER , 
        extract(year from sysdate) - ( to_number(substr(E.jubun, 1, 2)) + 
                                       case when substr(E.jubun, 7, 1) in('1','2') then 1900 else 2000 end
                                      ) as AGE,
        D.department_name , E.job_id,
        ltrim( to_char( nvl(E.salary + (E.salary * E.commission_pct), E.salary)*12, '999,999,999') ) ||'원' as YEARSAL
from hr.employees E left join hr.departments D
on E.department_id = D.department_id
where E.employee_id = 101;

-- in모드는 입력값, out모드는 프로시저를 통해 도출되는 출력값
create or replace procedure pcd_employees_select
( p_employee_id       IN      hr.employees.employee_id%type  -- p_employee_id   IN   VARCHAR2    <===  이렇게 해도 나온다.
 ,cur_employee_info   OUT     SYS_REFCURSOR)
is
begin
  OPEN cur_employee_info FOR 
  select E.employee_id , E.first_name || ' ' || E.last_name as ENAME,
            case when substr(E.jubun, 7, 1) in ('1','3') then '남' else '여' end as GENDER , 
            extract(year from sysdate) - ( to_number(substr(E.jubun, 1, 2)) + 
                                           case when substr(E.jubun, 7, 1) in('1','2') then 1900 else 2000 end
                                          ) as AGE,
            D.department_name , E.job_id,
            ltrim( to_char( nvl(E.salary + (E.salary * E.commission_pct), E.salary)*12, '999,999,999') ) ||'원' as YEARSAL
  from hr.employees E left join hr.departments D
  on E.department_id = D.department_id
  where E.employee_id = p_employee_id;
end pcd_employees_select;

-- 3) 부서번호를 받아서 여러 사원 출력하기3
create or replace procedure pcd_employees_select2
( p_department_id       IN      hr.employees.department_id%type 
 ,cur_employee_info     OUT     SYS_REFCURSOR)
is
begin
  OPEN cur_employee_info FOR 
  select E.employee_id , E.first_name || ' ' || E.last_name as ENAME,
            case when substr(E.jubun, 7, 1) in ('1','3') then '남' else '여' end as GENDER , 
            extract(year from sysdate) - ( to_number(substr(E.jubun, 1, 2)) + 
                                           case when substr(E.jubun, 7, 1) in('1','2') then 1900 else 2000 end
                                          ) as AGE,
            D.department_name , E.job_id,
            ltrim( to_char( nvl(E.salary + (E.salary * E.commission_pct), E.salary)*12, '999,999,999') ) ||'원' as YEARSAL
  from hr.employees E left join hr.departments D
  on E.department_id = D.department_id
  where E.department_id = p_department_id
  order by employee_id asc;
end pcd_employees_select2;