# LAB: Loading Tables in Redshift

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

### Get a Baseline

1. Drop the Orders table if it exists:
    ```redshift
    DROP TABLE IF EXISTS orders;
    ```  
1. Create a table for testing:
    ```redshift
    CREATE TABLE orders
    (
        o_orderkey BIGINT NOT NULL DISTKEY,
        o_custkey BIGINT NOT NULL,
        o_orderstatus VARCHAR(1) NOT NULL,
        o_totalprice NUMERIC(12, 2) NOT NULL,
        o_orderdate DATE NOT NULL SORTKEY,
        o_orderpriority VARCHAR(15) NOT NULL,
        o_clerk VARCHAR(15) NOT NULL,
        o_shippriority INTEGER NOT NULL,
        o_comment VARCHAR(79),
        PRIMARY KEY (o_orderkey)
    );
    ```
1. Load the table from the uncompressed single \
    **NOTE:** Replace **YOUR-BUCKET-NAME-HERE** with the bucket you created in the
    [Creating Sample Data For Redshift](Demo-RedshiftDataPrep.md) lab
    ```redshift
    copy orders from 's3://YOUR-BUCKET-NAME-HERE/raw/orders.tbl' 
    credentials 'aws_iam_role=arn:aws:iam::031849459082:role/redshift-S3-ro-access' 
    COMPUPDATE OFF delimiter '|';
    ```
1. Note how long it took to load the table:
   1. Open [this spreadsheet](documents/Redshift/RedshiftPerformanceAnalysis.xlsx)
   1. From the "Query results", record the number of seconds it took to run in the spreadsheet under **Load uncompressed 
   single file** in the **Redshift Table Loading Lab** section

### Loading From a Compressed Single File

1. Drop the Orders table:
    ```redshift
    DROP TABLE IF EXISTS orders;
    ```  
1. Recreate the table:
    ```redshift
    CREATE TABLE orders
    (
        o_orderkey BIGINT NOT NULL DISTKEY,
        o_custkey BIGINT NOT NULL,
        o_orderstatus VARCHAR(1) NOT NULL,
        o_totalprice NUMERIC(12, 2) NOT NULL,
        o_orderdate DATE NOT NULL SORTKEY,
        o_orderpriority VARCHAR(15) NOT NULL,
        o_clerk VARCHAR(15) NOT NULL,
        o_shippriority INTEGER NOT NULL,
        o_comment VARCHAR(79),
        PRIMARY KEY (o_orderkey)
    );
    ```
1. Load the table using the compressed single file \
    **NOTE:** Replace **YOUR-BUCKET-NAME-HERE** with the bucket you created in the
    [Creating Sample Data For Redshift](Demo-RedshiftDataPrep.md) lab
    ```redshift
    copy orders from 's3://YOUR-BUCKET-NAME-HERE/single-files/orders.tbl.gz' 
    credentials 'aws_iam_role=arn:aws:iam::031849459082:role/redshift-S3-ro-access' 
    COMPUPDATE OFF gzip delimiter '|';
    ```
1. From the "Query results", record the number of seconds it took to run in the spreadsheet under **Load compressed 
   single file** in the **Redshift Table Loading Lab** section

### Time Load From Multiple Files

1. Drop the Orders table:
    ```redshift
    DROP TABLE IF EXISTS orders;
    ```  
1. Recreate the table:
    ```redshift
    CREATE TABLE orders
    (
        o_orderkey BIGINT NOT NULL DISTKEY,
        o_custkey BIGINT NOT NULL,
        o_orderstatus VARCHAR(1) NOT NULL,
        o_totalprice NUMERIC(12, 2) NOT NULL,
        o_orderdate DATE NOT NULL SORTKEY,
        o_orderpriority VARCHAR(15) NOT NULL,
        o_clerk VARCHAR(15) NOT NULL,
        o_shippriority INTEGER NOT NULL,
        o_comment VARCHAR(79),
        PRIMARY KEY (o_orderkey)
    );
    ```
1. Create a [manifest file](https://docs.aws.amazon.com/redshift/latest/dg/loading-data-files-using-manifest.html)
to use with the COPY command:
    1. Create a new file called **orders-manifest**
    1. Open the file in a text editor
    1. Copy the statements below into the file:
        ```
        {
          "entries": [
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-00.tbl.gz", "mandatory":true},
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-01.tbl.gz", "mandatory":true},
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-02.tbl.gz", "mandatory":true},
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-03.tbl.gz", "mandatory":true},
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-04.tbl.gz", "mandatory":true},
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-05.tbl.gz", "mandatory":true},
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-06.tbl.gz", "mandatory":true},
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-07.tbl.gz", "mandatory":true},
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-08.tbl.gz", "mandatory":true},
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-09.tbl.gz", "mandatory":true},
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-10.tbl.gz", "mandatory":true},
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-11.tbl.gz", "mandatory":true},
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-12.tbl.gz", "mandatory":true},
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-13.tbl.gz", "mandatory":true},
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-14.tbl.gz", "mandatory":true},
            {"url":"s3://YOUR-BUCKET-NAME-HERE/multiple-files/orders-15.tbl.gz", "mandatory":true}
          ]
        }
        ```
    1. Do a global search and replace **YOUR-BUCKET-NAME-HERE** with the bucket you created in the
       [Creating Sample Data For Redshift](Demo-RedshiftDataPrep.md) lab
    1. Look at the **multiple-files** folder in your bucket and verify the order table has all
    of the files referenced in the new manifest file and adjust if necessary
    1. Upload the manifest file to the **multiple-files** folder in your bucket
    
1. Load the table from multiple files using the manifest file you created above \
    **NOTE:** Replace **YOUR-BUCKET-NAME-HERE** with the bucket you created in the
    [Creating Sample Data For Redshift](Demo-RedshiftDataPrep.md) lab
    ```redshift
    copy orders from 's3://YOUR-BUCKET-NAME-HERE/multiple-files/orders.manifest' 
    credentials 'aws_iam_role=arn:aws:iam::031849459082:role/redshift-S3-ro-access' 
    COMPUPDATE OFF gzip delimiter '|' manifest;
    ```
1. From the "Query results", record the number of seconds it took to run in the spreadsheet under **Load compressed 
   single file** in the **Redshift Table Loading Lab** section

## Analysis

1. Did compressing the file have a noticeable impact on load time?
   <details>
     <summary>Answer</summary>
     <p>No. The load times are virtually identical</p>
   </details>

1. Did using multiple compressed files have a noticeable impact on load time?
   <details>
     <summary>Answer</summary>
     <p>Yes. Using multiple compressed files loaded the data in about one third of the time</p>
   </details>

1. What benefit is there to compressing the files?
   <details>
     <summary>Answer</summary>
     <ul>
       <li>Compressing the files saves space in S3 which reduces storage expense</li>
       <li>While compressing smaller single files doesn't noticeably impact load times, it does for much larger files</li> 
   </details>

## Continue with the Labs

1. [Analyzing and Tuning Tables](Demo-RedshiftTableAnalysis.md)

## IMPORTANT - Don't Forget

[Delete the cluster](Lab-DeletingRedshiftCluster.md) as soon as you are done with the labs to stop the charges


---
&copy; 2018 by [Jeff Anderson](https://jeff-anderson.com/). All rights reserved


