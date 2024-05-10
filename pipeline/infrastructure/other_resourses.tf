/*LAMBDA ROLE*/

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
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:*"
        ]
        Resource = ["${aws_dynamodb_table.ING_dynamodb_timestamp.arn}"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment_lambda" { # Attach Policy to existing role
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

/*FIREHOSE ROLE*/
resource "aws_iam_role" "firehose_role" {
  name = "${local.prefix}_firehose_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}



resource "aws_iam_policy" "firehose_policy" {
  name = "${local.prefix}_firehose_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow" # Reading permissions for Source bucket
        Action = [
          "s3:*" # This permission corresponds to the newer version of the ListObjects API, introduced to overcome the limitations of the original ListObjects API
        ]
        Resource = [
          "${aws_s3_bucket.GLB_storage_bucket.arn}",
          "${aws_s3_bucket.GLB_storage_bucket.arn}/*" # Permissions on both the bucket itself and all the objects inside the bucket
        ]
      },
      {
        Effect = "Allow" # Reading permissions for Source bucket
        Action = [
          "kinesis:*" # This permission corresponds to the newer version of the ListObjects API, introduced to overcome the limitations of the original ListObjects API
        ]
        Resource = [
          "arn:aws:kinesis:eu-central-1:490288335462:stream/da7_data_stream"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment_firehose" { # Attach Policy to existing role
  policy_arn = aws_iam_policy.firehose_policy.arn
  role       = aws_iam_role.firehose_role.name
}


/*GLUE ROLE*/

resource "aws_iam_role" "glue_role" {
  name = "${local.prefix}_glue_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_policy" "glue_policy" {
  name = "GluePolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow" # Reading permissions for Source bucket
        Action = [
          "s3:*"
        ]
        Resource = [
          "${aws_s3_bucket.GLB_storage_bucket.arn}",   # Permissions on the bucket itself to list its objects
          "${aws_s3_bucket.GLB_storage_bucket.arn}/*", # Permission on its objects to copy them
          "${aws_s3_bucket.TRF_storage_bucket.arn}",   # Permissions on the bucket itself to list its objects
          "${aws_s3_bucket.TRF_storage_bucket.arn}/*"  # Permission on its objects to copy them
        ]
      },
      {
        Effect = "Allow" # Reading permissions for Source bucket
        Action = [
          "ec2:*"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow" # Reading permissions for Source bucket
        Action = [
          "glue:*"
        ]
        Resource = ["*"]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}