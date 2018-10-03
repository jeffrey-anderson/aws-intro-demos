**This directory contains [manifest](https://docs.aws.amazon.com/redshift/latest/dg/loading-data-files-using-manifest.html)
files for use with the Redshift COPY command.**

You will need to update them prior to using them

**Usage:**

1. Complete the [Creating Sample Data For Redshift](Demo-RedshiftDataPrep.md) lab including loading the sample data 
  to a bucket in S3
2. Change the URL in each of these files to reference the files you uploaded when creating the sample data
3. For each set of files, verify then manifest correctly references each and every file
4. Upload them to S3 so they can be referenced in your [Redshift COPY](https://docs.aws.amazon.com/redshift/latest/dg/t_loading-tables-from-s3.html) command

**Files:**

* [customer.manifest](customer.manifest)
* [lineitem.manifest](lineitem.manifest)
* [orders.manifest](orders.manifest)
* [part.manifest](part.manifest)
* [partsupp.manifest](partsupp.manifest)
* [supplier.manifest](supplier.manifest)



---
&copy; 2018 by [Jeff Anderson](https://jeff-anderson.com/). All rights reserved
