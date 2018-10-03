# LAB: Deleting a Redshift Cluster

Unless you have purchased one [reserved instance](https://aws.amazon.com/redshift/pricing/#Reserved_Instance_Pricing)
for each node in your cluster, [on-demand charges](https://aws.amazon.com/redshift/pricing/#On-Demand_Pricing)
will continue to accrue while the cluster is running. This lab walks you through the process
of shutting down and deleting your cluster to avoid this expense.

## Prerequisites

1. You are logged in to the console and have set **Ohio** as the region
1. You [launched a cluster](Lab-LaunchRedchiftCluster.md) named **redshift-lab** and the "Cluster Status" is 
**available** and the "DB Health" is **healthy**


## Deleting Your Cluster

1. From the "Services" menu, choose **Redshift**
1. Choose **Cluster** from the left navigation
1. Click the box to the left of your cluster name
1. From the **Cluster** menu choose **Delete Cluster**
1. If you **do not** want to launch this cluster again:
    * Choose **No** for "Create snapshot"
    * Check the box to indicate you acknowledge that when youi delete this cluster, data changes since the most recent 
      manual snapshot (if any) will be lost.
1. If, at some point in the future, you **DO** want to launch a new cluster with the data and state from this cluster preserved:
    * Choose **Yes** for "Create snapshot"
    * Enter a meaningful snapshot name so you will be able to easily identify it later
    * **NOTE:** you will be charged standard [S3 storage rates](https://aws.amazon.com/s3/pricing/) for the data in your 
    snapshot until you delete it
1. Click **Delete**

## Money Saving Tip

S3 storage rates are way cheaper than on-demand Redshift cluster compute charges. For clusters
that you only need to run occasionally, is is generally less expensive to delete the cluster and create a snapshot when 
you are done using it then launch a new cluster from the snapshot when you need it again.

Example: A 4 node cluster, like the one we used for these labs, costs $1 per hour to run. If you 
only use it 10 hours a day, you can save $14 per day with this strategy.

While this stragegy works will for occasional use, price out reserved instances which may be
less expensive if your cluster needs to be running for a significant percentage of time over a one or three year
period.