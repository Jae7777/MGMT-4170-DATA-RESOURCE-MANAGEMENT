/*
This is the answer key to the test that was given to the Thursday class and those in the Friday class that took the test early.
 */

--1)	What owner has:
--a.	a last name where the second character is NOT a vowel [aeiouy]
--b.	live in a city with two names
--c.	Return the owner name in the format “Lastname, First Initial” and the City

USE Riverview
GO

SELECT CONCAT(O.LastName,', ', LEFT(O.FirstName,1)) AS [Full Name], O.City
FROM OwnerODS O
WHERE NOT O.LastName LIKE '_[aeiouy]%'
-- WHERE O.LastName LIKE '_[^aeiouy]%'
-- WHERE SUBSTRING(O.LastName, 2, 1) NOT IN ('a','e', 'i', 'o','u','y')
-- WHERE LEFT(RIGHT(O.LastName, LEN(O.LastName) -1), 1) NOT IN ('a','e', 'i', 'o','u','y')
AND O.City LIKE '% %'


--2)	What animal has an owner that
--a.	The number of characters in the phone number is the same as the number of characters in the address
--b.	The second to last character in the last name is the same as the second to last character in the first name

USE Riverview
GO

SELECT A.AnimalName
FROM OwnerODS O JOIN AnimalODS A	ON O.OwnerID =A.OwnerID
WHERE LEN(O.Phone) = LEN(O.Address)
AND SUBSTRING(O.LastName, LEN(O.LastName)-1, 1) = SUBSTRING(O.FirstName, LEN(O.FirstName)-1, 1)
-- AND LEFT(RIGHT(O.LastName,2),1) = LEFT(RIGHT(O.FirstName,2),1)

--3)	Who owns the 3rd youngest dog and how many letters in its name? 
--a.	Create a full name like “FirstName LastName”.  
--b.	Also include the dog’s name, animal type, and its birthday.
--c.	Only show the 3rd youngest, don't display any other dogs

USE Riverview
GO

SELECT CONCAT(O.FirstName,' ', O.LastName) AS [Full Name], 
             A.AnimalName, A.AnimalType,  A.AnimalBirthDate, LEN(A.AnimalName) AS [# of char]
FROM OwnerODS O INNER JOIN AnimalODS A ON O.OwnerID = A.OwnerID
WHERE A.AnimalType = 'Dog'
ORDER BY A.AnimalBirthDate DESC
OFFSET 2 ROWS FETCH NEXT 1 ROW ONLY


--4)	Who are the top 5 customers who have spent (and paid) the most money from Cody 
--a.	if the total amount paid is greater than $200?  
--b.	Return the Lastname, FirstName as "Full Name", and amount spent as "Amount Paid"

USE Riverview
GO

SELECT TOP 5  O.OwnerID, CONCAT(O.Lastname, ', ', O.FirstName) AS [Full Name], SUM(B.InvoiceAmt) AS [Amount Paid]
FROM ((OwnerODS O INNER JOIN AnimalODS A ON O.OwnerID = A.OwnerID)
                                      INNER JOIN VisitODS V ON A.AnimalID = V.AnimalID)
									  INNER JOIN BillingODS B ON V.VisitID = B.VisitID
WHERE B.InvoicePaid = 1
AND O.City = 'Cody'
GROUP  BY  O.OwnerID, CONCAT(O.Lastname, ', ', O.FirstName)
HAVING SUM(B.InvoiceAmt) > 200
ORDER BY SUM(B.InvoiceAmt) DESC


--5)	What are the top 5 dates for visits for non-farm animals (Cattle, Bison, and Sheep)?  Show the number of visits for each date

USE Riverview
GO

SELECT TOP 5  V.VisitDate, COUNT(V.VisitID) AS [# of Visits]
FROM AnimalODS A INNER JOIN VisitODS V ON A.AnimalID = V.AnimalID
WHERE A.AnimalType  NOT IN ('Cattle', 'Bison', 'Sheep')
-- WHERE NOT A.AnimalType IN ('Cattle', 'Bison', 'Sheep')
GROUP BY V.VisitDate
ORDER BY COUNT(V.VisitID) DESC


--6)	What animal has not had a visit?  Don't show the animals that have had a visit.

USE Riverview
GO

SELECT A.AnimalName, V.VisitID
FROM AnimalODS A LEFT OUTER JOIN VisitODS V ON A.AnimalID = V.AnimalID
WHERE V.VisitID IS NULL

--7)	How many dogs were born between 04/29/2009 AND 05/19/2014?

USE Riverview
GO

SELECT COUNT(A.AnimalID) AS [# of dogs]
FROM AnimalODS A
WHERE A.AnimalType = 'Dog'
AND A.AnimalBirthDate BETWEEN '04/29/2009' AND '05/19/2014'

-- BETWEEN includes both begin and end dates

-- https://learn.microsoft.com/en-us/sql/t-sql/language-elements/between-transact-sql?view=sql-server-ver16

--8)	Create an email reminder list for the annual checkup by adding a year to the last visit.  
--a.	Include the Owner’s name, email, and animal name.  
--b.	Label the last visit as “Last Visit” and the next annual visit as “Annual Checkup Date”

USE Riverview
GO

SELECT O.FirstName, O.LastName, A.AnimalID, MAX(V.VisitDate) AS [Last Visit],
              DATEADD(YEAR, 1,MAX(V.VisitDate)) AS [Annual Checkup Date]
FROM (OwnerODS O INNER JOIN AnimalODS A ON O.OwnerID = A.OwnerID)
                                      INNER JOIN VisitODS V ON A.AnimalID = V.AnimalID
GROUP BY O.FirstName, O.LastName, A.AnimalID, V.VisitDate
ORDER BY MAX(V.VisitDate) 

--9)	What is the least popular month for a visit?  Return month name

USE Riverview
GO

SELECT TOP 1 DATENAME(MONTH,V.VisitDate) AS [Month]
FROM VisitODS V
GROUP BY DATENAME(MONTH,V.VisitDate)
ORDER BY COUNT(V.VisitID) ASC

--10)	 How much older are you than each animal (Your Bday – Animal Bday)?  
--a.	Return animal name, animal age, your age,  and the difference

USE Riverview
GO

DECLARE @YourBirthday date = '8/16/1958'
SELECT A.AnimalName,  DATEDIFF(YEAR,A.AnimalBirthDate,GETDATE()) AS [Animal Age],
											DATEDIFF(YYYY, @YourBirthday, GETDATE()) AS [My Age],
											DATEDIFF(YYYY, @YourBirthday, A.AnimalBirthDate) AS [Difference]							
FROM AnimalODS A
ORDER BY DATEDIFF(YYYY,A.AnimalBirthDate,GETDATE()) DESC
