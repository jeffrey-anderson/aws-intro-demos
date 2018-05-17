CREATE EXTERNAL TABLE STOCKS (
  Symbol string,
  price_date string,
  open_price string,
  high_price string,
  low_price string,
  close_price string,
  adjusted_close string,
  Volume string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
   'separatorChar' = ',',
   'quoteChar' = '\"',
   'escapeChar' = '\\'
   )
STORED AS TEXTFILE
LOCATION 's3://jaa-athena-data/stocks/'
TBLPROPERTIES (
  "skip.header.line.count"="1"
);
