----------- 1. Nice to have utilities -----------

-- 1.Create a stored procedure (SPSumAccount) that shows the total sum of all money in the table Account and the total sum -- of all money in the table AccountLog. 
--drop procedure SPSumAccount;
select * from Account;
go
select * from AccountLog;
go
create procedure SPSumAccount
as
begin
select sum(balanceAccount) as SumBalanceAccount from Account;
select sum(amountAccountLog) as SumAccountLog from AccountLog;
end;
go
exec SPSumAccount
go

-----------  2. Explicit / implicit transactions  -----------
--1.Lets create SQL for the action ”Nils withdraws 300”. It consists of one UPDATE (table Account) statement and one INSERT (AccountLog) statement that both needs to be carried out atomically.  Write the two statements as implicit transations and execute them. Verify that it works.
select * from Account;
go
select * from AccountLog;
go
update Account set balanceAccount=200 where nameAccount='Nils';
insert into AccountLog values(1,getdate(),-300);
go 
select * from Account;
go
select * from AccountLog;

--2.Now perform the opposite action ”Nils inserts 300 to his account”. This time do it using a explicit transaction. --Verify that it works.
select * from Account;
go
select * from AccountLog;
go
begin tran updateAccount
go
update Account set balanceAccount=500 where nameAccount='Nils';
go
insert into AccountLog values(1,getdate(),300);
go
commit tran updateAccount

select * from Account;
go
select * from AccountLog;

--3.Review the content of the both tables and use SPSumAccount to verify that the sum is correct (should be the same as --in the beginning).
select * from Account;
go
select * from AccountLog;
go
exec SPSumAccount
go
-----------  3. Transactions step by step -----------
--1.Write and execute SQL-statements that start a transaction and withdraw an optional amount of money from Nils' account.
--Check the tables.
select * from Account;
go
select * from AccountLog;
go
begin tran updateAccount
go
update Account set balanceAccount=200 where nameAccount='Nils';
go
select * from Account;
go
select * from AccountLog;
--2.Write and execute a SQL-statement that inserts a log entry for the performed action in the AccountLog table.
--Check the tables.
go
insert into AccountLog values(1,getdate(),400);
go
select * from Account;
go
select * from AccountLog;

--3. Write and execute a SQL-statement that performs a rollback of the transaction.
--Check the tables.
go
rollback tran updateAccount
go
select * from Account;
go
select * from AccountLog;

--4.Do the same steps again but perform commit instead of rollback.
--Check the tables.
go
select * from Account;
go
select * from AccountLog;
go
begin tran updateAccount
go
update Account set balanceAccount=900 where nameAccount='Nils';
go
insert into AccountLog values(1,getdate(),400);
go
commit tran updateAccount
go
select * from Account;
go
select * from AccountLog;
go
-----------  4. A transaction in a stored procedure  -----------
--1. Create the stored procedure (SPWithdraw) with two input parameters (account number and amount to withdraw).
--drop procedure SPWithdraw
go
create procedure SPWithdraw
    @accountNumber INT,
    @amountToWithdraw int
as
begin tran updateAccount
declare	@accountBalance int
set @accountBalance=(select balanceAccount from Account where nrAccount=@accountNumber);
set @accountBalance=@accountBalance-@amountToWithdraw;
update Account set balanceAccount=@accountBalance where nrAccount=@accountNumber;
insert into AccountLog values(@accountNumber,getdate(),@amountToWithdraw);
if @accountBalance>=0 
begin
commit tran updateAccount;
end
else 
begin
rollback tran updateAccount; 
end;

--2. Verify that SPWithdraw works by performing the actions

--2a) ”Nils withdraws 6000”. Nothing should change in the tables and SPSumAccount should still say the same value.
exec SPWithdraw @accountNumber=1,@amountToWithdraw=6000;
go
select * from Account;
go
select * from AccountLog;
go
exec SPSumAccount
go

--2b) ”Nils withdraws 400”. The balance on Nils' account should now be 100. Use SPSumAccount to verify that it worked.
exec SPWithdraw @accountNumber=1,@amountToWithdraw=400;
go
select * from Account;
go
select * from AccountLog;
go
exec SPSumAccount
go
-----------  5. Get two connections to the database  -----------
--Result ok


-----------  6. Concurrency and locking  -----------
go
begin tran -- BEGIN if MS SQL Server
UPDATE Account
SET balanceAccount = balanceAccount - 3000
WHERE nrAccount = 1;

SELECT * FROM Account;
--------------------------
ROLLBACK;
--------------------------
SELECT * FROM Account;

sp_who dv1454_ht14_d_7

--Do you understand what happens? Does it make sense? Do it again to get the hang of it.
--I am using TRANSACTION ISOLATION LEVEL read committed.
--This level does not allow reading of uncommitted data.
--From the first connection I started a transaction where balanceaccount for user 1 (Nils)
--where 3000 is to be withdrawed.
--From the second connection I do a SELECT * FROM Account; where nothing is displayed since
--it is not allowed read of uncomitted data.
--For the first connection I did a rollback so that the money that are supposed to be withdrawed
--are cancelled.
--For the second connection I do a SELECT * FROM Account; now values are displayed since the 
--first connection has rollbacked the commit. 
--For the first connection I do a SELECT * FROM Account; to display that the money has not
--been withdrawed.

begin tran test2 -- BEGIN if MS SQL Server

UPDATE Account
SET balanceAccount = balanceAccount - 3000
WHERE nrAccount = 1;

SELECT * FROM Account;
-----------------------
SELECT * FROM Account; 
COMMIT;

--Do you understand what happens? Does it make sense? Do it again to get the hang of it.
--The second connection can not read the Account but the second connection can update the 
--Account, The first connection does not see the second connections update until after the
--commit.

--Answer the following questions, use the reference manual if needed.

--Explain what happens, step by step.
--1. The first connection starts a transaction and make a withdraw with 3000 on NrAccount=1;
--2. The first connection makes a read and see that 3000 is to be withdrawn
--3. The second connetion makes a withdraw with 3000 on NrAccount=1;
--4. The first connection makes a read and does not see that connection 2 tries to make a withdraw.
--5. The first connection makes a commit and both of the withdraws are executed. 
--6. The second connection makes a read and see that 3000 has been withdrawned.

--Which isolation level is default in the database you are using?
--READ COMMITTED

--What is the default behaviour in your database?
--READ COMMITTED does not allow reading of uncommitted data-
--It does allow unrepetable readings, invalid sums and ghostposts.

--Is the behaviour of your database good according to your personal opinion (motivate)?
--No I dont think it is good because the second connections update is executed on the commit.

-----------  7. Isolation levels  -----------
DBCC USEROPTIONS
--isolation level, read committed
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DBCC USEROPTIONS
--isolation level, read uncommitted
--What are the consequences, for us as developers, if different DBMS has different default levels?
--The consequences is that the database behave different on different DBMS if they have
--different default levels.
--The lection learned is to always set a isolation level the first you do when starting to 
--program DBMS.
--It is always good to have isolation level serializable since serializable is the only level
--that all DBMS must be able to handle according to the SQL-standard.

-----------  8. Isolation level and dirty reads  -----------
-- Reset the balance on account Anna and Ingvar
UPDATE Account SET balanceAccount = 300 WHERE nameAccount = 'Anna';
UPDATE Account SET balanceAccount =   0 WHERE nameAccount = 'Ingvar';

-- Create a view to make easy checkup on balance
--go
--drop view VBalance
go
CREATE VIEW VBalance AS SELECT 
* FROM Account WHERE nameAccount = 'Anna' OR nameAccount = 'Ingvar';
go
SELECT * FROM VBalance;
---------------------------
begin tran test3 -- BEGIN if MS SQL Server

UPDATE Account SET balanceAccount = balanceAccount - 500 WHERE nameAccount = 'Anna';
UPDATE Account SET balanceAccount = balanceAccount + 500 WHERE nameAccount = 'Ingvar';

SELECT * FROM VBalance;
------------------------------

-- Anna can not ge below 0, rollback
ROLLBACK;

SELECT * FROM VBalance;
-------------------------------------------
--Did Ingvar get the 500 from the ATM? Maybe, depends on how the code was written in the ATM. Anyway, the example shows a dirty read and how things can go wrong because of it.
--No he didnt.
-----------  9. Locking and deadlock  -----------

-- Reset the balance on account Anna
UPDATE Account SET balanceAccount = 100 WHERE nameAccount = 'Anna';

-- Perform rollback in both clients to ensure that no transaction is ongoing
ROLLBACK;

-------------------

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
------------------------------------------------
begin tran test4-- BEGIN if MS SQL Server

SELECT * FROM Account WHERE nameAccount = 'Anna';

------------------------------------------------
-- Reset the balance on account Anna
UPDATE Account SET balanceAccount = 0 WHERE nameAccount = 'Anna';

-- Deadlock aquired and detected?
--yes
--Transaction (Process ID 52) was deadlocked on lock resources with another process and has been chosen as the deadlock victim. Rerun the transaction.

-------------------------------------------------------------------
SELECT * FROM Account WHERE nameAccount = 'Anna';

-- If lock proceed.

--------------------------------------------------

ROLLBACK tran test4;

--------------------------------------------------
--Perform the exercise again with another isolation level.
--As you will see the deadlock situation will disappear at some isolation level (dependent on DBMS).  

-----------------------------------
SET TRANSACTION ISOLATION LEVEL repeatable read;  --Still deadlocked

SET TRANSACTION ISOLATION LEVEL read committed;  --Deadlocked disappeared 




