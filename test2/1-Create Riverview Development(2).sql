/*----------------------------------------------
--	RiverviewDev Scripts
--
-- Author: Jonathan McKinney
-- Date: 9/22/25
-- Version 1.0
-------------------------------------------------

Before you start building the application, research the clinic and understand how they do business
https://riverviewveterinary.com/

Understand their business processes, compare them to the processes you see in the database, and do a Gap Analysis

-- Create RiverviewDev database from SSMS
-- Always include connecting to a database in the beginning of your script
-- otherwise you may create the objects in the wrong database
*/

USE RiverviewDev
GO

----------------------------------------------------------
-- Create RiverviewDev Database using SSMS
----------------------------------------------------------

-- Connect to RiverviewDev database
USE RiverviewDev
GO

/*
Create two sets of tables: Staging and Dev
Staging tables are to load the data, Dev tables are to build the objects that will eventually be migrated to production
*/

-- If they exist, drop the RiverviewDev Staging tables
PRINT 'Dropping Riverview Staging tables'
PRINT '---------------------------------'
PRINT ''

-- If the BillingStaging table exists, drop it
PRINT 'Dropping BillingStaging table'

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'BillingStaging') AND type in (N'U'))
	DROP TABLE  BillingStaging 
GO

-- If the VisitStaging table exists, drop it
PRINT 'Dropping VisitStaging table'

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'VisitStaging') AND type in (N'U'))
	DROP TABLE  VisitStaging 
GO

-- If the AnimalStaging table exists, drop it
PRINT 'Dropping AnimalStaging table'

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'AnimalStaging') AND type in (N'U'))
	DROP TABLE  AnimalStaging  
GO

-- If the OwnerStaging table exists, drop it
PRINT 'Dropping OwnerStaging  table'

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'OwnerStaging') AND type in (N'U'))
	DROP TABLE OwnerStaging  
GO


-------------------------------------------------
-- Creating Staging Tables
-------------------------------------------------
/*
Before you decide how to build the staging tables
- Open the CSV files in determine the largest field
- If you think this is the largest value, set the size to this value
- If you think otherwise, make it large enough to fit future data
- Import everything as a character initially
*/

-------------------------------------------------
--OwnerStaging
-------------------------------------------------
/*
Notice that Address and State are color-coded blue.  This means they are also SQL reserve words.
*/
-- Create the OwnerStaging table
PRINT 'Creating OwnerStaging table'

CREATE TABLE dbo.OwnerStaging(
	OwnerID int NOT NULL
		CONSTRAINT PK_OwnerStaging PRIMARY KEY CLUSTERED (OwnerID),
	FirstName varchar(50) NULL,
	LastName varchar(50) NULL,
	Phone varchar(50) NULL,
	StreetAddress varchar(50) NULL,
	City varchar(50) NULL,
	StateAbbr varchar(50) NULL,
	Zip varchar(50) NULL,
	Email varchar(50) NULL
) 
-------------------------------------------------
-- Load OwnerStaging data
-------------------------------------------------

PRINT 'Loading OwnerStaging table'

BULK INSERT OwnerStaging
FROM 'C:\Data\Riverview\OwnerProductionData.csv'
WITH
(
	FORMAT = 'CSV',
	FIRSTROW = 2              -- skip header
    --FIELDTERMINATOR = ',',        -- comma-delimited
    --ROWTERMINATOR = '\n',         -- or '\r\n' if needed
    --FIELDQUOTE = '"' ,            -- handle quoted fields (SQL 2017+)
    --CODEPAGE = '65001',           -- if UTF-8
    --TABLOCK
)

 
 --	Verify load
 PRINT 'Verifying OwnerStaging   table'

SELECT *
FROM OwnerStaging

-------------------------------------------------
-- AnimalStaging
-------------------------------------------------

-- Create AnimalStaging   table
 PRINT 'Creating AnimalStaging   table'

CREATE TABLE dbo.AnimalStaging(
	AnimalID int NOT NULL
			CONSTRAINT PK_AnimalStaging PRIMARY KEY CLUSTERED (AnimalID),
	OwnerID int NOT NULL
		CONSTRAINT FK_OwnerStagingAnimalStaging FOREIGN KEY  (OwnerID)
		REFERENCES OwnerStaging(OwnerID) ON DELETE CASCADE,
	AnimalName varchar(50) NULL,
	AnimalType varchar(50) NULL,
	AnimalBreed varchar(50) NULL,
	AnimalBirthDate varchar(50) NULL
) 

---- Load AnimalStaging  table
PRINT 'Loading AnimalStaging   table'

BULK INSERT AnimalStaging
FROM 'C:\Data\Riverview\AnimalProductionData.csv'
WITH
(
	FORMAT = 'CSV',
	FIRSTROW = 2
)
 
 -- Verify load
PRINT 'Verifying AnimalStaging   table'

SELECT *
FROM AnimalStaging  

-------------------------------------------------
--VisitStaging
-------------------------------------------------

CREATE TABLE dbo.VisitStaging (
    VisitID        int IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Visits PRIMARY KEY,
    AnimalID       int               NOT NULL,
    VisitDate      date              NOT NULL,
    Reason  nvarchar(200)     NULL,
	    CONSTRAINT FK_AnimalStagin_VisitStaging
        FOREIGN KEY (AnimalID) REFERENCES dbo.AnimalStaging(AnimalID)
)
--truncate table visitstaging
DECLARE @StartDate date = '2017-01-10';

WITH Tally AS (SELECT n FROM (VALUES(1),(2),(3)) AS v(n))  -- up to 3 visits/animal
INSERT dbo.VisitStaging (AnimalID, VisitDate, Reason)
SELECT
    p.AnimalID,
    DATEADD(day,
            ABS(CHECKSUM(NEWID())) % (DATEDIFF(day, @StartDate, GETDATE()) + 1),
            @StartDate) AS VisitDate,
    CHOOSE(1 + ABS(CHECKSUM(NEWID())) % 12,
           N'Annual wellness exam',
           N'Vaccination due',
           N'Coughing / sneezing',
           N'Skin irritation / itching',
           N'Ear shaking or odor',
           N'Limping',
           N'Vomiting / diarrhea',
           N'Dental cleaning',
           N'New pet check-up',
           N'Behavior concern',
           N'Eye discharge',
           N'Weight loss / gain') AS Reason
FROM dbo.AnimalStaging AS p
CROSS APPLY (SELECT 1 + ABS(CHECKSUM(NEWID())) % 3 AS VisitCount) AS c
JOIN Tally t ON t.n <= c.VisitCount;

select * from VisitStaging

-------------------------------------------------
--BillingStaging
-------------------------------------------------

-- Create BillingStaging   table
PRINT 'Creating BillingStaging   table' 
-- Invoices/Billing

CREATE TABLE dbo.BillingStaging (
    InvoiceID        int IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Invoices PRIMARY KEY CLUSTERED (InvoiceID),
    VisitID          int               NOT NULL,
    InvoiceItem      nvarchar(100)     NOT NULL,
    InvoiceDate      date              NOT NULL,
    InvoiceAmount    decimal(10,2)     NOT NULL,
    PartialPayment   decimal(10,2)     NOT NULL 
        CONSTRAINT DF_Invoices_PartialPayment DEFAULT (0),

    -- Computed columns
    AmountOwed AS (
        CASE 
            WHEN (InvoiceAmount - PartialPayment) > 0 
                THEN CONVERT(decimal(10,2), (InvoiceAmount - PartialPayment))
            ELSE CONVERT(decimal(10,2), 0.00)
        END
    ) PERSISTED,

    PaidInFull AS (
        CONVERT(bit, CASE WHEN (InvoiceAmount - PartialPayment) <= 0 THEN 1 ELSE 0 END)
    ) PERSISTED,
        CONSTRAINT FK_BillingStaging_VisitStaging FOREIGN KEY (VisitID) 
        REFERENCES dbo.VisitStaging(VisitID),

    -- Basic data quality checks
    CONSTRAINT CK_Invoices_Amounts_NonNegative 
        CHECK (InvoiceAmount >= 0 AND PartialPayment >= 0),
    CONSTRAINT CK_Invoices_AmountVsPayment_Reasonable
        CHECK (PartialPayment <= InvoiceAmount * 2)  -- guard against wild inputs
);


    -- Map visit reasons to invoice items & base prices; randomize partial payments
;WITH PriceMap AS (
    SELECT v.VisitID,
           v.VisitDate,
           CASE v.Reason
              WHEN N'Annual wellness exam'      THEN N'Wellness Exam'
              WHEN N'Vaccination due'           THEN N'Vaccination'
              WHEN N'Coughing / sneezing'       THEN N'Illness Exam'
              WHEN N'Skin irritation / itching' THEN N'Dermatology Consult'
              WHEN N'Ear shaking or odor'       THEN N'Otitis Treatment'
              WHEN N'Limping'                    THEN N'Lameness Exam'
              WHEN N'Vomiting / diarrhea'       THEN N'GI Workup'
              WHEN N'Dental cleaning'           THEN N'Dental Prophylaxis'
              WHEN N'New pet check-up'          THEN N'New Patient Exam'
              WHEN N'Behavior concern'          THEN N'Behavior Consult'
              WHEN N'Eye discharge'             THEN N'Ophthalmic Exam'
              WHEN N'Weight loss / gain'        THEN N'Weight Evaluation'
              ELSE                                   N'General Examination'
           END AS InvoiceItem,
           CASE v.Reason
              WHEN N'Annual wellness exam'      THEN  95.00
              WHEN N'Vaccination due'           THEN  65.00
              WHEN N'Coughing / sneezing'       THEN 115.00
              WHEN N'Skin irritation / itching' THEN 135.00
              WHEN N'Ear shaking or odor'       THEN 120.00
              WHEN N'Limping'                    THEN 140.00
              WHEN N'Vomiting / diarrhea'       THEN 160.00
              WHEN N'Dental cleaning'           THEN 275.00
              WHEN N'New pet check-up'          THEN  85.00
              WHEN N'Behavior concern'          THEN 150.00
              WHEN N'Eye discharge'             THEN 110.00
              WHEN N'Weight loss / gain'        THEN  90.00
              ELSE                                   100.00
           END AS BasePrice
    FROM dbo.VisitStaging AS v
),
WithAmounts AS (
    SELECT  pm.VisitID,
            pm.InvoiceItem,
            -- Add a small random +/- to base price (0–20):
            pm.BasePrice + (ABS(CHECKSUM(NEWID())) % 21) AS InvoiceAmount,
            -- Pick partial payment: 0%, 25%, 50%, 100% (random)
            CASE ABS(CHECKSUM(NEWID())) % 4
                WHEN 0 THEN 0.00
                WHEN 1 THEN ROUND((pm.BasePrice * 0.25), 2)
                WHEN 2 THEN ROUND((pm.BasePrice * 0.50), 2)
                ELSE      pm.BasePrice + 0.00  -- paid in full (or overage rounded down by computed col)
            END AS PartialPayment,
            -- Invoice date within 0–14 days after visit
            DATEADD(day, ABS(CHECKSUM(NEWID())) % 15, pm.VisitDate) AS InvoiceDate
    FROM PriceMap pm
)
INSERT dbo.BillingStaging(VisitID, InvoiceItem, InvoiceDate, InvoiceAmount, PartialPayment)
SELECT VisitID, InvoiceItem, InvoiceDate, InvoiceAmount, PartialPayment
FROM WithAmounts;

-- Unpaid or partially paid invoices
SELECT i.*
FROM dbo.BillingStaging i
WHERE i.PaidInFull = 0
ORDER BY i.InvoiceDate DESC;

-- Balance by animal
SELECT v.AnimalID, SUM(i.AmountOwed) AS TotalOwed
FROM dbo.BillingStaging i
JOIN dbo.VisitStaging  v ON v.VisitID = i.VisitID
GROUP BY v.AnimalID
ORDER BY TotalOwed DESC;

SELECT * FROM BillingStaging
-- If they exist, drop the RiverviewDev Dev tables
