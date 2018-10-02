# Creating Sample Data For Redshift

## Notes:

* Because this task is CPU and storage intensive, we will be using an instance type that is not eligible for the
EC2 [free tier](https://aws.amazon.com/free/) 
* We will use a spot request to save money but the worst case is you will spend around $.20 per hour while your instance 
is running
* See the [EC2 on demand price sheet](https://aws.amazon.com/ec2/pricing/on-demand/) for current on demand instance prices
* This activity will take around **two hours** to complete 
* **IMPORTANT:** Make sure to terminate your instance once you have created the sample data
* Finally, until you delete the sample data from S3, there will be an ongoing storage charge for 16G of data
which will cost around 37 cents per month. To avoid this charge, delete the sample data from S3 once you are done with
the lab.
    
## Prerequisites

1. You are logged in to the console and have set **Ohio** as the region
1. You created a [SSH key-pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) called 
"ohio-ec2-key" in the **Ohio region** and saved it as instructed on your current computer
1. You [created an S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html) with a unique 
name of your choosing in the **Ohio region** 
to store your sample data
1. You [created an IAM role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-service.html#roles-creatingrole-service-console)
named "S3-full-access" for the *AWS EC2 service* attaching the *AmazonS3FullAccess* policy 
1. You created an [EC2 security group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) named 
"ssh-access-from-my-ip" which has the following inbound rules:

| Type | Protocol | Port Range | Source |
|:---:|:--------:|:----------:|:------:|
| Custom TCP Rule | TCP | 22 | My IP | 

## Launch an EC2 Instance to Create the Data

1. From the AWS Console, choose "EC2" from the "Services" menu
1. From the EC2 dashboard, choose "Launch Instance"
1. Select the "Amazon Linux 2 AMI (HVM), SSD Volume Type" Amazon Machine Image (AMI)
1. Because this task is CPU and storage intensive, choose compute optimized "c5d.xlarge" as the instance type
1. Click "Next: Configure Instance Details"
1. Under "Purchasing Option" check "Request Spot instances"
1. Enter "0.192" in the "Maximum price" field. **NOTE:** since this is the full on-demand rate, bidding the full price 
substantially reduces the likelihood your instance will will be terminated because Amazon needs the capacity back to 
meet current demand. The actual charge you pay will be close to what appears in the "Current Price" table.
See [Amazon EC2 Spot Instances Pricing](https://aws.amazon.com/ec2/spot/pricing/) for more details.
1. In the "Subnet" field, choose a subnet that corresponds with the availability zone having the lowest current spot
prices (or leave the default if every availability zone has an identical current price)
1. Choose "Enable" in the "Auto-assign Public IP" field
1. In the "IAM role" field, choose "S3-full-access"
1. Click "Next: Add Storage"
1. Keeping the settings presented, click "Next: Add Tags"
1. Optionally, click "Add Tag" and enter "Name" for the "Key" and "redshift-data-prep" for the "Value"
1. Click "Next: Configure Security Group"
1. Choose "Select an existing security group" then choose "ssh-access-from-my-ip"
1. Click "Review and Launch"
1. Click "Launch"
1. In the "Select an existing keypair or create a new keypair" dialog, choose "Choose a existing keypair", select the
"ohio-ec2-key", check to acknowledge you have access to the keypair then press "Request Spot Instances"
1. Click "View Spot Requests" to continue

## Connect to Your Instance

1. Once your spot request has a status of "fulfilled", click on "Instances" in the left navigation pane
1. Once your instance has a "Instance State" of "running" and there is a green check in the "Status Checks" column,
[connect to your EC2 instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html)
using the ohio-ec2-key and public DNS address. For example:
```
ssh -i ~/.ssh/ohio-ec2-key.pem ec2-user@ec2-XX-XXX-XXX-XXX.us-east-2.compute.amazonaws.com
```
## Create a Filesystem for your Data

The instance type we chose has 100 gigs of high performance ephemeral storage which is not automatically prepared when the instance is
launched. This procedure will make that storage available.

1. Next, enter ``sudo fdisk -l`` to view the list of available disks
1. Note the device name, such as "/dev/nvme1n1" which has a size of 93.1 GiB
1. Format the disk using the mke2fs command: ``sudo mke2fs /dev/nvme1n1`` substituting your device name if different
1. Mount the disk under /var/tmp: ``sudo mount /dev/nvme1n1 /var/tmp``
1. Run ``df -h`` to verify the space is available which should produce output like this:
    ``` 
    Filesystem      Size  Used Avail Use% Mounted on
    devtmpfs        3.8G     0  3.8G   0% /dev
    tmpfs           3.8G     0  3.8G   0% /dev/shm
    tmpfs           3.8G  284K  3.8G   1% /run
    tmpfs           3.8G     0  3.8G   0% /sys/fs/cgroup
    /dev/nvme0n1p1  8.0G  1.2G  6.9G  14% /
    tmpfs           763M     0  763M   0% /run/user/1000
    /dev/nvme1n1     92G   60M   87G   1% /var/tmp
    ```
    Note the last entry is a 92G filesystem mounted on /var/tmp
1. Create a data directory under /var/tmp: ``sudo mkdir /var/tmp/redshift-data``
1. Change the ownership of the directory so the ec2-user has full access: ``sudo chown ec2-user.ec2-user /var/tmp/redshift-data``

## Create the test data

1. Install git, make and gcc: ``sudo yum install -y git make gcc``
1. Clone the [tcph-kit](https://github.com/gregrahn/tpch-kit) source code: ``git clone https://github.com/gregrahn/tpch-kit.git``
1. Create a directory for the data files: ``mkdir /var/tmp/redshift-data/single-files``
1. Change to the source directory: ``cd tpch-kit/dbgen``
1. Set environment variables used for generating data and queries: 
```
export DSS_CONFIG=/home/ec2-user/tpch-kit/dbgen
export DSS_QUERY=$DSS_CONFIG/queries
export DSS_PATH=/var/tmp/redshift-data/single-files
```
1. Prepare the source to compile: ``make MACHINE=LINUX DATABASE=POSTGRESQL``
1. Create the test data with a scale factor of 25: ``./dbgen -s 25`` \
**NOTE: this command will take about 10 minutes to complete**

## Create sample queries

1. Create a directory for the sample queries: ``mkdir /var/tmp/redshift-data/queries``
1. Generate each of the 22 TCPH benchmark queries:
```
for ((i=1;i<=22;i++)); do
  ./qgen -v -c -s 25 ${i} > /var/tmp/redshift-data/queries/tpch-q${i}.sql
done
```

## Split the sample data into 8 files for parallel loading

Since we will be using a cluster with 4 machines that each have 2 slices, we will 
follow the Redshift best practice to [split the larger files](https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-use-multiple-files.html)
into 8 smaller files:

1. Change to the data output directory: ``cd /var/tmp/redshift-data/single-files``

1. Run the following commands to split the files:
    ```
    split -l 468750 -d customer.tbl customer- --additional-suffix=.tbl
    split -l 6249850 --numeric-suffixes=0 lineitem.tbl lineitem- --additional-suffix=.tbl
    split -l 2343750 --numeric-suffixes=0 orders.tbl orders- --additional-suffix=.tbl
    split -l 2500000 -d partsupp.tbl partsupp- --additional-suffix=.tbl
    split -l 625000 -d part.tbl part- --additional-suffix=.tbl
    split -l 31250 -d supplier.tbl supplier- --additional-suffix=.tbl
    ```
    **NOTE: these commands will take about 7 minutes total to complete**
1. Create a directory for the split files: ``mkdir ../multiple-files``
1. Move the split files to the multi file directory: ``mv *-0?.tbl ../multiple-files``
1. Put a copy of the two smaller files in the multi file directory: ``cp nation.tbl region.tbl ../multiple-files``

## Compress the data to save space and improve table load times

Another Redshift best practice is to [compress the data files](https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-compress-data-files.html).
This procedure will compress the data using gzip compression. **NOTE: Each directory will take around 25-30 minutes to compress**

1. Change to the multiple-files directory: ``/var/tmp/redshift-data/multiple-files``
1. Gzip the files: ``gzip *``
1. Change to the single files directory: ``cd /var/tmp/redshift-data/single-files``
1. Gzip the files: ``gzip *``

## Copy the files to your S3 bucket

1. Change to the parent directory: ``cd /var/tmp/redshift-data``
1. Use the aws s3 sync command to copy the data to the S3 bucket you created for the lab:
``aws s3 sync . s3://redshift-lab-sample-data`` *replacing **redshift-lab-sample-data** with the bucket name you created* 

## IMPORTANT: Shut down your instance

You will continue to accrue charges until you shut down your instance. Now that we have created the sample
data and uploaded to to S3, we are done and no longer need this instance.

1. From the AWS Console "Services" menu, choose EC2
1. In the left navigation, choose "Spot Requests"
1. Check the box next to your fulfilled spot request
1. From the "Actions" menu, choose "Cancel Spot Request"
1. Leaving "Terminate instances" checked, click "Confirm" in the "Cancel Spot request" dialog
1. Once the state changes to "cancelled", choose "Instances" in the left navigation and verify your instance is in a 
"shutting down" or "terminated" state


