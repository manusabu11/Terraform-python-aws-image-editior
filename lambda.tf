resource "local_file" "lambda_py_script" {
  content  = local.lmbdacontent
  filename = "lambda_function.py"
}
resource "aws_iam_role" "iam_for_lambda" {
  name               = format("%s-iamrole", var.lambdafnname)
  assume_role_policy = local.lamdarolepolicy
}
resource "aws_iam_policy" "lambdas3policy" {
  name   = format("%s-lambdapolicy", var.lambdafnname)
  policy = local.lambdas3policy
}
resource "aws_iam_policy_attachment" "lambdas3" {
  name       = format("%s-lambdapolicy", var.lambdafnname)
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = aws_iam_policy.lambdas3policy.arn
}
data "archive_file" "lambda_zip" {
  type             = "zip"
  source_file      = local_file.lambda_py_script.filename
  output_file_mode = "0666"
  output_path      = "${local_file.lambda_py_script.filename}.zip"
}
resource "aws_lambda_layer_version" "pillow_lambda_layer" {
  filename   = "pillow-layer.zip"
  layer_name = "pillow-layer"

  compatible_runtimes = ["python3.9"]
}

resource "aws_lambda_function" "mylambdatest" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.lambdafnname
  role             = aws_iam_role.iam_for_lambda.arn
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  memory_size      = 10240
  timeout          = 20
  layers           = [aws_lambda_layer_version.pillow_lambda_layer.arn]
}
resource "aws_lambda_permission" "lambda_invoke_permission_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mylambdatest.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.bucket_list[local.arnbucketa].id}"
}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.bucket_list[local.arnbucketa].id
  lambda_function {
    lambda_function_arn = aws_lambda_function.mylambdatest.arn
    events              = ["s3:ObjectCreated:Put", ]

  }
}
