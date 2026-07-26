terraform {
  backend "s3" {
    bucket       = "nandini-production-terraform-state"
    key          = "env/production/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
