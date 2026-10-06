COMMENT ON TABLE measurement_input_params IS '1. Каждый пользователь имеет одинаковое количество измерений?';

SELECT 
    e.id AS employee_id,
    e.name AS employee_name,
    COUNT(p.id) AS total_measurements
FROM employees e
LEFT JOIN measurement_batchs b 
    ON e.id = b.employee_id AND b.id BETWEEN 101 AND 106
LEFT JOIN measurement_input_params p 
    ON b.id = p.measurement_batch_id
GROUP BY e.id, e.name;


COMMENT ON TABLE measurement_input_params IS '2. Отсутствие пустых пачек измерений (LEFT JOIN)?';

SELECT 
    b.id AS batch_id,
    b.employee_id,
    COUNT(p.id) AS params_count
FROM measurement_batchs b
LEFT JOIN measurement_input_params p ON b.id = p.measurement_batch_id
WHERE b.id BETWEEN 101 AND 106
GROUP BY b.id, b.employee_id
HAVING COUNT(p.id) = 0;


COMMENT ON TABLE measurement_input_params IS '3. Каждая пачка измерений содержит полное количество параметров (5 шт)?';

SELECT 
    b.id AS batch_id,
    COUNT(DISTINCT p.measurement_parameter_type_id) AS actual_params_count
FROM measurement_batchs b
LEFT JOIN measurement_input_params p ON b.id = p.measurement_batch_id
WHERE b.id BETWEEN 101 AND 106
GROUP BY b.id
HAVING COUNT(DISTINCT p.measurement_parameter_type_id) != 5;


COMMENT ON TABLE measurement_input_params IS '4. Все значения который сформировал корректны и в рамках нужного нам диапазонов?';

SELECT 
    p.id AS measurement_id,
    p.measurement_batch_id,
    mpt.name AS parameter_name,
    p.measurement_value,
    mpt.min_val,
    mpt.max_val
FROM measurement_input_params p
LEFT JOIN measurement_parameter_types mpt 
    ON p.measurement_parameter_type_id = mpt.id
WHERE p.measurement_batch_id BETWEEN 101 AND 106
  AND (p.measurement_value < mpt.min_val OR p.measurement_value > mpt.max_val);


COMMENT ON TABLE measurement_input_params IS '5. Все единицы измерения верны и корректны по отношению к указанным параметрам?';

SELECT 
    mpt.name AS parameter_name,
    u.name AS unit_name,
    bu.name AS base_unit_name
FROM measurement_parameter_types mpt
LEFT JOIN units u ON mpt.unit_id = u.id
LEFT JOIN base_units bu ON u.base_unit_id = bu.id
WHERE 
    (mpt.id = 2 AND bu.name != 'Градус')
    OR (mpt.id = 3 AND bu.name != 'Паскаль' AND u.name NOT LIKE '%ртутного столба%')
    OR (mpt.id = 1 AND bu.name != 'Метр');