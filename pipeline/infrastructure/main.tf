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
#   runtime       = "python3.8"
#   source_path   = "${path.module}/code/function.py"
#   attach_policy = true
#   policy        = aws_iam_policy.lambda_policy.arn

#   environment_variables = {
#     Ing_folder = var.ING_lambda_folder_names[count.index]
#   }

#   memory_size            = 256
#   ephemeral_storage_size = 2048
#   timeout                = 180

# }

# data "archive_file" "python_lambda_package" {
#   type = "zip"
#   source_file = "${path.module}/code/function.py"
#   output_path = "${path.module}/code/function.zip"
# }

resource "aws_s3_bucket" "ING_bucket" {
  bucket = "${var.GLB_project_name}-${var.GLB_identifier}"
}
