with times as (
    select
        generate_series(
            '2023-01-01 00:00:00'::timestamp,
            '2023-01-01 23:59:59'::timestamp,
            interval '1 second'
        ) as time
)
select
    CAST(time AS TIME) AS time,
    CAST(extract(hour from time) AS INTEGER) as hour,
    CAST(extract(minute from time) AS INTEGER) as minutes,
    CAST(extract(second from time) AS INTEGER) as seconds
from
    times