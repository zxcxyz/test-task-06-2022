### How to launch
1. Login with aws cli or provide credentials with AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY envs
2. Create an S3 bucket to store state
3. Add S3 bucket name and region to backend.tf
4. Use:
```bash
terraform init
terraform apply
```


### Install pre-commit
To install pre-commit hooks, run the following
```bash
brew install pre-commit
# or
pip install pre-commit

# and then
pre-commit install
```

Now, while you attempt to commit some code changes:
* Terraform fmt will be executed

To start all the hooks manually, run
```bash
pre-commit run -a
```
https://github.com/infrablocks/terraform-aws-ecs-cluster
https://github.com/infrablocks/terraform-aws-ecs-cluster


# Troubleshooting 
https://aws.amazon.com/premiumsupport/knowledge-center/ecs-instance-unable-join-cluster/
https://aws.amazon.com/premiumsupport/knowledge-center/create-alb-auto-register/

