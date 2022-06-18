### TODO:

### DONE:
- code should work
- only application nodes should have access to the Database - separate subnet and security group rules
- application nodes should be located in the private networks only - instances in private subnets
- communication with the Database should only be over private IP addresses - docdb doesnt have public ip or hostnames
- using RDS service is allowed (it should not be exposed - no public endpoint) - docdb
- to expose application instances, please consider application load balancer - ALB
- how you will provision the instances is entirely up to you (Ansible, Puppet, etc) - terraform
- please consider using reverse proxy for the applicaton but is not essential - ALB has the same functionality?
- the application needs to have access to the DB system - done
- as the example of the application please use [this project](https://github.com/benc-uk/nodejs-demoapp) - done
- Terraform code should contain VPC definition - done
- using external Terraform modules is not allowed - done
- application nodes should not have public IP addresses - done
- application nodes should be located on EC2 instances - done
- OS used on instances does not matter - done
- please use the latest version of the Terraform - done
- applications nodes should scale up automatically based on the CPU usage (please consider ASG rule) - done with ecs managed autoscaling
- please include instruction on how the Terraform code should be executed - done
