
do $$
declare
    var_count integer;
    var_errors integer;
    var_temperature integer;
begin
    drop table if exists public.meteo_expected_results;
    create table public.meteo_expected_results (
        height integer,
        temperature_deviation integer,
        wind_direction integer,
        wind_speed integer
    );
    insert into public.meteo_expected_results values
        (200,11,16,9),
        (400,11,17,11),
        (800,11,18,11),
        (1200,11,18,12),
        (1600,11,19,13),
        (2000,11,19,13),
        (2400,11,19,14),
        (3000,11,20,14),
        (4000,11,20,14);

    call public.sp_calculate_meteo(
        row(100,25,765,15,6,0)::public.input_params_type, 1
    );

    select count(*) into var_count from public.meteo_calculation_results;
    select count(*) into var_errors
    from public.meteo_expected_results expected
    join public.calc_correction_heights heights on heights.height = expected.height
    left join public.meteo_calculation_results actual on actual.height_id = heights.id
    where actual.height_id is null
       or actual.temperature_deviation <> expected.temperature_deviation
       or actual.wind_direction <> expected.wind_direction
       or actual.wind_speed <> expected.wind_speed;

    if var_count <> 9 or var_errors <> 0 then
        raise exception 'расчет дмк не совпал с тз';
    end if;
    raise notice 'проверка дмк по 9 высотам пройдена';

    -- пример температуры +3 на высоте 200 м получается -12
    call public.sp_calculate_meteo(
        row(100,3,765,15,6,0)::public.input_params_type, 1
    );
    select results.temperature_deviation into var_temperature
    from public.meteo_calculation_results results
    join public.calc_correction_heights heights on heights.id = results.height_id
    where heights.height = 200;

    if var_temperature is null or var_temperature <> -12 then
        raise exception 'для температуры +3 на высоте 200 м ожидалось -12';
    end if;
    raise notice 'пример +3 градуса пройден: отклонение -12, код %', 50 + abs(var_temperature);

    -- первый столбец таблицы 3 дальность сноса пуль 40 м
    delete from public.meteo_expected_results;
    insert into public.meteo_expected_results values
        (200,11,15,3),
        (400,11,16,4),
        (800,11,17,4),
        (1200,11,17,4),
        (1600,11,18,4),
        (2000,11,18,4),
        (2400,11,18,4),
        (3000,11,19,5),
        (4000,11,19,5);

    call public.sp_calculate_meteo(
        row(100,25,765,15,null,40)::public.input_params_type, 2
    );
    select count(*) into var_count from public.meteo_calculation_results;
    select count(*) into var_errors
    from public.meteo_expected_results expected
    join public.calc_correction_heights heights on heights.height = expected.height
    left join public.meteo_calculation_results actual on actual.height_id = heights.id
    where actual.height_id is null
       or actual.temperature_deviation <> expected.temperature_deviation
       or actual.wind_direction <> expected.wind_direction
       or actual.wind_speed <> expected.wind_speed;

    if var_count <> 9 or var_errors <> 0 then
        raise exception 'расчет вр не совпал с таблицей 3';
    end if;
    raise notice 'проверка вр по 9 высотам пройдена';

    --  при скорости меньше 3 м/с направление и скорость равны нулю
    call public.sp_calculate_meteo(
        row(100,25,765,15,2,0)::public.input_params_type, 1
    );
    select count(*) into var_count from public.meteo_calculation_results;
    select count(*) into var_errors from public.meteo_calculation_results
    where wind_direction <> 0 or wind_speed <> 0;
    if var_count <> 9 or var_errors <> 0 then
        raise exception 'не пройдена проверка слабого ветра для дмк';
    end if;

    --  при дальности сноса меньше 40 м направление и скорость равны нулю
    call public.sp_calculate_meteo(
        row(100,25,765,15,null,30)::public.input_params_type, 2
    );
    select count(*) into var_count from public.meteo_calculation_results;
    select count(*) into var_errors from public.meteo_calculation_results
    where wind_direction <> 0 or wind_speed <> 0;
    if var_count <> 9 or var_errors <> 0 then
        raise exception 'не пройдена проверка слабого ветра для вр';
    end if;
    raise notice 'проверки слабого ветра пройдены';

    -- оставляем в таблице основной пример 
    call public.sp_calculate_meteo(
        row(100,25,765,15,6,0)::public.input_params_type, 1
    );
    drop table public.meteo_expected_results;
    raise notice 'все проверки пройдены';
end;
$$;
with calculation as (
    select heights.height,
           case when results.temperature_deviation < 0
                then 50 + abs(results.temperature_deviation)
                else results.temperature_deviation end as temperature_code,
           results.wind_direction,
           results.wind_speed
    from public.meteo_calculation_results results
    join public.calc_correction_heights heights on heights.id = results.height_id
)
select row_number() over(order by height) as "№",
       height as "высота",
       lpad(temperature_code::text, 2, '0') as "отклонение температуры",
       lpad(wind_direction::text, 2, '0') as "направление ветра",
       wind_speed as "скорость ветра"
from calculation
order by height;
