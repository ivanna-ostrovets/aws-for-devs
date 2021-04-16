# aws-for-devs

Repo with Terraform and CloudFormation configs from "AWS for Devs" course

```shell
aws cloudformation validate-template --template-body file://week2-ec2-s3.yml
```

```shell
aws cloudformation create-stack --stack-name week1 \
    --template-body file://week1-ec2-asg.yml \
    --parameters ParameterKey=EC2InitScript,ParameterValue="$(cat scripts/init-ec2.sh)"
```

```shell
aws cloudformation create-stack --stack-name week2 --region=us-west-2 \
    --template-body file://week2-ec2-s3.yml \
    --capabilities CAPABILITY_NAMED_IAM
```
