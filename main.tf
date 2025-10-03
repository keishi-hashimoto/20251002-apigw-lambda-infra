terraform {
  required_version = ">=1.13"
  required_providers {
    aws = {
      version = ">=6.0"
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {

  }
}

provider "aws" {
  default_tags {
    tags = {
      Category = "20251002-apigw-lambda"
      env      = terraform.workspace
    }
  }
}


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
}

resource "aws_apigatewayv2_api" "main" {
  name          = var.api_gateway_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins  = ["*"]
    allow_headers  = ["Content-Type"]
    allow_methods  = ["GET", "POST", "OPTIONS"]
    expose_headers = ["Content-Type", "Access-Control-Allow-Headers"]
  }
}


resource "aws_apigatewayv2_integration" "main" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.main.arn
  payload_format_version = "2.0"
}

resource "aws_lambda_permission" "main" {
  statement_id  = var.lambda_permission_statement_id
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  # どのステージやメソッドなども許容するために /* を付ける
  source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*"
}

resource "aws_apigatewayv2_route" "name" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.main.id}"
}

resource "aws_apigatewayv2_stage" "main" {
  name          = "default"
  api_id        = aws_apigatewayv2_api.main.id
  deployment_id = aws_apigatewayv2_deployment.main.id
}

resource "aws_apigatewayv2_deployment" "main" {
  api_id = aws_apigatewayv2_api.main.id

  lifecycle {
    create_before_destroy = true
  }
}