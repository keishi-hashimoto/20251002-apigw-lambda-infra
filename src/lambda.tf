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