# Analyzing and Optimizing Redshift Tables

Inspired by the Redshift [table design](https://docs.aws.amazon.com/redshift/latest/dg/tutorial-tuning-tables.html)
and [table loading](https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-loading-take-loading-data-tutorial.html)
tutorials, using data and sample queries from the 
[TCP-H](http://www.tpc.org/tpch/) decision support benchmark, built using the 
[tpch-kit](https://github.com/gregrahn/tpch-kit) from 
[Greg Rahn](https://github.com/gregrahn).

## IMPORTANT:

Unless you are eligible for the [Amazon Redshift free trial](https://aws.amazon.com/redshift/free-trial/):
* **You will start accruing charges as soon as your cluster is active.** The on-demand hourly rate for this cluster will be 
**$1.00 per hour**, or $0.25 /node.
* Delete the cluster as soon as you are done with the labs to stop the charges
* **Tip:** To pause the cluster compute charges without loosing your work, delete the cluster, creating a final snapshot
which saves the custer data and state. Later, when you are ready to pick up where you left off, launch a new cluster 
from the snapshot. 
* Backups stored after your cluster is terminated are billed at standard [Amazon S3 rates](https://aws.amazon.com/s3/pricing/) 
so, to reduce ongoing expenses, remember to delete them once they are no longer needed


## Prerequisites

1. You are logged in to the console and have set **Ohio** as the region
1. You completed the [Creating Sample Data For Redshift](Demo-RedshiftDataPrep.md) lab including loading the sample data 
to a bucket in S3
1. You have a SQL Query tool such as [DBeaver](https://dbeaver.io/download/) installed on your machine
1. You [created an IAM role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-service.html#roles-creatingrole-service-console)
named "redshift-S3-ro-access" for the AWS *Redshift* service, *Redshift-customizable* use case, attaching the *AmazonS3ReadOnlyAccess* policy 
1. You created an [EC2 security group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) 
in your default VPC named "redshift-access-from-my-ip" which has the following inbound rules:

| Type | Protocol | Port Range | Source |
|:---:|:--------:|:----------:|:------:|
| Redshift | TCP | 5439 | My IP | 


## References

* [Amazon Redshift Best Practices](https://docs.aws.amazon.com/redshift/latest/dg/best-practices.html)
* [Amazon Redshift Engineering’s Advanced Table Design Playbook](https://aws.amazon.com/blogs/big-data/amazon-redshift-engineerings-advanced-table-design-playbook-preamble-prerequisites-and-prioritization/)
* [Top 10 Performance Tuning Techniques for Amazon Redshift](https://aws.amazon.com/blogs/big-data/top-10-performance-tuning-techniques-for-amazon-redshift/)

## Launch a New Cluster

1. Choose Redshift from the AWS Console "Services" menu
1. Click "Launch cluster" from the Redshift Dashboard
1. Enter "redshift-lab" as the "Cluster identifier"
1. Enter "lab" for the "Database name"
1. Enter "admin" for the "Master user name"
1. Enter a password you will remember, such as "H0ppyIPA", for the master user password
1. Click "Continue"
1. Leave the node type as "dc2.large"
1. Change the "Cluster type" to "Multi Node"
1. Enter "4" for the "Number of compute nodes"
1. Click "Continue"
1. Under "VPC security groups", choose "redshift-access-from-my-ip"
1. Under "Available IAM roles", choose "redshift-S3-ro-access"
1. From the review screen, click "Launch cluster"

## Create the tables and load the data

1. Using SQL from [this file](sql/redshift/redhift-create-tables-1.sql)


## 



---
&copy; 2018 by [Jeff Anderson](https://jeff-anderson.com/). All rights reserved