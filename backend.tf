terraform {
  backend "s3" {
    bucket = "terraformstatezxcxyz"
    key    = "demo.tfstate"
    region = "eu-west-1"
    # todo add dynamodb 
  }
}