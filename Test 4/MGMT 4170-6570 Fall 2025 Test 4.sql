USE Drug
GO


-- dimGeography
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dimGeography') AND type in (N'U'))
DROP TABLE dimGeography
GO



BULK INSERT dimGeography
FROM 'C:\Data\DrugPricing\dimGeography.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0A' 
)


select *
from dimGeography
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
FROM 'C:\Data\DrugPricing\Prognosis.txt'
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
FROM 'C:\Data\DrugPricing\Physician.csv'
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
FROM 'C:\Data\DrugPricing\SalesData.txt'
WITH (
    FIRSTROW = 2,           
    FIELDTERMINATOR = '\t',   
    ROWTERMINATOR = '\n',   
    CODEPAGE = 'ACP'
);

select *
from factSales

-- Q1 What did the customer pay and what were they willing to pay?

-- Q2 if people paid what they were willing to pay, how much money would we make


-- that number seems high.  

-- Q3 What is the min and max customers paid
	--What is the min and max customers were willing to pay


-- Q4 the problem seems to be with q6 
--  delete any rows where q6 > 2500

-- Q5 what is the average customers are willing to pay by location using grouping sets.  
-- first group is state, then division, then region

-- Q6 What are customers willing to pay?  Pivot gender and condition

-- Q7 Is $1399 a reasonable price to charge?

