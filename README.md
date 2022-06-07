### Features
Instances will refresh after template changing

### Issues
If you want to change name 
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