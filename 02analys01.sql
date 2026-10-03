COMMENT ON TABLE measurements IS '1. Проверяем, у всех ли юзеров одинаковое количество записей. Джойним юзеров и считаем сколько у кого строк и пачек.';

WITH users AS (
    SELECT DISTINCT user_id FROM measurements
)
SELECT 
    u.user_id,
    COUNT(m.id) AS total_records,
    COUNT(DISTINCT m.batch_id) AS total_batches
FROM users u
LEFT JOIN measurements m ON u.user_id = m.user_id
GROUP BY u.user_id;


COMMENT ON TABLE measurements IS '2. Проверяем, есть ли пустые пачки. Берем список всех пачек и смотрим, есть ли те, где нет строк.';

WITH batches AS (
    SELECT DISTINCT batch_id FROM measurements
)
SELECT 
    b.batch_id,
    COUNT(m.id) AS records_count
FROM batches b
LEFT JOIN measurements m ON b.batch_id = m.batch_id
GROUP BY b.batch_id
HAVING COUNT(m.id) = 0;


COMMENT ON TABLE measurements IS '3. Проверяем, во всех ли пачках ровно 5 параметров. Считаем количество уникальных параметров на каждую пачку.';

WITH batches AS (
    SELECT DISTINCT batch_id FROM measurements
),
param_counts AS (
    SELECT 
        batch_id,
        COUNT(DISTINCT parameter_name) AS cnt
    FROM measurements
    GROUP BY batch_id
)
SELECT 
    b.batch_id,
    p.cnt AS total_params
FROM batches b
LEFT JOIN param_counts p ON b.batch_id = p.batch_id
WHERE p.cnt != 5 OR p.cnt IS NULL;


COMMENT ON TABLE measurements IS '4. Проверяем значения на допустимые диапазоны. Делаем табличку с мин и макс и джойним к измерениям.';

WITH limits(param_name, min_val, max_val) AS (
    VALUES
        ('heart_rate', 60, 100),
        ('systolic_pressure', 110, 130),
        ('diastolic_pressure', 70, 85),
        ('body_temperature', 36.1, 37.2),
        ('spo2', 95, 100)
)
SELECT 
    m.id,
    m.parameter_name,
    m.parameter_value,
    l.min_val,
    l.max_val
FROM measurements m
LEFT JOIN limits l 
    ON m.parameter_name = l.param_name
   AND m.parameter_value BETWEEN l.min_val AND l.max_val
WHERE l.param_name IS NULL;


COMMENT ON TABLE measurements IS '5. Проверяем правильность единиц измерения. Сверяем фактические единицы с эталонным справочником.';

WITH correct_units(param_name, proper_unit) AS (
    VALUES
        ('heart_rate', 'bpm'),
        ('systolic_pressure', 'mmHg'),
        ('diastolic_pressure', 'mmHg'),
        ('body_temperature', 'C'),
        ('spo2', '%')
)
SELECT 
    m.id,
    m.parameter_name,
    m.unit AS current_unit,
    u.proper_unit
FROM measurements m
LEFT JOIN correct_units u 
    ON m.parameter_name = u.param_name 
   AND m.unit = u.proper_unit
WHERE u.param_name IS NULL;