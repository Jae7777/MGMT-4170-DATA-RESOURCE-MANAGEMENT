(6 bonus points, pet names)
nala
run
jojo the cat

follow syntax as per class
SELECT A.AnimalName
FROM OwnerODS O INNER JOIN AnimalODS A ON O.OwnerId = A.OwnerID
WHERE LEN(O.Phone) = LEN(O.Address)
AND SUBSTRING(O.LastName, LEN(O.LastName) - 1, 1) = SUBSTRING(O.FirstName, LEN(O.FirstName) - 1, 1)

-- What has not has a visit? Dont show the animals that have had a visit

-- How many bogs were born between 4/29/2009 AND 05/19/2014

-- Create an email reminder list for the annual checkup by adding a year to the last viist.
-- a. Include the Owner's name, email and animal name.
-- b. Label the last visit as "Last Visit" and the next annual visit as "Annual Checkup Date"

-- What is the leasat popular month for a visit? Return month name

-- How much older are you than each animal (Your Bday - Animal Bday)?
-- a. Return animal name, animal age, your age, and the difference