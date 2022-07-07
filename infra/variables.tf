
variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

variable "bucket_name" {
  default = ""
}

variable "glue_database" {
  default = ""
}

variable "stream_name" {
  default = ""
}

variable "hose_name" {
  default = ""
}

variable "function_name" {
  default = ""
}