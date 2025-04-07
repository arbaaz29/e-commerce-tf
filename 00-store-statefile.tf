#strore state files in a s3 bucket and its id in dynamodb for multi user purpose
terraform {

 backend "s3" {

   bucket = "my-tf-states-stores"
   key= "state/terraform.tfstate"
   region = "us-east-1"
   dynamodb_table = "lock-files"
   encrypt = true
 }
 required_version = ">=1.2.0"

}