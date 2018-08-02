# Using Apache Hive with HUE

## Prerequisites:

* You completed [Launching an Elastic Map Reduce (EMR) Cluster](./Demo-EMR-Launch.md)
* Your custer is in a "Waiting" state


## References:

[Hue User Guide](http://cloudera.github.io/hue/latest/user-guide/user-guide.html) \
[AWS Hue Documentation](https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-hue.html) \
[HUE](http://gethue.com/) website \
[Apache Hive](http://hive.apache.org/) website \
[Hive Language Manual](https://cwiki.apache.org/confluence/display/Hive/LanguageManual)


## Launching HUE:

1. Choose EMR from the Services screen
1. From the EMR cluster dashboard click on the running cluster name
1. From "Connections:" click on "Hue"
1. If you get a warning your connection is not secure:
    1. Choose "Advanced" then "Add Exception"
    1. Uncheck "Permanently store this exception"
    1. Click, "Confirm Security Exception"
1. Enter `hadoop` for the username and `Hiv3-Demo` for the password and click "Create Account"
1. Click through the "Hue 4 welcome" making note of each feature presented

## New Hue Users:

Spend a few minutes reviewing the [Hue user interface guide](http://cloudera.github.io/hue/latest/user-guide/user-guide.html)
until you feel comfortable navigating between various editors (Spark, PySpark, Hive, ...) and 
using the "quick browse" area to view database and tables, files and directories in HDFS and objects in 
S3 buckets. 

**Tips:** 
* Use CTRL/Cmd + ENTER to execute queries
* CTRL/Cmd + A followed by Backspace to clear the query window prior to entering the next SQL statement 

## Analyzing data with Hive:

1. Choose "Editor" then "Hive" from the "Query" button on the top action bar
1. Create a "weather" database:
    ```
    create database weather;
    ```    
    Once the command completes, use the quick browse area to view all Hive databases and see that it was created. If 
    it doesn't appear, use the refresh button.
1. Create an external table pointed at the [NOAA Global Historical Climatology Network Daily (GHCN-D)](https://registry.opendata.aws/noaa-ghcn/)
    weather observations data in S3
    ```
    CREATE EXTERNAL TABLE weather.noaa_ghcn_daily (
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
    ```    
1. Create a view that makes the observation date Hive friendly and converts the element_data to an integer:
    ```
    create view weather.noaa_ghcn_daily_view as
       select ID, 
       concat(substr(OBS_DATE,1,4),'-',substr(OBS_DATE,5,2),'-',substr(OBS_DATE,7,2)) OBS_DATE,
       ELEMENT,
       CAST(ELEMENT_DATA as int),
       M_FLAG,
       Q_FLAG,
       S_FLAG,
       OBS_TIME
    from weather.noaa_ghcn_daily;
    ```    
1. For better performance, create an [managed](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL#LanguageManualDDL-ManagedandExternalTables)
   table [partitioned](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL#LanguageManualDDL-PartitionedTables) 
   by the weather station ID, stored in [Parquet format](https://cwiki.apache.org/confluence/display/Hive/Parquet):
    ```
    CREATE TABLE weather.noaa_ghcn_daily_pid (
      obs_date date,
      ELEMENT string,
      ELEMENT_DATA int,
      M_FLAG string,
      Q_FLAG string,
      S_FLAG string,
      OBS_TIME string
    ) 
    PARTITIONED BY (id string)
    STORED AS PARQUET;
    ```    
1. Load data for the Port Columbus station (id='USW00014821') for all of 2018. This will take about 10 minutes:
    ```
    INSERT OVERWRITE TABLE weather.noaa_ghcn_daily_pid PARTITION (id='USW00014821')
    SELECT OBS_DATE, ELEMENT, ELEMENT_DATA, M_FLAG, Q_FLAG, S_FLAG, OBS_TIME
    FROM weather.noaa_ghcn_daily_view
    where ID = 'USW00014821'
    and YEAR(OBS_DATE) = 2018;
    ```    
    NOTE:  If you want to see all the data, omit  `and YEAR(OBS_DATE) = 2018`. The data load will take the same time but
    subsequent queries of this table will run slower because it has more data. 
1. View raw data:
    ```
    select * from weather.noaa_ghcn_daily_pid
    LIMIT 20;
    ```
1. Per the [dataset documentation](https://docs.opendata.aws/noaa-ghcn-pds/readme.html) the temperatures are in tenths 
of degrees celsius so view element data as fahrenheit for rows with an element of 'TMIN':
    ```
    select id, obs_date, element_data * 0.18 + 32 LOW_TEMP_F
    from weather.noaa_ghcn_daily_pid
    where element = 'TMIN'
    ```    
1. Create a query that show both the low and high temperatures for each day in fahrenheit and rounded to the nearest degree:
    ```
    select a.id, a.obs_date, round(a.element_data * 0.18 + 32) LOW_TEMP_F, round(b.element_data * 0.18 + 32) HIGH_TEMP_F
    from weather.noaa_ghcn_daily_pid a 
    JOIN weather.noaa_ghcn_daily_pid b ON (a.id = b.id AND a.obs_date = b.obs_date)
    where a.ID = 'USW00014821'
    and a.element = 'TMIN'
    and b.element = 'TMAX'
    order by a.obs_date;
    ```    
1. Once we terminate our cluster, the managed table we created above will be deleted. We can use Hive to create a
performance optimized external table stored in S3 which can be accessed future instances of EMR along with 
[Amazon Athena](https://aws.amazon.com/athena/) 
and even [Redshift Spectrum](https://aws.amazon.com/redshift/faqs/):
    1. Using the Amazon Console, [create an S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html) to store your data
    1. Substituting the bucket name from the step above for "YOUR-BUCKET-NAME-HERE" in the statement below, create the
    S3 external table: 
    ```
    CREATE EXTERNAL TABLE weather.noaa_ghcn_daily_pid_ym (
      obs_date date,
      ELEMENT string,
      ELEMENT_DATA int,
      M_FLAG string,
      Q_FLAG string,
      S_FLAG string,
      OBS_TIME string
    ) 
    PARTITIONED BY (id string, year int, month int)
    STORED AS PARQUET
    LOCATION 's3://YOUR-BUCKET-NAME-HERE/noaa_ghcn_daily/parquet';
    ```    
    NOTE: The table above has two additional partitions, one for YEAR and the other for MONTH. This makes it even faster to 
    select data for specific time periods by including them in the "WHERE" clause of subsequent queries.
1. Using the public dataset, create and load the load your newly created table (*this will take 12-15 minutes to complete*):
    ```
    INSERT OVERWRITE TABLE weather.noaa_ghcn_daily_pid_ym PARTITION (id='USW00014821', year, month)
       SELECT OBS_DATE, ELEMENT, ELEMENT_DATA, M_FLAG, Q_FLAG, S_FLAG, OBS_TIME,
       YEAR(OBS_DATE), MONTH(OBS_DATE)
       FROM weather.noaa_ghcn_daily_view
       where ID = 'USW00014821'
    ```
    NOTE: to load data for additional weather stations, repeat the SQL statement above omitting the "OVERWRITE" directive
    and entering the desired station ID in the "PARTITION" and "WHERE" clauses     
1. Query your newly loaded table for average low temperatures in every month in 2017:
    ```
    select id, year, month, round(avg(element_data * 0.18 + 32),2) AVG_LOW_TEMP_F
    from weather.noaa_ghcn_daily_pid_ym
    where ID = 'USW00014821'
    and year = 2017
    and element = 'TMIN'
    group by id, year, month;
    ```    
1. Finally, query the new table to see both the high and low temperatures for each month on 2017 :
    ```
    select l.id, l.month, round(avg(l.element_data * 0.18 + 32),2) AVG_LOW_TEMP_F, round(avg(h.element_data * 0.18 + 32),2) AVG_HIGH_TEMP_F 
    from weather.noaa_ghcn_daily_pid_ym as l
    JOIN weather.noaa_ghcn_daily_pid_ym as h ON (l.id = h.id AND l.year = h.year AND l.month = h.month)
    where l.ID = 'USW00014821'
        and l.element = 'TMIN'
        and h.element = 'TMAX'
        and l.year = 2017
    group by l.id, l.year, l.month
    order by l.month;
    ```


## Uploading data and creating a table

## Where to go from here

[Submitting Steps to EMR](Demo-EMR-Steps.md) \
[Using Presto with Hue](./Demo-EMR-Presto.md) \
[Using Spark with Jupyter](./Demo-Spark-Jupyter.md)  \
[Using EMR to do ETL](Demo-EMR-as-ETL.md) 

## Finally

Once you are done with the demos, terminate your cluster to avoid additional charges. 
