#!/bin/bash

aws dynamodb list-tables

echo "Put (1, EC2) item to table"
aws dynamodb put-item --table-name "aws_services" --item '{ "id": {"N": "1"}, "name": {"S": "EC2"} }'

echo "Put (2, S3) item to table"
aws dynamodb put-item --table-name "aws_services" --item '{ "id": {"N": "2"}, "name": {"S": "S3"} }'

echo "Put (3, RDS) item to table"
aws dynamodb put-item --table-name "aws_services" --item '{ "id": {"N": "3"}, "name": {"S": "RDS"} }'

echo "Get item with id '1' from table"
aws dynamodb get-item --table-name "aws_services" --key '{ "id": {"N": "1"} }'

echo "Get item with id '2' from table"
aws dynamodb get-item --table-name "aws_services" --key '{ "id": {"N": "2"} }'

echo "Get item with id '3' from table"
aws dynamodb get-item --table-name "aws_services" --key '{ "id": {"N": "3"} }'

echo "Get item with non-existing id '4' from table"
aws dynamodb get-item --table-name "aws_services" --key '{ "id": {"N": "4"} }'
