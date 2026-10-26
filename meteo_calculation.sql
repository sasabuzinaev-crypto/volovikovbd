do $$
begin
    if not exists (
        select 1
        from pg_type t
        join pg_namespace n on n.oid = t.typnamespace
        where n.nspname = 'public'
          and t.typname = 'meteo_header_type'
    ) then
        create type public.meteo_header_type as (
            ddhhm text,
            vvvv text,
            bbbtt text
        );
    end if;
end;
$$;

create or replace function public.fn_calculate_meteo_header(
    par_height numeric,
    par_temperature numeric,
    par_pressure numeric,
    par_measured_at timestamp default current_timestamp
)
returns public.meteo_header_type
language plpgsql
stable
as $$
declare
    var_result public.meteo_header_type;
    var_pressure_delta integer;
    var_pressure_code text;
    var_temperature_delta integer;
    var_temperature_code text;
    var_temperature_correction numeric;
begin
    if par_measured_at is null
       or par_height is null
       or par_temperature is null
       or par_pressure is null then
        raise exception 'все параметры для заголовка должны быть заданы';
    end if;

    if par_height <> trunc(par_height) then
        raise exception 'высота должна быть целым числом';
    end if;

    if par_pressure <> trunc(par_pressure) then
        raise exception 'давление должно быть целым числом';
    end if;

    var_result.ddhhm := to_char(par_measured_at, 'DDHH')
        || floor(extract(minute from par_measured_at) / 10)::integer::text;

    if par_height < -999 or par_height > 9999 then
        raise exception 'высота не помещается в поле вввв';
    end if;

    if par_height < 0 then
        var_result.vvvv := '-' || lpad(abs(par_height)::integer::text, 3, '0');
    else
        var_result.vvvv := lpad(par_height::integer::text, 4, '0');
    end if;

    var_pressure_delta := (par_pressure - public.fn_get_meteo_constant('standard_pressure'))::integer;

    if var_pressure_delta < 0 then
        var_pressure_code := lpad((
            public.fn_get_meteo_constant('negative_pressure_code')::integer
            + abs(var_pressure_delta)
        )::text, 3, '0');
    else
        var_pressure_code := lpad(var_pressure_delta::text, 3, '0');
    end if;

    var_temperature_correction := public.fn_interpolate_value(
        par_temperature,
        public.fn_get_interpolation_for_correction(par_temperature)
    );

    var_temperature_delta := round(
        par_temperature
        + var_temperature_correction
        - public.fn_get_meteo_constant('standard_temperature')
    )::integer;

    -- в задании нет отдельного формата для отрицательного тт, поэтому сохраняем минус.
    if var_temperature_delta < 0 then
        var_temperature_code := '-' || lpad(abs(var_temperature_delta)::text, 2, '0');
    else
        var_temperature_code := lpad(var_temperature_delta::text, 2, '0');
    end if;

    var_result.bbbtt := var_pressure_code || var_temperature_code;

    return var_result;
end;
$$;

comment on type public.meteo_header_type is
    'поля приближенного метеобюллетеня: ддччм, вввв, бббтт';
comment on function public.fn_calculate_meteo_header(numeric, numeric, numeric, timestamp) is
    'рассчитывает заголовок приближенного метеобюллетеня';
