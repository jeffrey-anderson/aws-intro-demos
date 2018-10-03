copy region FROM 's3://redshift-lab-sample-data/multiple-files/region.tbl.gz'
credentials 'aws_iam_role=arn:aws:iam::031849459082:role/redshift-S3-ro-access' 
COMPUPDATE ON gzip delimiter '|' ;

copy nation FROM 's3://redshift-lab-sample-data/multiple-files/nation.tbl.gz'
credentials 'aws_iam_role=arn:aws:iam::031849459082:role/redshift-S3-ro-access' 
COMPUPDATE ON gzip delimiter '|' ;

copy part from 's3://redshift-lab-sample-data/multiple-files/part.manifest' 
credentials 'aws_iam_role=arn:aws:iam::031849459082:role/redshift-S3-ro-access' 
COMPUPDATE ON gzip delimiter '|' manifest;

copy supplier from 's3://redshift-lab-sample-data/multiple-files/supplier.manifest' 
credentials 'aws_iam_role=arn:aws:iam::031849459082:role/redshift-S3-ro-access' 
COMPUPDATE ON gzip delimiter '|' manifest;

copy partsupp from 's3://redshift-lab-sample-data/multiple-files/partsupp.manifest' 
credentials 'aws_iam_role=arn:aws:iam::031849459082:role/redshift-S3-ro-access' 
COMPUPDATE ON gzip delimiter '|' manifest;

copy customer from 's3://redshift-lab-sample-data/multiple-files/customer.manifest' 
credentials 'aws_iam_role=arn:aws:iam::031849459082:role/redshift-S3-ro-access' 
COMPUPDATE ON gzip delimiter '|' manifest;

copy orders from 's3://redshift-lab-sample-data/multiple-files/orders.manifest' 
credentials 'aws_iam_role=arn:aws:iam::031849459082:role/redshift-S3-ro-access' 
COMPUPDATE ON gzip delimiter '|' manifest;

copy lineitem from 's3://redshift-lab-sample-data/multiple-files/lineitem.manifest' 
credentials 'aws_iam_role=arn:aws:iam::031849459082:role/redshift-S3-ro-access' 
COMPUPDATE ON gzip delimiter '|' manifest;
