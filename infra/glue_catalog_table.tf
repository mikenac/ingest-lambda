resource "aws_glue_catalog_table" "test-data" {
  name = "foobar"
  database_name = aws_glue_catalog_database.ingest_glue_database.name
  
  parameters = {
    EXTERNAL = "TRUE"
    "parquet.compression" = "SNAPPY"
   
  }

  storage_descriptor {
    location = aws_kinesis_stream.ingest-stream.name
    input_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    
    parameters = {
       "streamARN" = aws_kinesis_stream.ingest-stream.arn
       "typeOfData" = "kinesis"
    }
    schema_reference {

      schema_id {
          registry_name = aws_glue_registry.ingest-glue-registry.registry_name
          schema_name = aws_glue_schema.test-data-schema.schema_name
      }
      schema_version_number = aws_glue_schema.test-data-schema.latest_schema_version
    }
  }
}