USE RiverviewDev
GO


----------------------------------------------------------
-- STEP 1
----------------------------------------------------------

-- Add work phone
ALTER TABLE OwnerStaging
	ADD Workphone char(10) NULL

-- Add default value 'No work phone'
ALTER TABLE OwnerStaging
	ADD CONSTRAINT d_WorkPhone DEFAULT 'No work phone' FOR Workphone

-- Add a Status column 
ALTER TABLE OwnerStaging
	ADD CStatus char(10) NULL

-- Add constraint for the default values Active
ALTER TABLE OwnerStaging
	ADD CONSTRAINT c_CStatus DEFAULT 'Active' FOR CStatus

-- Add Cstatus column:  Active or Archived
ALTER TABLE AnimalStaging
	ADD CStatus char(10) NULL

-- Add contraint that default value is Active
ALTER TABLE AnimalStaging
	ADD CONSTRAINT c_AnimalStatus DEFAULT 'Active' FOR CStatus

----------------------------------------------------------
-- STEP 2
----------------------------------------------------------

-- Set all current customers and animals to Active

UPDATE OwnerStaging
SET CStatus = 'Active'


UPDATE AnimalStaging
SET CStatus = 'Active'


----------------------------------------------------------
-- STEP 3 
----------------------------------------------------------


-- Create a stored procedure to add a customer
CREATE OR ALTER PROCEDURE pr_AddCustomer
	@OwnerID int,
	@FirstName varchar(50),
	@LastName varchar(50),
	@Phone varchar(12) ,
	@StreetAddress varchar(50),
	@City varchar(50),
	@StateAbbr char(2),
	@Zip char (5),
	@Email varchar (50),
	@Workphone char(10),
	@CStatus char(10)-- create this.  default status is 'Active'
AS
BEGIN
	INSERT INTO OwnerStaging(OwnerID, FirstName, LastName, Phone, StreetAddress, City, StateAbbr, Zip, Email, Workphone)
	VALUES
	(@OwnerID, @FirstName, @LastName, @Phone, @StreetAddress, @City, @StateAbbr, @Zip, @Email, @Workphone)
END
GO




----------------------------------------------------------
-- STEP 4
----------------------------------------------------------

--Create a stored procedure to archive a customer
CREATE OR ALTER PROCEDURE pr_ArchiveCustomer
@FirstName varchar(50),
@LastName varchar(50)
AS 
BEGIN
	UPDATE OwnerStaging
	SET CStatus = 'Archived'
	WHERE FirstName = @FirstName
	AND LastName = @LastName
	AND CStatus <> 'Archived'
END
GO



----------------------------------------------------------
-- STEP 5
----------------------------------------------------------


--Create a stored procedure to activate a customer
CREATE OR ALTER PROCEDURE pr_ActivateCustomer
@FirstName varchar(50),
@LastName varchar(50)
AS 
BEGIN
	UPDATE OwnerStaging
	SET CStatus = 'Active'
	WHERE FirstName = @FirstName
	AND LastName = @LastName
	AND CStatus <> 'Active'
END
GO

----------------------------------------------------------
-- STEP 6
----------------------------------------------------------


-- Create trigger to update the animal status when the owner status changes
CREATE OR ALTER TRIGGER dbo.trg_OwnerStaging_CStatus_Cascade_UpdateOnly
ON dbo.OwnerStaging
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Skip if CStatus wasn't in the SET list
    IF NOT UPDATE(CStatus) RETURN;

    -- Only act when the value truly changed (case/space tolerant)
    ;WITH changed AS
    (
        SELECT i.OwnerID,
               NewStatus = UPPER(LTRIM(RTRIM(i.CStatus))),
               OldStatus = UPPER(LTRIM(RTRIM(d.CStatus)))
        FROM inserted i
        JOIN deleted  d ON d.OwnerID = i.OwnerID
        WHERE ISNULL(UPPER(LTRIM(RTRIM(d.CStatus))),'')
            <> ISNULL(UPPER(LTRIM(RTRIM(i.CStatus))),'')
    )
    UPDATE a
       SET a.CStatus =
           CASE c.NewStatus
             WHEN 'Active'   THEN 'Active'
             WHEN 'Archived' THEN N'Archived'
             ELSE a.CStatus       -- ignore other statuses
           END
    FROM dbo.AnimalStaging a
    JOIN changed c ON c.OwnerID = a.OwnerID
    WHERE
      -- only touch animals that actually differ from the new parent status
      (c.NewStatus = 'Active'   AND UPPER(LTRIM(RTRIM(a.CStatus))) <> 'Active')
      OR
      (c.NewStatus = 'Archived' AND UPPER(LTRIM(RTRIM(a.CStatus))) <> 'Archived');
END
GO

----------------------------------------------------------
-- STEP 7
----------------------------------------------------------

CREATE OR ALTER FUNCTION dbo.f_GetAnimalAge (@AnimalBirthDate DATE)
RETURNS INT
AS
BEGIN
    DECLARE @AnimalAge INT;

    -- Basic year difference
    SET @AnimalAge = DATEDIFF(YEAR, @AnimalBirthDate, GETDATE());

    -- Adjust if birthday hasn�t occurred yet this year
    IF (MONTH(@AnimalBirthDate) > MONTH(GETDATE()))
       OR (MONTH(@AnimalBirthDate) = MONTH(GETDATE()) AND DAY(@AnimalBirthDate) > DAY(GETDATE()))
        SET @AnimalAge = @AnimalAge - 1;

    RETURN @AnimalAge;
END;
GO


----------------------------------------------------------
-- STEP 8
----------------------------------------------------------

CREATE  OR ALTER VIEW v_ArchivedOwners
AS
SELECT *
FROM OwnerStaging
WHERE CStatus = 'Archived'
GO



----------------------------------------------------------
-- STEP 9
----------------------------------------------------------

-- Create column VisitTime as varchar(10) Valid appts times are (9am,11am, 1pm, 3pm, 5pm)
ALTER TABLE VisitStaging
	ADD VisitTime varchar(10)

-- run visittime script



UPDATE t
SET VisitTime = s.v
FROM VisitStaging AS t
CROSS APPLY (SELECT ABS(CHECKSUM(NEWID())) % 4 AS i) AS r   -- per-row random 0..3
CROSS APPLY (VALUES
   (0,'9am'),
   (1,'11am'),
   (2,'2pm'),
   (3,'4pm')
) AS s(i, v)
WHERE s.i = r.i;






