
1.  
SELECT CONCAT(O.LastName, ', ', SUBSTRING(O.FirstName, 1, 1)) as [Name], O.City FROM OwnerODS O 
INNER JOIN 
WHERE LEFT(O.LastName, 1) NOT IN ('A', 'E', 'I', 'O', 'U', 'Y')
AND O.City LIKE '% %'

2.
SELECT A.AnimalName FROM AnimalODS A
INNER JOIN OwnerODS O ON O.OwnerID = A.OwnerID
WHERE LEN(O.Phone) = LEN(O.Address)
AND SUBSTRING(LEN(O.LastName) - 1, 1) = SUBSTRING(LEN(O.FirstName) - 1, 1)

3.
SELECT CONCAT(O.FirstName, ' ', O.LastName) AS [Full name], A.AnimalName, A.AnimalType, A.AnimalBirthDate, LEN(A.AnimalName) AS [# of char] FROM OwnerODS O 
INNER JOIN AnimalODS A ON A.OwnerID = O.OwnerID
WHERE A.AnimalType = 'Dog'
ORDER BY A.AnimalBirthDate DESC
OFFSET 2 ROWS FETCH NEXT 1 ROW ONLY

4. 
SELECT TOP 5 CONCAT(O.LastName, ', ', O.FirstName) AS [Full Name], SUM(B.InvoiceAmt) AS [Amount Paid]
FROM OwnerODS O
INNER JOIN AnimalODS A ON O.OwnerID = A.OwnerID
INNER JOIN VisitODS V ON A.AnimalID = V.AnimalID
INNER JOIN BillingODS B ON V.VisitID = B.VisitID
WHERE O.City = 'Cody'
AND B.InvoicePaid = 1
GROUP BY O.LastName, O.FirstName
HAVING SUM(B.InvoiceAmt) > 200

5.
SELECT TOP 5 V.VisitDate