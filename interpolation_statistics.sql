select
    row_number() over (order by temperature) as id,
    temperature as x0,
    correction as y0,
    coalesce(lead(temperature) over (order by temperature), temperature) as x1,
    coalesce(lead(correction) over (order by temperature), correction) as y1,
    round(public.fn_interpolate_value(
        (
            temperature
            + coalesce(lead(temperature) over (order by temperature), temperature)
        ) / 2,
        (
            temperature,
            correction,
            coalesce(lead(temperature) over (order by temperature), temperature),
            coalesce(lead(correction) over (order by temperature), correction)
        )::public.interpolations_type
    ), 2) as y
from public.calc_temperature_correction
order by temperature;
