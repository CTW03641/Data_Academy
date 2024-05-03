# resource "aws_iam_role" "lambda_role" {
#   name = "${local.prefix}_lambda_role"
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
#   name = "${local.prefix}_lambda_policy"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Resource = ["arn:aws:logs:*:*:*"]
#         }, {
#         Effect = "Allow"
#         Action = [
#           "ec2:CreateNetworkInterface",
#           "ec2:DescribeNetworkInterfaces",
#           "ec2:DeleteNetworkInterface"
#         ]
#         Resource = ["*"]
#         }, 
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:*",
#         ]
#         Resource = ["*"]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "role_policy_attachment_lambda" {
#   policy_arn = aws_iam_policy.lambda_policy.arn
#   role       = aws_iam_role.lambda_role.name
# }