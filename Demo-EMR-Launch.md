# Launching an Elastic Map Reduce (EMR) Cluster

**IMPORTANT:** 
*   For the EMR demos, we will be using the [NOAA Global Historical Climatology Network Daily (GHCN-D)](https://registry.opendata.aws/noaa-ghcn/)
public dataset which is conveniently stored in Amazon Web Services (AWS) Simple Storage Service (S3) in the us-east-1 region.  **To avoid data transfer charges, 
make sure you are using the Northern Virginia (us-east-1) region.**
*   EMR does not have a "free tier" option. Completing this demo will result in charges of around 25 cents per hour so 
**be sure to terminate your cluster once you are done with these demos**.

## Prerequisites:

1. You are logged in to the console and have set "N. Virginia" as the region
1. You created a [SSH key-pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) for the us-east-1 
region and have access to it on your current computer
1. You created an [EC2 security group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) named 
"emr-access-from-my-ip" which has the following inbound rules:

| Type | Protocol | Port Range | Source |
|:---:|:--------:|:----------:|:------:|
| Custom TCP Rule | TCP | 22 | My IP | 
| Custom TCP Rule | TCP | 80 | My IP | 
| Custom TCP Rule | TCP | 8042 | My IP | 
| Custom TCP Rule | TCP | 8088 | My IP | 
| Custom TCP Rule | TCP | 8888 | My IP | 
| Custom TCP Rule | TCP | 8890 | My IP | 
| Custom TCP Rule | TCP | 9443 | My IP | 
| Custom TCP Rule | TCP | 16010 | My IP | 
| Custom TCP Rule | TCP | 18080 | My IP | 
| Custom TCP Rule | TCP | 50070 | My IP | 
| Custom TCP Rule | TCP | 50075 | My IP | 

## Launching a cluster:

### Step 1: Software and Steps

1. From the AWS Services screen, choose "EMR" under Analytics
1. From the EMR dashboard, click "Create cluster"
1. Click "Go to advanced options"
1. Under "Software Configuration" choose:
    * Hadoop
    * JupyterHub
    * Ganglia
    * Hive
    * Hue
    * Spark
    * Zeppelin
1. Click "Next" to move to step 2

### Step 2: Hardware

Before making any changes, note the default instance type (i.e. m4.large) and the availability zone associated with
the chosen EC2 Subnet

#### Questions:
1. Using the [Amazon EMR Pricing](https://aws.amazon.com/emr/pricing/) guide as a reference, what is the on-demand hourly 
charge for the auto-selected instance type?
1. Under the "Purchasing Option" column, note the information icon (i) to the right of the "Spot" radio button. Hover 
over it until the current spot price list appears.  What the lowest spot price available?
1. Given the availability zone chosen in the "EC2 Subnet" drop down, what spot price would apply?
1. Click on the pencil icon next to the Master node instance type and change it to the next level up (i.e. m4.large -> 
m4.xlarge) then press "Save". What is the on-demand price for the newly selected instance type?
1. What is the current spot price for the newly selected instance type?
1. If you choose the "Spot" purchasing option, and spot rates remain constant, how much per hour will you save?
1. If you choose the "Spot" purchasing option combined with "Use on-demand as max price" what is the maximum hourly
rate you will pay?

#### Hardware settings:

1. Choose the "Spot" purchasing option for the Master node leaving the default setting of, "Use on-demand as max price"
1. If necessary, change the EC2 Subnet so your cluster runs in an availability zone with the lowest spot price 
1. Change the instance count for the "Core" node type to zero (0) instances
1. Click "Next" to move on to step 3


### Step 3: General Options:

1. Name your cluster something meaningful like "My first cluster"
1. Uncheck "Logging" and "Termination protection" since this is a demo cluster which will only be running for a few hours
1. Optionally under "Tags", enter "Name" in the "Key" column and the cluster name you used for step 1 in the "Value" column
1. Click "Next" to move onto step 4

### Step 4 Security:

**NOTE:** See prerequisites above

1. For "EC2 key pair", choose one you have access to on your current computer
1. Optionally, un-check "Cluster visible to all IAM users in account"
1. Expand the "EC2 Security Groups" section
1. Click the pencil icon in the "Additional security groups" column of the "Master" node row
1. Choose the "emr-access-from-my-ip" security group you previously created and click, "Assign security groups" (see 
*Additional notes about cluster security* below)
1. Click "Create Cluster"

## Additional notes about cluster security

The most secure way to use your cluster is to disallow all access except through SSH and local port forward through SSH 
tunneling as described in [this document](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-web-interfaces.html). 
Doing so ensures only people with the chosen EC2 public key can gain access to the cluster. The procedure
is, however, complicated and, depending on the option chosen, requires installation and configuration of a SOCKS proxy browser plugin.

By creating and using a security group that allows access to the cluster only from your specific IP address, you 
can connect directly without using local port forwarding. While this reduces complexity, it also reduces security because anyone coming from that same 
IP address can access the cluster. For example, if you granted access to an IP address associated with your 
home network then any device on your home network can connect. If you are on a large corporate network then any device
in that network can also connect. Obviously, the bigger the network, the greater the risk.

Because our cluster is for demo purposes and will only be running for a short period of time, this is arguably a 
reasonable trade off considering a bad actor on the network would have to know the cluster IP address and be able to do bad things
while it is running. If this causes concern, only allow SSH access from your IP address and configure access as described 
in the official documentation. 

For a comprehensive list of EMR security options, see [this guide](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-security.html).

## Where to go from here

Once your cluster is up, running, and in a "Waiting" state, continue with the Using an EMR cluster demos:
* [Using Spark with Jupyter](./Demo-Spark-Jupyter.md)
* [Using Hive with HUE](./Demo-Hive-HUE.md)


## Finally

Once you are done with the demos, terminate your cluster to avoid additional charges. 
