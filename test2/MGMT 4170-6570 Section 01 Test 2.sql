
USE RiverviewDev
GO

------------------------------------------
-- OwnerStaging
------------------------------------------

-- Add column called MobilePhone char(10)
ALTER TABLE OwnerStaging
	ADD MobilePhone char(10) NULL;


-- Add default value 'No work phone
ALTER TABLE OwnerStaging
	ADD CONSTRAINT d_MobilePhone DEFAULT 'No mobile phone' FOR MobilePhone


-- create email in the rpi format
;WITH EmailCTE AS (
    SELECT
        OwnerID,
        LOWER(LEFT(LastName, 5) + LEFT(FirstName, 1)) AS BaseEmail,
        ROW_NUMBER() OVER (PARTITION BY LEFT(LastName, 5) + LEFT(FirstName, 1) ORDER BY OwnerID) AS rn
    FROM OwnerStaging
)
UPDATE OwnerStaging
SET Email = CASE
    WHEN E.rn = 1 THEN E.BaseEmail + '@rpi.edu'
    ELSE E.BaseEmail + CAST(E.rn - 1 AS VARCHAR(10)) + '@rpi.edu'
    END
FROM OwnerStaging O
JOIN EmailCTE E ON O.OwnerID = E.OwnerID;



-- create a column PreferredContact. choices are Mobile, Phone, Workphone, email
ALTER TABLE OwnerStaging
	ADD PreferredContact varchar(20) NULL;




-- run this script to populate

BEGIN TRAN 

UPDATE dbo.OwnerStaging
SET PreferredContact = 
    CASE ABS(CHECKSUM(NEWID())) % 4
        WHEN 0 THEN 'Phone'
        WHEN 1 THEN 'MobilePhone'
        WHEN 2 THEN 'WorkPhone'
        WHEN 3 THEN 'Email'
		ELSE 'No Preference'
    END;


SELECT * FROM OwnerStaging

--ROLLBACK TRAN
--COMMIT TRAN


-- Create as a CTE from this join
;WITH CustomerCountByState AS
(
	SELECT O.StateAbbr, COUNT(O.OwnerID) AS [# of Customers]
	FROM OwnerStaging O
	GROUP BY O.StateAbbr
)
SELECT *
FROM CustomerCountByState
ORDER BY [# of Customers] DESC




------------------------------------------
-- AnimalStaging
------------------------------------------

-- create a column for RabiesUpToDate char(3).  Values are yes or no
ALTER TABLE AnimalStaging
	ADD RabiesUpToDate char(3) NULL;
GO
ALTER TABLE AnimalStaging
	ADD CONSTRAINT chk_RabiesUpToDate CHECK (RabiesUpToDate IN ('Yes', 'No'));
GO

-- create a column for date of rabies vaccination.  
ALTER TABLE AnimalStaging
	ADD RabiesVaccinationDate DATE NULL;
GO


-- create a stored procedure that takes the animal name and returns " animal name " is  "age" old
-- use the dbo.f_GetAnimalAge (@AnimalBirthDate DATE) to calculate the age



CREATE OR ALTER PROCEDURE pr_AnimalInfo
@AnimalName varchar(50)
AS
BEGIN
	SELECT
		@AnimalName + ' is ' + CAST(dbo.f_GetAnimalAge(AnimalBirthDate) AS VARCHAR(10)) + ' years old.' AS AnimalInfo
	FROM
		AnimalStaging
	WHERE
		AnimalName = @AnimalName;
END
GO

EXEC pr_AnimalInfo 'Pumpkin'

------------------------------------------
-- Visit Staging
------------------------------------------

-- 
-- create a stored procedure called NextVisit to create the next visit date by added months to today
CREATE OR ALTER PROCEDURE pr_NextVisit
    @MonthsToAdd INT
AS
BEGIN
    SELECT DATEADD(MONTH, @MonthsToAdd, GETDATE()) AS NextVisitDate;
END
GO



-- create a column called MissedVisit 
ALTER TABLE VisitStaging
	ADD MissedVisit char(3) NULL;
GO

-- set MissedVisit = 'Yes' if VisitTime is null
UPDATE VisitStaging
SET MissedVisit = 'Yes'
WHERE VisitTime IS NULL;
GO


-- list how many visits for each day of the week 
SELECT 
    DATENAME(WEEKDAY, VisitDate) AS DayOfWeek,
    COUNT(VisitID) AS NumberOfVisits
FROM 
    VisitStaging
GROUP BY 
    DATENAME(WEEKDAY, VisitDate), DATEPART(WEEKDAY, VisitDate)
ORDER BY 
    DATEPART(WEEKDAY, VisitDate);
GO

------------------------------------------
-- Billing Staging
------------------------------------------


-- create a column LateFee with money datatype
ALTER TABLE BillingStaging
	ADD LateFee money NULL;
GO


--create a cursor that updates Late fee for $35 if missed visit is yes

DECLARE

  @visitid AS INT,
  @latefee as money = 35.00

-- Step 1: Declare the cursor based on a query
DECLARE LateFee CURSOR FAST_FORWARD /* read only, forward only */ FOR
SELECT VisitID FROM VisitStaging WHERE MissedVisit = 'Yes'

-- Step 2: Open the cursor
OPEN LateFee;

-- Step 3: Fetch attribute values from the first cursor record into variables
FETCH NEXT FROM LateFee INTO   @visitid  


WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE BillingStaging
	SET LateFee = @latefee
	WHERE VisitID = @visitid;
  
 FETCH NEXT FROM LateFee INTO   @visitid  
END;

-- Step 5: Close the cursor
CLOSE  LateFee;

-- Step 6: Deallocate the cursor
DEALLOCATE LateFee;

select * from BillingStaging
select * from VisitStaging
select * from OwnerStaging
SELECT * FROM AnimalStaging

