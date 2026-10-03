create database school;
use school;

create table students (
student_id int auto_increment primary key,
student_name varchar(50),
gender char(1),
age int, 
city varchar (50),
department varchar(50),
admission_year int
);

Create table instructors(
instructor_id int auto_increment primary key,
instructor_name varchar(50),
department varchar(50),
experience_years int,
salary int
);

alter table instructors modify column salary decimal(10,2);

create table courses (
course_id int auto_increment primary key,
course_name varchar(50),
department varchar(50),
instructor_id int,
credits int
);

alter table courses add primary key (course_id);

create table enrollments (
enrollment_id int primary key,
student_id int,
course_id int,
semester varchar(20),
year int,		
  foreign key (student_id) references students(student_id), 
  foreign key (course_id) references courses(course_id)
);

Create table exams (
exam_id int auto_increment primary key,
student_id int,
course_id int,
score int,
grade Varchar(2)
);

alter table exams add constraint chk_score check (score between 0 and 100);

create index idx_enrollments_student on enrollments(student_id);
create index idx_exams_student_course on exams(student_id, course_id);

create table attendance (
attendance_id int primary key auto_increment,
student_id int,
course_id int,
attendance_date date,
status enum ('present', 'absent', 'excused'),
   foreign key (student_id) references students (student_id),
   foreign key (course_id) references courses (course_id)
);

create table payments (
payment_id int primary key  auto_increment,
student_id int,
amount_paid int,
payment_date date,
payment_method varchar (20),
    foreign key (student_id) references students (student_id)
);

alter table payments modify column amount_paid decimal(10,2);

insert into attendance (student_id, course_id, attendance_date, status) values
(1, 1, '2026-05-01', 'Present'),
(1, 2, '2026-05-01', 'Present'),
(2, 1, '2026-05-01', 'Absent'),
(3, 3, '2026-05-02', 'Present'),
(4, 4, '2026-05-02', 'Present'),
(5, 3, '2026-05-02', 'Excused');

insert into payments (student_id, amount_paid, payment_date, payment_method) values
(1, 15000.00, '2026-04-10', 'HDFC Debit Card'),
(2, 15000.00, '2026-04-11', 'UPI'),
(3, 12000.00, '2026-04-12', 'Cash'),
(4, 15000.00, '2026-04-15', 'Credit Card');

insert into students values
(1,'Arjun','M',20,'Bangalore','Computer Science',2022),
(2,'Meera','F',21,'Mumbai','Computer Science',2021),
(3,'Ravi','M',22,'Hyderabad','Mechanical',2021),
(4,'Sneha','F',20,'Chennai','Electrical',2022),
(5,'Vikram','M',23,'Pune','Mechanical',2020),
(6,'Priya','F',21,'Bangalore','Computer Science',2022),
(7,'Rohit','M',22,'Delhi','Electrical',2021),
(8,'Neha','F',20,'Mumbai','Civil',2023),
(9,'Kiran','M',24,'Hyderabad','Civil',2020),
(10,'Anjali','F',21,'Chennai','Computer Science',2021);

insert into instructors values
(1,'Dr Sharma','Computer Science',15,120000),
(2,'Dr Iyer','Electrical',12,110000),
(3,'Dr Gupta','Mechanical',10,100000),
(4,'Dr Nair','Civil',8,90000),
(5,'Dr Kapoor','Computer Science',20,150000);

insert into courses values
(1,'Data Structures','Computer Science',1,4),
(2,'Machine Learning','Computer Science',5,4),
(3,'Thermodynamics','Mechanical',3,3),
(4,'Circuit Analysis','Electrical',2,3),
(5,'Structural Design','Civil',4,3),
(6,'Database Systems','Computer Science',1,4);

insert into enrollments values
(1,1,1,'Fall',2023),
(2,1,2,'Fall',2023),
(3,2,1,'Spring',2023),
(4,3,3,'Fall',2023),
(5,4,4,'Fall',2023),
(6,5,3,'Spring',2023),
(7,6,2,'Fall',2023),
(8,7,4,'Spring',2023),
(9,8,5,'Fall',2023),
(10,9,5,'Spring',2023),
(11,10,6,'Fall',2023);

insert into exams values
(1,1,1,88,'A'),
(2,1,2,91,'A'),
(3,2,1,76,'B'),
(4,3,3,69,'C'),
(5,4,4,82,'B'),
(6,5,3,73,'B'),
(7,6,2,95,'A'),
(8,7,4,67,'C'),
(9,8,5,79,'B'),
(10,9,5,85,'A'),
(11,10,6,90,'A');

-- Query Name: Departmental Cost Efficiency Report
-- Description: Analyzes the 'Cost per Credit' to identify which departments
-- are most expensive relative to their teaching output.

select i.department,
sum(i.salary) as total_dep_cost,
sum(c.credits) as total_credits_offered,
round (sum(i.salary) / sum(c.credits), 2) as cost_per_credit
from instructors i
join courses c on i.instructor_id = c.instructor_id
group by i.department;

-- Query Name: High Performance Payment_Mismatch
-- Objective: Identify students with high scores but low fee payments.

select s.student_name, e.score, p.amount_paid,
case 
when p.amount_paid < 15000 then 'Pending Balance'
else 'Fully Paid'
end as payment_status
  from students s
  join exams e on s.student_id = e.student_id
  join payments p on s.student_id = p.student_id
  where e.score > 85;

-- Query Name: Attendance Impact Analysis
-- Objective: Compare average scores between 'Present' and 'Absent' students.

select a.status as attendance_status,
    round(avg(e.score), 2) as average_score,
    count(s.student_id) as student_count
from attendance a
join exams e on a.student_id = e.student_id and a.course_id = e.course_id
join students s on s.student_id = a.student_id
group by a.status;

-- Department wise average score
select 
  c.department,
  round(avg(e.score), 2) as avg_score
from exams e
join courses c on e.course_id = c.course_id
group by c.department;

-- Students with at least one “A”
select distinct s.student_id, s.student_name
from students s
join exams e on s.student_id = e.student_id
where e.grade = 'A';

-- CORRELATED SUBQUERIES
-- 	1.	Find students who scored above class average in every course they took.
select student_id, student_name
from students
where student_id in
(select e1.student_id from exams e1 group by e1.student_id 
having sum(case when e1.score >
(select avg(e2.score)
from exams e2
where e2.course_id = e1.course_id )
then 1 else 0 end) = Count(e1.course_id)
);

-- COMPLEX JOINS
-- 	2.	Find students with highest score in each course.
select s.student_id, s.student_name, e1.course_id, e1.score
from students s
join exams e1 on s.student_id = e1.student_id
join 
   (select course_id, max(score) as max_score
   from exams
   group by course_id )
   top_scores
   on e1.course_id = top_scores.course_id 
   and e1.score = top_scores.max_score;

-- ACADEMIC PERFORMANCE ANALYTICS
-- 	1.	Find students who scored more than 90.
select s.student_id, e.score
from students s
join exams e on s.student_id = e.student_id
where e.score > 90;

-- 	2.	Find students who scored between 80 and 95.
select distinct s.student_id, s.student_name
from students s
join exams e on s.student_id = e.student_id
where e.score between 80 and 95;

-- 	3.	Find students who scored highest marks in any course.
select distinct s.student_id, s.student_name
from students s
join exams e1 on s.student_id = e1.student_id
join 
   (select course_id, max(score) max_score
   from exams 
   group by course_id )
   e2 on e1.course_id = e2.course_id 
   and e1.score = e2.max_score;

-- OPERATIONAL RISK & ENROLLMENT TRENDS
-- 	1.	Find students who never enrolled in any course.
select s.student_id, s.student_name
from students s
left join enrollments e on s.student_id = e.student_id
where e.student_id is null;

-- 2. Find students who took Computer Science courses but not Mechanical courses.
select student_id, student_name
from students
where student_id in (
    select e.student_id
    from enrollments e
    join courses c on e.course_id = c.course_id
    where c.department = 'Computer Science'
)
and student_id not in (
    select e.student_id
    from enrollments e
    join courses c on e.course_id = c.course_id
    where c.department = 'Mechanical'
);

-- 	3.	Find students who never took Computer Science courses.
select student_id, student_name
from students
where student_id not in (
  select distinct s.student_id
  from students s
  join enrollments e on s.student_id = e.student_id
  join courses c on e.course_id = c.course_id
  where c.department = 'Computer Science'
);

-- FACULTY COMPENSATION & HR INSIGHTS
-- 	1.	Find courses taught by instructors with salary > 120000.
select c.course_name, i.instructor_id
  from courses c
  join instructors i on c.instructor_id = i.instructor_id
  where salary > 120000;

-- 	2.	Find instructors whose salary is greater than instructors in Civil department.
select i.instructor_id, i.instructor_name, i.salary, i.department
from instructors i
join 
   (select max(salary) civil_max 
   from instructors 
   where department = 'Civil' )
   benchmark on i.salary > benchmark.civil_max;

--  3. Find the names of instructors who earn the highest salary in each department.
select i.instructor_name, i.salary, i.department
from instructors i
join 
   (select department, max(salary) as max_sal
   from instructors
   group by department ) as dept_max
   on i.department = dept_max.department
   and i.salary = dept_max.max_sal
