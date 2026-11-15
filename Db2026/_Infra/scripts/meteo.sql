do $$
begin
    begin
        drop table if exists public.meteo_calculation_results;
        drop table if exists public.calc_correction;
        drop table if exists public.calc_correction_types;
        drop table if exists public.calc_correction_heights;
        drop table if exists public.calc_correction_headers;
        drop sequence if exists public.calc_correction_seq;
        drop sequence if exists public.calc_correction_types_seq;
        drop sequence if exists public.calc_correction_height_seq;

    end;

    begin
        create sequence public.calc_correction_seq;
        create sequence public.calc_correction_types_seq start with 10;
        create sequence public.calc_correction_height_seq start with 10;

        create table public.calc_correction_headers (
            id integer not null,
            description text not null,
            header_values integer[]
        );

        create table public.calc_correction_heights (
            id integer not null default nextval('public.calc_correction_height_seq'),
            height integer not null
        );

        create table public.calc_correction_types (
            id integer not null default nextval('public.calc_correction_types_seq'),
            parent_id integer,
            measurment_equipment_id integer,
            header_id integer,
            description text not null
        );

        create table public.calc_correction (
            id integer not null default nextval('public.calc_correction_seq'),
            height_id integer not null,
            type_id integer not null,
            row_values integer[]
        );

        create table public.meteo_calculation_results (
            height_id integer not null,
            temperature_deviation integer not null,
            wind_direction integer not null,
            wind_speed integer not null
        );
    end;

    begin
        insert into public.calc_correction_headers(id, description, header_values) values
            (1, 'таблица 2', array[1,2,3,4,5,6,7,8,9,10,20,30,40,50]),
            (2, 'таблица 3, скорость ветра для дмк', array[3,4,5,6,7,8,9,10,11,12,13,14,15]),
            (3, 'таблица 3, дальность сноса пуль для вр', array[40,50,60,70,80,90,100,110,120,130,140,150]);

        insert into public.calc_correction_heights(id, height) values
            (1,200),(2,400),(3,800),(4,1200),(5,1600),(6,2000),(7,2400),(8,3000),(9,4000);

        insert into public.calc_correction_types
            (id, description, parent_id, measurment_equipment_id, header_id)
        values
            (1, 'таблица 2', null, null, 1),
            (2, 'таблица 3, скорость среднего ветра', null, null, null),
            (3, 'таблица 3, направление среднего ветра', null, null, null),
            (4, 'таблица 3, скорость среднего ветра для вр', 2, 2, 3),
            (5, 'таблица 3, направление среднего ветра для вр', 3, 2, null),
            (6, 'таблица 3, скорость среднего ветра для дмк', 2, 1, 2),
            (7, 'таблица 3, направление среднего ветра для дмк', 3, 1, null),
            (8, 'таблица 2, отрицательные температуры', 1, null, 1),
            (9, 'таблица 2, положительные температуры', 1, null, 1);
        insert into public.calc_correction(height_id, type_id, row_values) values
            (1,8,array[-1,-2,-3,-4,-5,-6,-7,-8,-8,-9,-20,-29,-39,-49]),
            (2,8,array[-1,-2,-3,-4,-5,-6,-6,-7,-8,-9,-19,-29,-38,-48]),
            (3,8,array[-1,-2,-3,-4,-5,-6,-6,-7,-7,-8,-18,-28,-37,-46]),
            (4,8,array[-1,-2,-3,-4,-4,-5,-5,-6,-7,-8,-17,-26,-35,-44]),
            (5,8,array[-1,-2,-3,-3,-4,-4,-5,-6,-7,-7,-17,-25,-34,-42]),
            (6,8,array[-1,-2,-3,-3,-4,-4,-5,-6,-6,-7,-16,-24,-32,-40]),
            (7,8,array[-1,-2,-2,-3,-4,-4,-5,-5,-6,-7,-15,-23,-31,-38]),
            (8,8,array[-1,-2,-2,-3,-4,-4,-4,-5,-5,-6,-15,-22,-30,-37]),
            (9,8,array[-1,-2,-2,-3,-4,-4,-4,-4,-5,-6,-14,-20,-27,-34]),
            (1,9,array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
            (2,9,array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
            (3,9,array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
            (4,9,array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
            (5,9,array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
            (6,9,array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
            (7,9,array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
            (8,9,array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
            (9,9,array[1,2,3,4,5,6,7,8,9,10,20,30,null,null]),
            (1,4,array[3,4,5,6,7,7,8,9,10,11,12,12]),
            (2,4,array[4,5,6,7,8,9,10,11,12,13,14,15]),
            (3,4,array[4,5,6,7,8,9,10,11,13,14,15,16]),
            (4,4,array[4,5,7,8,8,9,11,12,13,15,15,16]),
            (5,4,array[4,6,7,8,9,10,11,13,14,15,17,17]),
            (6,4,array[4,6,7,8,9,10,11,13,14,16,17,18]),
            (7,4,array[4,6,8,9,9,10,12,14,15,16,18,19]),
            (8,4,array[5,6,8,9,10,11,12,14,15,17,18,19]),
            (9,4,array[5,6,8,9,10,11,12,14,16,18,19,20]),
            (1,5,array[0]),
            (2,5,array[1]),
            (3,5,array[2]),
            (4,5,array[2]),
            (5,5,array[3]),
            (6,5,array[3]),
            (7,5,array[3]),
            (8,5,array[4]),
            (9,5,array[4]),
            (1,6,array[4,6,8,9,10,12,14,15,16,18,20,21,22]),
            (2,6,array[5,7,10,11,12,14,17,18,20,22,23,25,27]),
            (3,6,array[5,8,10,11,13,15,18,19,21,23,25,27,28]),
            (4,6,array[5,8,11,12,13,16,19,20,22,24,26,28,30]),
            (5,6,array[6,8,11,13,14,17,20,21,23,25,27,29,32]),
            (6,6,array[6,9,11,13,14,17,20,21,24,26,28,30,32]),
            (7,6,array[6,9,12,14,15,18,21,22,25,27,29,32,34]),
            (8,6,array[6,9,12,14,15,18,21,23,25,28,30,32,36]),
            (9,6,array[6,10,12,14,16,19,22,24,26,29,32,34,36]),
            (1,7,array[1]),
            (2,7,array[2]),
            (3,7,array[3]),
            (4,7,array[3]),
            (5,7,array[4]),
            (6,7,array[4]),
            (7,7,array[4]),
            (8,7,array[5]),
            (9,7,array[5]);
    end;

    begin
        alter table public.calc_correction_headers
            add constraint pk_calc_correction_headers primary key (id);
        alter table public.calc_correction_heights
            add constraint pk_calc_correction_heights primary key (id);
        alter table public.calc_correction_types
            add constraint pk_calc_correction_types primary key (id),
            add constraint fk_correction_types_parent foreign key (parent_id)
                references public.calc_correction_types(id),
            add constraint fk_correction_types_equipment foreign key (measurment_equipment_id)
                references public.measurement_equipment(id),
            add constraint fk_correction_types_header foreign key (header_id)
                references public.calc_correction_headers(id);
        alter table public.calc_correction
            add constraint pk_calc_correction primary key (id),
            add constraint fk_correction_height foreign key (height_id)
                references public.calc_correction_heights(id),
            add constraint fk_correction_type foreign key (type_id)
                references public.calc_correction_types(id);
        alter table public.meteo_calculation_results
            add constraint pk_meteo_calculation_results primary key (height_id),
            add constraint fk_meteo_result_height foreign key (height_id)
                references public.calc_correction_heights(id);
    end;

    begin
        create table if not exists public.calc_correction_temperature (
            temperature numeric(8,2) primary key not null,
            correction numeric(8,2) not null
        );
        delete from public.calc_correction_temperature;
        insert into public.calc_correction_temperature(temperature, correction) values
            (0,0),(5,0.5),(10,1),(15,1),(20,1.5),(25,2),(30,3.5),(40,4.5);
    end;

    begin
        comment on table public.calc_correction_headers is 'заголовки столбцов таблиц 2 и 3';
        comment on column public.calc_correction_headers.header_values is 'значения заголовка в порядке столбцов';
        comment on table public.calc_correction_heights is 'типовые высоты от 200 до 4000 метров';
        comment on table public.calc_correction_types is 'типы таблиц корректировок';
        comment on column public.calc_correction_types.header_id is 'ссылка на заголовок таблицы';
        comment on table public.calc_correction is 'исправленные значения таблиц 2 и 3';
        comment on column public.calc_correction.id is 'уникальный код';
        comment on column public.calc_correction.height_id is 'код высоты';
        comment on column public.calc_correction.type_id is 'код типа таблицы';
        comment on column public.calc_correction.row_values is 'массив значений строки в порядке заголовков';
        comment on table public.meteo_calculation_results is 'результат последнего вызова процедуры по типовым высотам';
        comment on column public.meteo_calculation_results.temperature_deviation is 'среднее отклонение температуры со знаком до кодирования';
    end;
end;
$$;
create or replace function public.fn_calc_temperature_interpolation(par_temperature numeric)
returns numeric
language plpgsql
as $body$
declare
    var_x0 numeric;
    var_y0 numeric;
    var_x1 numeric;
    var_y1 numeric;
begin
    if par_temperature is null then
        raise exception 'температура не заполнена';
    end if;

    if par_temperature < 0 then
        return 0;
    end if;

    select temperature, correction into var_x0, var_y0
    from public.calc_correction_temperature
    where temperature <= par_temperature
    order by temperature desc
    limit 1;

    select temperature, correction into var_x1, var_y1
    from public.calc_correction_temperature
    where temperature >= par_temperature
    order by temperature
    limit 1;

    if var_x0 is null or var_x1 is null then
        raise exception 'температура вне диапазона таблицы 1';
    end if;
    if var_x0 = var_x1 then
        return var_y0;
    end if;
    return round(var_y0 + (par_temperature - var_x0) * (var_y1 - var_y0)
        / (var_x1 - var_x0), 2);
end;
$body$;
create or replace procedure public.sp_calculate_meteo(
    par_params public.input_params_type,
    par_equipment_id integer
)
language plpgsql
as $body$
declare
    var_temperature integer;
    var_tens integer;
    var_units integer;
    var_tens_index integer;
    var_temperature_type integer;
    var_speed_type integer;
    var_direction_type integer;
    var_wind_value integer;
    var_speed_index integer;
    var_temperature_headers integer[];
    var_speed_headers integer[];
    var_calm boolean;
    var_count integer;
    var_errors integer;
begin
    if par_params.height is null or par_params.temperature is null
       or par_params.pressure is null or par_params.wind_direction is null then
        raise exception 'высота, температура, давление и направление ветра должны быть заполнены';
    end if;

    if par_params.wind_direction < 0 or par_params.wind_direction > 59
       or round(par_params.wind_direction, 0) <> par_params.wind_direction then
        raise exception 'направление ветра должно быть целым числом от 0 до 59';
    end if;

    var_temperature := round(par_params.temperature
        + public.fn_calc_temperature_interpolation(par_params.temperature) - 15.9)::integer;
    var_tens := abs(var_temperature) / 10 * 10;
    var_units := abs(var_temperature) % 10;

    if var_temperature < 0 then
        var_temperature_type := 8;
    else
        var_temperature_type := 9;
    end if;

    select headers.header_values into var_temperature_headers
    from public.calc_correction_types types
    join public.calc_correction_headers headers on headers.id = types.header_id
    where types.id = var_temperature_type;
    if var_tens = 0 then
        var_tens_index := 0;
    else
        var_tens_index := 9 + var_tens / 10;
        if coalesce(var_temperature_headers[var_tens_index], -1) <> var_tens then
            raise exception 'отклонение температуры отсутствует в заголовке таблицы 2';
        end if;
    end if;
    if var_units <> 0 and coalesce(var_temperature_headers[var_units], -1) <> var_units then
        raise exception 'единицы температуры отсутствуют в заголовке таблицы 2';
    end if;

    if par_equipment_id = 1 then
        if par_params.wind_speed is null or par_params.wind_speed < 0
           or round(par_params.wind_speed, 0) <> par_params.wind_speed then
            raise exception 'для дмк нужна целая неотрицательная скорость ветра';
        end if;
        var_speed_type := 6;
        var_direction_type := 7;
        var_wind_value := par_params.wind_speed::integer;
        var_calm := var_wind_value < 3;
    elsif par_equipment_id = 2 then
        if par_params.bullet_demolition_range is null or par_params.bullet_demolition_range < 0
           or round(par_params.bullet_demolition_range, 0) <> par_params.bullet_demolition_range then
            raise exception 'для вр нужна целая неотрицательная дальность сноса пуль';
        end if;
        var_speed_type := 4;
        var_direction_type := 5;
        var_wind_value := par_params.bullet_demolition_range::integer;
        var_calm := var_wind_value < 40;
    else
        raise exception 'тип оборудования должен быть 1 (дмк) или 2 (вр)';
    end if;

    select headers.header_values into var_speed_headers
    from public.calc_correction_types types
    join public.calc_correction_headers headers on headers.id = types.header_id
    where types.id = var_speed_type;

    if var_calm = false then
        -- дмк: заголовки 3,4,5,...; вр: 40,50,60,...
        if par_equipment_id = 1 then
            var_speed_index := var_wind_value - var_speed_headers[1] + 1;
        else
            var_speed_index := (var_wind_value - var_speed_headers[1]) / 10 + 1;
        end if;
        if coalesce(var_speed_headers[var_speed_index], -1) <> var_wind_value then
            raise exception 'значение ветра отсутствует в заголовке таблицы 3';
        end if;
    end if;

    delete from public.meteo_calculation_results;

    insert into public.meteo_calculation_results
        (height_id, temperature_deviation, wind_direction, wind_speed)
    select heights.id,
           case when var_tens = 0 then 0 else temperature.row_values[var_tens_index] end
             + case when var_units = 0 then 0 else temperature.row_values[var_units] end,
           case when var_calm then 0
                else par_params.wind_direction::integer + direction.row_values[1] end,
           case when var_calm then 0 else speed.row_values[var_speed_index] end
    from public.calc_correction_heights heights
    join public.calc_correction temperature
      on temperature.height_id = heights.id and temperature.type_id = var_temperature_type
    join public.calc_correction direction
      on direction.height_id = heights.id and direction.type_id = var_direction_type
    join public.calc_correction speed
      on speed.height_id = heights.id and speed.type_id = var_speed_type;

    select count(*) into var_count from public.calc_correction_heights;
    select count(*) into var_errors from public.meteo_calculation_results;
    if var_count <> var_errors then
        raise exception 'в справочниках отсутствует строка для типовой высоты';
    end if;
end;
$body$;
