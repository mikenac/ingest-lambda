
resource "aws_lambda_function" "ingest-lambda" {
  filename = "../lambda.zip"
  function_name = var.function_name
  role = aws_iam_role.firehose-stream-role.arn
  handler = "app.lambda_handler"
  runtime = "python3.8"
  timeout = 120
  source_code_hash = filebase64sha256("../lambda.zip")
}

resource "aws_cloudwatch_log_group" "ingest-lambda-loggroup" {
  name = "/aws/lamdbda/${var.function_name}"
  retention_in_days = 14
}
