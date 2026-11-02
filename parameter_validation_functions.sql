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
    ('value_not_set', 'значение не задано'),
    ('below_minimum', 'значение меньше'),
    ('above_maximum', 'значение больше'),
    ('wrong_decimal_places', 'неправильное количество знаков после запятой');

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
as $$
declare
    var_errors text := '';
    var_error text;
    var_parameter_name text;
    var_min_value numeric;
    var_max_value numeric;
    var_decimal_places integer;
    var_parameter_value numeric;
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
        into var_errors
        from public.parameter_error_messages
        where error_code = 'drift_for_dmk';
    elsif par_parameters.measurement_equipment_id = 2
       and par_parameters.wind_speed is not null then
        select error_text
        into var_errors
        from public.parameter_error_messages
        where error_code = 'speed_for_vr';
    end if;

    select parameter_name, min_value, max_value, decimal_places
    into var_parameter_name, var_min_value, var_max_value, var_decimal_places
    from public.parameter_limits
    where parameter_type_id = 1;
    var_parameter_value := par_parameters.height;
    var_error := null;
    if var_parameter_value is null then
        select error_text into var_error from public.parameter_error_messages where error_code = 'value_not_set';
        var_error := var_parameter_name || ': ' || var_error;
    elsif var_parameter_value <> round(var_parameter_value, var_decimal_places) then
        select error_text into var_error from public.parameter_error_messages where error_code = 'wrong_decimal_places';
        var_error := var_parameter_name || ': ' || var_error;
    end if;
    if var_error is not null then
        if var_errors = '' then var_errors := var_error; else var_errors := var_errors || '; ' || var_error; end if;
    end if;

    select parameter_name, min_value, max_value, decimal_places
    into var_parameter_name, var_min_value, var_max_value, var_decimal_places
    from public.parameter_limits
    where parameter_type_id = 2;
    var_parameter_value := par_parameters.temperature;
    var_error := null;
    if var_parameter_value is null then
        select error_text into var_error from public.parameter_error_messages where error_code = 'value_not_set';
        var_error := var_parameter_name || ': ' || var_error;
    elsif var_parameter_value < var_min_value then
        select error_text into var_error from public.parameter_error_messages where error_code = 'below_minimum';
        var_error := var_parameter_name || ': ' || var_error || ' ' || var_min_value::text;
    elsif var_parameter_value > var_max_value then
        select error_text into var_error from public.parameter_error_messages where error_code = 'above_maximum';
        var_error := var_parameter_name || ': ' || var_error || ' ' || var_max_value::text;
    elsif var_parameter_value <> round(var_parameter_value, var_decimal_places) then
        select error_text into var_error from public.parameter_error_messages where error_code = 'wrong_decimal_places';
        var_error := var_parameter_name || ': ' || var_error;
    end if;
    if var_error is not null then
        if var_errors = '' then var_errors := var_error; else var_errors := var_errors || '; ' || var_error; end if;
    end if;

    select parameter_name, min_value, max_value, decimal_places
    into var_parameter_name, var_min_value, var_max_value, var_decimal_places
    from public.parameter_limits
    where parameter_type_id = 3;
    var_parameter_value := par_parameters.pressure;
    var_error := null;
    if var_parameter_value is null then
        select error_text into var_error from public.parameter_error_messages where error_code = 'value_not_set';
        var_error := var_parameter_name || ': ' || var_error;
    elsif var_parameter_value < var_min_value then
        select error_text into var_error from public.parameter_error_messages where error_code = 'below_minimum';
        var_error := var_parameter_name || ': ' || var_error || ' ' || var_min_value::text;
    elsif var_parameter_value > var_max_value then
        select error_text into var_error from public.parameter_error_messages where error_code = 'above_maximum';
        var_error := var_parameter_name || ': ' || var_error || ' ' || var_max_value::text;
    elsif var_parameter_value <> round(var_parameter_value, var_decimal_places) then
        select error_text into var_error from public.parameter_error_messages where error_code = 'wrong_decimal_places';
        var_error := var_parameter_name || ': ' || var_error;
    end if;
    if var_error is not null then
        if var_errors = '' then var_errors := var_error; else var_errors := var_errors || '; ' || var_error; end if;
    end if;

    select parameter_name, min_value, max_value, decimal_places
    into var_parameter_name, var_min_value, var_max_value, var_decimal_places
    from public.parameter_limits
    where parameter_type_id = 4;
    var_parameter_value := par_parameters.wind_direction;
    var_error := null;
    if var_parameter_value is null then
        select error_text into var_error from public.parameter_error_messages where error_code = 'value_not_set';
        var_error := var_parameter_name || ': ' || var_error;
    elsif var_parameter_value < var_min_value then
        select error_text into var_error from public.parameter_error_messages where error_code = 'below_minimum';
        var_error := var_parameter_name || ': ' || var_error || ' ' || var_min_value::text;
    elsif var_parameter_value > var_max_value then
        select error_text into var_error from public.parameter_error_messages where error_code = 'above_maximum';
        var_error := var_parameter_name || ': ' || var_error || ' ' || var_max_value::text;
    elsif var_parameter_value <> round(var_parameter_value, var_decimal_places) then
        select error_text into var_error from public.parameter_error_messages where error_code = 'wrong_decimal_places';
        var_error := var_parameter_name || ': ' || var_error;
    end if;
    if var_error is not null then
        if var_errors = '' then var_errors := var_error; else var_errors := var_errors || '; ' || var_error; end if;
    end if;

    if par_parameters.measurement_equipment_id = 1 then
        select parameter_name, min_value, max_value, decimal_places
        into var_parameter_name, var_min_value, var_max_value, var_decimal_places
        from public.parameter_limits
        where parameter_type_id = 5;
        var_parameter_value := par_parameters.wind_speed;
        var_error := null;
        if var_parameter_value is null then
            select error_text into var_error from public.parameter_error_messages where error_code = 'value_not_set';
            var_error := var_parameter_name || ': ' || var_error;
        elsif var_parameter_value < var_min_value then
            select error_text into var_error from public.parameter_error_messages where error_code = 'below_minimum';
            var_error := var_parameter_name || ': ' || var_error || ' ' || var_min_value::text;
        elsif var_parameter_value > var_max_value then
            select error_text into var_error from public.parameter_error_messages where error_code = 'above_maximum';
            var_error := var_parameter_name || ': ' || var_error || ' ' || var_max_value::text;
        elsif var_parameter_value <> round(var_parameter_value, var_decimal_places) then
            select error_text into var_error from public.parameter_error_messages where error_code = 'wrong_decimal_places';
            var_error := var_parameter_name || ': ' || var_error;
        end if;
        if var_error is not null then
            if var_errors = '' then var_errors := var_error; else var_errors := var_errors || '; ' || var_error; end if;
        end if;
    end if;

    if par_parameters.measurement_equipment_id = 2 then
        select parameter_name, min_value, max_value, decimal_places
        into var_parameter_name, var_min_value, var_max_value, var_decimal_places
        from public.parameter_limits
        where parameter_type_id = 6;
        var_parameter_value := par_parameters.bullet_drift;
        var_error := null;
        if var_parameter_value is null then
            select error_text into var_error from public.parameter_error_messages where error_code = 'value_not_set';
            var_error := var_parameter_name || ': ' || var_error;
        elsif var_parameter_value < var_min_value then
            select error_text into var_error from public.parameter_error_messages where error_code = 'below_minimum';
            var_error := var_parameter_name || ': ' || var_error || ' ' || var_min_value::text;
        elsif var_parameter_value > var_max_value then
            select error_text into var_error from public.parameter_error_messages where error_code = 'above_maximum';
            var_error := var_parameter_name || ': ' || var_error || ' ' || var_max_value::text;
        elsif var_parameter_value <> round(var_parameter_value, var_decimal_places) then
            select error_text into var_error from public.parameter_error_messages where error_code = 'wrong_decimal_places';
            var_error := var_parameter_name || ': ' || var_error;
        end if;
        if var_error is not null then
            if var_errors = '' then var_errors := var_error; else var_errors := var_errors || '; ' || var_error; end if;
        end if;
    end if;

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
