-- Выполнять целиком в новой пустой базе volovikov_transactions_db.
-- Таблицы из script2.sql адаптированы к метеорологическому ТЗ. Запуск один раз.

-- 1. Создание таблиц и счетчиков.
begin;
do $$
begin

    create table public.positions (
        code int,
        name text
    );

    create sequence public.seq_positions start with 4;
    alter table public.positions alter column code set default nextval('public.seq_positions');

    create table public.users (
        code int,
        name text,
        position_text text,
        position_code int
    );

    create sequence public.seq_users start with 104;
    alter table public.users alter column code set default nextval('public.seq_users');

    create table public.batches (
        code int,
        batch_num text,
        user_text text,
        user_code int,
        measurement_date timestamp
    );

    create sequence public.seq_batches start with 1007;
    alter table public.batches alter column code set default nextval('public.seq_batches');

    create table public.equipment_types (
        code int,
        name text
    );

    create sequence public.seq_equipment_types start with 21;
    alter table public.equipment_types alter column code set default nextval('public.seq_equipment_types');

    create table public.parameters (
        code int,
        name text,
        val numeric,
        eq_type_code int,
        batch_code int,
        parameter_type_code int,
        unit_code int
    );

    create sequence public.seq_parameters start with 531;
    alter table public.parameters alter column code set default nextval('public.seq_parameters');

    create table public.base_units (
        code int,
        name text
    );

    create sequence public.seq_base_units start with 6;
    alter table public.base_units alter column code set default nextval('public.seq_base_units');

    create table public.units (
        code int,
        name text,
        base_unit_code int
    );

    create sequence public.seq_units start with 51;
    alter table public.units alter column code set default nextval('public.seq_units');

    create table public.parameter_types (
        code int,
        name text
    );

    create sequence public.seq_parameter_types start with 601;
    alter table public.parameter_types alter column code set default nextval('public.seq_parameter_types');

    create table public.temperature_table1 (
        code int,
        temperature text,
        correction numeric
    );

    create sequence public.seq_temperature_table1 start with 8;
    alter table public.temperature_table1 alter column code set default nextval('public.seq_temperature_table1');

end $$;
commit;

-- 2. Тестовые метеоизмерения: по две пачки и десять значений на пользователя.
begin;
do $$
begin
    insert into public.positions(code, name) values(1, 'главный админ');
    insert into public.positions(code, name) values(2, 'модератор');
    insert into public.positions(code, name) values(3, 'стажер');

    insert into public.users(code, name, position_text, position_code) values(101, 'Иванов Иван', 'главный админ', 1);
    insert into public.users(code, name, position_text, position_code) values(102, 'Петров Петр', 'модератор', 2);
    insert into public.users(code, name, position_text, position_code) values(103, 'Сидоров Алексей', 'стажер', 3);

    insert into public.equipment_types(code, name) values(10, 'Десантный метеорологический комплект');
    insert into public.equipment_types(code, name) values(20, 'Ветровое ружье');

    insert into public.base_units(code, name) values
        (1, 'Метр'), (2, 'Градус Цельсия'), (3, 'Паскаль'),
        (4, 'Деление угломера'), (5, 'Метр в секунду');
    insert into public.units(code, name, base_unit_code) values
        (10, 'м', 1), (20, '°C', 2), (30, 'мм рт. ст.', 3),
        (40, 'дел. угл.', 4), (50, 'м/с', 5);
    insert into public.parameter_types(code, name) values
        (100, 'Высота метеопоста'), (200, 'Температура воздуха'),
        (300, 'Давление атмосферы'), (400, 'Направление ветра'),
        (500, 'Скорость ветра'), (600, 'Дальность сноса пуль');

    insert into public.batches(code, batch_num, user_text, user_code, measurement_date) values
        (1001, 'BATCH-001', 'Иванов', 101, '2026-09-29 14:00:00'),
        (1002, 'BATCH-002', 'Петров', 102, '2026-09-29 15:30:00'),
        (1003, 'BATCH-003', 'Сидоров', 103, '2026-09-29 16:00:00'),
        (1004, 'BATCH-004', 'Иванов', 101, '2026-09-30 14:00:00'),
        (1005, 'BATCH-005', 'Петров', 102, '2026-09-30 15:30:00'),
        (1006, 'BATCH-006', 'Сидоров', 103, '2026-09-30 16:00:00');

    -- Первые три пачки - ДМК, следующие три - ветровое ружье.
    insert into public.parameters(code, name, val, eq_type_code, batch_code, parameter_type_code, unit_code) values
        (501, 'Высота метеопоста', 100, 10, 1001, 100, 10),
        (502, 'Температура воздуха', 15.0, 10, 1001, 200, 20),
        (503, 'Давление атмосферы', 750, 10, 1001, 300, 30),
        (504, 'Направление ветра', 0, 10, 1001, 400, 40),
        (505, 'Скорость ветра', 0, 10, 1001, 500, 50),
        (506, 'Высота метеопоста', 140, 10, 1002, 100, 10),
        (507, 'Температура воздуха', -12.4, 10, 1002, 200, 20),
        (508, 'Давление атмосферы', 728, 10, 1002, 300, 30),
        (509, 'Направление ветра', 18, 10, 1002, 400, 40),
        (510, 'Скорость ветра', 4, 10, 1002, 500, 50),
        (511, 'Высота метеопоста', -20, 10, 1003, 100, 10),
        (512, 'Температура воздуха', 26.7, 10, 1003, 200, 20),
        (513, 'Давление атмосферы', 782, 10, 1003, 300, 30),
        (514, 'Направление ветра', 43, 10, 1003, 400, 40),
        (515, 'Скорость ветра', 9, 10, 1003, 500, 50),
        (516, 'Высота метеопоста', 85, 20, 1004, 100, 10),
        (517, 'Температура воздуха', 3.2, 20, 1004, 200, 20),
        (518, 'Давление атмосферы', 741, 20, 1004, 300, 30),
        (519, 'Направление ветра', 11, 20, 1004, 400, 40),
        (520, 'Дальность сноса пуль', 35, 20, 1004, 600, 10),
        (521, 'Высота метеопоста', 210, 20, 1005, 100, 10),
        (522, 'Температура воздуха', -5.8, 20, 1005, 200, 20),
        (523, 'Давление атмосферы', 765, 20, 1005, 300, 30),
        (524, 'Направление ветра', 29, 20, 1005, 400, 40),
        (525, 'Дальность сноса пуль', 90, 20, 1005, 600, 10),
        (526, 'Высота метеопоста', 0, 20, 1006, 100, 10),
        (527, 'Температура воздуха', 19.6, 20, 1006, 200, 20),
        (528, 'Давление атмосферы', 754, 20, 1006, 300, 30),
        (529, 'Направление ветра', 57, 20, 1006, 400, 40),
        (530, 'Дальность сноса пуль', 125, 20, 1006, 600, 10);

    -- Расчет температуры, таблица 1 из метеорологического ТЗ.
    insert into public.temperature_table1(code, temperature, correction) values
        (1, 'Ниже 0', 0), (2, '0 - 5', 0.5), (3, '10 - 15', 1),
        (4, '20', 1.5), (5, '25', 2), (6, '30', 3.5), (7, '40', 4.5);
end $$;
commit;

-- 3. Первичные ключи, ограничения, связи и описания.
begin;
do $$
begin

    alter table public.positions add primary key (code);

    alter table public.users add primary key (code);

    alter table public.batches add primary key (code);

    alter table public.equipment_types add primary key (code);

    alter table public.parameters add primary key (code);

    alter table public.base_units add primary key (code);

    alter table public.units add primary key (code);

    alter table public.parameter_types add primary key (code);

    alter table public.temperature_table1 add primary key (code);

    alter table public.base_units alter column name set not null;

    alter table public.units alter column name set not null;

    alter table public.parameter_types alter column name set not null;

    alter table public.users add foreign key (position_code) references public.positions(code);

    alter table public.batches add foreign key (user_code) references public.users(code);

    alter table public.parameters add foreign key (eq_type_code) references public.equipment_types(code);

    alter table public.parameters add foreign key (batch_code) references public.batches(code);

    alter table public.parameters add foreign key (parameter_type_code) references public.parameter_types(code);

    alter table public.parameters add foreign key (unit_code) references public.units(code);

    alter table public.units add foreign key (base_unit_code) references public.base_units(code);

    comment on table public.positions is 'Справочник ролей и должностей пользователей';

    comment on column public.positions.code is 'Уникальный код должности';

    comment on column public.positions.name is 'Название роли ';

    comment on table public.users is 'Пользователи журнала метеоизмерений';

    comment on column public.users.code is 'Уникальный код пользователя';

    comment on column public.users.name is 'ФИО сотрудника';

    comment on column public.users.position_text is 'Текстовое наименование роли пользователя';

    comment on table public.batches is 'Пачки метеоизмерений с автором и датой';

    comment on column public.batches.code is 'Уникальный код пачки';

    comment on column public.batches.batch_num is 'Системный номер пачки';

    comment on column public.batches.user_text is 'Текстовое имя создателя';

    comment on table public.equipment_types is 'Оборудование метеопоста - ДМК и ветровое ружье';

    comment on column public.equipment_types.code is 'Уникальный код типа оборудования';

    comment on column public.equipment_types.name is 'Наименование типа техники';

    comment on table public.parameters is 'Значения метеорологических параметров';

    comment on column public.parameters.code is 'Уникальный код записи параметра';

    comment on column public.parameters.name is 'Название характеристики';

    comment on column public.parameters.val is 'Числовое значение метеорологического параметра';

    comment on column public.users.position_code is 'Ссылка на код должности из таблицы positions';

    comment on column public.batches.user_code is 'Ссылка на код пользователя из таблицы users';

    comment on column public.parameters.eq_type_code is 'Ссылка на тип оборудования';

    comment on column public.parameters.batch_code is 'Ссылка на пачку в которой создали параметр';

    comment on table public.base_units is 'Базовые единицы измерения';

    comment on column public.base_units.code is 'Уникальный код базовой единицы';

    comment on column public.base_units.name is 'Наименование базовой единицы';

    comment on table public.units is 'Единицы измерения';

    comment on column public.units.code is 'Уникальный код единицы измерения';

    comment on column public.units.name is 'Сокращенное наименование';

    comment on column public.units.base_unit_code is 'Ссылка на базовую единицу измерения';

    comment on table public.parameter_types is 'Типы метеорологических параметров';

    comment on column public.parameter_types.code is 'Уникальный код типа параметра';

    comment on column public.parameter_types.name is 'Наименование типа параметра';

    comment on column public.parameters.parameter_type_code is 'Ссылка на тип параметра';

    comment on column public.parameters.unit_code is 'Ссылка на единицу измерения';

    comment on column public.batches.measurement_date is 'Дата измерения';
    comment on table public.temperature_table1 is 'Расчет температуры, таблица 1 - виртуальные поправки';
    comment on column public.temperature_table1.code is 'Номер записи таблицы 1';
    comment on column public.temperature_table1.temperature is 'Температура воздуха из таблицы 1';
    comment on column public.temperature_table1.correction is 'Виртуальная поправка к температуре';

    comment on sequence public.seq_positions is 'Счетчик кодов таблицы positions';

    comment on sequence public.seq_users is 'Счетчик кодов таблицы users';

    comment on sequence public.seq_batches is 'Счетчик кодов таблицы batches';

    comment on sequence public.seq_equipment_types is 'Счетчик кодов таблицы equipment_types';

    comment on sequence public.seq_parameters is 'Счетчик кодов таблицы parameters';

    comment on sequence public.seq_base_units is 'Счетчик кодов таблицы base_units';

    comment on sequence public.seq_units is 'Счетчик кодов таблицы units';

    comment on sequence public.seq_parameter_types is 'Счетчик кодов таблицы parameter_types';

    comment on sequence public.seq_temperature_table1 is 'Счетчик кодов таблицы temperature_table1';

end $$;
commit;
