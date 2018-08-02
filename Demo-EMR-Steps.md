# Submitting Steps to EMR

## Prerequisites:

* You completed [Launching an Elastic Map Reduce (EMR) Cluster](./Demo-EMR-Launch.md)
* Using the Amazon Console, [create an S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html) to store your steps
* Download the [prep-hdfs-data.sql](sql/prep-hdfs-data.sql) to your computer then upload it to the bucket you created in the previous step
* Your custer is in a "Waiting" state

## References:

[Submitting Work to a Cluster](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-overview.html#emr-work-cluster) \
[Apache Hive](http://hive.apache.org/) website \
[Hive Language Manual](https://cwiki.apache.org/confluence/display/Hive/LanguageManual) 


## Adding Steps to a running EMR cluster:

1. Choose EMR from the Services screen
1. From the EMR cluster dashboard click on the running cluster name
1. Click on the "Steps" tab
1. Click "Add Step"
1. Change "Step Type" to "Hive Program"
1. In the "Script S3 location", browse to the ``prep-hdfs-data.sql`` you uploaded earlier
1. Choose "Continue" for "Action on failure"
1. Click "Add"

This step will take 6-10 minutes to run. Once the job completes, there will be a new internal Hive table called 
"weather.noaa_ghcn_daily_hdfs_pid_ym"

## Where to go from here

[Using Presto with Hue](./Demo-EMR-Presto.md) \
[Using Hive with Hue](./Demo-Hive-HUE.md) \
[Using Spark with Jupyter](./Demo-Spark-Jupyter.md) \
[Using EMR to do ETL](Demo-EMR-as-ETL.md) 

## Finally

Once you are done with the demos, terminate your cluster to avoid additional charges. 
