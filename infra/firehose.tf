
resource "aws_kinesis_firehose_delivery_stream" "ingest-hose" {

    name = var.hose_name
    destination = "extended_s3"


    kinesis_source_configuration {
        kinesis_stream_arn = aws_kinesis_stream.ingest-stream.arn
        role_arn = aws_iam_role.firehose-stream-role.arn
    }


    extended_s3_configuration {

      dynamic_partitioning_configuration {
        enabled = "true"
      }

      role_arn = aws_iam_role.firehose-stream-role.arn
      bucket_arn = aws_s3_bucket.firehose-ingest-bucket.arn

      prefix = "data/tenantId=!{partitionKeyFromQuery:tenantId}/date=!{partitionKeyFromQuery:eventDate}/"
      error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"

      buffer_size = 128
      buffer_interval = 90

      processing_configuration {
        enabled = "true"

        processors {
        type = "Lambda"

          parameters {
            parameter_name  = "LambdaArn"
            parameter_value = "${aws_lambda_function.ingest-lambda.arn}:$LATEST"
          }
          parameters {
            parameter_name = "RoleArn"
            parameter_value = aws_iam_role.firehose-stream-role.arn
          }
      }

        processors {
          type = "MetadataExtraction"
          parameters {
            parameter_name = "JsonParsingEngine"
            parameter_value = "JQ-1.6"
          }
          parameters {
            parameter_name = "MetadataExtractionQuery"
            parameter_value = "{tenantId:.header.tenantId,eventDate:.header.eventTimestamp | strptime(\"%Y-%m-%dT%H:%M:%S%Z\") | strftime(\"%Y-%m-%d\")}"
          }
        }
      }

      data_format_conversion_configuration {
        input_format_configuration {
          deserializer {
            open_x_json_ser_de {
              
            }
          }
        }
        output_format_configuration {
          serializer {
            parquet_ser_de {
              compression = "SNAPPY"
            }
          }
        }
        schema_configuration {
          database_name = aws_glue_catalog_database.ingest_glue_database.name
          role_arn = aws_iam_role.firehose-stream-role.arn
          table_name = aws_glue_catalog_table.test-data.name
        }
      }
    }

    tags = merge(
    var.additional_tags,
    {
        "Name" = "ingest_hose"
    }
  )
}