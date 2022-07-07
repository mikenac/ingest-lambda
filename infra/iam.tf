
resource "aws_iam_role" "firehose-stream-role" {
  
    name = "firehose-stream-role"
    permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/telesys/tt-base-permission-boundary"
    tags = merge(
        var.additional_tags,
        {
            "Name" = "firehose-stream-role"
        }
   )

  assume_role_policy = jsonencode(
    {
        Version =  "2012-10-17",
        Statement = [
            {
                Action = "sts:AssumeRole"
                Principal = {
                    Service = "firehose.amazonaws.com"
                }
                Effect = "Allow"
            },
            {
                Action = "sts:AssumeRole"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
                Effect = "Allow"
            }
        ]
    }
  )
}


resource "aws_iam_role_policy" "firehose-stream-policy" {

    name = "firehose-stream-policy"
    role = aws_iam_role.firehose-stream-role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
           {
                Effect = "Allow"
                Action = [
                    "kinesis:DescribeStream",
                    "kinesis:GetShardIterator",
                    "kinesis:GetRecords",
                    "kinesis:ListShards"
                ]
                Resource = aws_kinesis_stream.ingest-stream.arn
           },
           {
                Effect = "Allow"
                Action =[
                    "s3:AbortMultipartUpload",
                    "s3:GetBucketLocation",
                    "s3:GetObject",
                    "s3:ListBucket",
                    "s3:ListBucketMultipartUploads",
                    "s3:PutObject"
                ]
                Resource = [
                    aws_s3_bucket.firehose-ingest-bucket.arn,
                    "${aws_s3_bucket.firehose-ingest-bucket.arn}/*"
                ]
           },
            {
                Effect = "Allow"
                Action = [
                    "glue:*"
                ]
                Resource = "*"
           },
           {
                Effect = "Allow"
                Action = [
                    "logs:*"
                ]
                Resource = "arn:aws:logs:*:*:*"
           },
            {
                Effect = "Allow"
                Action = [
                    "lambda:InvokeFunction",
                    "lambda:GetFunctionConfiguration"
                ]
                Resource = [
                    aws_lambda_function.ingest-lambda.arn,
                    "${aws_lambda_function.ingest-lambda.arn}:*"
                ]
           }
        ]
    })
}

