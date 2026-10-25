with parameter_list as (
    select
        batch.id,
        batch.employee_id,
        batch.measurement_equipment_id,
        max(param.measurement_value) filter (where param.measurement_parameter_type_id = 1) as height,
        max(param.measurement_value) filter (where param.measurement_parameter_type_id = 2) as temperature,
        max(param.measurement_value) filter (where param.measurement_parameter_type_id = 3) as pressure,
        max(param.measurement_value) filter (where param.measurement_parameter_type_id = 4) as wind_direction,
        max(param.measurement_value) filter (where param.measurement_parameter_type_id = 5) as wind_speed,
        max(param.measurement_value) filter (where param.measurement_parameter_type_id = 6) as bullet_drift
    from public.measurement_batchs batch
    left join public.measurement_input_params param
        on param.measurement_batch_id = batch.id
    group by batch.id, batch.employee_id, batch.measurement_equipment_id
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
), error_counts as (
    select
        employee.id,
        employee.name,
        count(error_item.error_text) as error_count
    from public.employees employee
    left join checked_parameters
        on checked_parameters.employee_id = employee.id
    left join lateral regexp_split_to_table(
        nullif(checked_parameters.errors, ''),
        '; '
    ) as error_item(error_text) on true
    group by employee.id, employee.name
), ranked_users as (
    select
        rank() over (order by error_count) as place,
        name,
        error_count
    from error_counts
)
select
    place as "место",
    name as "пользователь",
    error_count as "количество ошибок"
from ranked_users
order by error_count, name;
