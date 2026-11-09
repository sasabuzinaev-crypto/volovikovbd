
do $$
declare
    var_count integer;
    var_errors integer;
    var_temperature integer;
    var_reference_rows integer;
    var_reference_value integer;
begin
    select count(*) into var_reference_rows from public.calc_correction;
    if var_reference_rows <> 54 then
        raise exception 'ожидалось 54 строки с массивами, получено %', var_reference_rows;
    end if;
    select row_values[13] into var_reference_value
    from public.calc_correction where height_id = 2 and type_id = 8;
    if var_reference_value is null or var_reference_value <> -38 then
        raise exception 'таблица 2: для высоты 400 м и -40 ожидалось -38';
    end if;
    select row_values[9] into var_reference_value
    from public.calc_correction where height_id = 4 and type_id = 6;
    if var_reference_value is null or var_reference_value <> 22 then
        raise exception 'таблица 3: для высоты 1200 м и скорости 11 ожидалось 22';
    end if;
    raise notice 'выданная структура: 54 строки с массивами, исправленные ячейки проверены';

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
    call public.sp_calculate_meteo(
        row(100,25,765,15,2,0)::public.input_params_type, 1
    );
    select count(*) into var_count from public.meteo_calculation_results;
    select count(*) into var_errors from public.meteo_calculation_results
    where wind_direction <> 0 or wind_speed <> 0;
    if var_count <> 9 or var_errors <> 0 then
        raise exception 'не пройдена проверка слабого ветра для дмк';
    end if;
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
    call public.sp_calculate_meteo(
        row(100,25,765,15,15,0)::public.input_params_type, 1
    );
    select wind_speed into var_count from public.meteo_calculation_results where height_id = 1;
    select wind_speed into var_errors from public.meteo_calculation_results where height_id = 9;
    if var_count is null or var_errors is null or var_count <> 22 or var_errors <> 36 then
        raise exception 'не пройдена проверка последнего столбца массива дмк';
    end if;
    call public.sp_calculate_meteo(
        row(100,25,765,15,null,150)::public.input_params_type, 2
    );
    select wind_speed into var_count from public.meteo_calculation_results where height_id = 1;
    select wind_speed into var_errors from public.meteo_calculation_results where height_id = 9;
    if var_count is null or var_errors is null or var_count <> 12 or var_errors <> 20 then
        raise exception 'не пройдена проверка последнего столбца массива вр';
    end if;
    call public.sp_calculate_meteo(
        row(100,15,765,15,6,0)::public.input_params_type, 1
    );
    select count(*) into var_count from public.meteo_calculation_results;
    select count(*) into var_errors from public.meteo_calculation_results
    where temperature_deviation <> 0;
    if var_count <> 9 or var_errors <> 0 then
        raise exception 'не пройдена проверка нулевого отклонения температуры';
    end if;
    raise notice 'проверки крайних столбцов массивов и нулевого отклонения пройдены';
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
