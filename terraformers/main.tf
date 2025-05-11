# IAMグループの作成
resource "aws_iam_group" "terraformers" {
  name = "terraformers"
}

# IAMポリシーのJSONドキュメントの作成
data "aws_iam_policy_document" "terraformer_policy_doc" {
  statement {
    actions = [
      "ec2:*",
      "s3:*",
      "iam:*",
      "dynamodb:*",
      "cloudwatch:*",
      "logs:*",
      "sts:AssumeRole"
    ]
    resources = ["*"]
  }
}

# IAMポリシーの作成
resource "aws_iam_policy" "terraformer_policy" {
  name        = "TerraformerPolicy"
  description = "Policy for Terraform Power Users"
  policy      = data.aws_iam_policy_document.terraformer_policy_doc.json
}

# IAMグループへポリシーをアタッチする
resource "aws_iam_group_policy_attachment" "terraformers_attached_policy" {
  group      = aws_iam_group.terraformers.name
  policy_arn = aws_iam_policy.terraformer_policy.arn
}
