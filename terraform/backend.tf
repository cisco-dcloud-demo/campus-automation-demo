terraform {
  backend "s3" {
    bucket = "cpn-tfstate"
    key    = "network"
    region = "us-east-1"
  }
}