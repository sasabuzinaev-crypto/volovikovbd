drop table if exists parameters;
drop table if exists equipment_types;
drop table if exists batches;
drop table if exists users;
drop table if exists positions;
drop table if exists units;
drop table if exists base_units;
drop table if exists parameter_types;
create table positions (
    code int primary key,
    name text
);
comment on table positions is 'Справочник ролей и должностей пользователей';
comment on column positions.code is 'Уникальный код должности';
comment on column positions.name is 'Название роли ';

create table users (
    code int primary key,
    name text,
    position_text text
);
comment on table users is 'Таблица учетных записей администраторов';
comment on column users.code is 'Уникальный код пользователя';
comment on column users.name is 'ФИО сотрудника';
comment on column users.position_text is 'Текстовое описание роли до привязки';

create table batches (
    code int primary key,
    batch_num text,
    user_text text
);
comment on table batches is 'Журнал пакетов данных и загрузок';
comment on column batches.code is 'Уникальный код пачки';
comment on column batches.batch_num is 'Системный номер пачки';
comment on column batches.user_text is 'Текстовое имя создателя';

create table equipment_types (
    code int primary key,
    name text
);
comment on table equipment_types is 'Категории обслуживаемой техники';
comment on column equipment_types.code is 'Уникальный код типа оборудования';
comment on column equipment_types.name is 'Наименование типа техники';

create table parameters (
    code int primary key,
    name text,
    val text,
    eq_type_text text,
    batch_text text
);
comment on table parameters is 'Конфигурационные параметры оборудования';
comment on column parameters.code is 'Уникальный код записи параметра';
comment on column parameters.name is 'Название характеристики';
comment on column parameters.val is 'Значение параметра';

insert into positions(code, name) values(1, 'главный админ');
insert into positions(code, name) values(2, 'модератор');
insert into positions(code, name) values(3, 'стажер');
insert into equipment_types(code, name) values(10, 'серверы');
insert into equipment_types(code, name) values(20, 'роутеры');

alter table users add position_code int;
alter table batches add user_code int;
alter table batches add measurement_date timestamp; -- Поле успешно добавлено в структуру
alter table parameters add eq_type_code int;
alter table parameters add batch_code int;

comment on column users.position_code is 'Ссылка на код должности из таблицы positions';
comment on column batches.user_code is 'Ссылка на код пользователя из таблицы users';
comment on column parameters.eq_type_code is 'Ссылка на тип оборудования';
comment on column parameters.batch_code is 'Ссылка на пачку в которой создали параметр';

insert into users(code, name, position_text, position_code) values(101, 'Иванов Иван', 'главный admin', 1);
insert into users(code, name, position_text, position_code) values(102, 'Петров Петр', 'модератор крутой какойто', null);
insert into users(code, name, position_text, position_code) values(103, 'Сидоров Алексей', 'стажер', 3);

update users set position_code = 2 where position_code is null;

insert into batches(code, batch_num, user_text, user_code, measurement_date) values(1001, 'BATCH-001', 'Иванов', 101, '2026-09-29 14:00:00');
insert into batches(code, batch_num, user_text, user_code, measurement_date) values(1002, 'BATCH-002', 'Петров', 102, '2026-09-29 15:30:00');

insert into parameters(code, name, val, eq_type_text, batch_text, eq_type_code, batch_code)
values(501, 'ОЗУ', '64GB', 'серверы', 'BATCH-001', 10, 1001);
insert into parameters(code, name, val, eq_type_text, batch_text, eq_type_code, batch_code)
values(502, 'Скорость', '1 Гбит/с', 'роутеры', 'BATCH-002', 20, 1002);
create table base_units (
    code int primary key,
    name text not null
);
comment on table base_units is 'Базовые единицы измерения';
comment on column base_units.code is 'Уникальный код базовой единицы';
comment on column base_units.name is 'Наименование базовой единицы';

create table units (
    code int primary key,
    name text not null,
    base_unit_code int
);
comment on table units is 'Единицы измерения';
comment on column units.code is 'Уникальный код единицы измерения';
comment on column units.name is 'Сокращенное наименование';
comment on column units.base_unit_code is 'Ссылка на базовую единицу измерения';

create table parameter_types (
    code int primary key,
    name text not null
);
comment on table parameter_types is 'Типы параметров конфигурации';
comment on column parameter_types.code is 'Уникальный код типа параметра';
comment on column parameter_types.name is 'Наименование типа параметра';
alter table parameters add parameter_type_code int;
alter table parameters add unit_code int;

comment on column parameters.parameter_type_code is 'Ссылка на тип параметра';
comment on column parameters.unit_code is 'Ссылка на единицу измерения';

insert into base_units (code, name) values (1, 'Объем данных');
insert into base_units (code, name) values (2, 'Скорость передачи');

insert into units (code, name, base_unit_code) values (10, 'GB', 1);
insert into units (code, name, base_unit_code) values (20, 'Гбит/с', 2);

insert into parameter_types (code, name) values (100, 'Аппаратная конфигурация');
insert into parameter_types (code, name) values (200, 'Сетевая характеристика');

update parameters set parameter_type_code = 100, unit_code = 10 where code = 501;
update parameters set parameter_type_code = 200, unit_code = 20 where code = 502;
alter table parameters drop column eq_type_text;
alter table parameters drop column batch_text;
select 
    b.measurement_date as "Дату измерения",
    b.batch_num as "Номер пачки",
    u.name as "ФИО сотрудника",
    (p.name || ' (' || un.name || ')') as "Параметр (Ед. изм.)",
    p.val as "Значение"
from parameters p, batches b, users u, units un, parameter_types pt
where p.batch_code = b.code
  and b.user_code = u.code
  and p.unit_code = un.code
  and p.parameter_type_code = pt.code;
