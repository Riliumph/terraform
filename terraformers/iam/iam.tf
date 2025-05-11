resource "aws_iam_group" "terraformers" {
  name = "terraformers"
}

resource "aws_iam_group_policy_attachment" "terraformers_attach" {
  group      = aws_iam_group.terraformers.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
