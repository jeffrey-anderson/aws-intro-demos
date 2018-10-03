# Using Apache Hive with HUE

## Prerequisites:

* You completed [Launching an Elastic Map Reduce (EMR) Cluster](./Demo-EMR-Launch.md)
* Your custer is in a "Waiting" state
* You completed the [Submitting Steps to EMR](Demo-EMR-Steps.md) walk-through


## References:

[Hue User Guide](http://cloudera.github.io/hue/latest/user-guide/user-guide.html) \
[AWS Hue Documentation](https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-hue.html) \
[HUE](http://gethue.com/) website \
[Apache Hive](http://hive.apache.org/) website \
[Hive Language Manual](https://cwiki.apache.org/confluence/display/Hive/LanguageManual) \
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


### Querying Hive data with Presto:

1. Choose "Editor" then "Presto" from the "Query" drop down
1. Determine the yearly average low and high temperatures for every year:
    ```
    select l.id, l.year, round(avg(l.element_data * 0.18 + 32),2) AVG_LOW_TEMP_F, round(avg(h.element_data * 0.18 + 32),2) AVG_HIGH_TEMP_F 
    from weather.noaa_ghcn_daily_hdfs_pid_ym as l
    JOIN weather.noaa_ghcn_daily_hdfs_pid_ym as h ON (l.id = h.id AND l.year = h.year AND l.month = h.month)
    where l.ID = 'USW00014821'
        and l.element = 'TMIN'
        and h.element = 'TMAX'
    group by l.id, l.year
    order by l.year
    ```
1.  Run the same analysis for every month:
    ```
    select l.id, l.year, l.month, round(avg(l.element_data * 0.18 + 32),2) AVG_LOW_TEMP_F, round(avg(h.element_data * 0.18 + 32),2) AVG_HIGH_TEMP_F 
    from weather.noaa_ghcn_daily_hdfs_pid_ym as l
    JOIN weather.noaa_ghcn_daily_hdfs_pid_ym as h ON (l.id = h.id AND l.year = h.year AND l.month = h.month)
    where l.ID = 'USW00014821'
        and l.element = 'TMIN'
        and h.element = 'TMAX'
    group by l.id, l.year, l.month
    order by l.year, l.month
    ``` 
1. Switch to the Hive editor and run the query above. Was it slower or faster?

1. Compare performance of the raw data to the query optimized data created in the step you ran earlier

1. Determine the rank order for yearly average high from 1988 on:
    ```
    select id, year, round(avg(element_data * 0.18 + 32),2) AVG_HIGH_TEMP_F, 
       rank() OVER (ORDER BY avg(element_data)) rank
    from weather.noaa_ghcn_daily_hdfs_pid_ym
    where ID = 'USW00014821'
        and year >= 1998
        and element = 'TMAX'
    group by id, year
    order by year
    ```
1. What year is the coolest?  The warmest?

## Where to go from here

[Using Hive with Hue](./Demo-Hive-HUE.md) \
[Using Spark with Jupyter](./Demo-Spark-Jupyter.md) \
[Using EMR to do ETL](Demo-EMR-as-ETL.md)  

## Finally

Once you are done with the demos, terminate your cluster to avoid additional charges. 

---
&copy; 2018 by [Jeff Anderson](https://jeff-anderson.com/). All rights reserved