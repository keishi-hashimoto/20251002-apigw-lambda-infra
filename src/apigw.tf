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
  api_id = aws_apigatewayv2_api.main.id
  # $default だとフロントエンドからの OPTIONS リクエストを lambda に渡してしまうので、POST /
  route_key = "POST /"
  target    = "integrations/${aws_apigatewayv2_integration.main.id}"
}

resource "aws_apigatewayv2_stage" "main" {
  name   = "default"
  api_id = aws_apigatewayv2_api.main.id
  # auto_deploy が true なので depdeployment_id は指定不可
  # deployment_id = aws_apigatewayv2_deployment.main.id
  auto_deploy = true

  access_log_settings {
    destination_arn = data.aws_cloudwatch_log_group.lambda.arn
    format          = "{ \"requestId\" : \"$context.requestId\", \"extendedRequestId\" : \"$context.extendedRequestId\", \"ip\" : \"$context.identity.sourceIp\", \"caller\" : \"$context.identity.caller\", \"user\" : \"$context.identity.user\", \"requestTime\" : \"$context.requestTime\", \"httpMethod\" : \"$context.httpMethod\", \"resourcePath\" : \"$context.resourcePath\", \"status\" : \"$context.status\", \"protocol\" : \"$context.protocol\", \"responseLength\" : \"$context.responseLength\" }"
  }
}

resource "aws_apigatewayv2_deployment" "main" {
  api_id = aws_apigatewayv2_api.main.id

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    # CORS 設定変更時にはデプロイし直すようにする
    redeployment = sha1(join("", [jsonencode(aws_apigatewayv2_api.main), jsonencode(aws_apigatewayv2_route.name)]))
  }
}