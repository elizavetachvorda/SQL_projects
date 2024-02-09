
SELECT 
trip_id,
ROUND(CAST(duration_sec AS float64)/60,2) AS duration_min,
start_date,
start_station_name,
start_station_id,
end_date,
end_station_name,
end_station_id,
COALESCE(NULLIF(subscriber_type,'nan'),c_subscription_type) AS subscription_type,
start_station_latitude,
start_station_longitude,
end_station_latitude,
end_station_longitude
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips`
WHERE
FORMAT_TIMESTAMP('%Y'-%m-, start_date) >= '2017-07' AND
start_station_latitude IS NOT NULL AND
start_station_longitude IS NOT NULL AND
end_station_latitude IS NOT NULL AND
end_station_longitude IS NOT NULL AND
start_date < end_date AND
start_station_id IN (SELECT CAST(station_id AS INT64)
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info`
WHERE region_id = 3)
