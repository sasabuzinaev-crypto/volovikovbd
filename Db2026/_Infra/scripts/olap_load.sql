-- Загрузка выгруженных из MSSQL строк из olap.stg_* в таблицы измерений и фактов.
-- Перед запуском импортируйте CSV в соответствующие staging-таблицы.
-- Скрипт можно запускать повторно: существующие строки фактов обновляются.

DO $$
BEGIN
    INSERT INTO olap.dim_product (product_id, product_name)
    SELECT product_id, MAX(product_name)
    FROM (
        SELECT product_id, product_name FROM olap.stg_purchase
        UNION ALL
        SELECT product_id, product_name FROM olap.stg_sales
        UNION ALL
        SELECT product_id, product_name FROM olap.stg_inventory
    ) p
    GROUP BY product_id
    ON CONFLICT (product_id) DO UPDATE SET product_name = EXCLUDED.product_name;

    INSERT INTO olap.dim_vendor (vendor_id, vendor_name)
    SELECT vendor_id, MAX(vendor_name)
    FROM olap.stg_purchase
    WHERE vendor_id IS NOT NULL
    GROUP BY vendor_id
    ON CONFLICT (vendor_id) DO UPDATE SET vendor_name = EXCLUDED.vendor_name;

    INSERT INTO olap.dim_staff (staff_id, first_name, last_name)
    SELECT staff_id, MAX(first_name), MAX(last_name)
    FROM olap.stg_staff_work
    GROUP BY staff_id
    ON CONFLICT (staff_id) DO UPDATE
    SET first_name = EXCLUDED.first_name, last_name = EXCLUDED.last_name;

    INSERT INTO olap.dim_warehouse (warehouse_id, warehouse_name)
    SELECT warehouse_id, MAX(warehouse_name)
    FROM olap.stg_inventory
    GROUP BY warehouse_id
    ON CONFLICT (warehouse_id) DO UPDATE SET warehouse_name = EXCLUDED.warehouse_name;

    INSERT INTO olap.fact_purchase (month_code, product_id, vendor_id, quantity, amount)
    SELECT month_code, product_id, vendor_id, SUM(quantity), SUM(amount)
    FROM olap.stg_purchase
    GROUP BY month_code, product_id, vendor_id
    ON CONFLICT (month_code, product_id, vendor_id) DO UPDATE
    SET quantity = EXCLUDED.quantity, amount = EXCLUDED.amount;

    INSERT INTO olap.fact_sales (month_code, product_id, quantity, revenue)
    SELECT month_code, product_id, SUM(quantity), SUM(revenue)
    FROM olap.stg_sales
    GROUP BY month_code, product_id
    ON CONFLICT (month_code, product_id) DO UPDATE
    SET quantity = EXCLUDED.quantity, revenue = EXCLUDED.revenue;

    INSERT INTO olap.fact_staff_work (month_code, staff_id, document_count, amount)
    SELECT month_code, staff_id, SUM(document_count), SUM(amount)
    FROM olap.stg_staff_work
    GROUP BY month_code, staff_id
    ON CONFLICT (month_code, staff_id) DO UPDATE
    SET document_count = EXCLUDED.document_count, amount = EXCLUDED.amount;

    INSERT INTO olap.fact_inventory
        (month_code, week_start, warehouse_id, product_id, operation_id,
         operation_name, quantity, amount)
    SELECT month_code, week_start, warehouse_id, product_id, operation_id,
           MAX(operation_name), SUM(quantity), SUM(amount)
    FROM olap.stg_inventory
    GROUP BY month_code, week_start, warehouse_id, product_id, operation_id
    ON CONFLICT (week_start, warehouse_id, product_id, operation_id) DO UPDATE
    SET month_code = EXCLUDED.month_code,
        operation_name = EXCLUDED.operation_name,
        quantity = EXCLUDED.quantity,
        amount = EXCLUDED.amount;
END;
$$ LANGUAGE plpgsql;
