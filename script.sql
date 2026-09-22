drop table if exists parameters;
drop table if exists equipment_types;
drop table if exists batches;
drop table if exists users;
drop table if exists positions;
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
alter table parameters add eq_type_code int;
alter table parameters add batch_code int;
comment on column users.position_code is 'Ссылка на код должности из таблицы positions';
comment on column batches.user_code is 'Ссылка на код пользователя из таблицы users';
comment on column parameters.eq_type_code is 'Ссылка на тип оборудования';
comment on column parameters.batch_code is 'Ссылка на пачку в которой создали параметр';
insert into users(code, name, position_text, position_code) values(101, 'Иванов Иван', 'главный админ', 1);
insert into users(code, name, position_text, position_code) values(102, 'Петров Петр', 'модератор крутой какойто', null);
insert into users(code, name, position_text, position_code) values(103, 'Сидоров Алексей', 'стажер', 3);
select * from users where position_code is null;
update users set position_code = 2 where position_code is null;
insert into batches(code, batch_num, user_text, user_code) values(1001, 'BATCH-001', 'Иванов', 101);
insert into batches(code, batch_num, user_text, user_code) values(1002, 'BATCH-002', 'Петров', 102);
insert into parameters(code, name, val, eq_type_text, batch_text, eq_type_code, batch_code)
values(501, 'ОЗУ', '64GB', 'серверы', 'BATCH-001', 10, 1001);
insert into parameters(code, name, val, eq_type_text, batch_text, eq_type_code, batch_code)
values(502, 'Скорость', '1 Гбит/с', 'роутеры', 'BATCH-002', 20, 1002);
select 
    p.code as id_параметра,
    p.name as параметр,
    p.val as значение,
    et.name as тип,
    b.batch_num as пачка,
    u.name as автор,
    pos.name as должность
from parameters p
join equipment_types et on p.eq_type_code = et.code
join batches b          on p.batch_code = b.code
join users u            on b.user_code = u.code
join positions pos      on u.position_code = pos.code;
