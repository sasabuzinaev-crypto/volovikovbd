-- 1. Добавляем вычисляемые колонки в таблицу типов параметров
ALTER TABLE measurement_parameter_types 
ADD COLUMN IF NOT EXISTS min_val NUMERIC GENERATED ALWAYS AS (
    CASE id
        WHEN 1 THEN 100
        WHEN 2 THEN -30
        WHEN 3 THEN 900
        WHEN 4 THEN 0
        WHEN 5 THEN 0
        WHEN 6 THEN 0
        ELSE 0
    END
) STORED;

ALTER TABLE measurement_parameter_types 
ADD COLUMN IF NOT EXISTS max_val NUMERIC GENERATED ALWAYS AS (
    CASE id
        WHEN 1 THEN 200
        WHEN 2 THEN 50
        WHEN 3 THEN 1100
        WHEN 4 THEN 360
        WHEN 5 THEN 50
        WHEN 6 THEN 300
        ELSE 1000
    END
) STORED;

-- 2. Вставляем 6 пачек измерений (measurement_batchs)
INSERT INTO measurement_batchs (id, employee_id, measurement_equipment_id, started)
VALUES 
    (101, 1, 1, now() - interval '5 days'),
    (102, 2, 1, now() - interval '4 days'),
    (103, 3, 1, now() - interval '3 days'),
    (104, 1, 1, now() - interval '2 days'),
    (105, 2, 1, now() - interval '1 day'),
    (106, 3, 1, now())
ON CONFLICT (id) DO NOTHING;

-- 3. Вставляем замеры (measurement_input_params)
INSERT INTO measurement_input_params (id, measurement_batch_id, measurement_parameter_type_id, measurement_value)
VALUES
-- Пачка 101
(10101, 101, 1, floor(100 + (200 - 100) * random() + 0.5)),
(10102, 101, 2, floor(-30 + (50 - (-30)) * random() + 0.5)),
(10103, 101, 3, floor(900 + (1100 - 900) * random() + 0.5)),
(10104, 101, 4, floor(0 + (360 - 0) * random() + 0.5)),
(10105, 101, 5, floor(0 + (50 - 0) * random() + 0.5)),

-- Пачка 102
(10201, 102, 1, floor(100 + (200 - 100) * random() + 0.5)),
(10202, 102, 2, floor(-30 + (50 - (-30)) * random() + 0.5)),
(10203, 102, 3, floor(900 + (1100 - 900) * random() + 0.5)),
(10204, 102, 4, floor(0 + (360 - 0) * random() + 0.5)),
(10205, 102, 5, floor(0 + (50 - 0) * random() + 0.5)),

-- Пачка 103
(10301, 103, 1, floor(100 + (200 - 100) * random() + 0.5)),
(10302, 103, 2, floor(-30 + (50 - (-30)) * random() + 0.5)),
(10303, 103, 3, floor(900 + (1100 - 900) * random() + 0.5)),
(10304, 103, 4, floor(0 + (360 - 0) * random() + 0.5)),
(10305, 103, 5, floor(0 + (50 - 0) * random() + 0.5)),

-- Пачка 104
(10401, 104, 1, floor(100 + (200 - 100) * random() + 0.5)),
(10402, 104, 2, floor(-30 + (50 - (-30)) * random() + 0.5)),
(10403, 104, 3, floor(900 + (1100 - 900) * random() + 0.5)),
(10404, 104, 4, floor(0 + (360 - 0) * random() + 0.5)),
(10405, 104, 5, floor(0 + (50 - 0) * random() + 0.5)),

-- Пачка 105
(10501, 105, 1, floor(100 + (200 - 100) * random() + 0.5)),
(10502, 105, 2, floor(-30 + (50 - (-30)) * random() + 0.5)),
(10503, 105, 3, floor(900 + (1100 - 900) * random() + 0.5)),
(10504, 105, 4, floor(0 + (360 - 0) * random() + 0.5)),
(10505, 105, 5, floor(0 + (50 - 0) * random() + 0.5)),

-- Пачка 106
(10601, 106, 1, floor(100 + (200 - 100) * random() + 0.5)),
(10602, 106, 2, floor(-30 + (50 - (-30)) * random() + 0.5)),
(10603, 106, 3, floor(900 + (1100 - 900) * random() + 0.5)),
(10604, 106, 4, floor(0 + (360 - 0) * random() + 0.5)),
(10605, 106, 5, floor(0 + (50 - 0) * random() + 0.5))
ON CONFLICT (id) DO NOTHING;