/*

*/

-- i named my database exam3. there was an error when i tried to rename it so i left it as is.
USE exam3
GO

-----------------------------------
--  Drop tables
-----------------------------------

PRINT 'Dropping Tables'
PRINT ''

IF OBJECT_ID('factCreditScore', 'U') IS NOT NULL DROP TABLE factCreditScore;
IF OBJECT_ID('dimGeneration', 'U') IS NOT NULL DROP TABLE dimGeneration;
IF OBJECT_ID('dimDebtRatio', 'U') IS NOT NULL DROP TABLE dimDebtRatio;
IF OBJECT_ID('dimMonthlyRevenue', 'U') IS NOT NULL DROP TABLE dimMonthlyRevenue;
IF OBJECT_ID('dimRatedExposure', 'U') IS NOT NULL DROP TABLE dimRatedExposure;
IF OBJECT_ID('dimOverdue30to59Days', 'U') IS NOT NULL DROP TABLE dimOverdue30to59Days;
IF OBJECT_ID('dimOverdue60to89Days', 'U') IS NOT NULL DROP TABLE dimOverdue60to89Days;
IF OBJECT_ID('dimOverdue90Days', 'U') IS NOT NULL DROP TABLE dimOverdue90Days;
IF OBJECT_ID('dimSeriousDelinquencies', 'U') IS NOT NULL DROP TABLE dimSeriousDelinquencies;
IF OBJECT_ID('CreditApprovalODS', 'U') IS NOT NULL DROP TABLE CreditApprovalODS;
IF OBJECT_ID('CreditApprovalStaging', 'U') IS NOT NULL DROP TABLE CreditApprovalStaging;



-----------------------------------
--  Credit Approval Staging
-----------------------------------

PRINT 'Creating Staging Table'
PRINT ''

CREATE TABLE CreditApprovalStaging(
	ApplicantID int,
    Age varchar(50),
    MonthlyRevenue varchar(50),
    DebtRatio varchar(50),
    RatedExposure varchar(50),
    Overdue30to59Days varchar(50),
    Overdue60to89Days varchar(50),
    Overdue90Days varchar(50),
    SeriousDelinquencies varchar(50)
)

	
    -- Load raw CSV into staging

PRINT 'Bulk Insert'
PRINT ''

BULK INSERT CreditApprovalStaging
FROM 'C:\Users\Justin\Documents\GitHub\MGMT-4170-DATA-RESOURCE-MANAGEMENT\test3\CreditApp(1).csv'
WITH (
  --FORMAT = 'CSV', 
  FIRSTROW = 2,
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '0x0d0a',   -- or '0x0d0a' on Windows line endings
  TABLOCK
)

PRINT 'Validate Load'
PRINT ''

SELECT *
FROM CreditApprovalStaging

-----------------------------------
--  Data Quality
-----------------------------------
PRINT 'Data Quality'
PRINT ''

--	   Age

PRINT 'Data Quality - Age'
PRINT ''


--    MonthlyRevenue 
PRINT 'Data Quality MonthlyRevenue'
PRINT ''


--    DebtRatio 
PRINT 'Data Quality DebtRatio'
PRINT ''


--    RatedExposure
--    Overdue30to59Days
PRINT 'Data Quality Overdue30to59Days'
PRINT ''


--    Overdue60to89Days
PRINT 'Data Quality Overdue60to89Days'
PRINT ''


--    Overdue90Days
PRINT 'Data Quality Overdue90Days'
PRINT ''


--    SeriousDelinquencies
PRINT 'Data Quality SeriousDelinquencies'
PRINT ''


PRINT 'Data Quality Validation'
PRINT ''

SELECT *
FROM CreditApprovalStaging


-----------------------------------
--  Operational Datastore
-----------------------------------

PRINT 'Operational Datastore'
PRINT ''

PRINT 'Create CreditApprovalODS'
PRINT ''

CREATE TABLE CreditApprovalODS(
    ApplicantID int  NOT NULL
        CONSTRAINT PK_CreditApprovalODS PRIMARY KEY CLUSTERED (ApplicantID),
    Age INT,
    MonthlyRevenue MONEY,
    DebtRatio decimal(9,4),
    RatedExposure INT,
    Overdue30to59Days INT,
    Overdue60to89Days INT,
    Overdue90Days INT,
    SeriousDelinquencies INT
)




PRINT 'Load CreditApprovalODS'
PRINT ''

INSERT INTO CreditApprovalODS
SELECT
  ApplicantID,
  TRY_CONVERT(int,   NULLIF(REPLACE(REPLACE(LTRIM(RTRIM(Age)),              CHAR(13), ''), CHAR(10), ''), '')),
  TRY_CONVERT(money, NULLIF(REPLACE(REPLACE(LTRIM(RTRIM(MonthlyRevenue)),   CHAR(13), ''), CHAR(10), ''), '')),
  TRY_CONVERT(decimal(9,4), NULLIF(REPLACE(REPLACE(LTRIM(RTRIM(DebtRatio)),        CHAR(13), ''), CHAR(10), ''), '')),
  TRY_CONVERT(int,   NULLIF(REPLACE(REPLACE(LTRIM(RTRIM(RatedExposure)),    CHAR(13), ''), CHAR(10), ''), '')),
  TRY_CONVERT(int,   NULLIF(REPLACE(REPLACE(LTRIM(RTRIM(Overdue30to59Days)),CHAR(13), ''), CHAR(10), ''), '')),
  TRY_CONVERT(int,   NULLIF(REPLACE(REPLACE(LTRIM(RTRIM(Overdue60to89Days)),CHAR(13), ''), CHAR(10), ''), '')),
  TRY_CONVERT(int,   NULLIF(REPLACE(REPLACE(LTRIM(RTRIM(Overdue90Days)),    CHAR(13), ''), CHAR(10), ''), '')),
  TRY_CONVERT(int,   NULLIF(REPLACE(REPLACE(LTRIM(RTRIM(SeriousDelinquencies)),CHAR(13), ''), CHAR(10), ''), ''))
FROM CreditApprovalStaging;

SELECT *
FROM CreditApprovalODS

-----------------------------------
--  Dimension Tables
-----------------------------------
PRINT 'Dimension Tables'
PRINT ''
-----------------------------------
-- dimGeneration
-----------------------------------

--   Greatest: <= 1927
--   Silent:   1928�1945
--   Boomer:   1946�1964
--   Gen X:    1965�1980
--   Millennial: 1981�1996
--   Gen Z:    1997�2012
--   Gen Alpha: 2013�2024
--   Gen Beta:  >= 2025  (placeholder label for post-Alpha)

PRINT 'Create dimGeneration'
PRINT ''

CREATE TABLE dimGeneration (
    GenerationID INT IDENTITY(1,1) PRIMARY KEY,
    GenerationDescription VARCHAR(50),
    AgeRangeDescription VARCHAR(50)
);
GO


PRINT 'Load dimGeneration'
PRINT ''

INSERT INTO dimGeneration (GenerationDescription, AgeRangeDescription)
VALUES
('Greatest',   '<= 1927'),
('Silent',     '1928-1945'),
('Boomer',     '1946-1964'),
('Gen X',      '1965-1980'),
('Millennial', '1981-1996'),
('Gen Z',      '1997-2012'),
('Gen Alpha',  '2013-2024'),
('Gen Beta',   '>= 2025');
GO


PRINT 'Validate dimGeneration'
PRINT ''

SELECT *
FROM dimGeneration

-----------------------------------
-- dimDebtRatio
-----------------------------------

	--('None'),
	--('DebtRatio < 0.10 '),  
	--('DebtRatio < 0.25'),           
	--('DebtRatio < 0.40'),             
	--('DebtRatio < 0.60'),            
	--('DebtRatio > 0.60')     

PRINT 'Create dimDebtRation'
PRINT ''

CREATE TABLE dimDebtRatio (
    DebtRatioID INT IDENTITY(1,1) PRIMARY KEY,
    DebtRatioDescription VARCHAR(50)
);
GO


PRINT 'Load dimDebtRatio'
PRINT ''

INSERT INTO dimDebtRatio (DebtRatioDescription)
VALUES
('None'),
('DebtRatio < 0.10'),
('DebtRatio < 0.25'),
('DebtRatio < 0.40'),
('DebtRatio < 0.60'),
('DebtRatio > 0.60');
GO
	
PRINT 'Validate dimDebtRatio'
PRINT ''

SELECT *
FROM dimDebtRatio

-----------------------------------
-- dimMonthlyRevenue
-----------------------------------

--('No Income'),
--('0 - 1,999'),
--('2,000 - 3,999'),
--('4,000 - 6,999'),
--('70,000 - 9,999'),
--('10,000 and above')

PRINT 'Create dimMonthlyRevenue'
PRINT ''

CREATE TABLE dimMonthlyRevenue (
    MonthlyRevenueID INT IDENTITY(1,1) PRIMARY KEY,
    MonthlyRevenueDescription VARCHAR(50)
);
GO

PRINT 'Load dimMonthlyRevenue'
PRINT ''

INSERT INTO dimMonthlyRevenue (MonthlyRevenueDescription)
VALUES
('No Income'),
('0 - 1,999'),
('2,000 - 3,999'),
('4,000 - 6,999'),
('7,000 - 9,999'), -- Corrected typo from 70,000
('10,000 and above');
GO

PRINT 'Validate dimMonthlyRevenue'
PRINT ''

SELECT *
FROM dimMonthlyRevenue




-----------------------------------
-- dimRatedExposure
-----------------------------------

--('None'),  -- 0-3
--('Low'), -- 4-7
--('Medium'), -- 8-9
--('High') -- 10_+

PRINT 'Create dimRatedExposure'
PRINT ''

CREATE TABLE dimRatedExposure (
    RatedExposureID INT IDENTITY(1,1) PRIMARY KEY,
    RatedExposureDescription VARCHAR(50)
);
GO

PRINT 'Load dimRatedExposure'
PRINT ''

INSERT INTO dimRatedExposure 
VALUES
('None'),  -- 0-3
('Low'), -- 4-7
('Medium'), -- 8-9
('High'); -- 10_+
GO

PRINT 'Validate dimRatedExposure'
PRINT ''


SELECT * 
FROM dimRatedExposure 


-------------------------------------
---- dimOverdue30to59Days
-------------------------------------

--('Low'),  -- 0 to 1
--('Medium'), --2 to 3
--('High') -- 4 and above

PRINT 'Create dimOverdue30to59Days'
PRINT ''

CREATE TABLE dimOverdue30to59Days (
    Overdue30to59DaysID INT IDENTITY(1,1) PRIMARY KEY,
    Overdue30to59DaysDescription VARCHAR(50)
);
GO

PRINT 'Load dimOverdue30to59Dayse'
PRINT ''

INSERT INTO dimOverdue30to59Days (Overdue30to59DaysDescription)
VALUES
('Low'),  -- 0 to 1
('Medium'), --2 to 3
('High'); -- 4 and above
GO

PRINT 'Validate dimOverdue30to59Days'
PRINT ''

SELECT *
FROM  dimOverdue30to59Days


-------------------------------------
---- dimOverdue60to89Days
-------------------------------------

--('Low'),  -- 0 to 1
--('Medium'), --2 
--('High') -- 3


PRINT 'Create dimOverdue60to89Days'
PRINT ''

CREATE TABLE dimOverdue60to89Days (
    Overdue60to89DaysID INT IDENTITY(1,1) PRIMARY KEY,
    Overdue60to89DaysDescription VARCHAR(50)
);
GO

PRINT 'Load dimOverdue60to89Days'
PRINT ''

INSERT INTO dimOverdue60to89Days (Overdue60to89DaysDescription)
VALUES
('Low'),  -- 0 to 1
('Medium'), --2 
('High'); -- 3
GO

PRINT 'Validate dimOverdue60to89Days'
PRINT ''

SELECT *
FROM  dimOverdue60to89Days


-------------------------------------
---- dimOverdue90Days
-------------------------------------

--('Low'),  -- 0 to 1
--('Medium'), --2 
--('High') -- 3 and above


PRINT 'Create dimOverdue90Days'
PRINT ''

CREATE TABLE dimOverdue90Days (
    Overdue90DaysID INT IDENTITY(1,1) PRIMARY KEY,
    Overdue90DaysDescription VARCHAR(50)
);
GO

PRINT 'Load dimOverdue90Days'
PRINT ''

INSERT INTO dimOverdue90Days (Overdue90DaysDescription)
VALUES
('Low'),  -- 0 to 1
('Medium'), --2 
('High'); -- 3 and above
GO

PRINT 'Validate dimOverdue90Days'
PRINT ''

SELECT *
FROM dimOverdue90Days


-------------------------------------
---- dimSeriousDelinquencies
-------------------------------------
--('Low'),  -- 0 to 1
--('Medium'), --2 
--('High') -- 3 and above



PRINT 'Create dimSeriousDelinquencies'
PRINT ''

CREATE TABLE dimSeriousDelinquencies (
    SeriousDelinquenciesID INT IDENTITY(1,1) PRIMARY KEY,
    SeriousDelinquenciesDescription VARCHAR(50)
);
GO

PRINT 'Load dimSeriousDelinquencies'
PRINT ''

INSERT INTO dimSeriousDelinquencies (SeriousDelinquenciesDescription)
VALUES
('Low'),  -- 0 to 1
('Medium'), --2 
('High'); -- 3 and above
GO

PRINT 'Validate dimSeriousDelinquencies'
PRINT ''

SELECT *
FROM dimSeriousDelinquencies


-------------------------------------
----  factCreditScore
-------------------------------------

	--ApplicantID PRIMARY KEY CLUSTERED
	--Age 
	--GenerationID FOREIGN KEY
	--MonthlyRevenue MONEY,
	--MonthlyRevenueID FOREIGN KEYL
	--DebtRatio numeric,
	--DebtRatioID FOREIGN KEY
	--RatedExposure INT,
	--RatedExposureID FOREIGN KEY
	--Overdue30to59Days INT,
	--Overdue30to59DaysID FOREIGN KEY
	--Overdue60to89Days INT,
	--Overdue60to89DaysID FOREIGN KEY
	--Overdue90Days INT,
	--Overdue90DaysID FOREIGN KEY
	--SeriousDelinquencies INT,
	--SeriousDelinquenciesID FOREIGN KEY
	--DelinquecyPoints int
--)

PRINT 'factCreditScore'
PRINT ''


PRINT 'Create factCreditScore'
PRINT ''

CREATE TABLE factCreditScore (
    ApplicantID INT PRIMARY KEY,
    Age INT,
    GenerationID INT FOREIGN KEY REFERENCES dimGeneration(GenerationID),
    MonthlyRevenue MONEY,
    MonthlyRevenueID INT FOREIGN KEY REFERENCES dimMonthlyRevenue(MonthlyRevenueID),
    DebtRatio DECIMAL(9,4),
    DebtRatioID INT FOREIGN KEY REFERENCES dimDebtRatio(DebtRatioID),
    RatedExposure INT,
    RatedExposureID INT FOREIGN KEY REFERENCES dimRatedExposure(RatedExposureID),
    Overdue30to59Days INT,
    Overdue30to59DaysID INT FOREIGN KEY REFERENCES dimOverdue30to59Days(Overdue30to59DaysID),
    Overdue60to89Days INT,
    Overdue60to89DaysID INT FOREIGN KEY REFERENCES dimOverdue60to89Days(Overdue60to89DaysID),
    Overdue90Days INT,
    Overdue90DaysID INT FOREIGN KEY REFERENCES dimOverdue90Days(Overdue90DaysID),
    SeriousDelinquencies INT,
    SeriousDelinquenciesID INT FOREIGN KEY REFERENCES dimSeriousDelinquencies(SeriousDelinquenciesID),
    DelinquecyPoints INT
);
GO

PRINT 'Load factCreditScore'
PRINT ''
INSERT INTO factCreditScore (
    ApplicantID, Age, GenerationID, MonthlyRevenue, MonthlyRevenueID, DebtRatio, DebtRatioID,
    RatedExposure, RatedExposureID, Overdue30to59Days, Overdue30to59DaysID, Overdue60to89Days,
    Overdue60to89DaysID, Overdue90Days, Overdue90DaysID, SeriousDelinquencies,
    SeriousDelinquenciesID, DelinquecyPoints
)
SELECT
    ods.ApplicantID,
    ods.Age,
    g.GenerationID,
    ods.MonthlyRevenue,
    mr.MonthlyRevenueID,
    ods.DebtRatio,
    dr.DebtRatioID,
    ods.RatedExposure,
    re.RatedExposureID,
    ods.Overdue30to59Days,
    o30.Overdue30to59DaysID,
    ods.Overdue60to89Days,
    o60.Overdue60to89DaysID,
    ods.Overdue90Days,
    o90.Overdue90DaysID,
    ods.SeriousDelinquencies,
    sd.SeriousDelinquenciesID,
    (10 * ISNULL(ods.Overdue30to59Days, 0) + 20 * ISNULL(ods.Overdue60to89Days, 0) + 35 * ISNULL(ods.Overdue90Days, 0) + 50 * ISNULL(ods.SeriousDelinquencies, 0)) AS DelinquencyPoints
FROM
    CreditApprovalODS ods
LEFT JOIN dimGeneration g ON g.GenerationDescription =
    CASE
        WHEN (YEAR(GETDATE()) - ods.Age) <= 1927 THEN 'Greatest'
        WHEN (YEAR(GETDATE()) - ods.Age) BETWEEN 1928 AND 1945 THEN 'Silent'
        WHEN (YEAR(GETDATE()) - ods.Age) BETWEEN 1946 AND 1964 THEN 'Boomer'
        WHEN (YEAR(GETDATE()) - ods.Age) BETWEEN 1965 AND 1980 THEN 'Gen X'
        WHEN (YEAR(GETDATE()) - ods.Age) BETWEEN 1981 AND 1996 THEN 'Millennial'
        WHEN (YEAR(GETDATE()) - ods.Age) BETWEEN 1997 AND 2012 THEN 'Gen Z'
        WHEN (YEAR(GETDATE()) - ods.Age) BETWEEN 2013 AND 2024 THEN 'Gen Alpha'
        ELSE 'Gen Beta'
    END
LEFT JOIN dimMonthlyRevenue mr ON mr.MonthlyRevenueDescription =
    CASE
        WHEN ods.MonthlyRevenue IS NULL OR ods.MonthlyRevenue <= 0 THEN 'No Income'
        WHEN ods.MonthlyRevenue < 2000 THEN '0 - 1,999'
        WHEN ods.MonthlyRevenue < 4000 THEN '2,000 - 3,999'
        WHEN ods.MonthlyRevenue < 7000 THEN '4,000 - 6,999'
        WHEN ods.MonthlyRevenue < 10000 THEN '7,000 - 9,999'
        ELSE '10,000 and above'
    END
LEFT JOIN dimDebtRatio dr ON dr.DebtRatioDescription =
    CASE
        WHEN ods.DebtRatio IS NULL OR ods.DebtRatio = 0 THEN 'None'
        WHEN ods.DebtRatio < 0.10 THEN 'DebtRatio < 0.10'
        WHEN ods.DebtRatio < 0.25 THEN 'DebtRatio < 0.25'
        WHEN ods.DebtRatio < 0.40 THEN 'DebtRatio < 0.40'
        WHEN ods.DebtRatio < 0.60 THEN 'DebtRatio < 0.60'
        ELSE 'DebtRatio > 0.60'
    END
LEFT JOIN dimRatedExposure re ON re.RatedExposureDescription =
    CASE
        WHEN ods.RatedExposure <= 3 THEN 'None'
        WHEN ods.RatedExposure <= 7 THEN 'Low'
        WHEN ods.RatedExposure <= 9 THEN 'Medium'
        ELSE 'High'
    END
LEFT JOIN dimOverdue30to59Days o30 ON o30.Overdue30to59DaysDescription =
    CASE
        WHEN ods.Overdue30to59Days <= 1 THEN 'Low'
        WHEN ods.Overdue30to59Days <= 3 THEN 'Medium'
        ELSE 'High'
    END
LEFT JOIN dimOverdue60to89Days o60 ON o60.Overdue60to89DaysDescription =
    CASE
        WHEN ods.Overdue60to89Days <= 1 THEN 'Low'
        WHEN ods.Overdue60to89Days = 2 THEN 'Medium'
        ELSE 'High'
    END
LEFT JOIN dimOverdue90Days o90 ON o90.Overdue90DaysDescription =
    CASE
        WHEN ods.Overdue90Days <= 1 THEN 'Low'
        WHEN ods.Overdue90Days = 2 THEN 'Medium'
        ELSE 'High'
    END
LEFT JOIN dimSeriousDelinquencies sd ON sd.SeriousDelinquenciesDescription =
    CASE
        WHEN ods.SeriousDelinquencies <= 1 THEN 'Low'
        WHEN ods.SeriousDelinquencies = 2 THEN 'Medium'
        ELSE 'High'
    END;
GO

PRINT 'Validate Operational Datastore'
PRINT ''

-- Join fact and dimension tables and display dimension descriptions
SELECT
    f.ApplicantID,
    g.GenerationDescription,
    mr.MonthlyRevenueDescription,
    dr.DebtRatioDescription,
    re.RatedExposureDescription,
    o30.Overdue30to59DaysDescription,
    o60.Overdue60to89DaysDescription,
    o90.Overdue90DaysDescription,
    sd.SeriousDelinquenciesDescription,
    f.DelinquecyPoints
FROM
    factCreditScore f
LEFT JOIN dimGeneration g ON f.GenerationID = g.GenerationID
LEFT JOIN dimMonthlyRevenue mr ON f.MonthlyRevenueID = mr.MonthlyRevenueID
LEFT JOIN dimDebtRatio dr ON f.DebtRatioID = dr.DebtRatioID
LEFT JOIN dimRatedExposure re ON f.RatedExposureID = re.RatedExposureID
LEFT JOIN dimOverdue30to59Days o30 ON f.Overdue30to59DaysID = o30.Overdue30to59DaysID
LEFT JOIN dimOverdue60to89Days o60 ON f.Overdue60to89DaysID = o60.Overdue60to89DaysID
LEFT JOIN dimOverdue90Days o90 ON f.Overdue90DaysID = o90.Overdue90DaysID
LEFT JOIN dimSeriousDelinquencies sd ON f.SeriousDelinquenciesID = sd.SeriousDelinquenciesID;
GO


-----------------------------------
--  Function f_CalculateCreditScore
--
-- Uncomment, run, comment
-----------------------------------

PRINT 'Function f_CalculatedCreditScore'
PRINT ''


-- CREATE OR ALTER FUNCTION dbo.CalculateCreditScore
-- (
--     @Age                    INT,
--     @MonthlyRevenue         DECIMAL(18,2),
--     @DebtRatio              DECIMAL(9,4),
--     @RatedExposure          INT,
--     @Overdue30to59Days      INT,
--     @Overdue60to89Days      INT,
--     @Overdue90Days          INT,
--     @SeriousDelinquencies   INT
-- )
-- RETURNS INT
-- AS
-- BEGIN
--     DECLARE
--         @AgePts     INT,
--         @RevPts     INT,
--         @DTIPts     INT,
--         @ExpoPts    INT,
--         @O30        INT,
--         @O60        INT,
--         @O90        INT,
--         @Ser        INT,
--         @DelinqPts  INT,
--         @Score      INT;

--     -- Age
--     SET @AgePts = CASE
--         WHEN @Age IS NULL                   THEN -20
--         WHEN @Age < 21                      THEN -40
--         WHEN @Age BETWEEN 21 AND 25         THEN -20
--         WHEN @Age BETWEEN 26 AND 35         THEN  10
--         WHEN @Age BETWEEN 36 AND 50         THEN  20
--         WHEN @Age > 50                      THEN  10
--         ELSE 0
--     END;

--     -- MonthlyRevenue
--     SET @RevPts = CASE
--         WHEN @MonthlyRevenue IS NULL OR @MonthlyRevenue <= 0 THEN -60
--         WHEN @MonthlyRevenue < 2000                          THEN -60
--         WHEN @MonthlyRevenue < 4000                          THEN -30
--         WHEN @MonthlyRevenue < 7000                          THEN   0
--         WHEN @MonthlyRevenue < 10000                         THEN  20
--         ELSE                                                      40
--     END;

--     -- DebtRatio
--     SET @DTIPts = CASE
--         WHEN @DebtRatio IS NULL THEN -40
--         WHEN @DebtRatio < 0.10  THEN  20
--         WHEN @DebtRatio < 0.25  THEN  10
--         WHEN @DebtRatio < 0.40  THEN -10
--         WHEN @DebtRatio < 0.60  THEN -40
--         ELSE                         -80
--     END;

--     -- RatedExposure
--     SET @ExpoPts = CASE
--         WHEN @RatedExposure IS NULL THEN -10
--         WHEN @RatedExposure <= 2    THEN  20
--         WHEN @RatedExposure <= 5    THEN   0
--         WHEN @RatedExposure <= 10   THEN -10
--         ELSE                         -30
--     END;

--     -- Cap delinquencies as specified (treat NULLs as 0)
--     SET @O30 = CASE WHEN @Overdue30to59Days IS NULL THEN 0 WHEN @Overdue30to59Days > 4 THEN 4 ELSE @Overdue30to59Days END;
--     SET @O60 = CASE WHEN @Overdue60to89Days IS NULL THEN 0 WHEN @Overdue60to89Days > 3 THEN 3 ELSE @Overdue60to89Days END;
--     SET @O90 = CASE WHEN @Overdue90Days IS NULL    THEN 0 WHEN @Overdue90Days > 3    THEN 3 ELSE @Overdue90Days END;
--     SET @Ser = CASE WHEN @SeriousDelinquencies IS NULL THEN 0 WHEN @SeriousDelinquencies > 3 THEN 3 ELSE @SeriousDelinquencies END;

--     -- Delinquency points
--     SET @DelinqPts = -(10 * @O30 + 20 * @O60 + 35 * @O90 + 50 * @Ser);

--     -- Base + components (no extra missing-core penalty beyond your NULL handling)
--     SET @Score = 600 + @AgePts + @RevPts + @DTIPts + @ExpoPts + @DelinqPts;

--     -- Clamp to 300–850
--     IF @Score < 300 SET @Score = 300;
--     IF @Score > 850 SET @Score = 850;

--     RETURN @Score;
-- END;
-- GO


SELECT dbo.CalculateCreditScore(Age, MonthlyRevenue, DebtRatio, RatedExposure, Overdue30to59Days, Overdue60to89Days, Overdue90Days,SeriousDelinquencies )
FROM factCreditScore
WHERE ApplicantID = 15

-- Calculates a credit score from component inputs using your rules
-- Usage example:

SELECT ApplicantID,
       dbo.CalculateCreditScore(
           Age, MonthlyRevenue, DebtRatio, RatedExposure,
           Overdue30to59Days, Overdue60to89Days, Overdue90Days, SeriousDelinquencies
       ) AS Score
FROM dbo.factCreditScore
ORDER BY ApplicantID;

---------------------------------------
------  View v_CreditApprovalScored
--
-- Uncomment, Run, comment
---------------------------------------


-- CREATE OR ALTER VIEW dbo.v_CreditApprovalScored
-- AS
-- SELECT
--     s.ApplicantID,
--     dbo.CalculateCreditScore(
--         s.Age, s.MonthlyRevenue, s.DebtRatio, s.RatedExposure,
--         s.Overdue30to59Days, s.Overdue60to89Days, s.Overdue90Days, s.SeriousDelinquencies
--     ) AS CreditScore,
--     CASE
--         WHEN dbo.CalculateCreditScore(s.Age, s.MonthlyRevenue, s.DebtRatio, s.RatedExposure,
--                                            s.Overdue30to59Days, s.Overdue60to89Days, s.Overdue90Days, s.SeriousDelinquencies) >= 750 THEN 'A'
--         WHEN dbo.CalculateCreditScore(s.Age, s.MonthlyRevenue, s.DebtRatio, s.RatedExposure,
--                                            s.Overdue30to59Days, s.Overdue60to89Days, s.Overdue90Days, s.SeriousDelinquencies) >= 700 THEN 'B'
--         WHEN dbo.CalculateCreditScore(s.Age, s.MonthlyRevenue, s.DebtRatio, s.RatedExposure,
--                                            s.Overdue30to59Days, s.Overdue60to89Days, s.Overdue90Days, s.SeriousDelinquencies) >= 650 THEN 'C'
--         WHEN dbo.CalculateCreditScore(s.Age, s.MonthlyRevenue, s.DebtRatio, s.RatedExposure,
--                                            s.Overdue30to59Days, s.Overdue60to89Days, s.Overdue90Days, s.SeriousDelinquencies) >= 600 THEN 'D'
--         ELSE 'E'
--     END AS RiskGrade
-- FROM factCreditScore AS s;
-- GO

SELECT RiskGrade,  COUNT(ApplicantID) AS [Applicant Count]
FROM v_CreditApprovalScored
GROUP BY  RiskGrade

---------------------------------------
------  Bonus
---------------------------------------

-- Number of Applicants by Risk Grade by Generation
SELECT
    v.RiskGrade,
    g.GenerationDescription,
    COUNT(f.ApplicantID) AS NumberOfApplicants
FROM
    factCreditScore f
JOIN
    v_CreditApprovalScored v ON f.ApplicantID = v.ApplicantID
JOIN
    dimGeneration g ON f.GenerationID = g.GenerationID
GROUP BY
    v.RiskGrade, g.GenerationDescription
ORDER BY
    g.GenerationDescription, v.RiskGrade;
GO

-- Average Credit Score by MonthlyIncome

SELECT
    mr.MonthlyRevenueDescription,
    AVG(v.CreditScore) AS AverageCreditScore
FROM
    factCreditScore f
JOIN
    v_CreditApprovalScored v ON f.ApplicantID = v.ApplicantID
JOIN
    dimMonthlyRevenue mr ON f.MonthlyRevenueID = mr.MonthlyRevenueID
GROUP BY
    mr.MonthlyRevenueID, mr.MonthlyRevenueDescription
ORDER BY
    mr.MonthlyRevenueID;
GO

-- Number of Applicants by Rated Exposure

SELECT
    re.RatedExposureDescription,
    COUNT(f.ApplicantID) AS NumberOfApplicants
FROM
    factCreditScore f
JOIN
    dimRatedExposure re ON f.RatedExposureID = re.RatedExposureID
GROUP BY
    re.RatedExposureDescription, re.RatedExposureID
ORDER BY
    re.RatedExposureID;
GO

-- Write a query that assigns Granted (risk grade A,B) or Denied risk 

SELECT
    ApplicantID,
    CreditScore,
    RiskGrade,
    CASE
        WHEN RiskGrade IN ('A', 'B') THEN 'Granted'
        ELSE 'Denied'
    END AS ApplicationStatus
FROM
    v_CreditApprovalScored
ORDER BY
    ApplicantID;
GO

-- create a cursor that says "ApplicanID xxx has a credit grade of X and is (approved/denied)"  for every applicant

DECLARE @ApplicantID INT;
DECLARE @RiskGrade CHAR(1);
DECLARE @Status VARCHAR(10);
DECLARE @Message VARCHAR(100);

DECLARE ApprovalCursor CURSOR FOR
SELECT
    ApplicantID,
    RiskGrade,
    CASE
        WHEN RiskGrade IN ('A', 'B') THEN 'Approved'
        ELSE 'Denied'
    END
FROM
    v_CreditApprovalScored;

OPEN ApprovalCursor;
FETCH NEXT FROM ApprovalCursor INTO @ApplicantID, @RiskGrade, @Status;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Message = 'ApplicantID ' + CAST(@ApplicantID AS VARCHAR) + ' has a credit grade of ' + @RiskGrade + ' and is ' + @Status;
    PRINT @Message;
    FETCH NEXT FROM ApprovalCursor INTO @ApplicantID, @RiskGrade, @Status;
END;

CLOSE ApprovalCursor;
DEALLOCATE ApprovalCursor;
GO

-- report listing applicant id, overdue columns, credit rating, credit score
SELECT
    f.ApplicantID,
    f.Overdue30to59Days,
    f.Overdue60to89Days,
    f.Overdue90Days,
    f.SeriousDelinquencies,
    v.CreditScore,
    v.RiskGrade AS CreditRating
FROM
    factCreditScore f
JOIN
    v_CreditApprovalScored v ON f.ApplicantID = v.ApplicantID
ORDER BY
    f.ApplicantID;
GO

