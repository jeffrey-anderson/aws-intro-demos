# Analyzing and Optimizing Redshift Tables

## Prerequisites

1. You are logged in to the console and have set **Ohio** as the region
1. You completed the [Creating Sample Data For Redshift](Demo-RedshiftDataPrep.md) lab including loading the sample data 
to a bucket in S3
1. You [launched a cluster](Lab-LaunchRedchiftCluster.md) named **redshift-lab** and the "Cluster Status" is 
**available** and the "DB Health" is **healthy**

## Use the Connecting to The Database

### Option 1: Use the Redshift Query Editor

This is a great way to get started without having to install and configure a SQL query tool

1. Click **Launch Query Editor**
1. In the login dialog, choose **redshift-lab** for the cluster name, **lab** for the database, 
and **admin** for the database user
1. Enter the password you chose for the admin user when you created your cluster

### Option 2: Use a Standard Query Tool:

You can connect using a SQL query tool such as [DBeaver](https://dbeaver.io/download/) or 
[Aginity Workbench for Redshift](https://www.aginity.com/main/workbench-for-amazon-redshift/)
which you have installed on your computer

1. From the Amazon "Services" menu, choose **Redshift**
2. Choose **Clusters** from the left navigation
3. Click on the cluster name to bring up the the configuration screen
4. Scroll down and look at the cluster properties
5. Click on the JDBC or ODBC URL and copy it to your clipboard
6. Paste it into the connection properties dialog of your query tool

**NOTE:** Some tools don't allow pasting of the URL. You can click on the **Endpoint** above "Cluster properties"
and copy / paste it into the host name field. If you do this, delete **:5439** from the end of the pasted data

## Create And Load Non-Optimized Tables

## Get a Baseline of Query Performance

## Analyse Possible Improvements

## Implement Your Changes

## Quantify The Results


## Credits
Inspired by the Redshift [table design](https://docs.aws.amazon.com/redshift/latest/dg/tutorial-tuning-tables.html)
tutorial, using data and sample queries from the 
[TCP-H](http://www.tpc.org/tpch/) decision support benchmark, built using the 
[tpch-kit](https://github.com/gregrahn/tpch-kit) from 
[Greg Rahn](https://github.com/gregrahn).

## References

* [Amazon Redshift Best Practices](https://docs.aws.amazon.com/redshift/latest/dg/best-practices.html)
* [Amazon Redshift Engineering’s Advanced Table Design Playbook](https://aws.amazon.com/blogs/big-data/amazon-redshift-engineerings-advanced-table-design-playbook-preamble-prerequisites-and-prioritization/)
* [Top 10 Performance Tuning Techniques for Amazon Redshift](https://aws.amazon.com/blogs/big-data/top-10-performance-tuning-techniques-for-amazon-redshift/)


---
&copy; 2018 by [Jeff Anderson](https://jeff-anderson.com/). All rights reserved