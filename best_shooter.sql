with parameter_list as (
    select
        batch.id,
        batch.employee_id,
        batch.measurement_equipment_id,
        max(case when param.measurement_parameter_type_id = 1 then param.measurement_value end) as height,
        max(case when param.measurement_parameter_type_id = 2 then param.measurement_value end) as temperature,
        max(case when param.measurement_parameter_type_id = 3 then param.measurement_value end) as pressure,
        max(case when param.measurement_parameter_type_id = 4 then param.measurement_value end) as wind_direction,
        max(case when param.measurement_parameter_type_id = 5 then param.measurement_value end) as wind_speed,
        max(case when param.measurement_parameter_type_id = 6 then param.measurement_value end) as bullet_drift
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
        count(case when checked_parameters.errors <> '' then 1 end) as error_count
    from public.employees employee
    left join checked_parameters
        on checked_parameters.employee_id = employee.id
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
