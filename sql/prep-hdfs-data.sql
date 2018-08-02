CREATE DATABASE IF NOT EXISTS weather;

CREATE EXTERNAL TABLE IF NOT EXISTS weather.noaa_ghcn_daily (
  `id` string,
  `obs_date` string,
  `ELEMENT` string,
  `ELEMENT_DATA` string,
  `M_FLAG` string,
  `Q_FLAG` string,
  `S_FLAG` string,
  `OBS_TIME` string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = ',',
  'field.delim' = ','
) LOCATION 's3://noaa-ghcn-pds/csv.gz/'
TBLPROPERTIES ('has_encrypted_data'='false');

CREATE TABLE IF NOT EXISTS weather.noaa_ghcn_daily_hdfs_pid_ym (
  obs_date date,
  ELEMENT string,
  ELEMENT_DATA int,
  M_FLAG string,
  Q_FLAG string,
  S_FLAG string,
  OBS_TIME string
)
PARTITIONED BY (id string, year int, month int)
STORED AS ORC;

INSERT OVERWRITE TABLE weather.noaa_ghcn_daily_hdfs_pid_ym PARTITION (id='USW00014821', year, month)
   SELECT cast(concat(substr(OBS_DATE,1,4),'-',substr(OBS_DATE,5,2),'-',substr(OBS_DATE,7,2)) as DATE),
   ELEMENT,
   CAST(ELEMENT_DATA as int),
   M_FLAG, Q_FLAG, S_FLAG, OBS_TIME,
   cast (substr(OBS_DATE,1,4) as int),
   cast (substr(OBS_DATE,5,2) as int)
   FROM weather.noaa_ghcn_daily
   where ID = 'USW00014821';
