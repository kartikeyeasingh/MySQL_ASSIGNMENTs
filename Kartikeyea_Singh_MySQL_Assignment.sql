-- Day 3, Ques. 1
use classicmodels;
select customerNumber, customerName, state, creditLimit
from customers
where state is not null and creditLimit between 50000 and 100000
order by creditLimit desc;

-- Day 3, Ques. 2
select distinct productLine
from products
where productLine like '%cars';

-- Day 4, Ques. 1
select orderNumber, status, coalesce(comments,'-')
from orders
where status = 'shipped';

-- Day 4, Ques. 2
select employeeNumber, firstName, jobTitle,
	case
	when jobTitle = 'President' then 'P'
	when jobTitle like 'Sales Manager%' or jobTitle like 'Sale Manager%' then 'SM'
	when jobTitle = 'Sales Rep' then 'SR'
	when jobTitle like '%VP%' then 'VP'
	end as jobTitle_abbr
from employees
order by jobTitle;

-- Day 5, Ques. 1
select year(paymentDate) as Year, min(amount) as 'Min Amount'
from  payments
group by year(paymentDate)
order by Year;

-- Day 5, Ques. 2
select year(orderDate) as Year, 
	case
	when quarter(orderDate) = 1 then 'Q1'
	when quarter(orderDate) = 2 then 'Q2'
	when quarter(orderDate) = 3 then 'Q3'
	when quarter(orderDate) = 4 then 'Q4'
	end as Quarter,
	count(distinct customerNumber) as 'Unique Customers', count(orderNumber) as 'Total Orders'
from orders
group by Year, Quarter
order by Year, Quarter;

-- Day 5, Ques. 3
select date_format(paymentDate, '%b') as Month, concat(round(sum(amount / 1000), 0), 'K') as 'formatted amount'
from payments
group by Month
having sum(amount) between 500000 and 1000000
order by sum(amount) desc;

-- Day 6, Ques. 1
create table journey
	(
	Bus_ID int not null, 
    Bus_Name varchar(255) not null,
    Source_Station varchar(255) not null,
    Destination varchar(255) not null,
    Email varchar(255) unique
    );
desc journey;

-- Day 6, Ques. 2
create table vendor
	(
	Vendor_ID int primary key,
    Name varchar(255) not null,
    Email varchar(255) unique,
    Country varchar(255) default 'N/A'
    );
desc vendor;
    
-- Day 6, Ques. 3
create table movies
	(
	Movie_ID int primary key,
    Name varchar(255) not null,
    Release_Year varchar(4) default '-',
    Cast varchar(255) not null,
    Gender enum('Male', 'Female'),
    No_of_shows int check(No_of_shows > 0)
    );
desc movies;

-- Day 6, Ques. 4, a
create table product
	(
	product_id int auto_increment primary key,
    product_name varchar(255) not null unique,
    description text,
    supplier_id int,
    foreign key(supplier_id)  references Suppliers(supplier_id)
    );
desc product;

-- Day 6, Ques. 4, b
create table suppliers
	(
	supplier_id int auto_increment primary key,
    supplier_name varchar(255),
    location varchar(255)
    );
desc suppliers;

-- Day 6, Ques. 4, c
create table stock
	(
	id int auto_increment primary key,
    product_id int,
    balance_stock int,
    foreign key(product_id) references Product(product_id)
    );
desc stock;

-- Day 7, Ques. 1
select employeeNumber, concat(firstName, ' ', lastName) as 'Sales Person', count(customerName) as 'Unique Customers' 
from customers as C
	join employees as E on C.salesRepEmployeeNumber = E.employeeNumber
group by employeeNumber
order by count(customerName) desc;

-- Day 7, Ques. 2
select C.customerNumber, C.customerName, P.productCode, P.productName, 
    OD.quantityOrdered as 'Ordered Qty', 
    P.quantityInStock as 'Total Inventory', 
	quantityInStock - quantityOrdered as 'Left Qty'
from customers as C
	join orders as O on C.customerNumber = O.customerNumber
    join orderdetails as OD on O.orderNumber = OD.orderNumber
    join products as P on OD.productCode = P.productCode
order by C.customerNumber, P.productCode;

-- Day 7, Ques. 3
create table laptop(Laptop_Name varchar(255));
insert into laptop values ('Dell'), ('HP');
create table colours(Colour_Name varchar(255));
insert into colours values ('white'), ('silver'), ('Black');
select count(*)
from laptop 
	cross join colours
order by Laptop_Name;
select *
from laptop 
	cross join colours
order by Laptop_Name;

-- Day 7, Ques. 4
create table project
	(
	EmployeeID int,
    FullName varchar(255),
    Gender varchar(255),
    ManagerID int
    );
insert into project
	values
	(1, 'Pranaya', 'Male', 3),
	(2, 'Priyanka', 'Female', 1),
	(3, 'Preety', 'Female', NULL),
	(4, 'Anurag', 'Male', 1),
	(5, 'Sambit', 'Male', 1),
	(6, 'Rajesh', 'Male', 3),
	(7, 'Hina', 'Female', 3);
select m.FullName as 'Manager Name', e.FullName as 'Emp Name'
from project as m
	join project as e on m.EmployeeID = e.ManagerID
where e.FullName is not null
order by 'Manager Name';

-- Day 8
create table facility
	(Facility_ID int, Name varchar(100), State varchar(100), Country varchar(100));
alter table facility
	modify Facility_ID int auto_increment primary key; 
alter table facility
	add City varchar(100) not null
	after Name;
desc facility;

-- Day 9
create table university (ID int, Name varchar(255));
insert into university
	values
	(1, "       Pune          University     "), 
	(2, "  Mumbai          University     "),
	(3, "     Delhi   University     "),
	(4, "Madras University"),
	(5, "Nagpur University");
set sql_safe_updates = 0;
update university
	set name = trim(both ' ' from name);
update university
	set name = regexp_replace(Name, '[[:space:]] +', ' ');
select * from university;

-- Day 10
create view products_status as
select 
year (orders.orderdate) as year,
concat(
count(orderdetails.quantityOrdered),
' (',
round((count(orderdetails.quantityordered) / (select count(*) from orderdetails) * 100), 0),
'%)'
) as value
from
orders
inner join
orderdetails on orders.ordernumber = orderdetails.ordernumber
group by
year (orders.orderdate)
order by
round((count(orderdetails.quantityordered) / (select count(*) from orderdetails) * 100), 0) desc;
select * from products_status;

-- Day 11, Ques 1
delimiter //
create procedure GetCustomerLevel (in p_customerNumber int, out p_customerLevel varchar(255))
	begin
	declare p_creditLimit decimal(10, 2);
select creditLimit into p_creditLimit from customers where p_customerNumber = CustomerNumber;
if p_creditLimit > 100000 then
	select 'Platinium' as customer_level;
elseif p_creditLimit between 25000 and 100000 then
	select 'gold' as customer_level;
else
	select 'silver' as customer_level;
end if;
end//
delimiter ;
CALL GetCustomerLevel(103, @customer_level);

-- Day 11, Ques 2
delimiter //
create procedure Get_country_payments (in p_year int, in p_country varchar(255))
begin
select year(p.paymentDate) as Year,
c.country as Country,
concat(format(sum(p.amount) / 1000, 0), 'K') as total_amount
from payments p
join customers c
on p.customerNumber = c.customerNumber
where year(p.paymentDate) = p_year and Country = p_country
group by year(p.paymentDate), Country;
end//
delimiter ;
CALL Get_country_payments(2003, 'France');

-- Day 12, Ques 1
select
	year(orderDate) as year,
    monthname(orderDate) as month,
    count(*) as Total_Orders,
    concat(
	format(
	ifnull(
	((count(*) - lag(count(*), 12) over (order by year(orderDate), month(orderDate))) / 
	lag(count(*), 12) over (order by year(orderDate), month(orderDate))) * 100, 0), 0), '%') as YoY_Percentage_Change
from
    orders
group by
    year(orderDate),
    month(orderDate)
order by
    year(orderDate),
	month(orderDate);

-- Day 12, Ques 2
create table emp_udf
	(
    Emp_ID int auto_increment primary key,
    Name varchar(255),
    DOB date
    );
insert into emp_udf (Name, DOB)
	values
    ("Piyush", "1990-03-30"), 
    ("Aman", "1992-08-15"), 
    ("Meena", "1998-07-28"), 
    ("Ketan", "2000-11-21"), 
    ("Sanjay", "1995-05-21");
delimiter //
create function calculate_age (dob date)
	returns varchar (255)
	deterministic
	begin
	declare years int;
	declare months int;
	declare age varchar (255);
set years = timestampdiff(year, dob, current_date());
set months = timestampdiff(month, dob, current_date()) - (years * 12);
set age = concat(years, ' years ', months, ' months ');
return age;   
end//
delimiter ;    
select Emp_Id, Name, DOB, calculate_age(DOB) AS Age FROM emp_udf;
 
-- Day 13, Ques 1
select customerNumber, customerName
from customers
where customerNumber not in
	(
	select customerNumber 
    from orders
    );
    
-- Day 13, Ques 2
select c.customerNumber, c.customerName, count(o.orderNumber) as 'Total Orders'
from customers as c
	left join orders as o
	on c.customerNumber = o.customerNumber
group by c.customerNumber
	union
select c.customerNumber, c.customerName, count(o.orderNumber) as 'Total Orders'
from customers as c
	right join orders as o
	on c.customerNumber = o.customerNumber
group by c.customerNumber;

-- Day 13, Ques 3
 with RankedOrderDetails as 
	(
    select
	orderNumber,
	quantityOrdered,
	rank() over (partition by OrderNumber order by quantityOrdered desc) as QuantityRank
    from Orderdetails
	)
select
    OrderNumber,
    max(quantityOrdered) as QuantityOrdered
from RankedOrderDetails
where QuantityRank = 2
group by OrderNumber;

-- Day 13, Ques 4
 with OrderProductCounts as
	(
    select OrderNumber, COUNT(*) as ProductCount
    from Orderdetails
    group by OrderNumber
	)
select
    max(ProductCount) as 'MAX(Total)',
    min(ProductCount) as 'MIN(Total)'
from OrderProductCounts;

-- Day 13, Ques 5
 SELECT ProductLine, COUNT(*) as LineCount
from products
where BuyPrice > (select avg(BuyPrice) from products)
group by ProductLine;

-- Day 14
create table emp_eh 
	(
    EmpID int primary key,
    EmpName varchar(255),
    EmailAddress varchar(255)
    );
delimiter //
create procedure insert_emp_eh 
	(
    in p_EmpID int, 
    in p_EmpName varchar(255), 
    in p_EmailAddress varchar(255)
    )
	begin
	declare exit handler for sqlexception
    begin
    select 'Error occurred' as message;
    end;
    insert into emp_eh (EmpID, EmpName, EmailAddress) 
    values (p_EmpID, p_EmpName, p_EmailAddress);
    select 'Data inserted successsfully' as message;
	end//
delimiter ;
call Insert_Emp_Eh (1, 'John', 'john@gmail.com');
call Insert_Emp_Eh (1, 'Don', 'don@gmail.com');

-- Day 15
create table emp_bit 
	(
    Name varchar(255), 
    Occupation varchar(255), 
    Working_date date, 
    Working_hours int
    );
insert into emp_bit 
	values
	('Robin', 'Scientist', '2020-10-04', 12),  
	('Warner', 'Engineer', '2020-10-04', 10),  
	('Peter', 'Actor', '2020-10-04', 13),  
	('Marco', 'Doctor', '2020-10-04', 14),  
	('Brayden', 'Teacher', '2020-10-04', 12),  
	('Antonio', 'Business', '2020-10-04', 11);
delimiter //
create trigger before_insert_trigger
	before insert
	on Emp_BIT for each row
	begin
	if new.working_hours < 0 then 
	set new.working_hours = -new.working_hours;
	end if;
	end//
delimiter ;
insert into emp_bit (Name, Occupation, Working_date, Working_hours)
	values
	('Rohit', 'Engineer', '2024-04-14', -9);
select * from emp_bit;
