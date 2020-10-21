#bucket for elb logs
resource "aws_s3_bucket" "elblogs-store" {
  bucket = "elblogs-store-${random_string.random.result}"
  acl    = "private"
  versioning {
    enabled = true
  }
  #combined tags
  tags = merge(
    local.common_tags,
    map(
      "Work", "awesome-storage",
      "Role", "storage"
    )
  )
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



#########################
# S3 bucket for ELB logs SAMPLE
#########################
// data "aws_elb_service_account" "this" {}

// resource "aws_s3_bucket" "logs" {
//   bucket        = "elb-logs-${random_pet.this.id}"
//   acl           = "private"
//   policy        = data.aws_iam_policy_document.logs.json
//   force_destroy = true
// }

// data "aws_iam_policy_document" "logs" {
//   statement {
//     actions = [
//       "s3:PutObject",
//     ]

//     principals {
//       type        = "AWS"
//       identifiers = [data.aws_elb_service_account.this.arn]
//     }

//     resources = [
//       "arn:aws:s3:::elb-logs-${random_pet.this.id}/*",
//     ]
//   }
// }

##################