### PROBLEMS:
ECS nodes fail to bootstrap. Suspecting wrong aws role.
### TODO:
- code should work
- as the example of the application please use [this project](https://github.com/benc-uk/nodejs-demoapp)
- the application needs to have access to the DB system
- application nodes should be located in the private networks only
- please consider using reverse proxy for the applicaton but is not essential
- applications nodes should scale up automatically based on the CPU usage (please consider ASG rule)
- only application nodes should have access to the Database
- communication with the Database should only be over private IP addresses
- using RDS service is allowed (it should not be exposed - no public endpoint)
- to expose application instances, please consider application load balancer
- how you will provision the instances is entirely up to you (Ansible, Puppet, etc)
- please include instruction on how the Terraform code should be executed

### DONE:
- Terraform code should contain VPC definition
- using external Terraform modules is not allowed
- application nodes should not have public IP addresses
- application nodes should be located on EC2 instances
- OS used on instances does not matter
- please use the latest version of the Terraform