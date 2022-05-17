--1.Write a plsql trigger on emp table by validating empno, 
--while inserting a record in emp table, if it exist it should not allow u to insert otherwise it should insert.
drop trigger trg_emp_empno ;
/
create or replace trigger trg_emp_empno
before insert on emp
for each row
declare
v_cnt int;
begin
select count(empno) into v_cnt
from emp
where empno = :new.empno;

if v_cnt = 1 then
raise_application_error(-20001,'existed data');
end if;

end;
/
select
* from emp;
/
insert into emp values (7369,'smith','clerk',7902,'17-DEC-18',1200,100,20);
insert into emp values (736,'smith','clerk',7902,'17-DEC-18',1200,100,20);

--2. Write a plsql trigger on emp table so that it should allow to do dml’s 
--only during business hours i.e only between 9 to 6 and only in the weekdays.
/
create or replace trigger trg_emp_weekday
before  insert or update or delete on emp
for each row
begin

if to_char(sysdate,'hh24') not between 9 and 18 and to_char (sysdate,'dy') in('sat','sun')then
raise_application_error(-20001,'existed data');
end if;

end;
/
--3. Write a plsql trigger so that whatever is done on emp like insert, update or delete that should be tracked in audit table.

create or replace trigger trg_emp_audit 
after insert or update or delete on emp
declare 
v_ent varchar2(20);
begin
if inserting then
v_ent := 'insertion';
elsif updating then
v_ent := 'updation';
else
v_ent := 'deletion';
end if ;
insert into cust_audit values (seq_cust_audit.nextval,v_ent,sysdate);
end;
/
insert into emp values (1111,'smith','clerk',7902,'17-DEC-18',1200,100,20);
/
select * from cust_audit;
/
delete from emp where empno = 1111;

--4. Write a plsql trigger on emp table so that inserted date,inserted_by and updated date,updated_by should be 
--automatically inserted whenever a dml is happened on emp table.
--Add inserted_dt, inserted_by, updated_dt and updated_by columns to the existing  emp table using Alter table command.
/
create or replace trigger trg_emp_automatic
before insert or update or delete on emp
for each row
declare

begin
if inserting then
   :new.inserted_by := user;
   :new.inserted_dt := sysdate;
elsif updating then
    :new.updated_by := user;
    :new.updated_dt :=sysdate;
end if;
end;
/
drop trigger trg_emp_deptno;
/
insert into emp values (6666,'smitha','clerk',7902,'17-DEC-18',1200,100,20,'','','','');
select * from emp;
/
alter table emp
add inserted_by varchar2(20);
alter table emp
add inserted_dt date;
alter table emp
add updated_by varchar2(20);
alter table emp
add updated_dt date;
select * from emp;
--5. Write a trigger to insert a record into employee table, 
--before inserting check whether the deptno exists in the dept table or not. 
--If exists the trigger should allow to insert that record in emp table otherwise no.
/
create or replace trigger trg_emp_deptno
before insert on emp
for each row
declare
v_cnt int;
begin
select count(deptno) into v_cnt
from dept 
where deptno = :new.deptno;

if v_cnt = 1 then
raise_application_error(-20001,'existed data');
end if;

end;
/
select
* from emp;
/
select * from dept;
/
insert into emp values (7369,'smith','clerk',7902,'17-DEC-18',1200,100,20);
/
insert into emp values (623,'smitha','clerk',7902,'17-DEC-18',1200,100,20);

--6. Write a  trigger to  update the salary of an employee, 
--the condition is the updated salary should be greater than the old sal. 
--If the updated sal is less compared to the old sal then it should not allow you to update.
select * from employee;
/
create or replace trigger trg_sal_emp
before update on employee
for each row
declare
begin
if :new.emp_sal < :old.emp_sal then
raise_application_error (-20001,'invaled sal');
end if;
end;

/
select * from employee;
/
update employee
set emp_sal = 100
where emp_id =105;
/

--7. Create a complex view by joining emp and dept tables.select empno,ename, dname and deptno in the view. 
--It is illegal to do the operations in the view. 
--So create an instead of trigger so that any DML happens on the View it has to be reflected in both the tables. 
--If I do insert on view, it has to insert both the tables, similarly update and delete also.
/
create view vw_emp_dept
as
select e.empno,e.ename, d.dname , d.deptno
from emp e
join dept d
on e.deptno =d.deptno;
/
insert into vw_emp_dept values (111,'sarik','it',50)
/
create or replace trigger trg_emp_dep
instead of insert on vw_emp_dept
for each row
begin
insert into emp(empno,ename) values (:new.empno,:new.ename);
insert into dept(deptno,dname) values (:new.deptno,:new.dname);

end;
/
select * from emp;
select * from dept;
/
--8.Write a trigger which does not allow update on salary column during first five days of the month.
/
create or replace trigger trg_sal_five_day
before update on employee
for each row
begin 
if to_char(sysdate,'dd')in (1,2,3,4,5) then
raise_application_error (-20001,'invaled date');
end if;
end;

/
update employee
set emp_sal = 100
where emp_id =105;
/
--9.Write a trigger which does not allow the update of salary if the updated salary is more than his respective manager salary.
/
create or replace trigger trg_sal_manager
before update on emp
for each row
declare
v_cnt number;
pragma autonomous_transaction;

begin 
select e2.sal into v_cnt
from emp e1, emp e2
where e1.mgr = e2.empno and e1.empno=:new.empno;
if :new.sal > v_cnt  then
raise_application_error (-20001,'invaled date');
end if;
end;
/
drop trigger trg_sal_manager;
select * from emp;
/
--10.Write  a trigger which will not allow to do an update if the hike is more than 30%. 
/
create or replace trigger trg_hike_30%
before update on employee
for each row
begin 
if :new.emp_sal > :old.emp_sal + (:old.emp_sal*.3) then
raise_application_error(-20001,'invalid hike');
end if;
end;
/
select * from employee;
/
--11. Write a trigger to impose the rule that foreign key should not allow nulls.
/
create or replace trigger trg_null
before insert on emp
for each row
begin 
if :new.deptno is null then
raise_application_error(-20001,'need deptno');
end if;
end
/
insert into emp(empno,ename,job,mgr,hiredate,sal,comm) values (6666,'smitha','clerk',7902,'17-DEC-18',1200,100);


/
select * from emp;
/

--12. What is the data dictionary to find the trigger related information.
/
user_triggers;
/