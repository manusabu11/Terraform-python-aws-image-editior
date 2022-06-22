resource "aws_s3_bucket" "bucket_list" {
  for_each = toset(var.bucket_list)
  bucket   = each.value

  tags = {
    Name        = "GEL"
    Environment = "Test"
  }
}
resource "aws_s3_bucket_acl" "bucket_list" {
  for_each = toset(var.bucket_list)
  bucket   = aws_s3_bucket.bucket_list[each.value].id
  acl      = "private"
}
resource "aws_s3_bucket_public_access_block" "s3Public" {
  for_each                = toset(var.bucket_list)
  bucket                  = aws_s3_bucket.bucket_list[each.value].id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
