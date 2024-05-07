/*
Resources' Prefixes:
  ING - Resources used in services of Ingestion Layer
  TRF - Resources used in services of Transformation Layer
  SER - Resources used in services of Serving Layer
  GLB - Resources used across all AWS structure
*/

# module "ING_lambda_function" {
#   count         = length(var.ING_lambda_folder_names) # calculates the number of folders that contain the objects to ingest
#   source        = "terraform-aws-modules/lambda/aws"
#   version       = "7.2.5"
#   function_name = "${local.prefix}_lambda_ingestion_${var.ING_lambda_folder_names[count.index]}"
#   handler       = "function.lambda_handler"
#   runtime       = "python3.10"
#   source_path   = "${path.module}/code/function.py"
#   # attach_policy = true
#   # policy        = aws_iam_policy.lambda_policy.arn
#   role_name = aws_iam_role.lambda_role.name

#   environment_variables = {
#     Ing_folder = var.ING_lambda_folder_names[count.index]
#   }

#   memory_size            = 256
#   ephemeral_storage_size = 2048
#   timeout                = 300

#   # Specify the dependency on the creation and attachment of role and policy
#   depends_on = [
#     aws_iam_role_policy_attachment.role_policy_attachment_lambda
#   ]
# }

data "archive_file" "ING_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/code/function.py"
  output_path = "${path.module}/code/function.zip"
}

resource "aws_lambda_function" "ING_lambda_function" {
  count         = length(var.ING_lambda_folder_names) # calculates the number of folders that contain the objects to ingest
  function_name = "${local.prefix}_lambda_ingestion_${var.ING_lambda_folder_names[count.index]}"
  #role          = aws_iam_role.lambda_role[count.index].arn
  role    = aws_iam_role.lambda_role.arn
  runtime = "python3.10"

  filename         = data.archive_file.ING_lambda_package.output_path # Path to your ZIP file containing the function code
  source_code_hash = data.archive_file.ING_lambda_package.output_base64sha256
  handler          = "function.lambda_handler"

  environment {
    variables = {
      ING_FOLDER          = var.ING_lambda_folder_names[count.index]
      SOURCE_BUCKET_NAME  = var.ING_source_bucket["bucket_name"]
      STORAGE_BUCKET_NAME = aws_s3_bucket.GLB_storage_bucket.bucket
    }
  }

  memory_size = 128 #256
  timeout     = 300 #180
  #ephemeral_storage_size = 512

  # Specify the dependency on the creation and attachment of role and policy
  depends_on = [
    aws_iam_role_policy_attachment.role_policy_attachment_lambda
  ]
}


# resource "aws_s3_bucket_notification" "example_bucket_notification" {
#   bucket = var.ING_source_bucket["bucket_name"]
#   count  = length(var.ING_lambda_folder_names)

#   lambda_function {
#     lambda_function_arn = aws_lambda_function.ING_lambda_function[count.index].arn
#     events              = ["s3:ObjectCreated:*"]
#     filter_prefix       = "${var.ING_lambda_folder_names[count.index]}/"
#   }

#   depends_on = [
#     aws_lambda_function.ING_lambda_function
#   ]
# }


resource "aws_s3_bucket" "GLB_storage_bucket" {
  bucket = "${var.GLB_project_name}-${var.GLB_identifier}"
}
