-- структуры для справочных данных таблиц 2 и 3
do $$
begin

	begin
		create sequence calc_correction_height_seq;
		create table calc_correction_heights
		(
			id integer primary key not null default nextval('public.calc_correction_height_seq'),
			height integer not null unique
		);

		create sequence calc_correction_types_seq;
		create table calc_correction_types
		(
			id integer primary key not null default nextval('public.calc_correction_types_seq'),
			parent_id integer references public.calc_correction_types(id),
			measurment_equipment_id integer references public.measurment_equipment(id),
			description text not null,
			header_values integer[]
		);

		create sequence calc_correction_seq;
		create table calc_correction
		(
			id integer primary key not null default nextval('public.calc_correction_seq'),
			height_id integer not null references public.calc_correction_heights(id),
			type_id integer not null references public.calc_correction_types(id),
			row_values integer[] not null
		);
	end;

	begin
		comment on table public.calc_correction_heights is 'Таблица стандартных высот';
		comment on column public.calc_correction_heights.id is 'Уникальный код высоты';
		comment on column public.calc_correction_heights.height is 'Стандартная высота в метрах';

		comment on table public.calc_correction_types is 'Справочник типов таблиц корректировок';
		comment on column public.calc_correction_types.id is 'Уникальный код типа таблицы';
		comment on column public.calc_correction_types.parent_id is 'Код общей таблицы для подтипа';
		comment on column public.calc_correction_types.measurment_equipment_id is 'Код оборудования для варианта таблицы';
		comment on column public.calc_correction_types.description is 'Название таблицы или ее варианта';
		comment on column public.calc_correction_types.header_values is 'Значения входных данных по столбцам';

		comment on table public.calc_correction is 'Значения корректировок по высоте и типу таблицы';
		comment on column public.calc_correction.id is 'Уникальный код строки справочника';
		comment on column public.calc_correction.height_id is 'Код стандартной высоты';
		comment on column public.calc_correction.type_id is 'Код типа таблицы';
		comment on column public.calc_correction.row_values is 'Значения строки таблицы по порядку столбцов';
	end;

end;
$$;
