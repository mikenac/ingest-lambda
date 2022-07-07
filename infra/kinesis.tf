resource "aws_kinesis_stream" "ingest-stream" {
  name             = var.stream_name
 # shard_count      = 2
  retention_period = 24
  encryption_type = "KMS"
  kms_key_id = "alias/aws/kinesis"

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
    "IncomingRecords"
  ]

   stream_mode_details {
    stream_mode = "ON_DEMAND"
  }


  tags = merge(
    var.additional_tags,
    {
        "Name" = var.stream_name
    }
  )
}

output "kinesis_stream_name" {
  value = aws_kinesis_stream.ingest-stream.name
}