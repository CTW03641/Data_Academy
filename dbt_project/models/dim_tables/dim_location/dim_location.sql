with geolocation_start_taxi AS (
select cast(cabs.do_location_id as varchar) station_id, 
case when ttz_start.location_id is null or ttz_start_shp.location_id is null then 'Unknown' else ttz_start.borough end as borough,
case when ttz_start.location_id is null or ttz_start_shp.location_id is null then 'Unknown' else ttz_start.zone end as "zone",
cast(ttz_start_shp.object_id as int), 
cast(ttz_start_shp.shape_area as float), 
cast(ttz_start_shp.shape_leng as float), 
cast(ttz_start_shp.geometry as text)
from ctw03641_staging.t_yellow_cabs cabs
left join ctw03641_core.t_taxi_zone ttz_start on cabs.do_location_id = cast(ttz_start.location_id as varchar)
left join ctw03641_staging.t_taxi_zones_shp ttz_start_shp on cast(ttz_start.location_id as varchar) = ttz_start_shp.object_id
),
geolocation_end_taxi AS (
    select cast(cabs.pu_location_id as varchar) station_id, 
    case when ttz_end.location_id is null or ttz_end_shp.location_id is null then 'Unknown' else ttz_end.borough end as borough,
    case when ttz_end.location_id is null or ttz_end_shp.location_id is null then 'Unknown' else ttz_end.zone end as "zone",
    cast(ttz_end_shp.object_id as int), 
    cast(ttz_end_shp.shape_area as float), 
    cast(ttz_end_shp.shape_leng as float), 
    cast(ttz_end_shp.geometry as text)
    from ctw03641_staging.t_yellow_cabs cabs
    left join ctw03641_core.t_taxi_zone ttz_end on cabs.pu_location_id = cast(ttz_end.location_id as varchar)
    left join ctw03641_staging.t_taxi_zones_shp ttz_end_shp on cast(ttz_end.location_id as varchar) = ttz_end_shp.object_id
),
geolocation_start_bikes as(
    select distinct cast(start_station_id as varchar) station_id, 
    case when start_zone.terminal_id is null then 'Unknown' else start_zone.borough end as borough,
    case when start_zone.terminal_id is null then 'Unknown' else start_zone.zone end as "zone",
    cast(null as int) as object_id, 
    cast(null as float) as shape_area, 
    cast(null as float) as shape_leng, 
    cast(null as text) as geometry
    from ctw03641_staging.t_city_bikes b
    left join ctw03641_core.t_city_bikes_zone start_zone on b.start_station_id = cast(start_zone.terminal_id as varchar)
),
geolocation_end_bikes as(
    select distinct cast(end_station_id as varchar) station_id, 
    case when end_zone.terminal_id is null then 'Unknown' else end_zone.borough end as borough,
    case when end_zone.terminal_id is null then 'Unknown' else end_zone.zone end as "zone",
    cast(null as int) as object_id, 
    cast(null as float) as shape_area, 
    cast(null as float) as shape_leng, 
    cast(null as text) as geometry
    from ctw03641_staging.t_city_bikes b
    left join ctw03641_core.t_city_bikes_zone end_zone on b.end_station_id = cast(end_zone.terminal_id as varchar)
    where b.end_station_id <>''
),
geolocation_taxi as(
    select * from geolocation_start_taxi
    union
    select * from geolocation_end_taxi
),
geolocation_bikes as(
    select * from geolocation_start_bikes
    union
    select * from geolocation_end_bikes
),
-- Merge citibikes and taxi locations
merge_locations as (
    select * from geolocation_bikes
    union all
    select * from geolocation_taxi
)
select cast(row_number() over () as int) as location_id, *
from merge_locations