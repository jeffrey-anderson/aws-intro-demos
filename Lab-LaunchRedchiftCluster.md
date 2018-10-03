# LAB: Launching a Redshift Cluster

## IMPORTANT:

Unless you are eligible for the [Amazon Redshift free trial](https://aws.amazon.com/redshift/free-trial/):
* **You will start accruing charges as soon as your cluster is active.** The on-demand hourly rate for this cluster will be 
**$1.00 per hour**, or $0.25 /node.
* [Delete the cluster](Lab-DeletingRedshiftCluster.md) as soon as you are done with the labs to stop the charges
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

## Launch a New Cluster

1. Choose **Redshift** from the AWS Console "Services" menu
1. Click **Launch cluster** from the Redshift Dashboard (NOT "Quick launch")
1. Enter ``redshift-lab`` as the "Cluster identifier"
1. Enter ``lab`` for the "Database name"
1. Enter ``admin`` for the "Master user name"
1. Enter a password you will remember for the master user password
1. Click **Continue**
1. Leave the node type as **dc2.large**
1. Change the "Cluster type" to **Multi Node**
1. Enter **4** for the "Number of compute nodes"
1. Click **Continue**
1. Under "VPC security groups", choose **redshift-access-from-my-ip**
1. Under "Available IAM roles", choose **redshift-S3-ro-access**
1. Click **Continue**
1. From the review screen, *note the "Applicable charges"* and click **Launch cluster**
1. Click **View all clusters** 

## Wait for Your Cluster To Become Available

It typically takes around 10 minutes for the cluster to fully come up. Your cluster is ready to use when
the "Cluster Status" is **available** and the "DB Health" is **healthy**

## Continue with the Labs

1. [Loading Tables](Lab-RedshiftTableLoading.md)
1. [Analyzing and Tuning Tables](Demo-RedshiftTableAnalysis.md)

## IMPORTANT - Don't Forget

[Delete the cluster](Lab-DeletingRedshiftCluster.md) as soon as you are done with the labs to stop the charges




---
&copy; 2018 by [Jeff Anderson](https://jeff-anderson.com/). All rights reserved
