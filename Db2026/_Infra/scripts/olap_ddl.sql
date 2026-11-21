-- Структура OLAP для анализа закупок, продаж, персонала и складских остатков.
-- Выполнить в новой базе PostgreSQL. Данные сначала загружаются в stg_*.

CREATE SCHEMA IF NOT EXISTS olap;

CREATE TABLE IF NOT EXISTS olap.dim_month (
    code integer PRIMARY KEY,                 -- YYYYMM
    month_start date NOT NULL UNIQUE,
    month_end date NOT NULL,
    month_name text NOT NULL,
    year integer NOT NULL,
    quarter_number integer NOT NULL CHECK (quarter_number BETWEEN 1 AND 4),
    quarter_name text NOT NULL
);

CREATE TABLE IF NOT EXISTS olap.dim_product (
    product_id integer PRIMARY KEY,            -- ID товара в Front
    product_name text
);

CREATE TABLE IF NOT EXISTS olap.dim_vendor (
    vendor_id integer PRIMARY KEY,
    vendor_name text
);

CREATE TABLE IF NOT EXISTS olap.dim_staff (
    staff_id integer PRIMARY KEY,
    first_name text,
    last_name text
);

CREATE TABLE IF NOT EXISTS olap.dim_warehouse (
    warehouse_id integer PRIMARY KEY,
    warehouse_name text
);

-- Закупки: месяц, товар и поставщик.
CREATE TABLE IF NOT EXISTS olap.fact_purchase (
    month_code integer NOT NULL REFERENCES olap.dim_month(code),
    product_id integer NOT NULL REFERENCES olap.dim_product(product_id),
    vendor_id integer NOT NULL REFERENCES olap.dim_vendor(vendor_id),
    quantity numeric(18, 3) NOT NULL DEFAULT 0,
    amount numeric(18, 2) NOT NULL DEFAULT 0,
    PRIMARY KEY (month_code, product_id, vendor_id)
);

-- Продажи: месяц и товар.
CREATE TABLE IF NOT EXISTS olap.fact_sales (
    month_code integer NOT NULL REFERENCES olap.dim_month(code),
    product_id integer NOT NULL REFERENCES olap.dim_product(product_id),
    quantity numeric(18, 3) NOT NULL DEFAULT 0,
    revenue numeric(18, 2) NOT NULL DEFAULT 0,
    PRIMARY KEY (month_code, product_id)
);

-- Работа персонала: месяц и сотрудник. Квартал и полугодие выводятся из dim_month.
CREATE TABLE IF NOT EXISTS olap.fact_staff_work (
    month_code integer NOT NULL REFERENCES olap.dim_month(code),
    staff_id integer NOT NULL REFERENCES olap.dim_staff(staff_id),
    document_count integer NOT NULL DEFAULT 0,
    amount numeric(18, 2) NOT NULL DEFAULT 0,
    PRIMARY KEY (month_code, staff_id)
);

-- Складские движения: неделя хранится датой понедельника; month_code связывает
-- движение с календарной метрикой месяца.
CREATE TABLE IF NOT EXISTS olap.fact_inventory (
    month_code integer NOT NULL REFERENCES olap.dim_month(code),
    week_start date NOT NULL,
    warehouse_id integer NOT NULL REFERENCES olap.dim_warehouse(warehouse_id),
    product_id integer NOT NULL REFERENCES olap.dim_product(product_id),
    operation_id integer NOT NULL,
    operation_name text,
    quantity numeric(18, 3) NOT NULL DEFAULT 0,
    amount numeric(18, 2) NOT NULL DEFAULT 0,
    PRIMARY KEY (week_start, warehouse_id, product_id, operation_id)
);

-- Промежуточные таблицы для результатов выгрузки из MSSQL.
CREATE TABLE IF NOT EXISTS olap.stg_purchase (
    month_code integer NOT NULL,
    product_id integer NOT NULL,
    product_name text,
    vendor_id integer NOT NULL,
    vendor_name text,
    quantity numeric(18, 3),
    amount numeric(18, 2)
);

CREATE TABLE IF NOT EXISTS olap.stg_sales (
    month_code integer NOT NULL,
    product_id integer NOT NULL,
    product_name text,
    quantity numeric(18, 3),
    revenue numeric(18, 2)
);

CREATE TABLE IF NOT EXISTS olap.stg_staff_work (
    month_code integer NOT NULL,
    staff_id integer NOT NULL,
    first_name text,
    last_name text,
    document_count integer,
    amount numeric(18, 2)
);

CREATE TABLE IF NOT EXISTS olap.stg_inventory (
    week_start date NOT NULL,
    month_code integer NOT NULL,
    warehouse_id integer NOT NULL,
    warehouse_name text,
    product_id integer NOT NULL,
    product_name text,
    operation_id integer NOT NULL,
    operation_name text,
    quantity numeric(18, 3),
    amount numeric(18, 2)
);

-- Представление ABC по закупкам и продажам: A — до 80% накопленной суммы,
-- B — следующие 15%, C — оставшиеся 5%.
CREATE OR REPLACE VIEW olap.v_purchase_abc AS
WITH totals AS (
    SELECT month_code, product_id, SUM(amount) AS amount
    FROM olap.fact_purchase
    GROUP BY month_code, product_id
), ranked AS (
    SELECT *, (SUM(amount) OVER (PARTITION BY month_code ORDER BY amount DESC, product_id)
             - amount) / NULLIF(SUM(amount) OVER (PARTITION BY month_code), 0) AS share_before
    FROM totals
)
SELECT month_code, product_id, amount,
       CASE WHEN share_before < 0.80 THEN 'A'
            WHEN share_before < 0.95 THEN 'B' ELSE 'C' END AS abc_group
FROM ranked;

CREATE OR REPLACE VIEW olap.v_sales_abc AS
WITH totals AS (
    SELECT month_code, product_id, SUM(revenue) AS revenue
    FROM olap.fact_sales
    GROUP BY month_code, product_id
), ranked AS (
    SELECT *, (SUM(revenue) OVER (PARTITION BY month_code ORDER BY revenue DESC, product_id)
             - revenue) / NULLIF(SUM(revenue) OVER (PARTITION BY month_code), 0) AS share_before
    FROM totals
)
SELECT month_code, product_id, revenue,
       CASE WHEN share_before < 0.80 THEN 'A'
            WHEN share_before < 0.95 THEN 'B' ELSE 'C' END AS abc_group
FROM ranked;
