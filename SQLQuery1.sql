CREATE SCHEMA service;

--create tables

--customer

CREATE TABLE service.customer
(cust_id int CONSTRAINT c_pkey PRIMARY KEY,
name varchar(25),
address_line1 varchar(25),
address_line2 varchar(25),
city varchar(20),
pin_code int,
totalrequests int);

--service_status
CREATE TABLE service.service_status
(status_id int CONSTRAINT ss_pkey PRIMARY KEY,
s_desc varchar(25));

--1.employee

CREATE TABLE service.employee
(emp_id int CONSTRAINT e_pkey PRIMARY KEY,
ename varchar(25),
age int,
requestcompleted int,
emp_rating int);

--service_request

CREATE TABLE service.service_request
(service_id int CONSTRAINT sr_pkey PRIMARY KEY,
cust_id int,CONSTRAINT sr_fkey1 FOREIGN KEY(cust_id) REFERENCES service.customer(cust_id),
service_desc varchar(50),
request_open_date date,
status_id int,CONSTRAINT sr_fkey2 FOREIGN KEY(status_id) REFERENCES service.service_status(status_id),
emp_id int,CONSTRAINT sr_fkey3 FOREIGN KEY(emp_id) REFERENCES service.employee(emp_id),
request_close_date date,
charges bigint);

--insert data
--customer
INSERT INTO service.customer VALUES
(01,'manali','waghere colony','pimprigaon','pune',411017,1);
INSERT INTO service.customer VALUES
(02,'monali','waghere colony','pimprigaon','ravet',411018,2),
(03,'mony','waghere colony','pimprigaon','ravet',411018,2),
(04,'sony','waghere colony','pimprigaon','pune',411017,1),
(05,'sonali','waghere colony','pimprigaon','ravet',411018,3);

--service_status
INSERT INTO service.service_status VALUES 
(1,'open'),(2,'in progress'),(3,'closed'),(4,'cancelled');

--employee
INSERT INTO service.employee VALUES
(11,'varun',33,12,1),
(12,'john',45,11,2),
(13,'raj',24,10,1),
(14,'pratik',23,5,2),
(15,'vrushabh',33,12,1);
INSERT INTO service.employee VALUES
(16,'sam',33,12,1);

--service_request

INSERT INTO service.service_request VALUES
(111,01,'urgent completion','2020-09-09',1,11,'2020-10-01',100);

INSERT INTO service.service_request VALUES
(112,02,'need quality work','2020-07-09',2,12,'2020-10-01',50),
(113,03,'proper finish','2020-07-09',3,13,'2020-10-01',550),
(114,04,'not urgent','2020-07-09',4,14,'2020-10-01',1050);

--queries

--2.add col totalrequests(int) to customer
ALTER TABLE service.customer ADD totalrequests int;

--3.create reqcopy similiar as service_request table
SELECT * INTO service.reqcopy FROM service.service_request;

--4.custname ,service desc,charges of req.servered by emp>age 30
SELECT c.name,sr.service_desc,sr.charges 
FROM service.customer c INNER JOIN service.service_request sr 
ON c.cust_id=sr.cust_id
WHERE emp_id IN (SELECT emp_id FROM service.employee WHERE age>30);

--5.custname for whom john(emp) not served req.
SELECT c.name FROM service.customer c
INNER JOIN service.service_request sr																																																				
ON c.cust_id=sr.cust_id
WHERE emp_id NOT IN (SELECT emp_id FROM service.employee WHERE ename='john');

--6.employee name ,total charges of all req. served only closed req.

SELECT ename,SUM(sr.charges)'total charges' FROM service.service_request sr 
inner join service.employee e  ON e.emp_id=sr.emp_id 
INNER JOIN service.service_status ss
ON sr.status_id=ss.status_id
GROUP BY e.ename,s_desc HAVING s_desc='closed';

--7.service desc.,cust name of req. having 3rd high charges
SELECT TOP 1 c.name,sr.service_desc FROM service.service_request sr
INNER JOIN service.customer c 
ON sr.cust_id=c.cust_id 
WHERE charges IN
(SELECT charges FROM service.service_request 
ORDER BY charges desc offset 2 rows);


--8.delete request served by sam 
DELETE FROM service.service_request WHERE emp_id=
(SELECT emp_id FROM service.employee WHERE ename='sam' );


--9.delete cancelled requests from request table
DELETE FROM service.service_request WHERE status_id=
(SELECT status_id FROM service.service_status WHERE s_desc='closed');

--10.update charges of req. raised by customer  sony ,add 10% to charges if <100
UPDATE service.service_request SET charges=charges-(charges*0.1) WHERE charges<100;

--11.update all total_requests of customer table,where total_requests are of total requests of customer
UPDATE service.customer SET totalrequests=(SELECT COUNT(*) FROM service.service_request sr WHERE sr.cust_id=customer.cust_id );

--updated to set o totalrequests in customer
UPDATE service.customer set totalrequests=0;

--12.view (cust name,service desc,ename,service charges,status desc) of not closed req.

CREATE VIEW view1 AS  
SELECT  c.name,e.ename,sr.charges,sr.service_desc,ss.s_desc
FROM service.service_request AS sr 
JOIN service.employee AS  e  
ON sr.emp_id = e.emp_id
JOIN service.customer AS c
ON sr.cust_id=c.cust_id
JOIN service.service_status AS ss
ON sr.status_id=ss.status_id
WHERE not s_desc ='closed'; 

--13.view to show city and total charges in city

CREATE VIEW view2 AS
SELECT c.city,SUM(c.totalrequests) 'totals'
FROM service.customer AS c
GROUP BY city,totalrequests;

select * from view1;
select * from view2;


--14left outer join ex.
SELECT c.name,c.city,sr.service_desc 
from service.customer c 
left outer join service.service_request sr
on c.cust_id=sr.cust_id
order by name;

--15 all emp with same rating as john
SELECT ename FROM service.employee
WHERE emp_rating in(select emp_rating from service.employee where ename='john'); 


select * from service.employee where emp_rating=2;

--rename column name
sp_rename 'TableName.OldColumnName', 'New ColumnName', 'COLUMN';
SP_RENAME  'service.employee.name', 'ename', 'COLUMN';

--select queries
SELECT * FROM service.customer;
SELECT * FROM service.service_request;
SELECT * FROM service.service_status;
SELECT * FROM service.reqcopy;
SELECT * FROM service.employee;


SELECT * FROM service.employee e WHERE EXISTS (SELECT emp_id FROM service.service_request sr WHERE e.emp_id=sr.emp_id);
SELECT * FROM service.employee e WHERE NOT EXISTS (SELECT emp_id FROM service.service_request sr WHERE e.emp_id=sr.emp_id);