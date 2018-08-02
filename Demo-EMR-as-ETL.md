# Using EMR to do ETL

## References:

[Submitting Work to a Cluster](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-overview.html#emr-work-cluster) 

## Prerequisites:

1. Using the Amazon Console, [create an S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html) to store your data
1. Download [WeatherRawToPartitionedORC.sql](sql/WeatherRawToPartitionedORC.sql) to your computer
1. Open the file in a text editor
1. Substituting the bucket name from the step above for "YOUR-BUCKET-NAME-HERE" in the SQL
1. Upload the file to the S3 bucket you created above
1. Using the AWS Glue Catalog, confirm you don't have a database called "weather".  Optionally, stop if you do, or delete it and 
all of it's tables if you ran this earlier.

## Launch a "Run and Done" Cluster

1. Choose EMR from the Services screen
1. Click "Create Cluster"
1. Click "Go to advanced options"
1. Uncheck everythng except "Hadoop" and "Hive"
1. Check "Use for Hive table metadata"
1. Under "Add Steps", choose "Hive Program" for the "Step Type" then click, "Configure"
1. In the "Script S3 location", browse to the ``WeatherRawToPartitionedORC.sql`` you uploaded earlier
1. Choose "Terminate cluster" for "Action on failure"
1. Click "Add"
1. Check "Auto-terminate cluster after the last step is completed"
1. Click "Next"
1. Change the "Purchasing option" for the Master node to "Spot" leaving the default max price
1. Either do the same for the Core nodes or change the instance count to 0
1. Click "Next"
1. Enter "My ETL Cluster" as the "Cluster name"
1. Uncheck "Termination protection"
1. Click "Next"
1. Uncheck "Cluster visible to all IAM users in account"
1. Click "Create cluster"

## Monitoring the progress:

* From the Cluster Summary screen, click on the "Steps" tab
* All steps should be in a "Pending" status while the cluster is starting
* Once the cluster is running, the steps will move to a "Running" status

## Check the output:

* The Hive program step will take 10 - 15 minutes to run
* Once the job completes, go back to the Glue catalog. There should now be a "weather" database with two tables  
* Using Athena, view the data in each table

## Where to go from here

[Submitting Steps to EMR](Demo-EMR-Steps.md) \
[Using Presto with Hue](./Demo-EMR-Presto.md) \
[Using Hive with Hue](./Demo-Hive-HUE.md) \
[Using Spark with Jupyter](./Demo-Spark-Jupyter.md) \

## Finally

Once you are done with the demos, terminate your cluster to avoid additional charges. 


