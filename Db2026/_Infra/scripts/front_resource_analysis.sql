-- Анализ ресурсов Front. Запросы только читают данные. Используется базовый стиль SELECT/JOIN/WHERE/GROUP BY/ORDER BY проекта.

-- Закупки по месяцам
SELECT TOP 10 o.Period AS [Month],p.ID AS ProductID,p.description AS Product,o.VendorID AS VendorID,v.firstname AS Vendor,SUM(o.Count) AS Quantity,SUM(o.Amount) AS Amount
FROM Front.dbo.bm_StorageOperations o
LEFT JOIN Front.dbo.product p ON p.ID=o.ProductID
LEFT JOIN Front.dbo.vendors v ON v.ID=o.VendorID
LEFT JOIN Front.dbo.bm_JournalBarnetDocs h ON h.ID=o.DocumentID
WHERE o.OperationID=1 AND h.IsUse=1
GROUP BY o.Period,p.ID,p.description,o.VendorID,v.firstname
ORDER BY o.Period DESC,SUM(o.Amount) DESC;

-- Продажи по месяцам и товарам
SELECT TOP 12 YEAR(j.dater) AS [Year],MONTH(j.dater) AS [Month],j.id AS ProductCode,p.description AS Product,SUM(j.quantity) AS Quantity,SUM(j.amount) AS Revenue
FROM Front.dbo.journal j
JOIN Front.dbo.product p ON p.productid=j.id
WHERE j.id<>''
GROUP BY YEAR(j.dater),MONTH(j.dater),j.id,p.description
ORDER BY YEAR(j.dater) DESC,MONTH(j.dater) DESC,SUM(j.amount) DESC;

-- Поставщики по месяцам
SELECT TOP 12 o.Period AS [Month],o.VendorID AS VendorID,v.firstname AS Vendor,COUNT(DISTINCT o.DocumentID) AS DocumentCount,SUM(o.Count) AS Quantity,SUM(o.Amount) AS Amount
FROM Front.dbo.bm_StorageOperations o
LEFT JOIN Front.dbo.vendors v ON v.ID=o.VendorID
LEFT JOIN Front.dbo.bm_JournalBarnetDocs h ON h.ID=o.DocumentID
WHERE o.OperationID=1 AND h.IsUse=1 AND o.VendorID>0
GROUP BY o.Period,o.VendorID,v.firstname
ORDER BY o.Period DESC,SUM(o.Amount) DESC;

-- Персонал по кварталам
SELECT TOP 12 YEAR(h.Period) AS [Year],DATEPART(QUARTER,h.Period) AS [Quarter],h.PersonID AS PersonID,p.firstname AS FirstName,p.lastname AS LastName,COUNT(*) AS DocumentCount,SUM(h.Amount) AS Amount
FROM Front.dbo.bm_JournalBarnetDocs h
JOIN Front.dbo.personnel p ON p.personid=h.PersonID
WHERE h.IsUse=1
GROUP BY YEAR(h.Period),DATEPART(QUARTER,h.Period),h.PersonID,p.firstname,p.lastname
ORDER BY YEAR(h.Period) DESC,DATEPART(QUARTER,h.Period) DESC,SUM(h.Amount) DESC;

-- Персонал по полугодиям
SELECT TOP 12 YEAR(h.Period) AS [Year],CASE WHEN DATEPART(QUARTER,h.Period)<=2 THEN 1 ELSE 2 END AS HalfYear,h.PersonID AS PersonID,p.firstname AS FirstName,p.lastname AS LastName,COUNT(*) AS DocumentCount,SUM(h.Amount) AS Amount
FROM Front.dbo.bm_JournalBarnetDocs h
JOIN Front.dbo.personnel p ON p.personid=h.PersonID
WHERE h.IsUse=1
GROUP BY YEAR(h.Period),CASE WHEN DATEPART(QUARTER,h.Period)<=2 THEN 1 ELSE 2 END,h.PersonID,p.firstname,p.lastname
ORDER BY YEAR(h.Period) DESC,CASE WHEN DATEPART(QUARTER,h.Period)<=2 THEN 1 ELSE 2 END DESC,SUM(h.Amount) DESC;

-- Недельное движение по складам и товарам
SELECT TOP 12 YEAR(o.DateAdd) AS [Year],DATEPART(ISO_WEEK,o.DateAdd) AS ISOWeek,o.StorageID AS StorageID,s.description AS Storage,o.ProductID AS ProductID,p.description AS Product,t.Description AS OperationType,SUM(o.Count) AS Quantity,SUM(o.Amount) AS Amount
FROM Front.dbo.bm_StorageOperations o
JOIN Front.dbo.bm_StorageOperationsType t ON t.ID=o.OperationID
LEFT JOIN Front.dbo.storages s ON s.id=o.StorageID
LEFT JOIN Front.dbo.product p ON p.ID=o.ProductID
WHERE o.OperationID>0
GROUP BY YEAR(o.DateAdd),DATEPART(ISO_WEEK,o.DateAdd),o.StorageID,s.description,o.ProductID,p.description,t.Description
ORDER BY YEAR(o.DateAdd) DESC,DATEPART(ISO_WEEK,o.DateAdd) DESC,SUM(o.Amount) DESC;
