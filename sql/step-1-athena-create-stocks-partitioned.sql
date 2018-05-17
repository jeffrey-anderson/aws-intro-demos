CREATE EXTERNAL TABLE STOCKS_PARTITIONED (
  price_date string,
  open_price string,
  high_price string,
  low_price string,
  close_price string,
  adjusted_close string,
  Volume string
)
PARTITIONED BY (symbol string)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
   'separatorChar' = ',',
   'quoteChar' = '\"',
   'escapeChar' = '\\'
   )
STORED AS TEXTFILE
LOCATION 's3://jaa-athena-data/partitioned'
TBLPROPERTIES (
  "skip.header.line.count"="1"
);
