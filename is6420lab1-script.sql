drop table if exists employee
;
create table employee(
first_name VARCHAR (15) not null,
middle_initial CHAR (1),
last_name VARCHAR (15) not null,
SSN CHAR (9) not null,
DOB DATE,
address VARCHAR (30),
gender CHAR (1),
salary MONEY,
SSN_supervisor CHAR (9),
department_id smallint not null,
primary key (SSN))
;
alter table employee alter column SSN type INTEGER using (SSN::INTEGER)
;
alter table employee alter column SSN type CHAR(9)
;
insert into employee values ('Doug', 'E', 'Gilbert', 123456780, '1960-06-09', '300 South 200 West', 'M', 81200.05, null, 1)
;
insert into employee values ('Amy', 'C', 'Elyot', 123456789, '1973-03-26', '100 Main St.', 'F', 80000.00, NULL, 1)
;
INSERT INTO employee (first_name, last_name, SSN, SSN_supervisor, department_id) values ('Richard', 'Smith', 987654321, 123456789, 1)
;
insert into employee (first_name, last_name, SSN, department_id) values ('George', 'Haman', 123456783, 2)
;
select *
from employee;


drop table if exists department
;
create table department(
department_name VARCHAR (30) not null,
department_id SMALLINT not null,
SSN_manager CHAR (9),
manager_start_date DATE,
primary key (department_id))
;
INSERT INTO department VALUES ('R and D', 1, 123456789, '2014-07-14')
;
INSERT INTO department VALUES ('Finance', 2, 123456783, '2016-02-07')
;
INSERT INTO department (department_id, department_name, SSN_manager, manager_start_date) VALUES (3, 'Marketing', 123456788, '2012-04-21')
;
INSERT INTO department (department_id, department_name) VALUES (4, 'Human Resources')
;
select *
from department
;

alter table employee rename column SSN_supervisor to SSN_manager
;

select employee.first_name, employee.last_name, department.department_name
from employee
inner join department on employee.SSN_manager=department.SSN_manager
;
