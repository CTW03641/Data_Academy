
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
