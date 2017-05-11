------ SQL PART 1 ------
---- 1. Visualize the data model ----
--   1.Take a look at the tables above. Which field are the PK of table S, P and SP?
--     The PK of table S (Suppliers) is S (The unique number that the supplier has).
--     The PK of table P (Products) is P (The unique number that the product has).
--     The SP does not have any PKs.

--   2. Roughly draw the tables above on a piece of paper and show the relationships between the tables. ----- 
--   Which key is connected to which?
--   Svar: Key S in table S is connected to key S in table SP
--   Svar: Key P in table P is connected to key P in table SP


---- 2. Create the tables and insert the data ----

--S (Suppliers)
create table S
(S varchar(2) not null,
SNAME varchar(7),
CITY varchar(9),
primary key (S));

--P (Products)
create table P
(P varchar(2) not null,
PNAME varchar(5),
COLOUR varchar(5),
WEIGHT integer,
PRICE float,
primary key (P));

--SP (Deliveries)
create table SP
(S varchar(2),
 P varchar(2),
 QTY integer,
foreign key (S) references S(S),
foreign key (P) references P(P));

insert into S values('S1','Smith','London');
insert into S values('S2','Jones','Paris');
insert into S values('S3','Blake','Paris');
insert into S values('S4','Clark','London');
insert into S values('S5','Adams','Athens');

insert into P values('P1','Nut','Red',12,45);
insert into P values('P2','Bolt','Green',17,23);
insert into P values('P3','Screw','Blue',17,12);
insert into P values('P4','Screw','Red',14,40);
insert into P values('P5','Cam','Blue',12,44);
insert into P values('P6','Cog','Red',19,12);

insert into SP values('S1','P1',300);
insert into SP values('S1','P2',200);
insert into SP values('S1','P3',400);
insert into SP values('S1','P4',200);
insert into SP values('S1','P5',100);
insert into SP values('S1','P6',100);
insert into SP values('S2','P1',300);
insert into SP values('S2','P2',400);
insert into SP values('S3','P2',200);
insert into SP values('S4','P2',200);
insert into SP values('S4','P4',300);
insert into SP values('S4','P5',400);

---- 3. Projection, restriction ----
--1. Show all columns from all suppliers in the database
select * from S;

--2. Show the same as 3.1 but now sorted on name.
select * from S order by SNAME;

--3. Project (show) the name of the suppliers 
select SNAME from S;

--4. Restrict 3.3 to the suppliers in London
select SNAME from S where CITY='London';

--5. Show all products with a weight smaller than 15
select * from P where WEIGHT<15;

--6. Show all red products with a price larger than 20
select * from P where COLOUR='red' and PRICE>20;
 
--7. Show all red products with a weight larger than 13 and a price larger than 43
select * from P where PRICE>43 and WEIGHT>13 and COLOUR='red';

---- 4. Aggregated functions ----
--1. Show the total weight of all products
select sum(WEIGHT) from P;

--2. Show the average price of all products
select avg(PRICE) from P;

--3. Show the average price of all green products
select avg(PRICE) from P where COLOUR='green';

--4. Show the total weight of all products for each colour (W3School: Group by)
select COLOUR, SUM(WEIGHT) from P group by COLOUR;  

---- 5. Join --
--View the slides (and book) for examples on cross join, natural join, inner join, right/left outer join etc.
--1. Show the cartesian product between SP and P (Wiki: Cross Join)
select * from SP cross join P;

--2. Restrict your 5.1 so you get the inner join (=natural join) between SP and P.
select * from SP inner join P on P.P=SP.P;

--3. Show all names of suppliers who have supplied more than 200 items of a product.
select SNAME from S,SP where S.S= SP.S and SP.QTY>200;

--4. Remove duplicates from 5.3 (W3School: SELECT DISTINCT)
select distinct(SNAME) from S,SP where S.S= SP.S and SP.QTY>200;

--5. Show all suppliers who have supplied 200 articles and live in Paris
select distinct(SNAME) from S,SP where S.S= SP.S and SP.QTY=200 and S.CITY='Paris';

---- 6. Joining Products, Deliveries and Suppliers ----
--1. Show the name of all products of which 300 or more are sold in a delivery.
select P.PNAME from S inner join SP on S.S=SP.S inner join P on P.P=SP.P and QTY>=300;

--2. Remove duplicates from 6.1
select distinct(P.PNAME) from S inner join SP on S.S=SP.S inner join P on P.P=SP.P and QTY>=300;

--3. Show all names of all products delivered and the name of all suppliers these products are delivered to.
select P.PNAME, S.SNAME from S inner join SP on S.S=SP.S inner join P on P.P=SP.P;

---- 7. Outer join ----
--1. Show the name of all suppliers and the quantity of the deliveries of all suppliers (use INNER JOIN).
select S.SNAME, SP.QTY from S inner join SP on S.S=SP.S inner join P on P.P=SP.P;

--2. The supplier Adams is missing, find out why Adams is not in the result found in 7.1.
--ANSWER:Adams does not have a row in table SP(Deliveries)

--3. Change your INNER JOIN (in 7.1) to an OUTER JOIN so also Adams is listed.
select S.SNAME, SP.QTY from (S left outer join SP on S.S=SP.S left outer join P on P.P=SP.P);

--4. Be aware of the difference between INNER and OUTER JOIN and the use of LEFT and RIGHT in OUTER JOINS.
-- Ok

---- 8. Nested queries ----
--1. Show the name of the supplier(s) who have delivered more than 100.
select distinct(S.SNAME) from S join SP on S.S=SP.S join P on P.P=SP.P where SP.QTY>100;

--2. Show the quantity of the largest delivery.
select max(SP.QTY) from S join SP on S.S=SP.S join P on P.P=SP.P;

--3. Show the name of the supplier(s) who have delivered the largest delivery (as a nested query).
select S.SNAME from (S join SP on S.S=SP.S join P on P.P=SP.P) where SP.QTY=(select max(SP.QTY) from SP);

---- 9. IN ----
--1. Show the names of all products that have weight 17, 14 or 12
Select PNAME from P where WEIGHT =17 or WEIGHT=14 or WEIGHT=12;

--2. Rewrite the 9.1 using IN
Select PNAME from P where WEIGHT in (17,14,12);

--3. Use IN while showing the names of all products that not have the weight 17, 14 and 10.
Select PNAME from P where WEIGHT not in (17,14,10);

---- 10. BETWEEN ----
--1. Show all products that have a price between 40 and 50.
Select PNAME from P where PRICE between 40 and 50;

--2. Show the name of all products that have a weight between 14 and 18 and are delivered to London   
select distinct(PNAME) from (S join SP on S.S=SP.S join P on P.P=SP.P) where WEIGHT between 14 and 18 and S.CITY='London';

---- 11. Potpourri ----
--1. How many products are delivered by each supplier?
select S.SNAME, count(P.PNAME) as NumberOfProducts from (S join SP on S.S=SP.S join P on P.P=SP.P) group by SNAME;

--2. How many suppliers have delivered blue articles?
select count(S.SNAME) as SuppliersThatDeliveredBlueArticles from (S join SP on S.S=SP.S join P on P.P=SP.P) where P.COLOUR='blue';

--3. How many articles are green?
select count(P.PNAME) as TheAmountOfProductsThatAreGreen from P where P.COLOUR='green';

select sum(SP.QTY) as TheAmountAllGreenProductsDelivered from (S join SP on S.S=SP.S join P on P.P=SP.P) where P.COLOUR='green';

--11.3 can be intepreted as (The amount of products that are green) or (The total amount of all producs delivered that has the color 
--green). Answer them both.

------ SQL PART 2 ------
---- 1. DELETE, UPDATE, INSERT ----
--1. Delete the supplier with the name "Adams" and check if the supplier is deleted
delete from S where SNAME='Adams';
select SNAME from S;

--2. Supplier "Jones" moved from Paris to Hallabro. Make the change in the database.
update S set CITY='Hallabro' where SNAME='Jones';
 
--3. Move all suppliers living in London to Tingsryd.
update S set CITY='Tingsryd' where CITY='London';

--4. Add supplier "Jackson" living in Stockholm.
insert into S values('S5','Jackson','Stockholm');

--5. Finally the € is introduced in Sweden. Devide all product prices by 10.
update P set P.PRICE=P.PRICE/10;

--6. A new paint causes all red products to be a little heavier. Add 2 to the weight of all red products.
update P set P.WEIGHT=WEIGHT+2 where COLOUR='red';

---- 2. VIEW ----
--1. Create a VIEW (VRedProducts) containing all attributes of all red products (see slides, the manual and W3Schools: CREATE VIEW).
create view VRedProducts as select P,P.PNAME,P.COLOUR,P.WEIGHT,P.PRICE from P where COLOUR='red';

--2. Show deliveries of red products. Use your view for joining.
select SP.S,SP.P,SP.QTY,VRedProducts.COLOUR from (S join SP on S.S=SP.S join VRedProducts on VRedProducts.P=SP.P);

--3. Make a view (VTotalWeight) on product showing the total weight of all products.
create view VTotalWeight as select sum(WEIGHT) as TotalWeight from P;

--4. Add a product called "Spike", colour red, weight 13, price 20 by using your view VRedProducts.
insert into VRedProducts values('P7','Spike','Red',13,20);
 
--5. Show the result of view VTotalWeight once more. Did it update?
select * from VTotalWeight;
  --It did update to 110

--6. Insert something in the view of VTotalWeight. Try to reason why this does not work
insert into VTotalWeight values(15);
--Man får:Update or insert of view or function 'VTotalWeight' failed because it contains a derived or constant field.
--Svar:Man kan bara uppdatera sådana fält i vyer som direkt kommer från tabell-kolumnen P, det gör inte ett aggregat som sum. 

---- 3. DROP TABLE ----
--1. Drop the table P
drop table P;
--2. If it is not possible to Drop table P try to find out why and solve the problem
--ANSWER:The table P is referenced by table SP, drop table SP first
drop table SP;
drop table P;

--3. Delete all rows in table S
delete from S;
--4. What is the difference between DROP TABLE and DELETE ?
--ANSWER:
--Drop table removes the databasobject, for instance a  table, view or stored procedure. Drop removes 
--the object from the schema.
--Delete table is used to remove zero, one or several rows from a table but delete table
--never removes the object from the schema.


------ SQL PART 3 ------
---- 1. Create the table and fill it with values ----
--1. Decide the PK and a FK for the table above.
       --PK=NR
	   --FK=BOSS
--2. Create the table Employee in SQL and fill the data into the tables
create table Employee
(NR integer not null,
ENAME varchar(9),
BOSS integer,
primary key (NR),
foreign key (BOSS) references Employee(NR));

insert into Employee values(1,'Johansson',NULL);
insert into Employee values(2,'Åkesson',1);
insert into Employee values(3,'Arvidsson',1);
insert into Employee values(4,'Svensson',3);
insert into Employee values(5,'Karlsson',3);
insert into Employee values(6,'Lundin',4);

---- 2. Hierarchies in SQL ----
--1. Show all the names of the employees sorted on name. Often this will go wrong with Swedish signs. Å will not be sorted with A but be put last on the list. This can be totally different in other database products (be careful!)
select ENAME from Employee order by ENAME;

--2. Show all the names of the employees and the name of the boss of each employee (hint: use a aliasing).
select Worker.ENAME as Worker,Chef.ENAME as Chef from Employee as Worker, Employee as Chef where Worker.BOSS=Chef.NR; 

--3. Change 2.2 so also Johansson will be listed in 2.2.
select Worker.ENAME as Worker,Chef.ENAME as Chef from (Employee as Worker left outer join Employee as Chef on Worker.BOSS=Chef.NR); 
