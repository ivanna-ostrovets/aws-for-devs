#!/bin/bash -xe

echo 'Hello World!' > test-file.txt

aws s3 mb s3://s3_bucket_name > /dev/null

aws s3api put-bucket-versioning --bucket s3_bucket_name --versioning-configuration Status=Enabled > /dev/null

aws s3 cp test-file.txt s3://s3_bucket_name/ > /dev/null
