/*
Variable's Prefixes:
  ING - Variables used in services of Ingestion Layer
  TRF - Variables used in services of Transformation Layer
  SER - Variables used in services of Serving Layer
  GLB - Variables used across all AWS structure
*/

variable "GLB_identifier" {
  default     = "qxz50zr"
  description = "Variable to describe resources created by you"
}

variable "GLB_project_name" {
  default     = "da7"
  description = "Name of the project"
}

variable "ING_source_bucket" { # Variable that defines the S3 bucket that serves as Source
  type = map(string)
  default = {
    "bucket_name" = "da7-source-bucket"
    "bucket_arn"  = "arn:aws:s3:::da7-source-bucket"
  }
  description = "S3 bucket that serves as the Data Source"
}

variable "ING_lambda_folder_names" { # Variable that defines the folders inside the bucket that the lambda should ingest
  type        = list(string)         # Specifies that a variable is expected to be a list, and the elements of that list are strings
  default     = ["taxi", "bicycles"] # Add /
  description = "Folders inside the bucket that the lambda should ingest"
}

locals { # This block is used to define local values, which are computed values derived from the input variables
  prefix = "${var.GLB_project_name}_${var.GLB_identifier}"
}