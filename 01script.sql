drop table if exists measurement_input_params cascade;
drop table if exists measurement_batchs cascade;
drop table if exists measurement_parameter_types cascade;
drop table if exists units cascade;
drop table if exists base_units cascade;
drop table if exists measurement_equipment cascade;
drop table if exists employees cascade;
drop table if exists military_positions cascade;

create table military_positions
(
    id integer primary key,
    description character varying(255)
);
comment on table military_positions is 'Справочник должностей';

insert into military_positions(id, description) values
(1, 'Рядовой'), (2, 'Лейтенант'), (3, 'Сержант');

create table employees
(
    id integer primary key,
    name text,
    birthday timestamp,
    military_position_id integer references military_positions(id)
);
comment on table employees is 'Пользователи';

insert into employees(id, name, birthday, military_position_id) values
(1, 'Воловиков Александр Сергеевич', '1978-06-24', 2),
(2, 'Иванов Петр Иванович', '1985-03-12', 1),
(3, 'Сидоров Алексей Викторович', '1990-11-05', 3);

create table measurement_equipment
(
   id integer primary key,
   short_name character varying(50),
   description text 
);
comment on table measurement_equipment is 'Измерительное оборудование';

insert into measurement_equipment(id, short_name, description) values
(1, 'ДМК', 'Десантный метео комплекс'),
(2, 'ВР', 'Ветровое ружье');

create table base_units
(
    id integer primary key,
    name text
);
comment on table base_units is 'Базовые единицы измерения';

insert into base_units(id, name) values 
(1, 'Метр'), (2, 'Градус'), (3, 'Паскаль');

create table units
(
    id integer primary key,
    name text,
    base_unit_id integer references base_units(id),
    convert_factor integer
);
comment on table units is 'Единицы измерения';

insert into units(id, name, base_unit_id, convert_factor) values
(1, 'Киллометр', 1, 1000),
(2, 'Градус', 2, 1),
(3, 'Паскаль', 3, 1),
(4, 'Метр', 1, 1),
(5, 'Миллиметры ртутного столба', null, null),
(6, 'Метр в секунду', null, null);

create table measurement_parameter_types
(
   id integer primary key,
   name text,
   unit_id integer references units(id),
   measurement_equipment_id integer references measurement_equipment(id)
);
comment on table measurement_parameter_types is 'Справочник типов параметров';

insert into measurement_parameter_types(id, name, unit_id, measurement_equipment_id) values
(1, 'Высота метеопаста', 4, null),
(2, 'Температура', 2, null),
(3, 'Давление', 5, null),
(4, 'Направление ветра', null, null),
(5, 'Скорость ветра', 6, 1),
(6, 'Дальность сноса пуль', null, 2);

create table measurement_batchs
(
    id integer primary key,
    employee_id integer references employees(id),
    measurement_equipment_id integer references measurement_equipment(id),
    started timestamp default now()
);
comment on table measurement_batchs is 'Пачки';

create table measurement_input_params
(
    id integer primary key,
    measurement_batch_id integer references measurement_batchs(id),
    measurement_parameter_type_id integer references measurement_parameter_types(id),
    measurement_value numeric(10,2) default 0
);
comment on table measurement_input_params is 'Таблица с параметрами';
INSERT INTO measurement_batchs (id, employee_id, measurement_equipment_id, started) VALUES
(101, 1, 1, '2025-10-04 08:00:00'),
(102, 1, 1, '2025-10-04 09:00:00'),
(103, 2, 1, '2025-10-04 08:15:00'),
(104, 2, 1, '2025-10-04 09:15:00'),
(105, 3, 1, '2025-10-04 08:30:00'),
(106, 3, 1, '2025-10-04 09:30:00');

INSERT INTO measurement_input_params (id, measurement_batch_id, measurement_parameter_type_id, measurement_value) VALUES
(1001, 101, 1, 150),
(1002, 101, 2, 22.5),
(1003, 101, 3, 1013),
(1004, 101, 4, 90),
(1005, 101, 5, 12.3),
(1006, 102, 1, 180),
(1007, 102, 2, 18.0),
(1008, 102, 3, 1005),
(1009, 102, 4, 270),
(1010, 102, 5, 8.5),
(1011, 103, 1, 120),
(1012, 103, 2, 5.5),
(1013, 103, 3, 998),
(1014, 103, 4, 180),
(1015, 103, 5, 25.0),
(1016, 104, 1, 165),
(1017, 104, 2, 10.0),
(1018, 104, 3, 1002),
(1019, 104, 4, 45),
(1020, 104, 5, 3.2),
(1021, 105, 1, 195),
(1022, 105, 2, -15.0),
(1023, 105, 3, 960),
(1024, 105, 4, 315),
(1025, 105, 5, 42.1),
(1026, 106, 1, 110),
(1027, 106, 2, 35.5),
(1028, 106, 3, 1045),
(1029, 106, 4, 0),
(1030, 106, 5, 0.0);