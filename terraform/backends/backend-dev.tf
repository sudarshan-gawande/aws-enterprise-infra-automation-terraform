# Maintained by Sudarshan Gawande - https://sudarshangawande.com

terraform {
  backend "s3" {
    bucket         = "sudarshan-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "sudarshan-terraform-locks"
    encrypt        = true
  }
}
