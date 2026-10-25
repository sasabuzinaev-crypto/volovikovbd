-- таблица температурных поправок создается в meteo_constants.sql
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = 'public'
          AND t.typname = 'interpolations_type'
    ) THEN
        CREATE TYPE public.interpolations_type AS (
            x0 numeric,
            y0 numeric,
            x1 numeric,
            y1 numeric
        );
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_get_interpolation_for_correction(
    par_temperature numeric
)
RETURNS public.interpolations_type
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    var_result public.interpolations_type;
BEGIN
    IF par_temperature IS NULL THEN
        RAISE EXCEPTION 'Температура для интерполяции не может быть NULL';
    END IF;

    SELECT
        COALESCE(
            (SELECT MAX(t1.temperature)
             FROM public.calc_temperature_correction t1
             WHERE t1.temperature <= p.target_temp),
            p.target_temp
        ),
        COALESCE(
            (SELECT t3.correction
             FROM public.calc_temperature_correction t3
             WHERE t3.temperature = (
                 SELECT MAX(t1.temperature)
                 FROM public.calc_temperature_correction t1
                 WHERE t1.temperature <= p.target_temp
             )),
            (SELECT t4.correction
             FROM public.calc_temperature_correction t4
             WHERE t4.temperature = (
                 SELECT MIN(t2.temperature)
                 FROM public.calc_temperature_correction t2
             ))
        ),
        COALESCE(
            (SELECT MIN(t1.temperature)
             FROM public.calc_temperature_correction t1
             WHERE t1.temperature >= p.target_temp),
            p.target_temp
        ),
        COALESCE(
            (SELECT t3.correction
             FROM public.calc_temperature_correction t3
             WHERE t3.temperature = (
                 SELECT MIN(t1.temperature)
                 FROM public.calc_temperature_correction t1
                 WHERE t1.temperature >= p.target_temp
             )),
            (SELECT t4.correction
             FROM public.calc_temperature_correction t4
             WHERE t4.temperature = (
                 SELECT MAX(t2.temperature)
                 FROM public.calc_temperature_correction t2
             ))
        )
    INTO var_result.x0, var_result.y0, var_result.x1, var_result.y1
    FROM (SELECT par_temperature AS target_temp) p;

    IF var_result.y0 IS NULL OR var_result.y1 IS NULL THEN
        RAISE EXCEPTION 'В таблице calc_temperature_correction нет данных';
    END IF;

    RETURN var_result;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_interpolate_value(
    p_x numeric,
    p_params public.interpolations_type
)
RETURNS numeric
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    IF p_x IS NULL OR p_params IS NULL THEN
        RAISE EXCEPTION 'Значение x и параметры интерполяции не могут быть NULL';
    END IF;

    IF p_params.x0 IS NULL OR p_params.y0 IS NULL
       OR p_params.x1 IS NULL OR p_params.y1 IS NULL THEN
        RAISE EXCEPTION 'Все координаты x0, y0, x1, y1 должны быть заданы';
    END IF;

    IF p_params.x0 = p_params.x1 THEN
        RETURN p_params.y0;
    END IF;

    RETURN p_params.y0
         + (p_x - p_params.x0) * (p_params.y1 - p_params.y0)
           / (p_params.x1 - p_params.x0);
END;
$$;

comment on table public.calc_temperature_correction is
    'таблица температур и поправок из задания';
comment on column public.calc_temperature_correction.temperature is
    'температура';
comment on column public.calc_temperature_correction.correction is
    'поправка для этой температуры';
comment on type public.interpolations_type is
    'тип с точками x0, y0, x1 и y1 для интерполяции';
comment on column public.interpolations_type.x0 is
    'первая температура';
comment on column public.interpolations_type.y0 is
    'поправка для первой температуры';
comment on column public.interpolations_type.x1 is
    'вторая температура';
comment on column public.interpolations_type.y1 is
    'поправка для второй температуры';
comment on function public.fn_get_interpolation_for_correction(numeric) is
    'находит две точки рядом с заданной температурой';
comment on function public.fn_interpolate_value(numeric, public.interpolations_type) is
    'считает поправку для заданного значения x';
