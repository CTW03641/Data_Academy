resource "aws_iam_role" "lambda_role" {
  name = "${local.prefix}_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${local.prefix}_lambda_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow" # Reading permissions for Source bucket
        Action = [
          "s3:GetObject",
          "s3:ListBucket",   # Must have this permission to perform ListObjectsV2 actions
          "s3:ListObjectsV2" # This permission corresponds to the newer version of the ListObjects API, introduced to overcome the limitations of the original ListObjects API
        ]
        Resource = [
          "${var.ING_source_bucket["bucket_arn"]}",  # Permissions on the bucket itself to list its objects
          "${var.ING_source_bucket["bucket_arn"]}/*" # Permission on its objects to copy them
        ]
      },
      {
        Effect = "Allow" # Reading and Write permissions for Storing buckets
        Action = [
          #"s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.GLB_storage_bucket.arn}",
          "${aws_s3_bucket.GLB_storage_bucket.arn}/*" # Permissions on both the bucket itself and all the objects inside the bucket
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment_lambda" { # Attach Policy to existing role
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}



# resource "aws_iam_role" "lambda_role" {
#   count = length(var.ING_lambda_folder_names) # each lambda must have a different role (since it will read from different folders)
#   name  = "${local.prefix}_lambda_role_${var.ING_lambda_folder_names[count.index]}"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "lambda_policy" {
#   count = length(var.ING_lambda_folder_names) # each lambda must have a different role with a different policy (since it will read from different folders)
#   name  = "${local.prefix}_lambda_policy_${var.ING_lambda_folder_names[count.index]}"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow" # Reading permissions for Source bucket
#         Action = [
#           "s3:GetObject",
#           "s3:ListBucket", # Must have this permission to perform ListObjectsV2 actions
#           "s3:ListObjectsV2" # This permission corresponds to the newer version of the ListObjects API, introduced to overcome the limitations of the original ListObjects API
#         ]
#         Resource = [
#           "${var.ING_source_bucket["bucket_arn"]}"
#           #"${var.ING_source_bucket["bucket_arn"]}/${var.ING_lambda_folder_names[count.index]}"
#         ]
#       },
#       {
#         Effect = "Allow" # Reading and Write permissions for Storing buckets
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:DeleteObject"
#         ]
#         Resource = [
#           "${aws_s3_bucket.GLB_storage_bucket.arn}/*", # Permissions on both the bucket itself and all the objects inside the bucket
#           "${aws_s3_bucket.GLB_storage_bucket.arn}"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "role_policy_attachment_lambda" {
#   count      = length(var.ING_lambda_folder_names)
#   policy_arn = aws_iam_policy.lambda_policy[count.index].arn
#   role       = aws_iam_role.lambda_role[count.index].name
# }