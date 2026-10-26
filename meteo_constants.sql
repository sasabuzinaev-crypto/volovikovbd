-- таблицы с постоянными значениями для расчета
create table if not exists public.calc_temperature_correction (
    temperature numeric(8,2) not null primary key,
    correction numeric(8,2) not null
);

insert into public.calc_temperature_correction (temperature, correction)
values
    (0, 0),
    (5, 0.5),
    (10, 1),
    (15, 1),
    (20, 1.5),
    (25, 2),
    (30, 3.5),
    (40, 4.5)
on conflict (temperature) do update
set correction = excluded.correction;

create table if not exists public.parameter_limits (
    parameter_type_id integer primary key,
    parameter_name text not null,
    min_value numeric,
    max_value numeric,
    decimal_places integer not null,
    equipment_id integer
);

insert into public.parameter_limits
    (parameter_type_id, parameter_name, min_value, max_value, decimal_places, equipment_id)
values
    (1, 'высота метеопоста', null, null, 0, null),
    (2, 'температура', -58, 58, 1, null),
    (3, 'давление', 500, 900, 0, null),
    (4, 'направление ветра', 0, 59, 0, null),
    (5, 'скорость ветра', 0, 15, 0, 1),
    (6, 'дальность сноса пуль', 0, 150, 0, 2)
on conflict (parameter_type_id) do update
set parameter_name = excluded.parameter_name,
    min_value = excluded.min_value,
    max_value = excluded.max_value,
    decimal_places = excluded.decimal_places,
    equipment_id = excluded.equipment_id;

create table if not exists public.meteo_constants (
    constant_name text primary key,
    constant_value numeric not null
);

insert into public.meteo_constants (constant_name, constant_value)
values
    ('standard_pressure', 750),
    ('standard_temperature', 15.9),
    ('negative_pressure_code', 500)
on conflict (constant_name) do update
set constant_value = excluded.constant_value;

create or replace function public.fn_get_meteo_constant(par_name text)
returns numeric
language plpgsql
stable
as $$
declare
    var_value numeric;
begin
    select constant_value
    into var_value
    from public.meteo_constants
    where constant_name = par_name;

    if var_value is null then
        raise exception 'константа % не найдена', par_name;
    end if;

    return var_value;
end;
$$;
