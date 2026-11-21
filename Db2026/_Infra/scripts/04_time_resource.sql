INSERT INTO stg_time
SELECT DISTINCT month_code
FROM stg_purchase
WHERE NOT EXISTS (
    SELECT code FROM stg_time WHERE code = stg_purchase.month_code
);

INSERT INTO stg_time
SELECT DISTINCT month_code
FROM stg_sales
WHERE NOT EXISTS (
    SELECT code FROM stg_time WHERE code = stg_sales.month_code
);

INSERT INTO stg_time
SELECT DISTINCT month_code
FROM stg_staff
WHERE NOT EXISTS (
    SELECT code FROM stg_time WHERE code = stg_staff.month_code
);

INSERT INTO stg_time
SELECT DISTINCT month_code
FROM stg_inventory
WHERE NOT EXISTS (
    SELECT code FROM stg_time WHERE code = stg_inventory.month_code
);

INSERT INTO resource_time
    (code, month_start, month_end, month_name, year, quarter_number, quarter_name)
SELECT
    code,
    to_date(code::text || '01', 'YYYYMMDD'),
    (to_date(code::text || '01', 'YYYYMMDD')
        + INTERVAL '1 month' - INTERVAL '1 day')::date,
    CASE code % 100
        WHEN 1 THEN 'Январь' WHEN 2 THEN 'Февраль' WHEN 3 THEN 'Март'
        WHEN 4 THEN 'Апрель' WHEN 5 THEN 'Май' WHEN 6 THEN 'Июнь'
        WHEN 7 THEN 'Июль' WHEN 8 THEN 'Август' WHEN 9 THEN 'Сентябрь'
        WHEN 10 THEN 'Октябрь' WHEN 11 THEN 'Ноябрь' WHEN 12 THEN 'Декабрь'
    END,
    code / 100,
    (code % 100 - 1) / 3 + 1,
    CASE (code % 100 - 1) / 3 + 1
        WHEN 1 THEN '1 квартал' WHEN 2 THEN '2 квартал'
        WHEN 3 THEN '3 квартал' WHEN 4 THEN '4 квартал'
    END
FROM stg_time
WHERE NOT EXISTS (
    SELECT code FROM resource_time WHERE code = stg_time.code
);
