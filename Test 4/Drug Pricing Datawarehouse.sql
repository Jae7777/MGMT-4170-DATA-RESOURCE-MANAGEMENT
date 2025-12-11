-------------------------
-- Drug Pricing Data Warehouse
-------------------------
USE DrugPricing
GO

-------------------------
-- Dropping Tables
-------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('CustomerSurveyStaging') AND type in (N'U'))
DROP TABLE CustomerSurveyStaging
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('CustomerSurveyODS') AND type in (N'U'))
DROP TABLE CustomerSurveyODS
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('factDrugPricing') AND type in (N'U'))
DROP TABLE factDrugPricing
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dimGender') AND type in (N'U'))
DROP TABLE dimGender
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dimQ1') AND type in (N'U'))
	DROP TABLE dimQ1
	GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dimQ2') AND type in (N'U'))
	DROP TABLE dimQ2
	GO	

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dimQ3') AND type in (N'U'))
	DROP TABLE dimQ3
	GO	

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimQ4]') AND type in (N'U'))
	DROP TABLE dimQ4
	GO	

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimQ5]') AND type in (N'U'))
	DROP TABLE dimQ5
	GO

-------------------------
-- CustomerSurveyStaging
-------------------------
CREATE TABLE CustomerSurveyStaging (
CustomerID int, 
Gender varchar(10), 
Income	varchar(100), 
StateAbbr varchar(3),
Q1	int, 
Q2	int,  
Q3	int, 
Q4	int,  
Q5	int, 
Q6   int, 
SurveyDate date
)

BULK INSERT CustomerSurveyStaging
FROM 'C:\Data\DrugPricing\CustomerSurvey.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0A' 
)

SELECT *
FROM CustomerSurveyStaging

-------------------------
-- Data Quality
-------------------------
-- Gender
SELECT DISTINCT Gender
FROM CustomerSurveyStaging

SELECT	Gender,
				CASE
					WHEN Gender IN ('man','ma', 'm') THEN 'M'
					WHEN Gender IN ('f','female') THEN 'F'
					ELSE 'U'
				END
FROM CustomerSurveyStaging

BEGIN TRAN

UPDATE	CustomerSurveyStaging
SET Gender =
				CASE
					WHEN Gender IN ('man','ma', 'm') THEN 'M'
					WHEN Gender IN ('f','female') THEN 'F'
					ELSE 'U'
				END

SELECT DISTINCT Gender
FROM CustomerSurveyStaging

COMMIT TRAN

--Income
SELECT Income
FROM CustomerSurveyStaging
WHERE Income LIKE '%DOLLAR%'

BEGIN TRAN

UPDATE CustomerSurveyStaging
SET Income =
	CASE 
		WHEN Income LIKE '"76' THEN '76'
		WHEN Income LIKE '"113' THEN '113'
		WHEN Income LIKE '93065 dollars' THEN '93065'
		ELSE Income
	END

COMMIT TRAN

-------------------------
-- CustomerSurveyODS
-------------------------

CREATE TABLE CustomerSurveyODS (
	CustomerID int, 
	Gender char(1),
	StateAbbr	char(2),
	Income money, 
	Q1	int , 
	Q2	int , 
	Q3	int , 
	Q4	int , 
	Q5	int , 
	Q6	money, 
	SurveyDate DATE
)

INSERT INTO CustomerSurveyODS
	SELECT CustomerID, Gender, StateAbbr, Income, Q1, Q2	,Q3, Q4, Q5, Q6, SurveyDate
	FROM CustomerSurveyStaging

SELECT *
FROM CustomerSurveyODS

-------------------------
-- dimGender
-------------------------	



CREATE TABLE dimGender(
	GenderID int IDENTITY(1,1) NOT NULL
		CONSTRAINT PK_dimGender PRIMARY KEY CLUSTERED (GenderID),
	GenderDesc char(1) NOT NULL
)

INSERT INTO dimGender
VALUES
('M'),
('F'),
('U')

SELECT *
FROM dimGender

-------------------------
-- dimQ1
-------------------------	
CREATE TABLE dimQ1(
	Q1ID int NOT NULL,
		CONSTRAINT PK_Q1 PRIMARY KEY CLUSTERED(Q1ID),
	Q1Desc varchar(25)
)

INSERT INTO dimQ1
VALUES
(0, 'Not Applicable'),
(1, 'Not Satisfied'),
(2, 'Somwhat Satisfied'),
(3, 'Satisfied'),
(4,  'Very Satisfied'),
(5, 'Extremely Satisfied')

SELECT *
FROM dimQ1

-------------------------
-- dimQ2
-------------------------

CREATE TABLE dimQ2(
	Q2ID int NOT NULL
		CONSTRAINT PK_Q2 PRIMARY KEY CLUSTERED(Q2ID),
	Q2Desc varchar(25)
)

INSERT INTO dimQ2
VALUES
(0,	'Not Applicable'),
(1,	'No Impact'),
(2,	'Little Impact'),
(3,	'Some impact'),
(4,	'Frequent Impact'),
(5,	'Significant Impact')

SELECT *
FROM dimQ2


-------------------------
-- CustomerSurveyODS
-------------------------
CREATE TABLE dimQ3(
	Q3ID int NOT NULL,
		CONSTRAINT PK_Q3 PRIMARY KEY CLUSTERED(Q3ID),
	Q3Desc varchar(25)
)

INSERT INTO dimQ3
VALUES
(0,	'Not Applicable'),
(1,	'Not at all easy'),
(2,	'Somewhat easy'),
(3,	'Moderately easy'),
(4,	'Very easy'),
(5,	'Extremely easy')

SELECT *
FROM dimQ3

-------------------------
-- dimQ4
-------------------------


CREATE TABLE dimQ4(
	Q4ID int NOT NULL,
		CONSTRAINT PK_Q4 PRIMARY KEY CLUSTERED(Q4ID),
	Q4Desc varchar(25)
)

INSERT INTO dimQ4
VALUES
(0, 'Not applicable'),
(1,	'Little value'),
(2, 'Some value'),
(3,	'Moderate value'),
(4,	'A lot of value'),
(5,	'Extremely valuable')

SELECT *
FROM dimQ4
	
-------------------------
-- dimQ5
-------------------------
CREATE TABLE dimQ5(
	Q5ID int NOT NULL,
		CONSTRAINT PK_Q5 PRIMARY KEY CLUSTERED(Q5ID),
	Q5Desc varchar(50)
)

INSERT INTO dimQ5
VALUES
(0,	'I did not have to seek any medical attention'),
(1,	'1 time'),
(2,	'2-3 times'),
(3,	'4-6 times'),
(4,	'7-9 times'),
(5,	'Greater than 10 times')

-------------------------
-- factDrugPricing
-------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('factDrugPricing') AND type in (N'U'))
	DROP TABLE factDrugPricing
	GO

CREATE TABLE factDrugPricing(
	SurveyID int IDENTITY(1,1) NOT NULL
		CONSTRAINT PK_factDrugPricing PRIMARY KEY CLUSTERED (SurveyID),
	CustomerID varchar(6),
	GenderID int NOT NULL,
		CONSTRAINT FK_Gender FOREIGN KEY (GenderID)
		REFERENCES dimGender(GenderID),
	Income money,
	StateAbbr char(2),
	Q1 int NOT NULL,
		CONSTRAINT FK_Q1 FOREIGN KEY (Q1)
		REFERENCES dimQ1 (Q1ID),
	Q2 int NOT NULL,
		CONSTRAINT FK_Q2 FOREIGN KEY (Q2)
		REFERENCES dimQ2 (Q2ID),
	Q3 int NOT NULL,
		CONSTRAINT FK_Q3 FOREIGN KEY (Q3)
		REFERENCES dimQ3 (Q3ID),
	Q4 int NOT NULL,
		CONSTRAINT FK_Q4 FOREIGN KEY (Q4)
		REFERENCES dimQ4 (Q4ID), 
	Q5 int NOT NULL,
		CONSTRAINT FK_Q5 FOREIGN KEY (Q5)
		REFERENCES dimQ5 (Q5ID),
	Q6 money,
	SurveyDate date,
)

INSERT INTO factDrugPricing
SELECT	CustomerID,
		Gender = 
			CASE
				WHEN Gender = 'F' THEN 1
				WHEN Gender = 'M' THEN 2
				ELSE 3
			END,
		Income,
		StateAbbr,
		Q1,
		Q2 ,
		Q3,
		Q4,
		Q5,
		Q6,
		SurveyDate
FROM CustomerSurveyODS

SELECT *
FROM factDrugPricing
