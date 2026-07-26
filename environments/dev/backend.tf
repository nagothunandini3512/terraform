terraform {
  backend "s3" {
    bucket       = "nandini-dev-terraform-state"
    key          = "env/dev/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
