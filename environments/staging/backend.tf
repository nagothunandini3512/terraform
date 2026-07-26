terraform {
  backend "s3" {
    bucket       = "nandini-staging-terraform-state"
    key          = "env/staging/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
