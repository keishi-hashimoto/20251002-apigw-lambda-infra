resource "aws_dynamodb_table" "main" {
  name         = var.tablename
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "username"

  attribute {
    name = "username"
    type = "S"
  }
}