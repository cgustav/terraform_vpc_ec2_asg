resource "aws_iam_user" "user" {
  name = var.user_name
}

resource "aws_iam_user_policy" "policy" {
  name = "${var.user_name}_policy"
  user = aws_iam_user.user.name

  policy = var.inline_policy
}

resource "aws_iam_access_key" "user_key" {
  user = aws_iam_user.user.name
}
