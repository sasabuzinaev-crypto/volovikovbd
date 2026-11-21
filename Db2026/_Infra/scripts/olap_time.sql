-- Заполнение календарного измерения месяцами, которые присутствуют в staging.
-- Запустить после импорта выгрузок и до olap_load.sql.
-- Код месяца имеет формат YYYYMM; квартал хранится номером и названием.

DO $$
DECLARE
    first_month date;
    last_month date;
BEGIN
    SELECT MIN(to_date(month_code::text || '01', 'YYYYMMDD')),
           MAX(to_date(month_code::text || '01', 'YYYYMMDD'))
      INTO first_month, last_month
    FROM (
        SELECT month_code FROM olap.stg_purchase
        UNION ALL SELECT month_code FROM olap.stg_sales
        UNION ALL SELECT month_code FROM olap.stg_staff_work
        UNION ALL SELECT month_code FROM olap.stg_inventory
    ) periods;

    IF first_month IS NULL THEN
        RAISE EXCEPTION 'Staging пуст. Сначала импортируйте выгрузки MSSQL в olap.stg_*';
    END IF;

    INSERT INTO olap.dim_month
        (code, month_start, month_end, month_name, year, quarter_number, quarter_name)
    SELECT
        to_char(m, 'YYYYMM')::integer,
        m::date,
        (m + INTERVAL '1 month - 1 day')::date,
        CASE EXTRACT(MONTH FROM m)::integer
            WHEN 1 THEN 'Январь' WHEN 2 THEN 'Февраль' WHEN 3 THEN 'Март'
            WHEN 4 THEN 'Апрель' WHEN 5 THEN 'Май' WHEN 6 THEN 'Июнь'
            WHEN 7 THEN 'Июль' WHEN 8 THEN 'Август' WHEN 9 THEN 'Сентябрь'
            WHEN 10 THEN 'Октябрь' WHEN 11 THEN 'Ноябрь' WHEN 12 THEN 'Декабрь'
        END,
        EXTRACT(YEAR FROM m)::integer,
        EXTRACT(QUARTER FROM m)::integer,
        EXTRACT(QUARTER FROM m)::integer || '-й квартал'
    FROM generate_series(first_month, last_month, INTERVAL '1 month') AS g(m)
    ON CONFLICT (code) DO UPDATE SET
        month_start = EXCLUDED.month_start,
        month_end = EXCLUDED.month_end,
        month_name = EXCLUDED.month_name,
        year = EXCLUDED.year,
        quarter_number = EXCLUDED.quarter_number,
        quarter_name = EXCLUDED.quarter_name;
END;
$$ LANGUAGE plpgsql;
