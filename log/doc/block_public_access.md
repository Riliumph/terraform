# S3の権限について

S3には「ブロックパブリックアクセス (バケット設定)」という設定があり、不特定多数からのアクセスは原則禁止とされている。  
しかし、これからどんなリソースがログを書き込むか分からない場合、このエラーをどう対処するべきか分からない。

## 問題のポリシー

```terraform
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
}
```

## 実行してみる

```console
$ terraform plan
（省略）
│ Error: putting S3 Bucket (structured-log-bucket) Policy: operation error S3: PutBucketPolicy, https response error StatusCode: 403, RequestID: ***, HostID: ***, api error AccessDenied: User: arn:aws:iam::<account_id>:user/<iam-user> is not authorized to perform: s3:PutBucketPolicy on resource: "arn:aws:s3:::structured-log-bucket" because public policies are blocked by the BlockPublicPolicy block public access setting.
│
│   with aws_s3_bucket_policy.log_bucket_policy,
│   on storage.tf line 41, in resource "aws_s3_bucket_policy" "log_bucket_policy":
│   41: resource "aws_s3_bucket_policy" "log_bucket_policy" {
│
```

このエラーは、Block Public Access機能により以下の設定が拒否されたことを示す。

```terraform
    principals {
      type        = "*"
      identifiers = ["*"]
    }
```

## 解決方針

### あまり良くない解決方針

以下の設定を加えてブロックパブリックアクセスを無効化し、誰でもアクセスできるようにする。

```terraform
resource "aws_s3_bucket_public_access_block" "main" {
  depends_on = [aws_s3_bucket_policy.main]
  bucket     = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

……危険なのでやらないように。

### 今回採用した解決方針

前提として「コマンドを実行したAWSアカウントが所有するリソースのみが書き込みできる」という条件を付与することで解決する。

- [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)について

```terraform
data "aws_caller_identity" "current" {}

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
```
