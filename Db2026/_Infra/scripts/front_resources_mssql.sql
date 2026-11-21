-- Выборки из Front для переноса в PostgreSQL OLAP.
-- Выполнять в MSSQL, выгружать каждый результат отдельно в CSV.
-- Порядок и имена колонок соответствуют таблицам olap.stg_*.

-- 1. Закупки по месяцам, товарам и поставщикам.
SELECT
    CAST(o.Period AS int) AS month_code,
    p.ID AS product_id,
    p.description AS product_name,
    ISNULL(o.VendorID, 0) AS vendor_id,
    v.firstname AS vendor_name,
    SUM(o.Count) AS quantity,
    SUM(o.Amount) AS amount
FROM Front.dbo.bm_StorageOperations o
JOIN Front.dbo.product p ON p.ID = o.ProductID
LEFT JOIN Front.dbo.vendors v ON v.ID = o.VendorID
JOIN Front.dbo.bm_JournalBarnetDocs h ON h.ID = o.DocumentID
WHERE o.OperationID = 1 AND h.IsUse = 1
GROUP BY CAST(o.Period AS int), p.ID, p.description, ISNULL(o.VendorID, 0), v.firstname;

-- 2. Продажи по месяцам и товарам.
SELECT
    YEAR(j.dater) * 100 + MONTH(j.dater) AS month_code,
    p.ID AS product_id,
    p.description AS product_name,
    SUM(j.quantity) AS quantity,
    SUM(j.amount) AS revenue
FROM Front.dbo.journal j
JOIN Front.dbo.product p ON p.productid = j.id
WHERE j.id <> ''
GROUP BY YEAR(j.dater) * 100 + MONTH(j.dater), p.ID, p.description;

-- 3. Работа персонала по месяцам. Квартальные и полугодовые итоги строятся
-- в OLAP агрегацией этих месячных строк.
SELECT
    YEAR(h.Period) * 100 + MONTH(h.Period) AS month_code,
    h.PersonID AS staff_id,
    p.firstname AS first_name,
    p.lastname AS last_name,
    COUNT(*) AS document_count,
    SUM(h.Amount) AS amount
FROM Front.dbo.bm_JournalBarnetDocs h
JOIN Front.dbo.personnel p ON p.personid = h.PersonID
WHERE h.IsUse = 1
GROUP BY YEAR(h.Period) * 100 + MONTH(h.Period), h.PersonID, p.firstname, p.lastname;

-- 4. Недельные складские движения по складу, товару и типу операции.
SELECT
    CAST(DATEADD(day, -(DATEDIFF(day, '19000101', CAST(o.DateAdd AS date)) % 7),
         CAST(o.DateAdd AS date)) AS date) AS week_start,
    YEAR(o.DateAdd) * 100 + MONTH(o.DateAdd) AS month_code,
    ISNULL(o.StorageID, 0) AS warehouse_id,
    s.description AS warehouse_name,
    p.ID AS product_id,
    p.description AS product_name,
    o.OperationID AS operation_id,
    t.Description AS operation_name,
    SUM(o.Count) AS quantity,
    SUM(o.Amount) AS amount
FROM Front.dbo.bm_StorageOperations o
JOIN Front.dbo.bm_StorageOperationsType t ON t.ID = o.OperationID
LEFT JOIN Front.dbo.storages s ON s.id = o.StorageID
JOIN Front.dbo.product p ON p.ID = o.ProductID
WHERE o.OperationID > 0
GROUP BY CAST(DATEADD(day, -(DATEDIFF(day, '19000101', CAST(o.DateAdd AS date)) % 7),
         CAST(o.DateAdd AS date)) AS date),
         YEAR(o.DateAdd) * 100 + MONTH(o.DateAdd), ISNULL(o.StorageID, 0), s.description,
         p.ID, p.description, o.OperationID, t.Description;
