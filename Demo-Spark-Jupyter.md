# Using Spark with Jupyter

## Prerequisites:

* You completed [Launching an Elastic Map Reduce (EMR) Cluster](./Demo-EMR-Launch.md)
* Your custer is in a "Waiting" state

## Launching JupyterHub

1. Choose EMR from the Services screen
1. From the EMR cluster dashboard click on the cluster name
1. From "Connections:" click on "JupyterHub"
1. If you get a warning your connection is not secure:
    1. Choose "Advanced" then "Add Exception"
    1. Uncheck "Permanently store this exception"
    1. Click, "Confirm Security Exception"
1. At the Jupyter Sign In screen, enter `jovyan` for the username and `jupyter` for the password.  
See [this link](https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-jupyterhub-user-access.html) for more
1. Click "Sign In"

## Create a new notebook

**NOTES:** 
1. Code blocks that have not been executed will have `In [ ]:` in the left column
1. After entering each code block, press "Enter" while holding down the "Shift" key to run the code
1. Code blocks that are running will have `In [*]:` in the left column
1. Once execution completes the asterisk will be replaced by a statement number indicating the order of execution
1. If you want to save some typing, upload and run [this](./weather-demo.ipynb) Jupyter notebook.

### Lab

1. From the "New" dropdown on the actions bar, choose "PySpark 3" 
1. Create a Spark application named "weather": 
    ```
    from pyspark.sql import SparkSession
    spark = SparkSession.builder.appName('weather').getOrCreate()
    ```
1. Create a data frame called "df" from the [ghcnd-stations.txt](https://docs.opendata.aws/noaa-ghcn-pds/readme.html) file 
in S3:
   ```
   df = spark.read.text("s3://noaa-ghcn-pds/ghcnd-stations.txt")
   ```
1. Create a dataframe called "stations" by splitting the fixed width data stored in the `df` dataframe into individual
columns, trimming whitespace, specifying the proper type, and providing a column name for each: 
    ```
    from pyspark.sql.functions import trim

    stations = df.select(
        df.value.substr(1,11).alias('ID'),
        df.value.substr(13,8).cast('double').alias('LATITUDE'),
        df.value.substr(22,9).cast('double').alias('LONGITUDE'),
        df.value.substr(32,6).cast('double').alias('ELEVATION'),
        trim(df.value.substr(39,2)).alias('STATE'),
        trim(df.value.substr(42,30)).alias('NAME'),
        trim(df.value.substr(73,3)).alias('GSN_FLAG'),
        trim(df.value.substr(77,3)).alias('NETWORK_FLAG'),
        trim(df.value.substr(81,5)).alias('WMO_ID')
    )
    ```
1. Instruct Spark to cache the `stations` dataframe into memory for faster performance:
    ```
    stations.cache()
    ```
1. Show the first 20 columns of the `stations` dataframe:
    ```
    stations.show()
    ```
1. Create and show a transient dataframe filtered so the name contains "COLUMBUS" and the state is OH:
    ```
    stations.filter(("NAME like '%COLUMBUS%' AND STATE = 'OH'")).show()
    ```
1. Further refine the results so only the "PORT COLUMBUS" row is shown:
    ```
    stations.filter(("NAME like '%PORT COLUMBUS%' AND STATE = 'OH'")).show()
    ```
1. Create a schema for the daily weather observation data and apply it while reading the 2018 file into a new dataframe called `df2`
    ```
    from pyspark.sql.types import *
    
    schema = StructType([
        StructField("ID", StringType(), False),
        StructField("OBS_DATE", DateType(), False),
        StructField("ELEMENT", StringType(), False),
        StructField("DATA_VALUE", IntegerType(), True),
        StructField("M_FLAG", StringType(), True),
        StructField("Q_FLAG", StringType(), True),
        StructField("S_FLAG", StringType(), True),
        StructField("OBS_TIME", StringType(), True)])
    df2 = spark.read.csv("s3://noaa-ghcn-pds/csv.gz/2018.csv.gz",schema,dateFormat='yyyyMMdd')
    ```
    *Note:* If you want to explore the full set of weather data, substitute `"s3://noaa-ghcn-pds/csv.gz/"` for the 
    location but be aware the history is large so operations may take several minutes to complete.
    
1.  Tell Spark to cache the results in memory:
    ```
    df2.cache()
    ```
1.  Show the results (*this may take a few minutes*):
    ```
    df2.show()
    ```
1.  Create a data frame called `port_cmh_df` which only has data for the month of July from the Port Columbus station`:
    ```
    port_cmh_df = df2.filter(("ID = 'USW00014821' and MONTH(OBS_DATE) = 7"))
    ```
1.  Cache the results:
    ```
    port_cmh_df.cache()
    ```
1.  Show the results:
    ```
    port_cmh_df.show()
    ```
1.  Create a new data frame called `cmh_min_temps` with two additional columns for celsius and fahrenheit low
temperatures calculated from the DATA_VALUE from rows with an element of 'TMIN':
    ```
    from pyspark.sql.functions import format_number
    
    cmh_min_temps = (port_cmh_df.filter("ELEMENT = 'TMIN'")
       .withColumn('LOW_TEMP_C', port_cmh_df.DATA_VALUE / 10)
       .withColumn('LOW_TEMP_F', format_number(port_cmh_df.DATA_VALUE * .18 + 32,1)))
    ```
1.  Show the new columns:
    ```
    cmh_min_temps.select('OBS_DATE', 'LOW_TEMP_C', 'LOW_TEMP_F').show()
    ```
1.  Create a `cmh_max_temps` dataframe derived the same way for rows with an element of 'TMAX':
    ```
    cmh_max_temps = (port_cmh_df.filter("ELEMENT = 'TMAX'")
       .withColumn('HIGH_TEMP_C', port_cmh_df.DATA_VALUE / 10)
       .withColumn('HIGH_TEMP_F', format_number(port_cmh_df.DATA_VALUE * .18 + 32,1)))
    ```
1.  Show the new columns:
    ```
    cmh_max_temps.select('OBS_DATE', 'HIGH_TEMP_C', 'HIGH_TEMP_F').show()
    ```
1.  Create a new dataframe called `cmh_2018_07_temps` by joining the min and max temperature dataframes created above:
    ```
    cmh_2018_07_temps = (cmh_min_temps.select('OBS_DATE', 'LOW_TEMP_C', 'LOW_TEMP_F')
       .join(cmh_max_temps.select('OBS_DATE', 'HIGH_TEMP_C', 'HIGH_TEMP_F'), 'OBS_DATE'))
    ```
1.  Show the joined dataframe:
    ```
    cmh_2018_07_temps.show(
    ```
1.  Save the dataframe to a CSV file in S3:
    ```
    cmh_2018_07_temps.write.format("com.databricks.spark.csv").option("header", "true")
       .save("s3://YOUR-BUCKET-NAME-HERE/cmh-temps-csv")
    ```
    
## References:

*   [Apache Spark Documentation](http://spark.apache.org/)
*   [Spark Python API Documentation](http://spark.apache.org/docs/latest/api/python/index.html)
*   [AWS JupyterHub Documentation](https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-jupyterhub.html)


## Where to go from here:

*   Using HIVE with HUE