# Creating Sample Data For Redshift

## Notes:

* Because this task is CPU and storage intensive, we will be using an instance type that is not eligible for the
EC2 [free tier](https://aws.amazon.com/free/) 
* We will use a spot request to save money but, at worst case, you will spend around 39 cents per hour while your instance 
is running
* See the [EC2 on demand price sheet](https://aws.amazon.com/ec2/pricing/on-demand/) for current on demand instance prices
* This activity will take around **90 minutes** to complete 
* **IMPORTANT:** Make sure to terminate your instance once you have created the sample data to avoid ongoing charges
* Finally, until you delete the sample data from S3, there will be an ongoing storage charge for 42G of data
which will cost around $1 per month. To avoid this charge, delete the sample data from S3 once you are done with
the lab.
    
## Prerequisites

1. You are logged in to the console and have set **Ohio** as the region
1. You created a [SSH key-pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) called 
"ohio-ec2-key" in the **Ohio region** and saved it as instructed on your current computer
1. You [created an S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html) with a unique 
name of your choosing in the **Ohio region** 
to store your sample data
1. You [created an IAM role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-service.html#roles-creatingrole-service-console)
named "EC2-S3-full-access" for the *AWS EC2 service* attaching the *AmazonS3FullAccess* policy 
1. You created an [EC2 security group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) named 
"ssh-access-from-my-ip" which has the following inbound rules:

| Type | Protocol | Port Range | Source |
|:---:|:--------:|:----------:|:------:|
| Custom TCP Rule | TCP | 22 | My IP | 

## Launch an EC2 Instance to Create the Data

1. From the AWS Console, choose "EC2" from the "Services" menu
1. From the EC2 dashboard, choose "Launch Instance"
1. Select the "Amazon Linux 2 AMI (HVM), SSD Volume Type" Amazon Machine Image (AMI)
1. Because this task is CPU and storage intensive, choose compute optimized "c5d.2xlarge" as the instance type
1. Click "Next: Configure Instance Details"
1. Under "Purchasing Option" check "Request Spot instances"
1. Enter "0.384" in the "Maximum price" field. **NOTE:** since this is the full on-demand rate, bidding the full price 
substantially reduces the likelihood your instance will will be terminated because Amazon needs the capacity back to 
meet current demand. The actual charge you pay will be close to what appears in the "Current Price" table.
See [Amazon EC2 Spot Instances Pricing](https://aws.amazon.com/ec2/spot/pricing/) for more details.
1. In the "Subnet" field, choose a subnet that corresponds with the availability zone having the lowest current spot
prices (or leave the default if every availability zone has an identical current price)
1. Choose "Enable" in the "Auto-assign Public IP" field
1. In the "IAM role" field, choose "EC2-S3-full-access"
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

The instance type we chose has 200 gigs of high performance ephemeral storage which is not automatically prepared when the instance is
launched. This procedure will make that storage available.

1. Next, enter ``sudo fdisk -l`` to view the list of available disks
1. Note the device name, such as "/dev/nvme1n1" which has a size of 186.3 GiB
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
    /dev/nvme1n1    184G   60M  174G   1% /var/tmp
    ```
    Note the last entry is a 184G filesystem mounted on /var/tmp
1. Create a data directory under /var/tmp: ``sudo mkdir /var/tmp/redshift-data``
1. Change the ownership of the directory so the ec2-user has full access: ``sudo chown ec2-user.ec2-user /var/tmp/redshift-data``

## Create the test data

1. Install git, make and gcc: ``sudo yum install -y git make gcc``
1. Clone the [tcph-kit](https://github.com/gregrahn/tpch-kit) source code: ``git clone https://github.com/gregrahn/tpch-kit.git``
1. Create a directory for the data files: ``mkdir /var/tmp/redshift-data/psv``
1. Change to the source directory: ``cd tpch-kit/dbgen``
1. Set environment variables used for generating data and queries: 
```
export DSS_CONFIG=/home/ec2-user/tpch-kit/dbgen
export DSS_QUERY=$DSS_CONFIG/queries
export DSS_PATH=/var/tmp/redshift-data/psv
```
1. Prepare and compile the source code: ``make MACHINE=LINUX DATABASE=POSTGRESQL``
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
**Note:** This creates queries for PostgreSQL. Most, but not all, run unmodified in Redshift 

## Create directories for compressed and compressed and split versions of the files
1. Create a directory for the compressed data files: ``mkdir /var/tmp/redshift-data/psv-gz``
1. Create a directory for the compressed split data files: ``mkdir /var/tmp/redshift-data/m-psv-gz``
 
## Split the sample data into multiple files for parallel loading

Since we will be using a cluster with 4 machines that each have 2 slices, we will 
follow the Redshift best practice to [split the larger files](https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-use-multiple-files.html)
into smaller files. The ``-l`` parameter in the commands below is computed by counting the number of lines in the file with ``wc -l <filename>`` then dividing the
line count by a multiple of the number of slices in the cluster (eight in our case). Since the line item and
orders tables are so big, they are split into more files to improve data load concurrency.

1. Change to the compressed individual files directory: ``cd /var/tmp/redshift-data/psv-gz``
1. Copy the uncompressed files into the current directory: ``cp /var/tmp/redshift-data/psv/*.tbl .``
1. Select all of the following commands, copy them to your clipboard and paste them into your terminal window to split the files:
    ```
    split -l 468750 --numeric-suffixes=0 customer.tbl customer- --additional-suffix=.tbl &
    split -l 6249850 --numeric-suffixes=0 lineitem.tbl lineitem- --additional-suffix=.tbl &
    split -l 2343750 --numeric-suffixes=0 orders.tbl orders- --additional-suffix=.tbl &
    split -l 2500000 --numeric-suffixes=0 partsupp.tbl partsupp- --additional-suffix=.tbl &
    split -l 625000 --numeric-suffixes=0 part.tbl part- --additional-suffix=.tbl &
    split -l 31250 --numeric-suffixes=0 supplier.tbl supplier- --additional-suffix=.tbl &
    
    for job in `jobs -p`
    do
        wait $job
    done
    
    ```
    **NOTE: This will take 2-3 minutes to complete**

## Compress the data to save space and improve table load times

Another Redshift best practice is to [compress the data files](https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-compress-data-files.html).
This procedure will compress the data using gzip compression.

1. Select all of the following commands, copy them to your clipboard and paste them into your terminal window to compress the files:
    ```
    gzip lineitem.tbl &
    gzip nation.tbl region.tbl customer.tbl orders.tbl part.tbl partsupp.tbl supplier.tbl &
    gzip lineitem-00.tbl lineitem-01.tbl lineitem-02.tbl lineitem-03.tbl orders-00.tbl orders-01.tbl orders-02.tbl partsupp-00.tbl partsupp-01.tbl customer-06.tbl &
    gzip lineitem-04.tbl lineitem-05.tbl lineitem-06.tbl lineitem-07.tbl orders-03.tbl orders-04.tbl orders-05.tbl partsupp-02.tbl partsupp-03.tbl customer-07.tbl &
    gzip lineitem-08.tbl lineitem-09.tbl lineitem-10.tbl lineitem-11.tbl orders-06.tbl orders-07.tbl orders-08.tbl partsupp-04.tbl partsupp-05.tbl part-05.tbl part-06.tbl part-07.tbl &
    gzip lineitem-12.tbl lineitem-13.tbl lineitem-14.tbl lineitem-15.tbl orders-09.tbl orders-10.tbl orders-11.tbl partsupp-06.tbl supplier-00.tbl supplier-01.tbl supplier-02.tbl &
    gzip lineitem-16.tbl lineitem-17.tbl lineitem-18.tbl lineitem-19.tbl orders-12.tbl orders-13.tbl customer-00.tbl customer-01.tbl customer-02.tbl partsupp-07.tbl supplier-03.tbl supplier-04.tbl supplier-05.tbl &
    gzip lineitem-20.tbl lineitem-21.tbl lineitem-22.tbl lineitem-23.tbl orders-14.tbl orders-15.tbl customer-03.tbl customer-04.tbl customer-05.tbl part-00.tbl part-01.tbl part-02.tbl part-03.tbl part-04.tbl supplier-06.tbl supplier-07.tbl &
    for job in `jobs -p`
    do
        wait $job
    done
    
    ```
    **NOTE: This will take around 20 minutes to complete**

## Move the compressed, split files into their own directory
1. Move all files with -##.tbl.gz to the multiple, compressed file directory: ``mv *-[0-9][0-9].tbl.gz /var/tmp/redshift-data/m-psv-gz``

## Copy the files to your S3 bucket

1. Change to the parent directory: ``cd /var/tmp/redshift-data``
1. Use the aws s3 sync command to copy the data to the S3 bucket you created for the lab:
``aws s3 sync . s3://redshift-lab-sample-data`` *replacing **redshift-lab-sample-data** with the bucket name you created*\
**NOTE: This will take 4-5 minutes to complete**

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


## Credits
Transaction Processing Council [TCP-H](http://www.tpc.org/tpch/) decision support benchmark, built using the 
[tpch-kit](https://github.com/gregrahn/tpch-kit) from [Greg Rahn](https://github.com/gregrahn).


---
&copy; 2018 by [Jeff Anderson](https://jeff-anderson.com/). All rights reserved