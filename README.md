### Features
Instances will refresh after template changing

### Issues
EIP addresses on target group not appearing ;/
https://www.architect.io/blog/2021-03-30/create-and-manage-an-aws-ecs-cluster-with-terraform/
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



The container instance profile cluster-instance-profile-hubstaff-test is missing the following required permission(s): 
['ecs:UpdateContainerInstancesState']
Make sure that the container instance has all the recommended permissions.
See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/security-iam-awsmanpol.html#instance-iam-role-permissions

The container instance is running in a public subnet without a public IP.
A public subnet is a subnet that's associated with a route table that has a route to an internet gateway. Container instances need access to communicate with the Amazon ECS service endpoint. This can be through an interface VPC endpoint or through your container instances having public IP addresses.You need to make sure that the container instance has the public IP assigned while using public subnet in order to allow the communication with Amazon ECS service endpoint.
See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_instances.html#container_instance_concepts