COMMENT ON TABLE measurement_input_params IS '1. Проверяем, у всех ли пользователей одинаковое количество записей и пачек';

SELECT 
    e.id AS employee_id,
    e.name AS employee_name,
    COUNT(p.id) AS total_records,
    COUNT(DISTINCT b.id) AS total_batches
FROM employees e
LEFT JOIN measurement_batchs b ON e.id = b.employee_id
LEFT JOIN measurement_input_params p ON b.id = p.measurement_batch_id
GROUP BY e.id, e.name;


COMMENT ON TABLE measurement_input_params IS '2. Проверяем наличие пустых пачек через LEFT JOIN';

SELECT 
    b.id AS batch_id,
    b.employee_id,
    COUNT(p.id) AS records_count
FROM measurement_batchs b
LEFT JOIN measurement_input_params p ON b.id = p.measurement_batch_id
GROUP BY b.id, b.employee_id
HAVING COUNT(p.id) = 0;


COMMENT ON TABLE measurement_input_params IS '3. Проверяем, во всех ли пачках оборудования ДМК ровно 5 параметров';

SELECT 
    b.id AS batch_id,
    COUNT(DISTINCT p.measurement_parameter_type_id) AS actual_params_count
FROM measurement_batchs b
LEFT JOIN measurement_input_params p ON b.id = p.measurement_batch_id
WHERE b.measurement_equipment_id = 1
GROUP BY b.id
HAVING COUNT(DISTINCT p.measurement_parameter_type_id) != 5;


COMMENT ON TABLE measurement_input_params IS '4. Проверяем значения измерений на допустимые диапазоны';

WITH limits(type_id, min_val, max_val) AS (
    VALUES
        (1, 100.0::numeric, 200.0::numeric),  
        (2, -30.0::numeric, 50.0::numeric),  
        (3, 900.0::numeric, 1100.0::numeric), 
        (4, 0.0::numeric, 360.0::numeric),    
        (5, 0.0::numeric, 50.0::numeric)      
)
SELECT 
    p.id,
    p.measurement_batch_id,
    p.measurement_parameter_type_id,
    p.measurement_value,
    l.min_val,
    l.max_val
FROM measurement_input_params p
LEFT JOIN limits l 
    ON p.measurement_parameter_type_id = l.type_id
   AND p.measurement_value BETWEEN l.min_val AND l.max_val
WHERE l.type_id IS NULL;


COMMENT ON TABLE measurement_input_params IS '5. Проверяем привязку параметров к единицам измерения';

SELECT 
    p.id AS input_param_id,
    mpt.name AS parameter_name,
    u.name AS unit_name
FROM measurement_input_params p
LEFT JOIN measurement_parameter_types mpt 
    ON p.measurement_parameter_type_id = mpt.id
LEFT JOIN units u 
    ON mpt.unit_id = u.id
WHERE mpt.id IS NULL;