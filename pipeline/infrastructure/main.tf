/*
Resources' Prefixes:
  ING - Resources used in services of Ingestion Layer
  TRF - Resources used in services of Transformation Layer
  SER - Resources used in services of Serving Layer
  GLB - Resources used across all AWS structure
*/


/* BUCKET FOR STORAGE */

resource "aws_s3_bucket" "GLB_storage_bucket" {
  bucket = "${var.GLB_project_name}-${var.GLB_identifier}"
}


/* LAMBDA FOR INGESTION */

data "archive_file" "ING_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/code/function.py"
  output_path = "${path.module}/code/function.zip"
}

resource "aws_lambda_function" "ING_lambda_function" {
  count         = length(var.ING_lambda_folder_names) # calculates the number of folders that contain the objects to ingest
  function_name = "${local.prefix}_lambda_ingestion_${var.ING_lambda_folder_names[count.index]}"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.10"

  filename         = data.archive_file.ING_lambda_package.output_path # Path to your ZIP file containing the function code
  source_code_hash = data.archive_file.ING_lambda_package.output_base64sha256
  handler          = "function.lambda_handler"

  environment {
    variables = {
      ING_FOLDER          = var.ING_lambda_folder_names[count.index]
      SOURCE_BUCKET_NAME  = var.ING_source_bucket["bucket_name"]
      STORAGE_BUCKET_NAME = aws_s3_bucket.GLB_storage_bucket.bucket
      DYNAMO_TABLE_NAME   = aws_dynamodb_table.ING_dynamodb_timestamp.name
    }
  }

  memory_size = 512
  timeout     = 500

  # Specify the dependency on the creation and attachment of role and policy
  depends_on = [
    aws_iam_role_policy_attachment.role_policy_attachment_lambda
  ]
}


/* DYNAMO TO HELP INGESTION */
resource "aws_dynamodb_table" "ING_dynamodb_timestamp" {
  name         = "${local.prefix}_dynamo_ingestion_timestamp"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
}


resource "aws_dynamodb_table_item" "ING_dynamodb_items" {
  count      = length(var.ING_lambda_folder_names)
  table_name = aws_dynamodb_table.ING_dynamodb_timestamp.name
  hash_key   = aws_dynamodb_table.ING_dynamodb_timestamp.hash_key

  item = <<ITEM
    {
      "ID"        : { "S": "${var.ING_lambda_folder_names[count.index]}" },
      "TIMESTAMP" : { "N": "0" }
    }
  ITEM

  lifecycle {
    ignore_changes = [item]
  }
}


/* FIREHOSE FOR STREAMING INGESTION */

resource "aws_kinesis_firehose_delivery_stream" "ING_firehose" {
  name        = "${local.prefix}_firehose"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = "arn:aws:kinesis:eu-central-1:490288335462:stream/da7_data_stream"
    role_arn           = aws_iam_role.firehose_role.arn
  }

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.GLB_storage_bucket.arn
    prefix     = "stream/"
  }

  depends_on = [aws_iam_role_policy_attachment.role_policy_attachment_firehose]
}


/* BUCKET FOR TRANSFORMATION */
resource "aws_s3_bucket" "TRF_storage_bucket" {
  bucket = "${var.GLB_project_name}-${var.GLB_identifier}-prepared-bucket"
}


/* S3 bucket to save glue job to transform taxi data*/
resource "aws_s3_object" "taxi_job_script" {
  bucket = aws_s3_bucket.TRF_storage_bucket.bucket
  acl    = "private"
  key    = "glue-jobs/taxi_job.py"
  source = "${path.module}/glue_jobs/taxi_job.py"
  etag   = filemd5("${path.module}/glue_jobs/taxi_job.py")
}


/* GLUE JOB TO PREPARE taxi Data*/
resource "aws_glue_job" "TRF_glue_job_taxi" {
  name          = "${local.prefix}_glue_job_taxi"
  role_arn      = aws_iam_role.glue_role.arn
  execution_property {
    max_concurrent_runs = 1
  }

  command {
    name     = "glueetl"
    script_location = "s3://${aws_s3_bucket.TRF_storage_bucket.bucket}/glue-jobs/taxi_job.py"
    python_version = "3"
  }

  number_of_workers = 5  # Adjust the number of workers as needed

  depends_on = [ aws_s3_object.taxi_job_script ]

}


/* S3 bucket to save glue job to transform taxi data*/
resource "aws_s3_object" "citibike_stream_job_script" {
  bucket = aws_s3_bucket.TRF_storage_bucket.bucket
  acl    = "private"
  key    = "glue-jobs/citibike_stream_job.py"
  source = "${path.module}/glue_jobs/citibike_stream_job.py"
  etag   = filemd5("${path.module}/glue_jobs/citibike_stream_job.py")
}


/* GLUE JOB TO PREPARE citibike_stream Data*/
resource "aws_glue_job" "TRF_glue_job_citibike_stream" {
  name          = "${local.prefix}_glue_job_citibike_stream"
  role_arn      = aws_iam_role.glue_role.arn
  execution_property {
    max_concurrent_runs = 1
  }

  command {
    name     = "glueetl"
    script_location = "s3://${aws_s3_object.citibike_stream_job_script.bucket}/glue-jobs/citibike_stream_job.py"
    python_version = "3"
  }
}






/* S3 bucket to save glue job to Load taxi and citibike data to RDS*/
resource "aws_s3_object" "citibike_load_job_script" {
  bucket = aws_s3_bucket.TRF_storage_bucket.bucket
  acl    = "private"
  key    = "glue-jobs/citibike_load.py"
  source = "${path.module}/glue_jobs/citibike_load.py"
  etag   = filemd5("${path.module}/glue_jobs/citibike_load.py")
}

resource "aws_s3_object" "taxi_load_job_script" {
  bucket = aws_s3_bucket.TRF_storage_bucket.bucket
  acl    = "private"
  key    = "glue-jobs/taxi_load.py"
  source = "${path.module}/glue_jobs/taxi_load.py"
  etag   = filemd5("${path.module}/glue_jobs/taxi_load.py")
}


# Create glue jobs to Load taxi and citibike data to RDS*/
resource "aws_glue_job" "TRF_glue_job_citibike_load" {
  name          = "${local.prefix}_glue_job_citibike_load"
  role_arn      = aws_iam_role.glue_role.arn
  execution_property {
    max_concurrent_runs = 1
  }

  command {
    name     = "glueetl"
    script_location = "s3://${aws_s3_object.citibike_load_job_script.bucket}/glue-jobs/citibike_load.py"
    python_version = "3"
  }

  max_capacity = 2.0  # Allocates 2 DPUs to this job

  connections = [
    "data-academy-7_postgres_connection_intranet_0","data-academy-7_postgres_connection_intranet_1"
  ]
}


resource "aws_glue_job" "TRF_glue_job_taxi_load" {
  name          = "${local.prefix}_glue_job_taxi_load"
  role_arn      = aws_iam_role.glue_role.arn
  execution_property {
    max_concurrent_runs = 1
  }

  command {
    name     = "glueetl"
    script_location = "s3://${aws_s3_object.taxi_load_job_script.bucket}/glue-jobs/taxi_load.py"
    python_version = "3"
  }

  max_capacity = 2.0  # Allocates 2 DPUs to this job

  connections = [
    "data-academy-7_postgres_connection_intranet_0","data-academy-7_postgres_connection_intranet_1"
  ]


}





















/* CATALOG FOR TRANSFORMATION */
# resource "aws_glue_catalog_database" "TRF_glue_prepared_catalog" {
#   name     = "${local.prefix}_prepared_catalog"
# }


# /* CREATE TABLE IN THAT CATALOG FOR TRANSFORMATION */
# resource "aws_glue_catalog_table" "example_table" {
#   database_name = aws_glue_catalog_database.TRF_glue_prepared_catalog.name
#   name          = "table_citibike"
#   table_type    = "EXTERNAL_TABLE"
#   parameters = {
#     "classification" = "parquet"
#   }

#   storage_descriptor {
#     location      = "s3://da7-qxz50zr-prepared-bucket/citibike_coords_partitioned/"
#     input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
#     output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
#     ser_de_info {
#       name                  = "parquet_serde"
#       serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
#     }

#     columns {
#       name    = "ride_id"
#       type    = "string"
#     }

#     columns {
#       name    = "Start_Coordinate"
#       type    = "string"
#     }

#     columns {
#       name    = "End_Coordinate"
#       type    = "string"
#     }

#   }

#   # Define partition keys for the table
#   partition_keys {
#       name = "Start_Month"
#       type = "int"
#     }
# }
