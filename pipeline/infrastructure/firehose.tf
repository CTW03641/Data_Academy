

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