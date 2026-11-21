DO $$
BEGIN
    INSERT INTO purchase (month_code, product_id, product_name, vendor_id,
                          vendor_name, quantity, amount)
    SELECT month_code, product_id, product_name, vendor_id,
           vendor_name, quantity, amount
    FROM stg_purchase;

    INSERT INTO sales (month_code, product_id, product_name, quantity, revenue)
    SELECT month_code, product_id, product_name, quantity, revenue
    FROM stg_sales;

    INSERT INTO staff_work (month_code, staff_id, first_name, last_name,
                            document_count, amount)
    SELECT month_code, staff_id, first_name, last_name, document_count, amount
    FROM stg_staff;

    INSERT INTO inventory (year, iso_week, month_code, warehouse_id, warehouse_name,
                           product_id, product_name, operation_id, operation_name,
                           quantity, amount)
    SELECT year, iso_week, month_code, warehouse_id, warehouse_name,
           product_id, product_name, operation_id, operation_name,
           quantity, amount
    FROM stg_inventory;
END;
$$;
