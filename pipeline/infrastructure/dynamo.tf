
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