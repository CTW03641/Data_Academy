with dates as (
    select
        generate_series(
            '2023-01-01'::date,
            '2024-01-01'::date,
            interval '1 day'
        ) as date
)
select
    CAST( to_char(date, 'YYYY-MM-DD') AS DATE ) AS date,
    CAST( extract(day from date) AS INTEGER ) as day,
    CAST( extract(month from date) AS INTEGER ) as month,
    CAST( to_char(date, 'Month') AS varchar(20) ) as month_description,
    CAST( extract(year from date) AS INTEGER ) as year,
    CAST( to_char(date, 'Day') AS varchar(20) ) as week_day,
    CAST( extract(week from date) AS INTEGER ) as week_number,
    case
        when extract(month from date) in (12, 1, 2) then CAST( 'Winter' AS varchar(20) )
        when extract(month from date) in (3, 4, 5) then CAST( 'Spring' AS varchar(20) )
        when extract(month from date) in (6, 7, 8) then CAST( 'Summer' AS varchar(20) )
        when extract(month from date) in (9, 10, 11) then CAST( 'Autumn' AS varchar(20) )
    end as season
from
    dates