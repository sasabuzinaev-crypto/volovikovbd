-- добавляем тестовые пачки с правильными и неправильными данными
insert into public.measurement_batchs (id, employee_id, measurement_equipment_id, started)
values
    (201, 1, 1, timestamp '2026-10-25 08:00:00'),
    (202, 1, 1, timestamp '2026-10-25 08:10:00'),
    (203, 1, 1, timestamp '2026-10-25 08:20:00'),
    (204, 1, 2, timestamp '2026-10-25 08:30:00'),
    (205, 1, 2, timestamp '2026-10-25 08:40:00')
on conflict (id) do update
set employee_id = excluded.employee_id,
    measurement_equipment_id = excluded.measurement_equipment_id,
    started = excluded.started;

insert into public.measurement_input_params
    (id, measurement_batch_id, measurement_parameter_type_id, measurement_value)
values
    -- пачка 201: правильные данные дмк
    (20101, 201, 1, 100),
    (20102, 201, 2, 15.0),
    (20103, 201, 3, 750),
    (20104, 201, 4, 30),
    (20105, 201, 5, 6),

    -- пачка 202: неправильная температура
    (20201, 202, 1, -5),
    (20202, 202, 2, 58.5),
    (20203, 202, 3, 500),
    (20204, 202, 4, 59),
    (20205, 202, 5, 15),

    -- пачка 203: несколько неправильных значений дмк
    (20301, 203, 1, 100.5),
    (20302, 203, 2, -58.5),
    (20303, 203, 3, 901),
    (20304, 203, 4, 60),
    (20305, 203, 5, 16),

    -- пачка 204: правильные данные вр
    (20401, 204, 1, 0),
    (20402, 204, 2, -10.5),
    (20403, 204, 3, 900),
    (20404, 204, 4, 0),
    (20406, 204, 6, 40),

    -- пачка 205: неправильные данные вр
    (20501, 205, 1, 1000),
    (20502, 205, 2, 60),
    (20503, 205, 3, 499),
    (20504, 205, 4, -1),
    (20506, 205, 6, 151)
on conflict (id) do update
set measurement_batch_id = excluded.measurement_batch_id,
    measurement_parameter_type_id = excluded.measurement_parameter_type_id,
    measurement_value = excluded.measurement_value;

with parameter_list as (
    select
        batch.id,
        batch.measurement_equipment_id,
        batch.started,
        max(param.measurement_value) filter (where param.measurement_parameter_type_id = 1) as height,
        max(param.measurement_value) filter (where param.measurement_parameter_type_id = 2) as temperature,
        max(param.measurement_value) filter (where param.measurement_parameter_type_id = 3) as pressure,
        max(param.measurement_value) filter (where param.measurement_parameter_type_id = 4) as wind_direction,
        max(param.measurement_value) filter (where param.measurement_parameter_type_id = 5) as wind_speed,
        max(param.measurement_value) filter (where param.measurement_parameter_type_id = 6) as bullet_drift
    from public.measurement_batchs batch
    left join public.measurement_input_params param
        on param.measurement_batch_id = batch.id
    where batch.id between 201 and 205
    group by batch.id, batch.measurement_equipment_id, batch.started
), checked_parameters as (
    select
        parameter_list.*,
        public.fn_check_parameters(row(
            measurement_equipment_id,
            height,
            temperature,
            pressure,
            wind_direction,
            wind_speed,
            bullet_drift
        )::public.measurement_parameters_type) as errors
    from parameter_list
), saved_errors as (
    update public.measurement_batchs batch
    set has_error = nullif(checked_parameters.errors, '') is not null,
        error_description = nullif(checked_parameters.errors, '')
    from checked_parameters
    where batch.id = checked_parameters.id
    returning batch.id, batch.has_error, batch.error_description
)
select
    checked_parameters.id as "№",
    case
        when checked_parameters.measurement_equipment_id = 1 then 'дмк'
        when checked_parameters.measurement_equipment_id = 2 then 'вр'
        else 'неизвестно'
    end as "тип оборудования",
    checked_parameters.height as "высота метеопоста",
    checked_parameters.temperature as "температура",
    checked_parameters.pressure as "давление",
    case
        when checked_parameters.wind_direction is null then null
        else lpad(checked_parameters.wind_direction::integer::text, 2, '0')
    end as "направление ветра",
    checked_parameters.wind_speed as "скорость ветра",
    checked_parameters.bullet_drift as "дальность сноса пуль",
    case when saved_errors.has_error then 'да' else 'нет' end as "флаг: есть ошибка",
    coalesce(saved_errors.error_description, 'нет ошибок') as "описание ошибки"
from checked_parameters
join saved_errors on saved_errors.id = checked_parameters.id
order by checked_parameters.id;
