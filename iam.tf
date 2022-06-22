resource "aws_iam_user" "user_list" {
  for_each = toset(var.user_list)

  name = each.value
}
resource "aws_iam_policy" "readpolicy" {
  name   = format("%s-policy", var.bucket_list[1])
  policy = local.bucketreadpolicy
}
resource "aws_iam_policy" "writepolicy" {
  name   = format("%s-policy", var.bucket_list[0])
  policy = local.bucketredwrite
}
resource "aws_iam_user_policy_attachment" "writeattachment" {
  user       = var.user_list[0]
  policy_arn = aws_iam_policy.writepolicy.arn
}
resource "aws_iam_user_policy_attachment" "readattachment" {
  user       = var.user_list[1]
  policy_arn = aws_iam_policy.readpolicy.arn
}

