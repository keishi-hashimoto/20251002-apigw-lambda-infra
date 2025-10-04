data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name               = var.lambda_exec_role
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "put_item_for_lambda" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.main.arn]
  }
}

resource "aws_iam_policy" "dynamodb_put_item_role" {
  name   = "DynamoDBPutItemRole"
  policy = data.aws_iam_policy_document.put_item_for_lambda.json
}

resource "aws_iam_role_policy_attachment" "dynamodb_put_item_role" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.dynamodb_put_item_role.arn
}

resource "aws_lambda_function" "main" {
  filename = "dummy.zip"

  lifecycle {
    ignore_changes = [source_code_hash, filename]
  }
  function_name = var.function_name
  runtime       = "python3.13"
  handler       = "my_func.my_handler"
  role          = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      TABLENAME = var.tablename
    }
  }
}