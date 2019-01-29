--| 2.1 Select |---
-- Select all employees from Employee table.
select * from employee;
-- Select all records from the Employee table where last name is King.
select * from employee where lastname = 'King';
--Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
select * from employee where firstname = 'Andrew' and reportsto is null;


--| 2.2 ORDER BY |--
--Select all albums in Album table and sort result set in descending order by title.
select * from album order by title desc;
-- Select first name from Customer and sort result set in ascending order by city
select firstname from customer order by city asc;

--| 2.3 INSERT INTO |--
-- Insert two new records into Genre table
insert into genre (genreid, name) values (28, 'Classic');
insert into genre (genreid, name) values (29, 'EDM');
--Insert two new records into Employee table
insert into employee (employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email) 
	values (9, 'Davis', 'Iman', 'Associate', 6, '1995/09/26', '2019/01/14', '12702 Bruce B Downs Blvd', 'Tampa', 'FL', 'United States', '33613', '+1 999) 767-8879', '+1 (888) 777-666', 'iman@gmail.com');
insert into employee (employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email) 
	values (10, 'Young', 'Dea', 'Artist', 6, '1945/08/01', '2019/01/19', '436 Fletcher', 'Tampa', 'FL', 'United States', '33164', '+1 (333) 333-3333', '+1 (222) 222-2222', 'jdoe@email.com');

--  Insert two new records into Customer table
insert into customer (customerid, firstname, lastname, address, city, country, postalcode, phone, email, supportrepid) 
	values (60, 'Janer', 'Will', 'Watson', 'DC', 'United States', '88987', '+1 (666) 888-8878', 'willtill@email.com', 9);
insert into customer (customerid, firstname, lastname, company, address, city, country, postalcode, phone, email, supportrepid) 
	values (61, 'Stark', 'Tony', 'IFloyd Lloyd', 'Manhattan', 'New York', 'United States', '46456', '+1 (777) 666-5555', 'Saw@gmail.com', 10);



--| 2.4 UPDATE |----
-- Update Aaron Mitchell in Customer table to Robert Walter
update customer set firstname = 'Robert', lastname = 'Walter' where firstname = 'Aaron' and lastname = 'Mitchell';
--Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
update artist set name = 'CCR' where name = 'Creedence Clearwater Revival';


--| 2.5 LIKE |---------------------------------------------------------
-- Select all invoices with a billing address like “T%”
select * from invoice where billingaddress like 'T%';


--| 2.6 BETWEEN |---------------------------------------------------------
--Select all invoices that have a total between 15 and 50
select * from invoice where total between 15 and 50;
-- Select all employees hired between 1st of June 2003 and 1st of March 2004
select * from employee where hiredate between '2003-06-01' and '2004-03-01';



--| 2.7 DELETE |---
-- Delete a record in Customer table where the name is Robert Walter (
---There may be constraints that rely on this, find out how to resolve them).
alter table invoiceline
drop constraint fk_invoicelineinvoiceid;

alter table invoiceline
add constraint k_invoicelineinvoiceid foreign key (invoiceid) references invoice(invoiceid) on delete cascade;

alter table invoice
drop constraint fk_invoicecustomerid;

alter table invoice
add constraint fk_invoicecustomerid foreign key (customerid) references customer(customerid) on delete cascade;

delete from customer where firstname = 'Robert' and lastname = 'Walter';



--| 3.1 System Defined Functions |---
-- Create a function that returns the current time.
create or replace function timeStamped() 
returns theTime as $$ 
begin
	return now();
end; 
$$ language plpgsql;

select timeStamped();
--create a function that returns the length of a mediatype from the mediatype table
create or replace function lengthed(id int) 
returns int as $$
begin
	return length(name) from mediatype where mediatypeid = id;
end;
$$ language plpgsql;

select lengthed(2);


--| 3.2 System Defined Aggregate Functions |------
-- Create a function that returns the average total of all invoices
create or replace function invoiceAvg() 
returns numeric as $$
begin
	return avg(total) from invoice;
end;
$$ language plpgsql;
select invoiceAvg();

--Create a function that returns the most expensive track
create or replace function trackEx() 
returns numeric as $$
begin
	return max(track.unitprice) from track;
end;
$$ language plpgsql;
select trackEx();


--| 3.3 User Defined Scalar Functions |----
--Create a function that returns the average price of invoiceline items in the invoiceline table
create or replace function averagePrice() 
returns numeric as $$
begin
	return avg(unitprice) from invoiceline;
end;
$$ language plpgsql;

select averagePrice();



--| 3.4 User Defined Table Valued Functions |-----
--| Task 1 – Create a function that returns all employees who are born after 1968.
create or replace function after1968() 
returns setof employee as $$
begin
	return Query(select * from employee where extract(year from birthdate) > 1968);
end;
$$ language plpgsql;
select after1968();


--| 4.1 Basic Stored Procedure |-----
-- Create a stored procedure that selects the first and last names of all the employees.
create function namesOfEmployees() returns TABLE(firstname text, lastname text) as 
    $$ select firstname, lastname from employee 
    $$ language sql;

--| 4.2 Stored Procedure Input Parameters |------
-- Create a stored procedure that updates the personal information of an employee.
create or replace function update_emp(
	emID int, 
	emBday timestamp, 
	emAddress varchar, 
	emCity varchar, 
	emState varchar,
	emCountry varchar,
        emZip varchar,
        emPhone varchar,
        emFax varchar,
        emEmail varchar
)
returns void as $$
begin
    update employee
    	set birthdate = emBday,
    	address =emAddress,
    	city = emCity,
    	state =emState,
    	country =emCountry,
    	postalcode =emZip,
    	phone = emPhone,
    	fax = emFax,
    	email = emEmail
        where employeeid =emID;
end;
$$ language plpgsql;

--Create a stored procedure that returns the managers of an employee.
 create function theManagers(empid integer) returns integer as 
    $$ select reportsto from employee where employeeid=$1;
    $$ language sql;
--| 4.3 Stored Procedure Output Parameters |-----
--Create a stored procedure that returns the name and company of a customer.
    create function customerInfo(custid integer) returns table(firstname text, lastname text, company text) as
    $$ select firstname, lastname, company from customer;
    $$ language sql;

--| 5.0 Transactions |----
--Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
begin;
	delete from invoice where invoiceid = 210;
commit;
-- Create a transaction nested within a stored procedure that inserts a new record in the Customer table
create or replace function insertCust(
       emID int,
       emFirstName varchar, 
	emLastName varchar, 
	emCompany varchar, 
	emBday timestamp, 
	emAddress varchar, 
	emCity varchar, 
	emState varchar,
	emCountry varchar,
        emZip varchar,
        emPhone varchar,
        emFax varchar,
        emEmail varchar
	emSupport int
) 
returns void as $$
	begin
		insert into customer values(emID, emFirstName,emLastName, emCompany, emBday, emAddress, emCity, emState, emCountry, emZip,emPhone, emFax, emEmail, emSupport;
	end;
$$ language plpgsql;

select insert_customer(64, 'Andy', 'Mack', 'Google', '2343 Blvd', 'Transport', 'PA', 'US', '38439', '333-233-4333', '243-934-3243', 'andy@gmamil.com', 9);



--| 6.1 AFTER/FOR |---

create or replace function helloWorld()
returns trigger as $$
	begin
		raise 'Hello, World';
	end;
$$ language plpgsql;

--Create an after insert trigger on the employee table fired after a new record is inserted into the table.
create trigger after_insert after insert on employee  for each row execute procedure insertTrig();
--Task Create an after update trigger
--Create an after update trigger on the album table that fires after a row is inserted in the table
  create trigger after_update_album after update on album for each row
    execute procedure afterTrig();
--Create an after delete trigger on the customer table that fires after a row is deleted from the table.
    create trigger after_delete_customer after update on customer for each row
    execute procedure afterDelete();

--| 7.1 INNER |-----
-- Create an inner join that joins customers and orders 
--and specifies the name of the customer and the invoiceId.
    Select invoiceid as "invoiceid", firstname as "fname", lastname as "lname" from customer C 
    Inner join invoice I on c.customerid = i.customerid;
--| 7.2 OUTER |---
-- Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
    select c.customerid as "customerid", firstname as "firstname", lastname as "lastname", invoiceid as "invoiceid", total as "total"
    from invoice I full join customer C on C.customerid = I.customerid;

--| 7.3 RIGHT |---
--Create a right join that joins album and artist specifying artist name and title.
   select name as "artistname", title as "title" from album A 
    right join artist art on a.artistid = art.artistid;
--| 7.4 CROSS |----
-- Task 4 – Create a cross join that joins album and artist and sorts by artist name in ascending order.
select * from
album cross join artist  
order by artist.name asc;


--| 7.5 SELF |-----
-- Task 5 – Perform a self-join on the employee table, joining on the reportsto column.
select 
	e.title as "Employee Title", 
	concat(e.lastname, ', ', e.firstname) as "Employee Name",
	e.reportsto as "Reports To", 
	m.title as "Manager Title", 
	concat(m.lastname, ', ', m.firstname) as "Manager Name",
	m.employeeid as "Manager ID"
from employee as e
inner join employee as m 
on e.reportsto = m.employeeid
order by m.employeeid asc;
