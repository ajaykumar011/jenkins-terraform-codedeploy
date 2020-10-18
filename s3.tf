#bucket for elb logs
resource "aws_s3_bucket" "elblogs-store" {
  bucket = "elblogs-store-${random_string.random.result}"
  acl    = "private"
  versioning {
    enabled = true
    }
  tags = {
    Name = "elblogs store"
  }
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}



# create an S3 bucket for codedeploy store
resource "aws_s3_bucket" "b" {
  bucket = "codedeploydemo-${random_integer.suffix.result}"
  acl    = "private"
}

resource "random_integer" "suffix" {
  min = 100
  max = 999
}
