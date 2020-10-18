terraform {
  backend "s3" {
    bucket = "cloudzone100"
    key    = "terrafpr-state/project/dev"
    region = "us-east-1"
  }
}