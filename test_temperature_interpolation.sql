-- Проверка примеров интерполяции из Db2026/_Docs/Artillery/TechnicalTask.md.
-- сначала запустить meteo_constants.sql, потом temperature_interpolation.sql.
DO $$
DECLARE
    v_params public.interpolations_type;
    v_actual numeric;
BEGIN
    -- ТЗ, пример расчёта ДТv при температуре 3 °C: ожидается 0.3.
    v_params := public.fn_get_interpolation_for_correction(3);
    v_actual := public.fn_interpolate_value(3, v_params);
    IF abs(v_actual - 0.3) > 0.000001 THEN
        RAISE EXCEPTION 'Тест t=3 °C не пройден: ожидалось 0.3, получено %', v_actual;
    END IF;
    RAISE NOTICE 'OK: t=3 °C, ΔTv=% (ожидалось 0.3), параметры=%', v_actual, v_params;

    -- ТЗ, пример 1: при t=23 °C интерполированная поправка равна 1.8.
    v_params := public.fn_get_interpolation_for_correction(23);
    v_actual := public.fn_interpolate_value(23, v_params);
    IF abs(v_actual - 1.8) > 0.000001 THEN
        RAISE EXCEPTION 'Тест t=23 °C не пройден: ожидалось 1.8, получено %', v_actual;
    END IF;
    RAISE NOTICE 'OK: t=23 °C, ΔTv=% (ожидалось 1.8), параметры=%', v_actual, v_params;

    -- Функция интерполяции принимает произвольный x, а не только температуру узла.
    v_params := public.fn_get_interpolation_for_correction(3);
    v_actual := public.fn_interpolate_value(2.5, v_params);
    IF abs(v_actual - 0.25) > 0.000001 THEN
        RAISE EXCEPTION 'Тест произвольного x не пройден: ожидалось 0.25, получено %', v_actual;
    END IF;
    RAISE NOTICE 'OK: произвольный x=2.5, y=% (ожидалось 0.25)', v_actual;

    -- Проверяем ограничение результата на концах диапазона табличных температур.
    v_actual := public.fn_interpolate_value(-10, public.fn_get_interpolation_for_correction(-10));
    IF abs(v_actual - 0) > 0.000001 THEN
        RAISE EXCEPTION 'Тест нижней границы не пройден: ожидалось 0, получено %', v_actual;
    END IF;
    RAISE NOTICE 'OK: ниже диапазона, y=% (ожидалось 0)', v_actual;

    v_actual := public.fn_interpolate_value(50, public.fn_get_interpolation_for_correction(50));
    IF abs(v_actual - 4.5) > 0.000001 THEN
        RAISE EXCEPTION 'Тест верхней границы не пройден: ожидалось 4.5, получено %', v_actual;
    END IF;
    RAISE NOTICE 'OK: выше диапазона, y=% (ожидалось 4.5)', v_actual;

    RAISE NOTICE 'Все проверки интерполяции успешно пройдены.';
END;
$$;
