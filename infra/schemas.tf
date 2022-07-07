
resource "aws_glue_schema" "test-data-schema" {

  registry_arn = aws_glue_registry.ingest-glue-registry.arn
  data_format = "JSON"
  compatibility = "BACKWARD"
  schema_name = "foobar"
  schema_definition = <<EOF
  {
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "properties": {
    "header": {
      "type": "object",
      "properties": {
        "eventId": {
          "type": "string"
        },
        "tenantId": {
          "type": "string"
        },
        "eventTimestamp": {
          "type": "string"
        },
        "eventTimestampUTC": {
          "type": "string"
        },
        "eventType": {
          "type": "string"
        }
      },
      "required": [
        "eventId",
        "tenantId",
        "eventTimestamp",
        "eventTimestampUTC",
        "eventType"
      ]
    },
    "body": {
      "type": "object",
      "properties": {
        "oldData": {
          "type": "object",
          "properties": {
            "Patient": {
              "type": "object",
              "properties": {
                "Name": {
                  "type": "string"
                }
              },
              "required": [
                "Name"
              ]
            }
          },
          "required": [
            "Patient"
          ]
        },
        "newData": {
          "type": "object",
          "properties": {
            "Patient": {
              "type": "object",
              "properties": {
                "Name": {
                  "type": "string"
                }
              },
              "required": [
                "Name"
              ]
            }
          },
          "required": [
            "Patient"
          ]
        }
      },
      "required": [
        "oldData",
        "newData"
      ]
    }
  },
  "required": [
    "header",
    "body"
  ]
}
EOF

    tags = merge(
    var.additional_tags,
    {
        "Name" = "foobar"
    }
  )
}