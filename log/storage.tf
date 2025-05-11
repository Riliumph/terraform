data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "log_bucket" {
  bucket        = "structured-log-bucket"
  force_destroy = true

  tags = {
    Name = "structured-log-bucket"
  }
}

data "aws_iam_policy_document" "log_bucket_policy_doc" {
  statement {
    sid    = "AllowPutObject"
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.log_bucket.arn}/*"
    ]
    # 実行者のAWSアカウントからのみアクセス許容
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id
  policy = data.aws_iam_policy_document.log_bucket_policy_doc.json
}

resource "aws_s3_bucket_lifecycle_configuration" "log_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    id     = "log-expiration"
    status = "Enabled"
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration#storage_class-2
    transition {
      # 30日後にGlacierへ移行
      days          = 30
      storage_class = "GLACIER"
    }

    transition {
      # Gracierは最小90日間は保存される
      days          = 120 # 30+90=120
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      # Deep Archiveは最小180日間は保存される
      days = 300 # 120 + 180 = 300
    }

    filter {
      prefix = "logs"
    }
  }
}

output "log_storage" {
  value = aws_s3_bucket.log_bucket.bucket
}
