resource "aws_glue_registry" "ingest-glue-registry" {

   registry_name = "ingest-glue-registry"
   tags = merge(
    var.additional_tags,
    {
        "Name" = "ingest-glue-registry"
    }
  )
}

