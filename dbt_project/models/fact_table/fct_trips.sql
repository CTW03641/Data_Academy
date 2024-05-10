with taxi_table as (
select dl_start.location_id as start_location_id, 
dl_end.location_id as end_location_id, 
dd_start.date as start_date_id, 
dd_end.date as end_date_id,
dt_start.time as start_time_id, 
dt_end.time as end_time_id,
'taxi' as type_description,
case cabs.payment_type  
    when '1' then 'Credit card'
    when '2' then 'Cash'
    when '3' then 'No charge'
    when '4' then 'Dispute'
    when '5' then 'Unknown'
    when '6' then 'Voided trip'
    else 'EMPTY'
end as payment_description,
trip_distance * 1.60934 as distance_km, -- as km
EXTRACT(EPOCH FROM (cast(cabs.tpep_dropoff_datetime as timestamp)-cast(cabs.tpep_pickup_datetime as timestamp))) as duration_sec,
cabs.passenger_count as passengers_total,
cabs.tip_amount as tip_amount_dol,
cabs.total_amount as total_amount_dol
from ctw03641_staging.t_yellow_cabs cabs
inner join ctw03641_core.dim_date dd_start on cast(cabs.tpep_pickup_datetime as date) = dd_start."date" 
inner join ctw03641_core.dim_date dd_end on cast(cabs.tpep_dropoff_datetime as date)  = dd_end."date"
inner join ctw03641_core.dim_time dt_start on cast(cabs.tpep_pickup_datetime as time) = dt_start."time" 
inner join ctw03641_core.dim_time dt_end on cast(cabs.tpep_dropoff_datetime as time)  = dt_end."time"
join ctw03641_core.dim_location dl_start on dl_start.station_id = cast(cabs.pu_location_id as varchar)
join ctw03641_core.dim_location dl_end on dl_end.station_id = cast(cabs.do_location_id as varchar)
),
bike_table as (
    select dl_start.location_id as start_location_id, 
    dl_end.location_id as end_location_id, 
    dd_start.date as start_date_id, 
    dd_end.date as end_date_id,
    dt_start.time as start_time_id, 
    dt_end.time as end_time_id,
    rideable_type as type_description,
    'Credit card' as payment_description,
    haversine_distance(end_lat, end_lng, start_lat, start_lng) as distance_km,
    EXTRACT(EPOCH FROM (cast(ended_at as timestamp)-cast(started_at as timestamp))) as duration_sec,
    1 as passengers_total,
    0 as tip_amount_dol,
    0.20*(EXTRACT(EPOCH FROM (cast(ended_at as timestamp)-cast(started_at as timestamp)))/60) as total_amount_dol
    from ctw03641_staging.t_city_bikes tcb
    inner join ctw03641_core.dim_date dd_start on cast(tcb.started_at as date) = dd_start."date" 
    inner join ctw03641_core.dim_date dd_end on cast(tcb.ended_at as date)  = dd_end."date"
    inner join ctw03641_core.dim_time dt_start on cast(tcb.started_at as time) = dt_start."time" 
    inner join ctw03641_core.dim_time dt_end on cast(tcb.ended_at as time)  = dt_end."time"
    join ctw03641_core.dim_location dl_start on cast(dl_start.station_id as varchar) = tcb.start_station_id
    join ctw03641_core.dim_location dl_end on cast(dl_end.station_id as varchar) = tcb.end_station_id
    where tcb.end_station_id <>'' and tcb.end_station_id is not null
),
trips as (
    select start_location_id, 
    end_location_id, 
    start_date_id, 
    end_date_id,
    start_time_id, 
    end_time_id,
    type_description,
    payment_description,
    distance_km, 
    cast(duration_sec as int),
    cast(passengers_total as int),
    tip_amount_dol,
    total_amount_dol
    from taxi_table
    union all 
    select start_location_id, 
    end_location_id, 
    start_date_id, 
    end_date_id,
    start_time_id, 
    end_time_id,
    type_description,
    payment_description,
    distance_km, 
    cast(duration_sec as int),
    cast(passengers_total as int),
    tip_amount_dol,
    total_amount_dol
    from bike_table
)
select cast(row_number() over () as int) as trip_id, *
from trips