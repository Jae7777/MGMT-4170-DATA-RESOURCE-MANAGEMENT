-- Justin Chen
-- MGMT 4170 Fall 2025 Test 4
-- 12/11/2025

USE exam4
GO


-- dimGeography
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('GeographyStaging') AND type in (N'U'))
DROP TABLE GeographyStaging
GO

CREATE TABLE GeographyStaging (
    FIPS int,
    StateName varchar(50),
    StateAbbr varchar(2),
    DivisionName varchar(50),
    DivisionID int,
    RegionName varchar(50),
    RegionID int
)

BULK INSERT GeographyStaging
FROM 'C:\Users\Justin\Documents\GitHub\MGMT-4170-DATA-RESOURCE-MANAGEMENT\Test 4\dimGeography.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0A' 
)

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dimGeography') AND type in (N'U'))
DROP TABLE dimGeography
GO

CREATE TABLE dimGeography (
    StateAbbr varchar(2),
    State varchar(50),
    Division varchar(50),
    Region varchar(50),
    FIPS int
)

INSERT INTO dimGeography (StateAbbr, State, Division, Region, FIPS)
SELECT StateAbbr, StateName, DivisionName, RegionName, FIPS
FROM GeographyStaging

SELECT *
FROM dimGeography
------------------------------
-- ProviderPrognosis
----
--	 CustomerID int,
--	 ProviderID int,
--	 Condition varchar(50),
--	 PatientWeight int,
--	 Height int,
--	 Age int,
--	 Prognosis int
--)

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('ProviderPrognosis') AND type in (N'U'))
DROP TABLE ProviderPrognosis
GO

CREATE TABLE  ProviderPrognosis (
	 CustomerID int,
	 ProviderID int,
	 Condition varchar(50),
	 PatientWeight int,
	 Height int,
	 Age int,
	 Prognosis int
)

BULK INSERT ProviderPrognosis
FROM 'C:\Users\Justin\Documents\GitHub\MGMT-4170-DATA-RESOURCE-MANAGEMENT\Test 4\Prognosis.txt'
WITH (
    FIRSTROW = 2,           
    FIELDTERMINATOR = '\t',   
    ROWTERMINATOR = '\n',   
    CODEPAGE = 'ACP'
);

SELECT *
FROM ProviderPrognosis
------------------------------
-- PhysicianStaging
--
-- Create a staging called PhysicianStaging
--
-- Create a dimension table called dimPhysician.  
-- split the name into first and last name
------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('PhysicianStaging') AND type in (N'U'))
DROP TABLE PhysicianStaging
GO

CREATE TABLE PhysicianStaging (
	ProviderID int ,
	FullName varchar(50),
	Position char(10)
)

BULK INSERT PhysicianStaging
FROM 'C:\Users\Justin\Documents\GitHub\MGMT-4170-DATA-RESOURCE-MANAGEMENT\Test 4\Physician.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0A' 
)

SELECT *
FROM PhysicianStaging

------------------------------
-- dimPhysician
-- Create a dimension table called dimPhysician
-- split name into first and last
------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dimPhysician') AND type in (N'U'))
DROP TABLE dimPhysician
GO

CREATE TABLE dimPhysician (
	ProviderID int NOT NULL,
	FirstName varchar(50),
	LastName varchar(50),
	CONSTRAINT PK_dimPhysician PRIMARY KEY CLUSTERED (ProviderID)
)

INSERT INTO dimPhysician (ProviderID, FirstName, LastName)
SELECT 
	ProviderID,
	SUBSTRING(FullName, 1, CHARINDEX(' ', FullName) - 1),
	SUBSTRING(FullName, CHARINDEX(' ', FullName) + 1, LEN(FullName))
FROM PhysicianStaging

SELECT *
FROM dimPhysician;
					
------------------------------
-- dimCustomer
-- Create a dimension table called dimCustomer by inserting these columns from the CustomerSurveyODS and the Prognosis
------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dimCustomer') AND type in (N'U'))
DROP TABLE dimCustomer
GO

CREATE TABLE dimCustomer (
	CustomerID int NOT NULL, 
		CONSTRAINT PK_dimCustomer PRIMARY KEY CLUSTERED (CustomerID),
	ProviderID int,
	Gender char(1),
	FIPS int,
	Income money, 
	Condition varchar(20),
	PatientWeight int,
	Height int,
	Age int,
	Prognosis int
)

INSERT INTO dimCustomer
	SELECT distinct	p.CustomerID,
			ProviderID,
			Gender,
			StateAbbr = 
				CASE 
					WHEN CS.StateAbbr = G.StateAbbr THEN FIPS
				END,
			Income, 
			Condition,
			PatientWeight,
			Height,
			Age,
			Prognosis
	FROM  ProviderPrognosis p inner join CustomerSurveyODS cs on p.CustomerID = cs.customerid
							  INNER JOIN dimGeography g ON CS.STATEABBR = G.StateAbbr
					
SELECT *
FROM dimCustomer

------------------------------
-- dimDiagnosis
-- Create a dimension table called dimDiagnosis
------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dimDiagnosis') AND type in (N'U'))
	DROP TABLE dimDiagnosis
	GO
	
CREATE TABLE dimDiagnosis(
	DiagnosisID int NOT NULL,
	CONSTRAINT PK_Diagnosis PRIMARY KEY CLUSTERED(DiagnosisID),
	DiagnosisDesc varchar(25) NOT NULL
)

INSERT INTO dimDiagnosis
VALUES
(1, 'COPD'),
(2, 'Diabetes'),
(3, 'Heart Disease'),
(4, 'High Cholesterol'),
(5, 'Hypertension'),
(6, 'Cancer'),
(0, 'None')

SELECT *
FROM dimDiagnosis

------------------------------
-- dimPrognosis
-- Create a dimension table called dimPrognosis
------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dimPrognosis') AND type in (N'U'))
	DROP TABLE dimPrognosis
	GO

CREATE TABLE dimPrognosis(
	PrognosisID int NOT NULL,
		CONSTRAINT PK_Prognosis PRIMARY KEY CLUSTERED(PrognosisID),
	PrognosisDesc varchar(25) NOT NULL
)

INSERT INTO dimPrognosis
VALUES
(1, 'COPD'),
(2, 'Diabetes'),
(3, 'Heart Disease'),
(4, 'High Cholesterol'),
(5, 'Hypertension')

SELECT *
FROM dimPrognosis



-- Create  factSales with three columns: CustomerID (int),	PurchaseDate (date), and 	PricePaid(money)


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('factSales') AND type in (N'U'))
	DROP TABLE factSales
	GO

CREATE TABLE factSales(
	CustomerID int NOT NULL,
	PurchaseDate date,	
	PricePaid money
)


BULK INSERT factSales
FROM 'C:\Users\Justin\Documents\GitHub\MGMT-4170-DATA-RESOURCE-MANAGEMENT\Test 4\SalesData.txt'
WITH (
    FIRSTROW = 2,           
    FIELDTERMINATOR = '\t',   
    ROWTERMINATOR = '\n',   
    CODEPAGE = 'ACP'
);

select *
from factSales

-- Q1 What did the customer pay and what were they willing to pay?
SELECT fs.CustomerID, fs.PricePaid, cs.Q6 AS WillingToPay
FROM factSales fs
JOIN CustomerSurveyODS cs ON fs.CustomerID = cs.CustomerID

-- Q2 if people paid what they were willing to pay, how much money would we make
SELECT SUM(cs.Q6) AS TotalPotentialRevenue
FROM factSales fs
JOIN CustomerSurveyODS cs ON fs.CustomerID = cs.CustomerID

-- that number seems high.  

-- revenue difference
select SUM(cs.Q6) - SUM(fs.PricePaid) AS RevenueDifference
from factSales fs
join CustomerSurveyODS cs ON fs.CustomerID = cs.CustomerID


-- Q3 What is the min and max customers paid
	--What is the min and max customers were willing to pay
SELECT 
    MIN(fs.PricePaid) AS MinPaid, 
    MAX(fs.PricePaid) AS MaxPaid,
    MIN(cs.Q6) AS MinWillingToPay,
    MAX(cs.Q6) AS MaxWillingToPay
FROM factSales fs
JOIN CustomerSurveyODS cs ON fs.CustomerID = cs.CustomerID

--select * from factSales fs
--join CustomerSurveyODS cs ON fs.CustomerID = cs.CustomerID
--order by cs.Q6 desc

-- Q4 the problem seems to be with q6 
--  delete any rows where q6 > 2500
DELETE FROM CustomerSurveyODS
WHERE Q6 > 2500

-- Q5 what is the average customers are willing to pay by location using grouping sets.  
-- first group is state, then division, then region
SELECT 
    g.State,
    g.Division,
    g.Region,
    AVG(cs.Q6) AS AvgWillingToPay
FROM CustomerSurveyODS cs
JOIN dimGeography g ON cs.StateAbbr = g.StateAbbr
GROUP BY GROUPING SETS (
    (g.State),
    (g.Division),
    (g.Region)
)

-- Q6 What are customers willing to pay?  Pivot gender and condition
SELECT Condition, [M], [F], [U]
FROM (
    SELECT dc.Condition, dc.Gender, cs.Q6
    FROM dimCustomer dc
    JOIN CustomerSurveyODS cs ON dc.CustomerID = cs.CustomerID
) AS SourceTable
PIVOT (
    AVG(Q6)
    FOR Gender IN ([M], [F], [U])
) AS PivotTable

-- Q7 Is $1399 a reasonable price to charge?
SELECT 
    AVG(Q6) AS AvgWillingness,
    (COUNT(CASE WHEN Q6 >= 1399 THEN 1 END) * 100.0 / COUNT(*)) AS PercentWillingToPay1399,
	CASE 
		WHEN (COUNT(CASE WHEN Q6 >= 1399 THEN 1 END) * 100.0 / COUNT(*)) >= 98 THEN 'Yes'
		ELSE 'No'
	END AS [Should Charge]
FROM CustomerSurveyODS

-- 98% willing to pay is the threshold i defined as a good price. why? because an alternate reality where 50% of people can't comfortably pay their medical and health care is a harrowing thought
-- (us stat: Around 51% of U.S. adults can currently afford and access quality healthcare).