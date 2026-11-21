-- Шаг 1. Выполнить CREATE DATABASE отдельно, подключиться к front_olap,
-- затем выполнить оставшуюся часть файла в новой базе.

CREATE DATABASE front_olap;

-- Таблицы ниже создать уже после подключения к front_olap.
CREATE TABLE stg_purchase (
    month_code integer,
    product_id integer,
    product_name text,
    vendor_id integer,
    vendor_name text,
    quantity numeric(18, 3),
    amount numeric(18, 2)
);

CREATE TABLE stg_sales (
    month_code integer,
    product_id integer,
    product_name text,
    quantity numeric(18, 3),
    revenue numeric(18, 2)
);

CREATE TABLE stg_staff (
    month_code integer,
    staff_id integer,
    first_name text,
    last_name text,
    document_count integer,
    amount numeric(18, 2)
);

CREATE TABLE stg_inventory (
    year integer,
    iso_week integer,
    month_code integer,
    warehouse_id integer,
    warehouse_name text,
    product_id integer,
    product_name text,
    operation_id integer,
    operation_name text,
    quantity numeric(18, 3),
    amount numeric(18, 2)
);

CREATE TABLE purchase (
    month_code integer,
    product_id integer,
    product_name text,
    vendor_id integer,
    vendor_name text,
    quantity numeric(18, 3),
    amount numeric(18, 2)
);

CREATE TABLE sales (
    month_code integer,
    product_id integer,
    product_name text,
    quantity numeric(18, 3),
    revenue numeric(18, 2)
);

CREATE TABLE staff_work (
    month_code integer,
    staff_id integer,
    first_name text,
    last_name text,
    document_count integer,
    amount numeric(18, 2)
);

CREATE TABLE inventory (
    year integer,
    iso_week integer,
    month_code integer,
    warehouse_id integer,
    warehouse_name text,
    product_id integer,
    product_name text,
    operation_id integer,
    operation_name text,
    quantity numeric(18, 3),
    amount numeric(18, 2)
);

CREATE TABLE stg_time (
    code integer
);

CREATE TABLE resource_time (
    code integer,
    month_start date,
    month_end date,
    month_name text,
    year integer,
    quarter_number integer,
    quarter_name text
);
