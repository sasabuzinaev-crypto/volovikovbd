do $$
begin
    begin
        drop table if exists public.meteo_calculation_results;
        drop table if exists public.calc_correction;
        drop table if exists public.calc_correction_types;
        drop table if exists public.calc_correction_heights;
        drop table if exists public.calc_correction_headers;

    end;

    begin
        create table public.calc_correction_headers (
            id integer not null,
            description text not null,
            header_values integer[]
        );

        create table public.calc_correction_heights (
            id integer not null,
            height integer not null
        );

        create table public.calc_correction_types (
            id integer not null,
            parent_id integer,
            measurement_equipment_id integer,
            header_id integer,
            description text not null
        );

        create table public.calc_correction (
            height_id integer not null,
            type_id integer not null,
            input_value integer not null,
            correction_value integer
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
            (1, 'таблица 2', array[0,1,2,3,4,5,6,7,8,9,10,20,30,40,50]),
            (2, 'таблица 3, скорость ветра для дмк', array[3,4,5,6,7,8,9,10,11,12,13,14,15]),
            (3, 'таблица 3, дальность сноса пуль для вр', array[40,50,60,70,80,90,100,110,120,130,140,150]);

        insert into public.calc_correction_heights(id, height) values
            (1,200),(2,400),(3,800),(4,1200),(5,1600),(6,2000),(7,2400),(8,3000),(9,4000);

        insert into public.calc_correction_types
            (id, description, parent_id, measurement_equipment_id, header_id)
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
        insert into public.calc_correction(height_id, type_id, input_value, correction_value) values
            (1,8,0,0),
            (1,8,1,-1),
            (1,8,2,-2),
            (1,8,3,-3),
            (1,8,4,-4),
            (1,8,5,-5),
            (1,8,6,-6),
            (1,8,7,-7),
            (1,8,8,-8),
            (1,8,9,-8),
            (1,8,10,-9),
            (1,8,20,-20),
            (1,8,30,-29),
            (1,8,40,-39),
            (1,8,50,-49),
            (2,8,0,0),
            (2,8,1,-1),
            (2,8,2,-2),
            (2,8,3,-3),
            (2,8,4,-4),
            (2,8,5,-5),
            (2,8,6,-6),
            (2,8,7,-6),
            (2,8,8,-7),
            (2,8,9,-8),
            (2,8,10,-9),
            (2,8,20,-19),
            (2,8,30,-29),
            (2,8,40,-38),
            (2,8,50,-48),
            (3,8,0,0),
            (3,8,1,-1),
            (3,8,2,-2),
            (3,8,3,-3),
            (3,8,4,-4),
            (3,8,5,-5),
            (3,8,6,-6),
            (3,8,7,-6),
            (3,8,8,-7),
            (3,8,9,-7),
            (3,8,10,-8),
            (3,8,20,-18),
            (3,8,30,-28),
            (3,8,40,-37),
            (3,8,50,-46),
            (4,8,0,0),
            (4,8,1,-1),
            (4,8,2,-2),
            (4,8,3,-3),
            (4,8,4,-4),
            (4,8,5,-4),
            (4,8,6,-5),
            (4,8,7,-5),
            (4,8,8,-6),
            (4,8,9,-7),
            (4,8,10,-8),
            (4,8,20,-17),
            (4,8,30,-26),
            (4,8,40,-35),
            (4,8,50,-44),
            (5,8,0,0),
            (5,8,1,-1),
            (5,8,2,-2),
            (5,8,3,-3),
            (5,8,4,-3),
            (5,8,5,-4),
            (5,8,6,-4),
            (5,8,7,-5),
            (5,8,8,-6),
            (5,8,9,-7),
            (5,8,10,-7),
            (5,8,20,-17),
            (5,8,30,-25),
            (5,8,40,-34),
            (5,8,50,-42),
            (6,8,0,0),
            (6,8,1,-1),
            (6,8,2,-2),
            (6,8,3,-3),
            (6,8,4,-3),
            (6,8,5,-4),
            (6,8,6,-4),
            (6,8,7,-5),
            (6,8,8,-6),
            (6,8,9,-6),
            (6,8,10,-7),
            (6,8,20,-16),
            (6,8,30,-24),
            (6,8,40,-32),
            (6,8,50,-40),
            (7,8,0,0),
            (7,8,1,-1),
            (7,8,2,-2),
            (7,8,3,-2),
            (7,8,4,-3),
            (7,8,5,-4),
            (7,8,6,-4),
            (7,8,7,-5),
            (7,8,8,-5),
            (7,8,9,-6),
            (7,8,10,-7),
            (7,8,20,-15),
            (7,8,30,-23),
            (7,8,40,-31),
            (7,8,50,-38),
            (8,8,0,0),
            (8,8,1,-1),
            (8,8,2,-2),
            (8,8,3,-2),
            (8,8,4,-3),
            (8,8,5,-4),
            (8,8,6,-4),
            (8,8,7,-4),
            (8,8,8,-5),
            (8,8,9,-5),
            (8,8,10,-6),
            (8,8,20,-15),
            (8,8,30,-22),
            (8,8,40,-30),
            (8,8,50,-37),
            (9,8,0,0),
            (9,8,1,-1),
            (9,8,2,-2),
            (9,8,3,-2),
            (9,8,4,-3),
            (9,8,5,-4),
            (9,8,6,-4),
            (9,8,7,-4),
            (9,8,8,-4),
            (9,8,9,-5),
            (9,8,10,-6),
            (9,8,20,-14),
            (9,8,30,-20),
            (9,8,40,-27),
            (9,8,50,-34),
            (1,9,0,0),
            (1,9,1,1),
            (1,9,2,2),
            (1,9,3,3),
            (1,9,4,4),
            (1,9,5,5),
            (1,9,6,6),
            (1,9,7,7),
            (1,9,8,8),
            (1,9,9,9),
            (1,9,10,10),
            (1,9,20,20),
            (1,9,30,30),
            (1,9,40,null),
            (1,9,50,null),
            (2,9,0,0),
            (2,9,1,1),
            (2,9,2,2),
            (2,9,3,3),
            (2,9,4,4),
            (2,9,5,5),
            (2,9,6,6),
            (2,9,7,7),
            (2,9,8,8),
            (2,9,9,9),
            (2,9,10,10),
            (2,9,20,20),
            (2,9,30,30),
            (2,9,40,null),
            (2,9,50,null),
            (3,9,0,0),
            (3,9,1,1),
            (3,9,2,2),
            (3,9,3,3),
            (3,9,4,4),
            (3,9,5,5),
            (3,9,6,6),
            (3,9,7,7),
            (3,9,8,8),
            (3,9,9,9),
            (3,9,10,10),
            (3,9,20,20),
            (3,9,30,30),
            (3,9,40,null),
            (3,9,50,null),
            (4,9,0,0),
            (4,9,1,1),
            (4,9,2,2),
            (4,9,3,3),
            (4,9,4,4),
            (4,9,5,5),
            (4,9,6,6),
            (4,9,7,7),
            (4,9,8,8),
            (4,9,9,9),
            (4,9,10,10),
            (4,9,20,20),
            (4,9,30,30),
            (4,9,40,null),
            (4,9,50,null),
            (5,9,0,0),
            (5,9,1,1),
            (5,9,2,2),
            (5,9,3,3),
            (5,9,4,4),
            (5,9,5,5),
            (5,9,6,6),
            (5,9,7,7),
            (5,9,8,8),
            (5,9,9,9),
            (5,9,10,10),
            (5,9,20,20),
            (5,9,30,30),
            (5,9,40,null),
            (5,9,50,null),
            (6,9,0,0),
            (6,9,1,1),
            (6,9,2,2),
            (6,9,3,3),
            (6,9,4,4),
            (6,9,5,5),
            (6,9,6,6),
            (6,9,7,7),
            (6,9,8,8),
            (6,9,9,9),
            (6,9,10,10),
            (6,9,20,20),
            (6,9,30,30),
            (6,9,40,null),
            (6,9,50,null),
            (7,9,0,0),
            (7,9,1,1),
            (7,9,2,2),
            (7,9,3,3),
            (7,9,4,4),
            (7,9,5,5),
            (7,9,6,6),
            (7,9,7,7),
            (7,9,8,8),
            (7,9,9,9),
            (7,9,10,10),
            (7,9,20,20),
            (7,9,30,30),
            (7,9,40,null),
            (7,9,50,null),
            (8,9,0,0),
            (8,9,1,1),
            (8,9,2,2),
            (8,9,3,3),
            (8,9,4,4),
            (8,9,5,5),
            (8,9,6,6),
            (8,9,7,7),
            (8,9,8,8),
            (8,9,9,9),
            (8,9,10,10),
            (8,9,20,20),
            (8,9,30,30),
            (8,9,40,null),
            (8,9,50,null),
            (9,9,0,0),
            (9,9,1,1),
            (9,9,2,2),
            (9,9,3,3),
            (9,9,4,4),
            (9,9,5,5),
            (9,9,6,6),
            (9,9,7,7),
            (9,9,8,8),
            (9,9,9,9),
            (9,9,10,10),
            (9,9,20,20),
            (9,9,30,30),
            (9,9,40,null),
            (9,9,50,null),
            (1,6,3,4),
            (1,6,4,6),
            (1,6,5,8),
            (1,6,6,9),
            (1,6,7,10),
            (1,6,8,12),
            (1,6,9,14),
            (1,6,10,15),
            (1,6,11,16),
            (1,6,12,18),
            (1,6,13,20),
            (1,6,14,21),
            (1,6,15,22),
            (2,6,3,5),
            (2,6,4,7),
            (2,6,5,10),
            (2,6,6,11),
            (2,6,7,12),
            (2,6,8,14),
            (2,6,9,17),
            (2,6,10,18),
            (2,6,11,20),
            (2,6,12,22),
            (2,6,13,23),
            (2,6,14,25),
            (2,6,15,27),
            (3,6,3,5),
            (3,6,4,8),
            (3,6,5,10),
            (3,6,6,11),
            (3,6,7,13),
            (3,6,8,15),
            (3,6,9,18),
            (3,6,10,19),
            (3,6,11,21),
            (3,6,12,23),
            (3,6,13,25),
            (3,6,14,27),
            (3,6,15,28),
            (4,6,3,5),
            (4,6,4,8),
            (4,6,5,11),
            (4,6,6,12),
            (4,6,7,13),
            (4,6,8,16),
            (4,6,9,19),
            (4,6,10,20),
            (4,6,11,22),
            (4,6,12,24),
            (4,6,13,26),
            (4,6,14,28),
            (4,6,15,30),
            (5,6,3,6),
            (5,6,4,8),
            (5,6,5,11),
            (5,6,6,13),
            (5,6,7,14),
            (5,6,8,17),
            (5,6,9,20),
            (5,6,10,21),
            (5,6,11,23),
            (5,6,12,25),
            (5,6,13,27),
            (5,6,14,29),
            (5,6,15,32),
            (6,6,3,6),
            (6,6,4,9),
            (6,6,5,11),
            (6,6,6,13),
            (6,6,7,14),
            (6,6,8,17),
            (6,6,9,20),
            (6,6,10,21),
            (6,6,11,24),
            (6,6,12,26),
            (6,6,13,28),
            (6,6,14,30),
            (6,6,15,32),
            (7,6,3,6),
            (7,6,4,9),
            (7,6,5,12),
            (7,6,6,14),
            (7,6,7,15),
            (7,6,8,18),
            (7,6,9,21),
            (7,6,10,22),
            (7,6,11,25),
            (7,6,12,27),
            (7,6,13,29),
            (7,6,14,32),
            (7,6,15,34),
            (8,6,3,6),
            (8,6,4,9),
            (8,6,5,12),
            (8,6,6,14),
            (8,6,7,15),
            (8,6,8,18),
            (8,6,9,21),
            (8,6,10,23),
            (8,6,11,25),
            (8,6,12,28),
            (8,6,13,30),
            (8,6,14,32),
            (8,6,15,36),
            (9,6,3,6),
            (9,6,4,10),
            (9,6,5,12),
            (9,6,6,14),
            (9,6,7,16),
            (9,6,8,19),
            (9,6,9,22),
            (9,6,10,24),
            (9,6,11,26),
            (9,6,12,29),
            (9,6,13,32),
            (9,6,14,34),
            (9,6,15,36),
            (1,7,0,1),
            (2,7,0,2),
            (3,7,0,3),
            (4,7,0,3),
            (5,7,0,4),
            (6,7,0,4),
            (7,7,0,4),
            (8,7,0,5),
            (9,7,0,5),
            (1,4,40,3),
            (1,4,50,4),
            (1,4,60,5),
            (1,4,70,6),
            (1,4,80,7),
            (1,4,90,7),
            (1,4,100,8),
            (1,4,110,9),
            (1,4,120,10),
            (1,4,130,11),
            (1,4,140,12),
            (1,4,150,12),
            (2,4,40,4),
            (2,4,50,5),
            (2,4,60,6),
            (2,4,70,7),
            (2,4,80,8),
            (2,4,90,9),
            (2,4,100,10),
            (2,4,110,11),
            (2,4,120,12),
            (2,4,130,13),
            (2,4,140,14),
            (2,4,150,15),
            (3,4,40,4),
            (3,4,50,5),
            (3,4,60,6),
            (3,4,70,7),
            (3,4,80,8),
            (3,4,90,9),
            (3,4,100,10),
            (3,4,110,11),
            (3,4,120,13),
            (3,4,130,14),
            (3,4,140,15),
            (3,4,150,16),
            (4,4,40,4),
            (4,4,50,5),
            (4,4,60,7),
            (4,4,70,8),
            (4,4,80,8),
            (4,4,90,9),
            (4,4,100,11),
            (4,4,110,12),
            (4,4,120,13),
            (4,4,130,15),
            (4,4,140,15),
            (4,4,150,16),
            (5,4,40,4),
            (5,4,50,6),
            (5,4,60,7),
            (5,4,70,8),
            (5,4,80,9),
            (5,4,90,10),
            (5,4,100,11),
            (5,4,110,13),
            (5,4,120,14),
            (5,4,130,15),
            (5,4,140,17),
            (5,4,150,17),
            (6,4,40,4),
            (6,4,50,6),
            (6,4,60,7),
            (6,4,70,8),
            (6,4,80,9),
            (6,4,90,10),
            (6,4,100,11),
            (6,4,110,13),
            (6,4,120,14),
            (6,4,130,16),
            (6,4,140,17),
            (6,4,150,18),
            (7,4,40,4),
            (7,4,50,6),
            (7,4,60,8),
            (7,4,70,9),
            (7,4,80,9),
            (7,4,90,10),
            (7,4,100,12),
            (7,4,110,14),
            (7,4,120,15),
            (7,4,130,16),
            (7,4,140,18),
            (7,4,150,19),
            (8,4,40,5),
            (8,4,50,6),
            (8,4,60,8),
            (8,4,70,9),
            (8,4,80,10),
            (8,4,90,11),
            (8,4,100,12),
            (8,4,110,14),
            (8,4,120,15),
            (8,4,130,17),
            (8,4,140,18),
            (8,4,150,19),
            (9,4,40,5),
            (9,4,50,6),
            (9,4,60,8),
            (9,4,70,9),
            (9,4,80,10),
            (9,4,90,11),
            (9,4,100,12),
            (9,4,110,14),
            (9,4,120,16),
            (9,4,130,18),
            (9,4,140,19),
            (9,4,150,20),
            (1,5,0,0),
            (2,5,0,1),
            (3,5,0,2),
            (4,5,0,2),
            (5,5,0,3),
            (6,5,0,3),
            (7,5,0,3),
            (8,5,0,4),
            (9,5,0,4);
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
            add constraint fk_correction_types_equipment foreign key (measurement_equipment_id)
                references public.measurement_equipment(id),
            add constraint fk_correction_types_header foreign key (header_id)
                references public.calc_correction_headers(id);
        alter table public.calc_correction
            add constraint pk_calc_correction primary key (height_id, type_id, input_value),
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
        comment on column public.calc_correction.input_value is 'отклонение температуры, скорость ветра или дальность сноса пуль; для направления ветра 0';
        comment on column public.calc_correction.correction_value is 'значение из ячейки справочной таблицы';
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
    var_temperature_type integer;
    var_speed_type integer;
    var_direction_type integer;
    var_wind_value integer;
    var_calm boolean;
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

    if not exists (
        select 1 from public.calc_correction
        where type_id = var_temperature_type and input_value = var_tens
          and correction_value is not null
    ) or not exists (
        select 1 from public.calc_correction
        where type_id = var_temperature_type and input_value = var_units
          and correction_value is not null
    ) then
        raise exception 'отклонение температуры отсутствует в таблице 2';
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

    if var_calm = false and not exists (
        select 1 from public.calc_correction
        where type_id = var_speed_type and input_value = var_wind_value
    ) then
        raise exception 'значение ветра отсутствует в таблице 3';
    end if;

    delete from public.meteo_calculation_results;

    insert into public.meteo_calculation_results
        (height_id, temperature_deviation, wind_direction, wind_speed)
    select heights.id,
           tens.correction_value + units.correction_value,
           case when var_calm then 0
                else par_params.wind_direction::integer + direction.correction_value end,
           case when var_calm then 0 else speed.correction_value end
    from public.calc_correction_heights heights
    join public.calc_correction tens
      on tens.height_id = heights.id and tens.type_id = var_temperature_type
     and tens.input_value = var_tens
    join public.calc_correction units
      on units.height_id = heights.id and units.type_id = var_temperature_type
     and units.input_value = var_units
    join public.calc_correction direction
      on direction.height_id = heights.id and direction.type_id = var_direction_type
     and direction.input_value = 0
    left join public.calc_correction speed
      on speed.height_id = heights.id and speed.type_id = var_speed_type
     and speed.input_value = var_wind_value;
end;
$body$;
