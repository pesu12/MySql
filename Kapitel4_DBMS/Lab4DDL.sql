--
-- Lab Directories of Studies (DoS)
--

--
-- Table for department, department names and
-- belongings usually changes within a 3-year period.
--
use dv1454_ht14_d_7;
DROP TABLE CourseBudgetElements;
DROP TABLE CourseElementTypes;
DROP TABLE CourseBudget;
DROP TABLE Courses;
DROP TABLE Personnel;
DROP TABLE Department;


CREATE TABLE Department
(
    idDepartment INT IDENTITY(1,1) NOT NULL,
    nameDepartment CHAR(3) NOT NULL UNIQUE,
    infoDepartment VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (idDepartment)
);

INSERT INTO Department VALUES ('APS', 'Programvaruteknik och Datavetenskap');
INSERT INTO Department VALUES ('AIS', 'Informationssystem och Data människa interaktion');
INSERT INTO Department VALUES ('MAM', 'Ekonomi och management');

SELECT * FROM Department;

--
-- Create a table for personal who belongs to a department
--
-- DROP TABLE Personnel;

CREATE TABLE Personnel
(
    -- Primary key
    idPersonnel INT IDENTITY(1,1) NOT NULL,
    PRIMARY KEY (idPersonnel),

    -- Foreign key
    Personnel_idDepartment INT NOT NULL,
    FOREIGN KEY (Personnel_idDepartment) REFERENCES Department(idDepartment),

    -- Attributes
    namePersonnel CHAR(40) NOT NULL DEFAULT 'No Name',
    akronymPersonnel CHAR(3) NOT NULL UNIQUE,
    birthdatePersonnel DATETIME NOT NULL,
    servicegradePersonnel INT NOT NULL DEFAULT 100,
    salaryPerHourPersonnal MONEY NOT NULL,
)
DELETE FROM Personnel;

INSERT INTO Personnel VALUES (1, 'Mikael Roos', 'MOS', '1968-03-07', 100, 999)
INSERT INTO Personnel VALUES (1, 'Charlie Svanberg', 'CSA', '1970-04-15', 100, 222)
INSERT INTO Personnel VALUES (1, 'Göran Fries', 'GFR', '1954-10-01', 75, 777)
INSERT INTO Personnel VALUES (2, 'Mats-Ola Landin', 'MOL', '1969-12-12', 100, 333)
INSERT INTO Personnel VALUES (2, 'Betty Bergström', 'BBE', '1971-06-23', 80, 444)
INSERT INTO Personnel VALUES (3, 'Anders Nilssson', 'ANI', '1959-01-30', 50, 555)

SELECT * FROM Personnel;

--
-- Course elements
--
-- DROP TABLE CourseElementTypes

CREATE TABLE CourseElementTypes
(
    -- Primary key
    nameCourseElementTypes CHAR(2) NOT NULL,  
    PRIMARY KEY (nameCourseElementTypes),

    -- Attributes
    descriptionCourseElementTypes VARCHAR(40) NOT NULL,
    factorCourseElementtypes FLOAT NOT NULL
)

INSERT INTO CourseElementTypes VALUES ('KA', 'Course responsible', 5);
INSERT INTO CourseElementTypes VALUES ('LE', 'Lectures', 4);
INSERT INTO CourseElementTypes VALUES ('SE', 'Seminar', 3);
INSERT INTO CourseElementTypes VALUES ('LA', 'Laboratory', 2.5);
INSERT INTO CourseElementTypes VALUES ('TE', 'Written exam', 8);
INSERT INTO CourseElementTypes VALUES ('TR', 'Correct exam', 1);

SELECT * FROM CourseElementTypes;

--
-- Courses
--
-- DROP TABLE Courses;

CREATE TABLE Courses
(
    -- Primary key
    idCourse INT IDENTITY(1, 1) NOT NULL,
    PRIMARY KEY(idCourse),

    -- Alt key
    kodCourse CHAR(6) UNIQUE,

    -- Attributes
    nameCourse VARCHAR(100) NOT NULL,
    pointsCourse DECIMAL(3,1) NOT NULL,
    descriptionCourse Varchar(100) NOT NULL
);

INSERT INTO Courses VALUES ('DV1201', 'Database technique', 7.5, 'Everything about databases');
INSERT INTO Courses VALUES ('DV1209', 'C++ programming', 7.5, 'Beginners level programming course')
INSERT INTO Courses VALUES ('DV1104', 'OO analys and design', 7.5, 'How to write UML-diagrams')
INSERT INTO Courses VALUES ('PA1102', 'Individual Software Engineering Project', 7.5, 'How to program and deliver')
INSERT INTO Courses VALUES ('PA1201', 'Small Team Software Engineering Project', 15.0, 'How to program and deliver, step 2')
INSERT INTO Courses VALUES ('PA1302', 'Large Team Software Engineering Project', 30.0, 'How to program and deliver, the ultimate step')

SELECT * FROM Courses;

--
-- Course budget
--
-- DROP TABLE CourseBudget;

CREATE TABLE CourseBudget
(
    -- Primary key
    idCourseBudget INT IDENTITY(1,1) NOT NULL,
    PRIMARY KEY (idCourseBudget),

    -- Foreing key
    CourseBudget_idCourse INT NOT NULL,
    FOREIGN KEY (CourseBudget_idCourse) REFERENCES Courses(idCourse),

    CourseBudget_idDepartment INT NOT NULL,
    FOREIGN KEY (CourseBudget_idDepartment) REFERENCES Department(idDepartment),

    -- Atttributes
    budgetYearCourseBudget INT NOT NULL, 
    studyPeriodCourseBudget INT NOT NULL, 
    locationCourseBudget CHAR(3) NOT NULL,
    languageCourseBudget CHAR(2) NOT NULL,
    numStudentsCourseBudget INT NOT NULL
);

INSERT INTO CourseBudget VALUES (1, 1, 2008, 1, 'Rby', 'Sv', 30);
INSERT INTO CourseBudget VALUES (1, 2, 2008, 1, 'Kna', 'Sv', 15);
INSERT INTO CourseBudget VALUES (2, 1, 2008, 1, 'Rby', 'En', 22);
INSERT INTO CourseBudget VALUES (2, 1, 2008, 2, 'Khm', 'En', 29);
INSERT INTO CourseBudget VALUES (3, 2, 2009, 3, 'Rby', 'Sv', 68);

SELECT* FROM CourseBudget;

--
-- Create each course element for a course budget
--
-- DROP TABLE CourseBudgetElements;

CREATE TABLE CourseBudgetElements
(
    -- Primary key
    idCourseBudgetElements INT IDENTITY(1,1) NOT NULL,
    PRIMARY KEY(idCourseBudgetElements),

    -- Foreing key
    CourseBudgetElements_idCourseBudget INT NOT NULL,
    FOREIGN KEY (CourseBudgetElements_idCourseBudget) REFERENCES CourseBudget(idCourseBudget),

    CourseBudgetElements_nameCourseElementTypes CHAR(2) NOT NULL,
    FOREIGN KEY (CourseBudgetElements_nameCourseElementTypes) REFERENCES CourseElementTypes(nameCourseElementTypes),

    CourseBudgetElements_akronymPersonnel CHAR(3) NOT NULL,
    FOREIGN KEY (CourseBudgetElements_akronymPersonnel) REFERENCES Personnel(akronymPersonnel),

    -- Attribute
    hoursCourseBudgetElements INT NOT NULL
);

-- SELECT * FROM CourseBudgetElements;
-- DELETE FROM CourseBudgetElements;

INSERT INTO CourseBudgetElements VALUES (1, 'KA', 'MOS', 5);
INSERT INTO CourseBudgetElements VALUES (1, 'LE', 'MOS', 26);
INSERT INTO CourseBudgetElements VALUES (1, 'LA', 'CSA', 16);
INSERT INTO CourseBudgetElements VALUES (1, 'TE', 'MOS', 1);
INSERT INTO CourseBudgetElements VALUES (1, 'TR', 'MOS', 1);
INSERT INTO CourseBudgetElements VALUES (2, 'KA', 'MOL', 5);
INSERT INTO CourseBudgetElements VALUES (2, 'LE', 'GFR', 20);
INSERT INTO CourseBudgetElements VALUES (2, 'SE', 'MOL', 10);
INSERT INTO CourseBudgetElements VALUES (2, 'LA', 'GFR', 15);
INSERT INTO CourseBudgetElements VALUES (3, 'KA', 'CSA', 5);
INSERT INTO CourseBudgetElements VALUES (3, 'LE', 'CSA', 26);
INSERT INTO CourseBudgetElements VALUES (3, 'LA', 'MOS', 10);
INSERT INTO CourseBudgetElements VALUES (3, 'TE', 'GFR', 1);
INSERT INTO CourseBudgetElements VALUES (3, 'TR', 'GFR', 1);
INSERT INTO CourseBudgetElements VALUES (4, 'KA', 'MOL', 5);
INSERT INTO CourseBudgetElements VALUES (4, 'LE', 'GFR', 20);
INSERT INTO CourseBudgetElements VALUES (4, 'SE', 'MOL', 10);
INSERT INTO CourseBudgetElements VALUES (4, 'LA', 'GFR', 15);
INSERT INTO CourseBudgetElements VALUES (5, 'KA', 'CSA', 5);
INSERT INTO CourseBudgetElements VALUES (5, 'LE', 'CSA', 26);
INSERT INTO CourseBudgetElements VALUES (5, 'LA', 'MOS', 10);
INSERT INTO CourseBudgetElements VALUES (5, 'TE', 'GFR', 1);
INSERT INTO CourseBudgetElements VALUES (5, 'TR', 'GFR', 1);

SELECT * FROM CourseBudgetElements;



