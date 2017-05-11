--
-- For BULK command
--
sp_addsrvrolemember dv1454_ht14_d_7,  bulkadmin;

--
-- For viewing the execution plan
--
use dv1454_ht14_d_7 grant SHOWPLAN to dv1454_ht14_d_7;

--************1. Primary key as index*********************

-- Create the Course table (drop first if it already exists)
--
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='Course')
  DROP TABLE Course
GO
CREATE TABLE Course
(
	codeCourse CHAR(6) NOT NULL,
	nameCourse VARCHAR(200) NOT NULL,
	pointsCourse DECIMAL(3,1) NOT NULL
);

--
-- Insert bulk data into Course table
-- File must be on same machine as databaseserver
--
BULK INSERT Course
	FROM 'c:/course.txt'
	WITH
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = '\t',
		ROWTERMINATOR = '\n',
		CODEPAGE = 'ACP'        -- Coding of character set
	)
;

SELECT * FROM Course;

SELECT * FROM Course WHERE codeCourse = 'DV1219';

ALTER TABLE Course ADD CONSTRAINT pk_codeCourse PRIMARY KEY (codeCourse);

SELECT * FROM Course WHERE codeCourse = 'DV1219';
--ESC 3.2831 (0,0032831)

--
-- Remove the constraint
--
ALTER TABLE Course DROP CONSTRAINT pk_codeCourse;

SELECT * FROM Course WHERE codeCourse = 'DV1219';

--0,0618958 

--What are the main difference between having a primary key and not?
--The difference is with having primary key is 20 times faster.

--
-- Check which PK's are defined for a table

exec sp_pkeys Course;

--Recreate the PRIMARY KEY constraint before proceeding.
ALTER TABLE Course ADD CONSTRAINT pk_codeCourse PRIMARY KEY (codeCourse);

--**************2. Foreign key as index *****************
--
-- Create the Register table (drop first if it already exists)
--
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='Register')
  DROP TABLE Register
GO
CREATE TABLE Register
(
	courseRegister CHAR(6) NOT NULL,
	termRegister CHAR(5) NOT NULL,
	starttermRegister CHAR(5) NOT NULL,
	instRegister VARCHAR(4) NOT NULL,
	utbomrRegister CHAR(2) NOT NULL,
	progRegister CHAR(5) NULL,
	konRegister CHAR(1) NOT NULL,
	nivaRegister CHAR(1) NOT NULL,
	hstkRegister DECIMAL(10,6) NOT NULL,
	hprkRegister DECIMAL(10,6) NOT NULL
);

--
-- Insert bulk data into Register table
-- File must be on same machine as databaseserver
--
BULK INSERT Register
	FROM 'C:\register.txt'
	WITH
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = '\t',
		ROWTERMINATOR = '\n'
	)
;

SELECT * FROM Register;

SELECT * FROM Register WHERE courseRegister = 'DV1219';

SELECT * FROM Register AS R INNER JOIN Course AS C ON R.courseRegister = C.codeCourse;

--
-- Create the FK
--
ALTER TABLE Register ADD CONSTRAINT fk_course FOREIGN KEY(courseRegister) REFERENCES Course(codeCourse);

--
-- Verify that it exists
exec sp_fkeys Course;

--ALTER TABLE Register DROP CONSTRAINT fk_course;

--Ok, lets review the execution plan for the join again. Did it change?

SELECT * FROM Register AS R INNER JOIN Course AS C ON R.courseRegister = C.codeCourse;

--It did not change

--Why did the execution plan not change when we introduced a foreign key?
--FOREIGN KEY Constraints

--Man behöver ha en alter WITH CHECK CHECK, annars så kan man inte lita på constraint 
--detta gör att Exection plan inte påverkas


ALTER TABLE Register DROP CONSTRAINT fk_course;
-- Create the index
--
CREATE INDEX i_courseRegister ON Register (courseRegister);

--
-- Verify that it exists
--
exec sp_helpindex Register;


ALTER TABLE Register ADD CONSTRAINT fk_course FOREIGN KEY(courseRegister) REFERENCES Course(codeCourse);

--
-- Verify that it exists
exec sp_fkeys Course;

SELECT * FROM Register AS R INNER JOIN Course AS C ON R.courseRegister = C.codeCourse;

--Did the execution plan change for the join? No, still the same huh?!
--No, Still the same

--
-- Drop and re-create the index
--
DROP INDEX Register.i_courseRegister;
CREATE CLUSTERED INDEX i_courseRegister ON Register (courseRegister);

--
-- Verify that it exists and what type it is
--
exec sp_helpindex Register;

SELECT * FROM Register AS R INNER JOIN Course AS C ON R.courseRegister = C.codeCourse;

--esc is 0.136665
--Review the manual to see what the difference is between a CLUSTERED and a NONCLUSTERED index.
-- What is the main differences between these two index-types?
--SQL CLUSTERED index är sorterade i samma ordning som huvudfilen, men på ett (eller flera)
 --fält som inte är en nyckel.
--SQL NONCLUSTERED index som är sorterade i en annan ordning än i huvudfilen.

--*****************3. Reviewing the impact of indexes ************
--No index
DROP INDEX Register.i_courseRegister;
--
-- Verify that it exists and what type it is
--
exec sp_helpindex Register;

SELECT *
FROM Register AS R
	INNER JOIN Course AS C
		ON R.courseRegister = C.codeCourse
WHERE
	courseRegister = 'DV1219';
--esc is 0.053334

--Clustered index
DROP INDEX Register.i_courseRegister;
CREATE CLUSTERED INDEX i_courseRegister ON Register (courseRegister);

--
-- Verify that it exists and what type it is
--
exec sp_helpindex Register;

SELECT *
FROM Register AS R
	INNER JOIN Course AS C
		ON R.courseRegister = C.codeCourse
WHERE
	courseRegister = 'DV1219';
--esc is 0.0066337

--NonClustered index
DROP INDEX Register.i_courseRegister;
CREATE NONCLUSTERED INDEX i_courseRegister ON Register (courseRegister);

--
-- Verify that it exists and what type it is
--
exec sp_helpindex Register;

SELECT *
FROM Register AS R
	INNER JOIN Course AS C
		ON R.courseRegister = C.codeCourse
WHERE
	courseRegister = 'DV1219';
--esc is 0.0424523

--******************4. Choosing the proper index ***************
DROP INDEX Register.i_courseRegister;
DROP INDEX Course.i_codeCourse;
DROP INDEX Register.i_progRegister;
-- Create the Program table (drop first if it already exists)
--
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='Program')
  DROP TABLE Program
GO
CREATE TABLE Program
(
	kodProgram CHAR(5) NOT NULL,
	benamnProgram VARCHAR(120) NOT NULL
);

--
-- Insert bulk data into Program table
-- File must be on same machine as databaseserver
--
BULK INSERT Program
	FROM 'C:\program.txt'
	WITH
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = '\t',
		ROWTERMINATOR = '\n',
		CODEPAGE = 'ACP'        -- Coding of character set
	)
;

SELECT * FROM Program;


SELECT *
FROM Register AS R
	INNER JOIN Course AS C
		ON R.courseRegister = C.codeCourse
	INNER JOIN Program AS P
		ON R.progRegister = P.kodProgram
WHERE 
	progRegister IN ('TSWEH', 'TSWEK')
;

--ACTION
CREATE NONCLUSTERED INDEX i_courseRegister ON Register (courseRegister);
CREATE NONCLUSTERED INDEX i_codeCourse ON Course (codeCourse);
CREATE NONCLUSTERED INDEX i_progRegister ON Register (progRegister);
CREATE NONCLUSTERED INDEX i_kodProgram ON Program (kodProgram);
--esc 0.143 
DROP INDEX Register.i_courseRegister;
DROP INDEX Course.i_codeCourse;
DROP INDEX Register.i_progRegister;
DROP INDEX Program.i_kodProgram;


--ACTION
CREATE CLUSTERED INDEX i_courseRegister ON Register (courseRegister);
CREATE NONCLUSTERED INDEX i_codeCourse ON Course (codeCourse);
CREATE NONCLUSTERED INDEX i_progRegister ON Register (progRegister);
CREATE CLUSTERED INDEX i_kodProgram ON Program (kodProgram);
--esc 0.136 
DROP INDEX Register.i_courseRegister;
DROP INDEX Course.i_codeCourse;
DROP INDEX Register.i_progRegister;
DROP INDEX Program.i_kodProgram;

--ACTION
CREATE NONCLUSTERED INDEX i_courseRegister ON Register (courseRegister);
CREATE NONCLUSTERED INDEX i_codeCourse ON Course (codeCourse);
CREATE CLUSTERED INDEX i_progRegister ON Register (progRegister);
CREATE CLUSTERED INDEX i_kodProgram ON Program (kodProgram);
--ESC 0,0824441
DROP INDEX Register.i_courseRegister;
DROP INDEX Course.i_codeCourse;
DROP INDEX Register.i_progRegister;
DROP INDEX Program.i_kodProgram;


--ACTION
CREATE CLUSTERED INDEX i_progRegister ON Register (progRegister);
CREATE CLUSTERED INDEX i_kodProgram ON Program (kodProgram);
--ESC 0,0824441
DROP INDEX Register.i_progRegister;
DROP INDEX Program.i_kodProgram;

--****************** 5. Compare queries to find the bottleneck ***************
go
CREATE VIEW vRegister
AS SELECT *
FROM Register AS R
	INNER JOIN Course AS C
		ON R.courseRegister = C.codeCourse
	INNER JOIN Program AS P
		ON R.progRegister = P.kodProgram
;

SELECT * FROM vRegister;

-- 1
SELECT * FROM vRegister;

-- 2
SELECT codeCourse
FROM vRegister
WHERE instRegister = 'TAPS'
;

-- 3
SELECT progRegister, codeCourse, SUM(hstkRegister) AS hstk
FROM vRegister
WHERE instRegister = 'TAPS'
GROUP BY progRegister, codeCourse
ORDER BY progRegister
;

--****************** 6. Evaluate the performance in previous labs ****************** 
--In the lab, "Programming a DBMS", there were a set of queries in the last section. Take all those queries and show the queryplan for them. 
--Pinpoint the one that has the "worst" performance.

SELECT dv1454_ht14_d_7.FCalcLatu_work_hours(hoursCourseBudgetElements,factorCourseElementtypes) AS Lätusum FROM CourseBudgetElements,CourseElementTypes where
CourseBudgetElements.CourseBudgetElements_nameCourseElementTypes = CourseElementTypes.nameCourseElementTypes;
--esc 0,01

select CourseBudget.idCourseBudget,CourseElementTypes.nameCourseElementTypes as Moment,
CourseElementTypes.descriptionCourseElementTypes,
CourseBudgetElements.CourseBudgetElements_akronymPersonnel,
CourseBudgetElements.hoursCourseBudgetElements,
CourseElementTypes.factorCourseElementtypes as Factor,
dv1454_ht14_d_7.FCalcLatu(hoursCourseBudgetElements,factorCourseElementtypes,numStudentsCourseBudget) as Lätusum,
nameCourse as CourseName
from CourseElementTypes,CourseBudgetElements,CourseBudget, Courses 
where CourseBudgetElements.CourseBudgetElements_nameCourseElementTypes = CourseElementTypes.nameCourseElementTypes
and CourseBudgetElements.CourseBudgetElements_idCourseBudget=CourseBudget.idCourseBudget 
and CourseBudget.CourseBudget_idCourse =Courses.idCourse order by Lätusum desc;
--esc 0,04688

select * from VTeacherPlanned;
--esc 0,0258097

select * from VTeacherWork;
--esc 0,0360074

select * from CourseElementTypes;
--esc 0,0032886

select VTeacherPlanned.Name,VTeacherWork.SupposedWorkHours,VTeacherPlanned.Lätusum,VTeacherPlanned.Lätusum-VTeacherWork.SupposedWorkHours as OvertimeHours_plus_undertime_minus
from VTeacherPlanned,VTeacherWork 
where VTeacherPlanned.Name=VTeacherWork.Name;
--esc 0,0798627  
--THIS IS THE WORST ONE
-----------------------------

--UNDERSÖKNING:
----Investigate the query and propose actions to enhance the performance.--------------

-------------------------------------------------------------------------------------
--Avsnitt 1.
drop INDEX CourseBudgetElements.i_CourseBudgetElements_nameCourseElementTypes;
drop INDEX CourseElementTypes.i_nameCourseElementTypes;
drop INDEX CourseBudgetElements.i_CourseBudgetElements_idCourseBudget;
drop INDEX CourseBudget.i_idCourseBudget;
drop INDEX Personnel.i_akronymPersonnel;

--drop view VTeacherPlanned;
CREATE CLUSTERED INDEX i_CourseBudgetElements_idCourseBudget ON CourseBudgetElements (CourseBudgetElements_idCourseBudget);
--Cannot create more than one clustered index on table 'CourseBudgetElements'.

CREATE CLUSTERED INDEX i_CourseBudgetElements_nameCourseElementTypes ON CourseBudgetElements (CourseBudgetElements_nameCourseElementTypes);
--Cannot create more than one clustered index on table 'CourseBudgetElements'.

CREATE CLUSTERED INDEX i_nameCourseElementTypes ON CourseElementTypes (nameCourseElementTypes);
--Failed, Cannot create more than one clustered index on table 'CourseElementTypes'.

CREATE CLUSTERED INDEX i_idCourseBudget ON CourseBudget (idCourseBudget);
--Cannot create more than one clustered index on table 'CourseBudget'.

CREATE CLUSTERED INDEX i_akronymPersonnel ON Personnel (akronymPersonnel);
--Cannot create more than one clustered index on table 'Personnel'.

CREATE CLUSTERED INDEX i_CourseBudgetElements_akronymPersonnel ON CourseBudgetElements (CourseBudgetElements_akronymPersonnel);
--Cannot create more than one clustered index on table 'CourseBudgetElements'.

--ACTION: DET GÅR INTE ATT GÖRA NÅGRA KLUSTERED INDEX för VTeacherPlanned

go
create view VTeacherPlanned as select 
namePersonnel as Name, sum(dv1454_ht14_d_7.FCalcLatu_work_hours(hoursCourseBudgetElements,factorCourseElementtypes)) as Lätusum from 
CourseBudgetElements,CourseElementTypes,CourseBudget,Personnel where 
CourseBudgetElements.CourseBudgetElements_nameCourseElementTypes = CourseElementTypes.nameCourseElementTypes and
CourseBudgetElements.CourseBudgetElements_idCourseBudget=CourseBudget.idCourseBudget and
Personnel.akronymPersonnel=CourseBudgetElements.CourseBudgetElements_akronymPersonnel
group by Personnel.namePersonnel;
go
select * from VTeacherPlanned;
--esc 0,0232266

drop INDEX CourseBudgetElements.i_CourseBudgetElements_nameCourseElementTypes;
drop INDEX CourseElementTypes.i_nameCourseElementTypes;
drop INDEX CourseBudgetElements.i_CourseBudgetElements_idCourseBudget;
drop INDEX CourseBudget.i_idCourseBudget;
drop INDEX Personnel.i_akronymPersonnel;

--drop view VTeacherPlanned;
CREATE NONCLUSTERED INDEX i_CourseBudgetElements_idCourseBudget ON CourseBudgetElements (CourseBudgetElements_idCourseBudget);
--OK

CREATE NONCLUSTERED INDEX i_CourseBudgetElements_nameCourseElementTypes ON CourseBudgetElements (CourseBudgetElements_nameCourseElementTypes);
--OK

CREATE NONCLUSTERED INDEX i_nameCourseElementTypes ON CourseElementTypes (nameCourseElementTypes);
--OK

CREATE NONCLUSTERED INDEX i_idCourseBudget ON CourseBudget (idCourseBudget);
--OK

CREATE NONCLUSTERED INDEX i_akronymPersonnel ON Personnel (akronymPersonnel);
--OK


--ACTION: DET GÅR ATT GÖRA NONKLUSTERED INDEX för VTeacherPlanned

go
create view VTeacherPlanned as select 
namePersonnel as Name, sum(dv1454_ht14_d_7.FCalcLatu_work_hours(hoursCourseBudgetElements,factorCourseElementtypes)) as Lätusum from 
CourseBudgetElements,CourseElementTypes,CourseBudget,Personnel where 
CourseBudgetElements.CourseBudgetElements_nameCourseElementTypes = CourseElementTypes.nameCourseElementTypes and
CourseBudgetElements.CourseBudgetElements_idCourseBudget=CourseBudget.idCourseBudget and
Personnel.akronymPersonnel=CourseBudgetElements.CourseBudgetElements_akronymPersonnel
group by Personnel.namePersonnel;
go
select * from VTeacherPlanned;
--esc 0,032266  , ingen skillnad

--------------------------------------------------------------------------------------------
--Avnsitt 2.

--drop view VTeacherWork;
go
create view VTeacherWork as select distinct(Personnel.namePersonnel) as Name,
dv1454_ht14_d_7.FCalculateServiceHours(servicegradePersonnel,age) AS SupposedWorkHours from Personnel,
Department,
VTeacherAge where 
Personnel.Personnel_idDepartment=Department.idDepartment and
Personnel.namePersonnel=VTeacherAge.namePersonnel;
go
select * from VTeacherWork;
--esc 0,0360074


CREATE CLUSTERED INDEX i_Personnel_idDepartment ON Personnel (Personnel_idDepartment);
--Cannot create more than one clustered index on table 'Personnel'.

CREATE CLUSTERED INDEX i_idDepartment ON Department (idDepartment);
--Cannot create more than one clustered index on table 'Department'.

CREATE CLUSTERED INDEX i_namePersonnel ON Personnel (namePersonnel);
--Cannot create more than one clustered index on table 'Personnel'.

CREATE CLUSTERED INDEX i_namePersonnel ON VTeacherAge (namePersonnel);
--Cannot create index on view 'VTeacherAge' because the view is not schema bound.

drop INDEX Personnel.i_Personnel_idDepartment;
drop INDEX Department.i_idDepartment;
drop INDEX Personnel.i_namePersonnel;


CREATE NONCLUSTERED INDEX i_Personnel_idDepartment ON Personnel (Personnel_idDepartment);
--OK, men tiden förbättrades inte

CREATE NONCLUSTERED INDEX i_idDepartment ON Department (idDepartment);
--OK, men tiden förbättrades inte

CREATE NONCLUSTERED INDEX i_namePersonnel ON Personnel (namePersonnel);
--OK, tiden förbättras.

CREATE NONCLUSTERED INDEX i_namePersonnel ON VTeacherAge (namePersonnel);
--Cannot create index on view 'VTeacherAge' because the view is not schema bound.

--drop view VTeacherWork;
go
create view VTeacherWork as select distinct(Personnel.namePersonnel) as Name,
dv1454_ht14_d_7.FCalculateServiceHours(servicegradePersonnel,age) AS SupposedWorkHours from Personnel,
Department,
VTeacherAge where 
Personnel.Personnel_idDepartment=Department.idDepartment and
Personnel.namePersonnel=VTeacherAge.namePersonnel;
go
select * from VTeacherWork;
--esc 0,0228727

select VTeacherPlanned.Name,VTeacherWork.SupposedWorkHours,VTeacherPlanned.Lätusum,VTeacherPlanned.Lätusum-VTeacherWork.SupposedWorkHours as OvertimeHours_plus_undertime_minus
from VTeacherPlanned,VTeacherWork 
where VTeacherPlanned.Name=VTeacherWork.Name;
--esc 0,0658974

CREATE CLUSTERED INDEX i_Name ON VTeacherPlanned (Name);
--Fails,Cannot create index on view 'VTeacherPlanned' because the view is not schema bound.

---------------------------------------------------------------------------------------------
--Avsnitt 3.

--Finns det index på foreign keys på de tabeller som ingår i view VTeacherPlanned och VTeacherWork.
--Foreign keys för VTeacherPlanned är:

--Table CourseBudgetElements
CourseBudgetElements_idCourseBudget INT NOT NULL,
FOREIGN KEY (CourseBudgetElements_idCourseBudget) REFERENCES CourseBudget(idCourseBudget),
CourseBudgetElements_nameCourseElementTypes CHAR(2) NOT NULL,
--Här finns det index på foreign key.
FOREIGN KEY (CourseBudgetElements_nameCourseElementTypes) REFERENCES CourseElementTypes(nameCourseElementTypes),
CourseBudgetElements_akronymPersonnel CHAR(3) NOT NULL,
--Här finns det index på foreign key.
FOREIGN KEY (CourseBudgetElements_akronymPersonnel) REFERENCES Personnel(akronymPersonnel),
--Här finns det inte index på foreign key.
 
--Table CourseElementTypes har inga foreign keys.

--Table CourseBudget
CourseBudget_idCourse INT NOT NULL,
FOREIGN KEY (CourseBudget_idCourse) REFERENCES Courses(idCourse),
--Här finns det index på foreign key.
CourseBudget_idDepartment INT NOT NULL,
FOREIGN KEY (CourseBudget_idDepartment) REFERENCES Department(idDepartment),
--Här finns det index på foreign key.

--Table Personnel har inga foreign keys.

--Table Department har inga foreign keys.

--Det är bara Personnel(akronymPersonnel) som inte har något index..
-------------------------------------------
--RESULTAT AV UNDERSÖKNINGEN.
Jag fick ner tiden från --esc 0,0798627 till esc 0,0658974 på min värsta query som var  
select VTeacherPlanned.Name,VTeacherWork.SupposedWorkHours,VTeacherPlanned.Lätusum,VTeacherPlanned.Lätusum-VTeacherWork.SupposedWorkHours as OvertimeHours_plus_undertime_minus
from VTeacherPlanned,VTeacherWork 
where VTeacherPlanned.Name=VTeacherWork.Name;

--Jag fick ner tiderna genom att alltid använda index på de foreign keys som fanns  
--Det enda stället som jag såg där index saknades på foreign key var för  ( se avsnitt 3. ovan)
--CourseBudgetElements.FOREIGN KEY (CourseBudgetElements_akronymPersonnel) REFERENCES Personnel(akronymPersonnel),

--Jag provade att sätta CLUSTERED INDEX men det gick inte (Se avsnitt 1. och avsnitt 2. ovan)

--Jag provade att skapa NONCLUSTERED INDEX på VTeacherWork med  
CREATE NONCLUSTERED INDEX i_namePersonnel ON Personnel (namePersonnel);
--detta gjorde att jag fick ner tiderna.

--Det går förmodligen också att få ner tiderna genom att lägga till constraints när man lägger till PK och FK men
--det är inte något som jag har hunnit att undersöka.
