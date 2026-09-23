terraform {
  backend "s3" {
    bucket = "statefile-store-nit"
    key = "terraform-statefile/terraformtfstate"
    region = "us-east-1"
    use_lockfile = true    #supports terraform latest version >=1.10
  }
}