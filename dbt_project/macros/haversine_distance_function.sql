{% macro haversine_distance_function(lat1, lon1, lat2, lon2) %}

CASE
    -- Check for NULL values
    WHEN lat1 IS NULL OR lon1 IS NULL OR lat2 IS NULL OR lon2 IS NULL THEN
        NULL
    -- Check for out-of-range values
    WHEN lat1 < -90 OR lat1 > 90 OR lon1 < -180 OR lon1 > 180 OR lat2 < -90 OR lat2 > 90 OR lon2 < -180 OR lon2 > 180 THEN
        null
    when lat1=lat2 and lon1=lon2 then 0
    ELSE
        -- Haversine distance calculation
        6371 * ACOS(COS(RADIANS(lat1)) * COS(RADIANS(lat2)) * COS(RADIANS(lon2) - RADIANS(lon1)) +
                    SIN(RADIANS(lat1)) * SIN(RADIANS(lat2)))
END;


{% endmacro %}