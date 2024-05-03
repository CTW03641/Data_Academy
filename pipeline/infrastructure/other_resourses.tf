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
        ]
        Resource = [
          "${var.ING_source_bucket["bucket_arn"]}/*", # Permissions on both the bucket itself and all the objects inside the bucket
          "${var.ING_source_bucket["bucket_arn"]}"
        ]
      },
      {
        Effect = "Allow" # Reading and Write permissions for Storing buckets
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.GLB_storage_bucket.arn}/*", # Permissions on both the bucket itself and all the objects inside the bucket
          "${aws_s3_bucket.GLB_storage_bucket.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment_lambda" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}