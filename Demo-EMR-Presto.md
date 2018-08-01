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
[Presto](https://prestodb.io/) website


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

### Using the Hue Hive query editor:

1. Choose "Editor" then "Hive" from the "Query" button on the top action bar
1. Create a "weather" database:
    ```
    CREATE DATABASE IF NOT EXISTS weather;
    ```    
    Once the command completes, use the quick browse area to view all Hive databases and see that it was created. If 
    it doesn't appear, use the refresh button.
1. Create an external table pointed at the [NOAA Global Historical Climatology Network Daily (GHCN-D)](https://registry.opendata.aws/noaa-ghcn/)
    weather observations data in S3
    ```
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
    ```    

### Using the Presto query editor:

1. Determine the average low and high temperatures for every month going back to 1945:
    ```
    select l.id, l.year, l.month, round(avg(l.element_data * 0.18 + 32),2) AVG_LOW_TEMP_F, round(avg(h.element_data * 0.18 + 32),2) AVG_HIGH_TEMP_F 
    from weather.noaa_ghcn_daily_pid_ym as l
    JOIN weather.noaa_ghcn_daily_pid_ym as h ON (l.id = h.id AND l.year = h.year AND l.month = h.month)
    where l.ID = 'USW00014821'
        and l.element = 'TMIN'
        and h.element = 'TMAX'
    group by l.id, l.year, l.month
    order by l.year, l.month
    ``` 
1. Switch to the Hive editor and run the query above. Was it slower or faster?
1. Since the start of 2008:
    ```
    select l.id, l.year, l.month, round(avg(l.element_data * 0.18 + 32),2) AVG_LOW_TEMP_F, round(avg(h.element_data * 0.18 + 32),2) AVG_HIGH_TEMP_F 
    from weather.noaa_ghcn_daily_pid_ym as l
    JOIN weather.noaa_ghcn_daily_pid_ym as h ON (l.id = h.id AND l.year = h.year AND l.month = h.month)
    where l.ID = 'USW00014821'
        and l.year >= 2008
        and l.element = 'TMIN'
        and h.element = 'TMAX'
    group by l.id, l.year, l.month
    order by l.year, l.month
    ```
1. Switch to the Hive editor and run the query above. Was it slower or faster?
    