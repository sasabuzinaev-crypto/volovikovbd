-- поля для результата проверки параметров пачки
alter table public.measurement_batchs
    add column if not exists has_error boolean not null default false;

alter table public.measurement_batchs
    add column if not exists error_description text;

create table if not exists public.parameter_error_messages (
    error_code text primary key,
    error_text text not null
);

delete from public.parameter_error_messages;

insert into public.parameter_error_messages (error_code, error_text)
values
    ('parameters_not_passed', 'список параметров не передан'),
    ('unknown_equipment', 'неизвестный тип оборудования'),
    ('drift_for_dmk', 'дальность сноса пуль не используется для дмк'),
    ('speed_for_vr', 'скорость ветра не используется для вр'),
    ('value_not_set', '%s: значение не задано'),
    ('below_minimum', '%s: значение меньше %s'),
    ('above_maximum', '%s: значение больше %s'),
    ('wrong_decimal_places', '%s: неправильное количество знаков после запятой');

do $$
begin
    if not exists (
        select 1
        from pg_type t
        join pg_namespace n on n.oid = t.typnamespace
        where n.nspname = 'public'
          and t.typname = 'measurement_parameters_type'
    ) then
        create type public.measurement_parameters_type as (
            measurement_equipment_id integer,
            height numeric,
            temperature numeric,
            pressure numeric,
            wind_direction numeric,
            wind_speed numeric,
            bullet_drift numeric
        );
    end if;
end;
$$;

create or replace function public.fn_check_parameters(par_parameters public.measurement_parameters_type)
returns text
language plpgsql
stable
as $$
declare
    var_parameter record;
    var_errors text := '';
    var_error text;
    var_error_template text;
begin
    if par_parameters is null then
        select error_text
        into var_errors
        from public.parameter_error_messages
        where error_code = 'parameters_not_passed';
        return var_errors;
    end if;

    if par_parameters.measurement_equipment_id is null
       or par_parameters.measurement_equipment_id not in (1, 2) then
        select error_text
        into var_errors
        from public.parameter_error_messages
        where error_code = 'unknown_equipment';
    elsif par_parameters.measurement_equipment_id = 1
       and par_parameters.bullet_drift is not null then
        select error_text
        into var_error
        from public.parameter_error_messages
        where error_code = 'drift_for_dmk';
        var_errors := concat_ws('; ', nullif(var_errors, ''), var_error);
    elsif par_parameters.measurement_equipment_id = 2
       and par_parameters.wind_speed is not null then
        select error_text
        into var_error
        from public.parameter_error_messages
        where error_code = 'speed_for_vr';
        var_errors := concat_ws('; ', nullif(var_errors, ''), var_error);
    end if;

    for var_parameter in
        select
            limits.parameter_name,
            limits.min_value,
            limits.max_value,
            limits.decimal_places,
            values_list.parameter_value
        from (
            values
                (1, par_parameters.height),
                (2, par_parameters.temperature),
                (3, par_parameters.pressure),
                (4, par_parameters.wind_direction),
                (5, par_parameters.wind_speed),
                (6, par_parameters.bullet_drift)
        ) as values_list(parameter_type_id, parameter_value)
        join public.parameter_limits limits
            on limits.parameter_type_id = values_list.parameter_type_id
        where limits.equipment_id is null
           or limits.equipment_id = par_parameters.measurement_equipment_id
        order by limits.parameter_type_id
    loop
        var_error := null;

        if var_parameter.parameter_value is null then
            select error_text
            into var_error_template
            from public.parameter_error_messages
            where error_code = 'value_not_set';
            var_error := format(var_error_template, var_parameter.parameter_name);
        elsif var_parameter.min_value is not null
          and var_parameter.parameter_value < var_parameter.min_value then
            select error_text
            into var_error_template
            from public.parameter_error_messages
            where error_code = 'below_minimum';
            var_error := format(var_error_template, var_parameter.parameter_name, var_parameter.min_value);
        elsif var_parameter.max_value is not null
          and var_parameter.parameter_value > var_parameter.max_value then
            select error_text
            into var_error_template
            from public.parameter_error_messages
            where error_code = 'above_maximum';
            var_error := format(var_error_template, var_parameter.parameter_name, var_parameter.max_value);
        elsif var_parameter.parameter_value <> round(
            var_parameter.parameter_value,
            var_parameter.decimal_places
        ) then
            select error_text
            into var_error_template
            from public.parameter_error_messages
            where error_code = 'wrong_decimal_places';
            var_error := format(var_error_template, var_parameter.parameter_name);
        end if;

        if var_error is not null then
            var_errors := concat_ws('; ', nullif(var_errors, ''), var_error);
        end if;
    end loop;

    return var_errors;
end;
$$;

comment on column public.measurement_batchs.has_error is
    'есть ли ошибки во входных параметрах пачки';
comment on column public.measurement_batchs.error_description is
    'список ошибок во входных параметрах пачки';
comment on type public.measurement_parameters_type is
    'тип со входными параметрами измерения';
comment on function public.fn_check_parameters(public.measurement_parameters_type) is
    'проверяет значения параметров и возвращает список ошибок';
