#!/bin/bash -xe

aws s3 mb s3://s3_bucket_name > /dev/null

aws s3 cp scripts/dynamodb-script.sh s3://s3_bucket_name/ > /dev/null
aws s3 cp scripts/rds-script.sql s3://s3_bucket_name/ > /dev/null
