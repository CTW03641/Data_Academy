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
